#set text(size: 10pt)
#set par(justify: true)
#let md = "mod"

= Hashing

== 1. Prefix hash (strings)

*Idea:* turn a string into a number, so two substrings can be compared in $O(1)$.

#table(
  columns: (auto, 1fr),
  [*Symbol*], [*Meaning*],
  [$s_i$], [letter at index $i$, mapped to $1..26$ (never 0)],
  [$B$], [base (random)],
  [$M$], [modulus (use $2^61 - 1$)],
  [$h_i$], [hash of the prefix $s_0 .. s_(i-1)$],
  [$B^k$], [stored in `pw[k]`],
)

$ h_0 = 0, quad h_(i+1) = h_i dot B + s_i quad (md M) $

Hash of the substring $s[l..r)$ (from $l$ to $r-1$):

$ H(l, r) = h_r - h_l dot B^(r - l) quad (md M) $

*Why:* unrolling gives $h_r = sum_(i<r) s_i B^(r-1-i)$, so a letter's weight depends on its distance from $r$. In $h_r$ the prefix part equals $h_l dot B^(r-l)$ (every exponent of $h_l$ is raised by $r-l$). Subtracting it leaves only the substring.

*Do not write* $(h_r - h_l) dot B^(-l)$ here: $h_r$ and $h_l$ give the same letter different weights, so they do not cancel. That form belongs to the other convention:

#table(
  columns: (auto, 1fr, 1fr),
  [], [*Convention 1 (this book)*], [*Convention 2*],
  [Build], [$h_(i+1) = h_i B + s_i$], [$g_(i+1) = g_i + s_i B^i$],
  [Weight of $s_i$], [distance from the end], [position from the start],
  [Substring], [$h_r - h_l B^(r-l)$], [$(g_r - g_l) B^(-l)$],
  [Inverse needed], [no], [yes (or cross-multiply)],
)

*Rules*
- Equal strings give equal hashes. Equal hashes mean "equal with high probability".
- Use a random base and a big modulus, or two bases. Avoid natural $2^64$ overflow (Thue-Morse breaks it).
- Add $M$ before taking `%`, so the result is never negative.

*Solution ideas (tricks)*
- *Rabin-Karp:* compute $H(P)$ and compare it with $H(i, i+m)$ for every $i$. Total $O(n + m)$.
- *LCP of suffixes $i$ and $j$:* binary search the largest $k$ with $H(i, i+k) = H(j, j+k)$. $O(log n)$ per query. To compare two substrings lexicographically, take the LCP and compare the next letters.
- *Palindrome:* build the hash of the reversed string. $s[l..r)$ is a palindrome iff $H(l, r)$ equals the reversed-string hash of $[n-r, n-l)$.
- *Longest palindromic substring:* for each center, binary search the radius (it is monotone). $O(n log n)$.
- *Border and period:* $s[0..k)$ is a border iff $H(0, k) = H(n-k, n)$. The string has period $p$ iff $H(0, n-p) = H(p, n)$.
- *Longest common (or repeated) substring:* binary search the length $k$ (monotone), put all $H(i, i+k)$ of one string in a set, and test the windows of the other.
- *Distinct substrings of length $k$:* the size of the set of $H(i, i+k)$.
- *Cyclic shifts:* hash $s + s$. Every rotation is a substring of length $n$.

The code stores prefix and suffix hashes of a *1-indexed* string, and `run_hash` needs a dummy character at index 0. `get_hash_prefix(l, r)` and `get_hash_suffix(l, r)` normalize their results, so you can compare strings regardless of where they sit.

#raw(read("code.cpp"), lang: "cpp", block: true)

== 2. 2D hash (grids)

*Idea:* hash a rectangle of a grid in $O(1)$, using one base per axis.

#table(
  columns: (auto, 1fr),
  [*Symbol*], [*Meaning*],
  [$a_(p,q)$], [letter at row $p$, column $q$ (values $1..26$)],
  [$B_x, B_y$], [random bases for rows and columns (different)],
  [$h_(i,j)$], [hash of rows $< i$ and columns $< j$],
  [$d_x, d_y$], [$B_x^(x_2-x_1)$ and $B_y^(y_2-y_1)$],
)

