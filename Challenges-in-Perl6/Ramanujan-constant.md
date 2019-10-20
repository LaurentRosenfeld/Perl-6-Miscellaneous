# Ramanujan's Constant

This is derived in part from my [blog post](http://blogs.perl.org/users/laurent_r/2019/05/perl-weekly-challenge-6-ramanujans-constant.html) made in answer to the [Week 06 of the Perl Weekly Challenge](https://perlweeklychallenge.org/blog/perl-weekly-challenge-006/) organized by  <a href="http://blogs.perl.org/users/mohammad_s_anwar/">Mohammad S. Anwar</a> as well as answers made by others to the same challenge.

The challenge reads as follows:

*Create a script to calculate Ramanujan’s constant with at least 32 digits of precision. Find out more about it here (Wikipedia link).*

## My Solutions

The Wikipedia link provided in the question concerning this challenge was apparently changed some time after the challenge was initially posted. 

The original link, posted on Monday, April 29, 2019, was pointing to the [Landau-Ramanujan Constant](https://en.wikipedia.org/wiki/Landau%E2%80%93Ramanujan_constant), which relates to the sum of two squares theorem.

Then, two days later, on May 1, 2019, I noticed that the link had changed and pointed towards this other [Wikipedia page about Ramanujan's constant](https://en.wikipedia.org/wiki/Heegner_number#Almost_integers_and_Ramanujan's_constant), which refers to irrational (well, in this case, actually transcendental) numbers that almost look like integers.

I guess that my good friend Mohammad Anwar got carried away when writing the challenge because it related to one of his most famous fellow citizens, Indian mathematician [Srinivasa Ramanujan (1887-1920)](https://en.wikipedia.org/wiki/Srinivasa_Ramanujan). If you've never heard about Ramanujan or don't know much about him, please visit the Wikipedia article just mentioned and search further on the Internet; he is, despite a limited access to other mathematicians of the time for a large part of his very short life, one of the greatest mathematicians of the early twentieth century. 

Here, I'll cover only the updated challenge, please refer to my other blog post linked above if you want to find out more about the Landau-Ramanujan Constant.


What has become known as the Ramanujan Constant in the recent period is a number that is an "almost integer" and has in fact little to do with mathematician Srinivasa Ramanujan.

This number is the following one:

![Ramanujan's Constant](./figures/Ramanujan_3.gif)

As you can see, there are twelve 9 digits after the decimal point, so that this number, which is built from a formula involving exponentials on one algebraic and two transcendental numbers, almost looks like an integer (when rounded to less than 12 digits after the decimal point). 

The number in question had been discovered by mathematician Charles Hermitte in 1859, more than 25 years before Ramanujan’s birth.

The reason why it has become known as Ramanujan’s constant is that, in 1975, "recreational mathematics" columnist Martin Gardner published in *Scientific American* an April fool article where he claimed that said number, calculated from algebraic and transcendental numbers, was in fact an integer, and further claimed that Ramanujan has already discovered that in the early twentieth century. This was just a joke, as this number is transcendental, but is an impressively close approximation of an integer. At the time, computers were not able to compute this number with enough accuracy to disprove Gardner's assertion. Following that, people have started to call this number Ramanujan’s constant (Ramanujan worked on a number of similar numbers and probably also on this one, but there is no evidence that he discovered anything significantly new on that specific number).

The [Wikipedia page on Ramanujan's constant](https://en.wikipedia.org/wiki/Heegner_number#Almost_integers_and_Ramanujan's_constant) and the formula given earlier in this post show that the integer part of this constant is equal to `640_320 ** 3 + 744` (i.e. 262537412640768744). The Wikipedia article further explains that the difference between this number and Ramanujan's constant is given by:

![](.\Figures\Ramanujan_4.gif)

So we just need to apply this approximate formula. Let's do it under the Rakudo REPL:

    > my $a = 640_320 ** 3 + 744; # $a is the integer approximation of R's constant
    262537412640768744
    > my $r-constant = $a - 196844 / $a;
    262537412640768743.999999999999250225
    > say $r-constant.fmt("%.33s");
    262537412640768743.99999999999925

Note that we are a bit lucky: the value obtained for `$r-constant` has an accuracy of 33 digits, and we only need 32. Using the `FatRat` type (instead of the implicit `Rat` type used above) does not improve accuracy, it is the math formula that is an approximation of Ramanujan’s constant.

## Alternative Solutions

Only five challengers contributed to this challenge.

[Arne Sommer](https://github.com/manwar/perlweeklychallenge-club/blob/master/challenge-006/arne-sommer/perl6/ch-2.p6) suggested the following program:

``` Perl6
sub FatRatRoot (Int $int where $int > 0, :$precision = 10)
{
  my @x =
    FatRat.new(1, 1),
    -> $x { $x - ($x ** 2 - $int) / (2 * $x) } ... *;

  return @x[$precision];
}
say $e ** ($pi * FatRatRoot(163));
```

I wasn't able to run it, because `$e` and `$pi` are not declared. Changing the last code line to this:

``` Perl6
say e ** (pi * FatRatRoot(163));
```
makes the program runnable, but still doesn't really produce any result with a 32-digit accuracy:

    2.625374126407677e+17

[Jaldhar H. Vyas](https://github.com/manwar/perlweeklychallenge-club/blob/master/challenge-006/jaldhar-h-vyas/perl6/ch-2.p6) started by trying essentially the same formula as the one just above:

``` Perl6
constant RAMANUJAN = 𝑒 ** (π * sqrt(163));
```
but found out that doesn't work and produces the same floating point approximation as Arne's program above. So Jaldhar admits that he decided to cheat a little bit and reuse his Perl 5 program:

``` Perl6
shell('../perl5/ch-2.pl');
```

[Joelle Maslak](https://github.com/manwar/perlweeklychallenge-club/blob/master/challenge-006/joelle-maslak/perl6/ch-2.p6) used the same approximation formula as my solution and also obtained 33 accurate digits (262537412640768743.999999999999250):

``` Perl6
say (640320³ + 744 - 196844.FatRat/(640320³ + 744)).Str.substr(0,34);
```

[Ruben Westerberg](https://github.com/manwar/perlweeklychallenge-club/blob/master/challenge-006/ruben-westerberg/perl6/ch-2.p6) implemented a `FatRat` factorial subroutine, a `FatRat` square root subroutine using the Newton-Raphson method, and a `FatRat` Taylor series exponential subroutine, and also hard-coded pi to 100 digits. Having done all this, he was able to write a version the original formula producing an accurate result:

``` Perl6
my $bigPi=FatRat.new(31415926535897932384626433832795028841971693993751058209749445923078164062862089986280348253421170679,10**100);

sub factorial($n) {
	constant @f= (1.FatRat, |[\*] 1.FatRat..*);
	@f[$n];
}
sub taylor-e ($atVal) {

	my $sum=0.FatRat;
	my $x=$atVal.FatRat;
	for 0..200 {
		 $sum+=($x**$_)/factorial($_);
		 say "Iteration $_: " ~ $sum.Str.substr(0,50);
	}
	$sum;
}

sub newton-sqrt($val, $target, $repeat){
	my $guess=$val.FatRat;
	for ^$repeat {
		$guess:=($guess - ($guess**2 -$target)/(2*$guess));
	}
	$guess;
}
say taylor-e($bigPi*newton-sqrt(10,163,6)).Str.substr(0,50);
```

which produces the right result after slightly more than 130 iterations:

    Iteration 132: 262537412640768743.9999999999990867965865161656471
    Iteration 133: 262537412640768743.9999999999992013528229697101850
    Iteration 134: 262537412640768743.9999999999992356420435776175716
    Iteration 135: 262537412640768743.9999999999992458295411941064733
    Iteration 136: 262537412640768743.9999999999992488340417359006698
    Iteration 137: 262537412640768743.9999999999992497136623415158025
    Iteration 138: 262537412640768743.9999999999992499693206922282684
    Iteration 139: 262537412640768743.9999999999992500430922335835121
    Iteration 140: 262537412640768743.9999999999992500642273428172645

[Tim Smith](https://github.com/manwar/perlweeklychallenge-club/blob/master/challenge-006/tim-smith/perl6/ch-2.p6) used the same approximation as Joelle Maslak and myself:

``` Perl6

# Ramanujan's constant is _almost_ this integer ...
my $r = 640_320 ** 3 + 744;

# But is off by an error which is defined in terms of the constant itself,
# so this approximation is close enough for at least 32 significant digits.
$r += FatRat.new: -196_844, $r;

put substr($r, 0, 33);
```

## See also

As far as I can say, there was only one blog post on this (in addition to mine):

* Arne Sommer: https://perl6.eu/int-erval.html

## Wrapping up

Please let me know if I forgot any of the challengers or if you think my explanation of your code misses something important (send me an e-mail or just raise an issue against this GitHub page).


