#import "util.typ": *

== Polygons

*Common*
#code("polygons.cpp")

*`ll` only*
#code("polygons_ll.cpp")

*`ld` only*
#code("polygons_ld.cpp")

#ntable(
  [`winding(p, a)`], [\# ccw turns of $p$ around $a$ ($-1$ for a cw polygon), exact; undefined on the boundary. Works for self-intersecting polygons],
  [`inPolygon(p, a, strict)`], [$a$ inside $p$, $O(n)$; on the boundary $=>$ `!strict`. Any simple polygon, either orientation],
  [`convexHull(p, keepCollinear)`], [ccw, starts at the smallest $(x, y)$, no repeated last point, duplicates removed. `keepCollinear` keeps the points on hull edges (all collinear $=>$ all of them, sorted)],
  [`inConvex(p, a, strict)`], [$O(log n)$; needs ccw, $n >= 3$, no 3 collinear vertices (hull without `keepCollinear`)],
  [`closestPair(p)`], [_squared_ smallest distance between two points ($n >= 2$), $O(n log n)$],
  [`polygonCut(p, a, b)`], [keeps the part left of $arrow(A B)$ (points on the line kept); correct for convex $p$. Intersection of a few half-planes: cut a big box repeatedly, $O(n^2)$],
)

=== Formulas

Polygon $P_0, ..., P_(n-1)$, indices mod $n$; $S$ area, $C$ centroid of the area; $(Delta x, Delta y) = P_(i+1) - P_i$.

#ftable(
  title: [General],
  [Signed area (exact) \ $> 0$ ccw, $< 0$ cw: reverse it], $
    2 S_"signed" = sum_(i=0)^(n-1) P_i times P_(i+1), quad S = 1 / 2 abs(2 S_"signed")
  $,
  [Convex \ (collinear vertices allowed)], [all $orient(P_i, P_(i+1), P_(i+2)) >= 0$, or all $<= 0$],
  [Centroid \ (either orientation, $S != 0$)], $
    C = 1 / (3 dot.op 2 S_"signed") sum_i (P_i + P_(i+1)) (P_i times P_(i+1))
  $,
  [Pick],
  [
    $ S = I + B / 2 - 1 $
    $I$ interior lattice points, $B = sum gcd(abs(Delta x), abs(Delta y))$ boundary ones
  ],
  [Interior angle sum], $ (n - 2) pi $,
  [Exterior angle sum], $ 2 pi $,
  [\# diagonals], $ (n (n - 3)) / 2 $,
)

#ftable(
  title: [Regular $n$-gon --- side $a$, circumradius $R$, inradius $r$],
  [Side], $ a = 2 R sin pi / n = 2 r tan pi / n $,
  [Interior angle], $ ((n - 2) pi) / n $,
  [Area], $ S = 1 / 2 n R^2 sin (2 pi) / n = n r^2 tan pi / n = (n a^2) / (4 tan pi / n) $,
)

Sides $a, b, c, d$ in order, $s = (a + b + c + d) / 2$, diagonals $p, q$ meeting at angle $theta$. Trapezoid: $a, b$ the parallel sides, $h$ the distance between them.

#ftable(
  title: [Quadrilaterals],
  [Any convex], $ S = 1 / 2 p q sin theta $,
  [Trapezoid], $ S = (a + b) / 2 h $,
  [Cyclic (Brahmagupta)], $ S = sqrt((s - a) (s - b) (s - c) (s - d)) $,
  [Cyclic $<==>$], [opposite angles sum to $pi$],
  [Ptolemy (cyclic)], $ p q = a c + b d $,
)
