template<typename T>
struct Fenwick2D {
    int n, m;
    vector<vector<T>> fen;
    Fenwick2D(int _n = 0, int _m = 0) {
        init(_n, _m);
    }
    void init(int _n, int _m) {
        n = _n;
        m = _m;
        fen.assign(n + 1, vector<T>(m + 1, 0));
    }
    void update(int x, int y, T val) {
        for (int i = x; i <= n; i += i & -i) {
            for (int j = y; j <= m; j += j & -j) {
                fen[i][j] += val;
            }
        }
    }
    T query(int x, int y) const {
        T res = 0;
        for (int i = x; i > 0; i -= i & -i) {
            for (int j = y; j > 0; j -= j & -j) {
                res += fen[i][j];
            }
        }
        return res;
    }
    T query(int x1, int y1, int x2, int y2) const {
        return query(x2, y2) - query(x1 - 1, y2) - query(x2, y1 - 1) + query(x1 - 1, y1 - 1);
    }
};