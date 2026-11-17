#set text(size: 10pt)
#set par(justify: true)
#let md = "mod"

= Aho-Corasick

== 1. What it does

*Idea:* KMP for many patterns at once. Find all occurrences of all patterns $P_1, dots, P_k$ in a text $T$ in $O(|T| + L)$, plus the size of the output if every occurrence is listed.

#table(
  columns: (auto, 1fr),
  [*Symbol*], [*Meaning*],
  [$L$], [total length of all patterns],
  [$Sigma$], [alphabet size (26)],
  [node $v$], [one prefix of some pattern (a trie node); node 0 is the empty prefix (root)],
  [$"fail"(v)$], [failure link of $v$],
  [$"go"(v, c)$], [next state from $v$ after reading letter $c$],
  [$"end"(p)$], [node where pattern $p$ ends],
)

*State meaning:* after reading a prefix of the text, the current node is the *longest suffix of the text read so far that is a prefix of some pattern*.

== 2. Construction (3 steps)

+ *Trie.* One node per distinct prefix of the patterns. Cost $O(L)$.
+ *Failure links (BFS, shallow nodes first).* $"fail"(v)$ is the longest proper suffix of the string of $v$ that is also a node. For a child $u = "go"(v, c)$:

$ "fail"(u) = "go"("fail"(v), c) $

*Why:* a suffix of $u$ is a suffix of $v$ followed by $c$. Children of the root have $"fail" = 0$.

+ *Automaton.* If the edge is missing, borrow it from the failure link:

$ "go"(v, c) = "go"("fail"(v), c) quad "if the edge " (v, c) " does not exist" $

After this every node has all $Sigma$ transitions, so reading a letter is $O(1)$ with no fallback loop.

== 3. The failure link trick

All the patterns that end at the current text position are the nodes on the chain

$ v, quad "fail"(v), quad "fail"("fail"(v)), quad dots, quad "root" $

that are ends of patterns, because every node on the chain is a suffix of the text read so far.

*Three ways to use the chain:*
- *Walk it* at every position. Simple, but it can cost $O(|T| dot "depth")$. Example: patterns $a, a a, a a a, dots$ and text $a a a dots$. This is what `search` in the code does.
- *Dictionary link:* for each node store the nearest pattern-end on its chain. Then the walk costs only the number of real occurrences.
- *Count on the failure tree* (next section). No walking at all.

*Values along the chain:* if every pattern has a weight $w$, then

$ "val"(v) = w(v) + "val"("fail"(v)) $

computed once in BFS order. The score of a text is the sum of $"val"("state")$ over its positions.

== 4. Failure tree and Euler tour

Make $"fail"(v)$ the parent of $v$ (root = node 0). This is the *failure tree*.

*Key fact:* pattern $p$ ends at a text position $<=>$ $"end"(p)$ is an ancestor of the current state in the failure tree (or equal to it). So:

$ "occ"(p) = "number of text positions whose state lies in subtree"("end"(p)) $

*Euler tour:* flatten the failure tree with entry and exit times $"tin"$ and $"tout"$. The subtree of $v$ is the contiguous range $["tin"(v), "tout"(v)]$, so "inside the subtree" becomes a range query.

*Fixed text, count everything:*
- Add 1 to $"cnt"["state"]$ for each text position.
- Push the counts up the tree, deepest nodes first: $"cnt"["fail"(v)] = "cnt"["fail"(v)] + "cnt"[v]$ (add the child's value to its parent).
- Then $"occ"(p) = "cnt"["end"(p)]$ for every pattern at once, in $O(|T| + L)$.

*Text that changes (contributions):* keep a Fenwick tree over the Euler tour.
- A text position (prefix) with state $s$ becomes active: add $+1$ at $"tin"(s)$.
- It is removed: add $-1$ at the same place.
- Query pattern $t$: the sum over $["tin"("end"(t)), "tout"("end"(t))]$ is the number of occurrences of $t$ right now.
- Cost: $O(log L)$ per update and per query.

== 5. Problems it solves

#table(
  columns: (1fr, 2fr),
  [*Problem*], [*Idea*],
  [Count or list the occurrences of many patterns in a text], [run the automaton, then count on the failure tree],
  [Does the text contain a forbidden word], [$"bad"(v) = "isEnd"(v) " or " "bad"("fail"(v))$; never enter a bad state],
  [Count strings of length $n$ that avoid the words], [DP over (position, state), skip bad states. For huge $n$: matrix power on the states, $O(S^3 log n)$],
  [Count strings that contain all the words], [DP over (position, state, mask of words seen), with $"mask"(v) = "mask"(v) | "mask"("fail"(v))$],
  [Shortest string that contains all the words], [BFS over (state, mask)],
  [Smallest or $k$-th string that avoids the words], [count with the DP above, then build letter by letter],
  [Word segmentation: ways to split a text into dictionary words], [$"dp"[i] = sum "dp"[i - |w|]$ over the words $w$ that end at $i$ (the pattern-ends on the chain)],
  [Best score or value of a text with weighted words], [$"val"(v) = w(v) + "val"("fail"(v))$, then add $"val"("state")$ along the text],
  [Occurrences of $t$ in strings built by appending a letter to an earlier string], [put all the $t$ in the automaton, DFS over the tree of strings, $+1$ on enter and $-1$ on leave on the Euler tour, query the subtree of $"end"(t)$],
)

== 6. Complexity

- Build: $O(L dot Sigma)$ time and memory (26 transitions per node).
- Search with the automaton: $O(|T|)$, plus the chain walk if you list occurrences.
- Count all patterns on the failure tree: $O(|T| + L)$.
- Dynamic version: $O(log L)$ per update and per query.

== 7. About the code

- `insert` builds the trie and stores in `out` the ids of the patterns that end at a node.
- `build` does Step A (depth-1 nodes, missing root edges go to the root) and Step B (BFS: compute $"fail"$ and complete the automaton).
- `search` moves in $O(1)$ per letter with the automaton, then walks the failure chain from the current node and adds one to `check[id]` for every pattern found. The root is marked in `vis` so the walk stops there.
- Because of that walk, the cost is the sum of the chain lengths, which can be large on repetitive input (see section 3).

#raw(read("code.cpp"), lang: "cpp", block: true)
