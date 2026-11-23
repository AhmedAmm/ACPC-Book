struct seg{
    vector<vector<ll>> sg;
    vector<vector<ll>> pref;
    int tree_size=1;
    vector<ll> a;
    vector<ll> merge (vector<ll> x,vector<ll> y){
        vector<ll> aux(x.size()+y.size());
        ll i=0,j=0,k=0;
        while(i<x.size() && j<y.size()){
            if(x[i]<=y[j]){
                aux[k++]=x[i++];
            }
            else{
                aux[k++]=y[j++];
            }
        }
        while(i<x.size()){
            aux[k++]=x[i++];
        }
        while(j<y.size()){
            aux[k++]=y[j++];
        }
        return aux;
    }
    void build(int ns,int ne,int id){
        if(ns==ne){
            if(ns<a.size())sg[id].pb(a[ns]),pref[id].pb(a[ns]);
            return;
        }
        ll md=ns+(ne-ns)/2;
        ll lid=2*id+1,rid=2*id+2;
        build(ns,md,lid);
        build(md+1,ne,rid);
        sg[id]=merge(sg[lid],sg[rid]);
        if(sg[id].empty())return;
        pref[id].resize(sg[id].size());
        pref[id][0]=sg[id][0];
        for(int i=1;i<sg[id].size();i++){
            pref[id][i]+=pref[id][i-1]+sg[id][i];
        }
    }
    pair<ll,ll> mrg(pair<ll,ll> x,pair<ll,ll> y){
        x.first+=y.first;
        x.second+=y.second;
        return x;
    }
    pair<ll,ll> qry(int l,int r,int val,int ns,int ne,int id){
        if(ne<l || ns>r || l>r || sg[id].empty())return {0,0};
        if(ns>=l && ne<=r){
            ll pos= std::upper_bound(sg[id].begin(), sg[id].end(),val)-sg[id].begin();
            if(pos<=0)return {0,0};
            return {pref[id][pos-1],pos};
        }
        ll md=ns+(ne-ns)/2;
        ll lid=2*id+1,rid=2*id+2;
        return mrg(qry(l,r,val,ns,md,lid),qry(l,r,val,md+1,ne,rid));
    }
    seg(int n,vector<ll>& aa){
        while(tree_size<n)tree_size<<=1;
        sg.assign(2*tree_size,{});
        pref.assign(2*tree_size,{});
        a=aa;
        build(1,tree_size,0);
    }
};