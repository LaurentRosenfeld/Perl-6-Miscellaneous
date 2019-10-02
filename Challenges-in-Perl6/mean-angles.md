# Mean Angles

This is derived in part from my [blog post](http://blogs.perl.org/users/laurent_r/2019/09/perl-weekly-challenge-26-common-letters-and-mean-angles.html#_login_JPSV0lQYdfLkWaJ474dLOAvxpoCYAdlVzcbYejEv) made in answer to the [Week 26 of the Perl Weekly Challenge](https://perlweeklychallenge.org/blog/perl-weekly-challenge-026/) organized by  <a href="http://blogs.perl.org/users/mohammad_s_anwar/">Mohammad S. Anwar</a> as well as answers made by others to the same challenge.

The challenge reads as follows:

*Create a script that prints mean angles of the given list of angles in degrees. Please read [wiki page](https://en.wikipedia.org/wiki/Mean_of_circular_quantities) that explains the formula in details with an example.*

In mathematics, a mean of circular quantities is a mean which is sometimes better-suited for quantities like angles, daytimes, and fractional parts of real numbers. This is necessary since most of the usual means may not be appropriate on circular quantities. For example, the arithmetic mean of 0° and 360° is 180°, which is misleading because for most purposes 360° is the same thing as 0°.

A common formula (provided by the Wikipedia article) for the mean of a list of angles is:

​		$\bar{\alpha} = \operatorname{atan2}\left(\frac{1}{n}\sum_{j=1}^n \sin\alpha_j, \frac{1}{n}\sum_{j=1}^n \cos\alpha_j\right)$

We just need to apply the formula, after having converted the input values from degrees to radians.

The Wikipedia page has the following example, that we will use in our tests: consider the following three angles as an example: 10, 20, and 30 degrees. Intuitively, calculating the mean would involve adding these three angles together and dividing by 3, in this case indeed resulting in a correct mean angle of 20 degrees. By rotating this system anticlockwise through 15 degrees the three angles become 355 degrees, 5 degrees and 15 degrees. The naïve mean is now 125 degrees, which is the wrong answer, as it should be 5 degrees.

There are modules that could be used: for example, the Perl 6 [Math::Trig](https://github.com/perlpilot/p6-Math-Trig) module supplies `rad2deg` and `deg2rad` functions that could be used here to convert degrees to radians and radians to degrees. There may be others to compute arithmetic means and perhaps even to compute directly mean angles. But that wouldn't be a challenge if we were just using modules to dodge the real work.

So I wrote the trivial `deg2rad` and `rad2deg` subroutines to do the angle unit conversions (it turns out that my subroutines are very similar to the functions provided by `Math::Trig`, but I had not looked at that module when I wrote my own subroutines), and computed the arithmetic means of sines and cosines using the `[+]` reduction metaoperator with the `+`operator. Despite what I said about modules, I'll be using the `Test` module to provide a clean framework for our tests. Or course, most of the tests used below would probably not have been necessary if I had used the the `deg2rad` and `rad2deg` functions provided by the `Math::Trig` module, since it can probably be assumed that they have been thoroughly tested already.

``` Perl6
use v6;
use Test;

sub deg2rad (Numeric $deg) { return $deg * pi /180; }
sub rad2deg (Numeric $rad) { return $rad * 180 / pi }

sub mean (*@degrees) {
    my @radians = map { deg2rad $_ }, @degrees;
    my $count = @radians.elems;
    my $avg-sin = ([+] @radians.map( {sin $_})) / $count; 
    my $avg-cos = ([+] @radians.map( {cos $_})) / $count; 
    return rad2deg atan2 $avg-sin, $avg-cos;
}
plan 9;
is deg2rad(0), 0, "To rad: 0 degree";
is deg2rad(90), pi/2, "To rad: 90 degrees";
is deg2rad(180), pi, "To rad: 180 degrees";
is rad2deg(pi/2), 90, "To degrees: 90 degrees";
is rad2deg(pi), 180, "To degrees: 180 degrees";
is deg2rad(rad2deg(pi)), pi, "Roundtrip rad -> deg -> rad";
is rad2deg(deg2rad(90)), 90, "Roundtrip deg -> rad -> deg";
is-approx mean(10, 20, 30), 20, "Mean of 10, 20, 30 degrees";
is-approx mean(355, 5, 15), 5, "Mean of 355, 5, 15 degrees";
```

And this is the output produced when running the script:

    perl6  angle-mean.p6
    1..9
    ok 1 - To rad: 0 degree
    ok 2 - To rad: 90 degrees
    ok 3 - To rad: 180 degrees
    ok 4 - To degrees: 90 degrees
    ok 5 - To degrees: 180 degrees
    ok 6 - Roundtrip rad -> deg -> rad
    ok 7 - Roundtrip deg -> rad -> deg
    ok 8 - Mean of 10, 20, 30 degrees
    ok 9 - Mean of 355, 5, 15 degrees

Note that I had to use the `is-approx` function of the Test module for tests computing the mean because I would otherwise get failed tests due to rounding issues when using simply `is`:

    # Failed test 'Mean of 10, 20, 30 degrees'
    # at angle-mean.p6 line 22
    # expected: '20'
    #      got: '19.999999999999996'
    not ok 9 - Mean of 355, 5, 15 degrees

As you can see, the program computes 19.999999999999996, where I expect 20, which is nearly the same numeric value, but the test fails if using `is`. It works fine with the `is-approx` function.

In some cases, we may end up with a negative value for the mean angle. In this case, we may want to convert it to a positive value by adding 360° to it, but it did not seem to me that it is really necessary. It probably depends on what you want to do with the mean angle value afterward.

When I posted my original blog post with the code above, *Saif* rightly commented that we don't really need to divide both arguments of the `atan2` built-in function by the number of angles. These arguments represent the abscissa and the ordinate of a point in the plan. Whether the two Cartesian coordinates are divided by `count` or not does not change the resulting polar angle calculated by the `atan2` function with the sums of sines and cosines.  In other words, the Wikipedia formula above could actually be simplified to:

​		$\bar{\alpha} = \operatorname{atan2}\left(\sum_{j=1}^n \sin\alpha_j, \sum_{j=1}^n \cos\alpha_j\right)$

Concretely, we don't need to perform this division and we don't even need the `$count` variable. The `mean` subroutine can be simplified as follows:

``` Perl6
sub mean (*@degrees) {
    my @radians = map { deg2rad $_ }, @degrees;
    my $sum-sin = [+] @radians.map( {sin $_}); 
    my $sum-cos = [+] @radians.map( {cos $_}); 
    return rad2deg atan2 $sum-sin, $sum-cos;
}
```

Actually, this `mean` subroutine is becoming so simple that it could fit on a single code-line:

``` Perl6
sub mean (*@angles) {
    rad2deg atan2 ([+] @angles.map({sin deg2rad $_})), [+] @angles.map({cos deg2rad $_});
}
```
Or, using the `sum` method rather than `[+]` to avoid precedence issues which led me to add parentheses in the code just above:

``` Perl6
sub mean (*@angles) {
    rad2deg atan2 @angles.map({sin deg2rad $_}).sum, @angles.map({cos deg2rad $_}).sum;
}
```

With these changes, the program displays the same test results as before.

Using the Perl 6 [Math::Trig](https://github.com/perlpilot/p6-Math-Trig) module, the whole program could boil down to about ten code lines (including the tests):

``` Perl6
use v6;
use Test;
use Math::Trig;

sub mean (*@angles) {
    rad2deg atan2 @angles.map( {sin deg2rad $_}).sum, @angles.map( {cos deg2rad $_}).sum;
}
plan 2;
is-approx mean(10, 20, 30), 20, "Mean of 10, 20, 30 degrees";
is-approx mean(355, 5, 15), 5, "Mean of 355, 5, 15 degrees";
```

## Alternate Solutions

[Arne Sommer](https://github.com/manwar/perlweeklychallenge-club/blob/master/challenge-026/arne-sommer/perl6/ch-2.p6) used essentially the same ideas, but with a slightly different route:

``` Perl6
my \n    = @angles.elems;
my @rad  = @angles.map(* * pi / 180);
my \s    = @rad.map(*.sin).sum / n;
my \c    = @rad.map(*.cos).sum / n;
my $mean = atan2( s / c ) * 180 / pi;

if    c < 0 { $mean += 180; }
elsif s < 0 { $mean += 360; }
```

[Mark Senn](https://github.com/manwar/perlweeklychallenge-club/blob/master/challenge-026/mark-senn/perl6/ch-2.p6) first uses the hyperoperator (rather than a `map`) to convert the list of degree values into radians:

``` Perl6
my @rad = @deg  <<*>> (pi /180);
```
His program then uses complex numbers arithmetic to do the conversion and computations:

``` Perl6
my  Complex  @z = @rad.map({e**(i *$_)});
my $p -bar = ([+] @z) / @z.elems;
my $theta -bar = atan2($p -bar.im ,$p -bar.re) * (180/pi);
$theta -bar.say;
```

[Markus Holzer](https://github.com/manwar/perlweeklychallenge-club/blob/master/challenge-026/markus-holzer/perl6/ch-2.p6), a new challenger this week, first created a `°` postfix operator to convert degrees to radians:

```Perl6
Multi sub postfix:<°>( Numeric $degrees ) returns Real { $degrees * π / 180 }
```

His program then calls the following subroutine, also using hyperoperators, to compute the mean:

``` Perl6
sub mean-angle( *@α ) returns Real
{
    # Neiter inv, nor ρ will ever change, so we can define them as immutable
    my \inv = 1 / @α.elems;
    my \ρ = atan2(
        (inv * [+] @α>>.sin), # calculate the sine of all angles, sum the result and multiply that with the factor
        (inv * [+] @α>>.cos)  # same, but with cosine
    );

    ρ > 0
        ?? ρ         # We always want a positive value
        !! ρ + 2 * π # When it isn't, we add 360°
}
```
[Noud](https://github.com/manwar/perlweeklychallenge-club/blob/master/challenge-026/noud/perl6/ch-2.p6) first defined an arithmetic mean subroutine:

``` Perl6
sub mean(@array) {
    @array.sum / @array.elems;
}
```

His program then uses this `mean` subroutine to compute mean of circular quantities in three different ways: using `atan2` (similar to other solutions seen previously), complex numbers, or modulo over the circle. For example:

``` Perl6
# Mean of circular quantities using complex numbers.
sub mean_angle2(@angles) {
    my $z = mean(@angles.map({ exp(i * $_) }));
    atan($z.im / $z.re);
}
# Mean of circular quantities using modulo over the circle
sub mean_angle3(@angles) {
    mean(@angles.map({ ($_ + pi) % (2 * pi) - pi }));
}
```

[Simon Proctor](https://github.com/manwar/perlweeklychallenge-club/blob/master/challenge-026/ozzy/perl6/ch-2.p6) defined a `deg2rad` and a `rad2deg` *constants* to be multiplied by the input value to perform conversions. His program then uses the `[+]` reduction operator to compute the sum of sines and cosines.

``` Perl6
sub MAIN (*@ang_deg where .elems > 0) {

    my constant \deg2rad = (pi/180);
    my constant \rad2deg = (180/pi);

    my $y = [+] map { ($_ * deg2rad).sin }, @ang_deg;
    my $x = [+] map { ($_ * deg2rad).cos }, @ang_deg;

    printf "Mean angle = %.2f degrees\n", (atan2($y,$x) * rad2deg);
}
```

[Athanasius](https://github.com/manwar/perlweeklychallenge-club/blob/master/challenge-026/athanasius/perl6/ch-2.p6) again suggested a very elaborate program far too long for reproducing here. Let me just quote the main subroutine with its `for` loop to compute the sums of sines and cosines:

``` Perl6
sub find-circular-mean(*@angles --> Real:D)
{
    my Real $sum-of-sines   = 0;
    my Real $sum-of-cosines = 0;

    for @angles -> Real $degrees
    {
        my Real $radians = $degrees * (π / 180);
        $sum-of-sines   += $radians.sin;              # build ∑ [j=1..n] sin α_j
        $sum-of-cosines += $radians.cos;              # build ∑ [j=1..n] cos α_j
    }
    my UInt $n = @angles.elems;
    return ($sum-of-sines / $n).atan2($sum-of-cosines / $n) * (180 / π);
}
```

[Jandhar H. Vyas](https://github.com/manwar/perlweeklychallenge-club/blob/master/challenge-026/jaldhar-h-vyas/perl6/ch-2.p6) defined `deg2rad` and `rad2deg` subroutine similar to mines. His program then builds the sum of sines and sum of cosines in a `for` loop:

```Perl 6
multi sub MAIN(*@ARGS) {
    my $sines = 0;
    my $cosines = 0;

    for @*ARGS -> $angle {
        $sines += sin deg2rad($angle);
        $cosines += cos deg2rad($angle);
    }

    $sines /= @*ARGS.elems;
    $cosines /= @*ARGS.elems;

    say rad2deg(atan2 $sines, $cosines).round;
}
```

[Joelle Maslak](https://github.com/manwar/perlweeklychallenge-club/blob/master/challenge-026/joelle-maslak/perl6/ch-2.p6) also used a `for` loop to convert degrees to radians and compute the sums of the sines and cosines. 

``` Perl6
for @angles -> $angle {
    my $rad = ($angle % 360) * π / 180;
    $x += cos($rad);
    $y += sin($rad);
}
```

Her program then computes the arctangent (one-argument `atan` built-in function) of the sums of sines divided by the sum of cosines and converts the obtained radian value back to degrees. Finally, the program adds 180 to the degree value if the sums of sines and cosines are of opposite signs, and adds 360 degrees if they are both negative.

[Roger Bell West](https://github.com/manwar/perlweeklychallenge-club/blob/master/challenge-026/roger-bell-west/perl6/ch-2.p6) used a `for` loop similar to Joelle's to compute the sums of sins and cosines and then computed the arctangent (two-argument `atan2`) of the sums of sines divided by the sum of cosines and converted the obtained radian value back to degrees.

``` Perl6
my ($s,$c,$n)=(0,0,0);
for @*ARGS -> $angle {
  my $aa=$angle*pi/180;
  $s+=sin($aa);
  $c+=cos($aa);
  $n++;
}
my $oa=atan2($s/$n,$c/$n);
say $oa*180/pi;
```

[Yet Ebreo](https://github.com/manwar/perlweeklychallenge-club/blob/master/challenge-026/yet-ebreo/perl6/ch-2.p6) also used a `for` loop to compute the sums of sines and cosines and then used the arctangent (two-argument `atan2`) of the sums of sines divided by the sum of cosines and converted the obtained radian value back to degrees.

``` Perl6
for @angles -> $r {
    $y += sin($r*π/180);
    $x += cos($r*π/180)
}
say atan2($y,$x)*180/π
```

[Ruben Westerberg](https://github.com/manwar/perlweeklychallenge-club/blob/master/challenge-026/ruben-westerberg/perl6/ch-2.p6) used a method more similar to mine, using `map` and `[+]`:

``` Perl6
my $avgCos= ( [+] @angles.map({($_*pi/180).cos}))/@angles;
my $avgSin= ( [+] @angles.map({($_*pi/180).sin}))/@angles;
my $avg=atan2($avgSin,$avgCos)*180/pi;
$avg+=360 if $avg < 0;
```

## See Also

Three blog posts this time:

* Arne Sommer: https://perl6.eu/string-angling.html;

* Jaldar H. Vyas: https://www.braincells.com/perl/2019/09/perl_weekly_challenge_week_26.html;

* Roger Bell West: https://blog.firedrake.org/archive/2019/09/Perl_Weekly_Challenge_26.html.

## Wrapping up

Please let me know if I forgot any of the challengers or if you think my explanation of your code misses something important (you can just file an issue against this GitHub page).

If you want to participate to the Perl Weekly Challenge, please connect to [this site](https://perlweeklychallenge.org/).

