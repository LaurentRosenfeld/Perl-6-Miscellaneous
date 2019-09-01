# Sexy Prime Pairs

This is derived from my [blog post](http://blogs.perl.org/users/laurent_r/2019/08/perl-weekly-challenge-22-sexy-prime-pairs-and-compression-algorithm.html) made in answer to the [Week 22 of the Perl Weekly Challenge](https://perlweeklychallenge.org/blog/perl-weekly-challenge-022/) organized by  <a href="http://blogs.perl.org/users/mohammad_s_anwar/">Mohammad S. Anwar</a> as well as answers made by others to the same challenge.

The challenge reads as follows:

*Write a script to print first 10 Sexy Prime Pairs. Sexy primes are prime numbers that differ from each other by 6. For example, the numbers 5 and 11 are both sexy primes, because 11 - 5 = 6. The term “sexy prime” is a pun stemming from the Latin word for six: sex. For more information, please checkout [wiki](https://en.wikipedia.org/wiki/Sexy_prime) page.*

My first question, when reading this definition, was whether sexy primes had to be consecutive prime numbers. The example provided (as well as those found in the the Wikipedia page) shows that it needs not be the case: 5 and 11 are not consecutive primes (since 7 is also prime). If sexy primes had to be consecutive primes, then the first such pair would be (23, 29). With that answer to my question, it seems to me that all we need to do is to look at each prime number *p* and check whether *p + 6* is prime (and stop as soon as we have 10 sexy pairs).

Note that (1, 7) is not a sexy prime pair (despite having a gap of 6), because 1 is not considered to be a prime number. Therefore, to avoid the risk of finding a false sexy prime pair, we will start our search with number 2.

## My Solution

We first build a lazy infinite list `@sexy-primes` of prime numbers such that each such prime + 6 is also prime, and then print the pairs:

``` Perl6
    use v6;

    my @sexy-primes = grep { .is-prime and ($_ + 6).is-prime}, (2, 3, *+2 ... Inf);
    say "@sexy-primes[$_] ", @sexy-primes[$_] + 6 for ^10;
```

Note that, as a basis for finding the primes, we use a sequence operator with an explicit generator in order to check parity only for odd numbers. This avoids useless computations on even numbers which cannot be prime (except for 2). This might be considered premature optimization (and we all know what Donald Knuth said about premature optimization). Well, yes, but, at the same time, I don't like to let my programs do unnecessary work.  

And this prints:

    $ perl6 sexy-pairs.p6
    5 11
    7 13
    11 17
    13 19
    17 23
    23 29
    31 37
    37 43
    41 47
    47 53

This program is so short that we can easily get rid of the `@sexy-primes` temporary array and transform the script into a Perl6 one-liner:

    $ perl6 'say "$_ ", $_+6 for (2...*).grep({.is-prime && ($_ + 6).is-prime})[^10];'
    5 11
    7 13
    11 17
    13 19
    17 23
    23 29
    31 37
    37 43
    41 47
    47 53

## Alternative Solutions

[Arne Sommer](https://github.com/manwar/perlweeklychallenge-club/blob/master/challenge-022/arne-sommer/perl6/ch-1.p6) also used a lazy infinite list of primes, grepped those primes to keep only those primes *n* for which *n + 6* is also prime, and printed the first ten.

[Kevin Colyer](https://github.com/manwar/perlweeklychallenge-club/blob/master/challenge-022/kevin-colyer/perl5/ch-1.pl) also populated a lazy infinite list of primes and then looks for those primes *n* where *n + 6* is also prime. I must say that I find that the way Kevin loops over the array of primes, with two nested loops and two iteration variables, is a little bit contrived and not very perlish.

[Mark Senn](https://github.com/manwar/perlweeklychallenge-club/blob/master/challenge-022/mark-senn/perl6/ch-1.p6) also used a lazy infinite list of primes but then looks for those where the *number - 6* is also prime. Why not? After all, defining sexy prime pairs as pairs of numbers such that *n* and *n* - 6 are both prime is equivalent to defining them as as pairs of numbers such that *n* and *n* + 6 are both prime. So this is perfectly fine. I think, however, that Mark's solution is a bit more complicated than it really needs to be. In particular, it uses a `@cb` circular buffer which seems unnecessary to me.

[Simon Proctor](https://github.com/manwar/perlweeklychallenge-club/blob/master/challenge-022/simon-proctor/perl6/ch-1.p6) used a one-real-code line solution:

```Perl6
.say for (^Inf).hyper.grep( { $_.is-prime && ($_ + 6).is-prime } ).map( { ($_,$_+6).join(",") } )[^$n];
```
Note the use of the `hyper` method to enable the processing of items in parallel (and preserving the order). It probably doesn't boost performance very much with such a small dataset, but it is still a good idea to keep in mind.

[Athanasius](https://github.com/manwar/perlweeklychallenge-club/blob/master/challenge-022/athanasius/perl6/ch-1.p6) used a lexical construct that I had never seen before to loop over prime numbers:
``` Perl6
Nil until is-prime(++$prime);    
# Now do something with $prime
```
Otherwise, he defines a `$partner` of `$prime` as `$prime + 6`, checks if the partner is prime and, if so, stores `[$prime, $partner]` into a `@pairs` array. His main `while` loop stops when the `@pairs` array has ten elements.

[Jaldhar M. Vyas](https://github.com/manwar/perlweeklychallenge-club/blob/master/challenge-022/jaldhar-h-vyas/perl6/ch-1.sh) made a Perl 6 one-liner fairly similar to my second solution:
``` Perl6
perl6 -e '(1..∞).grep({.is-prime}).map({($_,$_+6) if ($_+6).is-prime})[^10].map({.join(q{, }).say});'
```
[Joelle Maslak](https://github.com/manwar/perlweeklychallenge-club/blob/master/challenge-022/joelle-maslak/perl6/ch-1.p6) also used a lazy infinite list of primes, but then she used a `lazy gather ... take` statement to pick up the sexy pairs.

[Randy Lauen](https://github.com/manwar/perlweeklychallenge-club/blob/master/challenge-022/randy-lauen/perl6/ch-1.p6)'s solution uses a single line of real code:

``` Perl 6
say (1 .. Inf).map( { $_, $_+6 } ).flat.grep( { $^a.is-prime && $^b.is-prime } ).head(10).join("\n");
```
[Roger Bell West](https://github.com/manwar/perlweeklychallenge-club/blob/master/challenge-022/roger-bell-west/perl6/ch-1.p6) made an iterative solution with an infinite `for` loop. It appears that Roger did not read the challenge specification closely enough, since his solution only prints 6 sexy pairs.

[Ruben Westerberg](https://github.com/manwar/perlweeklychallenge-club/blob/master/challenge-022/ruben-westerberg/perl6/ch-1.p6) also started with a lazy infinite list of primes, but then almost lost me with an eleven-line `map` statement. Too complicated in my humble opinion.

[Yet Ebreo](https://github.com/manwar/perlweeklychallenge-club/blob/master/challenge-022/yet-ebreo/perl6/ch-1.p6), who just joined this challenge team (welcome, Yet!) and was writing a Perl 6 script for the first time (congratulations!). He supplied actually two solutions. The first one is a quite original one-liner generating all pairs of numbers between 0 and 55 with the `combinations` method and then grepping them for primality and a gap of 6:

``` Perl6
say grep { $_[1]-$_[0] == 6 }, (grep { $_.is-prime }, 0..55).combinations: 2;
```
Yet does not say how he knew he could stop his range at 55. His second solution implements manually a sieve of Eratosthenes (i.e. basically crossing out all composite numbers in a `0..55` range in order to retain only the primes), using a `grep` statement in a highly uncommon way. Then, his solution does another `grep` to find the primes with a gap of 6.

## See Also

Four blog posts this time:

Arne Sommer: https://perl6.eu/prime-lzw.html. Arne adds some bonuses: sexy prime triplets, sexy prime quadruplets, and even one sexy prime quintuplet.

Mark Senn: https://engineering.purdue.edu/~mark/pwc-022-1.pdf

Jaldar H. Vyas: https://www.braincells.com/perl/2019/08/perl_weekly_challenge_week_22.html

Yet Ebreo: http://blogs.perl.org/users/yet_ebreo/2019/08/perl-weekly-challenge-w022.html


## Wrapping up

Please let me know if I forgot any of the challengers or if you think my explanation of your code misses something important.

If you want to participate to the Perl Weekly Challenge, please connect to [this site](https://perlweeklychallenge.org/).


