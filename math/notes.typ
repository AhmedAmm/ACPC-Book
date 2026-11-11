=== Number of divisors

For a positive integer $n$ with prime factorization

$ n = p_1^(a_1) dots.c p_k^(a_k) $

the number of positive divisors of $n$ (often denoted $tau(n)$ or $d(n)$) is

$ tau(n) = product_(i=1)^k (a_i + 1). $

Notes:

- To compute $tau(n)$, factorize $n$ into primes and multiply $(exp + 1)$ for each prime.
- For competitive programming, factorization up to $sqrt(n)$ is usually enough for one number; use sieve-based factorization for many queries.
