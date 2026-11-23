/* ============ SEGMENT TREE BEATS: range chmin / chmax / add, queries sum / max / min ============
   Operations on [l, r] (0-indexed, inclusive):
       chmin(l, r, x)   a[i] = min(a[i], x)
       chmax(l, r, x)   a[i] = max(a[i], x)
       add(l, r, x)     a[i] += x
       sum(l, r), mx(l, r), mn(l, r)
   Every node keeps:  mx  = maximum              se = strict SECOND maximum  (-INF if none)
                      mn  = minimum              sm = strict SECOND minimum  (+INF if none)
                      cmx = how many equal mx    cmn = how many equal mn     sum, len
   Lazy tag = a function  x -> min(hi, max(lo, x + a))   ("add a, then clamp to [lo, hi]").
   A tag is only applied to a node when it changes NOTHING except the max group and the min group
   (chmin needs x > se, chmax needs x < sm), so max/min/second values and the sum can be updated in O(1).
   Complexity: O((n + q) log^2 n) amortized.
   ========================================================================================= */
typedef long long ll;
const ll INF = (ll) 2e18;

struct SegTreeBeats {
    struct Node {
        ll mx, se, mn, sm, sum;
        ll gd;                                   // GCD: gcd of |a_i - se| over the middle elements
        int cmx, cmn, len;
    };
    struct Tag { ll a, lo, hi; };               // x -> min(hi, max(lo, x + a))

    int n;
    vector<Node> t;
    vector<Tag> lz;

    static Tag id() { return {0, -INF, INF}; }
    static ll f(const Tag &g, ll y) { return min(g.hi, max(g.lo, y + g.a)); }

    SegTreeBeats(const vector<ll> &a) {
        n = a.size();
        t.resize(4 * n);
        lz.assign(4 * n, id());
        build(1, 0, n - 1, a);
    }

    // ---- merge two children into v (max side, min side, sum) ----
    void pull(int v) {
        Node &x = t[v], &L = t[2 * v], &R = t[2 * v + 1];
        x.sum = L.sum + R.sum;
        if (L.mx == R.mx) { x.mx = L.mx; x.cmx = L.cmx + R.cmx; x.se = max(L.se, R.se); }
        else if (L.mx > R.mx) { x.mx = L.mx; x.cmx = L.cmx; x.se = max(L.se, R.mx); }
        else { x.mx = R.mx; x.cmx = R.cmx; x.se = max(L.mx, R.se); }
        if (L.mn == R.mn) { x.mn = L.mn; x.cmn = L.cmn + R.cmn; x.sm = min(L.sm, R.sm); }
        else if (L.mn < R.mn) { x.mn = L.mn; x.cmn = L.cmn; x.sm = min(L.sm, R.mn); }
        else { x.mn = R.mn; x.cmn = R.cmn; x.sm = min(L.mn, R.sm); }

        // GCD: middle elements of the parent = everything that is neither x.mx nor x.mn; reference value = x.se
        x.gd = 0;
        if (x.se > x.mn) {                       // there is at least one middle element (se itself)
            for (Node *c : {&L, &R}) {
                if (c->se > c->mn)               // child's own middle elements stay middle
                    x.gd = gcd(x.gd, gcd(c->gd, llabs(c->se - x.se)));
                if (c->mx != x.mx && c->mx != x.mn) x.gd = gcd(x.gd, llabs(c->mx - x.se));   // child's max group
                if (c->mn != x.mx && c->mn != x.mn) x.gd = gcd(x.gd, llabs(c->mn - x.se));   // child's min group
            }
        }
    }

    void build(int v, int l, int r, const vector<ll> &a) {
        t[v].len = r - l + 1;
        if (l == r) {
            t[v].mx = t[v].mn = t[v].sum = a[l];
            t[v].se = -INF; t[v].sm = INF;
            t[v].gd = 0;                         // GCD
            t[v].cmx = t[v].cmn = 1;
            return;
        }
        int m = (l + r) / 2;
        build(2 * v, l, m, a);
        build(2 * v + 1, m + 1, r, a);
        pull(v);
    }

