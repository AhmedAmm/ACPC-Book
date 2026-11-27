struct DSU{
  vector<int> par, rnk, sz,rep;
  int c;
  DSU(int n) : par(n + 1), rnk(n + 1, 0), sz(n + 1, 1), c(n),rep(n+1) {
    for (int i = 1; i <= n; ++i) par[i] = i,rep[i]=i;
  }
  int find(int i) {
    return (par[i] == i ? i : (par[i] = find(par[i])));
  }
  bool same(int i, int j) {
    return find(i) == find(j);
  }
  int get_size(int i) {
    return sz[find(i)];
  }
  int count() {
    return c;    //connected components
  }
  int id(int i){
      return rep[find(i)];
  }
  int merge(int i, int j,int id) {
    if ((i = find(i)) == (j = find(j))) return -1;
    else --c;
    if (rnk[i] > rnk[j]) swap(i, j);
    par[i] = j;
    sz[j] += sz[i];
    if (rnk[i] == rnk[j]) rnk[j]++;
    rep[j]=id;
    return j;
  }
};
 
 
void solve() {
    ll n,m;cin>>n>>m;
    DSU d(n);
    ll s=2*n;
    ll lg=__lg(n)+1;
    ll ans=0;
    vector<vector<ll>> g(s+1);
    vector<ll> val(s+1,INF);
    vector<ll> occ(n+1,0);
    vector<ll> odd(s+1,0);
    int id=n;
    for(int i=0;i<m;i++){
        ll u,v;cin>>u>>v;
        occ[u]++;
        occ[v]++;
        ll w;cin>>w;
        ans+=w;
        if(d.same(u,v)){
            val[d.id(u)]=min(val[d.id(u)],w);
            continue;
        }
        ll u_id=d.id(u);
        ll v_id=d.id(v);
        d.merge(u,v,++id);
        val[id]=w;
        g[id].pb(u_id);
        g[id].pb(v_id);
    }
    for(int i=1;i<=n;i++){
        if(occ[i]%2)odd[i]++;
    }
 
    function<void(int)> dfs=[&](int v){
        for(auto child : g[v]){
            val[child]=min(val[child],val[v]);
            dfs(child);
            odd[v]+=odd[child];
        }
        ans+=val[v]*(odd[v]/2);
        odd[v]%=2;
    };
    dfs(id);
    cout<<ans<<endl;
}