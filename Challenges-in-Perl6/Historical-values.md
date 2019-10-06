# Displaying Historical Values

This is derived in part from my [blog post](http://blogs.perl.org/users/laurent_r/2019/09/perl-weekly-challenge-27-intersection-point-and-historical-values.html) made in answer to the [Week 27 of the Perl Weekly Challenge](https://perlweeklychallenge.org/blog/perl-weekly-challenge-027/) organized by  <a href="http://blogs.perl.org/users/mohammad_s_anwar/">Mohammad S. Anwar</a> as well as answers made by others to the same challenge.

The challenge reads as follows:

*Write a script that allows you to capture/display historical data. It could be an object or a scalar. For example:*

> *my $x = 10; $x = 20; $x -= 5;*

*After the above operations, it should list $x historical value in order.*

## My Solution

I was very busy during the week of that challenge and was running out of time. Therefore my answers were somewhat minimalist.

I initially tried to redefine the `=` assignment operator but that appears to be impossible:

    Cannot override infix operator '=', as it is a special form handled directly by the compiler

So, I decided to create my own `=:=` assignment operator for watched variables. Besides that, the program uses the `WatchedValue` class to enable the storing of current and past values.

``` Perl6
use v6;

class WatchedValue {
    has Int $.current-value is rw;
    has @.past-values = ();

    method get-past-values {
        return @.past-values;
    }
}

multi sub infix:<=:=> (WatchedValue $y, Int $z) {
    push $y.past-values, $y.current-value;
    $y.current-value = $z;
}
my $x = WatchedValue.new(current-value => 10);
say "Current: ", $x.current-value;
$x =:= 15;
say "Current: ", $x.current-value;
$x =:= 5;
say "Current: ", $x.current-value;
$x =:= 20;
say "Current: ", $x.current-value;
say "Past values: ", $x.get-past-values;
```

When running the program; I get warnings for each assignment:

    Useless use of "=:=" in expression "$x =:= 15" in sink context (line 18)

I do not know how to avoid or suppress these warnings (it seems that the `no warnings ...` pragma isn't implemented yet), but the program otherwise runs correctly and displays the successive values:

    Current: 10
    Current: 15
    Current: 5
    Current: 20
    Past values: [10 15 5]

## Alternate solutions

All challengers except Noud and Yet Ebreo used objects of the built-in [Proxy](https://docs.perl6.org/type/Proxy) class, which I did not know about before. According to the P6 documentation, a proxy is an object that allows you to set a hook that executes whenever a value is retrieved from a container (`FETCH`) or when it is set (`STORE`). This is quite obviously the right tool for solving the task at hand. This is the example provided in the official Perl 6 documentation to create a container that returns twice what was stored in it:

``` Perl6
sub double() is rw {
    my $storage = 0;
    Proxy.new(
        FETCH => method ()     { $storage * 2    },
        STORE => method ($new) { $storage = $new },
    )
 }
 my $doubled := double();
 $doubled = 4;
 say $doubled;       # OUTPUT: «8␤»
 ```
 

[Arne Sommer](https://github.com/manwar/perlweeklychallenge-club/blob/master/challenge-027/arne-sommer/perl6/ch-2.p6)'s program defines a`%hist` hash to store values according to their timestamp, and then defines the `memoryvariable` subroutine creating and returning `Proxy` object:

``` Perl6
sub memoryvariable($label) is rw
{
  my $val;
  Proxy.new(
    FETCH => method ()
    {
        $val
    },
    STORE => method ($new)
    {
        $val = $new;
        %hist{$label}.push( Pair(now.Int => $new) );
    },
  );
}
```
Arne also defines two additional subroutines, one for displaying the stored historical values and another to output historical values along with the associated time stamp. For example, the second subroutine might display the following:

    2019-10-06T17:35:10+02:00: 10
    2019-10-06T17:35:10+02:00: 20
    2019-10-06T17:35:10+02:00: 15

[Kevin Colyer](https://github.com/manwar/perlweeklychallenge-club/blob/master/challenge-027/kevin-colyer/perl6/ch-2.p6) created a `HistoryInt` class also using a `Proxy` object, storing the historical values in an array attribute (`@.history`) of the `HistoryInt` class:

``` Perl6
class HistoryInt {
  has Int $.x =0 ;
  has @.history;

  method x () is rw {
    Proxy.new(
      FETCH => -> $ { $!x },
      STORE => -> $, Int $new {
        $!x = $new;
        @!history.push: $new;
      }
    )
  }
  method History () {
    @!history;
  }
}
```

[Markus Holzer](https://github.com/manwar/perlweeklychallenge-club/blob/master/challenge-027/markus-holzer/perl6/ch-2.p6)'s program is extremely concise:

``` Perl6
use Scalar::History;

my Int $x := Scalar::History.create(10, Int);
$x = 20;
$x -= 5;
```

thanks to the fact that it uses the [Scalar::History](https://github.com/holli-holzer/perl6-Scalar-History) module, which he wrote and is still in development stage (it should presumably go to CPAN some time in the future when completed). This module also uses `Proxy` objects.

[Simon Proctor](https://github.com/manwar/perlweeklychallenge-club/blob/master/challenge-027/simon-proctor/perl6/ch-2.p6) implemented a `Historic` class with a `@!values` attibute, implementing various setters and getters and using `Proxy` objects. One very interesting point is that he also implemented a `Δ=` operator to handle `Historic` objects:

``` Perl6
multi sub infix:<Δ=> ( Any:U $h is rw, Any $v ) is equiv(&infix:<=>) {
     $h = Historic.new();
     $h.set( $v );
     $h;
}

multi sub infix:<Δ=> (Historic:D $h, Any $a) is equiv(&infix:<=>) {
    $h.set($a);
    return $h;
}
```

[Joelle Maslak](https://github.com/manwar/perlweeklychallenge-club/blob/master/challenge-027/joelle-maslak/perl6/ch-2.p6) implemented a `History` class with the `@!hist` and `$!data` attributes, also using `Proxy` objects:

``` Perl6
class History {
    has @!hist;
    has $!data;

    method get-proxy() is rw {
        my $data    := $!data;
        my $history := @!hist;
        Proxy.new(
            FETCH => method ()     { $data },
            STORE => method ($val) { $data = $val; $history.push( $data.clone ) },
        );
    }

    method history() {
        my @h = @!hist;
        return @h;
    }
}
```

[Ruben Westerberg](https://github.com/manwar/perlweeklychallenge-club/blob/master/challenge-027/ruben-westerberg/perl6/ch-2.p6) used a `@history` array to store the successive values of a `Proxy` object:

``` Perl6
sub remembering (@history) {
	return-rw Proxy.new(
		FETCH => method () {@history[*-1]},
		STORE => method ($new) {;@history.push($new)}
	);
}
```

[Noud](https://github.com/manwar/perlweeklychallenge-club/blob/master/challenge-027/noud/perl6/ch-2.p6) wrote a program that reads another program and writes a third one. His program takes another program as an argument and parses it to collect information about the variables used in this other script. After that, it creates a `%var_hash_` that updates the current values of each of the defined variables after each semicolon. The new script is then executed using the EVAL method. Noud humourously comments that he hopes he doesn't get banned from the Perl Weekly Challenge club for using the dangerous `EVAL` statement in this problem. He certainly shouldn't be banned, especially not for writing such an innovative solution! It is worth quoting the whole program:

``` Perl6
use MONKEY-SEE-NO-EVAL;

sub MAIN(Str $filename) {
    # Collect all variables in program.
    my @variables = ();
    for $filename.IO.slurp.split(";") -> $line {
        my @line_var = ($line ~~ /my\s*\$(\w+)/).values;
        if (@line_var.elems > 0) {
            @variables = (|(@line_var), |(@variables));
        }
    }

    my $exec_prog = "";
    for $filename.IO.slurp.split(";") -> $line {
        $exec_prog = "$exec_prog $line\;";
        # After every line update %var_hash_ with the current variable values.
        for @variables -> $x {
            $exec_prog = "$exec_prog
                if (not DYNAMIC::<\$$x> === Nil) \{
                    \%var_hash_\.push: ($x => DYNAMIC::<\$$x>)\; \}\;";
        }
    }

    my %var_hash_;
    EVAL $exec_prog;  # https://xkcd.com/292/

    say "Variables history:";
    for %var_hash_.kv -> $var, @hist {
        my @hist_ = @hist.grep({ not $_.^name === "Any" });
        if (@hist_.elems > 0) {
            print("$var = (");
            my $last = @hist_[0];
            print("$last");
            for @hist_[1..*] -> $next {
                if ($last != $next) {
                    print(", $next");
                    $last = $next;
                }
            }
            print(")\n");
        }
    }
}
```

[Yet Ebreo](https://github.com/manwar/perlweeklychallenge-club/blob/master/challenge-027/yet-ebreo/perl6/ch-2.p6) created an *apparently* very simple `hist` class with a `STORE` method:

``` Perl6
class hist {
    has @.history;
    has $!var handles <Str gist FETCH Numeric>;
    method STORE($val) {
        push @.history, $val;
        $!var = $val;
    }
}
my \x = hist.new(history => []);

x = 10; 
x = 20; 
x -= 5;
x = 3.1416;
x = Q[a quick brown fox jumps over the lazy dog];
x = 1e3;
x*= sqrt 3;
.say  for x.history;
```

The code of the `hist` class seems very simple, but is in fact pretty clever. I must admit that I don't fully grasp it: I don't really understand what the `handles` trait does in such context, and I am also not quite sure how this (re)definition of the `STORE` subroutine is supposed to work. If any reader wants to explain this, I would be very happy to update this blog post accordingly.

## See Also

Only one blog post this time (in addition to mine):

* Arne Sommer: https://perl6.eu/historical-intersection.html;

## Wrapping up

Please let me know if I forgot any of the challengers or if you think my explanation of your code misses something important (you can just file an issue against this GitHub page).

If you want to participate to the Perl Weekly Challenge, please connect to [this site](https://perlweeklychallenge.org/).



