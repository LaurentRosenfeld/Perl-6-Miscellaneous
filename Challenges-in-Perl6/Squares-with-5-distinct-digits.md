# Square Number With At Least 5 Distinct Digits

This is derived from this [blog post](http://blogs.perl.org/users/laurent_r/2019/05/perl-weekly-challenge-9-squares-and-rankings.html) and this [other blog post](http://blogs.perl.org/users/laurent_r/2019/05/perl-weekly-challenge-9-square-numbers-and-functional-programming-in-perl.html) made in answer to the [Week 9 of the Perl Weekly Challenge](https://perlweeklychallenge.org/blog/perl-weekly-challenge-009/) organized by  <a href="http://blogs.perl.org/users/mohammad_s_anwar/">Mohammad S. Anwar</a> as well as answers made by others to the same challenge.

The challenge reads as follows:

*Write a script that finds the first square number that has at least 5 distinct digits.*

There might be a slight ambiguity in the question. I consider that we want at least 5 distinct digits, but don't care if some of the digits have duplicates. For example, in my view, 105625 is the square of 325 and has at least 5 distinct digits and thus qualifies as a "square number that has at least 5 distinct digits" (except, or course, that it isn't the first one, but it would be a valid answer if it happened to be the first one). As it turns out, this possible ambiguity is immaterial, since the first number satisfying the requirement has only 5 digits anyway (and therefore no duplicate). The point, though, is that our code doesn't need to care about possible duplicate digits, provided we can count at least 5 distinct digits.

## My Solutions

We need square numbers with (at least) 5 digits, so we'll loop on successive integers from 100 on and compute their square (since the squares of smaller integers are bound to have less that 5 digits). We could use a hash or a set to remove duplicates from the list of individual digits, but it so happens that Perl 6 has a built-in `unique` function to do just that. This makes it easy to do it with a simple Perl 6 one-liner:

    $ perl6 -e 'say $_ and last if .comb.unique >= 5 for map {$_ **2}, 100..*;'
    12769

This is what it might look like if you prefer a full-fledged script:

``` Perl6    
use v6;

my @squares = map {$_ ** 2}, 100..*;   # lazy infinite list of squares
for @squares -> $square {
    if $square.comb.unique >= 5 {
        say $square;
        last;
    }
}
```

We could also remove any `for` loop and `if` conditional by just building successively two infinite lists:

``` Perl6 
use v6;

my @squares = map {$_ ** 2}, 100..*;
my @candidates = grep { .comb.unique >= 5}, @squares;
say @candidates[0];
```

By the way, this idea of using infinite lists can be boiled down to another approach for a one-liner:

    $ perl6 -e 'say (grep { .comb.unique >= 5}, map {$_ ** 2}, 100..*)[0];'
    12769

Another possible approach is to use chained method invocations:

    $ perl6 -e 'say (100..*).map(* ** 2).grep(*.comb.unique >= 5).first;'
    12769

### Exploring Functional Programming

A data pipeline in functional style may look like this:

    say first /\d+/, grep { 5 <= elems unique comb '', $_ }, map { $_ ** 2}, 100..*;

Note that `first` used as a functional subroutine apparently needs a regex as a first argument. The `/\d+/` isn't really useful for the algorithm, but is needed for `first` to work properly.

But we can use `first` with a `grep`-like syntax (and effectively remove the `grep`) to make this more convenient:

    say first { 5 <= elems unique comb '', $_ }, map { $_ ** 2}, 100..*;

Perl 6 also has the `==>` feed operator:

    my $square = 100...* ==> map { $_ ** 2 } ==> grep(*.comb.unique >= 5)  ==> first /\d+/;
    say $square;

or, probably better:

    100...* ==> map { $_ ** 2 } ==> first(*.comb.unique >= 5)  ==> say();

