// min squared distance between two of the points (n >= 2), O(n log n)
T closestPair(vector<pt> p) {
  sort(p.begin(), p.end());
  auto cmpY = [](pt a, pt b) { return make_pair(a.y, a.x) < make_pair(b.y, b.x); };
  set<pt, decltype(cmpY)> s(cmpY);
  T best = LLONG_MAX;
  for (int i = 0, j = 0; i < (int)p.size(); i++) {
    T d = ceill(sqrtl(best));
    while (p[i].x - p[j].x > d) s.erase(p[j++]);
    for (auto it = s.lower_bound(pt(LLONG_MIN, p[i].y - d));
         it != s.end() && it->y <= p[i].y + d; it++)
      best = min(best, sq(p[i] - *it));
    s.insert(p[i]);
  }
  return best;
}
