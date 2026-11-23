struct node {
    ll occ;
    int upd;
    int lazy;
    node() { occ = 0, upd = 0, lazy = 0; }
    node(int val) { upd = 0, lazy = 0, occ = val; }
    void update(int val, int ns, int ne) {
        upd = 1;
        lazy = val;
        occ = (ne - ns + 1)*lazy;
    }
};

struct seg {
    vector<node> sg;
    vector<ll> a;
    int n;

    node merge(node &x, node &y) {
        node res;
        res.occ=x.occ+y.occ;
        return res;
    }
    seg(){

    }
    seg(int nn, vector<ll> &ss) {
        a = ss;
        n = 1;
        while (n < nn)n <<= 1;
        sg.assign(2 * n, node());
        build(1, n, 0);
    }

    void build(int ns, int ne, int id) {
        if (ns == ne) {
            if (ns < a.size())sg[id] = node(a[ns]);
            return;
        }
        ll md = ns + (ne - ns) / 2;
        ll lid = 2 * id + 1, rid = 2 * id + 2;
        build(ns, md, lid);
        build(md + 1, ne, rid);
        sg[id] = merge(sg[lid], sg[rid]);
    }

    node qry(int l, int r, int ns, int ne, int id) {
        propagate(id, ns, ne);
        if (l > ne || r < ns)return node();
        if (ns >= l && ne <= r)return sg[id];
        ll md = ns + (ne - ns) / 2;
        auto aux1 = qry(l, r, ns, md, 2 * id + 1);
        auto aux2 = qry(l, r, md + 1, ne, 2 * id + 2);
        return merge(aux1, aux2);
    }

    void propagate(int id, int ns, int ne) {
        if (ns == ne || sg[id].upd == 0)return;
        ll lid = 2 * id + 1, rid = 2 * id + 2;
        sg[lid].update(sg[id].lazy, ns, ns + (ne - ns) / 2);
        sg[rid].update(sg[id].lazy, ns + (ne - ns) / 2 + 1, ne);
        sg[id].upd = 0;
        sg[id].lazy = 0;
    }

    void update(int l, int r, int val, int ns, int ne, int id) {
        propagate(id, ns, ne);
        if (l > ne || r < ns)return;
        if (ns >= l && ne <= r) {
            sg[id].update(val, ns, ne);
            propagate(id, ns, ne);
            return;
        }
        ll md = ns + (ne - ns) / 2;
        update(l, r, val, ns, md, 2 * id + 1);
        update(l, r, val, md + 1, ne, 2 * id + 2);
        ll lid = 2 * id + 1, rid = 2 * id + 2;
        sg[id] = merge(sg[lid], sg[rid]);
    }
};