#set text(size: 10pt)
#set par(justify: true)

= Heavy-Light Decomposition (HLD)

Heavy-Light Decomposition is a tree technique that breaks a tree into chains by choosing the largest-subtree child of each vertex as its *heavy child*. This allows a path between any two vertices to be split into $O(log N)$ contiguous segments, which can then be processed using a segment tree or another range data structure.

== Problems HLD Can Solve

HLD is useful when a problem requires efficient operations on tree paths or subtrees, such as:

- *Path queries:* find the sum, maximum, minimum, or GCD of vertex or edge values on a path.
- *Path updates:* add a value or apply another supported update to every vertex or edge on a path.
- *Subtree queries:* calculate an aggregate, such as the sum or maximum, over a subtree.
- *Subtree updates:* update all values inside a subtree.
- *Dynamic tree problems:* answer queries while vertex or edge values change over time.

== Complexity

With a segment tree, path queries and updates generally take $O(log^2 N)$, while subtree queries and updates take $O(log N)$. The HLD decomposition itself takes $O(N)$ preprocessing time.

#emph[Main idea:] HLD turns a tree path into a small number of array ranges, allowing efficient range queries and updates with standard data structures.

= Implementation 1: HLD + Binary Lifting

#raw(read("code.cpp"), lang: "cpp", block: true)

= Implementation 2: HLD + Lazy Segment Tree

#raw(read("code1.cpp"), lang: "cpp", block: true)
