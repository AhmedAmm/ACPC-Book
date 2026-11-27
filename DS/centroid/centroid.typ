#set text(size: 10pt)
#set par(justify: true)
#set heading(numbering: "1.")

= Centroid Decomposition

== Main Idea: Brute Force over All Paths, Made Cheap

A tree with $n$ vertices has $O(n^2)$ paths. Centroid decomposition lets us *look at all of them* without enumerating each one, by splitting the work so that every path is handled exactly once, at one special vertex.

+ Pick the *centroid* $c$ of the tree: a vertex whose removal leaves components of size at most $n / 2$.
+ Handle every path that passes through $c$.
+ Delete $c$ and repeat on each remaining component.

A path between $u$ and $v$ is handled at the first centroid that lies on it, which is the first one that separates $u$ from $v$. No path is missed and none is counted twice.

Handling paths through $c$ is easy because every such path is two *half paths* $u -> c$ and $c -> v$, which are independent of each other. So the question becomes: _given a list of half-path summaries (length, max, min, xor, count, and so on), combine pairs of them._ Combining pairs from a list is an ordinary array problem, usually solved by sorting, two pointers, or a Fenwick tree.

This is a *creative brute force*: we do the brute force "for all pairs", but on a flat list instead of on the tree, and the splitting guarantees that the lists are small in total.

== Finding the Centroid

Compute subtree sizes in the current component. Start anywhere and walk towards any child whose subtree is larger than `tot / 2`. When no such child exists, the current vertex is a centroid. Vertices already used as centroids are marked `done` and act as walls, so every recursive call sees only its own component.

*Default template.*

#raw(read("code.cpp"), lang: "cpp", block: true)

How the template works:
- `calc_sz(u, p)` computes the subtree size `sz` of every vertex in the current component, and counts the component size in `tot`. It skips the parent `p` and every `done` vertex.
- `find_cen(u, p)` walks down from `u`. If some child has `sz[v] > tot / 2`, the centroid must be inside that child, so it moves there. If no child is that large, `u` is the centroid.
- `decompose(u, pre)` runs the two steps, records `cenpar[cen] = pre` (the parent in the centroid tree, and `0` for the root), marks `done[cen] = 1`, and recurses on every neighbour that is not `done`. The recursive call on `v` receives `cen` as its parent.
- *Where to add work.* Put the problem-specific code between `done[cen] = 1` and the recursive loop. At that point `cen` is fixed and its component is still intact, except that `cen` itself is blocked for the children.
- Start with `decompose(1, 0)`.

== The Centroid Tree

Linking each centroid to the centroid of the component it was cut from (`cenpar`) gives a new tree on the same $n$ vertices, the *centroid tree*.

- *Depth is $O(log n)$.* Each component is at most half the size of its parent component.
- *Each vertex has $O(log n)$ ancestors.* Those are exactly the centroids whose components contain it.
- *LCA property.* For two vertices $u, v$, their LCA in the centroid tree is the first centroid that separates them, and it lies on the tree path between them. So every path is "owned" by one centroid: the LCA of its endpoints in the centroid tree.
- *Distances.* The distance from $v$ to any of its centroid ancestors can be stored while processing that ancestor, giving $O(n log n)$ numbers in total. Then $op("dist")(u, v) = op("dist")(u, c) + op("dist")(c, v)$ for $c$ equal to the centroid-tree LCA, with no extra LCA structure on the original tree.
- *The centroid tree is not a subtree structure of the original tree.* Its edges are not original edges. Only the *ancestor relationship* matters: "$c$ is an ancestor of $v$" means "$v$ is in $c$'s component".

Because of the depth bound, any work done per vertex per ancestor costs $O(log n)$ per vertex, and any work done per component costs $O(n)$ per level, so $O(n log n)$ over all levels, before the cost of the combining step.

== Combining Half Paths: The Inclusion-Exclusion Trick

At centroid $c$ the list of half paths includes pairs that lie in the *same* child subtree. Their real path does not pass through $c$ (it turns before reaching it), so such pairs must not be counted. Two clean ways to deal with them:

