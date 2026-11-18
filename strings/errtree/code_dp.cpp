struct Eertree {
    vector<array<int, 4>> nxt;
    vector<int> len, link, trans, dp, s;
    int last;
    Eertree(int n = 0) {
        for (auto* v : {&len, &link, &trans, &dp}) v->reserve(n + 2);
        nxt.reserve(n + 2);
        add_node(-1, 0); dp[0] = -1;     // imaginary root
        add_node(0, 0);  dp[1] = 0;      // empty string
        last = 1;
    }
    int add_node(int l, int lk) {
        nxt.push_back({}); len.push_back(l); link.push_back(lk);
        trans.push_back(1); dp.push_back(0);
        return (int)len.size() - 1;
    }
    int get_link(int v) {
        int n = s.size();
        while (true) {
            int i = n - 2 - len[v];
            if (i >= 0 && s[i] == s[n - 1]) return v;
            v = link[v];
        }
    }
    void push(int c) {
        s.push_back(c);
        int n = s.size();
        int p = get_link(last);
        if (!nxt[p][c]) {
            int w = add_node(len[p] + 2, 1);
            if (len[w] > 1) link[w] = nxt[get_link(link[p])][c];
            nxt[p][c] = w;
            if (len[w] <= 2) trans[w] = link[w];
            else {                        // longest palindromic suffix of w with length <= len[w]/2
                int t = trans[p];
                while ((len[t] + 2) * 2 > len[w] || s[n - 2 - len[t]] != c) t = link[t];
                trans[w] = nxt[t][c];
            }
            dp[w] = dp[p] + 2;            // add c on both sides
            if (len[w] % 2 == 0) {        // build the half, then double
                int t = trans[w];
                dp[w] = min(dp[w], dp[t] + 1 + len[w] / 2 - len[t]);
            }
        }
        last = nxt[p][c];
    }
};