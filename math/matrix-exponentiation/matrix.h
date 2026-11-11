struct Matrix
{
    // UPDATE type before using
    using S = long double;
    int n, m;
    vector<vector<S>> a;

    Matrix(int n, int m) : n(n), m(m), a(n, vector<S>(m, 0)) {}

    Matrix operator*(const Matrix &other) const
    {
        Matrix c(n, other.m);
        for (int i = 0; i < n; i++)
        {
            for (int k = 0; k < m; k++)
            {
                for (int j = 0; j < other.m; j++)
                {
                    c.a[i][j] += a[i][k] * other.a[k][j];
                }
            }
        }
        return c;
    }
};

Matrix mat_pow(Matrix base, long long e)
{
    assert(base.n == base.m);

    Matrix res(base.n, base.n);
    for (int i = 0; i < base.n; i++)
    {
        res.a[i][i] = 1;
    }

    while (e > 0)
    {
        if (e & 1)
        {
            res = res * base;
        }
        base = base * base;
        e >>= 1;
    }
    return res;
}