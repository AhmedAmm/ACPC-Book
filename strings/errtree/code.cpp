struct Eertree {
    vector<array<int, 26>> nxt;
    vector<int> len, link, st, en, cnt, oc, s;
    int last;
    Eertree(int n = 0) {
        for (auto* v : {&len, &link, &st, &en, &cnt, &oc}) v->reserve(n + 2);
        nxt.reserve(n + 2);
        add_node(-1, 0);  // node 0: imaginary root, len -1
        add_node(0, 0);   // node 1: empty string
        last = 1;
    }
    int add_node(int l, int lk) {
        nxt.push_back({});
        len.push_back(l); link.push_back(lk);
        st.push_back(0); en.push_back(-1); cnt.push_back(0); oc.push_back(0);
        return (int)len.size() - 1;
    }
    int get_link(int v) {  // walk down the links until s[n-2-len[v]] == s[n-1]
        int n = s.size();
        while (true) {
            int i = n - 2 - len[v];
            if (i >= 0 && s[i] == s[n - 1]) return v;
            v = link[v];
        }
    }
    bool push(int c) {  // returns 1 if it creates a new palindrome
        s.push_back(c);
        int pos = s.size() - 1;
        int p = get_link(last);
        bool created = false;
        if (!nxt[p][c]) {
            int w = add_node(len[p] + 2, 1);
            if (len[w] > 1) link[w] = nxt[get_link(link[p])][c];
            nxt[p][c] = w;
            en[w] = pos; st[w] = pos - len[w] + 1;
            cnt[w] = 1 + cnt[link[w]];
            created = true;
        }
        last = nxt[p][c];
        oc[last]++;
        return created;
    }
    void calc_occurrences() {
        for (int i = (int)len.size() - 1; i >= 2; i--) oc[link[i]] += oc[i];
    }
};



// less memory 
struct Eertree {                       // transitions as linked lists: 1 edge per node
    vector<int> len, link, cnt, head, sib;
    vector<char> ch, s;
    int last;
    Eertree(int n = 0) {
        for (auto* v : {&len, &link, &cnt, &head, &sib}) v->reserve(n + 2);
        ch.reserve(n + 2); s.reserve(n);
        add_node(-1, 0);               // node 0: imaginary root
        add_node(0, 0);                // node 1: empty string
        last = 1;
    }
    int add_node(int l, int lk) {
        len.push_back(l); link.push_back(lk); cnt.push_back(0);
        head.push_back(0); sib.push_back(0); ch.push_back(0);
        return (int)len.size() - 1;
    }
    int find(int p, int c) {           // 0 means "no edge" (node 0 is never a child)
        for (int e = head[p]; e; e = sib[e]) if (ch[e] == c) return e;
        return 0;
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
        int p = get_link(last);
        int x = find(p, c);
        if (!x) {
            int w = add_node(len[p] + 2, 1);
            if (len[w] > 1) link[w] = find(get_link(link[p]), c);
            ch[w] = c; sib[w] = head[p]; head[p] = w;
            cnt[w] = 1 + cnt[link[w]];
            x = w;
        }
        last = x;
    }
};