#set text(size: 10pt)
#set par(justify: true)

= Implicit Treap

== 1. What it is

*Idea:* a treap (a binary tree that is a BST by position and a heap by a random priority) where the *key is the position*, and it is not stored. The in-order walk of the tree is the array. Every node keeps the size of its subtree, so the position of a node is computed on the way down: $"size"("left") + 1$, plus what was skipped above.

#table(
  columns: (auto, 1fr),
  [*Symbol*], [*Meaning*],
  [`sz`], [size of the subtree (so the number of elements)],
  [`p`], [random priority; the root of every subtree has the smallest `p` (in this code)],
  [`val`, `sum`], [the value of the node and the sum of its subtree],
  [`lazy`, `is_lazy`], [pending "add this to the whole subtree"],
  [`rev`], [pending "reverse the whole subtree"],
  [`par`], [parent pointer (used by `get_idx_of_value`)],
)

- The random priorities keep the tree balanced: the depth is $O(log n)$ in expectation, whatever the order of the operations.
- *Lazy flags:* `prop` pushes the pending add and reverse to the children before the node is used. `recalc` recomputes `sz` and `sum` from the children after the node was changed. A reverse is just a swap of the two children plus the flag.

== 2. Split and merge

Every operation is built from two functions, both $O(log n)$ in expectation. Positions are 1-indexed.

*`split(t, cnt)`:* cuts the sequence into the first $"cnt"$ elements (left treap) and the rest (right treap).
- If $"size"("left child") >= "cnt"$: the root and its right subtree belong to the right part; split the left child and hang the right piece back as the left child of the root.
- Otherwise the root and its left subtree belong to the left part; split the right child with $"cnt" - "size"("left child") - 1$ and hang the left piece back as the right child.

*`merge(l, r)`:* joins two treaps where every element of `l` comes before every element of `r`.
- The root is the one with the smaller priority. If `l.p < r.p`, then `l` stays the root and `l.r = merge(l.r, r)`; otherwise `r` stays the root and `r.l = merge(l, r.l)`.

Both call `prop` before touching the children and `recalc` after.

*Range pattern* (used by every range function of the code): cut out the segment, work on it, glue back.
+ `split(t, r)` gives $a$ (first $r$ elements) and $b$ (the rest).
+ `split(a, l - 1)` gives $c$ (first $l - 1$) and $d$ (the elements $l, dots, r$).
+ Work on $d$: apply a lazy add, flip a reverse flag, read `d->sum`, or move it.
+ `merge(merge(c, d), b)`.

#table(
  columns: (1fr, 2fr),
  [*Function*], [*What it does*],
  [`add_range(t, l, r, val)`], [adds `val` to all the elements $l, dots, r$ (lazy add on $d$)],
  [`get_range(t, l, r)`], [prints the sum of $l, dots, r$, and returns the treap],
  [`reverse_range(t, l, r)`], [reverses the segment (reverse flag on $d$)],
  [`left_shift(t, l, r)`], [cyclic shift of the segment: the element $r$ goes to the position $l$, the others move one place right (it cuts $d$ = element $r$ and puts it before the elements $l, dots, r - 1$)],
  [`get_val(t, idx)`], [prints the element at the position `idx`],
  [`get_idx_of_value(node)`], [the position of a node, given its pointer: go up with `par`, and each time you come from a right child add $"size"("left sibling") + 1$],
  [`count_less(t, x)`], [number of elements smaller than $x$, using the minimum and maximum of a subtree to stop early],
)

== 3. Problems it solves

#table(
  columns: (1fr, 2fr),
  [*Problem*], [*Idea*],
  [Insert or delete an element at a position], [`split(t, pos)`, then `merge(left, new node, right)`; delete: cut the single element out and drop it. A normal array needs $O(n)$],
  [Range reverse (Luogu P3391)], [`reverse_range`; the flag is pushed down only when needed],
  [Cyclic shifts and reversals of segments, then ask for the elements at some positions (CF 863D)], [`left_shift` and `reverse_range` for each query, then `get_val`],
  [Cut a segment and paste it somewhere else], [split twice to take the segment out, merge the rest, split at the new place, merge the three pieces],
  [Range add, range sum on an array that also changes its shape], [the lazy add and `sum` of the treap, in the same tree that handles insertions and reversals],
  [$k$-th element, and the position of a known element], [`get_val`, and `get_idx_of_value` with the parent pointers (no search needed)],
  [Sequence editing (text editor: insert text, delete a block, move a block)], [every command is a split and merges],
  [Ordered set or multiset with rank and $k$-th, in one tree], [the same treap used with the *value* as the key: split by value instead of by count],
)

*Complexity:* every operation is $O(log n)$ in expectation, memory $O(n)$ nodes. Building from an array: $O(n log n)$ with repeated `merge`, or $O(n)$ with a stack. The recursion depth is $O(log n)$ in expectation.

*Compared with a segment tree:* the treap can insert, delete, cut, paste and reverse (the structure changes), but it is slower (random access, pointers) and has a larger constant. If the array has a fixed shape, use a segment tree.

== 4. Code

- Positions are 1-indexed, ranges are $[l, r]$.
- Every function that changes the tree *returns the new root*: write `t = add_range(t, l, r, val)`. `get_range` and `get_val` print inside the function and also return the treap, so use them the same way (`t = get_range(t, l, r)`).
- `get_idx_of_value` follows the parent pointers and does not look at pending reverse flags, so before using it, push the flags from the root down to the node (a pending reverse changes which child is the left one).
- `count_less` uses `mx` and `mn` of a subtree, which are not fields of the node in this code: add them to the node, compute them in `recalc` (the minimum and maximum of `val` and of the two children) and shift them in `apply_lazy` (both change by `val`). It also goes to the right child only when `t->val < x`, which is correct only when the sequence is sorted by value; for an arbitrary sequence always recurse on the right child.
- Keep one random generator (the `mt19937` of the code) seeded with the clock.

#raw(read("code.cpp"), lang: "cpp", block: true)