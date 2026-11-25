// V0.17 mounting-ring test coupon -- frozen geometry from d3afd6f.
// Dimensional prototype only; not installation qualified.
// Z=0 at ceiling-facing upper lip; dome points upward in print coordinates.
od=228; height=75; t=2; wall_inset=12; overhang=3; clear_h=11;
slot_outer=34; slot_inner=19; slot_back=21; corner_r=0.5;
ramp_chord=72; ramp_left_h=4; ramp_depth=3; ramp_entry=6;
recess_h=4; recess_depth=1.5; lock_count=3; lock_phase=0;
N=720;
R=od/2; rw=R-wall_inset; ri=rw-t; H=clear_h+2*t;
slot_shift=slot_back-wall_inset-t;
function clamp(x,a,b)=min(max(x,a),b);
function smooth(x)=let(u=clamp(x,0,1)) u*u*(3-2*u);
function ang(ch,r)=2*asin(ch/(2*r));
si=ang(slot_inner,rw)/2; so=ang(slot_outer,rw)/2;
ra=ang(ramp_chord,rw); ea=ang(ramp_entry,rw);
function local(a)=((a-lock_phase+180/lock_count)% (360/lock_count)+360/lock_count)%(360/lock_count)-180/lock_count;
function u(a)=-local(a);
function rounded_linear(x,w,b)= x<=0?0:x>=w?1:b<=0?x/w:x<b?x*x/(2*b*(w-b)):x>w-b?1-(w-x)*(w-x)/(2*b*(w-b)):(x-b/2)/(w-b);
function slot(a)=slot_shift*rounded_linear(so-abs(u(a)),so-si,min((so-si)/3,corner_r/rw*180/PI));
// V0.17: preserve ramp start and radial envelope; finish the rising
// upper edge exactly at the left boundary of the rectangular recess.
function ramp_fraction(a)=clamp((u(a)+si+ra)/(si+ra-recess_half_angle),0,1);
function ramp_h(a)=ramp_left_h+(clear_h-ramp_left_h)*ramp_fraction(a);
// Rising portion ends at the left inner tab edge; continue beneath tab.
// Follow the same rounded RHS return as the upper lip.
// Keep the 3 mm plateau. On the RHS, hold depth until the tab's
// return reaches that depth, then follow its actual radial path.
function ramp_rad(a)=ramp_depth*clamp((u(a)+si+ra)/ea,0,1)*
    (u(a)<=si?1:min(ramp_depth,slot(a))/ramp_depth);
// V0.11 diagnostic: only the accepted V0.8 ramp defines the wall.
// Keep slot() solely as the reference for the unchanged RHS return.
// No independent tab notch, rectangular recess, or lip junction blend.
// Diagnostic circular upper lip: both top edges are independent of ramp.
// Existing section topology connects the inner top edge to the wall at z=t
// with a bevel where necessary; the outer underside spans to the wall.
function ramp_wall_shift(a,z)=ramp_rad(a)*(ramp_h(a)>=clear_h?1:smooth((z-(t+clear_h-ramp_h(a))+0.15)/0.45));
// V0.15: a single local recess relative to the accepted V0.14 wall.
// Start directly at the underside of the upper lip; no upper-edge gate.
// Keep the lip outline and the underlying ramp functions unchanged.
// Match the actual flat portion of the clipped upper tab, not nominal si.
// Invert the same rounded slot function by bisection; preserve the tab and ramp.
function tab_half_angle(lo=0,hi=so,n=32)=n==0?(lo+hi)/2:
    let(m=(lo+hi)/2, d=slot_shift*rounded_linear(so-m,so-si,min((so-si)/3,corner_r/rw*180/PI)))
    d>ramp_depth ? tab_half_angle(m,hi,n-1) : tab_half_angle(lo,m,n-1);
recess_half_angle=tab_half_angle();
recess_enabled=true;
recess_edge=0.5;
function recess_offset(a,z)=recess_enabled && z>=t && z<t+recess_h ?
    recess_depth*smooth((recess_half_angle-abs(u(a)))/(recess_edge/rw*180/PI))*
    smooth((t+recess_h-z)/recess_edge) : 0;
function shift(a,z)=ramp_wall_shift(a,z)+recess_offset(a,z);
// V0.13: lip-only tab. Use the accepted ramp's RHS return exactly.
// Limit the tab displacement to the ramp depth to avoid a reversed
// underside or an oversized bevel where the lip joins the wall.
// Mirror the accepted RHS profile on the LHS; wall remains untouched.
function lip_tab_shift(a)=min(ramp_depth,slot(a));
function lip_inner(a)=ri-lip_tab_shift(a);
function lip_outer(a)=rw+overhang-lip_tab_shift(a);
zs=[for(j=[0:44]) t+clear_h*j/44];
function ring_section(a)=concat(
 [[lip_outer(a),0],[lip_outer(a),t]],
 [for(z=zs) [rw-shift(a,z),z]],
 [[R-1,t+clear_h],[R,t+clear_h+0.6],[R,H-0.6],[R-1,H]],
 [[ri,H]],
 [for(j=[len(zs)-1:-1:0]) [ri-shift(a,zs[j]),zs[j]]],
 [[lip_inner(a),0]]);
function xyz(p,a)=[p[0]*cos(a),p[0]*sin(a),p[1]];

// One complete ramp + tab, with unmodified ring cross-sections.
// u=-52..15 covers ramp start -46.679 and RHS end +9.594 degrees.
// Original angular grid spacing 0.5 degrees; no Boolean cut.
// Planar end caps use the same winding as the original side mesh.
module coupon(){
    first=-15; last=52; step=360/N;
    K=round((last-first)/step)+1;
    M=len(ring_section(first));
    pts=[for(i=[0:K-1]) each [for(p=ring_section(first+i*step)) xyz(p,first+i*step)]];
    sides=[for(i=[0:K-2],j=[0:M-1]) each
        let(a=i*M+j,b=i*M+(j+1)%M,c=(i+1)*M+(j+1)%M,d=(i+1)*M+j)
        concat(pts[a]==pts[b]||pts[b]==pts[c]||pts[c]==pts[a]?[]:[[a,b,c]],
               pts[a]==pts[c]||pts[c]==pts[d]||pts[d]==pts[a]?[]:[[a,c,d]])];
    caps=[[for(j=[M-1:-1:0]) j],[for(j=[0:M-1]) (K-1)*M+j]];
    polyhedron(points=pts,faces=concat(sides,caps),convexity=12);
}
// Lower flange on build plate; no dome; rotate to convenient bed orientation.
translate([0,0,H]) rotate([180,0,0]) rotate([0,0,-18.5]) coupon();
