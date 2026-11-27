mt19937 rng(chrono::steady_clock::now().time_since_epoch().count());
#define getrand(l, r) uniform_int_distribution<long long>(l, r)(rng)

struct TreapNode {
    int sz = 1;
    ll p = getrand(1, 1e18);

    ll sum = 0, lazy = 0, val;
    bool is_lazy = 0;
    bool rev = 0;

    TreapNode *l = NULL, *r = NULL, *par = NULL;

    TreapNode(int a): val(a), sum(a){}
};

using Treap = TreapNode*;

int size(Treap t) {
    return t ? t->sz : 0;
}

ll sum(Treap t) {
    return t ? t->sum : 0;
}

void apply_lazy(Treap t, ll val) {
    if(!t) return;
    t->val += val;
    t->sum += t->sz * val;
    t->lazy += val;
    t->is_lazy = 1;
}

void apply_rev(Treap t) {
    if(!t) return;
    swap(t->l, t->r);
    t->rev ^= 1;
}

void prop(Treap t) {
    if(!t) return;

    if(t->rev) {
        apply_rev(t->l);
        apply_rev(t->r);
        t->rev = 0;
    }
    if(t->is_lazy) {
        apply_lazy(t->l, t->lazy);
        apply_lazy(t->r, t->lazy);
        t->lazy = 0;
        t->is_lazy = 0;
    }
}

Treap recalc(Treap t) {
    prop(t->l), prop(t->r);
    t->sz = size(t->l) + 1 + size(t->r);
    t->sum = sum(t->l) + t->val + sum(t->r);
    return t;
}

Treap merge(Treap l, Treap r) {
    if(!l || !r) return r ? r : l;
    prop(l), prop(r);

    if(l->p < r->p) {
        Treap ri = merge(l->r, r);
        l->r = ri;
        if(ri != NULL) ri->par = l;
        return recalc(l);
    }

    Treap lf = merge(l, r->l);
    r->l = lf;
    if(lf != NULL) lf->par = r;

    return recalc(r);
}

array<Treap, 2> split(Treap t, int cnt) {
    if(!t) return {NULL, NULL};
    prop(t);

    if(size(t->l) >= cnt) {
        auto [left, right] = split(t->l, cnt);
        t->l = right;

        if(left != NULL) left->par = NULL;
        if(right != NULL) right->par = t;

        return {left, recalc(t)};
    }

    auto [left, right] = split(t->r, cnt - size(t->l) - 1);
    t->r = left;

    if(left != NULL) left->par = t;
    if(right != NULL) right->par = NULL;

    return {recalc(t), right};
}

Treap left_shift(Treap t, int l, int r) {
    auto [a, b] = split(t, r);
    auto [c, d] = split(a, r - 1);
    auto [e, f] = split(c, l-1);
    return merge(merge(e, d), merge(f, b));
}

Treap add_range(Treap t, int l, int r, int val) {
    auto [a, b] = split(t, r);
    auto [c, d] = split(a,  l - 1);

    apply_lazy(d, val);

    return merge(merge(c, d), b);
}

Treap get_range(Treap t, int l, int r) {
    auto [a, b] = split(t, r);
    auto [c, d] = split(a,  l - 1);

    cout << d->sum << '\n';

    return merge(merge(c, d), b);
}

Treap reverse_range(Treap t, int l, int r) {
    auto [a, b] = split(t, r);
    auto [c, d] = split(a,  l - 1);

    apply_rev(d);
    return merge(merge(c, d), b);
}

void print(Treap t) {
    if(!t) return;
    prop(t);
    print(t->l);
    cout << t->val << ' ';
    print(t->r);
}

int get_idx_of_value(Treap t) {
    if(!t) return 0;

    int idx = size(t->l) + 1;
    Treap curr = t;

    while (curr->par) {
        if(curr == curr->par->r)
            idx += size(curr->par->l) + 1;
        curr = curr->par;
    }

    return idx;
}

Treap get_val(Treap t, int idx) {
    auto [a, b] = split(t, idx);
    auto [c, d] = split(a, idx - 1);

    cout << d->val << ' ';

    return merge(merge(c, d), b);
}
int count_less(Treap t, ll x) {
    if (!t) return 0;
    prop(t);
    if (t->mx < x)
        return size(t);

    if (t->mn >= x)
        return 0;

    int ans = count_less(t->l, x);

    if (t->val < x)
        ans += 1;

    if (t->val < x)
        ans += count_less(t->r, x);

    return ans;
}