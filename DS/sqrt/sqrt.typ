#set text(size: 10pt)
#set par(justify: true)

= Sqrt Decomposition

== 1. The main idea

*Idea:* cut the array of $n$ elements into blocks of size $B$, so there are $n / B$ blocks. Every block keeps a summary of its elements (sum, min, a sorted copy, a lazy tag, ...). An operation on a range touches two kinds of pieces:

#table(
  columns: (auto, 1fr, 1fr),
  [], [*Partial blocks (the two ends)*], [*Full blocks (the middle)*],
  [How many], [at most $2B$ single elements], [at most $n / B$ blocks],
  [Query], [look at the elements one by one], [read the summary of the block],
  [Update], [change the elements, then rebuild the summary of that block in $O(B)$], [put a lazy tag on the block in $O(1)$],
)

$ "cost of one operation" = O(B + n / B) quad arrow.r quad B = sqrt(n) quad arrow.r quad O(sqrt(n)) $

- The block of the index $i$ (0-indexed) is $floor(i / B)$, and the block $k$ covers $[k B, min(n, (k + 1) B) - 1]$.
- If $l$ and $r$ are in the same block, just loop over the elements from $l$ to $r$.
- It is slower than a segment tree ($sqrt(n)$ against $log n$), but it needs almost no theory, so it works for operations that a segment tree cannot merge (counting values $>= x$, jumping pointers, modes).

== 2. Changing the block size when a block costs a log

If looking at one full block costs $log$ (for example a binary search in a sorted block) the cost of an operation is

$ f(B) = (n / B) dot log + 2B $

Setting the derivative to zero, $-n log / B^2 + 2 = 0$, gives

$ B = sqrt(n log / 2), quad f(B) = 2 sqrt(2 n log) = O(sqrt(n log n)) $

Example, $n = 10^5$ and $log approx 17$: with $B = sqrt(n) approx 316$ one operation costs about $316 dot 17 + 632 approx 6000$, with $B = sqrt(n log / 2) approx 920$ it costs about $109 dot 17 + 1840 approx 3700$.

*General rule:* if a full block costs $a$ and an element of a partial block costs $b$, the cost is $a n / B + b B$ and the best size is

$ B = sqrt(a n / b), quad "cost" = 2 sqrt(a b n) $

*Updates and queries with different costs:* with $U$ updates of cost $O(B)$ and $Q$ queries of cost $O(n / B)$ the total is $U B + Q n / B$, so take $B = sqrt(n Q / U)$. Many queries and few updates means a bigger block. In practice use a constant $B$ (a power of two if you want shifts) and test a few values.

== 3. Problems that can be solved

#table(
  columns: (1fr, 2fr),
  [*Problem*], [*Idea*],
  [Range add, range sum], [block sum plus a lazy tag per block; partial blocks element by element. $O(sqrt(n))$],
  [Range add, count the elements $>= x$ in a range], [every block keeps a *sorted copy* and a lazy value. Query: binary search $x - "lazy"$ in each full block, scan the partial blocks. Update: re-sort the two partial blocks (one merge, $O(B)$). Cost $(n / B) log B + B$, so tune the size as in section 2],
  [Holes (CF 13E): jump from the hole $i$ to $i + a_i$, count the jumps until you leave], [for each position store the number of jumps and the last hole to leave its own block. A query follows one jump per block, $O(n / B)$; an update rebuilds one block backwards, $O(B)$],
  [Range mode, static], [precompute the mode for every pair of blocks (a table of size $(n / B)^2$, built in $O(n dot n / B)$); a query starts from that answer and adds the elements of the two partial blocks using position lists],
  [Range assign, range min], [a block is either "all equal to $x$" (a tag) or a normal block; push the tag down only when a partial update arrives],
  [Offline queries on a static array (distinct values, counts of a value, ...)], [Mo's algorithm, section 5],
)

== 4. Heavy and light processing

*Idea:* split the items by a threshold $T$ (usually $sqrt(n)$) on a size, a degree or a frequency.
- *Light* items (size $<= T$) are handled by brute force, $O(T)$ each.
- *Heavy* items (size $> T$) are *few*: if the sizes add up to $n$, there are at most $n / T$ of them. Each one gets its own $O(n)$ process.

With $T = sqrt(n)$ both parts cost $O(n sqrt(n))$ in total.

*Examples*

