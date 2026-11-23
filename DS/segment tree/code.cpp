struct node{
    int val;
    node(){val=INF;};
    node(int vall){val=vall;}
};

struct seg{
    int n;
    int tree_size;
    vector<node> sg;
    vector<node> a;
    seg(int nn,vector<node>& aa){
        n=nn;
        tree_size = 1;
        while (tree_size < n) tree_size <<= 1;
        sg.assign(2*tree_size,node());
        a=aa;
        build(0,1,tree_size);
    }
    node merge(node x,node y){
        if(x.val>y.val)swap(x,y);
        return x;
    }
    void build(int id,int ns,int ne){
        if(ns==ne){
            if(ns<a.size())sg[id]=a[ns];
            return;
        }
        ll lid=2*id+1,rid=2*id+2,md=ns+(ne-ns)/2;
        build(lid,ns,md);
        build(rid,md+1,ne);
        sg[id]=merge(sg[lid],sg[rid]);
    }
    void update(int p,node val,int id,int ns,int ne){
        if(ns==ne){
            sg[id]=val;
            return;
        }
        ll lid=2*id+1,rid=2*id+2,md=ns+(ne-ns)/2;
        if(p<=md)update(p,val,lid,ns,md);
        else update(p,val,rid,md+1,ne);
        sg[id]=merge(sg[lid],sg[rid]);
    }
    node qry(int l,int r,int id,int ns,int ne){
        if(l>ne || r<ns)return node();
        if(l<=ns && r>=ne)return sg[id];
        ll lid=2*id+1,rid=2*id+2,md=ns+(ne-ns)/2;
        return merge(qry(l,r,lid,ns,md),qry(l,r,rid,md+1,ne));
    }
    int first(int val,int id,int ns,int ne){
        if(sg[id].val<val)return 0; //condition
        if(ns==ne)return ns;
        ll lid=2*id+1,rid=2*id+2,md=ns+(ne-ns)/2;
        int idx=first(val,lid,ns,md);
        if(idx)return idx;
        idx=first(val,rid,md+1,ne);
        return idx;
    }
    int idx_range(int l,int r,int val,int id,int ns,int ne){
        if(sg[id].val<val || ns>r || l>ne)return 0; //condition
        if(ns==ne)return ns;
        ll lid=2*id+1,rid=2*id+2,md=ns+(ne-ns)/2;
        int idx=idx_range(l,r,val,lid,ns,md);
        if(idx)return idx;
        idx=idx_range(l,r,val,rid,md+1,ne);
        return idx;
    }
};