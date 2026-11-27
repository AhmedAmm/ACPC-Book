template<class T> struct Seg { // comb(ID,b) = b
    const T ID = 0;    ll n; vector<T> seg;
    T comb(T a, T b) { return max(a,b); }
    void init(ll _n) { n = _n; seg.assign(2*n,ID); }
    void pull(ll p) { seg[p] = comb(seg[2*p],seg[2*p+1]); }
    void upd(ll p, T val) { // set val at position p
        seg[p += n] = val; for (p /= 2; p; p /= 2) pull(p); }
    T query(ll l, ll r) {   // sum on llerval [l, r]
        T ra = ID, rb = ID;
        for (l += n, r += n+1; l < r; l /= 2, r /= 2) {
            if (l&1) ra = comb(ra,seg[l++]);
            if (r&1) rb = comb(seg[--r],rb);
        }return comb(ra,rb);
    }
};

struct node{
    int idx,x,y,dp;
};

void solve() {
    ll n;cin>>n;
    Seg<ll> s;
    s.init(N);
    vector<node> a(n);
    vector<ll> comp;
    for(int i=0;i<n;i++){
        cin>>a[i].x>>a[i].y;
        a[i].idx=i;
        a[i].dp=1;
        comp.pb(a[i].y);
    }
    std::sort(comp.begin(), comp.end());
    comp.erase(std::unique(comp.begin(), comp.end()),comp.end());
    for(int i=0;i<n;i++){
        a[i].y= std::lower_bound(comp.begin(), comp.end(),a[i].y)-comp.begin()+1;
    }
    function<void(int,int)> cdq=[&](int l,int r){
        if(l==r)return;
        ll mid=(l+r) >> 1;
        cdq(mid+1,r);
        vector<node*> la,ra;
        for(int i=l;i<=mid;i++){
            la.pb(&a[i]);
        }
        for(int i=mid+1;i<=r;i++){
            ra.pb(&a[i]);
        }
        std::sort(la.begin(), la.end(),[&](auto na,auto nb){return na->x>nb->x;});
        std::sort(ra.begin(), ra.end(),[&](auto na,auto nb){return na->x>nb->x;});
        ll i=0;
        for(auto p : la){
            while(i<ra.size() && ra[i]->x>p->x){
                s.upd(ra[i]->y,max(ra[i]->dp,s.query(ra[i]->y,ra[i]->y)));
                i++;
            }
            p->dp=max(p->dp,s.query(p->y+1,N-1)+1);
        }
        for(int k=0;k<i;k++){
            s.upd(ra[k]->y,0);
        }
        cdq(l,mid);
    };
    cdq(0,n-1);
    ll ans=0;
    for(int i=0;i<n;i++){
        ans=max(a[i].dp,ans);
    }
    cout<<ans<<endl;
}