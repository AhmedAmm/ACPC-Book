#set text(size: 10pt)
#set par(justify: true)

= Merge Sort

== 1. What it is

*Idea:* split the array in two halves, sort each half, then merge the two sorted halves in $O(n)$.

$ T(n) = 2 T(n / 2) + O(n) = O(n log n) $

- It is *stable* (equal elements keep their order) and needs $O(n)$ extra memory.
- The useful part for contests is the merge step: when the two halves are sorted, for every element of one half you know how many elements of the other half are smaller or bigger. So any count of pairs *across the two halves* is done in $O(n)$ per level, $O(n log n)$ in total.

== 2. Problems it solves

#table(
  columns: (1fr, 2fr),
  [*Problem*], [*Idea*],
  [Number of inversions (pairs $i < j$ with $a_i > a_j$)], [while merging, if the element $R_j$ of the right half is taken before the remaining left elements $L_i, dots$, it is smaller than all of them: add $p - i$, where $p$ is the size of the left half and $i$ the number of left elements already taken],
  [Minimum adjacent swaps to sort], [the number of inversions (distinct values)],
  [For each element, how many smaller elements are on its right], [sort the indices instead of the values; when a left element is taken, add to its answer the number of right elements already taken (they are the strictly smaller ones on its right)],
  [Pairs with a condition such as $a_i > 2 a_j$ (reverse pairs) or $a_i - a_j <= d$], [before merging, use two pointers on the two sorted halves: the condition is monotone, so each element of the right half moves one pointer on the left half. $O(n)$ per level],
  [Pairs that are smaller in two keys at once ($i < j$, $a_i < a_j$, $b_i < b_j$)], [CDQ divide and conquer: sort by the first key, and while merging by the second key count with a Fenwick tree],
  [Count values $<= x$ in a range], [merge sort tree: every node of a segment tree keeps its segment sorted, binary search in $O(log n)$ nodes, $O(log^2 n)$ per query],
)


== 3. Complexity

- Time: $O(n log n)$, space: $O(n)$.
- Counting across the halves adds only $O(n)$ per level, so the total stays $O(n log n)$.
- Merge sort tree: build $O(n log n)$, memory $O(n log n)$.

== 4. Code

#raw(read("code.cpp"), lang: "cpp", block: true)