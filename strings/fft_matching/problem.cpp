void solve() {
    int n;cin>>n;
    string s;
    cin >> s;
    vector<int> a(n), b(n);
    for (int i = 0; i < n; i++) {
        a[i] = (s[i] == 'V');
        b[n - 1 - i] = (s[i] == 'K');
    }
    vector<ll> c = multiply(a, b);
    vector<int> bad(n, 0);
    for (int idx = 0; idx < c.size(); idx++) {
        int d = abs(idx - (n - 1));
        if (d > 0 && d < n && c[idx] > 0) bad[d] = 1;
    }
    vector<ll> ans;
    for (int k = 1; k <= n; k++) {
        bool ok = true;
        for (int m = k; m < n; m += k) {
            if (bad[m]) { ok = false; break; }
        }
        if (ok) {
            ans.pb(k);
        }
    }
    cout<<ans.size()<<endl;
    for(auto x : ans)cout<<x<<" ";
    cout<<endl;
}