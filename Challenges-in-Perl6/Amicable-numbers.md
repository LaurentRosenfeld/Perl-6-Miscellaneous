# Amicable Numbers

This is derived from my [blog post](http://blogs.perl.org/users/laurent_r/2019/08/perl-weekly-challenge-20-split-string-on-character-change-and-amicable-numbers.html) made in answer to the [Week 20 of the Perl Weekly Challenge](https://perlweeklychallenge.org/blog/perl-weekly-challenge-020/) organized by  <a href="http://blogs.perl.org/users/mohammad_s_anwar/">Mohammad S. Anwar</a> as well as answers made by others to the same challenge.

The challenge reads as follows:

*Write a script to print the smallest pair of Amicable Numbers. For more information, please checkout [wikipedia page](https://en.wikipedia.org/wiki/Amicable_numbers).*

Amicable numbers are two different numbers so related that the sum of the proper divisors of each is equal to the other number. (A proper divisor of a number is a positive factor of that number other than the number itself. For example, the proper divisors of 6 are 1, 2, and 3.)

## My Solution

We'll use the `sum-divisors` subroutine to find the divisors of a given number and return their sum. This subroutine uses trial division, i.e. tries division by all integers below a certain limit (here, half of the input number), and then sums up all those that evenly divide the input number. Then, we just loop over a lazy infinite list of integers from 2 onward and call `sum_divisors` subroutine. If the sum of divisors is larger than the integer being examined (if it is smaller, then it is a pair of numbers that we have already checked), then we check the sum of divisors of the sum of divisors. If it is equal to the current integer, then we've found two amicable numbers and can print them and exit the loop.

``` perl6
use v6;

sub sum-divisors (Int $num) {
    my @divisors = grep { $num %% $_ }, 2..($num / 2).Int;
    return [+] 1, | @divisors;
}

for 2..Inf -> $i {
    my $sum_div = sum-divisors $i;
    if $sum_div > $i and $i == sum-divisors $sum_div {
        say "$i and $sum_div are amicable numbers";
        last;
    }
}
```

The `sum-divisors` subroutine is not optimal and its performance could be greatly enhanced, but we don't need to do that since we're looking only for the first pair of amicable numbers, which are rather small. This program prints almost instantly the first pair of amicable numbers:

    $ perl6 amicable_nrs.p6
    220 and 284 are amicable numbers

Note that the Wikipedia article shows some rules to quickly find some amicable numbers (Thābit ibn Qurra's theorem and Euler's rule), but I did not want to use any of these because neither Thābit ibn Qurra's theorem, nor Euler's method will produce all amicable numbers, so that it is not guaranteed that we would find the first pair with such methods (although it so happens that both methods do produce the first pair).

## Alternative Solutions

[Arne Sommer](https://github.com/manwar/perlweeklychallenge-club/blob/master/challenge-020/arne-sommer/perl6/ch-2.p6) used essentially the same method, except that his `proper-divisors` subroutine returns a list of proper divisors which are then added in the calling code.

[Ruben Westerberg](https://github.com/manwar/perlweeklychallenge-club/blob/master/challenge-020/ruben-westerberg/perl6/ch-2.p6) also uses essentially the same method, but his `proper` subroutine is particularly concise:

``` perl6
sub proper(\n) {
	sum (1..n-1).grep({ n%%$_});
}
```

[Francis Whittle](https://github.com/manwar/perlweeklychallenge-club/blob/master/challenge-020/fjwhittle/perl6/ch-2.p6) used multi `MAIN` subroutine to use either Euler's rule or the naive trial division algorithm described in my solution above. One interesting thing in Francis's naive implementation is that is `proper-divisor-sum` is using the `is cached` trait to avoid recomputing the proper divisors of a numlber it it has already been calculated.

[Kevin Coyler](https://github.com/manwar/perlweeklychallenge-club/blob/master/challenge-020/kevin-colyer/perl6/ch-2.p6) and [Randy Lauen](https://github.com/manwar/perlweeklychallenge-club/blob/master/challenge-020/randy-lauen/perl6/ch-2.p6) also cached the sums of proper divisors, but did it manually by storing them into a hash. [Noud](https://github.com/manwar/perlweeklychallenge-club/blob/master/challenge-020/noud/perl6/ch-2.p6) also cached the results returned by `prop_div` subroutine, but did that in an original way by adding a wrapper to the subroutine.

[Adam Russell](https://github.com/manwar/perlweeklychallenge-club/blob/master/challenge-020/adam-russell/perl6/ch-2.p6) used the same general algorithm, but interestingly used [promises](https://docs.perl6.org/type/Promise) to parallelize part of the work over several concurrent threads and presumably speed up the search.

[Athanasius](https://github.com/manwar/perlweeklychallenge-club/blob/master/challenge-020/athanasius/perl6/ch-2.p6) used the `divisor_sum` subroutine of the CPAN `Math::Prime::Util` **Perl 5** module and further created an alias on it presumably to make its use easier:
``` Perl6
use Math::Prime::Util:from<Perl5> <divisor_sum>;
my Sub $divisor-sum := &Math::Prime::Util::divisor_sum;     # Alias
```
This is really cool, as it is a good example showing how a fairly large part of the Perl 5 ecosystem can be used in Perl 6. Note, however that the `divisor_sum` subroutine returns the sum of all divisors of a number (including itself), so that he had to subtract the number from the sums of its divisors in order to obtain the sum of *proper* divisors.

[Feng Chang](https://github.com/manwar/perlweeklychallenge-club/blob/master/challenge-020/feng-chang/perl6/ch-2.p6) made a very nice and concise script using infinite lists:

``` perl6
my @a = (0..∞).map:  { sod($_) };
my @b = (0..∞).grep: { @a[$_] > $_ and @a[@a[$_]] == $_ };
say(@b[0], ' ', @a[@b[0]]);
# sum of proper divisors
sub sod(UInt $n) {
    [+] (1 .. $n/2).grep: { $n %% $_ }
}
```

[Jaldhar H. Vyas](https://github.com/manwar/perlweeklychallenge-club/blob/master/challenge-020/jaldhar-h-vyas/perl6/ch-2.p6) used Thābit ibn Qurra's theorem to generate the first pair of amicable numbers. As mentioned above, I believe this is a bit dangerous since this method cannot generate an exhaustive list of such pairs, so we are not really garanteed to find the first pair. As it turns out, though, this method does yield the first pair, so that Jaldhar's reesult is nonetheless correct.

[Joelle Maslak](https://github.com/manwar/perlweeklychallenge-club/blob/master/challenge-020/joelle-maslak/perl6/ch-2.p6)'s `factorsum` subroutine is probably more efficient than my `sum-divisors` subroutine (and is certainly faster for large input integers) because it iterates to the square root on the input number (instead of going to half the input number in my subroutine) and then computes the other divisors (for example, when looking for the divisors of 12, my subroutine iterates until 6, whereas Joelle's subroutine only need to iterate until 3, obtains 2 and 3 and finds 6 by dividing 12 by 2 and 4 by dividing 12 by 3; this probably doesn't improve very much performance for a small number such as 12, but it certainly does for larger numbers). In addition, she caches the results with the `is cached` trait. Her code is also a pretty clockwork of functional programming with two nice data pipelines.

[Roger Bell West](https://github.com/manwar/perlweeklychallenge-club/blob/master/challenge-020/roger-bell-west/perl6/ch-2.p6)'s `divisors_unself` subroutine also iterates only to the square root of the input number, using essentially the same method as Joelle to generate the missing divisors above the square root. As noted just above, this is liukely to be signiificantly faster for large inpout integers.

##Enter Damian Conway

Also known as [TheDamian](https://www.perlmonks.org/?node_id=107600), Damian Conway wrote (as often) the most definitive analysis on the subject in his [With friends as these...](http://blogs.perl.org/users/damian_conway/2019/08/with-friends-like-these.html) blog post. On top of that, it is really well-written.

I will not try to summarize Damian's master piece, you should really follow the link and read it, but I will only highlight a few points.

Given a function that returns the divisors of a number, Damian says it is easy enough to iterate through each integer from 1 to infinity, find its divisors, then check to see if the sum-of-divisors of that number is identical to the original number (pretty much what I did in the main code on my script at the beginning of this post). Then, the article goes on to study how to do it if we want to find more than one amicable pair. Of course, in such a case, the performance issues that I originally brushed aside because we only needed ther first pair now need to be re-examined.

The problem is that, since Perl 6 does not have a built-in function that returns the proper divisors of a number, we obviously need to write one. Damian comes up with a handful of such subroutines using the naive trial division algorithm, for example:

``` perl6
multi divisors (\N) { (1..N).grep(N %% *) }
```

The problem with it is that it is very inefficient when the input numbers become large. The first thing that Damian does is more or less the same improvement that Joelle and Roger used: iterate until the square root of the input number and compute the larger missing divisors as the division of the input integer by each of the smaller divisors. For example:

``` perl6
multi divisors (\N) {
    my \small-divisors = (1..sqrt N).grep(N %% *);
    my \big-divisors   = N «div« small-divisors;
    return unique flat small-divisors, big-divisors;
}
```

This is vastly more efficient. The performance of the `divisors` subroutine up to `divisors(10**9)` is entirely acceptable at under 0.1 seconds, but starts to fall off rapidly after that point. What if we want to go further?

Cryptographers have designed a number of more efficient algorithms to find the factors of an integer. One of them is [Pollard’s 𝜌 algorithm](https://en.wikipedia.org/wiki/Pollard%27s_rho_algorithm), which is implemented in the `prime-factors` function of a Perl 6 module named [Prime::Factor](https://github.com/thundergnat/Prime-Factor/blob/master/lib/Prime/Factor.pm6) by Stephen Schulze. This function finds all the prime factors of a large input number very quickly. But the prime factors of a number isn't the same thing as its divisors. But we can use prime factors to compute the divisors by combining the gactors in all possible ways. Except that if we use the naive approach of finding all combinations of prime factors, the program becomes catastrophically slow because of [combinatorial explosion](https://en.wikipedia.org/wiki/Combinatorial_explosion).  Damian then shows how storing the prime factors in a `Bag` data structure makes it possible to test every possible combination of the prime factors exponents (the values of the bag). And the new version based on this isea scales incredibly better than any previous implementation: the program can find the divisors of a number with 100 digits in less than half a second.

Damian makes two additional points. One is that the new version of the `divisors` is a lot faster for very large numbers, but that for smaller numbers (below about 10,000), iterating trial division to the square root of the input integer is faster. He then shows how easy it is to make two `multi` versions of the `divisors` subroutine, one for small numbers and one for big ones.  Finally, Damian demonstrate how adding a single word, the `hyper` prefix, to his main `for` loop enables concurrency and makes the overall program about twice as fast.

I hope that I have opened your appetite. Once again, you should really follow [the link]((http://blogs.perl.org/users/damian_conway/2019/08/with-friends-like-these.html) to Damian's post and read it in detail. It's really worth it.

## See Also

See also the following blog posts:

* Arne Sommer: https://perl6.eu/amicable-split.html
* Adam Russell: https://adamcrussell.livejournal.com/6526.html
* Roger Bell West: https://blog.firedrake.org/archive/2019/08/Perl_Weekly_Challenge_19.html
* Jaldhar Y. Vyas: https://www.braincells.com/perl/2019/08/perl_weekly_challenge_week_20.html
* Damian Conway: http://blogs.perl.org/users/damian_conway/2019/08/with-friends-like-these.html

## Wrapping up

Please let me know if I forgot any of the challengers or if you think my explanation of your code misses something important.

If you want to participate to the Perl Weekly Challenge, please connect to [this site](https://perlweeklychallenge.org/).

