#set text(size: 10pt)
#set par(justify: true)

= Mo's Algorithm

== 1. Normal Mo (Gilbert sorting)

*Idea:* offline range queries $[l, r]$ on a static array. Reorder the queries so that two pointers $l$ and $r$ can walk from one query to the next with few moves, and keep a structure with `add(pos)` and `del(pos)` that cost $O(1)$.

#table(
  columns: (auto, 1fr),
  [*Symbol*], [*Meaning*],
  [$n$, $q$], [length of the array, number of queries],
  [$B$], [block size of $l$ (the code uses $B approx n / sqrt(q)$)],
  [`aux`], [the current answer of the range $[l, r]$],
)

*Order:* group the queries by the block of $l$ ($floor(l / B)$), and inside a block sort by $r$.
- $r$ moves at most $n$ per block, so $n / B$ blocks cost $n^2 / B$.
- $l$ moves at most $B$ per query, so $q B$ in total.

$ "cost" = q B + n^2 / B quad arrow.r quad B = n / sqrt(q) quad arrow.r quad O(n sqrt(q)) $

*Gilbert order:* the plain order makes $r$ run back to the start at the end of every block. The odd-even trick (in the code, the sort named gilbert) sorts $r$ upward in even blocks and downward in odd blocks, so $r$ never runs back. A true Hilbert (Gilbert) curve order is a bit better still, about $30%$ fewer moves, but the bound is the same.

*Moving the pointers:* first expand ($r$ right, $l$ left), then shrink ($l$ right, $r$ left). Shrinking first can leave $l > r + 1$ and remove an element that was never added.

#table(
  columns: (1fr, 2fr),
  [*Problem*], [*Idea*],
  [Distinct values in a range (SPOJ DQUERY)], [`cnt[x]`; `aux` grows when `cnt[x]` goes from 0 to 1 and drops when it goes back to 0],
  [Powerful array (CF 86D): $sum "cnt"[x]^2 dot x$], [add: $"aux" arrow.l "aux" + (2 "cnt"[x] + 1) x$; del: $"aux" arrow.l "aux" - (2 "cnt"[x] - 1) x$ (use the value of `cnt` before the change)],
  [Little Elephant and Array (CF 220B): how many $x$ occur exactly $x$ times], [`cnt[x]`; `aux` changes when `cnt[x]` becomes or stops being $x$],
  [XOR and Favorite Number (CF 617E): subarrays with xor $k$], [prefix xors $p$; the range $[l, r]$ becomes the pair $(l - 1, r)$ of prefix indices; add $p_i$: $"aux" arrow.l "aux" + "cnt"[p_i ⊕ k]$, then $"cnt"[p_i] arrow.l "cnt"[p_i] + 1$],
  [Mode of a range (hard)], [keep `cnt[x]` and `cc[f]` = how many values have frequency $f$. Add: the maximum frequency grows by at most 1. Del: if `cc[max]` becomes 0 the maximum drops by exactly 1. $O(1)$ per move],
  [Mex of a range (hard)], [keep `cnt[x]` and, for each block of values, how many values are present. Add and del are $O(1)$; a query looks for the first block that is not full and scans it, $O(sqrt(n))$. Total $O(n sqrt(q) + q sqrt(n))$],
)

The code below counts the values that appear an odd number of times in the range. It has both orders, the second sort overrides the first.

#raw(read("mo.cpp"), lang: "cpp", block: true)

== 2. Mo with rollback

*Idea:* use it when an element can be *added* but not *removed* easily (maximum, a union-find, a linear basis). Never delete: only add, and undo the last additions with a stack.

*Order:* blocks of $l$, and inside a block $r$ increasing (no odd-even trick).

*For every block of $l$ with the right end $E$:*
- Start with an empty structure and $r = E$.
- A query with $l$ and $r$ in the same block: add the elements $l, dots, r$ one by one, answer, and undo all of them.
- Otherwise move $r$ to the right, adding only (it is never undone inside this block). Then add the elements $E, E - 1, dots, l$ (the left part, at most $B$ of them), answer, and undo exactly these left additions.

$ "cost" = O(n sqrt(q)) "additions and undos" $

*Undo:* push on a stack what every addition changed, and pop to undo. For a union-find use union by size without path compression and undo the last union.

#table(
  columns: (1fr, 2fr),
  [*Problem*], [*Idea*],
  [Maximum of $"value" dot "frequency"$ over a range (JOI Historical Research)], [the maximum cannot be recomputed after a deletion; with rollback just restore the old maximum together with the old count],
  [Connected components, or is it bipartite, using only the edges $l, dots, r$], [rollback union-find: add an edge = one union, undo = pop the union],
  [Maximum xor of a subset of a range], [a linear basis cannot delete an element, but it can be restored from a copy; add the elements and roll the basis back],
  [Longest run, or the first position with a property, inside a range], [store the old state before every addition and restore it],
)

== 3. Mo with sweepline (second offline)

*Idea:* use it when `add` and `del` are not $O(1)$ (they need a data structure), but the *contribution of one element to a prefix* can be read in $O(1)$ after an offline sweep. Do not move the pointers for real: record every move as an *interval query on a prefix*, then answer all of them in one sweep over the array.

