#import "util.typ": *

= Geometry

#ftable(
  title: [Notation used in all formulas],
  columns: (auto, auto, 1fr),
  $ v dot.op w $, [`dot(v, w)`], [$> 0$ acute, $= 0$ perpendicular, $< 0$ obtuse],
  $ v times w $, [`cross(v, w)`], [$> 0$ $w$ is ccw from $v$, $< 0$ cw, $= 0$ parallel],
  $ abs(p)^2 $, [`sq(p)`], [squared length, exact],
  $ abs(p) $, [`abs(p)`], [length],
  $ p^perp $, [`perp(p)`], [$(-y, x)$: $p$ rotated $+90 degree$ (ccw)],
  $ orient(A, B, C) $, [`orient(a, b, c)`], [$(B - A) times (C - A)$; $> 0$: $C$ left of $A B$],
  $ side_l (P) $, [`l.side(p)`], [$v times P - c$ for the line $l = (v, c)$],
)

#include "points.typ"
#include "lines.typ"
#include "segments.typ"
#include "triangles.typ"
#include "polygons.typ"
#include "circles.typ"
