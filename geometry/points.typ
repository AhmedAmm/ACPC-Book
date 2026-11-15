#import "util.typ": *

== Points and vectors

`T = long long` for exact / lattice problems, `T = long double` otherwise.

#code("points.cpp")

#ntable(
  title: [Primitives],
  [`/`], [only for `ld` (truncates with `ll`)],
  [`==`], [exact; with `ld` test $abs(a - b) < #`EPS`$ if needed. No `!=`: write `!(a == b)` (C++20 makes it for you)],
  [`<`], [lexicographic ($x$ then $y$), only for `sort` / `set` / `map`],
  [`sgn`], [$-1, 0, 1$. Multiply the `sgn`s of two `orient`s instead of the values (overflow with `ll`)],
  [`ll` overflow], [`cross` / `orient` of differences safe for $abs(x) <= 10^9$],
)

=== Polar sort

#code("polarsort.cpp")

#ntable(
  [`half(p)`], [true iff $arg p in (0, pi]$; needs $p != (0, 0)$],
  [`polarSort(v, o)`], [by angle around $o$ (default: origin) in $(-pi, pi]$, starting just after $-pi$; same direction: nearest first. Exact with `ll`],
)

=== Formulas

#ftable(
  title: [Basics --- $A = (x_1, y_1)$, $B = (x_2, y_2)$],
  [Distance], $ abs(A B) = abs(B - A) = sqrt((x_2 - x_1)^2 + (y_2 - y_1)^2) $,
  [Midpoint], $ M = (A + B) / 2 $,
  [Unit vector], $ hat(v) = v / abs(v) $,
  [Divide $A B$ in ratio $m : n$], $ P = (n A + m B) / (m + n) $,
  [Point of the segment], $ P(t) = A + t (B - A), quad t in [0, 1] $,
  [Normals of $p = (x, y)$], $ p^perp = (-y, x) "(left)", quad (y, -x) "(right)" $,
  [From polar $(r, phi)$], $ (r cos phi, thick r sin phi) $,
)

#ftable(
  title: [Tests],
  [$v parallel w$], $ v times w = 0 $,
  [$v perp w$], $ v dot.op w = 0 $,
  [$A, B, C$ collinear], $ orient(A, B, C) = 0 $,
  [Symmetries of $orient$], $
    orient(A, B, C) &= orient(B, C, A) = orient(C, A, B) \
    &= -orient(B, A, C)
  $,
  [$P$ in the closed disk of diameter $[A B]$ \ ($angle A P B >= 90 degree$)], $ (A - P) dot.op (B - P) <= 0 $,
  [$X$ in the angle ($< 180 degree$) of rays $A B$, $A C$, borders included],
  [
    If $orient(A, B, C) < 0$ swap $B$ and $C$, then
    $ orient(A, B, X) >= 0 and orient(A, C, X) <= 0 $
  ],
)

`atan2l(y, x)` $in [-pi, pi]$, `acosl` $in [0, pi]$, `asinl` $in [-pi / 2, pi / 2]$; `PI = acosl(-1)`.

#ftable(
  title: [Angles],
  [Argument of $p$], $ arg p = atan2(y, x) $,
  [Signed angle from $v$ to $w$], $ theta = atan2(v times w, thick v dot.op w) in (-pi, pi] $,
  [Unoriented angle], $ abs(theta) in [0, pi] $,
  [Ccw angle in $[0, 2 pi)$], $ theta < 0 => theta <- theta + 2 pi $,
  [$angle B A C$], $ "same with" v = B - A, quad w = C - A $,
  [Cosine and sine], $ cos theta = (v dot.op w) / (abs(v) abs(w)), quad sin theta = (v times w) / (abs(v) abs(w)) $,
  [Degrees to radians], $ "rad" = "deg" dot.op pi / 180 $,
)

#ftable(
  title: [Transformations --- $p$ the point moved, $c$ a center, $theta$ a ccw angle],
  [Translate by $v$], $ p + v $,
  [Scale by $f$ around $c$], $ c + (p - c) f $,
  [Point reflection through $c$], $ 2 c - p $,
  [Rotate by $theta$ around $0$], $ rot_theta (p) = (x cos theta - y sin theta, thick x sin theta + y cos theta) $,
  [Rotate by $theta$ around $c$], $ c + rot_theta (p - c) $,
  [Quarter turns], $
    rot_90 (p) = p^perp = (-y, x), quad rot_(-90) (p) = (y, -x) \
    rot_180 (p) = -p
  $,
  [Rotate by the angle from $v$ to $w$], [no trig needed: take $cos theta$, $sin theta$ from the Angles table],
)

