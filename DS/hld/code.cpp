const int N = 2e5 + 5;
const int LG = 20;
vector<ll> adj[N];
int childs[N], par[N], bg[N], tin[N], tout[N], val[N], dep[N];
int up[N][LG];
Seg<ll> s;
int timer = 0;

void dfs_init(int v = 1, int p = 0) {
    dep[v] = dep[p] + 1;
    up[v][0] = p;
    for (int l = 1; l < LG; l++) {
        up[v][l] = up[up[v][l - 1]][l - 1];
    }
    bg[v] = 0;
    for (auto child: adj[v]) {
        if (child == p)continue;
        dfs_init(child, v);
        if (childs[child] > childs[bg[v]]) {
            bg[v] = child;
        }
        childs[v] += childs[child];
    }
    childs[v]++;
}

void dfs(int v = 1, int p = 0, int top = 1) {
    tin[v] = ++timer;
    s.upd(timer, val[v]);
    par[v] = top;
    if (bg[v])dfs(bg[v], v, top);
    for (auto child: adj[v]) {
        if (child == bg[v] || child == p) continue;
        dfs(child, v, child);
    }
    tout[v] = timer;
}

void init() {
    s.init(N);
    dep[0] = 0;
    dfs_init();
    dfs();
}

int lca(int u, int v) {
    if (dep[u] < dep[v])swap(u, v);
    int k = dep[u] - dep[v];
    for (int l = 0; l < LG; l++) {
        if (k & (1 << l))u = up[u][l];
    }
    if (u == v) return u;
    for (int l = LG - 1; l >= 0; l--) {
        if (up[v][l] != up[u][l])u = up[u][l], v = up[v][l];
    }
    return up[v][0];
}

// u should be the ancesstor of v
int path(int v, int u) {
    ll ans = 0;
    while (v != u) {
        if (dep[par[v]] <= dep[u]) {
            ans = max(ans, s.query(tin[u] + 1, tin[v]));
            v = u;
        } else {
            ans = max(ans, s.query(tin[par[v]], tin[v]));
            v = up[par[v]][0];
        }
    }
    return ans;
}

int query(int v, int u) {
    ll l = lca(u, v);
    ll ans = path(v, l);
    ans = max(ans, path(u, l));
    ans = max(val[l], ans);
    return ans;
}