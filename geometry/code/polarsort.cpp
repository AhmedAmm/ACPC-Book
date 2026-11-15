// arg(p) in (0, pi] ?  (p != 0)
bool half(pt p) { return p.y > 0 || (p.y == 0 && p.x < 0); }
// by arg(p - o) in (-pi, pi], same direction: closer first; no point equal to o
void polarSort(vector<pt> &v, pt o = pt()) {
  sort(v.begin(), v.end(), [&](pt a, pt b) {
    a = a - o, b = b - o;
    return make_tuple(half(a), (T)0, sq(a)) <
           make_tuple(half(b), cross(a, b), sq(b));
  });
}
