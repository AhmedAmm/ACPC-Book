const int N = 100005, LOG = 18;
bitset<N> B[256];                    // B[c][j] = (T[j] == c)
bitset<N> cnt[LOG];                  // bit-sliced match counters

for (int j = 0; j < n; j++) B[(unsigned char)T[j]][j] = 1;

for (int k = 0; k < m; k++) {
    bitset<N> carry = B[(unsigned char)P[k]] >> k;   // windows matching at position k
    for (int l = 0; l < LOG && carry.any(); l++) {
        bitset<N> t = cnt[l] & carry;
        cnt[l] ^= carry;
        carry = t;
    }
}

for (int i = 0; i + m <= n; i++) {
    int matches = 0;
    for (int l = 0; l < LOG; l++) matches |= cnt[l][i] << l;
    int ham = m - matches;           // Hamming distance of window i
}