#set text(size: 10pt)
#set par(justify: true)
#set heading(numbering: "1.")

= Cartesian Tree

== Concept

A *Cartesian tree* of an array $a_1, dots, a_n$ is a binary tree with one node per index that satisfies two rules at once:

- *In-order = array order.* Reading the tree left, node, right gives indices $1, 2, dots, n$.
- *Heap order on values.* Every node's value is smaller than (min-version) or larger than (max-version) the values of its children.

The root is the position of the minimum (or maximum) of the whole array. Its left subtree is the Cartesian tree of the part to the left of the root, and its right subtree is the tree of the part to the right. Every node $v$ therefore owns a *contiguous segment* $[l_v, r_v]$ of the array, and $op("sz")[v] = r_v - l_v + 1$.

*Ties.* With equal values the tree is not unique. A fixed rule is needed, for example "the leftmost maximum is the root".

== Why it is useful

- *Range queries.* The minimum (or maximum) of $a[l..r]$ is the value at $op("LCA")(l, r)$ in the tree.
- *Divide and conquer for free.* Each node is the extreme of its segment $[l_v, r_v]$, so "for every subarray, look at its maximum" becomes "for every node $v$, look at the subarrays that contain $v$ and lie inside $[l_v, r_v]$". There are $(v - l_v + 1) dot (r_v - v + 1)$ of them.
- *Small-to-large.* When combining information from the two sides of $v$, iterate over the smaller side. The total is $O(n log n)$ because the tree has $O(n)$ nodes and each element moves to a larger segment only when the segment size at least doubles.
- *Tree DP over the array.* Problems about segments and extremes become ordinary DP on a binary tree.

== How the code works

The code builds the *max* Cartesian tree (`spt<ll, mx>`). For the min-version use `mn`.

- `spt` is a *sparse table*. `v[bit][i]` stores the combined value of the $2^"bit"$ elements ending at $i$. `qry(l, r)` combines two overlapping blocks that cover $[l, r]$, which is valid for idempotent operations such as min and max. Build is $O(n log n)$, a query is $O(1)$.
- `find(l, r)` returns the position of the *leftmost* maximum of $[l, r]$. It computes the maximum value `tst` and binary searches the first prefix $[l, mid]$ whose maximum already equals `tst`. This costs $O(log n)$ per call.
- `build(l, r)` picks the root `id = find(l, r)`, then builds the left child from $[l, "id" - 1]$ and the right child from $["id" + 1, r]$. It returns `0` for an empty segment. `nodes[id]` stores `lf` and `rg`.
- The node's segment is $[l, r]$ at the moment of the call, so `sz[id] = r - l + 1` can be saved inside `build` when needed.

*Complexity.* $O(n log n)$ in total for the table and for the $n$ calls to `find`.

*Notes.*
- The recursion depth is $O(n)$ for a sorted array. Use an explicit stack if the limit is small.
- A monotonic stack builds the same tree in $O(n)$ and uses no sparse table. The sparse table version is handy when range queries are needed anyway.
- Inside `find`, the local variables `mx` and `mn` shadow the functions with the same names. This works, but renaming them avoids confusion.

#raw(read("code.cpp"), lang: "cpp", block: true)

== Counting the Arrays that Have a Given Tree

*Question.* Fix the shape of a Cartesian tree $T$ with $n$ nodes. In how many ways can the values $1, dots, n$ (all distinct) be placed on the nodes so that the min-heap property holds? Equivalently, how many permutations of $1..n$ have exactly this Cartesian tree?

*Formula.*
$ op("Ways")(T) = frac(n!, product_(v in T) op("sz")[v]) $

where $op("sz")[v]$ is the number of nodes in the subtree of $v$.
