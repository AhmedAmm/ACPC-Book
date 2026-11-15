#import "util.typ": *

== Circles

`ld` only. Uses `circumCenter` from Triangles.

#code("circles_ld.cpp")

=== Formulas

Circle of center $O$ and radius $r$. With `ld`, clamp $h^2$: $h^2 < -#`EPS` =>$ none, else $h^2 <- max(h^2, 0)$; $h^2 < #`EPS` =>$ tangent (1 point).

#ftable(
  title: [Intersections and tangents],
  [Circle $∩$ line $l = (v, c)$ \ (points ordered along $v$)], $
    h^2 = r^2 - side(O)^2 / abs(v)^2, quad M = proj_l (O) \
    "points:" M plus.minus v sqrt(h^2) / abs(v)
  $,
  [Circle $(O_1, r_1) ∩ (O_2, r_2)$ \ ($D = 0$: concentric, no point --- or identical if $r_1 = r_2$)], $
    d = O_2 - O_1, quad D = abs(d)^2 \
    e = (D + r_1^2 - r_2^2) / 2, quad h^2 = r_1^2 - e^2 / D \
    "points:" O_1 + d thin e / D plus.minus d^perp sqrt(h^2 / D)
  $,
  [Common tangents of $(O_1, r_1)$, $(O_2, r_2)$ \ outer ones as is, inner ones with $r_2 <- -r_2$; $r_2 = 0$ gives the tangents from the point $O_2$],
  [
    $
      d = O_2 - O_1, quad D = abs(d)^2 \
      delta = r_1 - r_2, quad h^2 = D - delta^2
    $
    none if $D = 0$ or $h^2 < 0$; $h^2 = 0$: one tangent. \ For each sign $s = plus.minus 1$:
    $ u = (d thin delta + s thin d^perp sqrt(h^2)) / D $
    touches circle 1 at $O_1 + r_1 u$ and circle 2 at $O_2 + r_2 u$
  ],
)

$O = (x_0, y_0)$; $theta$ a central angle (radians); $h$ distance from $O$ to a chord; sagitta: from the chord's midpoint to the arc.

#ftable(
  title: [Basics],
  [Equation], $ (x - x_0)^2 + (y - y_0)^2 = r^2 $,
  [$x^2 + y^2 + D x + E y + F = 0$], $ O = (-D / 2, -E / 2), quad r^2 = (D^2 + E^2) / 4 - F $,
  [Point at angle $theta$], $ O + r (cos theta, sin theta) $,
  [Diameter $[A B]$], $ O = (A + B) / 2, quad r = abs(A B) / 2 $,
  [Area, circumference], $ S = pi r^2, quad L = 2 pi r $,
  [Arc], $ r theta $,
  [Sector], $ 1 / 2 r^2 theta $,
  [Circular segment], $ 1 / 2 r^2 (theta - sin theta) $,
  [Chord], $ 2 r sin theta / 2 = 2 sqrt(r^2 - h^2) $,
  [Sagitta], $ r - h = r - sqrt(r^2 - ("chord" \/ 2)^2) $,
)

A line through $P$ cuts the circle at $A, B$, another one at $C, D$; $T$ a tangency point from $P$.

#ftable(
  title: [Angles and power],
  [Inscribed angle], [$1 / 2$ of the central angle on the same arc],
  [Angle in a semicircle], $ 90 degree $,
  [Power of $P$ \ $> 0$ outside, $= 0$ on, $< 0$ inside], $ pw(P) = abs(P - O)^2 - r^2 = (A - P) dot.op (B - P) $,
  [Secants], $ P A dot.op P B = P C dot.op P D = abs(pw(P)) $,
  [Tangent length], $ abs(P T) = sqrt(abs(P - O)^2 - r^2) $,
  [Angle between $P - O$ and $T - O$], $ arccos r / abs(P - O) $,
  [Radical axis \ ${P : pw_1 (P) = pw_2 (P)}$], $
    cline(2 (O_2 - O_1)^perp, thick abs(O_1)^2 - abs(O_2)^2 - r_1^2 + r_2^2)
  $,
)

$d = abs(O_1 O_2)$; $M$ midpoint of the common chord, $h$ its half-length; $alpha_i$ central angle of the common chord in circle $i$, ${i, j} = {1, 2}$.

#ftable(
  title: [Two circles],
  [Outer tangent length], $ sqrt(d^2 - (r_1 - r_2)^2) $,
  [Inner tangent length], $ sqrt(d^2 - (r_1 + r_2)^2) $,
  [Common chord], $ abs(O_1 M) = (d^2 + r_1^2 - r_2^2) / (2 d), quad h = sqrt(r_1^2 - abs(O_1 M)^2) $,
  [Lens area], $
    alpha_i = 2 arccos (d^2 + r_i^2 - r_j^2) / (2 d r_i), quad S = sum_i 1 / 2 r_i^2 (alpha_i - sin alpha_i)
  $,
)

#ftable(
  title: [Number of common tangents],
  columns: (1fr, auto),
  $ d > r_1 + r_2 $, [4],
  $ d = r_1 + r_2 $, [3],
  $ abs(r_1 - r_2) < d < r_1 + r_2 $, [2],
  $ d = abs(r_1 - r_2) $, [1],
  $ d < abs(r_1 - r_2) $, [0],
)
