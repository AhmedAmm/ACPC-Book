struct RollbackDSU {
    struct State {
        int x, p;
        ll old_pot;
        int old_sz;
    };

    int flaw;
    vector<ll> pot;
    vector<int> prec, sz;
    vector<State> snapshot;

    RollbackDSU() {}
    RollbackDSU(int n) { initialize(n); }

    void initialize(int n) {
        flaw = 0;
        snapshot.clear();
        pot.assign(n + 1, 0);
        prec.resize(n + 1);
        sz.assign(n + 1, 1);
        for (int i = 0; i <= n; i++) prec[i] = i;
    }

    // No path compression, so rollback stays valid.
    // Union by size keeps the depth at O(log n).
    pair<int, ll> find(int x) {
        if (prec[x] == x) return {x, 0};

        auto [r, p] = find(prec[x]);

        return {r, pot[x] ^ p};
        // DIFFERENCE VERSION: return {r, pot[x] + p};
    }

    int save() {
        return snapshot.size();
    }

    void rollback(int checkpoint) {
        while ((int)snapshot.size() > checkpoint) {
            auto [x, p, old_pot, old_sz] = snapshot.back();
            snapshot.pop_back();

            if (x == -1) { // A recorded contradiction
                flaw--;
                continue;
            }

            if (x == -2) { // A recorded no-op
                continue;
            }

            prec[x] = x;
            pot[x] = old_pot;
            sz[p] = old_sz;
        }
    }

    // Add equation:
    // XOR:        value[a] ^ value[b] = d
    // DIFFERENCE: value[a] - value[b] = d
    void merge(int a, int b, ll d) {
        auto [ra, pa] = find(a);
        auto [rb, pb] = find(b);

        // Already connected
        if (ra == rb) {
            if ((pa ^ pb) != d) { // DIFFERENCE VERSION: (pa - pb) != d
                flaw++;
                snapshot.push_back({-1, -1, -1, -1});
            }
            else {
                snapshot.push_back({-2, -2, -2, -2});
            }
            return;
        }

        // Union by size: attach the smaller root ra under rb
        if (sz[ra] > sz[rb]) {
            swap(ra, rb);
            swap(pa, pb);

            // XOR VERSION: Nothing to change
            // DIFFERENCE VERSION: d = -d;
        }

        snapshot.push_back({ra, rb, pot[ra], sz[rb]});

        prec[ra] = rb;

        pot[ra] = d ^ pa ^ pb;
        // DIFFERENCE VERSION: pot[ra] = d - pa + pb;

        sz[rb] += sz[ra];
    }

    bool ok() {
        return flaw == 0;
    }
};