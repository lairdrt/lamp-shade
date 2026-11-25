// Lamp Shade V0.8 -- dimensional prototype, not installation qualified.
// Z=0 at ceiling-facing upper lip; dome points upward in print coordinates.
mode="full"; // [full:ring]
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
function ramp_fraction(a)=clamp((u(a)+si+ra)/ra,0,1);
function ramp_h(a)=ramp_left_h+(clear_h-ramp_left_h)*ramp_fraction(a);
// Rising portion ends at the left inner tab edge; continue beneath tab.
// Follow the same rounded RHS return as the upper lip.
// Keep the 3 mm plateau. On the RHS, hold depth until the tab's
// return reaches that depth, then follow its actual radial path.
function ramp_rad(a)=ramp_depth*clamp((u(a)+si+ra)/ea,0,1)*
    (u(a)<=si?1:min(ramp_depth,slot(a))/ramp_depth);
// V0.6: both lip edges derive from a single rounded radial profile.
// Rectangular recess remains disabled. Preserve the ramp below the lip junction.
lip_join_h=2; // provisional smooth junction height (mm)
function ramp_wall_shift(a,z)=ramp_rad(a)*(ramp_h(a)>=clear_h?1:smooth((z-(t+clear_h-ramp_h(a))+0.15)/0.45));
function lip_inner(a)=ri-slot(a);
function lip_outer(a)=lip_inner(a)+t+overhang;
// Connect the full-width displaced lip to the shallower ramp continuously.
// Blend only within the tab region and the first lip_join_h mm below the lip.
function shift(a,z)=let(b=abs(u(a))<=so?smooth((t+lip_join_h-z)/lip_join_h):0)
    (1-b)*ramp_wall_shift(a,z)+b*slot(a);
zs=[for(j=[0:44]) t+clear_h*j/44];
function ring_section(a)=concat(
 [[lip_outer(a),0],[lip_outer(a),t]],
 [for(z=zs) [rw-shift(a,z),z]],
 [[R-1,t+clear_h],[R,t+clear_h+0.6],[R,H-0.6],[R-1,H]],
 [[ri,H]],
 [for(j=[len(zs)-1:-1:0]) [ri-shift(a,zs[j]),zs[j]]],
 [[lip_inner(a),0]]);
function xyz(p,a)=[p[0]*cos(a),p[0]*sin(a),p[1]];
function section(a)=mode=="ring"?ring_section(a):full_section(a);
profile=[[0,0],[25,1.8],[50,7.2],[75,18.2],[90,28.8],[100,37.8],[105,43.2],[110,49.4],[112,53],[113.4,56],[114,59.5]];
function sec(i)=(profile[i+1][1]-profile[i][1])/(profile[i+1][0]-profile[i][0]);
function tangent(i)=i==0?0:i==len(profile)-1?sec(i-1):2/(1/sec(i-1)+1/sec(i));
function drop(i,u)=let(dx=profile[i+1][0]-profile[i][0],y0=profile[i][1],y1=profile[i+1][1]) (2*u^3-3*u^2+1)*y0+(u^3-2*u^2+u)*dx*tangent(i)+(-2*u^3+3*u^2)*y1+(u^3-u^2)*dx*tangent(i+1);
P=concat([for(i=[0:len(profile)-2],j=[0:11]) let(u=j/12) [(profile[i][0]+u*(profile[i+1][0]-profile[i][0]))*R/114,height-drop(i,u)*(height-H)/59.5]],[[R,H]]);
function inner(i)=let(p=P[i],a=P[max(0,i-1)],b=P[min(len(P)-1,i+1)],dx=b[0]-a[0],dz=b[1]-a[1],l=sqrt(dx*dx+dz*dz)) [max(0,p[0]+t*dz/l),p[1]-t*dx/l];
function full_section(a)=let(q=ring_section(a)) concat(
 [for(i=[0:len(zs)+4]) q[i]],
 [for(i=[len(P)-1:-1:0]) P[i]],
 [for(i=[0:len(P)-2]) if(inner(i)[1]>H+0.1) inner(i)],
 [[R-t,H],[ri,H]],
 [for(j=[len(zs)-1:-1:0]) [ri-shift(a,zs[j]),zs[j]]],
 [[lip_inner(a),0]]);
module model(){
 pts=[for(i=[0:N-1]) each [for(p=section(i*360/N)) xyz(p,i*360/N)]];
 faces=[for(i=[0:N-1],j=[0:M-1]) each let(a=i*M+j,b=i*M+(j+1)%M,c=((i+1)%N)*M+(j+1)%M,d=((i+1)%N)*M+j)
 concat(pts[a]==pts[b]||pts[b]==pts[c]||pts[c]==pts[a]?[]:[[a,b,c]],pts[a]==pts[c]||pts[c]==pts[d]||pts[d]==pts[a]?[]:[[a,c,d]])];
 polyhedron(points=pts,faces=faces,convexity=12);
}
M=len(section(0));
model();
