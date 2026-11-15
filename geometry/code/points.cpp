typedef long long T; // or: typedef long double T;
const ld PI = acosl(-1), EPS = 1e-9;

struct pt {
  T x, y;
  pt() : x(0), y(0) {}
  pt(T x, T y) : x(x), y(y) {}
  pt operator+(pt p) const { return {x + p.x, y + p.y}; }
  pt operator-(pt p) const { return {x - p.x, y - p.y}; }
  pt operator*(T d) const { return {x * d, y * d}; }
  pt operator/(T d) const { return {x / d, y / d}; } // ld only
  bool operator==(pt p) const { return x == p.x && y == p.y; }
  bool operator<(pt p) const { return tie(x, y) < tie(p.x, p.y); } // sort / set
};

template <class U> int sgn(U x) { return (U(0) < x) - (x < U(0)); }
T sq(pt p) { return p.x * p.x + p.y * p.y; } // |p|^2, exact
ld abs(pt p) { return sqrtl(sq(p)); }
pt perp(pt p) { return {-p.y, p.x}; } // rotate +90 (ccw)
T dot(pt v, pt w) { return v.x * w.x + v.y * w.y; }
T cross(pt v, pt w) { return v.x * w.y - v.y * w.x; }
// > 0: C left of AB (ccw turn), < 0: right (cw), 0: collinear
T orient(pt a, pt b, pt c) { return cross(b - a, c - a); }