    // ---- apply a tag to a node (must be "safe": only max / min groups are clamped) ----
    void apply(int v, const Tag &g) {
        if (g.a == 0 && g.lo == -INF && g.hi == INF) return;
        Node &x = t[v];
        if (x.mx == x.mn) {                      // all elements equal
            ll val = f(g, x.mx);
            x.mx = x.mn = val;
            x.sum = val * x.len;
            x.gd = 0;                            // GCD: no middle elements
        } else {
            ll nmx = f(g, x.mx), nmn = f(g, x.mn);
            x.sum += g.a * x.len + (nmx - x.mx - g.a) * x.cmx + (nmn - x.mn - g.a) * x.cmn;
            x.mx = nmx; x.mn = nmn;
            x.se = f(g, x.se);                   // a middle value only gets +a, but se may equal mn
            x.sm = f(g, x.sm);                   // (and sm may equal mx), so apply the whole function
        }
        Tag &o = lz[v];                          // lazy = g after o
        ll lo = min(max(o.lo + g.a, g.lo), g.hi);
        ll hi = min(max(o.hi + g.a, g.lo), g.hi);
        o = {o.a + g.a, lo, hi};
    }

    void push(int v) {
        apply(2 * v, lz[v]);
        apply(2 * v + 1, lz[v]);
        lz[v] = id();
    }

    // ---- updates ----
    void chmin(int v, int l, int r, int ql, int qr, ll x) {
        if (qr < l || r < ql || t[v].mx <= x) return;
        if (ql <= l && r <= qr && t[v].se < x) { apply(v, {0, -INF, x}); return; }   // only max group changes
        push(v);
        int m = (l + r) / 2;
        chmin(2 * v, l, m, ql, qr, x);
        chmin(2 * v + 1, m + 1, r, ql, qr, x);
        pull(v);
    }
    void chmax(int v, int l, int r, int ql, int qr, ll x) {
        if (qr < l || r < ql || t[v].mn >= x) return;
        if (ql <= l && r <= qr && t[v].sm > x) { apply(v, {0, x, INF}); return; }    // only min group changes
        push(v);
        int m = (l + r) / 2;
        chmax(2 * v, l, m, ql, qr, x);
        chmax(2 * v + 1, m + 1, r, ql, qr, x);
        pull(v);
    }
    void add(int v, int l, int r, int ql, int qr, ll x) {
        if (qr < l || r < ql) return;
        if (ql <= l && r <= qr) { apply(v, {x, -INF, INF}); return; }
        push(v);
        int m = (l + r) / 2;
        add(2 * v, l, m, ql, qr, x);
        add(2 * v + 1, m + 1, r, ql, qr, x);
        pull(v);
    }

    // ---- queries ----
    ll sum(int v, int l, int r, int ql, int qr) {
        if (qr < l || r < ql) return 0;
        if (ql <= l && r <= qr) return t[v].sum;
        push(v);
        int m = (l + r) / 2;
        return sum(2 * v, l, m, ql, qr) + sum(2 * v + 1, m + 1, r, ql, qr);
    }
    ll mx(int v, int l, int r, int ql, int qr) {
        if (qr < l || r < ql) return -INF;
        if (ql <= l && r <= qr) return t[v].mx;
        push(v);
        int m = (l + r) / 2;
        return max(mx(2 * v, l, m, ql, qr), mx(2 * v + 1, m + 1, r, ql, qr));
    }
    ll mn(int v, int l, int r, int ql, int qr) {
        if (qr < l || r < ql) return INF;
        if (ql <= l && r <= qr) return t[v].mn;
        push(v);
        int m = (l + r) / 2;
        return min(mn(2 * v, l, m, ql, qr), mn(2 * v + 1, m + 1, r, ql, qr));
    }

    // ---- GCD query ----
    ll nodeGcd(const Node &x) {                  // GCD: gcd of all the values of a node
        if (x.mx == x.mn) return llabs(x.mx);
        ll g = gcd(llabs(x.mx), llabs(x.mn));
        if (x.se > x.mn) g = gcd(g, gcd(llabs(x.se), x.gd));
        return g;
    }
    ll gcdq(int v, int l, int r, int ql, int qr) {
        if (qr < l || r < ql) return 0;
        if (ql <= l && r <= qr) return nodeGcd(t[v]);
        push(v);
        int m = (l + r) / 2;
        return gcd(gcdq(2 * v, l, m, ql, qr), gcdq(2 * v + 1, m + 1, r, ql, qr));
    }

    // ---- easy wrappers: [l, r] inclusive, 0-indexed ----
    ll qgcd(int l, int r) { return gcdq(1, 0, n - 1, l, r); }  // GCD
    void chmin(int l, int r, ll x) { chmin(1, 0, n - 1, l, r, x); }
    void chmax(int l, int r, ll x) { chmax(1, 0, n - 1, l, r, x); }
    void add(int l, int r, ll x) { add(1, 0, n - 1, l, r, x); }
    ll sum(int l, int r) { return sum(1, 0, n - 1, l, r); }
    ll mx(int l, int r) { return mx(1, 0, n - 1, l, r); }
    ll mn(int l, int r) { return mn(1, 0, n - 1, l, r); }
};