Here $h_(i,j) = sum_(p<i, q<j) a_(p,q) B_x^(i-1-p) B_y^(j-1-q)$.

$ h_(i+1, j+1) = h_(i, j+1) B_x + h_(i+1, j) B_y - h_(i, j) B_x B_y + a_(i,j) quad (md M) $

*Why:* the first two terms both contain $h_(i,j)$, so it is counted twice. We subtract it once (inclusion-exclusion).

Hash of the rectangle rows $[x_1, x_2)$, columns $[y_1, y_2)$:

$ H = h_(x_2, y_2) - h_(x_1, y_2) d_x - h_(x_2, y_1) d_y + h_(x_1, y_1) d_x d_y $

This is the 1D rule applied once per axis.

*Uses*
- 2D pattern matching: compare every $p times q$ window with the pattern hash, $O(n m)$ total.
- Largest square that appears twice: binary search on the side, then put the hashes in a set.
- Rotations and flips: build the hash of the transformed grid.

*Tricks*
- Use two different bases. With one base for both axes a transposed pattern collides.
- Both grids must use the same $B_x, B_y$.
- Cost: build $O(n m)$, query $O(1)$.

*Solution ideas (tricks)*
- *2D pattern matching:* hash the pattern once, slide the window over the text. $O(n m)$.
- *Largest square that appears twice:* binary search the side $k$ (monotone), put the hashes of all $k times k$ squares in a set.
- *Count distinct $k times k$ subgrids:* the size of the set of rectangle hashes.
- *Symmetric subgrid:* build a second hash on the mirrored grid. A rectangle is symmetric iff its hash equals the hash of the mirrored rectangle (columns $[m - y_2, m - y_1)$).

The code is in `hash2d.cpp`.

#raw(read("hash2d.cpp"), lang: "cpp", block: true)

== 3. Path hash on a tree (with LCA)

*Idea:* a path $u arrow.r v$ is a string. Split it at $l = "LCA"(u, v)$ into an up part and a down part, hash each part, then join them.

#table(
  columns: (auto, 1fr),
  [*Symbol*], [*Meaning*],
  [$c_v$], [letter on node $v$],
  [$d_v$], [depth of $v$ ($d_"root" = 0$)],
  [$a_v$], [hash of the string root $arrow.r v$],
  [$b_v$], [sum of $c_x B^(d_x)$ over the nodes from the root to $v$],
  [$l$], [$"LCA"(u, v)$],
  [$b$], [length of the down part, $d_v - d_l$],
)

*Build* (for each $v$ with parent $p$):

$ a_v = a_p B + c_v, quad b_v = b_p + c_v B^(d_v) $

*Down part* ($l$ excluded, child of $l$ down to $v$). It is the same as a substring hash (convention 1):

$ D = a_v - a_l B^b $

*Up part* ($u$ up to $l$, $l$ included). $b_v$ uses convention 2, so node $x$ must be moved to exponent $d_x - d_l$; we divide by $B^(d_l)$:

$ U = (b_u - b_l + c_l B^(d_l)) dot B^(-d_l) $

*Join* (concatenation rule $H(X Y) = H(X) B^(|Y|) + H(Y)$):

$ H(u arrow.r v) = U dot B^b + D $

*Uses*
- Compare two paths: compare their $H$.
- Palindromic path: $H(u arrow.r v) = H(v arrow.r u)$.
- If $u = l$ or $v = l$ the formulas still work (then $D = 0$ when $v = l$).

*Cost:* $O(n)$ build, then one LCA query plus $O(1)$ per path (binary lifting $O(log n)$, or Euler tour with a sparse table $O(1)$). $B^(-1)$ is needed only for $U$.

