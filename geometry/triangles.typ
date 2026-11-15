#import "util.typ": *

== Triangles

Kept because `minEnclosingCircle` and the orthocenter use it.

#code("triangles_ld.cpp")

=== Formulas

#ntable(
  title: [Notation],
  [$A, B, C$], [vertices (also the angles at them)],
  [$a, b, c$], [sides: $a = abs(B - C)$, $b = abs(C - A)$, $c = abs(A - B)$],
  [$s$, $S$], [$s = (a + b + c) / 2$; $S$ area],
  [$R$, $r$, $r_a$], [circumradius, inradius, exradius opposite $A$],
  [$h_a$, $m_a$, $t_a$], [from vertex $A$: altitude, median, angle bisector],
  [$O$, $I$, $I_A$, $G$, $H$], [circumcenter, incenter, excenter opposite $A$, centroid, orthocenter],
)

#ftable(
  title: [With the primitives],
  [Area (exact)], $ 2 S = abs(orient(A, B, C)) $,
  [Centroid], $ G = (A + B + C) / 3 $,
  [Orthocenter], $ H = A + B + C - 2 O $,
  [Circumcenter], $
    O = A + (u abs(w)^2 - w abs(u)^2)^perp / (2 (u times w)), quad u = B - A, thick w = C - A
  $,
  [Circumradius \ (collinear $-> oo$)], $ R = (a b c) / (2 abs(orient(A, B, C))) $,
  [Incenter], $ I = (a A + b B + c C) / (a + b + c) $,
  [Inradius], $ r = abs(orient(A, B, C)) / (a + b + c) $,
)

#ftable(
  title: [Laws],
  [Sines], $ a / (sin A) = b / (sin B) = c / (sin C) = 2 R $,
  [Cosines], $ c^2 = a^2 + b^2 - 2 a b cos C, quad cos C = (a^2 + b^2 - c^2) / (2 a b) $,
  [Tangents], $ (a - b) / (a + b) = frac(tan (A - B) / 2, tan (A + B) / 2) $,
  [Projection], $ a = b cos C + c cos B $,
  [Angle sum], $ A + B + C = pi $,
)

#ftable(
  title: [Area],
  [Base and height, two sides], $ S = 1 / 2 a h_a = 1 / 2 a b sin C $,
  [Heron], $ S = sqrt(s (s - a) (s - b) (s - c)) $,
  [Heron, exact with integer sides], $ 16 S^2 = 4 a^2 b^2 - (a^2 + b^2 - c^2)^2 $,
  [With the radii], $ S = (a b c) / (4 R) = r s = r_a (s - a) = sqrt(r thin r_a r_b r_c) $,
  [With the angles], $ S = 2 R^2 sin A sin B sin C = (a^2 sin B sin C) / (2 sin A) $,
)

#ftable(
  title: [Radii and lengths],
  [Circumradius], $ R = (a b c) / (4 S) = a / (2 sin A) $,
  [Inradius], $ r = S / s = (s - a) tan A / 2 $,
  [Exradius], $ r_a = S / (s - a) $,
  [Altitude], $ h_a = (2 S) / a = b sin C $,
  [Median], $ m_a = 1 / 2 sqrt(2 b^2 + 2 c^2 - a^2) $,
  [Angle bisector \ (splits $a$ in ratio $b : c$)], $ t_a = (2 b c cos A / 2) / (b + c) = sqrt(b c thin [(b + c)^2 - a^2]) / (b + c) $,
  [Stewart: cevian $A D$, $d = abs(A D)$, $m = abs(B D)$, $n = abs(D C)$], $ b^2 m + c^2 n = a (d^2 + m n) $,
  [Euler], $
    abs(O I)^2 = R (R - 2 r), quad R >= 2 r \
    abs(O H)^2 = 9 R^2 - (a^2 + b^2 + c^2)
  $,
)

#ftable(
  title: [Centers],
  [Excenter], $ I_A = (-a A + b B + c C) / (-a + b + c) $,
  [Euler line], [$O$, $G$, $H$ collinear, $arrow(O H) = 3 arrow(O G)$],
  [Centroid], [splits each median $2 : 1$ (from the vertex)],
)

#ftable(
  title: [Classification],
  [$a, b, c$ form a triangle], $ a < b + c, quad b < a + c, quad c < a + b $,
  [Kind, $c$ the largest side], $
    c^2 < a^2 + b^2 & "acute" \
    c^2 = a^2 + b^2 & "right" \
    c^2 > a^2 + b^2 & "obtuse"
  $,
  [Right, hypotenuse $c$], $ R = c / 2, quad r = (a + b - c) / 2, quad h_c = (a b) / c $,
  [Equilateral], $ S = sqrt(3) / 4 a^2, quad h = sqrt(3) / 2 a, quad R = a / sqrt(3), quad r = a / (2 sqrt(3)) $,
)
