#set text(size: 10pt)
#set par(justify: true)

= Segment Tree

== 1. What it is

*Idea:* a binary tree over an array. The node $v$ covers a segment $[l, r]$ and stores a summary of it (sum, min, max, gcd, count, ...). Its children cover the two halves, split at $m = (l + r) / 2$.

$ "node"(v) = "combine"("node"(2v), "node"(2v + 1)) $

- *Point update:* go down to the leaf, change it, recompute the nodes on the way back. $O(log n)$.
- *Range query:* a segment splits into $O(log n)$ nodes of the tree, combine their summaries. $O(log n)$.
- Memory: $4n$ nodes (the recursive version).
- The operation must be associative (sum, min, max, gcd, xor, matrix product).

== 2. Tricks

- *Range update with point query:* put the tag $+x$ on the $O(log n)$ nodes that cover $[l, r]$ and never push it down. The value of position $i$ is $a_i$ plus the sum of the tags on the path from the root to the leaf $i$.
- *K-th value in a prefix:* build a persistent tree over the compressed values (a node stores a count) with one version per prefix. In version $i$ go left if $k <= "cnt"("left")$, else set $k arrow.l k - "cnt"("left")$ and go right.
- *K-th value in a range:* use the same tree and descend in the versions $r$ and $l - 1$ together, with $c = "cnt"_r ("left") - "cnt"_(l-1) ("left")$ in place of $"cnt"("left")$.

== 3. Code

#raw(read("code.cpp"), lang: "cpp", block: true)

== 4. Dynamic segment tree

#raw(read("code1.cpp"), lang: "cpp", block: true)