There is also the `<==` leftward feed operator (although I'm not entirely convinced about its usefulness):

    say()  <== first(*.comb.unique >= 5) <== map { $_ ** 2} <== 100..*;

When answering this challenge in Perl 5, one of my solutions was to build an iterator to provide squares on demand. We have no compelling reason to try to build an iterator in Perl 6 as in Perl 5, since the lazy infinite list mechanism just offers what we need. But we can create an iterator if we want to. This is what it might look like using the `state` declarator:

``` Perl6
use v6;
sub provide-square (Int $in) {
    state $num = $in;
    return ++$num ** 2;
}
while my $square = provide-square 100 {
    if $square.comb.unique >= 5 {
        say $square;
        last;
    }
}
```

The main `while` loop can me made a bit more compact using a `LAST` phaser to print the square when exiting the loop (and thus avoid the conditional block):

``` Perl6
while my $square = provide-square 100 {
    last if $square.comb.unique >= 5;
    LAST say $square;
}
```

We could also create an iterator in the old traditional way with a closure:

``` Perl6
sub create-iter (Int $in) {
    my $num = $in;
    return sub {
        return ++$num ** 2;
    }
}
my &square-iter = create-iter 100;
while my $square = &square-iter() {
    last if $square.comb.unique >= 5;
    LAST say $square;
}
```
## Alternative Solutions

[Arne Sommer](https://github.com/manwar/perlweeklychallenge-club/blob/master/challenge-009/arne-sommer/perl6/ch-1.p6) used an infinite list of integers and a bag to remove duplicate digits from their squares:

``` Perl6
for 100 .. Inf
{
  my $candidate = $_ ** 2;
  ( say "$_ -> $candidate"; last ) if $candidate.comb.Bag.elems >= 5;
}
```
I did not know about the `( say "$_ -> $candidate"; last ) if ...` syntax, which is another nice way to avoid a conditional block.

[Daniel Mita](https://github.com/manwar/perlweeklychallenge-club/blob/master/challenge-009/daniel-mita/perl6/ch-1.p6) used an infinite list of integers and a set, leading to an extremely concise and elegant solution:

``` Perl6
say first map ^∞: *²: *.comb.Set ≥ 5;
```

[Francis J. Whittle](https://github.com/manwar/perlweeklychallenge-club/blob/master/challenge-009/fjwhittle/perl6/ch-1.p6) used an infinite list of integers and a bag, and his solution is also fairly concise:

``` Perl6
(^∞).map(* ** 2).grep(*.comb.Bag.elems >= $digits)[0].put;
```

[Jaldhar M. Vyas](https://github.com/manwar/perlweeklychallenge-club/blob/master/challenge-009/jaldhar-h-vyas/perl6/ch-1.p6) looped over integers larger than or equal to 100 and used a hash to remove duplicates:

``` Perl6
sub MAIN() {
    my $n = 100; # first number with a 5-digit square
    loop {
        my $nsquared = $n * $n;
        my %digits;
        $nsquared.comb.map({ %digits{$_} = True; });
        if (%digits.elems  == 5) { 
            say "$nsquared ($n * $n)";
            last;
        }
        $n++;
    }
}
```

[Joelle Maslak](https://github.com/manwar/perlweeklychallenge-club/blob/master/challenge-009/joelle-maslak/perl6/ch-1.p6) used an infinite list of integers and the built-in `unique` function to build a (pseudo-)infinite list of squares with five distinct digits. Her program then prints the first item of this infinite list:

``` Perl6
my $seq = (0..∞).map( *² ).grep({ .comb.sort eq .comb.unique.sort }).grep( *.chars ≥ 5 );
say $seq[0];
```

[Ruben Westerberg](https://github.com/manwar/perlweeklychallenge-club/blob/master/challenge-009/ruben-westerberg/perl6/ch-1.p6) used an infinite list of integers and a bag to remove duplicate digits:

``` Perl6
(0..*).map({
	my $sq= $_**2;
	$result=$sq;
	last if ($sq.comb.Bag.keys)>=5;

});
```

[Simon Proctor](https://github.com/manwar/perlweeklychallenge-club/blob/master/challenge-009/simon-proctor/perl6/ch-1.p6) used an infinite list of integers and a set to remove duplicate digits:

``` Perl6
say (1..*).map( * ** 2 ).grep( { set( $_.comb ).keys.elems >=5 } )[0];
```

[uzluisf](https://github.com/manwar/perlweeklychallenge-club/blob/master/challenge-009/uzluisf/perl6/ch-01.p6), who translated my *Think Perl 6* book into Spanish (many thanks to him), suggested a relatively long solution:

``` Perl 6
sub find-first-square( UInt:D $with-different-n-digits where * > 0 ) {
    my @nums;
    for 1..∞ {
        my $square = $_ ** 2;
        if has-at-least($square, $with-different-n-digits) {
            @nums.push: $square;
            return @nums if @nums == 5;
        }
    }

    sub has-at-least( Int:D $number, Int:D $num-of-digits ) {
        my %digits = ($_ => True for $number.comb);
        %digits == $num-of-digits;
    }
}
```
But Luis also suggested a fairly concise one-line solution:

``` Perl6
(1..∞).map(* ** 2).grep(.comb.unique ≥ 5).head(5)
```

## Enter Damian Conway

In his [blog post](http://blogs.perl.org/users/damian_conway/2019/05/why-i-love-perl-6.html), Damian Conway writes that the solution is (*obviously!*) to lazily square every number from 1 to infinity, then comb through each square's digits looking for five or more unique numerals, and immediately output the first such square you find. This can be written so:

``` Perl6
1..∞ ==> map {$^n²} ==> first {.comb.unique ≥ 5} ==> say();
```

But the elegance of that solution is *not* why Damian loves Perl 6. Damian loves Perl 6 because, if that solution is too scary for you, then Perl 6 will also allow you to write a plain imperative, iterative, block structured, more-or-less exactly what you'd write in Perl 5, or even in C: 

``` Perl6
loop (my $n=1 ;; $n++) {
    my $n_squared = $n ** 2;

    my %unique-digits;
    for (split '', $n_squared, :skip-empty) {
        %unique-digits{$_}++
    }

    if (%unique-digits >= 5) {
        say $n_squared;
        last;
    }
}
```

Or, Damian continues, you could just as easily write a solution somewhere between those two extremes, at whatever level of complexity and decomposition happens to be the sweet spot in your personal comfort zone. For example:

``` Perl6
sub find_special_square {
    for 1..Inf -> $n {
        return $n²
            if $n².comb.unique >= 5
    }
}
say find_special_square();
```

And that's why Damian loves this language: Perl 6 lets you write code in precisely the way that suits you best, at whatever happens to be your (team's) current level of coding sophistication, and in whichever style you will later find most readable

## See Also

Three blog posts this time:

* Arne Sommer: https://perl6.eu/squared-ranking.html

* Francis J. Whittle: https://rage.powered.ninja/2019/05/26/unique-square-and-rank.html

* Damian Conway: http://blogs.perl.org/users/damian_conway/2019/05/why-i-love-perl-6.html


## Wrapping up

Please let me know if I forgot any of the challengers or if you think my explanation of your code misses something important.

If you want to participate to the Perl Weekly Challenge, please connect to [this site](https://perlweeklychallenge.org/).
