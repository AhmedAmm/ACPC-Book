template<typename T, T (*op)(T, T)>
struct spt {
    vector<vector<T>> v;
    vector<T> a;

    spt(int n, vector<T> &aa, int ID) {
        a = aa;
        int lg = __lg(n) + 1;
        v.assign(lg, vector<T>(n + 1, ID));
        for (int i = 1; i <= n; i++)v[0][i] = a[i];

        for (int bit = 1; bit < lg; bit++) {
            for (int i = 1; i <= n; i++) {
                int j = max(1ll, i - (1 << (bit - 1)));
                v[bit][i] = op(v[bit - 1][i], v[bit - 1][j]);
            }
        }
    }

    T qry(int l, int r) {
        int lg = __lg(r - l + 1);
        return op(v[lg][r], v[lg][l + (1 << lg) - 1]);
    }
};

ll mn(ll a, ll b) {
    return min(a, b);
}

ll mx(ll a, ll b) {
    return max(a, b);
}


struct node {
    int lf = 0, rg = 0;
};

void solve() {
    ll n;cin>>n;
    vector<ll> a(n+1);
    for(int i=1;i<=n;i++)cin>>a[i];
    spt<ll,mx> sa(n,a,0);
    vector<node> nodes(n+1);
    auto find = [&](int l, int r) -> int {
        ll ans = r;
        ll tst = sa.qry(l, r);
        ll mx = r, mn = l;
        while (mx >= mn) {
            ll md = (mx + mn) / 2;
            ll res = sa.qry(l, md);
            if (res == tst) {
                ans = md;
                mx = md - 1;
            } else {
                mn = md + 1;
            }
        }
        return ans;
    };
    function<int(int, int)> build = [&](int l, int r) -> int {
        if (l > r)return 0;
        if (l == r)return l;
        int id = find(l, r);
        nodes[id].lf = build(l, id - 1);
        nodes[id].rg = build(id + 1, r);
        return id;
    };
    int root = build(1, n);
    ll ans=0;
}