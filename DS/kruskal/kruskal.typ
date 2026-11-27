#set text(size: 10pt)
#set par(justify: true)
#set heading(numbering: "1.")

= Kruskal Reconstruction Tree (DSU with Merge Tree)

== Concept

A *Kruskal Reconstruction Tree* (KRT) records the history of DSU merges as a tree. Normally, merging two components throws away their identity. Here, every successful merge creates a *new virtual node* that becomes the parent of the two merged components.

- The $n$ original vertices are *leaves* with ids $1..n$.
- Every successful merge creates a new internal node with id $n+1, n+2, dots$ and stores the edge weight on it.
- A connected graph ends up with exactly $2n - 1$ nodes, so arrays of size $2n$ are enough.
- If the edges are processed in increasing weight order (Kruskal), weights are non-decreasing from leaves to root. The tree is also a heap by weight.

*Key property.* The set of vertices reachable from a KRT node $x$ (its subtree) is exactly the component that existed right after that edge was added. Therefore:

- Two vertices $u, v$ are first connected at time $t$ if and only if $t$ is the time of $op("LCA")(u, v)$.
- In a Kruskal order, the minimax path weight between $u$ and $v$ is the weight stored at $op("LCA")(u, v)$.
- "All vertices reachable from $u$ using edges $<= w$" is a subtree: climb from $u$ to the highest ancestor with weight $<= w$ (binary lifting). Subtrees are contiguous ranges in the DFS order, so range data structures apply.

== Complexity

- DSU: $O(alpha(n))$ per operation, so building the tree takes $O(m alpha(n))$.
- DFS and DP: $O(n)$, as the tree has $2n - 1$ nodes.
- Memory: $O(n)$ for `g`, `val`, `odd` (size $2n + 1$).

== Implementation notes

- The tree has at most $2n$ nodes, so `g`, `val`, `odd` are sized `2n + 1`.
- The DFS can reach depth $O(n)$, because the KRT can be a path (a chain of merges). Use an iterative DFS, or process ids in decreasing order instead, since children always have smaller ids than their parent. This avoids recursion limits and `std::function` overhead.
- If the graph is disconnected, there are several roots. Run the DP on every root (every `d.id(i)` where `i` is a DSU root), not only on `id`.
- Capture `u_id` and `v_id` *before* calling `merge`, because afterwards `rep` changes.
- Use `long long` for `val` and for the answer. The `INF` sentinel must be large but safe from overflow in the multiplication.

#raw(read("kruskal.cpp"), lang: "cpp", block: true)

= Hard Problems Solvable with a Kruskal Reconstruction Tree

All statements below are written in full so that no outside material is needed. In every problem, the same pattern appears: _paths or components with a bound on edge weights, or minimax/maximin paths_. Build the KRT, then solve a problem on a tree.

== Recognizing the pattern

- "Minimize the maximum edge on a path" (minimax) $->$ weight of $op("LCA")$ in the KRT.
- "Using only edges of weight $<= x$, which vertices can I reach?" $->$ a subtree of an ancestor, found by binary lifting.
- "k-th largest or smallest value among reachable vertices" $->$ DFS order plus a persistent segment tree or merge-sort tree on the subtree range.
- "Components evolve with time and each needs some aggregate" $->$ tree DP over the KRT, as in the code above.
- "Edges are added by time" $->$ the same idea with time as the weight.

== Problem 1: Minimax path queries (warm-up)

*Statement.* An undirected weighted graph has $n$ vertices and $m$ edges. There are $q$ queries $(u, v)$. For each query, consider all paths from $u$ to $v$ and, for each path, its largest edge weight. Print the smallest such value, or $-1$ if $u$ and $v$ are not connected.

*Limits.* $n, m, q <= 2 dot 10^5$.

*Solution.* Build the KRT with edges sorted by weight. The answer is $w[op("LCA")(u, v)]$, or $-1$ if they are in different trees. Use binary lifting or an Euler tour with a sparse table for the LCA. Time $O((m + q) log n)$.

== Problem 2: First time a whole range becomes connected

*Statement.* There are $n$ vertices and $m$ edges, given in the order they are added. There are $q$ queries $(l, r)$. For each query, print the smallest $k$ such that after adding the first $k$ edges all vertices $l, l+1, dots, r$ are in the same component, or $-1$ if this never happens. A query with $l = r$ has answer $0$.

*Solution.* Use the edge index as the weight in the KRT. Let $t_i = w[op("LCA")(i, i+1)]$ (infinite if disconnected). Vertices $l..r$ are all connected exactly when every adjacent pair is connected, so the answer is $max(t_l, dots, t_(r-1))$. Answer it with a sparse table. Time $O((n + m + q) log n)$.

*Why it is hard.* A direct approach uses parallel binary search or small-to-large merging. The reduction to adjacent pairs is the key step.

== Problem 3: k-th largest value in the reachable set (online)

*Statement.* A graph has $n$ vertices, where vertex $i$ has a height $h_i$, and $m$ edges with weights. There are $q$ queries $(v, x, k)$. Among all vertices reachable from $v$ using only edges of weight $<= x$ (including $v$), print the $k$-th largest height, or $-1$ if fewer than $k$ vertices are reachable. Queries must be answered online: the real $v, x, k$ are obtained by xor-ing the input values with the previous answer (using $0$ if the previous answer was $-1$).

