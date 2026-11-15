// P on [AB], endpoints included
bool onSegment(pt a, pt b, pt p) {
  return orient(a, b, p) == 0 && dot(a - p, b - p) <= 0;
}
// single crossing point that is not an endpoint
bool properInter(pt a, pt b, pt c, pt d) {
  return sgn(orient(c, d, a)) * sgn(orient(c, d, b)) < 0 &&
         sgn(orient(a, b, c)) * sgn(orient(a, b, d)) < 0;
}
// [AB] and [CD] share at least one point
bool segInter(pt a, pt b, pt c, pt d) {
  return properInter(a, b, c, d) || onSegment(c, d, a) ||
         onSegment(c, d, b) || onSegment(a, b, c) || onSegment(a, b, d);
}