*Solution ideas (tricks)*
- *Two paths are equal as strings:* compare $H$.
- *LCP of two vertical paths:* binary search the length and use the $k$-th ancestor to find the end node.
- *Rearrangeable into a palindrome (alphabet up to 26):* no hashing needed. Keep the parity mask $"mask"_v = "mask"_p ⊕ 2^(c_v)$. The path mask is $"mask"_u ⊕ "mask"_v ⊕ 2^(c_l)$, and the answer is yes iff it has at most one bit set. This is the XOR trick of section 5 with exact bits.

_Note: `code.cpp` is the string hash only. It does not implement these path arrays._

== 4. Rooted tree isomorphism

*Goal:* two rooted trees are the same if you can reorder the children at every node to turn one into the other. So the hash must not depend on child order.

*Key fact:* the shape of a node is the *multiset* of its children's shapes.

=== (a) Randomized hash

#table(
  columns: (auto, 1fr),
  [*Symbol*], [*Meaning*],
  [$h(v)$], [hash of the subtree of $v$],
  [$X$], [random number in $[1, M-1]$, chosen *once* per run],
)

$ h(v) = product_(c " child of " v) (X + h(c)) quad (md M), quad h("leaf") = 1 $

- Multiplication is commutative, so child order does not matter.
- $h(v)$ is a polynomial in $X$. Different shapes give different polynomials, which agree on at most $n$ values of $X$. So $P("collision") <= n / M$.
- Plain sum or XOR of the child hashes collides easily, so don't use them.
- A fixed $X$ can be attacked; a random $X$ cannot, because the input was fixed first.
- Time: $O(n)$.

=== (b) Exact canonical IDs

$ q_v = f("sorted"(q_(c_1), q_(c_2), dots)) $

- $q_v$ is the ID of node $v$.
- $f$ looks the sorted vector up in a `map<vector<int>, int>`. A new vector gets the next free number.
- Equal sorted vectors give the same ID, so there are *no collisions*.
- Use *one shared map* for both trees.
- Time: $O(n log n)$.

=== Which one to use

#table(
  columns: (1fr, 1fr, 1fr),
  [], [*Randomized*], [*Exact IDs*],
  [Collisions], [possible, $<= n/M$], [none],
  [Time], [$O(n)$], [$O(n log n)$],
  [Code], [very short], [needs a map],
)

*Unrooted trees:* root each tree at its *centroid*. If there are two centroids, compare both choices. Hashing from an arbitrary root does not decide unrooted isomorphism.

*Solution ideas (tricks)*
- *Count distinct subtrees:* put every $h(v)$ in a set, or with exact IDs the answer is the number of IDs created.
- *Subtree equal to a pattern tree:* count the nodes whose hash equals the pattern's root hash.
- *Compare two trees:* compare the root hashes (or IDs).
- *Deep trees (path of $10^5$ nodes):* recursion can overflow the stack, so process the nodes in reverse BFS order (children before parents).

The code compares two trees rooted at vertex 1 using both methods.

#raw(read("isomorphique.cpp"), lang: "cpp", block: true)

== 5. XOR hashing (Zobrist)

*Idea:* give every distinct value a random 64-bit number and XOR them. A pair cancels, so the hash records the *parity* of each value's count.

#table(
  columns: (auto, 1fr),
  [*Symbol*], [*Meaning*],
  [$r_x$], [random 64-bit number of value $x$ (chosen once per run)],
  [$P_i$], [XOR of $r_(a_1), dots, r_(a_i)$],
  [$⊕$], [XOR],
)

$ P_i = P_(i-1) ⊕ r_(a_i), quad H[l, r] = P_r ⊕ P_(l-1) $

*Why:* $r_x ⊕ r_x = 0$. In $H[l,r]$ every value that appears an even number of times cancels out.

*Key fact:* every value appears an even number of times in $[l, r]$ $<=>$ $P_r = P_(l-1)$.

*Tree path:* $P(v) = P("parent") ⊕ r_v$, and $H(u arrow.r v) = P(u) ⊕ P(v) ⊕ r_("lca")$.

*Uses*
- Count subarrays where all counts are even: count equal prefix values with a map.
- Set equality after add/remove updates: each update is one XOR.
- Is a window a permutation of $1..k$: compare its XOR with the XOR of $r_1, dots, r_k$.
- Subsets with a square product: XOR the prime-exponent parities.

