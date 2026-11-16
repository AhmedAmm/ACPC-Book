auto kmp= prefix_function(ch);
vector<vector<ll>> next(ch.size()+1,vector<ll>(26,0));
for(int i=0;i<=ch.size();i++){
    for(int c=0;c<26;c++){
        if(i<ch.size() && (ch[i]-'a')==c){
            next[i][c]=i+1;
        }
        else{
            if(i==0){
                next[i][c]=0;
            }
            else{
                next[i][c]=next[kmp[i-1]][c];
            }
        }
    }
}