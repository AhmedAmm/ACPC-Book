class DSU {
  private:
	vector<int> p, sz;
	// stores previous unites
	vector<pair<int &, int>> history;
    ll c;

  public:
	DSU(int n) : p(n+1), sz(n+1, 1) { iota(p.begin(), p.end(), 0),c=n; }

	int get(int x) { return x == p[x] ? x : get(p[x]); }

	void unite(int a, int b) {
		a = get(a);
		b = get(b);
		if (a == b) { return; }
        c--;
		if (sz[a] < sz[b]) { swap(a, b); }

		// save this unite operation
		history.push_back({sz[a], sz[a]});
		history.push_back({p[b], p[b]});

		p[b] = a;
		sz[a] += sz[b];
	}

	pair<ll,ll> snapshot() { return {history.size(),c}; }
    int count(){
        return c;
    }
	void rollback(int until,int cc) {
        c=cc;
		while (snapshot().first > until) {
			history.back().first = history.back().second;
			history.pop_back();
		}
	}
};