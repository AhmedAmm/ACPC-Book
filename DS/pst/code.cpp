struct node {
    int val, left, right;

    node() {
        val = 0;
        left = 0;
        right = 0;
    }

    node(int v) {
        val = v;
        left = 0;
        right = 0;
    }
};

struct pst {
    vector<node> nodes;
    int n;

    pst(int nn) {
        n = nn;
        nodes.reserve(3e6);
        create_node();
    }

    void merge(node &ans, const node &x, const node &y) {
        ans.val = x.val + y.val;
    }

    int create_node() {
        nodes.pb({});
        return nodes.size() - 1;
    }

    int set(int pos, int val, int nid, int ns, int ne) {
        int id = create_node();
        nodes[id] = nodes[nid];
        if (ns == ne) {
            nodes[id].val += val;
            return id;
        }
        int md = ns + (ne - ns) / 2;
        if (md >= pos) nodes[id].left = set(pos, val, nodes[nid].left, ns, md);
        else nodes[id].right = set(pos, val, nodes[nid].right, md + 1, ne);
        merge(nodes[id], nodes[nodes[id].left], nodes[nodes[id].right]);
        return id;
    }

    node get(int l, int r, int nid, int ns, int ne) {
        if (nid == 0)return nodes[nid];
        if (l <= ns && ne <= r)return nodes[nid];
        if (ne < l || r < ns)return nodes[0];
        int md = ns + (ne - ns) / 2;
        node ans;
        merge(ans, get(l, r, nodes[nid].left, ns, md), get(l, r, nodes[nid].right, md + 1, ne));
        return ans;
    }
    

    int kth(int k, int sum, int nl, int nr, int ns, int ne) {
        int occ = nodes[nr].val - nodes[nl].val;
        if (sum + occ < k)return -1;
        if (sum + occ >= k && ns == ne)return ns;
        int mid = ns + (ne - ns) / 2;
        auto ans1 = kth(k, sum, nodes[nl].left, nodes[nr].left, ns, mid);
        if (ans1 != -1)return ans1;
        occ = nodes[nodes[nr].left].val - nodes[nodes[nl].left].val;
        sum += occ;
        return kth(k, sum, nodes[nl].right, nodes[nr].right, mid + 1, ne);
    }
};