- *Sum along a progression:* queries $(x, y)$ ask for $a_x + a_(x+y) + a_(x+2y) + dots$ (CF 103D; CF 797E uses the same small and large split on the step).
  - Step $y > sqrt(n)$ (heavy step): walk it, at most $n / y < sqrt(n)$ terms.
  - Step $y <= sqrt(n)$ (light step): precompute $"dp"_y [x] = a_x + "dp"_y [x + y]$, in $O(n)$ per step, or group the queries by $y$ and reuse one array.
- *Intersection of two sets:* the sets have total size $N$ and the queries ask for the size of the intersection of two of them.
  - A set with more than $sqrt(N)$ elements is heavy, there are at most $sqrt(N)$ of them: for each one precompute its intersection with every other set in $O(N)$.
  - For two light sets, go through the smaller one and test membership in the other (a hash set or a bitset), $O(sqrt(N))$.
- *Values that repeat many times:* a value with more than $sqrt(n)$ occurrences is heavy (at most $sqrt(n)$ of them): keep a prefix count array for each of them. A light value has few positions, so loop over its position list.
- *Graph, update a vertex and ask the sum of its neighbors:* a vertex with degree $> sqrt(m)$ is heavy (at most $2 sqrt(m)$ of them).
  - Every heavy vertex stores the current sum of its neighbors. An update of $v$ changes the stored value of each heavy neighbor of $v$, which is at most $2 sqrt(m)$ of them.
  - A query on a light vertex loops over its $<= sqrt(m)$ neighbors; a query on a heavy vertex reads the stored value.
- *Triangles in a graph:* give each edge the direction from the endpoint with the smaller degree to the other one (ties by index). Every vertex gets at most $sqrt(2m)$ outgoing edges, so for each vertex $u$ mark its out-neighbors, then for each edge $u arrow.r v$ and each out-neighbor $w$ of $v$ check whether $w$ is marked. Every triangle is found once and the cost is $O(m sqrt(m))$.

== 5. Batch processing

*Idea:* handle the operations in batches of $B$. Keep a structure that is *correct for the state at the start of the batch* and rebuild it after each batch. Inside a batch, the at most $B$ pending changes are handled naively for every query.

$ "cost" = underbrace(q / B dot "rebuild", "rebuilds") + underbrace(q dot B, "pending changes per query") $

*Example, Xenia and Tree (CF 342E):* some tree vertices are painted red, a query asks for the distance to the nearest red vertex.
- Every $B$ paintings run one BFS from all the red vertices, $O(n)$, so the distances are correct for the old red vertices.
- A query takes the BFS value and also checks the at most $B$ new red vertices with an LCA distance in $O(1)$.
- Total $O((q / B) n + q B)$, with $B = sqrt(n)$ it is $O((n + q) sqrt(n))$.

*Same idea for updates with offline queries:* inside a batch only $O(B)$ positions are touched, so the untouched parts between them can be compressed into single pieces and the batch is solved on a structure of size $O(B)$.

*Mo's algorithm* is the same idea on queries: sort them by (block of $l$, $r$) and move two pointers.
- Inside a block of $l$ the pointer $l$ moves at most $B$ per query and the pointer $r$ only moves forward, at most $n$ per block.
- Total $O(q B + n^2 / B)$, so take $B = n / sqrt(q)$, which gives $O(n sqrt(q))$.
- It needs a structure where adding or removing one element at an end costs $O(1)$ (a count array, a running sum).

== 6. The sum of distinct integers is at most $sqrt(n)$

*Fact:* if $k$ different positive integers add up to at most $n$, then

$ 1 + 2 + dots + k <= n quad arrow.r quad k (k + 1) / 2 <= n quad arrow.r quad k <= sqrt(2 n) $

So when some quantities add up to $n$, there are only $O(sqrt(n))$ *different* values among them, and you can do the work once per different value instead of once per item.

*Examples*
- *Component sizes of a graph* (they add up to $n$): there are at most $sqrt(2 n)$ different sizes. A subset-sum or knapsack over the components becomes a bounded knapsack with $sqrt(2 n)$ item types, $O(n sqrt(n))$ (split a count $c$ into $1, 2, 4, dots$, or use the sliding window on residues).
- *Pattern lengths:* a dictionary with total length $L$ has at most $sqrt(2 L)$ different lengths, so matching with hashing keeps one hash set per length, $O(|T| sqrt(L))$.
- *Degrees:* the degrees add up to $2 m$, so a graph has at most $2 sqrt(m)$ different degrees.
- *Partition into distinct parts:* a number $n$ has at most $sqrt(2 n)$ parts, so a dp over (number of parts, sum) has $O(n sqrt(n))$ states.
- *Sizes of the children of a vertex:* the sizes of the subtrees of the children add up to the size of the vertex, so there are few different ones, and equal sizes can be handled together.