== KMP (Prefix Function) / Z Array

=== What it is

- The *prefix function* $pi[i]$ is the length of the longest proper prefix of $s[0..i]$ that is also a suffix of it (the longest border).
- The *Z array* $z[i]$ is the length of the longest common prefix of $s$ and the suffix starting at $i$. The included implementation uses $z[0] = 0$.
- The two arrays contain the same information and can be converted into each other in $O(n)$ time.

=== Complexity

- Build either array: $O(n)$ time and $O(n)$ memory.
- Match a pattern of length $m$ in text of length $n$: $O(n + m)$ time and $O(n + m)$ memory using a combined string. KMP's fallback work is amortized linear.
- Build a KMP automaton: $O(m dot.op Sigma)$ time and memory, then $O(1)$ per transition. Here $Sigma$ is the alphabet size.

=== When to use

- *Pattern matching:* compute the prefix function on `P + '#' + T` and find positions where $pi[i] = |P|$. With the Z array, use $z[i] = |P|$. Choose a separator that cannot occur in either string.
- *Smallest period:* for nonempty $s$, let $p = n - pi[n - 1]$. The string is a repetition of a shorter block exactly when $p < n$ and $n mod p = 0$.
- *All decompositions* (write `s = sub^k`, with `k >= 2`): let `p = n - pi[n - 1]`. If `p < n` and `n` is divisible by `p`, the valid block lengths are exactly the divisors `d` of `n` that are multiples of `p`, with `d < n`. For each such `d`, `sub = s[0..d-1]` and `k = n / d`; otherwise, there are none.
- *All borders:* set `b = pi[n - 1]`; while `b > 0`, record `b` and set `b = pi[b - 1]`.
- *Count occurrences of every prefix:* initialize `cnt[0..n]` to zero and do `cnt[pi[i]]++` for every `i` from `0` to `n - 1`. Then, for `i = n - 1` down to `1`, do `cnt[pi[i - 1]] += cnt[i]`. Finally add `1` to each `cnt[i]` for `i = 1..n` to include the prefix itself.
- *Cyclic shifts:* for equal-length strings, search for `B` in `A + A`.
- *Z array:* use it for the LCP of every suffix with the whole string, or for simpler pattern-matching code. To count distinct substrings incrementally, reverse the current string, compute its Z array, let `best = max(z[i])` over `i > 0`, and add `n - best`.

=== KMP vs Z

Use *KMP* for borders, periods, automaton-based DP, or when characters arrive online (streaming). Use *Z* when the task asks for the LCP of each suffix with the whole string, or when you want a straightforward matching implementation; it requires the whole string upfront.

#raw(read("code.cpp"), lang: "cpp", block: true)