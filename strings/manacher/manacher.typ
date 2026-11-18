#set text(size: 10pt)
#set par(justify: true)

= Manacher

== 1. What it is

*Idea:* for every center of the string, find the largest palindrome around it in $O(n)$ total. A palindrome that sits inside a bigger palindrome is the mirror image of one on the other side of the center, so its radius is already known and only the part that sticks out of the big one needs new comparisons.

#table(
  columns: (auto, 1fr),
  [*Symbol*], [*Meaning*],
  [$n$], [length of the string `s`],
  [$"d1"(i)$], [number of odd palindromes centered at $i$ (the radius, the center counts): the longest is `s[i-d1+1 .. i+d1-1]` of length $2 "d1"(i) - 1$],
  [$"d2"(i)$], [number of even palindromes whose right middle letter is $i$ (the center is between $i-1$ and $i$): the longest is `s[i-d2 .. i+d2-1]` of length $2 "d2"(i)$],
  [$[l, r]$], [the palindrome found so far that has the rightmost end],
)

*Key fact:* if $i$ is inside $[l, r]$, its mirror is $j = l + r - i$, so $"d1"(i) >= min("d1"(j), r - i + 1)$. If $"d1"(j)$ fits inside $[l, r]$ the value is exact, otherwise we start from $r - i + 1$ and expand.

Example for `abaab`:

#table(
  columns: (auto, auto, auto, auto),
  [*i*], [*letter*], [*d1*], [*d2*],
  [0], [`a`], [1], [0],
  [1], [`b`], [2 (`b`, `aba`)], [0],
  [2], [`a`], [1], [0],
  [3], [`a`], [1], [2 (`aa`, `baab`)],
  [4], [`b`], [1], [0],
)

- Palindromic substrings (by position): $sum "d1"(i) + sum "d2"(i) = 6 + 2 = 8$.
- Longest palindrome: `baab`, from $"d2"(3) = 2$, length 4, start $= i - "d2"(i) = 1$.

== 2. How to put the string

- Call the function on the string, it fills two arrays:

`vector<int> d1, d2; manacher(s, d1, d2);`

- No sentinel is needed, odd and even palindromes are handled separately.
- Indices are 0-indexed. For an even palindrome the center is *between* $i-1$ and $i$.
- To get one array instead of two, put a separator between the letters (`#a#b#a#`); then one run gives both kinds, but the string is twice as long.

== 3. The algorithm

Keep $[l, r]$ with $l = 0, r = -1$ at the start. For each $i$ from $0$ to $n - 1$:

*Odd* ($"d1"$):
- $k = 1$ if $i > r$, else $k = min("d1"(l + r - i), r - i + 1)$.
- While $i - k >= 0$, $i + k < n$ and $s[i - k] = s[i + k]$, do $k$++.
- $"d1"(i) = k$. If $i + k - 1 > r$ then $l = i - k + 1$, $r = i + k - 1$.

*Even* ($"d2"$):
- $k = 0$ if $i > r$, else $k = min("d2"(l + r - i + 1), r - i + 1)$.
- While $i + k < n$, $i - k - 1 >= 0$ and $s[i + k] = s[i - k - 1]$, do $k$++.
- $"d2"(i) = k$. If $i + k - 1 > r$ then $l = i - k$, $r = i + k - 1$.

*Why it is linear:* $r$ only moves to the right. A comparison that succeeds always pushes $r$, and each $i$ has at most one failing comparison, so the total is $O(n)$.

== 4. Problems it solves

#table(
  columns: (1fr, 2fr),
  [*Problem*], [*Idea*],
  [Number of palindromic substrings (by position)], [$sum "d1"(i) + sum "d2"(i)$],
  [Longest palindromic substring], [the largest $2 "d1"(i) - 1$ (start $i - "d1"(i) + 1$) or $2 "d2"(i)$ (start $i - "d2"(i)$)],
  [Is `s[l..r]` a palindrome (query)], [let $m = (l + r) / 2$; if the length is odd check $"d1"(m) >= (r - l) / 2 + 1$; if even check $"d2"(m + 1) >= (r - l + 1) / 2$],
  [Is the whole string a palindrome], [the query above with $l = 0, r = n - 1$],
  [Longest palindromic prefix / suffix], [a prefix `s[0..e]` is a palindrome if its center covers it (use the query above for each $e$, take the largest); the suffix is the same on the reversed string],
  [Count palindromes that start (or end) at each position], [the palindromes of the center $i$ end at $i, i+1, dots, i + "d1"(i) - 1$ (odd): add 1 on this range with a difference array; the starts are the mirror range],
  [Minimum letters to add in front to make a palindrome], [$n -$ (length of the longest palindromic prefix)],
  [Partition into palindromes (min cuts)], [use the queries above as the $O(1)$ check inside the dp, or the palindromic tree for $O(n log n)$],
)

*Note:* the sum $sum "d1" + sum "d2"$ counts substrings by position, so the same palindrome that occurs in two places is counted twice. For the number of *distinct* palindromes use the palindromic tree (at most $n$ of them).

== 5. Complexity

- Build: $O(n)$ time and $O(n)$ memory.
- Query "is `s[l..r]` a palindrome": $O(1)$ after the build.
- Count / longest: $O(n)$.
- Hashing gives the same queries with $O(n log n)$ for the longest palindrome, Manacher is faster and exact.

== 6. About the code

- `d1[i]` and `d2[i]` are the two arrays of section 1, and `l`, `r` are the window of section 3.
- The loop does the odd part and then the even part for the same $i$, with the same $[l, r]$ updated twice (each kind has its own update rule).
- The answer of the problems is read from `d1` and `d2` directly, as in section 4.

*Watch out*
- The even case is shifted: `d2[i]` is the palindrome with the center *between* $i - 1$ and $i$, so `d2[0]` is always $0$.
- The mirror of $i$ for the even case is $l + r - i + 1$, not $l + r - i$. This is the most common bug.
- The start of the longest odd palindrome is $i - "d1"(i) + 1$, of the even one is $i - "d2"(i)$. The length is $2 "d1" - 1$ and $2 "d2"$.
- Store the total number of palindromes in a `long long` (it is about $n^2 / 2$ for a string of one letter).
- If you use the separator version, the radius in the new string is the length of the palindrome in the old one, and the letters of `s` must not contain the separator.

#raw(read("code.cpp"), lang: "cpp", block: true)
