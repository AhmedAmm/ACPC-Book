#set text(size: 10pt)
#set par(justify: true)

= Partially Persistent DSU

*Idea.* Each node keeps a history of its parent/size as a list of `(value, time)` pairs. A negative value means the node is a root and stores minus the component size; a non-negative value is the parent. Only the latest version can be modified, but any past version can be queried.

*How it works.*
- `merge(u, v)` increments the global time, finds both roots, and attaches the smaller component to the larger one (union by size). It appends a new size entry to the new root `u` and a new parent entry to `v`, both stamped with the current time.
- `root(u, t)` climbs parent links, ignoring any link created after time `t`. There is no path compression, since it would destroy history, so the depth stays $O(log n)$ thanks to union by size.
- `size(u, t)` finds the root at time `t`, then binary searches its history for the last entry with time $<= t$.
- `same(u, v, t)` checks whether both roots are equal at time `t`.

*Complexity.* Merge and query take $O(log n)$ each, and `size` takes $O(log n)$ plus the binary search. In the driver, the first time two nodes become connected is found by binary searching over time, giving $O(log^2 n)$ per query.

#raw(read("code.cpp"), lang: "cpp", block: true)

= Persistent DSU

*Idea.* Fully persistent DSU: any version can be queried and any version can be used as the base for a new merge, forming a version tree. The `par` and `sz` arrays are stored in a persistent segment tree (`PersistentArray`). Each update copies only the $O(log n)$ nodes on the path to the changed leaf, and the rest is shared between versions.

*How it works.*
- `PersistentArray` supports `get_val(r, i)` for reading index `i` of version `r`, `upd` which creates a new version with one index changed, and `set` which overwrites a version in place (used for path compression).
- `find(r, u)` follows parents in version `r` and compresses the path with `set`, which rewrites the version in place without creating a new one. This is safe because compression does not change the represented sets.
- `merge(r, u, v)` creates a new version `cur` from version `r`. If `u` and `v` are already connected, it just copies the version (a dummy update keeps the version indices aligned). Otherwise it links one root under the other, with the direction chosen randomly, and updates the size of the new root. The component count `c` is tracked per version.
- Randomized linking replaces union by size, which keeps expected tree depth logarithmic, so `find` stays fast.

*Complexity.* Each operation takes about $O(log^2 n)$ expected time and each update uses $O(log n)$ extra memory.

#raw(read("code1.cpp"), lang: "cpp", block: true)