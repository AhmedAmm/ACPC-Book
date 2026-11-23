struct node{
    int val;
    int mx;
    node(){val=0,mx=0;}
    node(int vall){val=vall,mx=vall;}
};
struct seg{
    vector<node> sg;
    vector<node> a;
    int tree_size=1;
    node merge(node x,node y){
        x.val+=y.val;
        x.mx=max(x.mx,y.mx);
        return x;
    }
    void build(int ns,int ne,int id){
        if(ns==ne){
            if(ns<a.size())sg[id]=a[ns];
            return;
        }
        ll md=ns+(ne-ns)/2;
        build(ns,md,2*id+1);
        build(md+1,ne,2*id+2);
        sg[id]=merge(sg[2*id+1],sg[2*id+2]);
    }
    void upd(int l,int r,int val,int ns,int ne,int id){
        if(ne<l || ns>r || sg[id].mx<val)return;
        if(ns==ne){
            sg[id].val=sieve[sg[id].val];
            sg[id].mx=sg[id].val;
            return;
        }
        ll md=ns+(ne-ns)/2;
        ll lid=2*id+1,rid=2*id+2;
        upd(l,r,val,ns,md,lid);
        upd(l,r,val,md+1,ne,rid);
        sg[id]=merge(sg[2*id+1],sg[2*id+2]);
    }
    node qry(int l,int r,int ns,int ne,int id){
        if(ne<l || ns>r)return node();
        if(ns>=l && ne<=r)return sg[id];
        ll md=ns+(ne-ns)/2;
        ll lid=2*id+1,rid=2*id+2;
        return merge(qry(l,r,ns,md,lid),qry(l,r,md+1,ne,rid));
    }
    void set(int pos,int val,int ns,int ne,int id){
        if(ne<pos || ns>pos)return;
        if(ns==ne){
            sg[id]=node(val);
            return;
        }
        ll md=ns+(ne-ns)/2;
        if(pos<=md){
            set(pos,val,ns,md,2*id+1);
        }
        else{
            set(pos,val,md+1,ne,2*id+2);
        }
        sg[id]=merge(sg[2*id+1],sg[2*id+2]);
    }
    seg(int n,vector<node>& aa){
        while(tree_size<n)tree_size <<=1;
        sg.assign(2*tree_size,node());
        a=aa;
        build(1,tree_size,0);
    }
};