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
struct seg {
    vector<node> nodes;
    int n;
    seg(int nn) {
        n = nn;
        nodes.reserve(3e6);
        create_node();
    }
    void merge(node &ans, const node &x, const node &y) {
        ans.val = x.val + y.val;
    }

    int create_node() {
        nodes.push_back({});
        return nodes.size() - 1;
    }
    void update(int pos, int val, int id, int ns, int ne) {
        if (ns == ne) {
            nodes[id].val += val;
            return;
        }
        int mid = ns + (ne - ns) / 2;
        if (pos <= mid) {
            if (!nodes[id].left) nodes[id].left = create_node();
            update(pos, val, nodes[id].left, ns, mid);
        }
        else {
            if (!nodes[id].right) nodes[id].right = create_node();
            update(pos, val, nodes[id].right, mid + 1, ne);
        }
        merge(nodes[id], nodes[nodes[id].left], nodes[nodes[id].right]);
    }
    void update(int pos, int val) {
        update(pos, val, 0, 1, n);
    }
    node qry(int l, int r, int id, int ns, int ne) {
        if (!id || l > ne || r < ns) return node();
        if (l <= ns && ne <= r) return nodes[id];
        int mid = ns + (ne - ns) / 2;
        node ans;
        merge(ans,
              qry(l, r, nodes[id].left, ns, mid),
              qry(l, r, nodes[id].right, mid + 1, ne));
        return ans;
    }
    int qry(int l, int r) {
        return qry(l, r, 0, 1, n).val;
    }
};