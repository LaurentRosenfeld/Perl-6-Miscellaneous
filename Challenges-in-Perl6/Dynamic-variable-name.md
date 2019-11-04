# Dynamic Variable Name

This is derived in part from my [blog post](http://blogs.perl.org/users/laurent_r/2019/10/perl-weekly-challenge-31-illegal-division-by-zero-and-dynamic-variables.html) made in answer to the [Week 31 of the Perl Weekly Challenge](https://perlweeklychallenge.org/blog/perl-weekly-challenge-031/) organized by  <a href="http://blogs.perl.org/users/mohammad_s_anwar/">Mohammad S. Anwar</a> as well as answers made by others to the same challenge.

The challenge reads as follows:

*Create a script to demonstrate creating dynamic variable name, assign a value to the variable and finally print the variable. The variable name would be passed as command line argument.*

There are some scripting languages (such as various Unix shells or the VMS equivalent, the DCL language) where it is possible to dynamically create variable names. This is sometimes useful, but it tends to mess up the script's name space. It seems that it can also be done in PHP (but, then, it is PHP, if you see what I mean).

It is *possible* but strongly discouraged to do it in Perl 5 using symbolic references. If you want to know why it is considered to be bad to do it in Perl 5, please read Mark-Jason Dominus's article in three installments on the subject:

* [Why it's stupid to `use a variable as a variable name'](https://perl.plover.com/varvarname.html);

* [A More Direct Explanation of the Problem](https://perl.plover.com/varvarname2.html);

* [What if I'm Really Careful?](https://perl.plover.com/varvarname3.html).

The solution to avoid symbolic references in Perl 5 is to use a hash. Please read my other blog post linked above if you want to know more.

## My Solution

My first reaction is that I did not think that there is anything like symbolic references in Perl 6/Raku and that it was possible to create a variable dynamically. So, it seemed that it was not possible to literally "demonstrate creating dynamic variable name" in Perl 6/Raku. What we can do, however, is, like in P5, to use a hash:

``` Perl6
use v6;

sub MAIN (Str $name, Str $value) {
    my %hash = $name => $value;
    say "The item is called $name and its value is %hash{$name}";
}
```

This program displays the name of the item and its value:

    $ perl6 sym_ref.p6 foo bar
    The item is called foo and its value is bar

It turns out that I was wrong and that there are some ways to dynamically create variables in Perl6/Raku, as several of the alternative solutions below will show. So, it can be done, but I very much doubt it is a good idea, as I tend to think that the reasons outlined by Mark Jason Dominus on the context of Perl 6 also apply to Perl6/Raku.

## Alternative Solutions

[Adam Russell](https://github.com/manwar/perlweeklychallenge-club/blob/master/challenge-031/adam-russell/perl6/ch-2.p6) has been participating to the challenge in Perl 5 since the very beginning, but is participating to the challenge in Perl 6 / Raku for the first time (if I'm not wrong). His very imaginative solution creates a variable name by concatenating `"\$"` with the first argument passed to the script, then creates on the fly a `Temp.pm6` file containing a module printing out newly created variable, runs the module (with `require` to import the module at run time) and finally deletes the `Temp.pm6` file. 

``` Perl6
my $variable = "\$" ~ @*ARGS[0];
my $value = @*ARGS[1]; 
spurt "Temp.pm6", "unit module Temp; my $variable = $value; say \"The value of \\$variable is $variable.\"";
use lib ".";
require Temp;
unlink "Temp.pm6";
```

See also his quite clever C++ implementation using macros to create dynamically a variable.

[Arne Sommer](https://github.com/manwar/perlweeklychallenge-club/blob/master/challenge-031/arne-sommer/perl6/ch-2.p6) also thought that it is not possible to create a variable dynamically in Raku, but argued that it is possible to access an already existing one with the `::()` operator:

``` Perl6
unit sub MAIN ($name = '$a');

my $a = 12;
my $b = 15;
my $c = 19;
my $d = 26;
my $e = 99;

say "The value of $name: " ~ ::($name);
```

So, after all, I was wrong: there appears to exist something like [symbolic references](https://docs.perl6.org/language/packages#Interpolating_into_names) in Raku, or, at least, it is possible to interpolate strings as variable names.

[Kevin Colyer](https://github.com/manwar/perlweeklychallenge-club/blob/master/challenge-031/kevin-colyer/perl6/ch-2.p6) used essentially the same technique as Arne:

``` Perl6
sub MAIN($name='test'){
    # From http://rosettacode.org/wiki/Dynamic_variable_names#Perl_6
    my $var=$name;
    say "variable named $var is {$::('var')}";
    $::('var')=137;
    say "variable named $var is {$::('var')}";
}
```

[Mark Senn](https://github.com/manwar/perlweeklychallenge-club/blob/master/challenge-031/mark-senn/perl6/ch-2.p6) tried various ways to implement indirect names or symbolic references, and finally used a hash:

``` Perl6
sub MAIN($name, $value)
{
    say "$name    $value";

    # Using
    #     my $$name = $value;
    # gave
    #     Cannot declare a variable by indirect name (use a hash instead?)
    #
    # Using
    #     ${$name} = $value;
    # gave
    #     Unsupported use of ${$name}; in Perl 6 please use $($name) for hard ref
    #     or $::($name) for symbolic ref
    #
    # Using
    #     my $::($name);
    # gave
    #     Cannot declare a variable by indirect name (use a hash instead?)
    my %hash;
    %hash{$name} = $value;
    %hash{$name}.say;
}
```

[Markus Holzer](https://github.com/manwar/perlweeklychallenge-club/blob/master/challenge-031/markus-holzer/perl6/ch-2.p6) created a [VariableFactory](https://github.com/manwar/perlweeklychallenge-club/blob/master/challenge-031/markus-holzer/perl6/lib/VariableFactory.pm6) class:

``` Perl6
class VariableFactory { * }
sub EXPORT( $var-name ) 
{
    $var-name 
        ?? %( '$*' ~ $var-name => 42 )
        !! %();
}
```
and used it in his program:

``` Perl6
INIT use VariableFactory ( @*ARGS[0] );
sub MAIN( $var-name ) { say ::( '$*' ~ $var-name ) }
```

Markus's program creates the variable name through concatenation of the `'$*'` and `$var-name` components within the `::( ... )` construct, but I must admit that I don't fully understand the syntax. Well, no, it's not really the syntax that puzzles me, it's quite simple, after all, it is rather the fact that I have some difficulty to see actual use cases for such a contrived construct.

[Noud](https://github.com/manwar/perlweeklychallenge-club/blob/master/challenge-031/noud/perl6/ch-2.p6) made something similar, although quite simpler, but I also have some difficulty understanding how this could be useful:

``` Perl6
sub MAIN($name, $value) {
    GLOBAL::{'$' ~ $name} = $value;
    say '$' ~ $name ~ " = " ~ GLOBAL::{'$' ~ $name};
}
```

[Tyler Limkemann](https://github.com/manwar/perlweeklychallenge-club/blob/master/challenge-031/tyler-limkemann/perl6/ch-2.p6) created a `Contextualizer` class using `nqp` (not quite Perl), a lower-level subset of the Perl 6 syntax. 

``` Perl6
use MONKEY;
use nqp;

class Contextualizer {
  submethod ctxsave(*@args --> Nil) {
    $*MAIN_CTX := nqp::ctxcaller(nqp::ctx());
  }
}

sub MAIN(Str $s) {
  my $compiler = nqp::getcomp('perl6');

  my $*MAIN_CTX := nqp::ctx();
  my $*CTXSAVE := Contextualizer;

  $compiler.eval("my \${$s.uc} = ':)'", :outer_ctx($*MAIN_CTX), :interactive(1));
  $compiler.eval("\${$s.uc}.say", :outer_ctx($*MAIN_CTX), :interactive(1));
}
```

[Athanasius](https://github.com/manwar/perlweeklychallenge-club/blob/master/challenge-031/athanasius/perl6/ch-2.p6) used the `EVAL` built-in routine which makes it possible to execute a string containing valid Perl 6/ Raku code:

``` Perl6
use MONKEY-SEE-NO-EVAL;
my Real constant $VALUE = 42;

sub MAIN(Str:D $variable-name)
{
    # Declare the variable and assign a value to it
    my Str $expression = "my \$$variable-name = $VALUE;";
    # Print the variable
    $expression ~= " qq[\\\$$variable-name = \$$variable-name].say;";
    # Declaration, assignment, and printing must be EVALuated together to avoid
    # a "Variable ... is not declared" error in the say statement
    EVAL $expression;
}
```

Note that `EVAL` is considered to be a dangerous function and therefore requires the `use MONKEY-SEE-NO-EVAL;` pragma to be activated.

[Joelle Maslak](https://github.com/manwar/perlweeklychallenge-club/blob/master/challenge-031/joelle-maslak/perl6/ch-2.p6) also used the `EVAL` built-in routine:

``` Perl6
use MONKEY-SEE-NO-EVAL;

# Note all sorts of bad things can still be done with this code - like a
# user might pass in the name of an existing variable, might start a
# variable name with a number, etc.

sub MAIN(Str:D $var-name, $value) {
    die "Invalid variable name" if $var-name !~~ m/^ \w+ $/;  # Doesn't catch everything
    EVAL("my \$OUR::$var-name = { $value.perl }");
    EVAL("say '\$$var-name is set to: ' ~ \$OUR::$var-name");
}
```

[Ruben Westerberg](https://github.com/manwar/perlweeklychallenge-club/blob/master/challenge-031/ruben-westerberg/perl6/ch-2.p6) also  the `EVAL` built-in routine:

``` Perl6
use MONKEY-SEE-NO-EVAL;
my $name=@*ARGS[0]//"var"~1000.rand.Int;
my $value=@*ARGS[1]//1.rand;
{
	put "Using Module/eval";
	module D {
		EVAL "our \$$name=\"$value\"";
	}
	put $D::($name);
	put "Variable name: $name Value: {$D::($name)}";
}

put "";

{
	put "Using Hash";
	my %h;
	%h{$name}=$value;
	put "Variable name: $name Value: %h{$name}";

}
```

[Jaldhar H. Vyas](https://github.com/manwar/perlweeklychallenge-club/blob/master/challenge-031/jaldhar-h-vyas/perl6/ch-2.p6) suggested this quite simple solution:

``` Perl6
sub MAIN( Str $var ) {
    my $newvar = $var;
    $($newvar) = 42;

    say "$var = ", $($newvar);
}
```

[Javier Luque](https://github.com/manwar/perlweeklychallenge-club/blob/master/challenge-031/javier-luque/perl6/ch-2.p6) used the `GLOBAL` name space to perform the task:

``` Perl6
sub MAIN (Str $variable) {
    # Randomly populate the random value
    my $random_value = (0..^9).roll(12).join;
    GLOBAL::{'$' ~ $variable} = $random_value;

    # Say dynamic variable name and random value
    say 'Dynamic variable name: ' ~  $variable;
    say 'Random value: ' ~ GLOBAL::{'$' ~ $variable};

    # test like this: perl6 ch2.p6 test
    say 'Variable test is: ' ~ $*test if ($variable eq 'test');
}
```


## See Also

Four blog posts this time:

* Adam Russell: https://adamcrussell.livejournal.com/10620.html;

* Arne Sommer: https://raku-musings.com/dynamic-zero.html;

* Jaldhar H. Vyas: https://www.braincells.com/perl/2019/10/perl_weekly_challenge_week_31.html;

* Javier Luque: https://perlchallenges.wordpress.com/2019/10/24/perl-weekly-challenge-031/.


## Wrapping up

Please let me know if I forgot any of the challengers or if you think my explanation of your code misses something important (send me an e-mail or just raise an issue against this GitHub page).

