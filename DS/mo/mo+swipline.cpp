// Mo with sweepline: count pairs i<j in a range of prefix-xors with a[i]^a[j] == k.
// Idea: do NOT simulate the pointer moves; turn each move into an interval query on a prefix, answer all by one sweep.
const int N = 2e6 + 5;                      // size of the value domain (xor values)
const int BLK = 333;                        // block size of Mo (about n / sqrt(q))

int freq[N];                                // freq[v] = how many inserted t have a[t]^k == v

struct Node {
    int l, r, idx;                          // query range [l, r] on the prefix array, original index

    bool operator < (const Node &other) const {
        if (l / BLK != other.l / BLK)       // different blocks of l:
            return make_pair(l / BLK, r) <  // order by block first
                   make_pair(other.l / BLK, other.r);

        if ((l / BLK) & 1)                  // same block, odd block:
            return r > other.r;             // r goes down (snake order)

        return r < other.r;                 // same block, even block: r goes up
    }
};

void solve() {
    int n, q, k;
    cin >> n >> q >> k;

    /*
        a[i] = prefix xor
    */
    vector<int> a(n + 1, 0);                // a[0] = 0, so the subarray [x, y] is the pair (x-1, y)

    for (int i = 1; i <= n; i++) {
        int x;
        cin >> x;
        a[i] = a[i - 1] ^ x;                // prefix xor
    }

    vector<Node> qs(q);

    for (int i = 0; i < q; i++) {
        cin >> qs[i].l >> qs[i].r;
        qs[i].l--;                          // subarray [l, r] -> prefix range [l-1, r]
        qs[i].idx = i;                      // remember the input order
    }

    sort(qs.begin(), qs.end());             // Mo order
    vector<vector<array<int, 4>>> iv(n + 1);// iv[p] = interval queries {l, r, query, sign} asked at prefix p

    int cl = 0;                             // current range [cl, cr], starts empty
    int cr = -1;
    for (int i = 0; i < q; i++) {           // walk the pointers, but only RECORD the moves
        if (cr < qs[i].r) {                 // r goes right: new elements cr+1..r
            if (cl - 1 >= 0) {              // their pairs with [0, cl-1] must be removed (see formula)
                iv[cl - 1].pb({cr + 1, qs[i].r, i, -1});
            }
            cr = qs[i].r;
        }
        if (cl > qs[i].l) {                 // l goes left: new elements l..cl-1
            iv[cr].pb({qs[i].l,cl - 1,i,1});// their pairs with prefix [0, cr]
            cl = qs[i].l;
        }
        if (qs[i].r < cr) {                 // r goes left: elements r+1..cr leave
            if (cl - 1 >= 0) {
                iv[cl - 1].pb({qs[i].r + 1,cr,i,1});
            }
            cr = qs[i].r;
        }
        if (qs[i].l > cl) {                 // l goes right: elements cl..l-1 leave
            iv[cr].pb({cl,qs[i].l - 1,i,-1});
            cl = qs[i].l;
        }
    }

    vector<ll> before(n + 1, 0);            // before[i] = sum over x<=i of g(x, [0, x-1])
    vector<ll> me(n + 1, 0);                // me[i]     = sum over x<=i of g(x, [0, x])
    vector<ll> ans(q, 0);                   // sum of the interval parts, per sorted query

    for (int i = 0; i <= n; i++) {          // the sweep over the prefix p = i
        before[i] = (i ? before[i - 1] : 0) + freq[a[i]];   // freq[a[i]] = # t<i with a[t]^k == a[i]
        freq[a[i] ^ k]++;                   // insert i: it matches every j with a[j] == a[i]^k
        me[i] =(i ? me[i - 1] : 0) + freq[a[i]];            // same, but i itself is now inserted

        for (auto [l, r, idx, d] : iv[i]) { // every interval query asked at prefix i
            ll cnt = 0;
            for (int j = l; j <= r; j++) {
                cnt += freq[a[j]];          // g(j, [0, i]) in O(1)
            }
            ans[idx] += cnt * d;            // sign d: + when elements enter, - when they leave
        }
    }

    ll cur = 0;
    vector<ll> ret(q);
    for (int i = 0; i < q; i++) {
        cur += ans[i];                      // total of the interval parts up to this query (moves telescope)
        int l = qs[i].l;
        int r = qs[i].r;
        ret[qs[i].idx] = cur + before[r] + (l ? me[l - 1] : 0);  // + prefix parts of the final r and l
    }

    for (int i = 0; i < q; i++) {
        cout << ret[i] << endl;             // answers in the input order
    }
}