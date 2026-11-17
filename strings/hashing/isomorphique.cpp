typedef unsigned long long ull;
const ull MODH = (1ULL << 61) - 1;
mt19937_64 rng(chrono::steady_clock::now().time_since_epoch().count());
const ull X = rng() % (MODH - 1) + 1;          // random, chosen ONCE per run

ull mulmod(ull a, ull b) {
    __uint128_t t = (__uint128_t) a * b;
    ull r = (ull) (t & MODH) + (ull) (t >> 61);
    if (r >= MODH) r -= MODH;
    return r;
}

// ---------- Approach 1: randomized, h(v) = prod (X + h(child)) ----------
ull dfsH(int v, int p, vector<vector<int>> &g) {
    ull h = 1;                                  // leaf = empty product = 1
    for (int u : g[v]) {
        if (u == p) continue;
        ull c = X + dfsH(u, v, g);
        if (c >= MODH) c -= MODH;
        h = mulmod(h, c);
    }
    return h;
}

// ---------- Approach 2: exact, id(v) = ID[sorted child ids] ----------
map<vector<int>, int> ID;                       // SHARED between all trees
int dfsE(int v, int p, vector<vector<int>> &g) {
    vector<int> ch;
    for (int u : g[v]) {
        if (u == p) continue;
        ch.pb(dfsE(u, v, g));
    }
    sort(ch.begin(), ch.end());                 // sorting removes the order
    auto it = ID.find(ch);
    if (it == ID.end()) {
        int k = ID.size();
        ID[ch] = k;
        return k;
    }
    return it->second;
}

void solve() {
    int n;
    cin >> n;
    vector<vector<int>> g1(n + 1), g2(n + 1);
    for (int i = 0; i < n - 1; i++) {
        int a, b;
        cin >> a >> b;
        g1[a].pb(b), g1[b].pb(a);
    }
    for (int i = 0; i < n - 1; i++) {
        int a, b;
        cin >> a >> b;
        g2[a].pb(b), g2[b].pb(a);
    }

    // Approach 1
    if (dfsH(1, 0, g1) == dfsH(1, 0, g2)) yes else no

    // Approach 2
    if (dfsE(1, 0, g1) == dfsE(1, 0, g2)) yes else no
}