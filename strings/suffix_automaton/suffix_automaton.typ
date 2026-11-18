#set text(size: 10pt)
#set par(justify: true)
#let md = "mod"

= Suffix Automaton

== 1. What it is

*Idea:* the smallest automaton that accepts all the suffixes of the string. Every substring is a path that starts at the root, and two substrings share a state exactly when they end at the same set of positions in the text.

#table(
  columns: (auto, 1fr),
  [*Symbol*], [*Meaning*],
  [$n$], [length of the string],
  [$"len"(v)$], [`t[v].len`: length of the longest string of state $v$],
  [$"link"(v)$], [`t[v].link`: suffix link, the state of the longest suffix of that string that has a different end set (root has link $-1$)],
  [$"nxt"(v, c)$], [`t[v].nxt[c]`: transition by the letter $c$],
  [$"cnt"(v)$], [number of occurrences in the text of every string of $v$],
  [$"firstpos"(v)$], [end position (1-indexed) of the first occurrence of the strings of $v$],
)

*Key fact:* the state $v$ holds all the strings that are suffixes of its longest string and have a length from $"len"("link"(v)) + 1$ to $"len"(v)$.

Example for `abab`:

#table(
  columns: (auto, auto, auto, 1fr, auto, auto),
  [*state*], [*len*], [*link*], [*strings*], [*cnt*], [*firstpos*],
  [0], [0], [$-1$], [empty string (root)], [], [0],
  [1], [1], [0], [`a`], [2], [1],
  [2], [2], [0], [`ab`, `b`], [2], [2],
  [3], [3], [1], [`aba`, `ba`], [1], [3],
  [4], [4], [2], [`abab`, `bab`], [1], [4],
)

Transitions: $0 arrow.r^a 1$, $0 arrow.r^b 2$, $1 arrow.r^b 2$, $2 arrow.r^a 3$, $3 arrow.r^b 4$.

- At most $2n - 1$ states and $3n - 4$ transitions.
- Distinct substrings: $sum_(v >= 1) ("len"(v) - "len"("link"(v))) = 1 + 2 + 2 + 2 = 7$ here.

== 2. How to put the string

- Create it with the length of the string, then build:

`SuffixAutomaton sa(n); sa.build(s);`

- The arrays have $2n$ entries, so $n$ must be at least the number of letters you will add.
- No sentinel is needed, and the alphabet is anything that fits a `char` (the transitions are a `map`).
- It is *online*: `extend(c)` adds one letter at a time. If you call it yourself, also set `terminal[last] = 1` after each letter and call `build_tree()` before using `cnt`, `kth`, or `calc`.
- `search(t)` returns $-1$ if $t$ does not occur, otherwise `firstpos`, which is the *end* of the first occurrence. The start index is `firstpos` $- |t|$.
- *Many strings:* put them in one `vector<int>` and put a different separator (a value $>= 1000$) before each string, so the first element is a separator. In this version `extend` takes an `int` and `nxt` is `map<int, int>` (a `char` has only 256 values and separators could collide with letters). The automaton needs the total length plus the number of separators, and the members `pref` (one vector of states per string) and `ans` (one value per string).

== 3. Link tree and occurrences

*Extend rule* (adding the letter $c$, `cur` is the new state with $"len"(" cur") = "len"(" last") + 1$):
- Walk $p$ from `last` along the links and add the transition $"nxt"(p, c) = " cur"$ until a state already has a transition by $c$ (or $p = -1$, then $"link"(" cur") = 0$).
- Let $q = "nxt"(p, c)$. If $"len"(p) + 1 = "len"(q)$ then $"link"(" cur") = q$.
- Otherwise copy $q$ into a *clone* with $"len"(" clone") = "len"(p) + 1$, redirect the transitions of $p$ and of its links from $q$ to the clone, and set $"link"(q) = "link"(" cur") = " clone"$.

*Link tree:* make $"link"(v)$ the parent of $v$ (root 0). The strings of a state are suffixes of the strings of its descendants.

*Occurrences:* mark `terminal` on the state created by each letter (each prefix of the text). A string occurs once for every prefix state in the subtree of its state:

$ "cnt"(v) = "terminal"(v) + sum_("link"(u) = v) "cnt"(u) $

