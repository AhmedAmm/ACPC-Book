// Li Chao tree over integer x in [lo, hi], lines y = kx + b.
//   LiChao lc(lo, hi);          // max (default)
//   LiChao lc(lo, hi, false);   // min
//   lc.add(k, b);               // whole line              O(log)
//   lc.add(k, b, l, r);         // segment, x in [l, r]    O(log^2)
//   lc.query(x);                // best y at x, NONE if no line covers x
struct LiChao {
  struct fn {
    T k, b;
    T operator()(T x) { return k * x + b; }
  };
  int lo, hi;
  bool mx;
  T NONE;
  vector<fn> t;
  LiChao(int lo, int hi, bool mx = true)
      : lo(lo), hi(hi), mx(mx), NONE(mx ? MIN : INF),
        t(4 * (hi - lo + 1), fn{0, NONE}) {}

  bool better(T a, T b) { return mx ? a > b : a < b; }
  void add(T k, T b) { ins({k, b}, 1, lo, hi); }
  void add(T k, T b, int l, int r) { seg({k, b}, l, r, 1, lo, hi); }
  T query(T x) { return qry(x, 1, lo, hi); }

  void ins(fn f, int node, int l, int r) {
    int m = (l + r) >> 1;
    bool lef = better(f(l), t[node](l));
    bool mid = better(f(m), t[node](m));
    if (mid) swap(t[node], f);
    if (l == r) return;
    if (lef != mid) ins(f, 2 * node, l, m);
    else ins(f, 2 * node + 1, m + 1, r);
  }
  void seg(fn f, int ql, int qr, int node, int l, int r) {
    if (r < ql || qr < l) return;
    if (ql <= l && r <= qr) return ins(f, node, l, r);
    int m = (l + r) >> 1;
    seg(f, ql, qr, 2 * node, l, m);
    seg(f, ql, qr, 2 * node + 1, m + 1, r);
  }
  T qry(T x, int node, int l, int r) {
    T res = t[node](x);
    if (l == r) return res;
    int m = (l + r) >> 1;
    T sub = x <= m ? qry(x, 2 * node, l, m) : qry(x, 2 * node + 1, m + 1, r);
    return better(sub, res) ? sub : res;
  }
};
