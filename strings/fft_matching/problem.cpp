void solve() {
    string s,t;cin>>s>>t;
    ll n=s.size();
    ll m=t.size();
    vector<DSU> st(n-m+1);
    for(int a=0;a<6;a++){
        for(int b=0;b<6;b++){
            if(a==b)continue;
            vector<ll> pos1,pos2;
            for(auto c : s){
                pos1.pb(c-'a'==a);
            }
            for(auto c : t){
                pos2.pb(c-'a'==b);
            }
            std::reverse(pos2.begin(), pos2.end());
            auto res= multiply(pos1,pos2);
            for(int l=m-1;l<n;l++){
                if(res[l]>0){
                    st[l-m+1].merge(a+1,b+1);
                }
            }
        }
    }
    for(int i=0;i<n-m+1;i++){
        cout<<6-st[i].count()<<" ";
    }
    cout<<endl;
 
}