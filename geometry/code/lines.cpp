struct line {
  pt v; // direction
  T c;  // points p with cross(v, p) = c
  line(pt v, T c) : v(v), c(c) {}
  line(T a, T b, T c) : v(b, -a), c(c) {} // ax + by = c
  line(pt p, pt q) : v(q - p), c(cross(v, p)) {}
  T side(pt p) { return cross(v, p) - c; } // > 0 left, < 0 right
};
