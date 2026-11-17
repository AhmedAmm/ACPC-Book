#set text(size: 10pt)
#set par(justify: true)
#let md = "mod"

= Suffix Array

== 1. What it is

*Idea:* sort all suffixes of the string. A substring is a prefix of some suffix, so all the substrings that start with the same letters sit next to each other in the sorted list.

#table(
  columns: (auto, 1fr),
  [*Symbol*], [*Meaning*],
  [$n$], [length of the string *with the sentinel* (`s.size()` after `s += '$'`)],
  [$p_i$], [`p[i]`: start index of the $i$-th smallest suffix],
  [$c_i$], [`c[i]`: rank of the suffix that starts at $i$, so $c_(p_i) = i$],
  [$"lcp"_i$], [`lcp[i]`: longest common prefix of the suffixes $p_(i-1)$ and $p_i$, and $"lcp"_0 = 0$],
)

Example for `banana$`:

#table(
  columns: (auto, auto, auto, auto, auto, auto, auto, auto),
  [*$i$*], [0], [1], [2], [3], [4], [5], [6],
  [*$p_i$*], [6], [5], [3], [1], [0], [4], [2],
  [*suffix*], [`$`], [`a$`], [`ana$`], [`anana$`], [`banana$`], [`na$`], [`nana$`],
  [*$c_i$*], [4], [3], [6], [2], [5], [1], [0],
  [*$"lcp"_i$*], [0], [0], [1], [3], [0], [0], [2],
)

(The row of $c_i$ is indexed by the start position: the suffix `banana$` starts at 0 and has rank 4.)

== 2. How to put the string

- Read the string and append a *sentinel*: a unique character smaller than every letter, for example `s += '$'`.
- The code sorts the cyclic shifts of the string. The unique smallest last character makes the cyclic order equal to the suffix order.
- All the vectors have size $n$, with the sentinel counted, and the suffix `$` is always $p_0 = n - 1$.
- If the string can contain characters below `'$'`, use `'\0'` or compress the letters first.
- To join several strings use a *different* separator between them, each smaller than the letters.



== 3. LCP of any two suffixes

For two start positions $i != j$ with ranks $a = c_i < b = c_j$:

$ "LCP"(i, j) = min("lcp"_(a+1), dots, "lcp"_b) $

*Why:* going from rank $a$ to rank $b$ the common prefix can only shrink, and it shrinks exactly to the minimum of the steps. For $i = j$ the answer is $n - i$.

- Use a sparse table: build $O(n log n)$, query $O(1)$.
- This is the exact version of comparing substrings with hashing, with no randomness.
- Comparing two substrings of lengths $l_1, l_2$: take the LCP, then compare the next letters (or the lengths if the LCP covers a whole substring).


== 4. Problems it solves

#table(
  columns: (1fr, 2fr),
  [*Problem*], [*Idea*],
  [Number of distinct substrings], [with $m = n - 1$ the original length: $m(m+1)/2 - sum "lcp"_i$. For `banana`: $21 - 6 = 15$],
  [$k$-th distinct substring], [suffix $p_i$ adds $(n - 1 - p_i) - "lcp"_i$ new substrings; subtract these counts from $k$ in rank order, then the answer is a prefix of that suffix],
  [Count or find a pattern], [lb and ub, count $= "ub" - "lb"$, positions $p_("lb") dots p_("ub"-1)$],
  [Longest repeated substring], [$max("lcp"_i)$],
  [Longest substring that appears at least $k$ times], [$k$ suffixes at consecutive ranks $i, dots, i + k - 1$ share $min("lcp"_(i+1..i+k-1))$; take the maximum over $i$],
  [Longest repeated substring without overlap], [binary search the length $L$; group the suffixes by $"lcp" >= L$ and test $max(p) - min(p) >= L$ in a group],
  [Longest common substring of two strings], [build `s + '#' + t + '$'`; the answer is the maximum $"lcp"_i$ over the ranks where $p_(i-1)$ and $p_i$ start in different strings],
  [Common substring of $k$ strings], [join with different separators; slide a window of ranks that holds all $k$ strings and take the minimum lcp inside (deque)],
  [Smallest cyclic rotation], [suffix array of `s + s` (with a sentinel); the first rank with $p_i < |s|$ gives the start],
  [Compare two substrings], [LCP with the sparse table, then compare the next letters],
  [Count pairs of suffixes with $"LCP" >= k$], [cut the ranks wherever $"lcp" < k$; a block of size $g$ gives $g(g-1)/2$],
)

== 5. Complexity

- Build: $O(n log n)$ with the counting sort (the code), $O(n log^2 n)$ with `std::sort`, $O(n)$ with SA-IS.
- Kasai: $O(n)$.
- Sparse table: $O(n log n)$ memory, $O(1)$ per query.
- Pattern search: $O(|t| log n)$.


== 6. About the code

- `count_sort` sorts $p$ by the class $c$ in $O(n)$ and is stable.
- `buildSuffixArray` fills $p$ (suffix order) and $c$ (rank of each suffix) by prefix doubling.
- `build_lcp` is Kasai and returns the `lcp` vector described in section 1.
- `lb_suffix` and `ub_suffix` are the two binary searches of section 6, and `countOcc` returns their difference.
- `longestMatch` returns the longest prefix of $t$ that occurs in $s$ and where.
- `LCPQuery` is the sparse table of section 5.

#raw(read("code.cpp"), lang: "cpp", block: true)
