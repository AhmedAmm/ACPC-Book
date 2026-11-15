// smallest circle containing all points (center, radius), expected O(n)
pair<pt, ld> minEnclosingCircle(vector<pt> p) {
  shuffle(p.begin(), p.end(), mt19937(time(0)));
  pt o = p[0];
  ld r = 0;
  for (int i = 0, n = p.size(); i < n; i++) if (abs(p[i] - o) > r + EPS) {
    o = p[i], r = 0;
    for (int j = 0; j < i; j++) if (abs(p[j] - o) > r + EPS) {
      o = (p[i] + p[j]) / 2, r = abs(p[i] - o);
      for (int k = 0; k < j; k++) if (abs(p[k] - o) > r + EPS)
        o = circumCenter(p[i], p[j], p[k]), r = abs(p[i] - o);
    }
  }
  return {o, r};
}
