== Matrix Exponentiation

#raw(read("matrix.h"), lang: "cpp", block: true)

*Optimization Note:* For fixed-size matrices, use a 2D static array instead of `vector<vector<S>>` for a huge performance improvement:
```cpp
    int a[5][5];
    Matrix() : n(0), m(0) {}
    Matrix(int n, int m) : n(n), m(m) { memset(a, 0, sizeof(a)); }

    // Initialize manually
    Matrix init(1, 5);
    init.a[0][0] = 1;
```

=== Example Usage: Graph Paths

*Note:* For this example, type `S` in the `Matrix` template should be changed to `long long`, and the multiplication operation `*` should be updated to apply modulo arithmetic if required.

Counts the number of paths of length up to $k$ in a directed graph. The extra dimension $n$ acts as an accumulator.

#text(0.85em)[
  $
    mat(R_0, dots.h, R_n) = mat(1, dots.h, 1, 0) mat(
      C_(0,0), dots.h, C_(0,n-1), 1;
      dots.v, dots.down, dots.v, dots.v;
      C_(n-1,0), dots.h, C_(n-1,n-1), 1;
      0, dots.h, 0, 1
    )^(k+1)
  $
  $
    R_i =
    mat(arrow.r, 1, dots.h, 1, 0, arrow.l)
    mat(
      arrow.b;
      (t^(k+1))_(0,i);
      dots.v;
      (t^(k+1))_(n-1,i);
      (t^(k+1))_(n,i);
      arrow.t
    )
  $
]

```cpp
int n, m, k;
cin >> n >> m >> k;

Matrix t(n + 1, n + 1);

for (int i = 0; i < m; i++) {
    int u, v;
    cin >> u >> v;
    u--; v--;
    t.a[v][u] = 1;
}

for (int i = 0; i <= n; i++) {
    t.a[i][n] = 1;
}
Matrix tk = mat_pow(t, k);

Matrix initial(1, n + 1);

for (int i = 0; i < n; i++) {
    initial.a[0][i] = 1;
}
initial.a[0][n] = 0;

Matrix result = initial * tk * t;

cout << result.a[0][n] << "\n";
```

