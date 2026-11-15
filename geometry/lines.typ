#import "util.typ": *

== Lines

#code("lines.cpp")

#ntable(
  [`line(v, c)`], [direction $v$, points $P$ with $v times P = c$],
  [`line(a, b, c)`], [$a x + b y = c$, direction $(b, -a)$],
  [`line(p, q)`], [through $p$ and $q$, oriented $p -> q$; `line(q, p)` swaps left and right],
  [`side(p)`], [$> 0$ left of $v$, $< 0$ right, $= 0$ on the line; $abs(side) = abs(v) dot.op "dist"$. \ `side` of `line(p, q)` $=$ `orient(p, q, ·)`],
)

=== Formulas

Line $l = (v, c)$, $side(P) = v times P - c$; two lines $l_i = (v_i, c_i)$.
With `ll`: everything without a $abs(v)$ is exact.

#ftable(
  title: [Operations],
  [Distance to $l$], $ dist(P, l) = abs(side(P)) / abs(v), quad dist^2 (P, l) = side(P)^2 / abs(v)^2 $,
  [Sort points along $l$], [by $v dot.op P$],
  [Projection], $ proj_l (P) = P - v^perp thin side(P) / abs(v)^2 $,
  [Reflection], $ refl_l (P) = P - v^perp thin (2 side(P)) / abs(v)^2 $,
  [Exact projection with `ll`],
  [
    $ abs(v)^2 proj_l (P) = P abs(v)^2 - v^perp side(P) $
    (same for $refl$ with $2 side$); safe for $abs(x) <= 5 dot.op 10^5$; lattice point iff both coordinates are divisible by $abs(v)^2$
  ],
  [Intersection],
  [
    $ l_1 ∩ l_2 = (c_1 v_2 - c_2 v_1) / (v_1 times v_2) $
    none if $v_1 times v_2 = 0$ ($abs(dot.op) <$ `EPS` with `ld`)
  ],
  [$l_1 parallel l_2$], $ v_1 times v_2 = 0 $,
  [$l_1 perp l_2$], $ v_1 dot.op v_2 = 0 $,
  [Perpendicular through $P$],
  [
    $ cline(P, thick P + v^perp) $
    points to the left of $l$; meets $l$ at $proj_l (P)$
  ],
  [Translate by $t$], $ cline(v, thick c + v times t) $,
  [Shift left by distance $d$ \ ($d < 0$: right)], $ cline(v, thick c + d abs(v)) $,
  [Perpendicular bisector of $[P Q]$ \ ($P$ on its left; exact)], $ cline(2 (Q - P)^perp, thick abs(P)^2 - abs(Q)^2) $,
  [Angle bisectors ($v_1 times v_2 != 0$) \ $+$: direction between $v_1$ and $v_2$], $ cline(v_2 / abs(v_2) plus.minus v_1 / abs(v_1), thick c_2 / abs(v_2) plus.minus c_1 / abs(v_1)) $,
)

$l: a x + b y = c$, normal $(a, b)$, direction $(b, -a)$; $P = (x_1, y_1)$, $Q = (x_2, y_2)$ on $l$; $P_0 = (x_0, y_0)$ any point; $m$ slope, $k$ $y$-intercept, $theta$ angle between two lines.

#ftable(
  title: [Reference (coordinates)],
  [Slope form], $ y = m x + k, quad m = (y_2 - y_1) / (x_2 - x_1) = tan theta $,
  [Point-slope form], $ y - y_1 = m (x - x_1) $,
  [Through $P$, $Q$], $ (y_1 - y_2) x + (x_2 - x_1) y = x_2 y_1 - x_1 y_2 $,
  [Distance from $P_0$ to $l$], $ abs(a x_0 + b y_0 - c) / sqrt(a^2 + b^2) $,
  [Distance between $a x + b y = c_1$ and $a x + b y = c_2$], $ abs(c_1 - c_2) / sqrt(a^2 + b^2) $,
  [Intersection (Cramer)], $ x = (c_1 b_2 - c_2 b_1) / (a_1 b_2 - a_2 b_1), quad y = (a_1 c_2 - a_2 c_1) / (a_1 b_2 - a_2 b_1) $,
  [Projection, $A in l$], $ proj_l (P) = A + ((P - A) dot.op v) / abs(v)^2 thin v $,
  [$l_1 parallel l_2$], $ m_1 = m_2 $,
  [$l_1 perp l_2$], $ m_1 m_2 = -1 $,
  [Angle between two lines], $ tan theta = abs((m_1 - m_2) / (1 + m_1 m_2)), quad cos theta = abs(v_1 dot.op v_2) / (abs(v_1) abs(v_2)) $,
)

=== Li Chao tree

Maintains lines $y = k x + b$ (or segments) over integer $x in [#`lo`, #`hi`]$ and answers "max (or min) $y$ at $x$".
Uses `T = ll`, `INF`, `MIN`; independent of `line`.

#code("lichao.cpp")

#ntable(
  [Idea], [each node keeps the line that wins at its midpoint; the loser can only win on one side (two lines cross at most once), so it is pushed into that half only],
  [Complexity], [`add` line $O(log n)$, `add` segment $O(log^2 n)$, `query` $O(log n)$. Memory: $4 (#`hi` - #`lo` + 1)$ lines],
  [Empty point], [`query(x) == lc.NONE` iff no inserted line / segment covers $x$],
  [Overflow], [$abs(k x + b)$ must fit in `ll` over the whole node range, not just $[l, r]$ of a segment],
  [Large / sparse $x$], [build over indices $0 .. abs(#`xs`) - 1$ of the sorted query coordinates and evaluate at the real value: replace `f(l)`, `f(m)`, `t[node](x)` by `f(xs[l])`, `f(xs[m])`, `t[node](xs[i])`],
  [Typical uses], [CHT DP $d p_i = min_j (k_j x_i + b_j)$ with arbitrary insertion / query order; upper envelope of segments (CSES 3428)],
)