*Tricks*
- Always XOR random $r_x$, never the numbers themselves ($1 ⊕ 2 ⊕ 3 = 0$).
- Seed `mt19937_64` with the clock. A fixed seed can be hacked.
- 64 bits fail with probability about $2^(-64)$ per comparison. For $10^10$ comparisons use two values (128 bits).
- XOR sees parity only. For "count divisible by $k$" use a vector of counts mod $k$, or the multiset hash.
- Use sort or `gp_hash_table` for hash maps, since `unordered_map` can be hacked.

```cpp
mt19937_64 rng(chrono::steady_clock::now().time_since_epoch().count());
vector<ull> r(V + 1);                       // V = number of distinct values
for (auto &x : r) x = rng();
vector<ull> P(n + 1, 0);
for (int i = 1; i <= n; i++) P[i] = P[i - 1] ^ r[a[i]];
// subarray [l, r] has all counts even  <=>  P[r] == P[l - 1]
```

*Solution ideas (tricks)*
- *Count subarrays with all counts even:* count equal prefix values with a map.
```cpp
map<ull, int> cnt; cnt[0] = 1; long long ans = 0;
for (int i = 1; i <= n; i++) ans += cnt[P[i]]++;
```
- *Window is a permutation of $1..k$:* its XOR must equal $Z_k = r_1 ⊕ dots ⊕ r_k$. Enumerate the candidate windows (for example around the position of the value 1, with length equal to the running maximum) and test each one in $O(1)$.
- *Every value appears exactly 3 times (counts mod 3):* XOR is not enough, so keep $Q_i = sum_x r_x dot (c_x mod 3)$ over the prefix, where $c_x$ is the count of $x$. A subarray has all counts divisible by 3 iff its two prefix values $Q$ are equal. Add two pointers so that no value appears more than 3 times in the window, and count equal $Q$ with a map of the prefixes inside the window.
- *Subsets whose product is a square:* give each number the bitmask of primes with an odd exponent. A subset is good iff its XOR is 0. The number of non-empty good subsets is $2^(n - "rank") - 1$ (linear basis over GF(2)).
- *Cut edges in a graph:* take a spanning tree, give every non-tree edge a random $r$, and give each tree edge the XOR of the non-tree edges whose cycle covers it (a subtree XOR). A tree edge is a bridge iff its value is 0. Two edges form a 2-edge cut iff their values are equal.
- *Set equality with updates:* keep one XOR per set. An insert and a delete are both a single XOR.

== 6. Multiset hashing

*Idea:* compare multisets where the *exact count* matters, not only the parity.

#table(
  columns: (auto, 1fr),
  [*Symbol*], [*Meaning*],
  [$r_x$], [random number of value $x$],
  [$"cnt"_x$], [how many times $x$ occurs in the multiset $S$],
  [$X$], [random point (for the product version)],
)

*Sum version:*

$ H(S) = sum_x r_x dot "cnt"_x quad (md 2^64 " or " md M) $

- Adding an element is $+ r_x$, removing is $- r_x$.
- Prefix sums give any subarray: $H[l, r] = P_r - P_(l-1)$.
- Two multisets are equal $<=>$ their $H$ are equal (with high probability).

*Product version (same trick as tree isomorphism):*

$ H(S) = product_(x in S) (X + x) quad (md M) $

It is a polynomial in $X$, so $P("collision") <= n / M$.

*Code, sum version* (mod $2^64$ by natural overflow, no multiplication so it is safe):

```cpp
typedef unsigned long long ull;
mt19937_64 rng(chrono::steady_clock::now().time_since_epoch().count());

// a[1..n] already compressed to 0..V-1
vector<ull> r(V);
for (auto &x : r) x = rng();                 // random value per distinct value

vector<ull> P(n + 1, 0);
for (int i = 1; i <= n; i++) P[i] = P[i - 1] + r[a[i]];   // wraps mod 2^64

auto get = [&](int l, int rr) { return P[rr] - P[l - 1]; };  // multiset hash of [l, rr]
// same multiset  <=>  get(l1, r1) == get(l2, r2)

// sliding window (anagram windows of length m): add the new letter, remove the old one
// hw += r[a[i]]; if (i > m) hw -= r[a[i - m]]; if (hw == ht) cnt++;
```

