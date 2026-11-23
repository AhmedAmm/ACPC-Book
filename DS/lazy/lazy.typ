#set text(size: 10pt)
#set par(justify: true)

= Lazy Segment Tree

== 1. What it is

*Idea:* a segment tree that supports a *range update* and a range query, both in $O(log n)$. Each node keeps its summary and a pending tag (the lazy value): "this update is already applied to my summary, but my children do not know about it yet".

#table(
  columns: (auto, 1fr),
  [*Symbol*], [*Meaning*],
  [$"sum"(v)$], [summary of the node $v$ (here the sum of its segment)],
  [$"len"(v)$], [number of elements in the segment of $v$],
  [$"lazy"(v)$], [the pending tag of $v$ (the identity tag means nothing is pending)],
)

== 2. How it works

- *apply*$(v, x)$: put the tag $x$ on the node in $O(1)$, without looking at the children. For range add with sum:

$ "sum"(v) arrow.l "sum"(v) + x dot "len"(v), quad "lazy"(v) arrow.l "lazy"(v) + x $

- *push*$(v)$: send the pending tag to both children with *apply*, then reset $"lazy"(v)$ to the identity.
- *pull*$(v)$: recompute the node from its children, $"sum"(v) = "sum"(2v) + "sum"(2v + 1)$.
- *Update* $[l, r]$: a node completely inside $[l, r]$ gets *apply* and the recursion stops. Otherwise *push*, go to the children that intersect $[l, r]$, then *pull*.
- *Query* $[l, r]$: the same walk, with *push* before going down, and no *pull*.

*What the tag must satisfy:*
- It can be applied to a node summary in $O(1)$.
- Two tags can be combined into one tag (so a node can hold several updates).

#table(
  columns: (1fr, 1fr, 1fr),
  [*Update / query*], [*Apply to the node*], [*Combine two tags*],
  [add $x$ / sum], [$"sum" arrow.l "sum" + x dot "len"$], [$x_1 + x_2$],
  [add $x$ / max (or min)], [$"max" arrow.l "max" + x$], [$x_1 + x_2$],
  [assign $x$ / sum], [$"sum" arrow.l x dot "len"$], [the newer tag replaces the older],
  [$a_i arrow.l p a_i + q$ / sum], [$"sum" arrow.l p dot "sum" + q dot "len"$], [$(p_2, q_2) ∘ (p_1, q_1) = (p_2 p_1, p_2 q_1 + q_2)$],
)

When the updates do not commute (assign, affine), the tags must reach the children in the order of the updates, which is why *push* is done before a new tag is put on a node that already has one.

== 3. Complexity

- Update and query: $O(log n)$.
- Build: $O(n)$. Memory: $O(n)$, about $4n$ nodes for the summaries and $4n$ for the tags.

== 4. Code

#raw(read("code.cpp"), lang: "cpp", block: true)