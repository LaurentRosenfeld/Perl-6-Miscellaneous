# Illegal Division by Zero


This is derived in part from my [blog post](http://blogs.perl.org/users/laurent_r/2019/10/perl-weekly-challenge-31-illegal-division-by-zero-and-dynamic-variables.html) made in answer to the [Week 31 of the Perl Weekly Challenge](https://perlweeklychallenge.org/blog/perl-weekly-challenge-031/) organized by  <a href="http://blogs.perl.org/users/mohammad_s_anwar/">Mohammad S. Anwar</a> as well as answers made by others to the same challenge.

The challenge reads as follows:

*Create a function to check divide by zero error without checking if the denominator is zero.*

## My Solution

Perl 6/Raku has very rich [error handling features](https://docs.perl6.org/language/exceptions), most notably the [Exception class](https://docs.perl6.org/type/Exception). Without going into all the lengthy details, let us say that it's possible to handle exceptional circumstances by supplying a `CATCH` block. To solve the challenge can be as simple as this:

``` Perl6
use v6;

sub MAIN (Numeric $numerator, Numeric $denominator) {
    say "Result of division is: ", $numerator / $denominator;
    CATCH {
        say $*ERR: "Something went wrong here: ", .Str;
        exit; 
    }
}
```

Using this script first with legal parameters and then with an illegal 0 denominator produces the following output:

    $ perl6 try-catch.p6  8 4
    Result of division is: 2
    
    $ perl6 try-catch.p6  8 0
    Something went wrong here: Attempt to divide by zero when coercing Rational to Str

An exception object is usually contained in the `$!` special variable, but a `CATCH` block topicalizes the exception object, meaning that it becomes available in the `$_` topical variable (hence the `.Str` syntax above is sufficient to obtain the description of the exception).

Although it is not really needed here, it may sometimes be useful to define the scope of the `CATCH` block by enclosing it in a `try` block, for example:

``` Perl6
use v6;

sub MAIN (Numeric $numerator, Numeric $denominator) {
    try {
        say "Result of division is: ", $numerator / $denominator;
        CATCH {
            say $*ERR: "Something went wrong here: ", .Str;
            exit; 
        }
    }
}
```

Actually, defining a `try` block (it doesn't really have to be a block, a simple statement will also work) creates an implicit `CATCH` block, and this may be used to contain the exception:

``` Perl6
use v6;

sub MAIN (Numeric $numerator, Numeric $denominator) {
    try {
        say "Result of division is: ", $numerator / $denominator;
    }
}
```

The above program does not die and doesn't print anything but exits normally (with the successful exit code, 0, on Unix-like systems) when you pass a zero value for the denominator. We're in effect silencing the exception. Even if you don't want to abort the program when encountering such an error, you might still prefer to tell the user that something went wrong with a message containing the description of the caught exception:

``` Perl6
use v6;

sub MAIN (Numeric $numerator, Numeric $denominator) {
    try {
        say "Result of division is: ", $numerator / $denominator;
    } or say "Houston, we've had a problem here: ",  $!.Str;
}
```

which outputs the following:

    $ perl6 try-catch.p6  8 4
    Result of division is: 2
    
    $ perl6 try-catch.p6  8 0
    Houston, we've had a problem here: Attempt to divide by zero when coercing Rational to Str

## Alternative Solutions

[Arne Sommer](https://github.com/manwar/perlweeklychallenge-club/blob/master/challenge-031/arne-sommer/perl6/ch-1.p6) used a `try` [statement prefix](https://docs.perl6.org/language/statement-prefixes#index-entry-try_(statement_prefix)-try) to catch any error in the division. 

``` Perl6
unit sub MAIN (Numeric $a = 10, Numeric $b = 0);
my $c = $a / $b;
try say "a/b = $c";
say "Division by zero detected." if $!;
```

Arne's program works well in its own context. However, this may be nitpicking, but the error detected by `try` could be something else than a division by zero, for example a non-numerical argument to the division. Consider this test under the REPL:

    > try say 10 / "b";
    Nil
    > say $!
    Cannot convert string to number: base-10 number must begin with valid digits or '.' in '<HERE>b' (indicated by <HERE>)
      in block <unit> at <unknown file> line 2

The fact that `$!` is populated doesn't necessarily mean that the problem was a division by zero. So, it might be wise to check the content of `$_`.

[Kevin Colyer](https://github.com/manwar/perlweeklychallenge-club/blob/master/challenge-031/kevin-colyer/perl6/ch-1.p6) use a `try` block, but apparently did not succeed to get an exception with a simple division by zero such as `my $c = 1/0;` computation and therefore had to use a trick such as `"{$a/$b}"`:

``` Perl6
sub Is_DivByZero($a,$b){
    my Bool $result=False;
    my $misc;
    try {    $misc= "{$a/$b}" ; } ; # NOTE why does $misc = $a/$b not throw an exception! ????????????
    if $! {
        $result= True;
        # say "$a / $b failed with " ~ $!.^name
    }
    return $result;
}
```

Let me try to answer Kevin's interrogation. I have read in the past somewhere in the documentation an explanation about why `my $c = 1/0;` doesn't throw an exception immediately, but only when one tries to use `$c` is used, but can no longer find it right now. Let me try to explain what I understood at the time. From what I remember, the idea is that there is no reason to throw an exception just because you compute an illegal value, but that the exception should be raised only when you try to use that illegal value. The `my $c = 1/0;` leads only to a [Failure](https://docs.perl6.org/type/Failure), i.e. a *soft* or *unthrown* exception.  In other words, we could say that `my $c = 1/0` sort of throws a lazy exception that doesn't become real until you use that `$c` illegal value. I can understand the idea behind this, although I'm not entirely convinced that it is better to postpone the moment the exception is raised, but so it is. Anyway, the idea here is that Kevin gets the exception only when he tries to convert the result of the division by zero computation into a string.

[Mark Senn](https://github.com/manwar/perlweeklychallenge-club/blob/master/challenge-031/mark-senn/perl6/ch-1.p6) provided three possible solutions:

``` Perl6
sub div1($a, $b) {
    my $c = $a / $b;
    return $c  //  Inf;
}

sub div2($a, $b) {
    my $c = $a / $b;  
    ($c == Inf)  and  fail '/0 or other problem';
    return $c;
}

sub div3($a, $b) {
    my $c;
    try {
        CATCH {
            when (X::Numeric::DivideByZero)  { return '  /0 or other problem'; }
        }
        $c = $a / $b;
    }
    return "  $c";
}

sub MAIN() {
    my $n = 10;
    print 'div1:';
    for (0,2) -> $d {
        my $c = div1($n, $d);
        ($c == Inf)
            ??  '  /0 or other problem'.print
            !!  "  $c".say;
    }
    print 'div2:';
    for (0,2) -> $d {
        with div2($n, $d) -> $c {
            "  $c".say;
        }  else  {
            "  {.exception.message}".print;
        }
    }
    print 'div3:';
    for (0,2) -> $d {
        # This won't work without using ".Num".
        my $c = div3($n.Num, $d.Num);
        $c.print;
    }
    ''.say;
}
```

[Markus Holzer](https://github.com/manwar/perlweeklychallenge-club/blob/master/challenge-031/markus-holzer/perl6/ch-1.p6) suggested a two-line script:

``` Perl6
say "Division by zero" without try ( 1/0 ).Str;
say "Division is okay" with try ( 1/1 ).Str;
```

The first line outputs a "Division by zero" error and the second one doesn't, as expected. But I still don't really understand what Markus tried to prove with that.

[Noud](https://github.com/manwar/perlweeklychallenge-club/blob/master/challenge-031/noud/perl6/ch-1.p6) suggested a [stereographic projection](https://en.wikipedia.org/wiki/Stereographic_projection) (on a complex sphere) where a division by zero is not an error (a division by zero produces the North Pole of the complex sphere). Please follow the link to understand Noud's idea.

``` Perl6
sub infix:<%/>($x, $y) {
    my $z = Complex.new($x * $y / ($x**2 + $y**2), $x**2 / ($x**2 + $y**2));
    if ($z === i) {
        # If z is the north pole, the inverse stereographic projection is
        # not a number. (this is actually the perl weekly challenge)
        NaN;
    } else {
        # For fun, use the inverse stereographic projection to compute x / y.
        $z.re / (1 - $z.im);
    }
}
```

[Simon Proctor](https://github.com/manwar/perlweeklychallenge-club/blob/master/challenge-031/simon-proctor/perl6/ch-1.p6) suggested a `safe-division` subroutine:

``` Perl6
sub safe-division( Numeric $nu, Numeric $de ) {
    try {
        ($nu/$de).Str();
        return True;
    }
    return False;
}
```

[Tyler Limkemann](https://github.com/manwar/perlweeklychallenge-club/blob/master/challenge-031/tyler-limkemann/perl6/ch-1.p6), a new member of the team, suggested this very simple solution:

``` Perl6
CATCH { default { "can't divide by 0!".say } }
(1/0).say;
```

[Athanasius](https://github.com/manwar/perlweeklychallenge-club/blob/master/challenge-031/athanasius/perl6/ch-1.p6) provided, as usual, a somewhat verbose solution using a `try`block:

``` Perl6
my Real constant $DEFAULT-DIVIDEND = 1;
my Real constant $DEFAULT-DIVISOR  = 0;

sub MAIN
(
    Real:D $dividend = $DEFAULT-DIVIDEND,
    Real:D $divisor  = $DEFAULT-DIVISOR,
)
{
    try
    {
        my Real $quotient = $dividend / $divisor;

        "$dividend / $divisor = $quotient".say;
    }

    if $!
    {
        if $! ~~ rx/ ^ Attempt \s to \s divide .+ by \s zero /
        {
            "$dividend / $divisor = DIVIDE BY ZERO ERROR".say;
        }
        else
        {
            $!.throw;
        }
    }

    "\nNormal exit".say;
}
```

[Jaldhar H. Vyas](https://github.com/manwar/perlweeklychallenge-club/blob/master/challenge-031/jaldhar-h-vyas/perl6/ch-1.p6) created a `isDividedByZero` subroutine to handle exception conditions with a `CATCH` block:

``` Perl6
sub isDividedByZero($numerator, $denominator) {
        ($numerator / $denominator).grep({});
        CATCH {
            default {
                return True;
            }
        }
    return False;
}
```
[Javier Luque](https://github.com/manwar/perlweeklychallenge-club/blob/master/challenge-031/javier-luque/perl6/ch-1.p6), another new member of the team, used a `try` block with an embedded `CATCH` block: 

``` Perl6
sub divide-by-zero-check(Str $statement) {
    try {
        my $answer = Rat($statement);
        say $answer;
        CATCH {
            default { say "divide by 0 error, $_" }
        }
    }
}
```

[Joelle Maslak](https://github.com/manwar/perlweeklychallenge-club/blob/master/challenge-031/joelle-maslak/perl6/ch-1.p6) used a `CATCH` block specifying the `X::Numeric::DivideByZero` exception, so that her program will pick only that error and no other:

``` Perl6
sub MAIN($numerator, $denominator) {
    if test-for-div-by-zero($numerator, $denominator) {
        say "Denominator is zero";
    } else {
        say "Denominator is not zero";
    }
}
sub test-for-div-by-zero($numerator, $denominator) {
    ($numerator / $denominator).Int.sink;
    return; # Not div by zero
    CATCH {
        when X::Numeric::DivideByZero {
            return 1; # Div by zero
        }
    }
}
```

[Ruben Westerberg](https://github.com/manwar/perlweeklychallenge-club/blob/master/challenge-031/ruben-westerberg/perl6/ch-1.p6) used a `try` statement prefix and tested the value of the `$!` error variable populated by `try` when it catches an exception:

``` Perl6
my $numerator=@*ARGS[0]//1;
my $denominator=@*ARGS[1]//0;
my $result;

try $result=($numerator/$denominator).Str;

put "Division ok: $numerator/$denominator = $result" unless $!;
put "Division failed: Divide by zero" if $!;
```

[Yet Ebreo](https://github.com/manwar/perlweeklychallenge-club/blob/master/challenge-031/yet-ebreo/perl6/ch-1.p6) created a `div_zero_check` subroutine using a `try` block and testing the `$!` error variable (pretty much like like Ruben):

``` Perl6
sub div_zero_check ($n, $d) {
    my $r;
    try {
        $r = $n / $d;       
        #Error is not raised when the result of division is not used
        say $r;
    }
    $! && say "Division by zero detected";
}
```

## See Also

Three blog posts this time:

* Arne Sommer: https://raku-musings.com/dynamic-zero.html;

* Jaldhar H. Vyas: https://www.braincells.com/perl/2019/10/perl_weekly_challenge_week_31.html;

* Javier Luque: https://perlchallenges.wordpress.com/2019/10/24/perl-weekly-challenge-031/.


## Wrapping up

Please let me know if I forgot any of the challengers or if you think my explanation of your code misses something important (send me an e-mail or just raise an issue against this GitHub page).