*Code, product version* (mod $2^61 - 1$, polynomial in $X$):

```cpp
typedef unsigned long long ull;
const ull MODH = (1ULL << 61) - 1;
mt19937_64 rng(chrono::steady_clock::now().time_since_epoch().count());
const ull X = rng() % (MODH - 1) + 1;        // random, chosen once

ull mulmod(ull a, ull b) {
    __uint128_t t = (__uint128_t) a * b;
    ull r = (ull) (t & MODH) + (ull) (t >> 61);
    if (r >= MODH) r -= MODH;
    return r;
}
ull power(ull b, ull e) {
    ull r = 1;
    while (e) { if (e & 1) r = mulmod(r, b); b = mulmod(b, b); e >>= 1; }
    return r;
}

// factor of element v is (X + v) mod M  (never 0 in practice, v < M and X is random)
auto f = [&](ull v) { ull c = X + v; if (c >= MODH) c -= MODH; return c; };

vector<ull> pre(n + 1, 1), ipre(n + 1, 1);
for (int i = 1; i <= n; i++) pre[i] = mulmod(pre[i - 1], f(a[i]));
ipre[n] = power(pre[n], MODH - 2);           // ONE inverse, then go backwards
for (int i = n; i >= 1; i--) ipre[i - 1] = mulmod(ipre[i], f(a[i]));

auto get = [&](int l, int rr) { return mulmod(pre[rr], ipre[l - 1]); };
// same multiset  <=>  get(l1, r1) == get(l2, r2)
```

*Uses*
- Is $[l_1, r_1]$ a permutation (anagram) of $[l_2, r_2]$.
- Count windows that are an anagram of a pattern.
- Point updates: keep the sum in a Fenwick tree.
- Count of every value divisible by $k$: give each value a random vector in $ZZ_k^d$ and add the vectors mod $k$.

*Tricks*
- Use a random $r_x$ per value, never $x$ itself: $1 + 4 = 2 + 3$.
- Sum mod $2^64$ is safe, because there is no multiplication by a base (the Thue-Morse attack does not apply).
- Compress the values first, so `r[]` is a plain array.

*Solution ideas (tricks)*
- *Anagram windows:* compute $H$ of the pattern, then slide the window by $+ r_("in") - r_("out")$ and compare. $O(n)$.
- *Two ranges have the same multiset (or one is a permutation of the other):* compare the prefix-sum differences $P_r - P_(l-1)$.
- *Every count divisible by $k$ (with point updates):* give each value a random $r_x in [0, k)$ and keep the sums in a Fenwick tree. If all counts are multiples of $k$, the range sum is divisible by $k$. If some count is not, the sum is divisible with probability at most $1/2$, so repeat about 30 times with different $r$.
- *Subarrays where all $c$ letters appear equally often:* the difference vector $D = (op("cnt")_j - op("cnt")_0)_j$ must be zero. Keep the prefix hash $sum_(j>=1) r_j (op("cnt")_j - op("cnt")_0)$. Adding letter 0 subtracts $sum_(j>=1) r_j$, adding letter $j >= 1$ adds $r_j$. Two equal prefix values give a good subarray, so count them with a map.

#table(
  columns: (auto, 1fr, 1fr),
  [], [*XOR*], [*Sum*],
  [Records], [parity of counts], [full counts],
  [Remove an element], [the same XOR], [subtract],
  [Use for], [even occurrences, set equality], [permutation, anagram, exact counts],
)

== 7. Which hash to choose

- Compare substrings, LCP, palindromes: polynomial hash, section 1.
- Compare grids: 2D hash, section 2.
- Compare paths: path hash, section 3.
- Compare unordered shapes: $product (X + h)$ or exact IDs, section 4.
- Parity of counts: XOR, section 5.
- Exact counts, permutations, anagrams: multiset hash, section 6.
