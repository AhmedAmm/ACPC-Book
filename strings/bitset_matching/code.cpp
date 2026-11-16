bitset<N> ok[26], ans;
 
void solve() {
    vector<int> p(26), pinv(26);
    for (int i = 0; i < 26; i++) cin >> p[i], p[i]--, pinv[p[i]] = i;
    string s, t;
    cin >> s >> t;
    int n = s.size();
    int m = t.size();
 
    // ok[c][q] = 1 if t[q] == c or t[q] == p[c]
    for (int q = 0; q < m; q++) {
        int x = t[q] - 'a';
        ok[x][q] = 1;
        ok[pinv[x]][q] = 1;
    }
 
    // window i survives only if every s[j] is allowed at i + j
    ans.set();
    for (int j = 0; j < n; j++)
        ans &= (ok[s[j] - 'a'] >> j);
 
    string out;
    for (int i = 0; i + n <= m; i++)
        out += (ans[i] ? '1' : '0');
    cout << out << endl;
}