*All substrings with repeats* (each distinct substring counted `cnt` times), with $x = "nxt"(v, c)$:

$ "ways"(v) = sum_c ("cnt"(x) + "ways"(x)) $

*$k$-th substring in lexicographic order* (the repeats count, this is `kth`): stand at $v$ and look at the letters in order. For $x = "nxt"(v, c)$ the group of the letter $c$ has size $"cnt"(x) + "ways"(x)$.
- If $k$ is bigger than the group, subtract it and try the next letter.
- Otherwise take $c$. If $k <= "cnt"(x)$ the answer is the string built so far, else subtract $"cnt"(x)$ and continue from $x$.

*Distinct version:* replace $"cnt"(x)$ by 1 in the two formulas above.

== 4. Problems it solves

#table(
  columns: (1fr, 2fr),
  [*Problem*], [*Idea*],
  [Does $t$ occur, where is the first occurrence], [walk $t$ from the root; if a transition is missing the answer is no; the start is `firstpos` $- |t|$ (this is `search`)],
  [Number of occurrences of $t$], [walk $t$ to the state $v$; the answer is $"cnt"(v)$],
  [Number of distinct substrings], [$sum_(v >= 1) ("len"(v) - "len"("link"(v)))$ (this is `count`)],
  [Distinct substrings of a growing string], [after each `extend`, the number grows by $"len"(" cur") - "len"("link"(" cur"))$],
  [$k$-th substring, with repeats], [group sizes $"cnt"(x) + "ways"(x)$, section 3 (this is `kth`)],
  [$k$-th distinct substring], [the same walk with $"cnt"$ replaced by 1],
  [Longest repeated substring], [$max "len"(v)$ over the states with $"cnt"(v) >= 2$],
  [Longest common substring of two strings], [build the automaton of $s$, run $t$ through it keeping the state and the current length $l$; when the transition is missing follow the links ($l = "len"(" link")$) until it exists, then $l$ grows by 1; the answer is the maximum $l$],
  [Smallest cyclic rotation], [build the automaton of $s + s$ and walk the smallest transition $n$ times from the root],
  [For each string, how many of its substrings occur in at least $k$ of $m$ strings], [the many-strings code: for each string mark the states on the link chains of its prefix states (stop at a state already marked by this string), so $"cnt"[u]$ is the number of strings containing $u$; $f[v] = "len"(v)$ if $"cnt"[v] >= k$, else $f["link"(v)]$ (the counts only drop going down the tree); the answer of a string is the sum of $f$ over its prefix states; the special case $k = 1$ is $L(L+1)/2$]
)

*Note on the last problem:* the sum over the prefix states counts the substrings by position, as pairs $(l, r)$, so a substring that occurs twice in the same string is counted twice. The case $k = 1$ is special because the states that contain a separator have $"cnt" = 1$ and would be counted.

== 5. Complexity

- Build: $O(n log Sigma)$ with the `map`, $O(n)$ with arrays of size $Sigma$ (then $O(n Sigma)$ memory).
- `cnt`, `calc`: $O("states" + "transitions") = O(n)$.
- `kth`: $O(|"answer"| dot Sigma)$ after `cnt` and `calc`.
- `search`: $O(|t| log Sigma)$.
- Many strings: $O("total length")$ for the marking, plus $O(n log n)$ for sorting the states by `len`.

== 6. About the code

- `node` holds `len`, `link`, `firstpos` and the transitions `nxt`.
- The constructor takes $n$ and allocates $2n$ states for the nodes and for the arrays `terminal`, `dp`, `ways`, `g`.
- `extend` is the rule of section 3. `build_tree` fills `g` with the children of the link tree. `build` extends the whole string and sets `terminal[last] = 1` after each letter.
- `cnt(i)` returns the number of occurrences of state $i$ (stored in `dp`). `calc(v)` returns $"ways"(v)$.
- `kth(k)` is the walk of section 3. It needs $1 <= k <=$ the number of substrings counted with repeats.
- `count()` is the number of distinct substrings, `search(t)` is the first occurrence.
- The last block of the code is the many-strings version (`build` on a `vector<int>`, and `calc(m, k)`).


#raw(read("code.cpp"), lang: "cpp", block: true)
