# Mutually Recursive Subroutines and the Female and Male Hofstadter Sequences

This is derived from my [blog post](http://blogs.perl.org/users/laurent_r/2019/06/perl-weekly-challenge-13-fridays-and-mutually-recursive-subroutines.html) made in answer to the [Week 13 of the Perl Weekly Challenge](https://perlweeklychallenge.org/blog/perl-weekly-challenge-013/) organized by  <a href="http://blogs.perl.org/users/mohammad_s_anwar/">Mohammad S. Anwar</a> as well as answers made by others to the same challenge.

The challenge reads as follows:

*Write a script to demonstrate Mutually Recursive methods. Two methods are mutually recursive if the first method calls the second and the second calls first in turn. Using the mutually recursive methods, generate [Hofstadter Female and Male sequences](https://en.wikipedia.org/wiki/Hofstadter_sequence#Hofstadter_Female_and_Male_sequences).*

     F ( 0 ) = 1   ;   M ( 0 ) = 0
     F ( n ) = n − M ( F ( n − 1 ) ) , n > 0
     M ( n ) = n − F ( M ( n − 1 ) ) , n > 0.


There is nothing complicated about mutually recursive subroutines. As with any recursive subroutine, you just need to make sure there is a base case to stop recursion (and that the base case will eventually be reached). The Wikipedia link provided in the question gives the beginning of the two sequences, which will help us checking our results:

    F: 1, 1, 2, 2, 3, 3, 4, 5, 5, 6, 6, 7, 8, 8, 9, 9, 10, 11, 11, 12, 13, ... 
    M: 0, 0, 1, 2, 2, 3, 4, 4, 5, 6, 6, 7, 7, 8, 9, 9, 10, 11, 11, 12, 12, ...

## My Solutions

We just need to apply the mathematical definition:

``` Perl6
use v6;

sub female (UInt:D $n) {
    return 1 if $n == 0;   # base case
    return $n - male (female ($n - 1));
}
sub male (UInt:D $n) {
    return 0 if $n == 0;   #base case
    return $n - female (male ($n - 1));
}
say "Female sequence:";
printf "%d ", female $_ for 0..30;
say "";
say "Male sequence:";
printf "%d ", male $_ for 0..30;
```

This displays the following output:

    Female sequence:
    1 1 2 2 3 3 4 5 5 6 6 7 8 8 9 9 10 11 11 12 13 13 14 14 15 16 16 17 17 18 19
    Male sequence:
    0 0 1 2 2 3 4 4 5 6 6 7 7 8 9 9 10 11 11 12 12 13 14 14 15 16 16 17 17 18 19

### Using Multi Subs for Dealing With the Base Case

Perl 6 has the notion of multi subs, which might be used for dealing with the base case needed to stop recursion. Multi subs are subroutines with the same name but a different signature to deal with different cases. 

``` Perl6
multi sub female (0) { 1; }   # base case
multi sub female (UInt:D $n) {
    return $n - male (female ($n - 1));
}
multi sub male (0) { 0; }    # base case
multi sub male (UInt:D $n) {
    return $n - female (male ($n - 1));
}
say "Female sequence:";
printf "%d ", female $_ for 0..30;
say "";
say "Male sequence:";
printf "%d ", male $_ for 0..30;
```

This prints the same output as before.

### The Performance Problem

For large input values, we have a very serious performance problem.

Let's change the script to compute only one female value and measure the time taken:

``` Perl6
use v6;

sub female (UInt:D $n) {
    return 1 if $n == 0;   # base case
    return $n - male (female ($n - 1));
}
sub male (UInt:D $n) {
    return 0 if $n == 0;   #base case
    return $n - female (male ($n - 1));
}
sub MAIN (UInt $input) {
    say "Female $input: ", female $input;
    say "Time taken: ", now - INIT now;
}
```

These are the execution times for input values 50 and 100:

    ~ perl6 hofstadter.p6 50
    Female 50: 31
    Time taken: 0.2816245
    
    ~ perl6 hofstadter.p6 100
    Female 100: 62
    Time taken: 10.96803473

They are quite bad and suggest an exponential explosion.

The reason for that is that the `female` and `male` subroutines are called many times, most of the time to compute results that have already been computed before. It would be nice if we could avoid all these useless function calls.

### Caching the Values

In Perl 5, this problem could be easily solved using Mark Jason Dominus's P5 `Memoize` module, which caches the result already obtained to avoid recomputing them. I did not think that this module had been ported yet to Perl 6 when I worked on the challenge (but see Athanasius's solution below), but there are some built-in caching features existing in Perl 6. However, before trying those, I think it is interesting to see how we can cache manually the intermediate results.

In the program below, we are storing intermediate results in the `@*female` and `@*male` dynamic-scope arrays. When the result exists in the array, we just return it, and we compute it and store it in the array when the result is not known yet (and implicitly return the result in the array in that case). Note that the two base cases are now handled through the initialization of the `@*female` and `@*male` arrays

``` Perl6
use v6;

sub female (UInt:D $n) {
    return @*female[$n] if defined @*female[$n];
    @*female[$n] = $n - male (female ($n - 1));
}
sub male (UInt:D $n) {
    return @*male[$n] if defined @*male[$n];
    @*male[$n] = $n - female (male ($n - 1));
}
sub MAIN (UInt $input) {
    my @*female = 1,;
    my @*male = 0,;
    say "Female $input: ", female $input;
    say "Time taken: ", now - INIT now;
}
```

Now, this is very fast:

    ~ perl6 hofstadter.p6 50
    Female 50: 31
    Time taken: 0.0124059
    
    ~ perl6 hofstadter.p6 100
    Female 100: 62
    Time taken: 0.02777636

Not only is this incredibly faster, but we also see that doubling the size of the input value leads to an execution duration more or less twice longer. In other words, the execution duration grows more or less linearly with the size of the input value.

The `@*female` and `@*male` use the `*` twigil to enable dynamic scoping of these variables, which means that, when used in the `female` and `male` subroutines, they are they looked up through the caller's, not through the outer, scope; in other words, when these subroutines see one of these variables and don't find a local declaration of them, they look into the MAIN subroutine, where they are properly defined. Using such dynamic scope variables makes it possible to avoid passing those arrays back and forth between calling and called subroutines, and also avoids the pitfalls of global (package scope) variables.

We built two manual caches to demonstrate the underlying idea, but, as mentioned, Perl 6 has a built-in caching feature, the `is cached` trait, which stores the result of a routine call, returning the same value if called with the same arguments. For some reasons, this trait is considered an experimental feature, so that we will need to use the `use experimental :cached;`pragma to enable the feature. 

Our benchmark program modified to include the built-in caching feature may now look like this:

``` Perl6
use v6;
use experimental :cached;

sub female (UInt:D $n) is cached {
    return 1 if $n == 0;   # base case
    return $n - male (female ($n - 1));
}
sub male (UInt:D $n) is cached {
    return 0 if $n == 0;   #base case
    return $n - female (male ($n - 1));
}
sub MAIN (UInt $input) {
    say "Female $input: ", female $input;
    say "Time taken: ", now - INIT now;
}
```

The timings show that using the built-in caching feature eliminated the performance bottleneck problem:

    ~ perl6 hofstadter-cached.p6 50
    Female 50: 31
    Time taken: 0.06588805
    
    ~ hofstadter-cached.p6 100
    Female 100: 62
    Time taken: 0.08577007

Note, however, that our manual caching strategy gave more speed. Also note that caching only one of the two subroutines brings almost the same speed improvement, since this is sufficient to prevent the huge cascade of mutually recursive calls.



## Alternative Solutions

[Arne Sommer](https://github.com/manwar/perlweeklychallenge-club/blob/master/challenge-013/arne-sommer/perl6/ch-2.p6)'s solution on the Github repository is intriguing and very interesting in the sense that it does not really implement mutually recursive subroutines, but rather *mutually recursive `gather/take` blocks* to populate a sequence of female and a sequence of male values. With values being stored in sequences, Arne's solution naturally caches its values and encounters no performance problem.

``` Perl 6
unit sub MAIN ($limit = 10);

my $M;
my $F := gather
{
  take 1;
  loop { state $index++; take $index - $M[$F[$index -1]]; }
}
$M := gather
{
  take 0;
  loop { state $index++; take $index - $F[$M[$index -1]]; }
}
say "  ", (    $_.fmt("%2d") for ^$limit ).join(" ");
say "F:", ( $F[$_].fmt("%2d") for ^$limit ).join(" ");
say "M:", ( $M[$_].fmt("%2d") for ^$limit ).join(" ");
```

Reading Arne's [Hofstadter, Friday and Perl 6](https://perl6.eu/hofstadter-friday.html) blog post, we find that Arne initially wrote proper mutually recursive subroutines. It is only because of the performance problem with mutually recursive subroutines and large input values that he decided to populate sequences of male and female values, used as a caching strategy, with `gather/take` blocks. So, it isn't a lucky coincidence that Arne's solution caches its values, it is entirely deliberate. And that makes Arne's solution even more interesting than I originally thought.

[Simon Proctor](https://github.com/manwar/perlweeklychallenge-club/blob/master/challenge-013/simon-proctor/perl6/ch-2.p6) also did not implement mutually recursive subroutines, but used two mutually recursive lazy `gather/take` blocks to generate lazy infinite lists of female and male values. Just as Arne's, Simon's solution naturally caches its values and encounters no performance problem. As an example, this is the generation of the lazy list for female values:

``` Perl6
my @F = lazy gather {
    my $n = 0;
    take 1;
    loop {
        $n++;
        take $n - @M[@F[$n-1]];
    }
}
```

And, as it turns out, Simon's use of lazy infinite lists is also an entirely deliberate caching strategy: Simon wrote in his [Hofstadter Female and Male sequences](http://www.khanate.co.uk/blog/2019/06/19/perl-weekly-challenge-13/) blog post that he was sort of prompted to suggest this solution after having read my own discussion (in this [original blog post on the subject](http://blogs.perl.org/users/laurent_r/2019/06/perl-weekly-challenge-13-fridays-and-mutually-recursive-subroutines.html)) of the performance problems with mutually recursive subroutines and the possible caching strategies. Well, thank you, Simon, it's great to see that at least some people are reading my blog posts and, more importantly, your caching solution is definitely a very nice one.

[Athanasius](https://github.com/manwar/perlweeklychallenge-club/blob/master/challenge-013/athanasius/perl6/ch-2.p6) used the `Sub::Memoized` module to speed up execution. His solution otherwise uses two mutually recursive subroutines, `F` and `M`. Reading this nice solution, you probably wouldn't guess that Athanasius is a Perl 6 novice (which I know only because he admits it in his blog post).

[Jaldhar H. Vyas](https://github.com/manwar/perlweeklychallenge-club/blob/master/challenge-013/jaldhar-h-vyas/perl6/ch-2.p6) managed the recursion base cases by writing two multi versions of the `female` and `male` subroutines. His solution is quite similar to my second (multi subs) solution above.

[Joelle Maslak](https://github.com/manwar/perlweeklychallenge-club/blob/master/challenge-013/joelle-maslak/perl6/ch-2.p6) obviously planned to use the Perl 6 built-in caching feature, as she used the `experimental :cached` pragma that I used in my last solution. But then she wrote the following comment in her code: "can't use the cached trait (because it's a multi?)". So it appears that the `cached` trait apparently can't be used with multi subs. And it seems that I was lucky when I tested my program with the `cached` trait: by chance, I did not try it with a multi sub version, but with my original non multi version. Anyway, because of that, Joelle implemented a manual cache using a hash (`%c`). Her (non base case) `F` and `M` subroutines are really very concise and yet well written and very easy to understand:

``` Perl6
multi sub F($n where * > 0 ) { state %c; %c{$n} //= $n - M( F($n-1) ) }
multi sub M($n where * > 0 ) { state %c; %c{$n} //= $n - F( M($n-1) ) }
```

[Ruben Westerberg](https://github.com/manwar/perlweeklychallenge-club/blob/master/challenge-013/ruben-westerberg/perl6/ch-2.p6) did not try to cache the results, but his two mutually recursive subroutines are also very compact:
``` Perl6
sub male ($n) {
	$n==0??0!!($n - female(male($n-1)));
}
sub female($n) {
	$n==0??1!!($n - male(female($n-1)));
}
```

## See Also

Four blog posts on the female and male Hofstadter sequences:

* Arne Sommer: https://perl6.eu/hofstadter-friday.html

* Athanasius: http://blogs.perl.org/users/athanasius/2019/06/perl-weekly-challenge-013.html. One of the amazing things I learned from Athanasius's blog is that "*F(n)* is not equal to *M(n)* if and only if `n+1` is a Fibonacci number." 

* Jaldhar H. Vyas: https://www.braincells.com/perl/2019/06/perl_weekly_challenge_week_13.html

* Simon Proctor: http://www.khanate.co.uk/blog/2019/06/19/perl-weekly-challenge-13/



## Wrapping up

Please let me know if I forgot any of the challengers or if you think my explanation of your code misses something important.

If you want to participate to the Perl Weekly Challenge, please connect to [this site](https://perlweeklychallenge.org/).

