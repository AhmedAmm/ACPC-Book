// # ccw turns of p around a (cw polygon: -1); a not on the boundary
int winding(const vector<pt> &p, pt a) {
  int w = 0;
  for (int i = 0, n = p.size(); i < n; i++) {
    pt u = p[i], v = p[(i + 1) % n];
    if (u.y <= a.y && a.y < v.y && orient(u, v, a) > 0) w++;
    if (v.y <= a.y && a.y < u.y && orient(u, v, a) < 0) w--;
  }
  return w;
}
// strict: boundary counts as outside
bool inPolygon(const vector<pt> &p, pt a, bool strict = true) {
  for (int i = 0, n = p.size(); i < n; i++)
    if (onSegment(p[i], p[(i + 1) % n], a)) return !strict;
  return winding(p, a) != 0;
}

// ccw, starts at the lexicographically smallest point, O(n log n)
vector<pt> convexHull(vector<pt> p, bool keepCollinear = false) {
  sort(p.begin(), p.end());
  p.erase(unique(p.begin(), p.end()), p.end());
  int n = p.size(), k = 0;
  if (n < 3) return p;
  if (keepCollinear) { // all collinear: return them all
    bool col = true;
    for (pt q : p) col &= orient(p[0], p[n - 1], q) == 0;
    if (col) return p;
  }
  auto bad = [&](pt a, pt b, pt c) {
    T o = orient(a, b, c);
    return keepCollinear ? o < 0 : o <= 0;
  };
  vector<pt> h(2 * n);
  for (int i = 0; i < n; i++) {
    while (k >= 2 && bad(h[k - 2], h[k - 1], p[i])) k--;
    h[k++] = p[i];
  }
  for (int i = n - 2, t = k + 1; i >= 0; i--) {
    while (k >= t && bad(h[k - 2], h[k - 1], p[i])) k--;
    h[k++] = p[i];
  }
  h.resize(k - 1);
  return h;
}

// point in convex polygon, O(log n). p: ccw, no 3 collinear, n >= 3
bool inConvex(const vector<pt> &p, pt a, bool strict = true) {
  int n = p.size(), l = 1, r = n - 1;
  T o1 = orient(p[0], p[1], a), o2 = orient(p[0], p[n - 1], a);
  if (o1 < 0 || o2 > 0) return false;
  if (strict && (o1 == 0 || o2 == 0)) return false;
  while (r - l > 1) {
    int m = (l + r) / 2;
    (orient(p[0], p[m], a) >= 0 ? l : r) = m;
  }
  T o = orient(p[l], p[r], a);
  return strict ? o > 0 : o >= 0;
}
