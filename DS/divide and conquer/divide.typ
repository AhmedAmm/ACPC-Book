#set text(size: 10pt)
#set par(justify: true)
#set heading(numbering: "1.")

= Divide and Conquer

== Main Idea

Split the input in the middle, solve both halves recursively, then count only what *crosses the middle*. Everything that lies inside one half is already handled by the recursion. This works when the crossing part is easier to handle than the whole problem. For example, the two halves are independent of each other, or one half is known to lie entirely "before" the other.

The recursion is $T(n) = 2T(n/2) + C(n)$, where $C(n)$ is the cost of the crossing step.
- $C(n) = O(n)$ gives $O(n log n)$.
- $C(n) = O(n log n)$ gives $O(n log^2 n)$.

== Example: Best Subarray by Brute Force, then by Divide and Conquer

*Problem.* Find the contiguous subarray of $a_1, dots, a_n$ with the largest sum.

*Brute force.* Try every pair $(l, r)$ and compute the sum with prefix sums: $O(n^2)$. Without prefix sums, it is $O(n^3)$.

*Divide and conquer.* Split at $m$. The best subarray is one of three kinds:
+ entirely in the left half $[l, m]$, found recursively;
+ entirely in the right half $[m+1, r]$, found recursively;
+ *crossing the middle*, which contains both $a_m$ and $a_(m+1)$.

A crossing subarray is a suffix of the left half joined to a prefix of the right half, and the two parts are independent. So the best crossing sum is
$ max_(i <= m) sum_(k=i)^(m) a_k + max_(j > m) sum_(k=m+1)^(j) a_k, $
and each maximum is found by one linear scan outward from the middle. The answer is the maximum of the three cases. The crossing step costs $O(n)$, so the total is $O(n log n)$. (A single pass, Kadane's algorithm, gives $O(n)$, but the divide and conquer shape is the one that generalises.)

*The lesson.* The brute force "check all pairs $(i, j)$" is split into pairs inside the left half, pairs inside the right half, and pairs that cross. The crossing pairs have a simple structure that a scan can exploit. The same principle drives CDQ.

== CDQ Divide and Conquer

CDQ (named after the Chinese competitive programmer Chen Dan Qi) uses divide and conquer on the *index order* of the elements to count or optimise over pairs $(i, j)$ with several conditions at once. At each level it takes the contribution of the left half to the right half (or the reverse) and handles it with a sort and a data structure.

*Why it works.* Elements in the left half and the right half are separated by the first condition: every left element is before every right element. That condition no longer needs to be checked. One dimension is removed, and what remains is a lower dimensional problem that a sort and a Fenwick tree (or segment tree) can solve.

*Template.*
+ `cdq(l, r)`: if the range has one element, return.
+ Let $m$ be the middle. Recurse on the halves.
+ Compute the effect of $[l, m]$ on $[m+1, r]$ (a lower dimensional problem).
+ Optionally restore the order, if the algorithm needs the array sorted by another key.

*Where the dimension goes.*
- The recursion order removes the first dimension (index, or a sorted coordinate).
- The sort inside the merge step removes the second dimension.
- The Fenwick or segment tree handles the third.
- *Undo, don't clear.* After each merge step the inserts are reversed, so the cost depends only on the size of the range.

*Complexity.* $T(n) = 2T(n/2) + O(n log n)$, which gives $O(n log^2 n)$ in total.

*Two classic uses.*
+ *Static counting of dominance pairs.* There are no updates and the answer for every point is the number of points that beat it in all coordinates. The first coordinate is removed by sorting once, and the recursion splits that sorted order.
+ *DP with a partial order.* Here $"dp"_i$ depends on earlier $j$ satisfying several conditions (for example, a longest chain). The order of the recursion matters: the contribution may be used only after the source values are final.

== Code 1: Three-Dimensional Dominance Counting

*Task.* For every point $(x, y, z)$, count the points with strictly greater $x$, $y$ and $z$. Points are distinct, and coordinates may repeat.

#raw(read("code1.cpp"), lang: "cpp", block: true)

How it works:
- *Dimension 1 (x).* Sort all points by $x$ descending. After this, every point in the left half of a range has $x$ at least as large as every point in the right half.
- *Dimension 2 (y).* In `work`, both parts are sorted by $y$ descending. A pointer `pl` moves over the left part and inserts every left point with $y$ larger than the current right point, so it works as a sliding window.
- *Dimension 3 (z).* A tree indexed by $z$ stores the inserted points. `query(p.z+1, N-1)` counts the inserted points with larger $z$, and this is added to `ans[p.i]`.
- After the right points are processed, the inserted points are removed by reverse updates.
- *Equal $x$ across the middle.* Equal values must not count as "greater". The code finds the block of points with $x = a[mid].x$, `[lf, rg]`, and avoids pairing the points of the block with each other. It calls `work(lf, mid, rg+1, r)` and `work(l, lf-1, mid+1, r)`, so the block pairs only with points that have a really different $x$.
- *Strict $y$.* The window uses `la[pl].y > p.y`, so equal $y$ is excluded.
- The result of `ans[i]` is the count for the point whose original index is $i$, so the points carry `.i`.

Note that this code uses a tree with *point add* and *range sum*. The `Seg` shown in the next section is a max version, so use a Fenwick tree or a sum segment tree here.

*Complexity.* $O(n log^2 n)$.

== Code 2: CDQ for DP (Longest Chain in Two Coordinates)

*Task.* Points $(x_i, y_i)$ are given in index order. Find the longest sequence $i_1 < i_2 < dots$ with strictly increasing $x$ and strictly increasing $y$. This is a three-condition problem (index, $x$, $y$), so a plain sort and a Fenwick tree are not enough on their own.

#raw(read("code1.cpp"), lang: "cpp", block: true)

How it works:
- $"dp"_i$ is the best chain *starting* at $i$, so it depends on elements to the right of $i$ in index order.
- *Recursion order.* `cdq(mid+1, r)` runs first, so the right half has final `dp` values. Then the right half is used to update the left half. Finally `cdq(l, mid)` runs, so the left half is completed with all contributions from its own right side and from the outside. This order is the key difference from the counting problem, where the order did not matter.
- *Merge step.* Sort both halves by $x$ descending. For each left element `p`, a pointer moves over the right elements with $x > p.x$ and inserts them into a tree indexed by (compressed) $y$, storing the max `dp`. The query `query(p->y + 1, N-1)` returns the best `dp` among inserted elements with larger $y$, and `p->dp = max(p->dp, that + 1)`.
- Afterwards the inserted positions are set back to `0`, so the tree is clean again.
- The $y$ values are compressed first, so that the tree has size $O(n)$.
- The `Seg` here is a *max* tree (`comb = max`, identity `0`, point set), which matches the "best `dp`" need.

*Complexity.* $O(n log^2 n)$, which is much better than the $O(n^2)$ DP.

== Checklist

+ Identify the conditions $(c_1, c_2, c_3, dots)$ of a pair. One of them should be the position or a sortable key.
+ Check the *order of the recursion*: for a counting problem it does not matter, for a DP it must follow the dependency direction (right half first if $"dp"_i$ uses larger indices).
+ In the merge step, sort by the second condition and use a window pointer. Use a Fenwick or segment tree for the third.
+ Handle *ties* carefully: strict versus non-strict comparison, and equal keys across the middle.
+ Undo the tree by reversing the inserts. Do not clear the whole tree.
+ Compress coordinates when values are large.