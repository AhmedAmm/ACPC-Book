void solve() {
    vector<int> p(26);
    for (int i = 0; i < 26; i++) cin >> p[i], p[i]--;
    string s, t;
    cin >> s >> t;
    int n = s.size(), m = t.size();
    vector<long long> cnt(m - n + 1, 0);
 
    for (int a = 0; a < 26; a++) {
        if (s.find(char('a' + a)) == string::npos) continue;   
 
        vector<int> A(n), B(m);
        for (int i = 0; i < n; i++) A[i] = (s[n - 1 - i] - 'a' == a);   
        for (int j = 0; j < m; j++) {
            int x = t[j] - 'a';
            B[j] = (x == a || x == p[a]);
        }
 
        auto res = multiply(A, B);
        res.resize(n + m - 1, 0);                   
        for (int j = 0; j + n <= m; j++) cnt[j] += res[j + n - 1];
    }
 
    string out;
    for (int j = 0; j + n <= m; j++) out += (cnt[j] == n ? '1' : '0');
    cout << out << endl;
}