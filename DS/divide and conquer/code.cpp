struct point {
    int x, y, z, i;
};
Seg<ll> s;

void solve() {
    ll n;cin >> n;
    vector<point> a(n);
    for (int i = 0; i < n; i++) {
        cin >> a[i].x >> a[i].y >> a[i].z;
        a[i].i = i;
    }
    sort(a.begin(), a.end(), [&](auto a, auto b) {if (a.x != b.x) return a.x > b.x;if (a.y != b.y) return a.y < b.y;return a.z < b.z;});
    s.init(N);
    vector<ll> ans(n,0);

    function<void(int,int,int,int)> work=[&](int l1,int r1,int l2,int r2){
        vector<point> la,ra;
        for(int i=l1;i<=r1;i++){
            la.pb(a[i]);
        }
        for(int i=l2;i<=r2;i++){
            ra.pb(a[i]);
        }
        sort(la.begin(), la.end(), [&](auto a, auto b) {if (a.y != b.y) return a.y > b.y;return a.z < b.z;});
        sort(ra.begin(), ra.end(), [&](auto a, auto b) {if (a.y != b.y) return a.y > b.y;return a.z < b.z;});
        ll pl=0;
        for(auto p:ra){
            while(pl<la.size() && la[pl].y>p.y){
                s.upd(la[pl].z,1);
                pl++;
            }
            ans[p.i]+=s.query(p.z+1,N-1);
        }
        for(int i=0;i<pl;i++){
            s.upd(la[i].z,-1);
        }
    };

    function<void(int,int)> cdq =[&](int l,int r){
        if(l==r)return;
        int mid=(l+r)/2;
        cdq(l,mid);
        cdq(mid+1,r);
        if(a[mid].x==a[mid+1].x){
            ll lf=mid,rg=mid+1;
            while(rg<=r && a[mid].x==a[rg].x){
                rg++;
            }
            rg--;
            while(lf>=l && a[mid].x==a[lf].x){
                lf--;
            }
            lf++;
            if(rg<r)work(lf,mid,rg+1,r);
            if(l<lf)work(l,lf-1,mid+1,r);
        }
        else{
            work(l,mid,mid+1,r);
        }
    };
    cdq(0,n-1);
    for(int i=0;i<n;i++){
        cout<<ans[i]<<endl;
    }
}