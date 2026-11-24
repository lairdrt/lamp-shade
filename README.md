# Lamp shade

Parametric OpenSCAD reverse-engineering prototype for a 228 mm ceiling shade. V0.1 is a dimensional prototype, not installation qualified. Original photographs remain private.

Open `models/lamp-shade.scad` in OpenSCAD. Set `mode` to `full` or `ring` to inspect the complete shade or mounting ring. Z=0 is the ceiling-facing lip; the model is inverted relative to installed orientation.

## Dimensional baseline (mm)
- Diameter 228, overall height 75 (approximate), material 2.
- Channel: outside wall inset 12, upper lip outward overhang 3, clear height 11, overall height 15.
- Three slots, assumed 120 degree spacing; width 34 approximate, inner width 19, backside inset 21, estimated 45 degree transitions and 0.5 corner radii. Direct 5 mm indentation estimate conflicts with absolute inset; absolute inset controls prototype.
- Rectangular recess directly beneath upper tab: width 19, height 4, radial depth 1.5, top flush with underside of tab.
- Ramp descends left when viewed externally in installed orientation; 72 chord, left height 4, right height 11, bottom flush with lower flange, radial depth transitions from 0 to 3 over initial 10, then remains 3. Connection to rectangle provisional.
- Dome profile is an approximate photo-based reconstruction, not calibrated metrology.

## Validation
Compare against original before printing. Actual mating fixture is remote; fit, heat resistance, creep, retention and light transmission remain unverified. Do not install an unqualified overhead printed part. Use a suitable listed replacement if thermal or retention safety cannot be established.
