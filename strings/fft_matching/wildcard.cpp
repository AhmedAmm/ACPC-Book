void solve() {
    string s, t;                       // s = text, t = pattern
    cin >> s >> t;
    int n = s.size(), m = t.size();

    vector<int> S1(n), S2(n), S3(n), T1(m), T2(m), T3(m);
    for (int i = 0; i < n; i++) {
        int v = (s[i] == '*' ? 0 : s[i] - 'a' + 1);
        S1[i] = v;
        S2[i] = v * v;
        S3[i] = v * v * v;
    }
    for (int j = 0; j < m; j++) {      // t reversed
        char ch = t[m - 1 - j];
        int v = (ch == '*' ? 0 : ch - 'a' + 1);
        T1[j] = v;
        T2[j] = v * v;
        T3[j] = v * v * v;
    }

    auto r1 = multiply(T3, S1);        // sum T^3 * S
    auto r2 = multiply(T2, S2);        // sum T^2 * S^2
    auto r3 = multiply(T1, S3);        // sum T   * S^3
    r1.resize(n + m - 1, 0);           // multiply() pops trailing zeros
    r2.resize(n + m - 1, 0);
    r3.resize(n + m - 1, 0);

    string out;
    for (int l = m - 1; l < n; l++) {  // window ends at l, starts at l-m+1
        long long w = r1[l] - 2 * r2[l] + r3[l];
        out += (w == 0 ? '1' : '0');
    }
    cout << out << endl;
}