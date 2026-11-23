vector<vector<ll>> s(n+1,vector<ll>(20,INF));
    for(int i=1;i<=n;i++)s[i][0]=a[i];
    for(int l=1;l<20;l++){
        for(int i=1;i<=n;i++){
            ll nw_i=i-(1<<(l-1));
            if(nw_i<=0)continue;
            s[nw_i][l]=min(s[nw_i][l-1],s[i][l-1]);
        }
    }
    while(q--){
        ll l,r;cin>>l>>r;
        ll lg=log2(r-l+1);
        //cout<<lg<<" ";
        cout<<min(s[l][lg],s[r-(1<<lg)+1][lg])<<endl;
    }