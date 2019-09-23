
# Smallest Script With No Execution Error

This is derived from my [blog post](http://blogs.perl.org/users/laurent_r/2019/09/perl-weekly-challenge-24-smallest-script-and-inverted-index.html) made in answer to the [Week 24 of the Perl Weekly Challenge](https://perlweeklychallenge.org/blog/perl-weekly-challenge-024/) organized by  <a href="http://blogs.perl.org/users/mohammad_s_anwar/">Mohammad S. Anwar</a> as well as answers made by others to the same challenge.

The challenge reads as follows:

*Create a smallest script in terms of size that on execution doesn’t throw any error. The script doesn’t have to do anything special. You could even come up with smallest one-liner.*

I was first puzzled by this strange specification. Can it be that we really want a script that does nothing? Does it have to be the shortest possible script.

Well, after reading again, yes, it seems so.

## My Solutions

I'll go for a one-liner:

    $ perl6 -e ''

Just in case there is any doubt, we can check the return value under Bash to confirm that there was no error:

    $ echo $?
    0

Note that creating an empty file and using it as a parameter to the `perl` or `perl6` command line command would work just as well, for example:

    $ perl6 my-empty-file.pl

And that's it for my solutions to the first challenge. Boy, that was a quick one.


## Alternative Solutions

The challenge specification says that the script "doesn’t have to do anything special." Several of the challengers (including me) understood that it could just do nothing, others interpreted it as meaning that it should do something. I had quite a bit of fun reading the various solutions offered to solve this difficult problem.

[Arne Sommer](https://github.com/manwar/perlweeklychallenge-club/blob/master/challenge-024/arne-sommer/perl6/ch-1.sh) also wrote a Perl 6 one-liner:

    perl6 3

In his blog post, Arne also provided a solution with an empty script file.

[Francis J. Whittle](https://github.com/manwar/perlweeklychallenge-club/blob/master/challenge-024/fjwhittle/perl6/ch-1.p6), [Joelle Maslak](https://github.com/manwar/perlweeklychallenge-club/blob/master/challenge-024/joelle-maslak/perl6/ch-1.p6), [Ruben Westerberg](https://github.com/manwar/perlweeklychallenge-club/blob/master/challenge-024/ruben-westerberg/perl6/ch-1.p6), and [Simon Proctor](https://github.com/manwar/perlweeklychallenge-club/blob/master/challenge-024/simon-proctor/perl6/ch-1.p6) provided an empty `ch-1.p6` program.

[Kevin Colyer](https://github.com/manwar/perlweeklychallenge-club/blob/master/challenge-024/kevin-colyer/perl6/ch-1.p6) wrote a long script:

    @*ARGS.map: *.IO.lines.reverse».say

At least, it does something: it prints the in reverse order the files passed to it as parameters.

[Noud](https://github.com/manwar/perlweeklychallenge-club/blob/master/challenge-024/noud/perl6/ch-1.p6) wrote an even longer script:

``` Perl6
    # Create a smallest script in terms of size that on execution doesn’t throw any
    # error. The script doesn’t have to do anything special. You could even come up
    # with smallest one-liner.
```

but with no executable code in it.

[Athanasius](https://github.com/manwar/perlweeklychallenge-club/blob/master/challenge-024/athanasius/perl6/ch-1.sh) wrote a Perl 6 one-liner printing the virtual machine on which Perl is running (for example Moar or JVM) and trhe version:

    perl6 -e"say $*VM"

[Jaldhar H. Vyas](https://github.com/manwar/perlweeklychallenge-club/blob/master/challenge-024/jaldhar-h-vyas/perl6/ch-1.sh) wrote another one liner displaying information about the Perl 6 version being used:

    perl6 -V

[Randy Lauen](https://github.com/manwar/perlweeklychallenge-club/blob/master/challenge-024/randy-lauen/perl6/ch-1.sh) actually provided an 11-line Bash script with a Perl 6 one-liner in it. This is his one-liner:

    perl6 -e ';'

[Roger Bell West](https://github.com/manwar/perlweeklychallenge-club/blob/master/challenge-024/roger-bell-west/perl6/ch-1.p6) implemented a script containing only a shebang-line, so that it can run without having to type `perl6` at the prompt:

``` Perl6
#! /usr/bin/perl6
```
[Yet Ebreo](https://github.com/manwar/perlweeklychallenge-club/blob/master/challenge-024/yet-ebreo/perl6/ch-1.sh) suggested this script:

    perl6 -e '$%'

His script appears to do nothing, but I must say that I'm not sure what the strange `$%` variable is supposed to be.

## Enter Damian Conway

Surprisingly, Damian has not (yet) commented on this very challenging task.

## See also

Not less that five blog post this week!

* Arne Sommer really has an amazing lot to say about scripts that are empty or do nothing: https://perl6.eu/small-inversions.html. Arne uses this opportunity to show his Perl 6 `hex-dump` program, which can be quite useful when you have weird string behaviors of Unicode problems. I made a copy of it in my tools directory.

* Jaldhar H. Vyas: https://www.braincells.com/perl/2019/09/perl_weekly_challenge_week_24.html

* Joelle Maslak: https://www.braincells.com/perl/2019/09/perl_weekly_challenge_week_24.html. Joelle asks the question: how well do languages do nothing? Her blog analyzes half a dozen languages on that criterium and demonstrates that Perl (Perl 5, that is) is really good for nothing. I'm sorry that, after reading her thorough analysis, I am afraid that I have to admit that Perl 6 is quite probably not as good, though, for nothing (although some comments to her blog show that things have improved recently). I had a lot of fun reading Joelle's ultimate benchmark.

* Roger Bell West: https://blog.firedrake.org/archive/2019/09/Perl_Weekly_Challenge_24.html

* Yet Ebreo: http://blogs.perl.org/users/yet_ebreo/2019/09/perl-weekly-challenge-w024---smallest-script-inverted-index.html

## Wrapping up

This is probably the shortest blog post I ever wrote here.

Please let me know if I forgot any of the challengers or if you think my explanation of your code misses something important.

If you want to participate to the Perl Weekly Challenge, please connect to [this site](https://perlweeklychallenge.org/).



