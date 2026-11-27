int flaw;

int pot[N], prec[N];

vector<pair<int,int>> edges;

void initialize(int n) {
    flaw = 0;
    edges.clear();

    for (int i = 0; i <= n; i++) {
        prec[i] = i;
        pot[i] = 0;
    }
}

int find(int x) {
    if (prec[x] == x) return x;

    int p = prec[x];
    int rx = find(p);

    pot[x] += pot[p]; // CHANGE: XOR -> addition

    prec[x] = rx;
    return rx;
}

bool merge(int a, int b, int d) {
    int ra = find(a);
    int rb = find(b);

    if (ra == rb) {
        // CHANGE: Check difference instead of XOR
        if (pot[a] - pot[b] != d) {
            flaw++;
            return false;
        }
        return true;
    }

    // CHANGE: Derive potential from a - b = d
    pot[ra] = d - pot[a] + pot[b];

    prec[ra] = rb;

    return true;
}

// Returns value[a] - value[b], or INF if disconnected
int difference(int a, int b) {
    if (find(a) != find(b)) return INF;

    return pot[a] - pot[b];
}

vector<int> construct(int n) {
    vector<int> val(n + 1, 0);

    // Compress all paths
    for (int i = 1; i <= n; i++)
        find(i);

    // Every connected component gets an arbitrary root value = 0
    for (int i = 1; i <= n; i++) {
        if (prec[i] == i)
            val[i] = 0;
    }

    // CHANGE: XOR -> addition
    // value[i] = value[parent[i]] + pot[i]
    for (int i = 1; i <= n; i++) {
        if (prec[i] != i)
            val[i] = val[prec[i]] + pot[i];
    }

    // Each component has an independent additive constant.
    // Unlike XOR DSU, there is no universal ans/occ adjustment
    // that can be applied without knowing the problem's objective.

    return val;
}
