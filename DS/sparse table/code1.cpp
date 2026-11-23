struct DST {
    using T = long long;
    int n, LOG;
    vector<vector<T>> s;
    T ID = 0;
    // change this
    T comb(T a, T b) {
        return max(a, b);
    }
    DST(int _n, vector<T> &a) {
        n = _n;
        LOG = 32 - __builtin_clz(n) + 1;
        s.assign(LOG, vector<T>(n + 1, ID));
        for (int i = 1; i <= n; i++) s[0][i] = a[i];
        build();
    }

    void build() {
        for (int bit = 1; bit < LOG; bit++) {
            int len = 1 << bit;

            for (int l = 1; l <= n; l += len) {
                int r = min(n, l + len - 1);
                int mid = min(r, l + (len >> 1) - 1);

                // suffix on left half
                s[bit][mid] = s[0][mid];
                for (int i = mid - 1; i >= l; i--) {
                    s[bit][i] = comb(s[0][i], s[bit][i + 1]);
                }

                // prefix on right half
                if (mid + 1 <= r) {
                    s[bit][mid + 1] = s[0][mid + 1];
                    for (int i = mid + 2; i <= r; i++) {
                        s[bit][i] = comb(s[bit][i - 1], s[0][i]);
                    }
                }
            }
        }
    }

    T qry(int l, int r) {
        if (l == r) return s[0][l];
        int k = 31 - __builtin_clz((l - 1) ^ (r - 1)) + 1;
        return comb(s[k][l], s[k][r]);
    }
};