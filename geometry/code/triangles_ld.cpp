pt circumCenter(pt a, pt b, pt c) { // asserts: not collinear
  b = b - a, c = c - a;
  assert(cross(b, c) != 0);
  return a + perp(b * sq(c) - c * sq(b)) / cross(b, c) / 2;
}
