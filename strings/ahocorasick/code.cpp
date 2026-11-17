struct AhoCorasick {
    struct Node {
        int next[26];
        int fail;
        vector<int> out;

        Node() {
            memset(next, -1, sizeof(next));
            fail = 0;
        }
    };

    vector<Node> trie;
    vector<string> patterns;
    vector<int> check;
    vector<int> vis;

    AhoCorasick() {
        trie.emplace_back(); // root
        vis.pb(true);
    }

    // 1️⃣ Insert patterns into trie
    void insert(const string &s) {
        int node = 0;
        for (char ch : s) {
            int c = ch - 'a';
            if (trie[node].next[c] == -1) {
                trie[node].next[c] = trie.size();
                trie.emplace_back();
                vis.pb(false);
            }
            node = trie[node].next[c];
        }
        trie[node].out.push_back(patterns.size());
        patterns.push_back(s);
        check.pb(false);
    }

    // 2️⃣ Build failure links
    void build() {
        queue<int> q;

        // Step A: depth-1 nodes
        for (int c = 0; c < 26; c++) {
            int v = trie[0].next[c];
            if (v != -1) {
                trie[v].fail = 0;
                q.push(v);
            } else {
                // missing edges point to root
                trie[0].next[c] = 0;
            }
        }

        // Step B: BFS
        while (!q.empty()) {
            int v = q.front(); q.pop();

            for (int c = 0; c < 26; c++) {
                int u = trie[v].next[c];
                if (u != -1) {
                    // core failure logic
                    int f = trie[v].fail;
                    while (trie[f].next[c] == -1)
                        f = trie[f].fail;

                    trie[u].fail = trie[f].next[c];

                    // propagate outputs
                    /*for (int id : trie[trie[u].fail].out)
                        trie[u].out.push_back(id);*/

                    q.push(u);
                } else {
                    // automaton completion
                    trie[v].next[c] = trie[trie[v].fail].next[c];
                }
            }
        }
    }

    // 3️⃣ Search text
    void search(const string &text) {
        int node = 0;
        for (int i = 0; i < (int)text.size(); i++) {
            int c = text[i] - 'a';
            node = trie[node].next[c];

            int temp = node;
            while (!vis[temp]) {
                for (int id : trie[temp].out)
                    check[id]++;
                //vis[temp]=true;
                temp = trie[temp].fail;
            }
        }
    }
};

//how to build the fail link tree.....
int n = ac.trie.size();
vector<vector<int>> fail_tree(n);
for (int i = 1; i < n; i++)
    fail_tree[ac.trie[i].fail].push_back(i);