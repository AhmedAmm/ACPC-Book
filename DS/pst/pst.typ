#set text(size: 10pt)
#set par(justify: true)

= Persistent Segment Tree

== 1. What it is

*Idea:* a segment tree that keeps *all its old versions*. An update never changes a node; it copies the nodes on the path from the root to the leaf (path copying) and shares every other node with the previous version.

#table(
  columns: (auto, 1fr),
  [*Symbol*], [*Meaning*],
  [node], [`val` (the summary, here a count or a sum), `left` and `right` (indices of the children)],
  [version], [identified by the index of its root; the same node can belong to many versions],
  [node 0], [the empty node: `val` $= 0$ and both children are 0, so it is also the empty tree, the version before any update],
)

- An update on version $v$ creates a *new root* and about $log n + 1$ new nodes; the version $v$ stays intact. Keep the roots in an array: $"root"_i$ is the tree after the $i$-th update.
- A query takes a root, so it can be asked on any version.
- *Subtracting two versions:* if the tree stores counts, the version $r$ minus the version $l - 1$ is exactly the tree of the updates $l, dots, r$. This is what makes range queries possible.

*With the code below* ($n$ is the size of the value range):
- `root[i] = set(pos, +1, root[i - 1], 0, n - 1)` adds one occurrence of the value `pos` to the previous version. `set` adds `val` at the leaf, it does not assign.
- `get(l, r, root[i], 0, n - 1)` returns the sum of the values in $[l, r]$ of the version $i$ (the node it returns holds it in `val`).
- `kth(k, 0, root[l - 1], root[r], 0, n - 1)` returns the $k$-th smallest value among the updates $l, dots, r$, or $-1$ if there are fewer than $k$ of them. It descends two versions at once.

== 2. Problems it solves

#table(
  columns: (1fr, 2fr),
  [*Problem*], [*Idea*],
  [$k$-th smallest in a range $a[l..r]$ (SPOJ MKTHNUM)], [compress the values; version $i$ = version $i - 1$ plus the value $a_i$; descend in $"root"_r$ and $"root"_(l-1)$ with the difference of the counts],
  [Count the values in $[x, y]$ among $a[l..r]$], [$"get"(x, y, "root"_r) - "get"(x, y, "root"_(l-1))$],
  [Distinct values in a range, online], [version $i$ is indexed by *position*: add $+1$ at $i$ and $-1$ at the previous occurrence of $a_i$. Then the answer is the sum of $[l, r]$ in $"root"_r$ (the persistent form of the Fenwick sweep)],
  [Points in a rectangle, online], [sort the points by $x$, version = prefix of the points, tree over $y$; the count in $[x_1, x_2] times [y_1, y_2]$ is a difference of two versions],
  [$k$-th value on a tree path (SPOJ COT)], [version of a vertex = version of its parent plus its value; the path $u, v$ is $"root"_u + "root"_v - "root"_("lca") - "root"_("parent of lca")$, so descend in four versions at once],
  [Queries about the past ("what was the value at position $p$ after the update $t$")], [keep the root of every update, query that root],
  [Forced online queries], [when each query is decoded with the previous answer, an offline sweep is impossible, but a persistent tree answers every query on arrival],
  [Range update on a persistent tree], [put the tag on the nodes and never push it down (permanent tags); a query adds the tags met on the way. About $4 log n$ new nodes per update],
)

When the queries can be read first, an offline method (a Fenwick sweep, Mo's algorithm) uses less memory. The persistent tree is the tool when the queries must be answered online, or when old versions are needed.

== 3. Memory optimisation: time tag

*Problem:* path copying creates $log n + 1$ new nodes for *every* update, even when the previous root is never needed. Example: a version is built by adding $a_i$ and then $a_i$ again (or a batch of $u$ values, the values of one vertex, the initial array). The roots between the updates are never queried, but $u (log n + 1)$ nodes are created.

*Idea:* every node remembers the *time* (the number of the version) that created it.
- While building the version $t$, a node whose time is $t$ can only be seen by the version $t$, so it is *changed in place* instead of being copied.
- A node with an older time belongs to an older version: copy it and give the copy the time $t$.
- So the first update of a version copies its path, and the next updates of the same version copy only the part of their path that was not copied yet.

*What has to be added to the tree:*
- a field `tm` in every node, equal to 0 at the start (the empty node 0 has time 0);
- the number of the version being built as an extra parameter of the update;
- at the start of the update: if the node has `tm` equal to that number, reuse it, otherwise create the copy and set its `tm` to that number.

*Rules:*
- Number the versions from 1, so that the empty node is never changed in place.
- Use the same number for all the updates of one version, starting from the root of the version you build on.
- When a version is finished, never use its number again, because other versions may now share its nodes.

$ "nodes of a version with " u " updates" <= min(u (log n + 1), 2n - 1) $

*Example:* $2 dot 10^5$ updates in one version over $2 dot 10^5$ values create about $3.1 dot 10^5$ nodes instead of $3.8 dot 10^6$. If every update is its own version (every root is queried) nothing is saved, and the tag costs 4 more bytes per node.

== 4. Complexity

- `set`: $O(log n)$ time and $log n + 1$ new nodes (one per level).
- `get`: $O(log n)$.
- `kth`: $O(log n)$. The left call returns at once when the left side has too few elements, so only one path is followed.
- Memory: $O((n + q) log n)$ nodes of 3 integers (12 bytes). For $2 dot 10^5$ updates this is about $3.8 dot 10^6$ nodes, about 46 MB. The `reserve(3e6)` in the code is only a preallocation, the vector still grows past it.
- With $m$ distinct values the tree has $m$ leaves, so compress the values first.
- With the time tag a version of $u$ updates creates at most $min(u (log n + 1), 2n - 1)$ nodes (section 3).

== 5. Code

#raw(read("code.cpp"), lang: "cpp", block: true)