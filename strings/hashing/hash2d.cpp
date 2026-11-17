// 2D hashing (rectangle hash) - mod 2^61-1, two random bases (rows / columns)
// Build O(n*m), query O(1).
// Usage:
//   Hash2D A(grid);                 // grid = vector<string> (letters 'a'..'z')
//   A.get(x1, y1, x2, y2);          // hash of rows [x1,x2) x cols [y1,y2)
// Include after the template header (needs bits/stdc++.h, using namespace std).

typedef unsigned long long ull;
const ull MODH = (1ULL << 61) - 1;
mt19937_64 rng(chrono::steady_clock::now().time_since_epoch().count());
const ull BX = rng() % (MODH - 1000) + 500;   // base for rows
const ull BY = rng() % (MODH - 1000) + 500;   // base for columns

ull mulmod(ull a, ull b) {
    __uint128_t t = (__uint128_t) a * b;
    ull r = (ull) (t & MODH) + (ull) (t >> 61);
    if (r >= MODH) r -= MODH;
    return r;
}

ull addmod(ull a, ull b) {
    ull r = a + b;
    if (r >= MODH) r -= MODH;
    return r;
}

ull submod(ull a, ull b) {
    return a >= b ? a - b : a + MODH - b;
}

struct Hash2D {
    int n, m;
    vector<vector<ull>> h;
    vector<ull> px, py;                       // px[i] = BX^i, py[j] = BY^j

    // h[i+1][j+1] = h[i][j+1]*BX + h[i+1][j]*BY - h[i][j]*BX*BY + a[i][j]
    Hash2D(const vector<string> &a) {
        n = a.size();
        m = a[0].size();
        h.assign(n + 1, vector<ull>(m + 1, 0));
        px.assign(n + 1, 1);
        py.assign(m + 1, 1);
        for (int i = 0; i < n; i++) px[i + 1] = mulmod(px[i], BX);
        for (int j = 0; j < m; j++) py[j + 1] = mulmod(py[j], BY);
        ull bxy = mulmod(BX, BY);
        for (int i = 0; i < n; i++) {
            for (int j = 0; j < m; j++) {
                ull v = addmod(mulmod(h[i][j + 1], BX), mulmod(h[i + 1][j], BY));
                v = submod(v, mulmod(h[i][j], bxy));
                v = addmod(v, (ull) (a[i][j] - 'a' + 1));
                h[i + 1][j + 1] = v;
            }
        }
    }

    // hash of rectangle rows [x1,x2) x cols [y1,y2)
    ull get(int x1, int y1, int x2, int y2) {
        ull dx = px[x2 - x1], dy = py[y2 - y1];
        ull r = h[x2][y2];
        r = submod(r, mulmod(h[x1][y2], dx));
        r = submod(r, mulmod(h[x2][y1], dy));
        r = addmod(r, mulmod(h[x1][y1], mulmod(dx, dy)));
        return r;
    }
};

// ---- Example: 2D pattern matching (count occurrences of pattern P in grid G) ----
// IMPORTANT: build both with the SAME BX, BY (they are globals, so it is automatic).
//
// void solve() {
//     int n, m, p, q; cin >> n >> m >> p >> q;
//     vector<string> G(n), P(p);
//     for (auto &x : G) cin >> x;
//     for (auto &x : P) cin >> x;
//     Hash2D A(G), B(P);
//     ull target = B.get(0, 0, p, q);
//     int cnt = 0;
//     for (int i = 0; i + p <= n; i++)
//         for (int j = 0; j + q <= m; j++)
//             if (A.get(i, j, i + p, j + q) == target) cnt++;
//     cout << cnt << endl;
// }
//
// Rotation / flip: build a Hash2D on the transformed grid (rotate or reverse rows)
// and compare against the original's get().