#table(
  columns: (auto, 1fr),
  [*Symbol*], [*Meaning*],
  [$g(j, S)$], [how many elements $t in S$ form a pair with $j$ (here $a_t ⊕ a_j = k$)],
  [$"before"_i$], [$sum_(x <= i) g(x, [0, x - 1])$],
  [$"me"_i$], [$sum_(x <= i) g(x, [0, x])$],
  [$"Int"(p, x, y)$], [$sum_(j = x)^y g(j, [0, p])$, the interval query asked at the prefix $p$],
)

The answer is the number of pairs $i < j$ inside the range, so $P(l, r) = sum_(j = l)^r g(j, [l, j - 1])$. A move of the pointers changes it like this:

*$r$ grows from $r$ to $R$:*

$ Delta = sum_(j = r+1)^R g(j, [l, j - 1]) = ("before"_R - "before"_r) - "Int"(l - 1, r + 1, R) $

*$l$ shrinks from $l$ to $L$:*

$ Delta = sum_(j = L)^(l - 1) g(j, [j + 1, r]) = "Int"(r, L, l - 1) - ("me"_(l - 1) - "me"_(L - 1)) $

*Why:* $g(j, [l, j - 1]) = g(j, [0, j - 1]) - g(j, [0, l - 1])$, the first term is a prefix sum ($"before"$), the second is an interval query at the prefix $l - 1$. The same for the left move with $[0, r]$ and $[0, j]$. When the pointers move the other way, the same terms are taken with the opposite sign.

*Telescoping:* all the $"before"$ parts of the moves add up to $"before"_r$ of the last query, and all the $"me"$ parts to $"me"_(l-1)$. So

$ "answer" = sum "of the interval parts so far" + "before"_r + "me"_(l - 1) $

*Algorithm:*
+ Sort the queries (Mo order) and walk the pointers, only writing the four kinds of intervals `{l, r, query, sign}` into the list of the prefix where they are asked.
+ Sweep $i = 0, dots, n$: compute $"before"_i$ and $"me"_i$, insert $i$ into the structure, then answer every interval stored at $i$ by summing $g(j, [0, i])$ over the interval.
+ Rebuild the answer of each query from the running sum of the interval parts, $"before"$ and $"me"$.

*Cost:* there are $O(n sqrt(q))$ element lookups in total and only $n$ insertions. With a structure that has update $O(sqrt(n))$ and query $O(1)$ this is $O(n sqrt(n) + n sqrt(q))$, instead of $O(n sqrt(q) log n)$ for a normal Mo with a $log$ structure.

*To reuse it:* replace `freq[a[j]]` by your $O(1)$ query $g(j, [0, i])$ and `freq[a[i] ^ k]++` by your insertion.

*Problems:* number of inversions inside a range (Ynoi, Yuno loves sqrt technology II): $g$ is a count of bigger or smaller values in the prefix, with an $O(sqrt(n))$ update and $O(1)$ query structure. The code below is CF 617E, where a normal Mo is enough; it is used to show the method.

#raw(read("mo+swipline.cpp"), lang: "cpp", block: true)

== 4. Mo on trees

*Idea:* turn the tree into an array with an Euler tour, then use a normal Mo on that array.

*Subtree queries:* with the order of the DFS, the subtree of $v$ is the range $["tin"_v, "tout"_v]$ of the array of the nodes. It is a plain range query.

*Path queries* $u arrow.r v$: use an Euler tour of length $2n$ where a node appears twice, at its entry and at its exit. Let $"tin"_v$ and $"tout"_v$ be the first and the last position of $v$, and assume $"tin"_u <= "tin"_v$ (swap otherwise), and $l = "LCA"(u, v)$.

#table(
  columns: (auto, auto, 1fr),
  [*Case*], [*Range*], [*Extra*],
  [$l = u$ ($u$ is an ancestor of $v$)], [$["tin"_u, "tin"_v]$], [nothing],
  [otherwise], [$["tout"_u, "tin"_v]$], [add the node $l$ before answering, remove it after],
)

*Why it works:* in the range, a node on the path appears exactly once (only its entry or only its exit is inside), and a node that hangs off the path appears twice or not at all. So both `add(pos)` and `del(pos)` just *flip* the node: if it is active, remove it, otherwise add it. The node $l$ is the exception because the range does not contain it when $u != l$, hence the extra step.

#table(
  columns: (1fr, 2fr),
  [*Problem*], [*Idea*],
  [Number of distinct values on a path (SPOJ COT2)], [flip the node, with `cnt[value]` and `aux` as in DQUERY; add $l$ temporarily],
  [Number of colors with at least $k$ nodes in a subtree (CF 375D)], [subtree range; keep `cnt[color]` and `cc[f]`, with a counter of colors with frequency at least $k$],
)

For $n$ nodes the array has $2n$ positions (paths) or $n$ positions (subtrees). Use an iterative DFS for deep trees and an $O(1)$ or $O(log n)$ LCA computed once for all queries.