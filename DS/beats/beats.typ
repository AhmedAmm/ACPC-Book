#set text(size: 10pt)
#set par(justify: true)

= Segment Tree Beats

== 1. What it is

*Idea:* a segment tree that supports range $"chmin"$ ($a_i arrow.l min(a_i, x)$) and range $"chmax"$ ($a_i arrow.l max(a_i, x)$) together with range add and the queries sum, max, min. A normal lazy tree cannot do it, because the new sum after a $"chmin"$ depends on which elements are bigger than $x$.

#table(
  columns: (auto, 1fr),
  [*Symbol*], [*Meaning*],
  [$"mx"$, $"se"$], [maximum of the node and its *strict second* maximum ($-infinity$ if none)],
  [$"mn"$, $"sm"$], [minimum of the node and its *strict second* minimum ($+infinity$ if none)],
  [$"cmx"$, $"cmn"$], [how many elements are equal to $"mx"$ and to $"mn"$],
  [$"sum"$, $"len"$], [sum of the node and its length],
  [tag], [a function $x arrow.r min("hi", max("lo", x + a))$: "add $a$, then clamp to $["lo", "hi"]$"],
)

*Key step* ($"chmin"(x)$ on a node that is fully inside the range):
- if $"mx" <= x$: nothing changes, stop.
- if $"se" < x < "mx"$: only the elements equal to $"mx"$ change, all of them become $x$. Update in $O(1)$: $"sum" arrow.l "sum" - ("mx" - x) dot "cmx"$, $"mx" arrow.l x$, and put a lazy tag on the node.
- if $x <= "se"$: more than one distinct value would change, so go down to the children.

$"chmax"(x)$ is the same with $"mn"$, $"sm"$, $"cmn"$ ($x <= "mn"$ stop; $"mn" < x < "sm"$ tag; else go down). Add is a normal tag.

*Why it is fast:* going down merges the two biggest distinct values of a node into one, so the number of distinct values in the tree only drops. With range add the total cost is $O((n + q) log^2 n)$ amortized (without add it is $O((n + q) log n)$).

*Safe tags:* a tag is only applied when it changes nothing except the max group and the min group, and add shifts everything equally. So the second values and the sum can be updated without looking at the children, and a tag can be pushed down by the same rule.

== 2. Trick: gcd

*Problem:* the same operations, and the query "gcd of $a_l, dots, a_r$". The gcd of a node cannot be stored directly, because $"chmin"$ and add change the values.

*Idea:* the gcd of a set equals the gcd of one element and of the differences to it, and differences do not change under add.

$ gcd(a_1, dots, a_k) = gcd(a_1, a_2 - a_1, dots, a_k - a_1) $

Split the elements of a node into the max group, the min group and the *middle* ones (neither). Tags only change the max group and the min group, so keep one extra value that no tag can touch:

$ "gd" = gcd_(i " middle") |a_i - "se"| quad (0 " if there are no middle elements") $

*Gcd of a node:* $gcd("mx", "mn", "se", "gd")$. If $"se" = "mn"$ there are no middle elements and only $"mx"$ and $"mn"$ count. If the node has one distinct value the gcd is $|"mx"|$.

*Only the merge has to be written:* in `pull`, the middle elements of the parent are all the elements that are neither $"mx"$ nor $"mn"$ of the parent, and the reference is the parent's $"se"$. For each child add three kinds of terms to the gcd:
- the child's own middle elements: $gcd("gd"_c, |"se"_c - "se"|)$ (only if the child has middle elements),
- the child's max group: $|"mx"_c - "se"|$, if $"mx"_c$ is not the parent's $"mx"$ or $"mn"$,
- the child's min group: $|"mn"_c - "se"|$, if $"mn"_c$ is not the parent's $"mx"$ or $"mn"$.

The query is the gcd of the node gcds. The cost grows by a factor $log V$ for the gcd, where $V$ is the size of the values.

== 3. Code

`code.cpp` is the tree with chmin, chmax, add and the queries sum, max, min. The struct keeps the lazy tag as the function of section 1, so a new operation is a new tag (one line in `chmin`, `chmax` or `add`).

#raw(read("code.cpp"), lang: "cpp", block: true)

`code1.cpp` is the simple segment tree beats.

#raw(read("code1.cpp"), lang: "cpp", block: true)
