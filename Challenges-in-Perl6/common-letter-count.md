# Common Letter Count

This is derived in part from my [blog post](http://blogs.perl.org/users/laurent_r/2019/09/perl-weekly-challenge-26-common-letters-and-mean-angles.html#_login_JPSV0lQYdfLkWaJ474dLOAvxpoCYAdlVzcbYejEv) made in answer to the [Week 26 of the Perl Weekly Challenge](https://perlweeklychallenge.org/blog/perl-weekly-challenge-026/) organized by  <a href="http://blogs.perl.org/users/mohammad_s_anwar/">Mohammad S. Anwar</a> as well as answers made by others to the same challenge.

The challenge reads as follows:

*Create a script that accepts two strings, let us call it, “stones” and “jewels”. It should print the count of “alphabet” from the string “stones” found in the string “jewels”. For example, if your stones is “chancellor” and “jewels” is “chocolate”, then the script should print “8”. To keep it simple, only A-Z,a-z characters are acceptable. Also make the comparison case sensitive.*

We're given two strings and need to find out how many letters of the second string can be found in the first string.

## My Solution

This is straight forward. Our script should be given two arguments (else the program aborts). We split the first string into individual letters and store them in the `$letters` set. Note that we filter out any character not in the `<[A-Za-z]>` character class. Then we split the second string into individual letters, keep only letters found in the `$letters` set and finally use the `.elems` method to count the number of letters.

``` Perl6
use v6;

sub MAIN (Str $str1, Str $str2) {
    my $letters = $str1.comb.grep( /<[A..Za..z]>/ ).Set;
    my $count = $str2.comb.grep( { $_ (elem) $letters} ).elems;
    say "$str2 has $count letters from $str1";
}
```

This works as expected:

    $ perl6 count_letters.p6 chocolate chancellor
    chancellor has 8 letters from chocolate
    
    $ perl6 count_letters.p6 chocolate CHANCELLOR
    CHANCELLOR has 0 letters from chocolate

## Alternate Solutions

This week, we are welcoming two new members, Donald Hunter and Markus Holzer, who both provided very interesting solutions.

[Arne Sommer](https://github.com/manwar/perlweeklychallenge-club/blob/master/challenge-026/arne-sommer/perl6/ch-1.p6) used a subset `AtoZ` of strings to enforce strings with only ASCII lower case and upper case letters. The code doing the work is very concise and holds in just one code line:

``` Perl6
say ($alphabet.comb.Set ⊍ $string.comb.Bag).Int;
```

[Donald Hunter](https://github.com/manwar/perlweeklychallenge-club/blob/master/challenge-026/donald-hunter/perl6/ch-1.p6) used a `collect` subroutine to return a `Bag` of letters for each input string. Then, computing the count of common letters is one code line:

``` Perl6
say [+] collect($stones){collect($jewels).keys};
```

Donald also suggest a one-liner in his [blog post](http://donaldh.wtf/2019/09/stones-and-jewels/):

``` Perl6
[+] 'chancellor'.comb(/<[A..Z a..z]>/).Bag{'chocolate'.comb(/<[A..Z a..z]>/).Bag.keys}
```

[Mark Senn](https://github.com/manwar/perlweeklychallenge-club/blob/master/challenge-026/mark-senn/perl6/ch-1.p6) provided not less than four possible solutions: array-based, cross-product-based, hash-based and set-based. Let me illustrate with the cross-product-based solution, which is, IMHO, quite original:

``` Perl6
$count = 0;
(@a X @b).map({$_[0] eq $_[1] and $count++});
$count.say;
```

[Markus Holzer](https://github.com/manwar/perlweeklychallenge-club/blob/master/challenge-026/markus-holzer/perl6/ch-1.p6)'s program is quite uncommon, creative, and clever. He first created a multi `<∈` element-of operator between an iterable and a set that returns a sequence of all elements on the left side (the iterable) that are in the right side (the set):

``` Perl6
multi sub infix:<\<∈>( Iterable $stones, Set $jewels ) returns Seq
{
    # constant runs at BEGIN time, so this work gets only done once
    constant \alphabet = ( 'a' .. 'z', 'A' .. 'Z' ).Set;
    $stones.grep({ $_ ∈ alphabet && $_ ∈ $jewels });
}
```

His program then extends this operator to also work on two iterables and re-uses the previous definition of the operator in this new one:

``` Perl6
multi sub infix:<\<∈>( Iterable $stones, Iterable $jewels ) returns Seq
{
    $stones <∈ $jewels.Set
}
```

Note that, thanks to the `multi`mechanism, the program is able to use the previously defined `<∈` operator between an iterable and a set within the definition of the same operator between two iterables.

And, it finally extends is again to work on two strings. After these definitions, the code to find common letters is incredibly simple:

``` Perl6
say "chancellor" <∈ "chocolates" ).chars;
```

Truly a beautiful use of Perl 6 expressive power.

[Noud](https://github.com/manwar/perlweeklychallenge-club/blob/master/challenge-026/noud/perl6/ch-1.p6) created a `count_abc` subroutine to do the work:

``` Perl6
sub count_abc(Str $stones, Str $jewels) {
    $jewels.comb.grep({$_ (elem) $stones.comb.Set}).elems;
}
```

[Ozzy](https://github.com/manwar/perlweeklychallenge-club/blob/master/challenge-026/ozzy/perl6/ch-1.p6) used a `for` loop to do the heavy work:

``` Perl6for @string1 -> $i {
    $count++ if @string2.grep: { $_ eq $i };
}
```

[Simon Proctor](https://github.com/manwar/perlweeklychallenge-club/blob/master/challenge-026/simon-proctor/perl6/ch-1.p6) used the `SimpleLetters` subset of ASCII upper and lower case letters strings to validate the input. His program then uses the following `MAIN` subroutine:

``` Perl6
multi sub MAIN(
    SimpleLetters $stones, #= String to find letters in
    SimpleLetters $jewels  #= String of letters to look for
) {
    my $stone-set = $stones.comb.Set;
    $jewels.comb.grep( { $_ (elem) $stone-set } ).elems.say;
}
```

[Athanasius](https://github.com/manwar/perlweeklychallenge-club/blob/master/challenge-026/athanasius/perl6/ch-1.p6) provided, as often, a solution a bit too long for quoting here. Most of the work is done in the following `for` loop:

``` Perl6
for $stones.split('').grep( { $ALPHA } ) -> Str $letter
    {
        if %jewels{$letter}:exists
        {
            ++$count;
            @letters.push($letter) if $show;
        }
    }
```

[Jaldhar H. Vyas](https://github.com/manwar/perlweeklychallenge-club/blob/master/challenge-026/jaldhar-h-vyas/perl6/ch-1.sh) provided a Perl 6 one-liner:

    perl6 -e 'my @a = @*ARGS[0].comb ∩ @*ARGS[1].comb; @*ARGS[1].comb.grep({$_ ∈  @a.any }).elems.say;' chancellor chocolate

[Joelle Maslak](https://github.com/manwar/perlweeklychallenge-club/blob/master/challenge-026/joelle-maslak/perl6/ch-1.p6) used a set to find the common letters:

``` Perl6
sub MAIN(Str:D $stones, Str:D $jewels) {
    my $stone-set = $stones.comb.cache;
    my $matches   = $jewels.comb.grep: { $^a ∈ $stone-set };
    say $matches.elems;
}
```
[Roger Bell West](https://github.com/manwar/perlweeklychallenge-club/blob/master/challenge-026/roger-bell-west/perl6/ch-1.p6) used a hash to record the letters of the first string, and then updated a counter to account for letters of the second string found in the aforesaid hash.

[Ruben Westerberg](https://github.com/manwar/perlweeklychallenge-club/blob/master/challenge-026/ruben-westerberg/perl6/ch-1.p6) used a somewhat unexpected methodology to find the letters:

```perl 6
put "Number of letters of Alphabet found in Test: ", $jewels.chars-(S:g/[@stones]// given $jewels).chars;
```

[Yet Ebreo](https://github.com/manwar/perlweeklychallenge-club/blob/master/challenge-026/yet-ebreo/perl6/ch-1.p6) also used an unexpected methodology:

``` Perl6
say ($string2.chars-$string2.trans( $string1 => "").chars);
```

## See Also

Four blog posts this time:

* Arne Sommer: https://perl6.eu/string-angling.html;

* Donald Hunter: http://donaldh.wtf/2019/09/stones-and-jewels/

* Jaldar H. Vyas: https://www.braincells.com/perl/2019/09/perl_weekly_challenge_week_26.html

* Roger Bell West: https://blog.firedrake.org/archive/2019/09/Perl_Weekly_Challenge_26.html

## Wrapping up

Please let me know if I forgot any of the challengers or if you think my explanation of your code misses something important (you can just file an issue against this GitHub page).

If you want to participate to the Perl Weekly Challenge, please connect to [this site](https://perlweeklychallenge.org/).