- *Subtract.* Count all valid pairs in the whole list, then for each child subtree build the list again, with the summary of $c$ already included in its starting value, count its pairs, and subtract. What is left is pairs from different subtrees only. The centroid itself is a record with the empty path, so pairs $(c, x)$ are counted too.
- *Add subtree by subtree.* Process the child subtrees one at a time. Query each new record against the structure holding the earlier subtrees, then insert the subtree. This avoids the subtraction, but the structure must support insertion.

The subtraction method is shorter to write when the combine step is a function that takes a list and returns the number of good pairs.

== Offline Path Queries

Centroid decomposition also answers *queries* if they are collected first and answered while processing each centroid. Two common shapes:

*Queries on a pair $(u, v)$.* The answer depends on the path between them, which passes through their centroid-tree LCA $c$. Attach the query to $c$. When $c$ is processed, the half-path summaries of $u$ and $v$ to $c$ are known, so the query is answered from them. The offline form is natural: group queries by $c$, collect them while the decomposition runs, and answer them together using the same sweep that handles the list.

*Queries on a single vertex $v$.* The path from $v$ to any other vertex $x$ has a centroid-tree LCA that is an ancestor of $v$ as well. So the query is split into $O(log n)$ parts, one per ancestor $c$ of $v$: "combine $v$'s summary to $c$ with all other records of $c$'s component". The records in the same child subtree as $v$ are subtracted, as above. A common instance is a set of *marked* vertices that changes over time and a query for the nearest one: keep for each centroid the best summary of marked vertices in its component, update the $O(log n)$ ancestors of a mark, and answer a query as the best combination over the ancestors of $v$.

*Why offline helps.*
- Per centroid, the list of records and the list of queries can be sorted together and swept once.
- Data structures are filled and then *undone by reversing the inserts*, so the cost is proportional to the component size, not to $n$.
- Time ordering (when the problem has updates) can be handled in the same sweep.

== Trick: Sliding Window over the Sorted List

The combine step is where the time goes, and it is often simplified by sorting the list by one coordinate and keeping a *window* of the records that are still allowed to pair with the current one.

*Two pointers.* If the condition is monotone (for example "sum of two values at most $K$"), sort the list and move two pointers from the ends. A fixed left record pairs with a contiguous range of right records, and the range only shrinks as the left value grows. This replaces a data structure with $O(s)$ work after the sort, where $s$ is the list size.

*Shrinking window with a Fenwick tree.* When the condition involves two coordinates, for example the maximum of one value and the minimum of another over the whole path, a single pointer is not enough.

+ Sort the records by the first coordinate.
+ Insert all records into a Fenwick tree indexed by the second coordinate.
+ Walk from the largest first coordinate to the smallest. Before handling a record, *remove* it from the tree. Now the tree holds exactly the records with a smaller or equal first coordinate that appear earlier in the order.
+ For the current record, the first coordinate of the combined path is its own (the others are no larger), so the condition reduces to a condition on the second coordinates. One Fenwick query counts the matches.

Why it works:
- The sort turns a "max of two values" into "the value of one of them", because the processed record is always the larger one in the pair.
- Removing the record first stops it from pairing with itself and makes every unordered pair appear once, from its larger side.
- Removals empty the tree again, so no clearing is needed between components.

The same window shape applies when the first coordinate is a length and the second a count of something, or when the condition is on a range of values: sort, maintain the window, query once per record.

*Cost.* Sorting dominates: $O(s log s)$ per list. Over all levels, the total is $O(n log^2 n)$. If the keys are small integers, bucket sort removes one logarithm.

== Checklist

+ Decide what a half path stores and how two halves merge into one path.
+ Make sure the centroid itself is a record (the empty half path), so paths that end at $c$ are counted.
+ Remove the pairs inside one child subtree (subtract, or insert subtree by subtree).
+ Choose the combine method: two pointers if monotone, sorted sweep with a Fenwick tree for two coordinates.
+ Attach pair queries to their centroid-tree LCA, and single-vertex queries to all $O(log n)$ ancestors.
+ Undo the structures by reversing the inserts, never by clearing arrays of size $n$.
+ Watch the recursion depth (convert the DFS to an iterative form on long paths), overflow, and the double counting of unordered pairs.