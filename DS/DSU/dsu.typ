#set text(size: 10pt)
#set par(justify: true)

= DSU

== 1. DSU

*Idea:* every set is a tree and `find` returns its root. `merge` hangs the root of one tree under the root of the other. With path compression and union by rank, an operation costs $O(alpha(n))$.

- `c` is the number of components, `sz[find(i)]` is the size of the set of $i$.
- `merge` returns the new root, or $-1$ if the two elements were already in the same set.

#raw(read("code.cpp"), lang: "cpp", block: true)

== 2. DSU with rollback

*Idea:* undo the last unions. Path compression changes many cells and cannot be undone cheaply, so here there is *no compression* and we use union by size: `get` costs $O(log n)$.

- Every change is saved in `history` as a pair (reference to the cell, old value). A `unite` saves two cells: `sz[a]` and `p[b]`.
- `snapshot()` returns the size of `history` and the number of components.
- `rollback(until, cc)` restores the cells while `history` is longer than `until`, and sets the number of components back to `cc`.

#raw(read("code1.cpp"), lang: "cpp", block: true)

== 3. Augmented DSU (potentials)

*Idea:* every node keeps $"pot"(x) = "value"(x) - "value"("parent"(x))$. After `find(x)` the path is compressed, so $"pot"(x)$ is relative to the root. It handles equations $"value"(a) - "value"(b) = d$:

- `merge(a, b, d)`: if $a$ and $b$ have the same root, the equation is true when $"pot"(a) - "pot"(b) = d$, else it is a contradiction (`flaw++`). Otherwise attach $r_a$ under $r_b$ with
$ "pot"(r_a) = d - "pot"(a) + "pot"(b) $
- `difference(a, b)` is $"pot"(a) - "pot"(b)$ if they are connected.
- `construct` gives one valid assignment: every root gets 0 and $"value"(i) = "value"("parent"(i)) + "pot"(i)$ (a whole component can be shifted by any constant).

*XOR version:* the same code, with $+$ and $-$ replaced by $xor$ (the potential is $"value"(x) xor "value"("parent"(x))$).

#raw(read("code2.cpp"), lang: "cpp", block: true)

== 4. Augmented DSU with rollback

*Idea:* the same potentials, but with no path compression. `find` only walks up to the root and sums the potentials on the way, so it does not modify anything. Union by size keeps the depth at $O(log n)$.

- Every `merge` pushes exactly *one* record, so `save()` is the number of merges done so far and `rollback(k)` undoes the merges down to $k$.
- The record `{ra, rb, old_pot, old_sz}` is an attach: undo it by making $r_a$ a root again and restoring its potential and the size of $r_b$.
- The record `{-1, ...}` is a contradiction (undo: `flaw--`), and `{-2, ...}` is a consistent equation between two connected elements (nothing to undo).
- If the smaller tree is the one of $a$, we swap the roots and negate $d$ (the XOR version does not negate).

#raw(read("code3.cpp"), lang: "cpp", block: true)