#ftable(
  title: [Complex numbers --- $(x, y) <-> x + y i$, $cis phi = cos phi + i sin phi$],
  [Product \ (lengths multiply, angles add)], $
    (a + b i)(c + d i) = (a c - b d) + (a d + b c) i \
    (r_1 cis phi_1)(r_2 cis phi_2) = r_1 r_2 cis(phi_1 + phi_2)
  $,
  [Conjugate], $ overline(a + b i) = a - b i $,
  [Dot and cross at once], $ overline(v) w = (v dot.op w) + (v times w) i $,
  [Similarity $f$ (rotation + scaling + translation) with $f(p)$, $f(q)$ known: image of any $r$], $ f(r) = f(p) + (r - p) (f(q) - f(p)) / (q - p) $,
  [Same without complex numbers], $
    u = q - p, quad w = f(q) - f(p), quad n = (u times w, thick u dot.op w) \
    f(r) = f(p) + (((r - p) times n, thick (r - p) dot.op n)) / abs(u)^2
  $,
)

#ftable(
  title: [Dot product --- $theta$ the angle between $v$ and $w$],
  [Definition], $ v dot.op w = abs(v) abs(w) cos theta = v_x w_x + v_y w_y $,
  [Properties], $ v dot.op (w + u) = v dot.op w + v dot.op u, quad v dot.op v = abs(v)^2 $,
  [Scalar projection of $w$ on $v$], $ (v dot.op w) / abs(v) $,
  [Vector projection of $w$ on $v$], $ (v dot.op w) / abs(v)^2 thin v $,
  [Law of cosines], $ abs(v - w)^2 = abs(v)^2 + abs(w)^2 - 2 thin v dot.op w $,
  [Parallelogram law], $ abs(v + w)^2 + abs(v - w)^2 = 2 abs(v)^2 + 2 abs(w)^2 $,
)

#ftable(
  title: [Cross product --- $theta$ the oriented angle from $v$ to $w$],
  [Definition], $
    v times w &= abs(v) abs(w) sin theta = v_x w_y - v_y w_x \
    &= mat(delim: "|", v_x, w_x; v_y, w_y)
  $,
  [Properties], $ w times v = -v times w, quad v times w = v^perp dot.op w $,
  [Signed distance from $w$'s tip to the line of $v$], $ (v times w) / abs(v) $,
  [Area of the parallelogram $(v, w)$], $ abs(v times w) $,
  [Area of the triangle $A B C$], $ 1 / 2 abs(orient(A, B, C)) $,
  [Lagrange], $ (v dot.op w)^2 + (v times w)^2 = abs(v)^2 abs(w)^2 $,
)

#ftable(
  title: [Trigonometry],
  [Pythagoras], $ sin^2 alpha + cos^2 alpha = 1 $,
  [Sine of a sum], $ sin(alpha plus.minus beta) = sin alpha cos beta plus.minus cos alpha sin beta $,
  [Cosine of a sum], $ cos(alpha plus.minus beta) = cos alpha cos beta minus.plus sin alpha sin beta $,
  [Tangent of a sum], $ tan(alpha plus.minus beta) = (tan alpha plus.minus tan beta) / (1 minus.plus tan alpha tan beta) $,
  [Double angle], $
    sin 2 alpha &= 2 sin alpha cos alpha \
    cos 2 alpha &= cos^2 alpha - sin^2 alpha \
    &= 1 - 2 sin^2 alpha = 2 cos^2 alpha - 1
  $,
)

#ftable(
  title: [Lattice (`ll`) --- integer $A$, $B$; integer direction $(Delta x, Delta y)$],
  [\# lattice points on $[A B]$], $ gcd(abs(x_2 - x_1), thick abs(y_2 - y_1)) + 1 $,
  [Canonical direction \ (equal $<==>$ parallel, either sense)],
  [
    $ ((Delta x) / g, (Delta y) / g), quad g = gcd(abs(Delta x), abs(Delta y)) $
    negated if $x < 0$ or ($x = 0$ and $y < 0$)
  ],
)
