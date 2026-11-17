ll inv(ll Nn) {if (Nn == 1) return 1; return (mod - ((mod / Nn) * inv(mod % Nn)) % mod) % mod;}

int add(ll a, ll b){return (a % mod + b % mod) % mod;}
 
int sub(ll a, ll b){return (a % mod - b % mod + mod) % mod;}
 
int mult(ll a, ll b){return (a % mod) * (b % mod) % mod;}
  
int po[2][N_Max], inverse[2][N_Max];
array<int, 2> base = {9973, 37};
 
void prep(){
    for (int i = 0; i < 2; i++) po[i][0] = inverse[i][0] = 1;
    for (int j = 0; j < 2; j++){
        for (int i = 1; i < N_Max; i++){
            po[j][i] = mult(po[j][i - 1], base[j]);
        }
        inverse[j][N_Max-1] = inv(po[j][N_Max-1]);
        for (int i = N_Max-2; i >= 0; i--){
            inverse[j][i] = mult(inverse[j][i + 1], base[j]);
        }
    }
}
 
struct Hash{
    int N;
    vector<int> pref[2], suff[2];
 
    void run_hash(string &s){
        N = (int)s.size() - 1;
        for (int i = 0; i < 2; i++){
            pref[i].clear();
            pref[i].resize(N + 5);
            suff[i].clear();
            suff[i].resize(N + 5);
        }
        for (int i = 1; i <= N; i++)
            for (int j = 0; j < 2; j++)
                pref[j][i] = add(pref[j][i - 1], mult(s[i], po[j][i]));
        for (int i = N; i >= 1; i--)
            for (int j = 0; j < 2; j++)
                suff[j][i] = add(suff[j][i + 1], mult(s[i], po[j][N - i + 1]));
    }
 
    array<int, 2> get_hash_prefix(int l, int r){
        array<int, 2> ret;
        for (int i = 0; i < 2; i++)
            ret[i] = mult(sub(pref[i][r], pref[i][l - 1]), inverse[i][l]);
        return ret;
    }
 
    array<int, 2> get_hash_suffix(int l, int r){
        array<int, 2> ret;
        for (int i = 0; i < 2; i++)
            ret[i] = mult(sub(suff[i][l], suff[i][r + 1]), inverse[i][N - r + 1]);
        return ret;
    }
};