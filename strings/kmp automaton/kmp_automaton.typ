== KMP Automaton

=== What it is

- A deterministic finite automaton (DFA) built from the prefix function of pattern `P`. State `j` is the length of the longest prefix of `P` that is a suffix of the text read so far.
- `go[j][c]` is the next state after reading character `c`. Precomputing these transitions turns KMP's amortized fallback work into a worst-case $O(1)$ transition.

=== Complexity

- Build: $O(m dot.op Sigma)$ time and memory, where $m = |P|$ and $Sigma$ is the alphabet size.
- Process a text of length $n$: $O(n)$ time.
- For $Sigma = 26$ and $m = 10^5$, the table has about $2.6 dot.op 10^6$ entries (about 10 MB with `int`, or 21 MB with `long long`).
- For a large alphabet, such as $Sigma = 10^9$ or full Unicode, do not build a dense table; use the plain prefix-function fallback or a sparse map when appropriate.

=== When to use

- *Counting strings:* run `dp[i][state]` over positions and automaton states. For each character `c`, add the count to `dp[i + 1][go[state][c]]`. To count strings avoiding `P`, discard transitions into state `m`. To count strings containing `P`, make state `m` absorbing. The complexity is $O(n dot.op m dot.op Sigma)$.
- *Huge lengths:* for $n$ as large as $10^18$ and small $m$, represent transitions as a matrix and exponentiate it in $O(m^3 log n)$. The avoiding-pattern matrix has $m$ states; counting strings that contain the pattern can include an extra absorbing state.
- *Constrained constructions:* construct the lexicographically smallest or $k$-th string avoiding `P`, or combine pattern matching with other constraints.
- *Digit DP:* carry the KMP state as an additional DP dimension.
- *Streaming:* use the table when characters arrive one at a time and each needs a worst-case $O(1)$ transition, rather than amortized time.

The code below builds the lowercase-English alphabet transitions for states `0..m`. Its state-`m` row falls back through the prefix function, allowing further matches (including overlaps); for a contains-pattern DP, replace that row with transitions back to `m` so it is absorbing.

#raw(read("code.cpp"), lang: "cpp", block: true)