// maths library

// radius of earth (meters)
RE:6371000
PI:acos -1

// degrees <> radians
d2r:(PI%180)*
r2d:(180%PI)*

//haversine
hav:0.5*1-cos@
ahav:acos 1-2*

/ haversine formula (for spheres)
havf:{ahav sum hav[(-/)r]*1,prd cos first each r:d2r(x;y)}
