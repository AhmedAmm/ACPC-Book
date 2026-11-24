static int occ[N];

struct qry {
    int l, r, idx;
};

struct mo {
    vector<qry> qr;
    vector<ll> a;
    vector<ll> ans;
    ll n, q;
    ll l = 1, r = 0;
    ll aux = 0;

    void add(int pos) {
        if (occ[a[pos]] % 2)aux--;
        occ[a[pos]]++;
        if (occ[a[pos]] % 2)aux++;
    }

    void del(int pos) {
        if (occ[a[pos]] % 2)aux--;
        occ[a[pos]]--;
        if (occ[a[pos]] % 2)aux++;
    }

    mo(int nn, int qq, vector<qry> &qrr, vector<ll> &aa) {
        n = nn;
        q = qq;
        qr = qrr;
        a = aa;
        ans.assign(q + 1, 0);
        ll sq = n / (sqrt(q) + 1) + 1;

        //1:normal
        std::sort(qr.begin(), qr.end(), [&](qry &x, qry &y) {
            if (x.l / sq == y.l / sq) {
                return x.r < y.r;
            }
            return x.l / sq < y.l / sq;
        });

        //2:gilbert
        std::sort(qr.begin(), qr.end(), [&](qry &x, qry &y) {
            int bx = x.l / sq;
            int by = y.l / sq;

            if (bx != by)
                return bx < by;

            if (bx & 1)
                return x.r > y.r;
            return x.r < y.r;
        });
        
        for (auto x: qr) {
            while (r < x.r)add(++r);
            while (l > x.l)add(--l);
            while (l < x.l)del(l++);
            while (r > x.r)del(r--);
            ans[x.idx] = aux;
        }
    }
};