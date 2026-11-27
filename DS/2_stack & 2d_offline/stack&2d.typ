#set text(size: 10pt)
#set par(justify: true)

= Two-Stack Queue and Offline 2D BIT

== 1. Two-stack queue

*Idea:* a queue built from two stacks that can also answer "what is the aggregate of all the elements in the queue" in $O(1)$, for any associative operation (min, max, gcd, sum, xor, and, or, matrix product).

#table(
  columns: (auto, 1fr),
  [*Symbol*], [*Meaning*],
  [`a`], [the input stack: `push` puts the new element on it],
  [`b`], [the output stack: `pop` takes the front of the queue from it],
  [$"agg"_i$], [aggregate of the element $i$ of a stack and all the elements under it],
)

*How it works*
- Every stack element stores the aggregate of everything below it and itself: $"agg"_i = "agg"_(i-1) " op " x_i$.
- `push`: put $x$ on `a` with its aggregate.
- `pop`: if `b` is empty, move all of `a` into `b` (this reverses the order, so the oldest element ends on top) and recompute the aggregates on the way; then pop `b`.
- *Whole queue:* $"agg"("queue") = "agg"("top of " b) " op " "agg"("top of " a)$. The stack `b` holds the older elements, so it goes first (this matters when the operation is not commutative; min and max do not care).

*Complexity:* `push`, `get` are $O(1)$; `pop` is $O(1)$ amortized, because every element moves from `a` to `b` once. A single `pop` can cost $O(n)$ when it triggers the move.

*Problems*
- *Sliding window min or max* over an array, and both together (the code keeps `mn` and `mx`).
- *Two pointers with an aggregate that cannot be undone:* the left pointer removes an element, but min, max, gcd, and, or have no inverse. The queue gives the aggregate of the window $[l, r]$ after each move. Examples: the longest subarray with $max - min <= k$; count the subarrays with gcd, and or or equal to a given value.
- *Window of a monoid:* products of matrices, composition of functions, or any associative operation over the last $k$ elements.
- *Queue with a minimum* (a queue where you ask the smallest element at any time).

#raw(read("code.cpp"), lang: "cpp", block: true)

== 2. Offline 2D BIT

*Idea:* a Fenwick tree over the rows, where every node holds a Fenwick tree over the *columns*. A normal 2D BIT needs a table of size $n times m$. Here every row node keeps only the columns that will really be updated in it, so the memory is $O(P log n)$ for $P$ points. For that, all the points that will ever be updated must be known in advance (offline).

#table(
  columns: (auto, 1fr),
  [*Symbol*], [*Meaning*],
  [`todo`], [the list of all the points $(r, c)$ that will be updated, given to the constructor],
  [`vals[r]`], [the sorted columns of the points that touch the row node $r$ (with a sentinel 0 first)],
  [`bit[r]`], [a Fenwick tree over the positions of `vals[r]`],
)

*How it works*
- *Build:* sort `todo` by column. For every point, walk the row nodes $r, r + "lowbit"(r), dots$ and append the column to `vals` of each one (skip it if it is the same as the last one). So every `vals[r]` is sorted and without duplicates.
- *`add(r, c, val)`:* for each row node $r' = r, r + "lowbit"(r), dots$, find the position of $c$ in `vals[r']` with a binary search and update the inner Fenwick tree from that position.
- *`rect_sum(r, c)`* (rows $<= r$, columns $<= c$): for each row node $r' = r, r - "lowbit"(r), dots$, find the last stored column $<= c$ in `vals[r']` and query the inner tree up to it.
- *Rectangle* by inclusion and exclusion:

$ S(r_1, c_1, r_2, c_2) = S(r_2, c_2) - S(r_2, c_1 - 1) - S(r_1 - 1, c_2) + S(r_1 - 1, c_1 - 1) $

*Complexity:* build $O(P log P + P log n)$, memory $O(P log n)$, `add` and `rect_sum` $O(log^2 n)$ each (the outer walk times the binary search and the inner walk).

*Rules*
- Every point passed to `add` must have been in `todo`, otherwise the update lands on the nearest smaller stored column and the sums are wrong.
- The coordinates must be in $[0, n - 1]$ for the rows; the columns can be large, they are compressed by the binary search.

*Problems*
- *Point add, rectangle sum* with large coordinates (up to $10^9$) when the points are known offline.
- *Range count with updates:* count the elements of $a[l..r]$ with a value in $[x, y]$ while single elements change. Use the position as the row and the value as the column. An update $a_i: u arrow.r v$ is `add(i, u, -1)` and `add(i, v, +1)`; collect all the pairs $(i, "value")$ first. This is the core of Dynamic Rankings (the $k$-th value of a range with updates, with a binary search on the value).
- *Count points in a rectangle online* when the points are inserted and removed over time, and the whole list of points is read first.

#raw(read("code1.cpp"), lang: "cpp", block: true)