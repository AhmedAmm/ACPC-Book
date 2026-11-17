struct SuffixAutomaton {
    struct node {
        int len, link, firstpos;
        map<char, int> nxt;
    };
    int sz, last;
    vector<node> t;
    vector<int> terminal;
    vector<long long> dp;
    vector<vector<int>> g;
    vector<bool> vis;
    vector<ll> ways;

    SuffixAutomaton() {}

    SuffixAutomaton(int n) {
        t.resize(2 * n);
        terminal.resize(2 * n, 0);
        dp.resize(2 * n, -1);
        sz = 1;
        last = 0;
        g.resize(2 * n);
        ways.resize(2 * n, -1);
        vis.resize(2 * n, 0);
        t[0].len = 0;
        t[0].link = -1;
        t[0].firstpos = 0;
    }

    void extend(char c) {
        int p = last;
        int cur = sz++;
        t[cur].len = t[last].len + 1;
        t[cur].firstpos = t[cur].len;
        p = last;
        while (p != -1 && !t[p].nxt.count(c)) {
            t[p].nxt[c] = cur;
            p = t[p].link;
        }
        if (p == -1) t[cur].link = 0;
        else {
            int q = t[p].nxt[c];
            if (t[p].len + 1 == t[q].len) t[cur].link = q;
            else {
                int clone = sz++;
                t[clone] = t[q];
                t[clone].len = t[p].len + 1;
                while (p != -1 && t[p].nxt[c] == q) {
                    t[p].nxt[c] = clone;
                    p = t[p].link;
                }
                t[q].link = t[cur].link = clone;
            }
        }
        last = cur;
    }

    void build_tree() {
        for (int i = 1; i < sz; i++) g[t[i].link].push_back(i);
    }

    void build(string &s) {
        for (int i = 0; i < s.size(); i++) {
            extend(s[i]);
            terminal[last] = 1;
        }
        build_tree();
    }

    long long cnt(int i) { //number of times i-th node occurs in the string
        if (dp[i] != -1) return dp[i];
        long long ret = terminal[i];
        for (auto &x: g[i]) ret += cnt(x);
        return dp[i] = ret;
    }

    ll calc(int v) {
        if (ways[v] != -1) return ways[v];
        ways[v] = 0;
        for (auto [c, node]: t[v].nxt) {
            ways[v] += dp[node] + calc(node);
        }
        return ways[v];
    }

    string kth(ll k) {
        cnt(0);
        calc(0);
        string ans = "";
        int cur = 0;
        while (true) {
            for (auto [c, node]: t[cur].nxt) {
                ll group = dp[node] + ways[node];
                if (k > group) {
                    k -= group;
                } else {
                    ans += c;
                    cur = node;
                    if (k <= dp[node]) return ans;
                    k -= dp[node];
                    break;
                }
            }
        }
    }

    long long count() {
        int ret = 0;
        for (int i = 0; i < sz; i++) {
            ret += t[i].len - t[t[i].link].len;
        }
        return ret;
    }

    int search(string ch) {
        int cur = 0;
        for (auto c: ch) {
            if (t[cur].nxt.count(c)) {
                cur = t[cur].nxt[c];
                continue;
            }
            return -1;
        }
        return t[cur].firstpos;
    }
};



//use this for finding the number of distinct substrings of a string that appear in at least k of m strings

// CHANGED: s is a vector<int>; letters are < 1000, separators are >= 1000
    void build(vector<int> &s) {
        int c = -1;                        // CHANGED: start at -1 (first char is a separator)
        for (int i = 0; i < (int)s.size(); i++) {
            extend(s[i]);
            if (s[i] < 1000) pref[c].pb(last);
            else c++;
        }
    }

    // CHANGED: replaces dfs(); no m x states matrix
    void calc(int m, int k) {
        vector<int> cnt(sz, 0), vis(sz, -1);
        for (int i = 0; i < m; i++)
            for (int p : pref[i])
                for (int u = p; u > 0 && vis[u] != i; u = t[u].link) {
                    vis[u] = i;
                    cnt[u]++;              // number of distinct strings containing state u
                }
        vector<int> order(sz);
        iota(order.begin(), order.end(), 0);
        sort(order.begin(), order.end(), [&](int x, int y) { return t[x].len < t[y].len; });
        vector<ll> f(sz, 0);
        for (int v : order) {
            if (v == 0) continue;
            f[v] = (cnt[v] >= k) ? t[v].len : f[t[v].link];
        }
        for (int i = 0; i < m; i++) {
            if (k == 1) {                  // every substring qualifies
                ll L = pref[i].size();
                ans[i] = L * (L + 1) / 2;
                continue;
            }
            for (int p : pref[i]) ans[i] += f[p];
        }
    }