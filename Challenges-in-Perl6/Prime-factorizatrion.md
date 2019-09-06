# Prime Factorization

This is derived from my [blog post](http://blogs.perl.org/users/laurent_r/2019/08/perl-weekly-challenge-23-difference-series-and-prime-factorization.html) made in answer to the [Week 23 of the Perl Weekly Challenge](https://perlweeklychallenge.org/blog/perl-weekly-challenge-023/) organized by  <a href="http://blogs.perl.org/users/mohammad_s_anwar/">Mohammad S. Anwar</a> as well as answers made by others to the same challenge.

The challenge reads as follows:

_Create a script that prints **Prime Decomposition** of a given number. The prime decomposition of a number is defined as a list of prime numbers which when all multiplied together, are equal to that number. For example, the Prime decomposition of 228 is 2,2,3,19 as 228 = 2 * 2 * 3 * 19._

## My Solution

The simplest way to solve this challenge is called trial division, i.e. to divide the input number by successive integers until the result is 1. This may appear to be a silly brute force approach, but it turns out to be fairly fast even for commonly large integers (there is nothing in the challenge specification that says that we should be able to handle very large numbers). Of course, it is a completely different story when cryptographers ask you about 200 or 300 digits integers. 

Perl 6 has a fast `is-prime` built-in routine that we can use to build a lazy infinite list of prime numbers, so that we can try even division by prime factors only.

``` Perl6
 use v6;

 my @primes = grep {.is-prime}, 1..*;

 sub MAIN (UInt $num is copy) {
     my %factors;
     for @primes -> $div {
         while ($num %% $div) {
             %factors{$div}++;
             $num div= $div;
         }
         last if $num == 1;
         ++%factors{$num} and last if $num.is-prime;
     }
     for sort {$^a <=> $^b}, keys %factors -> $fact {
         say "$fact ** %factors{$fact}";
     }
     say now - INIT now; # timings
 }
```

Note that this line:

``` Perl6
++%factors{$num} and last if $num.is-prime;
```

isn't really needed but brings a significant performance enhancement when the last factor to be found is very large, as it can be seen in the last three tests below (BTW, in such cases, Perl 6 runs significantly faster than equivalent Perl 5 scripts):

    $ perl6 prime-fact.p6 12
    2 ** 2
    3 ** 1
    0.0129253
    
    $ perl6 prime-fact.p6 1200
    2 ** 4
    3 ** 1
    5 ** 2
    0.01692924
    
    $ perl6 prime-fact.p6 1280
    2 ** 8
    5 ** 1
    0.01294
    
    $ perl6 prime-fact.p6 128089876
    2 ** 2
    463 ** 1
    69163 ** 1
    0.052831
    
    $
    $ perl6 prime-fact.p6 1280898769976
    2 ** 3
    7 ** 2
    1783 ** 1
    1832641 ** 1
    0.1106868
    
    $ perl6 prime-fact.p6 128089876997685
    3 ** 1
    5 ** 1
    29 ** 1
    37 ** 1
    179 ** 1
    44460137 ** 1
    0.051871
    
    perl6 prime-fact.p6 12808987699768576
    2 ** 8
    509 ** 1
    98300801969 ** 1
    0.0469033

## Alternative Solutions

[Kevin Colyer](https://github.com/manwar/perlweeklychallenge-club/blob/master/challenge-023/kevin-colyer/perl6/ch-2.p6) implemented a trial division algorithm with primes fairly similar to my solution, using a `while` loop. He also used the same optimization consisting in checking primality of the result of the last division.

[Mark Senn](https://github.com/manwar/perlweeklychallenge-club/blob/master/challenge-023/mark-senn/perl6/ch-2.p6) also implemented  a trial division algorithm, but using a `for` loop for the main loop. His program stops looking for new primes when the square of the next prime is larger than the number being factorized. Mark optimized the construction of the lazy prime list by creating a sequence to check primality of only odd numbers (in addition to 2):

``` Perl6
for   (2, 3, *+2 ... *). grep ({.is -prime}) ->$p   {
```

[Noud](https://github.com/manwar/perlweeklychallenge-club/blob/master/challenge-023/noud/perl6/ch-2.p6) implemented trial division in the form of a recursive `decomp` subroutine:

``` Perl6
sub decomp(Int $n) {
    if ($n > 1) {
        my $prime = (2..Inf).grep({ $n %% $_ })[0];
        ($prime, |(decomp(($n / $prime).Int)));
    }
}
```
The program is trying even division with all numbers, not just primes. It works for small integer input, but Noud's program becomes very slow for moderately large input values. For example, it took more than 30 seconds to factorize a 15-digit number that my program processed in 0.052 second.

[Simon Proctor](https://github.com/manwar/perlweeklychallenge-club/blob/master/challenge-023/simon-proctor/perl6/ch-2.p6) used trial division in a `while` loop. His `least-prime-divisor` subroutine returns its input parameter if it is prime and its smallest prime divisor otherwise. Simon's loop also stops when the result of a trial division is prime.

[Arne Sommer](https://github.com/manwar/perlweeklychallenge-club/blob/master/challenge-023/arne-sommer/perl6/ch-2.p6) used trial division with primes in a `for` loop. Arne's loop also stops when the result of a trial division is prime.

[Athanasius](https://github.com/manwar/perlweeklychallenge-club/blob/master/challenge-023/athanasius/perl6/ch-2.p6) implemented trial division with primes in a `for` loop.

[Jaldhar H. Vyas](https://github.com/manwar/perlweeklychallenge-club/blob/master/challenge-023/jaldhar-h-vyas/perl6/ch-2.p6) implemented trial division with primes, using a recursive `factorize` subroutine. Jaldhar's program is very slow for moderately large numbers, presumably because it has to recompute the primes on each recursive call of the `factorize` subroutine and also because it tries even division by primes already used on each recursive call.

[Joelle Maslak](https://github.com/manwar/perlweeklychallenge-club/blob/master/challenge-023/joelle-maslak/perl6/ch-2.p6) also used a recursive subroutine, `prime-factors`. Her program doesn't use prime numbers for trial division, but all integers from 2 up to the square root of the number being factorized. Contrary to the two other recursive solutions presented above, her program is very fast, which shows that a recursive approach is perfectly valid and that you don't need to use a lazy list of primes to obtain good performance. I haven't really benchmarked all solutions, but her program may very well be the fastest (or, at least, one of the fastest), which would tend to prove that, although the `is-prime` built-in function is very fast, it has a penalty when used many times for generating the large number of primes needed in trial division. 

[Randy Lauen](https://github.com/manwar/perlweeklychallenge-club/blob/master/challenge-023/randy-lauen/perl6/ch-2.p6) used trial division in a `for` loop over 2 and odd numbers between 3 and the square root of the integer being factorized. His program becomes very slow for some large input numbers (I guess this is the case especially when there is a large prime factor).

[Roger Bell West](https://github.com/manwar/perlweeklychallenge-club/blob/master/challenge-023/roger-bell-west/perl6/ch-2.p6) implemented trial division in a `while` loop 2 and odd numbers between 3 and the square root of the integer being factorized. His program is very fast.

[Ruben Westerberg](https://github.com/manwar/perlweeklychallenge-club/blob/master/challenge-023/ruben-westerberg/perl6/ch-2.p6) implemented trial division in an infinite `loop` loop over a list of primes.

[Yet Ebreo](https://github.com/manwar/perlweeklychallenge-club/blob/master/challenge-023/yet-ebreo/perl6/ch-2.p6) implemented trial division in a `while` loop over 2 and odd numbers between 3 and the square root of the integer being factorized.

## A more efficient solution

All challengers, including myself, have used some form of trial division algorithm for solving the challenge. This method is good enough for small and moderately large input integers.

But there are some better algorithms for finding prime factors of a large input integer, such as, for example, John Pollard's [rho algorithm](https://en.wikipedia.org/wiki/Pollard%27s_rho_algorithm), already mentioned in my blog post about [Amicable Numbers](./Amicable-numbers.md), in the context of comments on Damian Conway's blog post on the same subject: [With friends as these...](http://blogs.perl.org/users/damian_conway/2019/08/with-friends-like-these.html). It is implemented in the `prime-factors` function of a Perl 6 module named [Prime::Factor](https://github.com/thundergnat/Prime-Factor/blob/master/lib/Prime/Factor.pm6) by Stephen Schulze (aka *thundergnat*). 

### Minor Optimizations

Stephen Schulze's program starts with a phase of trial division for primes between 2 and 43, but does it in a way that is presumably optimized. His program first tries even division by 2 as long as the resulting number is even. Then it computes the greatest common divisor (GCD) between the number being factorized and the product of all primes between 3 and 43. Computing once the GCD with the built-in `gcd` operator is faster than trial division with all primes between 3 and 43. You still have to try division with the prime factors of the GCD, but this turns out to be faster.  The performance gain is slightly more significant when the GCD is 1 (i.e. the number is not evenly divisible by any of the primes between 3 and 43.

I tried to implement this optimization with the program of my solution at the beginning of this post:

``` Perl6
use v6;

sub MAIN (UInt $n) {
    my %*factors;
    factorize $n;
    for sort {$^a <=> $^b}, keys %*factors -> $fact {
        say "$fact ** %*factors{$fact}";
    }
    say now - INIT now;
}

sub factorize (UInt $num is copy) {
    my @small-primes = grep {.is-prime}, 3..43;
    my $magic-nr = [*] @small-primes; # 6541380665835015
    $num div=2 and %*factors{2}++ while $num %% 2;
    if (my $gcd = $num gcd $magic-nr) > 1 {
        factor-gcd $num, $gcd, @small-primes;
    }
    return if $num == 1;
    factor2 $num;
    
    sub factor-gcd (UInt $num is rw, UInt $gcd is copy, @primes) {
         for @primes -> $div {
            if $gcd %% $div {
                while $num %% $div {
                    %*factors{$div}++;
                    $num div= $div;
                }
                $gcd div= $div;
                last if $gcd == 1;
            }
        }
    }
    
    sub factor2 (UInt $num is copy) {
        my @primes = grep {.is-prime}, 47..*;
        for @primes -> $div {  0.0598399
            while ($num %% $div) {
                %*factors{$div}++;
                $num div= $div;
            }
            last if $num == 1;
            ++%*factors{$num} and last if $num.is-prime;
        }
    }
}
```

This table compares the timings of my original solution with those of the modified solution:

| Input number      | Timing my solution | Timing modified solution |
| ----------------- | ------------------ | ------------------------ |
| 1200              | 0.0129922          | 0.01194031               |
| 1280              | 0.01293717         | 0.01196898               |
| 128089876         | 0.035905           | 0.0329119                |
| 128089876997685   | 0.03490866         | 0.0329133                |
| 12808987699768576 | 0.0598399          | 0.04189898               |
| 5694893435273012  | 21.4445461         | 20.68674372              |

As it can be seen, the modified version is consistently faster, but only by a narrow margin. These micro-optimizations are probably not worth the extra effort.

Note that the timings on the last row are much larger than the others because 5694893435273012 is a relatively pathological case in the sense that is contains more than one relatively large prime factor (the prime decomposition of it is: 2, 2, 463, 69163, and 44460137).

### Pollard's Rho (or *ρ*) Algorithm

I won't attempt to explain the mathematical reasoning behind Pollard's algorithm, you should really check this [Wikipedia page](https://en.wikipedia.org/wiki/Pollard%27s_rho_algorithm) if you want to know, as I wouldn't be able to do much more than paraphrasing it.

The algorithm itself is rather simple. It takes as its inputs *n*, the integer to be factored; and *g(x)*, a polynomial in *x* computed modulo *n*. In the original algorithm, *g(x) = (x² − 1) mod n*, but nowadays it is more common to use *g(x) = (x² + 1) mod n*. The output is either a non-trivial factor of *n*, or failure. It performs the following steps:

    x ← 2; y ← 2; d ← 1
    while d = 1:
        x ← g(x)
        y ← g(g(y))
        d ← gcd(|x - y|, n)
    if d = n: 
        return failure
    else:
        return d

This algorithm may fail to find a nontrivial factor even when *n* is composite. In that case, the method can be tried again, using a starting value other than 2 or a different *g(x)*. 

Stephen Schultze's implementation of John Pollard's rho (or *ρ*) algorithm looks like this:

``` Perl6
use v6;

sub prime-factors ( Int $n where * > 0 ) {
    return $n if $n.is-prime;
    return [] if $n == 1;
    my $factor = find-factor( $n );
    sort flat prime-factors( $factor ), prime-factors( $n div $factor );
}

sub find-factor ( Int $n, $constant = 1 ) {
    return 2 unless $n +& 1;  # return 2 if $n is even
    if (my $gcd = $n gcd 6541380665835015) > 1 { # magic number: [*] primes 3 .. 43
        return $gcd if $gcd != $n
    }
    my $x      = 2;
    my $rho    = 1;
    my $factor = 1;
    while $factor == 1 {
        $rho = $rho +< 1;  # equivalent to: $rho *= 2;
        my $fixed = $x;
        my int $i = 0;
        while $i < $rho {
            $x = ( $x * $x + $constant ) % $n;
            $factor = ( $x - $fixed ) gcd $n;
            last if 1 < $factor;
            $i = $i + 1;
        }
    }
    $factor = find-factor( $n, $constant + 1 ) if $n == $factor; # try again if failure (rare)
    $factor;
}

sub MAIN (Int $n where * > 0) {
    say prime-factors $n;
    say now - INIT now;
}
```

(I've added a few comments to the code to clarify things that may seem obscure to some readers, especially on these pesky bitwise operators that most of us no longer use very commonly nowadays.)

Let's now look at the timings of Pollard's rho algorithm as implemented in Perl 6 by Stephen Schulze:



| Input number      | Timing my solution | Pollard rho |
| ----------------- | ------------------ | ----------- |
| 1200              | 0.0129922          | 0.0109705   |
| 1280              | 0.01293717         | 0.0109427   |
| 128089876         | 0.035905           | 0.0149337   |
| 128089876997685   | 0.03490866         | 0.01897     |
| 12808987699768576 | 0.0598399          | 0.0229645   |
| 5694893435273012  | 21.4445461         | 0.0229195   |

Pollard's rho algorithm for integer factorization appears to be significantly more efficient for most common cases of moderately large input integers, and hugely more efficient for pathological cases (e.g. when there are at least two large prime factors, as in the last row above).


## See Also

Four blog posts on prime decomposition of an integer:

* Mark Senn: https://engineering.purdue.edu/~mark/pwc-023-2.pdf

* Arne Sommer: https://perl6.eu/forward-prime.html

* Jaldhar M. Vyas: https://www.braincells.com/perl/2019/09/perl_weekly_challenge_week_23.html

* Roger Bell West: https://blog.firedrake.org/archive/2019/08/Perl_Weekly_Challenge_23.html



## Wrapping up

Please let me know if I forgot any of the challengers or if you think my explanation of your code misses something important.

If you want to participate to the Perl Weekly Challenge, please connect to [this site](https://perlweeklychallenge.org/).


