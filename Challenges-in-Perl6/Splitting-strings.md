# Split Strings on Character Change

This is derived from my [blog post](http://blogs.perl.org/users/laurent_r/2019/08/perl-weekly-challenge-20-split-string-on-character-change-and-amicable-numbers.html) made in answer to the [Week 20 of the Perl Weekly Challenge](https://perlweeklychallenge.org/blog/perl-weekly-challenge-020/) organized by  <a href="http://blogs.perl.org/users/mohammad_s_anwar/">Mohammad S. Anwar</a> as well as answers made by others to the same challenge.

The challenge reads as follows:

*Write a script to accept a string from command line and split it on change of character. For example, if the string is "ABBCDEEF", then it should split like "A", "BB", "C", "D", "EE", "F".*

## My Solutions

For this, it seemed fairly obvious to me that a simple regex in a one-liner should do the trick.

``` shell
$ perl6 -e 'say ~$/ if "ABBBCDEEF" ~~ m:g/( (.) $0*)/;'
A BBB C D EE F

$ perl6 -e 'say ~$/ if "ABBCDEEF" ~~ m:g/( (.) $0*)/;'
A BB C D EE F
```

The `((.)$0*)` pattern looks for repeated characters and stores the captured groups of identical characters into the `$/` match object, which we just need to stringify for outputting it.

Just in case the quote marks and commas are part of the desired output (which I don't really believe), we can fix that easily:

``` shell
$ perl6 -e 'print join ", ", map {"\"$_\""}, "ABBCDEEF" ~~ m:g/((.)$0*)/'
"A", "BB", "C", "D", "EE", "F"
```

If we don't want to use a regex and prefer a more traditional procedural approach, we can split the input string, loop through each letter individually, and take actions depending on whether the current letter is equal to the previous one. For example:

``` perl6
use v6;

sub split-str ($in) {
    my $prev = "";
    my $tmp-str = "";
    my @out;
    for $in.comb -> $letter {
        if $letter eq $prev {
            $tmp-str ~= $letter;
        } else {
            push @out, $tmp-str if $tmp-str ne "";
            $tmp-str = $letter;
            $prev = $letter;
        }
    }
    push @out, $tmp-str;
    return join ", ", @out;
}

sub MAIN (Str $input = "ABBBCDEEF") {
    say split-str $input;
}
```

When using the default input parameter (`"ABBBCDEEF"`), this prints the following:

    $ perl6 split-string.p6
    A, BBB, C, D, EE, F

## Alternative Solutions

[Arne Sommer](https://github.com/manwar/perlweeklychallenge-club/blob/master/challenge-020/arne-sommer/perl6/ch-1.p6) devised a solution somewhat similar to the procedural approach I outlined just above: splitting the input string into an array of individual letters and then loop over each letter to check whether it is the same as the previous one . [Adam Russell](https://github.com/manwar/perlweeklychallenge-club/blob/master/challenge-020/adam-russell/perl6/ch-1.p6), who was apparently offering solutions in Perl 6 for the first time, also used a procedural approach, but he used a `repeat ... while` loop and he printed the letters on the fly within the loop. 

[Ruben Westerberg](https://github.com/manwar/perlweeklychallenge-club/blob/master/challenge-020/ruben-westerberg/perl6/ch-1.p6) also used a procedural approach on an array of letters, but with a fairly original and clever use of `state` variables, as well a somewhat unexpected use of the `when ... default` construct; his solution is also the only one using `NEXT` and `LAST` phasers.

[Jaldhar H Vyas](https://github.com/manwar/perlweeklychallenge-club/blob/master/challenge-020/jaldhar-h-vyas/perl6/ch-1.sh) was the only person other than me to suggest a Perl 6 one-liner and also the only person to use the regex pattern (similar to mine) in a substitution rather than a simple match:

    perl6 -e ' @*ARGS.shift.subst(/ ( (.)$0* ) /, { "\"$0\"" }, :g).subst("\"\"", "\", \"", :g).say; ' "ABBCDEEF"

[Francis Whittle](https://github.com/manwar/perlweeklychallenge-club/blob/master/challenge-020/fjwhittle/perl6/ch-1.p6), [Martin Barth](https://github.com/manwar/perlweeklychallenge-club/blob/master/challenge-020/martin-barth/perl6/ch-1.p6), [Randy Lauen](https://github.com/manwar/perlweeklychallenge-club/blob/master/challenge-020/randy-lauen/perl6/ch-1.p6), [Joelle Maslak](https://github.com/manwar/perlweeklychallenge-club/blob/master/challenge-020/joelle-maslak/perl6/ch-1.p6),and [Feng Chang](https://github.com/manwar/perlweeklychallenge-club/blob/master/challenge-020/feng-chang/perl6/ch-1.p6) used regex patterns almost identical to mine above, but used that pattern as a parameter to the `comb` built-in function. As an example, this is Joelle's solution:

``` perl6
sub MAIN(Str:D $input) {
    my @matches = $input.comb( / (.) $0* / );
    say @matches.join("\n");
}
```

[Kevin Colyer](https://github.com/manwar/perlweeklychallenge-club/blob/master/challenge-020/kevin-colyer/perl6/ch-1.p6), [noud](https://github.com/manwar/perlweeklychallenge-club/blob/master/challenge-020/noud/perl6/ch-1.p6), and [Athanasius](https://github.com/manwar/perlweeklychallenge-club/blob/master/challenge-020/athanasius/perl6/ch-1.p6) used the same regex pattern as I did along with a similar syntax to retrieve the bits and pieces.

[Ozzy](https://github.com/manwar/perlweeklychallenge-club/blob/master/challenge-020/ozzy/perl6/ch-1.p6) also used a regex, but with named captures rather than using the `$0` special variable (which is really a shortcut for `$/[0]`):

``` perl6
$string.match: / ( $<l>=<.alpha> $<l>* )+ /;    # Quantified capture yields array $/[0] of Match objects
say $/[0][*].Str;                               # Stringify each Match object to see the overall match
```

[Roger Bell West](https://github.com/manwar/perlweeklychallenge-club/blob/master/challenge-020/roger-bell-west/perl6/ch-1.p6) also used something similar to a named capture (although it is really assigning a capture number to a variable):

``` perl6
sub splitchange ($in) {
   return map {$_.Str}, $in ~~ m:g/(.) {} :my $c = $0; ($c*)/;
}
```

Although Damian Conway doesn't participate directly to the Perl Weekly Challenge, but usually comments on it afterwards, his beautifully crafted solutions are always worth contemplating. His [latest blog](http://blogs.perl.org/users/damian_conway/2019/08/with-friends-like-these.html) suggests a regex as a parameter to the `comb` builtin subroutine:

``` perl6
use v6.d;

sub MAIN (\str) {
    .say for str.comb: /(.) $0*/
}
```

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

