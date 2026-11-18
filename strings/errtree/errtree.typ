#set text(size: 10pt)
#set par(justify: true)

= Palindromic Tree (Eertree) and Rollback

== 1. What it is

*Idea:* a tree where every node is a distinct palindromic substring of the string. A string of length $n$ has at most $n$ distinct palindromes, so the tree has at most $n + 2$ nodes. There are two roots: node 0 with length $-1$ (the imaginary root) and node 1 with length $0$ (the empty string). The real palindromes are the nodes from 2 on.

#table(
  columns: (auto, 1fr),
  [*Symbol*], [*Meaning*],
  [$n$], [length of the string `s`],
  [$"len"(v)$], [length of the palindrome of node $v$ ($"len"(0) = -1$, $"len"(1) = 0$)],
  [$"nxt"(v, c)$], [the node of the palindrome $c, v, c$ (the letter $c$ on both sides of $v$); node 0 gives the strings of length 1, node 1 gives the strings of length 2; a missing edge is stored as 0],
  [$"link"(v)$], [suffix link: the longest proper palindromic suffix of $v$ (also a node); $"link"(1) = "link"(0) = 0$],
  [$"last"$], [node of the longest palindromic suffix of the text so far],
  [$"st"(v)$, $"en"(v)$], [start and end index (0-indexed) of the *first* occurrence of $v$ in `s`],
  [$"cnt"(v)$], [number of palindromic suffixes of $v$, itself included (the depth of $v$ in the link tree)],
  [$"oc"(v)$], [number of occurrences of $v$ in the text],
)

*Key fact:* when we add a letter $c$, only *one* new palindrome can appear (the longest palindromic suffix of the new text). So each letter creates at most one node, and all the other palindromic suffixes of the new text are the chain $"last"$, $"link"("last")$, $"link"("link"("last"))$, ... down to the empty string.

Example for `abaab`:

#table(
  columns: (auto, auto, auto, auto, auto, auto, auto),
  [*node*], [*len*], [*link*], [*string*], [*st..en*], [*cnt*], [*oc*],
  [0], [$-1$], [0], [imaginary root], [], [], [],
  [1], [0], [0], [empty string], [], [], [],
  [2], [1], [1], [`a`], [0..0], [1], [3],
  [3], [1], [1], [`b`], [1..1], [1], [2],
  [4], [3], [2], [`aba`], [0..2], [2], [1],
  [5], [2], [2], [`aa`], [2..3], [2], [1],
  [6], [4], [3], [`baab`], [1..4], [2], [1],
)

Transitions: $0 arrow.r^a 2$, $0 arrow.r^b 3$, $3 arrow.r^a 4$, $1 arrow.r^a 5$, $5 arrow.r^b 6$.

- Distinct palindromes: number of nodes $- 2 = 5$.
- Palindromic substrings counted by position: $sum_v "oc"(v) = 3 + 2 + 1 + 1 + 1 = 8$. The same number is $sum "cnt"("last")$ taken after each letter: $1 + 1 + 2 + 2 + 2 = 8$.

*The two counters.* $"cnt"(v) = 1 + "cnt"("link"(v))$ is fixed when the node is created. For $"oc"$, each letter adds 1 to $"oc"("last")$ (the longest palindromic suffix), which counts only the occurrences where $v$ is the longest one. The shorter ones are added at the end, from the last node down to node 2:

$ "oc"("link"(v)) "+=" "oc"(v) $

One pass is enough, because the link of a node is always created before the node, so it has a smaller index.

== 2. Problems it solves

