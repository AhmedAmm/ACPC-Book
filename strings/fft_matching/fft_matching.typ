  
== FFT String Matching

=== What it is

Turn the question “does `P` match `T` at shift `i`?” into a convolution. This computes scores for all $n - m + 1$ shifts together in $O(n log n)$ time when $m <= n$. KMP, Z, and ordinary rolling hashes do not directly handle wildcard compatibility at every shift.

=== Wildcard method

Let `|P| = m` and `|T| = n`. The code maps lowercase letters to positive integers and `*` to `0`. For a shift `i`, it computes the score

$
S(i) = sum_(j=0)^(m-1) T[i + j] P[j] (T[i + j] - P[j])^2
$

Every summand is nonnegative. A wildcard makes its term zero, and two ordinary letters contribute zero exactly when they match. Expanding the score gives three correlations: reversed `P` with `T^3`, reversed `P^2` with `T^2`, and reversed `P^3` with `T`. Each correlation is a convolution; shift `i` is read at index `i + m - 1`.

=== Complexity

- One convolution: $O(L log L)$ time and $O(L)$ memory, where `L` is the next power of two at least `n + m - 1` (so `L = O(n)` when `m <= n`).
- Wildcard matching: three convolutions.

For exact integer scores, use NTT/CRT or an FFT implementation with safe coefficient bounds and rounding.

=== Applications

- Match with `*` wildcards in the pattern, the text, or both.
- Compare `A` against `B + B` to check cyclic shifts, including wildcard positions.
- Compute `sum_j f(A[j], B[i + j])` for every shift when `f` can be written as a sum of products.
- Count pairs with a given sum using convolution of frequency arrays.

=== Code examples

==== Permutation-compatible matching

`code.cpp` reads a lowercase-letter permutation, then the pattern `s` and text `t`. A pattern character matches itself or its mapped character. It prints a `0`/`1` string with one character per shift.

#raw(read("code.cpp"), lang: "cpp", block: true)

==== Wildcard matching

`wildcard.cpp` expects the FFT `multiply` helper from the contest template. It reads the text first and the pattern second; both contain lowercase letters and optional `*` wildcards. It prints a `0`/`1` string with one character per shift, where `1` means the window matches.

#raw(read("wildcard.cpp"), lang: "cpp", block: true)

==== Replace-all operations

*Problem in one line*

#quote(block: true)[
  For every window of `S` of length `|T|`, find the minimum number of “replace all `c1` by `c2`” operations that makes the window equal to `T`.
]

#raw(read("problem.cpp"), lang: "cpp", block: true)