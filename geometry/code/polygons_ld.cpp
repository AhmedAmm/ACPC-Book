// part of p on the left of line a->b (stays ccw if p is ccw); p convex
vector<pt> polygonCut(const vector<pt> &p, pt a, pt b) {
  vector<pt> res;
  for (int i = 0, n = p.size(); i < n; i++) {
    pt c = p[i], d = p[(i + 1) % n];
    ld oc = orient(a, b, c), od = orient(a, b, d);
    if (oc > -EPS) res.push_back(c);
    if ((oc > EPS && od < -EPS) || (oc < -EPS && od > EPS))
      res.push_back((c * od - d * oc) / (od - oc));
  }
  return res;
}
