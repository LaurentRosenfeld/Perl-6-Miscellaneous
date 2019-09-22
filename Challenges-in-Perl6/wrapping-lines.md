# Wrapping Lines

This is derived from my [blog post](http://blogs.perl.org/users/laurent_r/2019/07/perl-weekly-challenge-19-weekends-and-wrapping-lines.html) made in answer to the [Week 19 of the Perl Weekly Challenge](https://perlweeklychallenge.org/blog/perl-weekly-challenge-019/) organized by  <a href="http://blogs.perl.org/users/mohammad_s_anwar/">Mohammad S. Anwar</a> as well as answers made by others to the same challenge.

The challenge reads as follows:

*Write a script that can wrap the given paragraph at a specified column using the [greedy algorithm](https://en.wikipedia.org/wiki/Line_wrap_and_word_wrap#Minimum_number_of_lines).*

The greedy algorithm does not try to balance successive lines: it just stores as much as it can from the text into the current line, and then moves to the next line. 

For this, we will suppose our `wrap` subroutine receives a line of text as a parameter and return a string wrapped to fit a given maximal width. We will also suppose that the input text is plain ASCII, some changes may have to be done for Unicode text.

## My Solution

The most typical way to solve such a problem is usually to split the input into words and to add words to a line until it goes over the maximal width; at this point, the script removes the last word (or doesn't add it is the line would get too long), produces the line and starts the new iteration with the current word. As we will see below, all challengers except Francis J. Whittle (and myself) used some variation of that algorithm.

I tend to think it will be more efficient to look for a space backward (with the `rindex` built-in function) from the maximal length position, because this will be doing less string manipulations:

``` perl6
use v6;

sub wrap (Str $line is copy, Int $width) {
    my $out = '';
    while ($line) {
        return $out ~ "$line\n" if $line.chars < $width;
        my $pos = rindex $line, ' ', $width - 1;
        $out = $out ~ substr($line, 0, $pos) ~ "\n";
        $line = substr $line, $pos+1;
    }
    return $out;
}

my $in = "Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Dolor sed viverra ipsum nunc aliquet bibendum enim. In massa tempor nec feugiat. Nunc aliquet bibendum enim facilisis gravida. Nisl nunc mi ipsum faucibus vitae aliquet nec ullamcorper. Amet luctus venenatis lectus magna fringilla.";

say wrap $in, $_ for 60, 35;
```

Note that the `$out` variable is always either the empty string or a string ending with a new line character, so that I can always add a string of `$width` or less characters to it.

This produces the following output:

    $ perl6 wrap.p6
    Lorem ipsum dolor sit amet, consectetur adipiscing elit,
    sed do eiusmod tempor incididunt ut labore et dolore magna
    aliqua. Dolor sed viverra ipsum nunc aliquet bibendum enim.
    In massa tempor nec feugiat. Nunc aliquet bibendum enim
    facilisis gravida. Nisl nunc mi ipsum faucibus vitae
    aliquet nec ullamcorper. Amet luctus venenatis lectus magna
    fringilla.

    Lorem ipsum dolor sit amet,
    consectetur adipiscing elit, sed
    do eiusmod tempor incididunt ut
    labore et dolore magna aliqua.
    Dolor sed viverra ipsum nunc
    aliquet bibendum enim. In massa
    tempor nec feugiat. Nunc aliquet
    bibendum enim facilisis gravida.
    Nisl nunc mi ipsum faucibus vitae
    aliquet nec ullamcorper. Amet
    luctus venenatis lectus magna
    fringilla.

## Alternative Solutions

[Arne Sommer](https://github.com/manwar/perlweeklychallenge-club/blob/master/challenge-019/arne-sommer/perl6/ch-2.p6) used multi `MAIN` subroutines to handle both string and file input parameters. Otherwise, his solution consists in looping over the words, building the current line and "flushing" it if the new word would make the line length too large.

[Jo Christian Oterhals](https://github.com/manwar/perlweeklychallenge-club/blob/master/challenge-019/jo-christian-oterhals/perl6/ch-2.p6) also provided for different input parameters and proceeded to split the input in words and simply outputs the words; at the same time, the script maintains a `$space-left` variable: whenever a word (plus a space) is longer than this variable, the script outputs a new line character. [Ozzy](https://github.com/manwar/perlweeklychallenge-club/blob/master/challenge-019/ozzy/perl6/ch-2.p6),  [Randy Lauen](https://github.com/manwar/perlweeklychallenge-club/blob/master/challenge-019/randy-lauen/perl6/ch-2.p6), and Jaldhar H. Vyas](https://github.com/manwar/perlweeklychallenge-club/blob/master/challenge-019/jaldhar-h-vyas/perl6/ch-2.p6) also split the input into words and maintained a `space-left` variable to figure out when to add a new line. [Simon Proctor](https://github.com/manwar/perlweeklychallenge-club/blob/master/challenge-019/simon-proctor/perl6/ch-2.p6), Roger Bell West](https://github.com/manwar/perlweeklychallenge-club/blob/master/challenge-019/roger-bell-west/perl6/ch-2.p6), [Ruben Westernerg](https://github.com/manwar/perlweeklychallenge-club/blob/master/challenge-019/ruben-westerberg/perl6/ch-2.p6,) and [Athanasius](https://github.com/manwar/perlweeklychallenge-club/blob/master/challenge-019/athanasius/perl6/ch-2.p6) essentially did the same method (except that their space left variables are called, respectively, `$left`, `$s`, `$rem`, and `remaining`). Note that Athanasius's script is fairly elaborate, as it first splits the input into paragraphs and then splits the paragraphs into words. 

[Noud](https://github.com/manwar/perlweeklychallenge-club/blob/master/challenge-019/noud/perl6/ch-2.p6), [Feng Chang](https://github.com/manwar/perlweeklychallenge-club/blob/master/challenge-019/feng-chang/perl6/ch-2.p6), and [Joelle Maslak](https://github.com/manwar/perlweeklychallenge-club/blob/master/challenge-019/joelle-maslak/perl6/ch-2.p6) split the input into words and concatenated each word into a line. When adding a new word to the line would make the line too long, the script outputs the current line and starts the new line with the current word.

[Francis J. Whittle](https://github.com/manwar/perlweeklychallenge-club/blob/master/challenge-019/fjwhittle/perl6/ch-2.p6)'s fairly original solution also provides for the possibility of taking a string or a file as input parameter, and then uses a single relatively complex regex (with three alternatives) as a parameter to the `comb` built-in function to process the input. For a single paragraph, part of the regex might look like this:

``` perl6
/ \s * <( <-[ \n ]> ** { 1..($column-1) } \S )> [ \s+ || $ ] /
```

which looks for up to the specified `$column` minus 1 non-newline characters, followed by one non-whitespace character and followed by trailing whitespace or the end of the input string (in case you don't know these capture markers, note that spaces before `<(` or after  `)>` will not be part of the overall capture). The above regex will not handle properly words which are longer than the maximal line length, so the next alternative in Francis's complete regex cuts such words at the line length limit. For an input of several paragraphs, the regex gets again slightly more complicated. Quite impressive, I must say. I really advise you to read his code and/or his blog. IMHO, this is the best of all the P6 solutions suggested for this challenge.

Note that Joelle and one or two other challengers decided to abort the script if it found a single word longer than the line length limit.

## Enter Damian Conway

Damian Conway blogged about this challenge in [Greed is good, balance is better, beauty is best.](http://blogs.perl.org/users/damian_conway/2019/08/greed-is-good-balance-is-better-beauty-is-best.html). His basic solution is somewhat similar to Francis: it uses the `comb` built-in with a regex to split the input into lines of less than the maximal length and then joins those lines with a new line character. The beauty of his solution is that it consists in one single statement:

``` perl6
sub MAIN (:$width = 80) {
    $*IN.slurp.words
        .join(' ')
        .comb(/ . ** {1..$width}  )>  [' ' | $] /)
        .join("\n")
        .say
}
```

But, Damian continues, this does not work properly with extremely long words: first, some words are decapitated and the balance of the lines really looks bad (go to his blog and see his hilariously absurd examples). Damian proceeds to show how to cut too long words (but not too close to either end) and to add hyphens.

Even with that problem solved, Damian complains that the greedy algorithm still produces ugly unbalanced paragraphs. So, he turns to the algorithm suggested by Donald Knuth and Michael Plass in the article [Breaking paragraphs into lines](https://onlinelibrary.wiley.com/doi/abs/10.1002/spe.4380111102) for the Tex typesetting system. The result looks much better, but the algorithm is much slower. 

I will not try to summarize the rest of Damian's lengthly blog, for two reasons: it becomes slightly off-topic compared to the original challenge (which certainly does not mean that it is not interesting), and it would be almost impossible to summarize it anyway without either quoting most of it or losing most of the meat of it. Damian's piece is really interesting and well written, follow [the link](http://blogs.perl.org/users/damian_conway/2019/08/greed-is-good-balance-is-better-beauty-is-best.html). and read it.

## See Also

See also the following blog posts:

* Arne Sommer: https://perl6.eu/word-wrapped-weekends.html
* Francis Whittle: https://rage.powered.ninja/2019/07/29/best-months.html
* Jo Christian Oterhals: https://medium.com/@jcoterhals/perl-6-small-stuff-21-its-a-date-or-learn-from-an-overly-complex-solution-to-a-simple-task-cf469252724f
* Jaldhar H. Vyas: https://www.braincells.com/perl/2019/08/perl_weekly_challenge_week_19.html
* Roger Bell West: https://blog.firedrake.org/archive/2019/08/Perl_Weekly_Challenge_19.html
* Damian Conway: http://blogs.perl.org/users/damian_conway/2019/08/greed-is-good-balance-is-better-beauty-is-best.html

## Wrapping up

Please let me know if I forgot any of the challengers or if you think my explanation of your code misses something important.

If you want to participate to the Perl Weekly Challenge, please connect to [this site](https://perlweeklychallenge.org/).

