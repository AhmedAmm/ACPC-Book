#include <bits/stdc++.h>
using namespace std;
typedef long long ll;

const int N = 2e5 + 5;

// ---------- Lazy segment tree: range add, range max ----------
struct LazySeg {
    int n;
    vector<ll> mx, lz;

    void init(int _n) {
        n = _n;
        mx.assign(4 * n + 4, 0);
        lz.assign(4 * n + 4, 0);
    }
    void apply(int x, ll v) { mx[x] += v; lz[x] += v; }
    void push(int x) {
        if (lz[x]) {
            apply(2 * x, lz[x]);
            apply(2 * x + 1, lz[x]);
            lz[x] = 0;
        }
    }
    void pull(int x) { mx[x] = max(mx[2 * x], mx[2 * x + 1]); }

    // point assign (used while loading initial values)
    void upd(int pos, ll v, int x = 1, int l = 1, int r = -1) {
        if (r == -1) r = n;
        if (l == r) { mx[x] = v; lz[x] = 0; return; }
        push(x);
        int m = (l + r) / 2;
        if (pos <= m) upd(pos, v, 2 * x, l, m);
        else upd(pos, v, 2 * x + 1, m + 1, r);
        pull(x);
    }
    // range add
    void add(int ql, int qr, ll v, int x = 1, int l = 1, int r = -1) {
        if (r == -1) r = n;
        if (qr < l || r < ql) return;
        if (ql <= l && r <= qr) { apply(x, v); return; }
        push(x);
        int m = (l + r) / 2;
        add(ql, qr, v, 2 * x, l, m);
        add(ql, qr, v, 2 * x + 1, m + 1, r);
        pull(x);
    }
    // range max
    ll query(int ql, int qr, int x = 1, int l = 1, int r = -1) {
        if (r == -1) r = n;
        if (qr < l || r < ql) return LLONG_MIN;
        if (ql <= l && r <= qr) return mx[x];
        push(x);
        int m = (l + r) / 2;
        return max(query(ql, qr, 2 * x, l, m),
                   query(ql, qr, 2 * x + 1, m + 1, r));
    }
} s;

// ---------- HLD ----------
vector<int> adj[N];
int sz[N], heavy[N], top_[N], parent_[N], tin[N], tout[N], dep[N];
ll val[N];
int timer_ = 0;

void dfs_init(int v = 1, int p = 0) {
    dep[v] = dep[p] + 1;
    parent_[v] = p;
    heavy[v] = 0;
    sz[v] = 1;
    for (int c : adj[v]) {
        if (c == p) continue;
        dfs_init(c, v);
        sz[v] += sz[c];
        if (sz[c] > sz[heavy[v]]) heavy[v] = c;  // sz[0] == 0
    }
}

void dfs(int v = 1, int p = 0, int top = 1) {
    tin[v] = ++timer_;
    s.upd(tin[v], val[v]);
    top_[v] = top;
    if (heavy[v]) dfs(heavy[v], v, top);
    for (int c : adj[v]) {
        if (c == heavy[v] || c == p) continue;
        dfs(c, v, c);
    }
    tout[v] = timer_;
}

void init(int n) {
    s.init(n);
    timer_ = 0;
    dep[0] = 0;
    sz[0] = 0;
    dfs_init();
    dfs();
}

// add x to every node on path u..v (inclusive)
void path_update(int u, int v, ll x) {
    while (top_[u] != top_[v]) {
        if (dep[top_[u]] < dep[top_[v]]) swap(u, v);
        s.add(tin[top_[u]], tin[u], x);
        u = parent_[top_[u]];
    }
    if (dep[u] > dep[v]) swap(u, v);
    s.add(tin[u], tin[v], x);
}

// max over nodes on path u..v (inclusive)
ll path_query(int u, int v) {
    ll ans = LLONG_MIN;
    while (top_[u] != top_[v]) {
        if (dep[top_[u]] < dep[top_[v]]) swap(u, v);
        ans = max(ans, s.query(tin[top_[u]], tin[u]));
        u = parent_[top_[u]];
    }
    if (dep[u] > dep[v]) swap(u, v);
    ans = max(ans, s.query(tin[u], tin[v]));
    return ans;
}

void subtree_update(int v, ll x) { s.add(tin[v], tout[v], x); }
ll subtree_query(int v) { return s.query(tin[v], tout[v]); }

// ---------- Example driver ----------
// Input:
//   n q
//   val[1..n]
//   n-1 edges (u v)
//   q queries:
//     1 u v x   -> add x on path u..v
//     2 u v     -> print max on path u..v
//     3 v x     -> add x on subtree of v (rooted at 1)
//     4 v       -> print max on subtree of v
int main() {
    ios::sync_with_stdio(false);
    cin.tie(nullptr);

    int n, q;
    cin >> n >> q;
    for (int i = 1; i <= n; i++) cin >> val[i];
    for (int i = 0; i < n - 1; i++) {
        int u, v;
        cin >> u >> v;
        adj[u].push_back(v);
        adj[v].push_back(u);
    }
    init(n);

    while (q--) {
        int t;
        cin >> t;
        if (t == 1) {
            int u, v; ll x;
            cin >> u >> v >> x;
            path_update(u, v, x);
        } else if (t == 2) {
            int u, v;
            cin >> u >> v;
            cout << path_query(u, v) << "\n";
        } else if (t == 3) {
            int v; ll x;
            cin >> v >> x;
            subtree_update(v, x);
        } else {
            int v;
            cin >> v;
            cout << subtree_query(v) << "\n";
        }
    }
    return 0;
}