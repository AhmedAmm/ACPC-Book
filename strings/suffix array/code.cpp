/* ===================== SUFFIX ARRAY (prefix doubling + counting sort) =====================
   HOW TO PUT THE STRING
       string s; cin >> s;
       s += '$';                           // sentinel: a unique char SMALLER than every letter
                                           // ('$' < 'A' < 'a' in ASCII). Without it the code sorts
                                           // cyclic shifts, not suffixes.
       vector<int> p, c;
       buildSuffixArray(s, p, c);          // O(n log n)
       vector<int> lcp = build_lcp(s, p, c);

   OUTPUT (n = s.size(), the sentinel is counted), example s = "banana$":
       i      : 0  1  2  3  4  5  6
       p[i]   : 6  5  3  1  0  4  2     p[i] = start index of the i-th smallest suffix
                                        ($, a$, ana$, anana$, banana$, na$, nana$)
       c[i]   : 4  3  6  2  5  1  0     c[i] = rank of the suffix starting at i  (c[p[i]] = i)
       lcp[i] : 0  0  1  3  0  0  2     lcp[i] = LCP(suffix p[i-1], suffix p[i]),  lcp[0] = 0
   ======================================================================================== */

// sort p by class c[p[i]]; stable, O(n). Classes are 0..n-1.
void count_sort(vector<int> &p, const vector<int> &c) {
    int n = p.size();
    vector<int> cnt(n, 0), pos(n, 0), p_new(n);
    for (int x : c) cnt[x]++;
    for (int i = 1; i < n; i++) pos[i] = pos[i - 1] + cnt[i - 1];   // start of each class
    for (int x : p) p_new[pos[c[x]]++] = x;
    p.swap(p_new);
}

void buildSuffixArray(const string &s, vector<int> &p, vector<int> &c) {
    int n = s.size();
    p.resize(n);
    c.assign(n, 0);
    // k = 0: order by the first letter only
    iota(p.begin(), p.end(), 0);
    sort(p.begin(), p.end(), [&](int a, int b) { return s[a] < s[b]; });
    for (int i = 1; i < n; i++) c[p[i]] = c[p[i - 1]] + (s[p[i]] != s[p[i - 1]]);
    // k -> k+1: order by the first 2^(k+1) letters = (class of first half, class of second half)
    for (int k = 0; (1 << k) < n; k++) {
        for (int i = 0; i < n; i++) p[i] = (p[i] - (1 << k) + n) % n;   // now p is sorted by SECOND half
        count_sort(p, c);                                               // stable sort by FIRST half
        vector<int> c2(n, 0);
        for (int i = 1; i < n; i++) {
            pair<int, int> a = {c[p[i - 1]], c[(p[i - 1] + (1 << k)) % n]};
            pair<int, int> b = {c[p[i]],     c[(p[i]     + (1 << k)) % n]};
            c2[p[i]] = c2[p[i - 1]] + (a != b);
        }
        c.swap(c2);
    }
}

// Kasai, O(n): go through suffixes in TEXT order; the lcp drops by at most 1 per step.
vector<int> build_lcp(const string &s, const vector<int> &p, const vector<int> &c) {
    int n = s.size(), k = 0;
    vector<int> lcp(n, 0);
    for (int i = 0; i < n; i++) {
        if (c[i] == 0) { k = 0; continue; }           // rank 0 has no previous suffix
        int j = p[c[i] - 1];                          // previous suffix in sorted order
        while (i + k < n && j + k < n && s[i + k] == s[j + k]) k++;
        lcp[c[i]] = k;
        k = max(k - 1, 0);
    }
    return lcp;
}

/* ---------- pattern search: the occurrences of t in s form ONE block of ranks [lb, ub) ----------
   Cut every suffix to its first |t| letters. In sorted order these cuts are sorted too.
   Example: s = "banana$", t = "an"
        rank  : 0   1    2    3    4    5    6
        suffix: $   a$   ana$ anan.. bana.. na$  nana$
        cut   : $   a$   an   an   ba   na   na
        vs t  : <   <    =    =    >    >    >
                          ^lb       ^ub
   lb = first rank whose cut is >= t   (first '=' or later)
   ub = first rank whose cut is >  t   (first '>')
   count = ub - lb = 2,   start positions = p[lb] .. p[ub-1] = 3, 1
   The two functions are IDENTICAL except for ONE line (marked "<-- the only change").
*/
int lb_suffix(const string &s, const vector<int> &p, const string &t) {
    int l = 0, r = p.size();                       // answer is in [0, n]
    while (l < r) {
        int mid = (l + r) / 2;
        int cmp = s.compare(p[mid], t.size(), t);  // cut vs t:  <0 smaller, 0 equal, >0 bigger (no copy)
        if (cmp >= 0) r = mid;                     // <-- the only change (lb: cut >= t)
        else l = mid + 1;
    }
    return l;
}

int ub_suffix(const string &s, const vector<int> &p, const string &t) {
    int l = 0, r = p.size();
    while (l < r) {
        int mid = (l + r) / 2;
        int cmp = s.compare(p[mid], t.size(), t);
        if (cmp > 0) r = mid;                      // <-- the only change (ub: cut > t)
        else l = mid + 1;
    }
    return l;
}

// number of occurrences of t in s
int countOcc(const string &s, const vector<int> &p, const string &t) {
    return ub_suffix(s, p, t) - lb_suffix(s, p, t);
}

/* ---------- longest prefix of t that appears anywhere in s: {length, start in s} ---------- */
pair<int, int> longestMatch(const string &s, const vector<int> &p, const string &t) {
    int l = 0, r = p.size();
    while (l < r) {                                   // first suffix >= t
        int mid = (l + r) / 2;
        if (s.compare(p[mid], string::npos, t) < 0) l = mid + 1; else r = mid;
    }
    pair<int, int> best = {0, -1};
    for (int idx : {l - 1, l}) {                      // the best match is a neighbour of t's position
        if (idx < 0 || idx >= (int) p.size()) continue;
        int a = p[idx], len = 0;
        while (len < (int) t.size() && a + len < (int) s.size() && s[a + len] == t[len]) len++;
        if (len > best.first) best = {len, a};
    }
    return best;
}

/* ---------- LCP of ANY two suffixes i, j in O(1) (sparse table on lcp) ---------- */
struct LCPQuery {
    int n;
    vector<int> c;
    vector<vector<int>> sp;
    LCPQuery(const vector<int> &lcp, const vector<int> &c) : n(lcp.size()), c(c) {
        int K = __lg(n) + 1;
        sp.assign(K, vector<int>(n));
        sp[0] = lcp;
        for (int k = 1; k < K; k++)
            for (int i = 0; i + (1 << k) <= n; i++)
                sp[k][i] = min(sp[k - 1][i], sp[k - 1][i + (1 << (k - 1))]);
    }
    int get(int i, int j) {                           // LCP(suffix i, suffix j)
        if (i == j) return n - i;
        int a = c[i], b = c[j];
        if (a > b) swap(a, b);
        a++;                                          // answer = min lcp[a..b]
        int k = __lg(b - a + 1);
        return min(sp[k][a], sp[k][b - (1 << k) + 1]);
    }
};

// distinct substrings of the ORIGINAL string (length m = n - 1):  m(m+1)/2 - sum(lcp)