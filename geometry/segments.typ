#import "util.typ": *

== Segments

#code("segments.cpp")

#ntable(
  [`onSegment(a, b, p)`], [$P in [A B]$, endpoints included],
  [`properInter(a, b, c, d)`], [crossing in the interior of both (touching / collinear $=>$ `false`)],
  [`segInter(a, b, c, d)`], [any common point, endpoints and overlaps included],
  [With `ld`], [the `== 0` / `sgn` tests are exact: replace by $abs(dot.op) <$ `EPS` if the input is not exact],
)

=== Formulas

#ftable(
  title: [Segments $[A B]$ and $[C D]$, $P$ any point, $o_X = orient(C, D, X)$],
  [$P in [A B]$], $ orient(A, B, P) = 0 and (A - P) dot.op (B - P) <= 0 $,
  [Proper crossing], $
    orient(C, D, A) dot.op orient(C, D, B) < 0 \
    and orient(A, B, C) dot.op orient(A, B, D) < 0
  $,
  [Crossing point \ (if `properInter`)], $ (A o_B - B o_A) / (o_B - o_A) $,
  [$dist(P, [A B])$],
  [
    if $A != B$ and $0 < (B - A) dot.op (P - A) < abs(B - A)^2$:
    $ abs(orient(A, B, P)) / abs(B - A) $
    otherwise:
    $ min(abs(P - A), abs(P - B)) $
  ],
  [$dist([A B], [C D])$],
  [
    $0$ if `properInter`, otherwise:
    $
      min(& dist(A, [C D]), dist(B, [C D]), \
        & dist(C, [A B]), dist(D, [A B]))
    $
  ],
  [\# lattice points on $[A B]$], $ gcd(abs(Delta x), abs(Delta y)) + 1 $,
  [All of $[A B] ∩ [C D]$], [if `properInter`: the crossing point above. Otherwise the `set<pt>` of those of $A, B$ that are on $[C D]$ and those of $C, D$ that are on $[A B]$: size 0 none, 1 one point, 2 the overlap is the segment between them],
)
