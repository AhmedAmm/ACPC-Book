== Sparse Table

A Sparse Table precomputes answers for intervals whose lengths are powers of two.

Let `st[i][k]` represent the result of applying the operation over the interval

$
[i, i + 2^k - 1]
$

The transition is

$
S_(i,k) = min(S_(i,k - 1), S_(i + 2^(k - 1),k - 1))
$

To answer a query `[l, r]`, take two overlapping intervals of length $2^k$, where

$
k = floor(log_2(r - l + 1))
$

Their union covers the entire query range. Overlap is safe because the operation is idempotent.

- *Build:* $O(N log N)$
- *Query:* $O(1)$
- *Memory:* $O(N log N)$

=== Code

#raw(read("code.cpp"), lang: "cpp", block: true)

== Disjoint Sparse Table

A Disjoint Sparse Table is an extension of the Sparse Table that supports any associative operation, not just idempotent ones.

The idea is to divide the array into blocks of size $2^k$. For each block, precompute:

- Suffix answers for the left half.
- Prefix answers for the right half.

For a query `[l, r]`, find the highest bit at which `l - 1` and `r - 1` differ. This identifies the level where the two endpoints belong to different halves of the same block.

The answer is simply

$
q(l, r) = f(s_(k,l), s_(k,r))
$

Since the two precomputed intervals are disjoint, the operation does not need to be idempotent.

- *Build:* $O(N log N)$
- *Query:* $O(1)$
- *Memory:* $O(N log N)$

*When to use:* Use a standard Sparse Table for `min`, `max`, or `gcd`. Use a Disjoint Sparse Table when you need operations such as `sum`, matrix multiplication, or any other associative operation.

=== Code

#raw(read("code1.cpp"), lang: "cpp", block: true)
