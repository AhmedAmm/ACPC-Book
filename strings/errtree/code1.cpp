struct EertreeRB {
    static const int S = 26;
    vector<array<int, S>> nxt, quick;
    vector<int> len, link, st, en, cnt, oc, s;
    struct Rec { int prev_last, created, p; };
    vector<Rec> stk;
    int last;
    EertreeRB(int n = 0) {
        nxt.reserve(n + 2); quick.reserve(n + 2);
        for (auto* v : {&len, &link, &st, &en, &cnt, &oc}) v->reserve(n + 2);
        add_node(-1, 0);  // node 0: imaginary root, len -1
        add_node(0, 0);   // node 1: empty string
        last = 1;
    }
    int add_node(int l, int lk) {
        nxt.push_back({}); quick.push_back({});
        len.push_back(l); link.push_back(lk);
        st.push_back(0); en.push_back(-1); cnt.push_back(0); oc.push_back(0);
        return (int)len.size() - 1;
    }
    void push(int c) {
        s.push_back(c);
        int n = s.size(), pos = n - 1;
        auto ok = [&](int v) { int i = n - 2 - len[v]; return i >= 0 && s[i] == c; };
        int p = last;
        if (!ok(p)) p = quick[p][c];
        int created = -1;
        if (!nxt[p][c]) {
            int w = add_node(len[p] + 2, 1);
            int l = 1;
            if (len[w] > 1) {
                int x = link[p];
                int q = ok(x) ? x : quick[x][c];
                l = nxt[q][c];
            }
            link[w] = l;
            quick[w] = quick[l];
            quick[w][s[n - 1 - len[l]]] = l;
            nxt[p][c] = w;
            en[w] = pos; st[w] = pos - len[w] + 1; cnt[w] = 1 + cnt[l];
            created = w;
        }
        stk.push_back({last, created, p});
        last = nxt[p][c];
        oc[last]++;
    }
    void pop() {
        Rec r = stk.back(); stk.pop_back();
        int c = s.back(); s.pop_back();
        oc[last]--;
        if (r.created != -1) {
            nxt[r.p][c] = 0;
            nxt.pop_back(); quick.pop_back(); len.pop_back(); link.pop_back();
            st.pop_back(); en.pop_back(); cnt.pop_back(); oc.pop_back();
        }
        last = r.prev_last;
    }
    int distinct() { return (int)len.size() - 2; }
    vector<int> occurrences() {  // oc of every node for the current text (does not change the tree)
        vector<int> o = oc;
        for (int i = (int)len.size() - 1; i >= 2; i--) o[link[i]] += o[i];
        return o;
    }
};