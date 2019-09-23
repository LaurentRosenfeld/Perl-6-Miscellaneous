# Longest Pokémon Sequence

This is derived from my [blog post](http://blogs.perl.org/users/laurent_r/2019/09/perl-weekly-challenge-25-pokemon-sequence-and-chaocipher.html) made in answer to the [Week 25 of the Perl Weekly Challenge](https://perlweeklychallenge.org/blog/perl-weekly-challenge-025/) organized by  <a href="http://blogs.perl.org/users/mohammad_s_anwar/">Mohammad S. Anwar</a> as well as answers made by others to the same challenge.

The challenge reads as follows:

*Generate a longest sequence of the following English Pokemon names where each name starts with the last letter of previous name.*

> audino bagon baltoy banette bidoof braviary bronzor carracosta charmeleon cresselia croagunk darmanitan deino emboar emolga exeggcute gabite girafarig gulpin haxorus heatmor heatran ivysaur jellicent jumpluff kangaskhan kricketune landorus ledyba loudred lumineon lunatone machamp magnezone mamoswine nosepass petilil pidgeotto pikachu pinsir poliwrath poochyena porygon2 porygonz registeel relicanth remoraid rufflet sableye scolipede scrafty seaking sealeo silcoon simisear snivy snorlax spoink starly tirtouga trapinch treecko tyrogue vigoroth vulpix wailord wartortle whismur wingull yamask

First, an assumption: each name in the sequence must appear only once, because if there could be duplicates, then it wouldn't be difficult to find an infinite cyclical sequence and easily win the prize for the longest sequence. Therefore, when we use a name at some point in a sequence, it should be removed from the list of names authorized afterwards in the same sequence. We also assume that the longest sequence means the sequence with the largest number of names (and not, for example, the largest number of letters). One comment, finally: one of the Pokémons is named "porygon2"; since no name starts with a digit, this name cannot be used within a sequence, but at best as the final item of a sequence. The same can be said about, for example, "audino", which also has no successor, since no name starts with the letter "o".  

In fact, there are even three names, "bidoof," "jumpluff," and "vulpix," that have no predecessor and no successor. We could decide to remove them from the list before we start with the idea to improve performance, but this wouldn't buy us any significant advantage, as we will never see them as possible successor of some other name anyway.

## My solutions

The first version of my program did not handle the case where there are several sequences, but it still printed the largest sequence count each time it was updated. And it appeared immediately that there were many sequences (more than 1200) with the highest count (23 names). So I changed the code to record all the sequences with the highest count.

The first thing that the program does is to populate a hash with arrays of words starting with the same letter (that letter being the key in the hash). This way, when we look for a successor in a sequence, we only look at names starting with the right letter. The program also maintains a `$seen` hash reference to filter out names that have already been used in a sequence.

The program is using brute force, i.e. trying every legal sequence. Each time we've found a sequence that can no longer be augmented, we need to backtrack. The easiest way to implement a backtracking algorithm is to use recursion. So, our `search-seq` calls itself recursively each time we want to add a new name to a sequence.

``` Perl6
use v6;

my @names = < audino bagon baltoy banette bidoof braviary bronzor carracosta 
              charmeleon cresselia croagunk darmanitan deino emboar emolga 
              exeggcute gabite girafarig gulpin haxorus heatmor heatran ivysaur 
              jellicent jumpluff kangaskhan kricketune landorus ledyba loudred 
              lumineon lunatone machamp magnezone mamoswine nosepass petilil 
              pidgeotto pikachu pinsir poliwrath poochyena porygon2 porygonz 
              registeel relicanth remoraid rufflet sableye scolipede scrafty 
              seaking sealeo silcoon simisear snivy snorlax spoink starly 
              tirtouga trapinch treecko tyrogue vigoroth vulpix wailord 
              wartortle whismur wingull yamask >;

my %name-by-letter;
for @names -> $name {
    my $start-letter = substr $name, 0, 1;
    push %name-by-letter{$start-letter}, $name;
}

my @best-seq;
my $best-count = 0;
for @names -> $name {
    search-seq( [$name], $name.SetHash );
}
say "BEST SEQUENCES: ";
for @best-seq -> $item {
   say "$item";
}
say now - INIT now;

sub search-seq (@current-seq, $seen) {
    my $last-name = @current-seq[*-1];
    my $last-letter = substr $last-name, *-1, 1;
    my @next-candidates = grep {defined $_}, # Remove empty slots
        (@(%name-by-letter{$last-letter}) (-) $seen).keys;
    if ( @next-candidates.elems == 0) {
        my $count = @current-seq.elems;
        if $count > $best-count {
            @best-seq = @current-seq;
            $best-count = $count;
        } elsif ($count == $best-count) {
            push @best-seq, @current-seq;
        }
    } else {
        for @next-candidates -> $name {
            my @new-seq = | @current-seq, $name;
            search-seq( @new-seq, $seen ∪ $name.SetHash );
        }
    }
}
```
We display here only a small fraction of the output:

    machamp petilil landorus seaking girafarig gabite exeggcute emboar rufflet trapinch heatmor registeel loudred darmanitan nosepass simisear relicanth haxorus scrafty yamask kricketune emolga audino
    
    machamp petilil landorus seaking girafarig gabite exeggcute emboar rufflet trapinch haxorus simisear relicanth heatmor registeel loudred darmanitan nosepass scrafty yamask kricketune emolga audino
    
    machamp petilil landorus seaking girafarig gabite exeggcute emboar rufflet trapinch haxorus simisear relicanth heatmor registeel loudred darmanitan nosepass snivy yamask kricketune emolga audino
    
    machamp petilil landorus seaking girafarig gabite exeggcute emboar rufflet trapinch haxorus simisear relicanth heatmor registeel loudred darmanitan nosepass starly yamask kricketune emolga audino

So this works, but this program runs in more than eight minutes. I have to think harder about optimizations or preferably a better algorithm.

In a comment to my original post, Timo Paulssen suggested that the `grep` in this statement:

        my @next-candidates = grep {defined $_}, # Remove empty slots
            (@(%name-by-letter{$last-letter}) (-) $seen).keys;

is slowing down significantly the program. For some reason, his suggested correction wasn't really successful, but changing the statement to this:

        my @next-candidates = %name-by-letter{$last-letter} ??
            (@(%name-by-letter{$last-letter}) (-) $seen).keys !! ();

reduced the execution time to four and a half minutes. I don't understand why this simple `grep` is taking so much time (not far from half of the total time), but that's a very good improvement. To me, the time taken by this `grep` is probably a Perl 6 performance bug.

I also tried to populate a hash giving directly a list of possible successors for each name in the list (to avoid having to check repeatedly the last letter of the last word added), but that does not bring any significant speed improvement (a win of only about ten seconds).

Yet Ebreo suggested another improvement (going backward, starting with names with no successors). While Yet's modification does improve significantly the runtime (1 minute) with this particular list of names, it wouldn't work in the general case (there are cases for which his modification would lead to missing the longest sequence). See my initial [blog post](http://blogs.perl.org/users/laurent_r/2019/09/perl-weekly-challenge-25-pokemon-sequence-and-chaocipher.html) and Yet's [blog post]( http://blogs.perl.org/users/yet_ebreo/2019/09/perl-weekly-challenge-w025---pokemon-nameschaocipher.html) for details.

# Alternate Solutions

[Arne Sommer](https://github.com/manwar/perlweeklychallenge-club/blob/master/challenge-025/arne-sommer/perl6/ch-1.p6) also used a hash (actually a HoA) populated with arrays of words starting with the same letter. His program then calls a `do-check` subroutine for every word in the list, and the `do-check` subroutine calls itself recursively for every name starting with the last letter of the previous name in the sequence. So, his algorithm is essentially the same as mine, although coded in a very different way. According to Arne's blog post, his program also found a large number of 23-name paths and ran in about 13 minutes.

[Kevin Colyer](https://github.com/manwar/perlweeklychallenge-club/blob/master/challenge-025/kevin-colyer/perl6/ch-1.p6) also used a hash (`%pokeIndex`) mapping letters to names starting with such letter. Then, for every name in the Pokémon list, his program calls the `RecursivePokeSeqence`, which, as implied by the name, recursively calls itself for every possible successor. So again essentially the same algorithm. Kevin found results that are not the same as Arne's and mine because his understanding of "longest sequence" is the number of characters, not the number of names (and also because he changes "porygon2" to "porygon2n". A comment in his program provides some interesting statistics which I did not have the idea of computing:

    # Found in 3710104 iterations and 229.1811084 seconds

3.7 million iterations, clearly there is a reason why these programs take quite a bit of time to execute. Kevin's program runs in about 229 seconds, i.e. about 40 seconds less than mine), but it's not looking for the same thing and it's not on the same hardware, so the comparison may not be very significant.

[Ozzy](https://github.com/manwar/perlweeklychallenge-club/blob/master/challenge-025/ozzy/perl6/ch-1.p6) has a `search_next` recursive subroutine. His algorithm is similar to the previous one. Ozzy's program also understood "longest sequence" in terms of the number of characters, so that he found 416 chains with 174 characters (and 23 names).

[Simon Proctor](https://github.com/manwar/perlweeklychallenge-club/blob/master/challenge-025/simon-proctor/perl6/ch-1.p6) implemented a partly OO solution (with the `NodeLink` and `Node` roles). His approach looked promising to me. However, his solution is wrong, as it finds only 14 names for the longest sequence. I filed a Github [issue](https://github.com/manwar/perlweeklychallenge-club/issues/622) on his program to inform him. Simon answered that he knew it, but that he was sick and therefore unable to work on solving the problems at the time. Perhaps he will come back to it when he feels in a better health condition. All my best wishes for a prompt recovery, Simon!

[Athanasius](https://github.com/manwar/perlweeklychallenge-club/blob/master/challenge-025/athanasius/perl6/ch-1.p6) implemented a quite different solution. His program first creates 
a `%pairs` hash of arrays mapping the first and last letter of words to the corresponding words, leading to a structure like thiq: `{ao => [audino], ... me => [magnezone mamoswine], mp => [machamp], ...}`, and then a `@chains` sorted list letter pairs (like so: `[ao be bf bn ... wr yk]`) and a `%dominoes` hash recording the number of names for each letter pair (`{ao => 1, be => 1, ...  by => 2, ca => 2, ck => 1, ...}`). His program then implements three nested `for` loops which use the `@chains` and `%dominoes` data structures to build the solution. His program finally calls a `decode-chain` subroutine to transform the solution's sequence of pairs back into Pokémon names and finally displays a sequence of 23 names. The program is significantly slower (25 minutes on my computer) than Arne's, Kevin's or mine.

[Joelle Maslak](https://github.com/manwar/perlweeklychallenge-club/blob/master/challenge-025/joelle-maslak/perl6/ch-1.p6) used a hash mapping every names to its possible successors (e.g. `{audino => (), bagon => (nosepass), banette => (emboar emolga exeggcute) ...}`). Her program uses a recursive `build-longest` subroutine, as several other solutions, but the most original feature of Joelle's program is that it uses channels to introduce some parallel or concurrent processing. The program finds 1.2k solutions with 23 words, in 191 seconds on my computer; this is the best timing seen so far (about 30% less time than mine), which is really not bad, although I must admit that I'm a bit disappointed that parallel processing did not bring a more significant gain with the four cores of my CPU.

[Ruben Westerberg](https://github.com/manwar/perlweeklychallenge-club/blob/master/challenge-025/ruben-westerberg/perl6/ch-1.p6) also used channels. I must confess that I don't fully understand Ruben's solution and therefore can't really explain it. Despite using channels, Ruben's solution is quite slow, as it runs on my computer in 41 minutes.

[Yet Embreo](https://github.com/manwar/perlweeklychallenge-club/blob/master/challenge-025/yet-ebreo/perl6/ch-1.p6) suggested successively several solutions with an `iter` recursive subroutine. A solution similar in spirit to mine led to an execution time of 5 minutes. Using multithreading brought that duration to about 3 minutes. He then tried a further optimization (going backward, starting with names with no successors) which brought the duration to less than 1 minute. However, as already discussed above, while his performance optimization happened to give a correct result for our input data set, there can be input data sets for which it wouldn't work correctly and would miss the longest sequence.

[Jaldhar H. Vyas](https://github.com/jaldhar/perlweeklychallenge-club/blob/master/challenge-025/jaldhar-h-vyas/perl6/ch-1.p6) had a very busy week and provided his solution too late for the official Sunday deadline, but he nonetheless provided a complete contribution. His program first uses the `graph` subroutine to construct a `%graph` hash of arrays mapping words to possible successors. Then, its `traverse` recursive subroutine looks for the longest sequence of names in pretty much the same way as most solutions above, including mine. In his blog post, Jaldhar reports that his program runs in more than one hour. I suspect that this code line;

``` Perl6
if @path.grep(none /$neighbor/) { # ...
```

is probably what crucifies the performance, but I don't have time now to verify that. I think that using a hash or a set to record the names already in the current sequence (what I do in my `$seen` set) might improve significantly the performance.

## See Also

Only three blog posts this time:

* Arne Sommer: https://perl6.eu/pokemon-chiao.html
* Yet Ebreo: http://blogs.perl.org/users/yet_ebreo/2019/09/perl-weekly-challenge-w025---pokemon-nameschaocipher.html
* Jaldhar H. Vyas:  https://www.braincells.com/perl/2019/09/perl_weekly_challenge_week_25.html.


## Wrapping up

Please let me know if I forgot any of the challengers or if you think my explanation of your code misses something important.

If you want to participate to the Perl Weekly Challenge, please connect to [this site](https://perlweeklychallenge.org/).
