== Bitset Matching

=== What it is

- Maintain a bitset `D` where bit `i` is set exactly when the prefix `P[0..i]` is a suffix of the text read so far.
- Precompute `mask[c]` with bit `i` set when pattern position `i` accepts character `c`.
- For each text character `c`, update `D = ((D << 1) | one) & mask[c]`, where `one` has only bit `0` set. A match ends at the current character when bit `m - 1` is set.
- This simulates all pattern-prefix states in parallel using bit operations.

=== Complexity

- Time: $O(n dot.op ceil(m / w))$, where $w$ is the machine word size (typically 64 bits).
- Memory: $O(Sigma dot.op ceil(m / w))$ words for the masks.
- For $m <= 64$, matching takes $O(n)$ word operations. For longer patterns, bit-parallel matching processes about 64 positions per word instead of one.
- With `std::bitset<N>`, `N` is a compile-time capacity and the pattern length must not exceed it.

=== Bitset as DP

Any recurrence of the form `dp[i][j] = dp[i - 1][j - 1] AND cond[j]` can update a whole row at once: shift the previous row, set the initial bit, then AND with the positions satisfying the condition. For matching, this is `D = ((D << 1) | one) & mask[c]`.

=== Problems it solves

- *Exact matching:* find occurrences of a short pattern, or run one matcher per pattern against the same text.
- *Character classes and wildcards:* let each pattern position accept a set of characters by setting its bit in every corresponding `mask[c]`. This handles classes such as `[abc]` and `.`, which ordinary KMP does not support directly.
- *Approximate matching:* Bitap / Wu-Manber variants keep `k + 1` bitsets for up to `k` mismatches or edits, taking $O(n dot.op k dot.op ceil(m / w))$ time.
- *Subsequence queries:* use bitsets of text positions for each character to check many queries for whether they are subsequences of the text.
- *Hamming distance over windows:* combine bitsets of matching text positions with shifted pattern positions. A per-character approach can take $O(n dot.op m dot.op Sigma / w)$ time; suitable organization can reduce this to $O(n dot.op m / w)$.

The first listing intersects bitsets of valid text positions for character-class matching.

#raw(read("code.cpp"), lang: "cpp", block: true)

=== Hamming Distance of Every Window

For each pattern position `k`, `B[P[k]] >> k` marks the text windows that match at that position. The bit-sliced counter `cnt` accumulates the number of matching positions for every window, so the Hamming distance is `m - matches`. Choose `N` large enough for the text and `2^LOG > m`.

Let `W = ceil(N / w)` be the number of machine words in each bitset. The snippet takes $O(n + m dot.op log dot.op W + (n - m + 1) dot.op log)$ time: building the character masks, counting matches with up to `LOG` bitset operations per pattern position, then reading each window's counter. It uses $O((256 + log) dot.op W)$ words for `B` and `cnt`.

#raw(read("hamming_distance.cpp"), lang: "cpp", block: true)