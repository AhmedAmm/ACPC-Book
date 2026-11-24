#set text(size: 10pt)
#set par(justify: true)

= Fenwick Tree (BIT)

== 1. What it is

*Idea:* an array that supports a point update and a prefix sum, both in $O(log n)$, with a tiny code and $O(n)$ memory. It is 1-indexed.

$ "lowbit"(i) = i " & " (-i) $

- `bit[i]` stores the sum of the range $i - "lowbit"(i) + 1, dots, i$.
- *Update* (add $x$ at position $i$): add $x$ to `bit[i]`, then $i arrow.l i + "lowbit"(i)$, until $i > n$.
- *Prefix sum* $"pre"(i)$: add `bit[i]`, then $i arrow.l i - "lowbit"(i)$, until $i = 0$.
- *Range sum:* $"pre"(r) - "pre"(l - 1)$.

== 2. Tricks

=== Multiset and set

Use the *value* as the index (compress it first if it is large) and store how many times it occurs: `bit[v]` counts the copies of $v$.

- *Insert* $v$: update $+1$ at $v$. *Erase* one copy: update $-1$ at $v$.
- *Number of elements* $<= x$: $"pre"(x)$. In a range of values $[a, b]$: $"pre"(b) - "pre"(a - 1)$.
- *Rank* of $x$ (how many are smaller): $"pre"(x - 1)$.
- *$k$-th smallest* by binary lifting, in $O(log n)$: start with `"pos" = 0` and go through the powers of two $2^j$ from the largest down. If `"pos" + 2^j <= n` and `bit[pos + 2^j] < k`, set `"pos" = "pos" + 2^j` and `k = k - bit[pos]`. The answer is `"pos" + 1`.
- *Successor* of $x$: the $k$-th smallest with $k = "pre"(x) + 1$. *Predecessor*: $k = "pre"(x - 1)$ (if it is $>= 1$).
- *Set:* the same, but insert a value only if it is not there yet, so every count is 0 or 1.
- Also gives the median, and the number of inversions (insert the elements from left to right and count how many earlier ones are bigger).

=== Offline queries for distinct values

*Problem:* many queries "how many different values in $a[l..r]$".

*Idea:* sort the queries by $r$ and sweep $i = 1, dots, n$. Keep a Fenwick tree where *only the last occurrence of every value* has a $1$.
- When adding $a_i$: if the value occurred before at position $"last"[a_i]$, update $-1$ there. Then update $+1$ at $i$ and set $"last"[a_i] = i$.
- After processing $i$, answer every query with $r = i$ as $"pre"(i) - "pre"(l - 1)$.

*Why:* in the prefix $[1, i]$ every value has exactly one mark, at its last occurrence. The marks inside $[l, i]$ are the values whose last occurrence is at least $l$, and those are exactly the different values of $a[l..i]$.

Example, $a = [1, 2, 1, 3, 2]$:

#table(
  columns: (auto, 1fr, auto),
  [*$i$*], [*marks in the tree after processing $i$*], [*query*],
  [1], [1], [],
  [2], [$1, 2$], [],
  [3], [$2, 3$ (value 1 moved from 1 to 3)], [$(1, 3)$: $"pre"(3) - "pre"(0) = 2$],
  [4], [$2, 3, 4$], [],
  [5], [$3, 4, 5$ (value 2 moved from 2 to 5)], [$(2, 5)$: $"pre"(5) - "pre"(1) = 3$],
)

Cost: $O((n + q) log n)$.

== 3. Code

#raw(read("code.cpp"), lang: "cpp", block: true)

== 2d bit

#raw(read("code1.cpp"), lang: "cpp", block: true)
