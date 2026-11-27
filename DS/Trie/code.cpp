struct NodeTrie{
    NodeTrie* nxt[2]={NULL,NULL};
    int sub[2]={0,0};
};
using Trie = NodeTrie*;

void ins(int x, Trie tr){
    Trie curr = tr;
    for (int i = 30; i >= 0; i--){
        int cx = (x >> i) & 1;
        if (curr->nxt[cx] == NULL) curr->nxt[cx] = new NodeTrie;
        curr->sub[cx]++;
        curr = curr->nxt[cx];
    }
}
/*void dlt(int x,Trie tr){
    Trie curr = tr;
    tr->vals.erase(tr->vals.find(x));
    for (int i = 30; i >= 0; i--){
        int cx = (x >> i) & 1;
        if (curr->nxt[cx] == NULL) curr->nxt[cx] = new NodeTrie;
        curr->sub[cx]--;
        curr = curr->nxt[cx];
    }
}*/

int get_max(int x,Trie tr){
    int ret = 0;
    Trie curr = tr;
    for (int i = 30; i >= 0; i--){
        int cx = (x >> i) & 1;
        if (curr->sub[cx ^ 1] > 0){
            ret += (1 << i);
            curr = curr->nxt[(cx ^ 1)];
        }
        else curr = curr->nxt[cx];
    }
    return ret;
}

void clear(Trie tr){
    if(tr == NULL) return;

    clear(tr->nxt[0]);
    clear(tr->nxt[1]);

    delete(tr);
    tr = NULL;
}