#table(
  columns: (1fr, 2fr),
  [*Problem*], [*Idea*],
  [Number of distinct palindromic substrings], [number of nodes $- 2$],
  [Number of palindromic substrings (by position)], [$sum_v "oc"(v)$, or add $"cnt"("last")$ after each letter. Use `long long`, the answer is about $n^2 / 2$],
  [Longest palindromic substring], [$max "len"(v)$; its first occurrence is $"st"(v) .. "en"(v)$],
  [Occurrences of every palindrome], [$"oc"$ with the pass $"oc"("link"(v)) "+=" "oc"(v)$ from the last node down to node 2],
  [Palindromic suffixes of every prefix], [after each letter, $"len"("last")$ is the longest one and $"cnt"("last")$ is how many there are],
  [Distinct palindromes of every prefix (online)], [the number of nodes $- 2$ after each letter; it grows by 1 exactly when the letter creates a node],
  [Palindromes common to two strings], [build both trees and walk them together from the roots $(0, 0)$ and $(1, 1)$, going down only by the letters that exist in both; each pair reached is one common palindrome. The number of pairs of equal palindromic substrings is $sum_v "oc"_s (v) dot "oc"_t (v)$ over those nodes],
  [Pairs of adjacent palindromes], [let $E_i$ be the number of palindromes that end at $i$ ($"cnt"("last")$ after the letter $i$) and $B_i$ the number that start at $i$ (the same on the reversed string). The pairs where the second starts right after the first are $sum_i E_i B_(i+1)$; with any gap allowed use $sum_i E_i dot sum_(j > i) B_j$],
  [Minimum number of palindromes that split the string], [series links, section below, $O(n log n)$],
  [Build a palindrome with the cheapest operations (copy the half, add letters on both sides)], [dp over the nodes with the half link, section 4],
  [A palindromic tree over a trie, or over a DFS], [push the letter when entering a vertex and pop when leaving (the rollback of section 5), so every root-to-vertex string is handled],
  [Distinct palindromes inside a substring $s[l..r]$ (queries)], [offline: sort the queries by $r$; when the letter $r$ is added, the latest occurrence of every palindromic suffix moves to the right, and these suffixes form $O(log n)$ arithmetic series, so $O(log n)$ range updates on a Fenwick or segment tree; total $O(n log^2 n)$],
)

*Series link (for the factorization dp).* The palindromic suffixes of a string form $O(log n)$ arithmetic progressions of lengths. Define for a node $v$:

$ "diff"(v) = "len"(v) - "len"("link"(v)) $

- $"slink"(v) = "link"(v)$ if $"diff"(v) != "diff"("link"(v))$,
- otherwise $"slink"(v) = "slink"("link"(v))$.

So $"slink"$ jumps over a whole series at once, and the chain $"last"$, $"slink"("last")$, ... has $O(log n)$ steps. Let $"dp"(i)$ be the minimum number of palindromes that split the first $i$ letters, with $"dp"(0) = 0$. After adding the letter $i$, for each $v$ on the chain $"last"$, $"slink"("last")$, ... while $"len"(v) > 0$:

$ "sa"(v) = "dp"(i - ("len"("slink"(v)) + "diff"(v))) $

and if $"diff"(v) = "diff"("link"(v))$ then $"sa"(v) = min("sa"(v), "sa"("link"(v)))$. Then

$ "dp"(i) = min_v ("sa"(v) + 1) $

*Why:* $"sa"(v)$ is the best $"dp"$ over the starts of all the palindromes of the series of $v$. The series of $"link"(v)$ is the same series shifted by $"diff"(v)$, and it was already computed at the position $i - "diff"(v)$, so only the one new start has to be added.

*Palindromic tree or Manacher:* Manacher gives the maximal palindrome at every center in $O(n)$ and is the shortest code for "longest palindrome" and "count palindromic substrings". The palindromic tree is needed when you need *distinct* palindromes, the palindromes of each prefix, counts per palindrome, the series links, or the online version.

== 3. Complexity

- Build: $O(n)$ amortized (the depth of $"last"$ in the link tree grows by at most 1 per letter), $O(n Sigma)$ memory for the transitions.
- `calc_occurrences`: $O(n)$.
- The dp of section 4: $O(n)$.
- The factorization dp with series links: $O(n log n)$.
- Rollback version (section 5): $O(Sigma)$ worst case per `push` and per `pop`, with no amortization.

== 4. The half link trick

For a node $v = c, p, c$ with even length, $v = X overline(X)$ and the half $X$ starts with a palindrome $t$: the longest palindromic suffix of $v$ with length at most $"len"(v) / 2$. Define this node as $"trans"(v)$. Then a dp over the palindromes can use it (build $t$, extend it to $X$, double):

$ "dp"(v) = min("dp"(p) + 2, "dp"("trans"(v)) + "len"(v) / 2 - "len"("trans"(v)) + 1) $

*Getting $"trans"(v)$ when $v$ is created:*
- if $"len"(v) <= 2$: $"trans"(v) = "link"(v)$;
- otherwise start with $t = "trans"(p)$ ($p$ is the parent, not $"link"(v)$) and, while $("len"(t) + 2) dot 2 > "len"(v)$ or the letter before $t$ in the text is not $c$, set $t = "link"(t)$. Then $"trans"(v) = "nxt"(t, c)$.

#raw(read("code_dp.cpp"), lang: "cpp", block: true)

== 5. Rollback

Version of the tree with `pop` (remove the last letter), useful for a DFS over a trie. Every `push` and `pop` costs $O(Sigma)$ in the worst case. `occurrences()` returns the occurrence counts without changing the tree.

#raw(read("code1.cpp"), lang: "cpp", block: true)

== 6. Code

#raw(read("code.cpp"), lang: "cpp", block: true)