*Solution.*
+ Build the KRT. Compute `tin`/`tout` over the *leaves* with a DFS, so each node's subtree is a contiguous range of leaves.
+ For a query, find $a = op("climb")(v, x)$. The reachable set is the leaf range of $a$.
+ Build a persistent segment tree (or a wavelet tree) over the leaf order, indexed by compressed height. The $k$-th largest in a range is found by descending two versions at once.

Time $O((m + q) log n)$, memory $O(n log n)$. Binary lifting is required because the queries are forced online.

== Problem 4: Two independent weights, count vertices

*Statement.* An undirected graph has $n$ vertices and $m$ edges. Each edge $e$ has two weights $(a_e, b_e)$. There are $q$ queries $(v, A, B)$. Count the vertices $u$ such that there exists a path from $v$ to $u$ using only edges with $a_e <= A$, *and* there exists a (possibly different) path from $v$ to $u$ using only edges with $b_e <= B$. The offline version is allowed.

*Solution.*
+ Build two KRTs: $T_a$ sorted by $a$, and $T_b$ sorted by $b$.
+ For each leaf $u$ record the point $(op("tin")_a (u), op("tin")_b (u))$, using the leaf order of each tree.
+ For a query, climb in $T_a$ with $A$ and in $T_b$ with $B$. The two subtrees are leaf ranges $[l_1, r_1]$ and $[l_2, r_2]$.
+ The answer is the number of points inside the rectangle $[l_1, r_1] times [l_2, r_2]$.

Solve the rectangle counting offline with a sweep line and a Fenwick tree, in $O((n + q) log n)$.

*Note.* If the problem instead required a *single* path using both constraints at once, this does not work: that is a filtered graph and needs a different approach. Read the statement carefully.

== Problem 5: Shortest distance after a restricted ride

*Statement.* A connected graph has $n$ vertices and $m$ edges. Each edge has a length $l_e$ and an altitude $a_e$. Vertex $1$ is the home. Queries are $(v, p)$: a car starts at $v$ and may drive only on edges with altitude $> p$. The car can be left at any vertex it reaches, and from there the person walks to vertex $1$ on any route, with cost equal to the sum of lengths. Print the minimum walking distance. Queries are online.

*Solution.*
+ Run Dijkstra from vertex $1$ to get $d_u$ for all $u$.
+ Build the KRT on the *maximum* spanning order (sort altitudes in decreasing order). The condition "all edges $> p$" becomes "weight $> p$" when climbing.
+ For each KRT node store `best[x]` = the minimum $d_u$ over the leaves in its subtree, computed bottom up.
+ For a query, climb from $v$ while the parent weight is $> p$. The answer is `best` of the node reached.

Time $O((n + m) log n + q log n)$.

*Why it is hard.* Three ideas combine: shortest paths, a reversed KRT, and a subtree minimum. The easy mistake is running Dijkstra per query.

== Problem 6: Sum of all pairwise minimax values

*Statement.* An undirected connected graph has $n$ vertices and $m$ weighted edges. For each unordered pair $\{u, v\}$ let $f(u, v)$ be the minimax path weight. Print $sum_({u, v}) f(u, v)$ modulo $10^9 + 7$.

*Solution.* Every pair has its LCA in exactly one internal node $p$ of the KRT. For a node with children $c_1, c_2$, the number of pairs having it as LCA is $op("sz")[c_1] dot op("sz")[c_2]$. Therefore the answer is
$ sum_p w[p] dot op("sz")[c_1(p)] dot op("sz")[c_2(p)]. $
Time $O(m log m + n)$.

*Variant.* "Count pairs with $f(u, v) <= X$ for many $X$": sort internal nodes by weight and accumulate the same products, then binary search per query.

== Problem 7: Parity matching on a growing graph (the idea of the code above)

*Statement (the shape of the problem).* Edges are given in an order, each with a cost. Every vertex whose number of incident edges is odd must be matched with another odd vertex. A match is paid with the cheapest edge cost that is usable for the two vertices. Print the total cost.

*Solution.* Build the KRT in input order and keep for every node the cheapest usable edge. Push cheap values down to the children, then process the tree bottom up. At each node match as many odd leftovers as possible, pay `val[node]` per pair, and pass at most one unmatched vertex to the parent. This is exactly the DP in the code above.

*Warning.* The exact statement of the problem the code was written for is not reproduced here. Paste its text into this section so that the book is complete.

== Typical ways to make a problem harder

- *Online forced queries* (answers xor into the next query): this requires binary lifting and persistent structures, not offline DSU.
- *Two weights per edge*: build two KRTs and intersect subtrees using the leaf ranges (2D counting, offline Fenwick tree or merge-sort tree).
- *Counting instead of existence*: tree DP over the KRT with `sz[x]` and combinatorics, as in Problem 6.
- *Parity or matching constraints*: a leftover-state DP per component, passed up to the parent.
- *Edge insertion times as weights*: the first time two vertices are connected is the weight of their LCA, which replaces binary search over a partially persistent DSU.
- *Preprocessing that changes the weights*: for example a shortest-path computation first, as in Problem 5.

== Solving checklist

+ Sort the edges (or keep them in time order) and build the KRT with a DSU, creating a new node per successful merge.
+ Decide what the *non-tree* edges contribute. They are often recorded on the component node, as `val[...]` is in the code.
+ Choose the traversal: Euler tour of the leaves for subtree ranges, binary lifting for "highest ancestor with weight $<= x$", $op("LCA")$ for minimax.
+ Push constraints down and aggregate answers up. Process node ids in decreasing order to avoid deep recursion.
+ Handle disconnected graphs (a forest of KRTs), the sentinel values and overflow.