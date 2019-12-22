# A Scrabble-Like Word Game

This is derived in part from my [blog post](http://blogs.perl.org/users/laurent_r/2019/12/perl-weekly-challenge-38-date-finder-and-word-game.html) made in answer to the [Week 38 of the Perl Weekly Challenge](https://perlweeklychallenge.org/blog/perl-weekly-challenge-038/) organized by  <a href="http://blogs.perl.org/users/mohammad_s_anwar/">Mohammad S. Anwar</a> as well as answers made by others to the same challenge.

The challenge reads as follows:

*Lets assume we have tiles as listed below, with an alphabet (A..Z) printed on them. Each tile has a value, e.g. A (1 point), B (4 points) etc. You are allowed to draw 7 tiles from the lot randomly. Then try to form a word using the 7 tiles with maximum points altogether. You don’t have to use all the 7 tiles to make a word. You should try to use as many tiles as possible to get the maximum points.*

*For example, A (x8) means there are 8 tiles with letter A.*

    1 point
    
        A (x8), G (x3), I (x5), S (x7), U (x5), X (x2), Z (x5)
    
    2 points
    
        E (x9), J (x3), L (x3), R (x3), V (x3), Y (x5)
    
    3 points
    
        F (x3), D (x3), P (x5), W (x5)
    
    4 points
    
        B (x5), N (x4)
    
    5 points
    
        T (x5), O (x3), H (x3), M (x4), C (x4)
    
    10 points
    
        K (x2), Q (x2)

So, the game is essentially similar to Scrabble, except that there is no game board.

## My Solution

I don't see any way to solve correctly this task without a brute-force approach, i.e. trying all possibilities to find the best score.

Just as for some previous challenges, I will use a `words.txt` file containing 113,809 lower-case English words usually accepted for crossword puzzles and other word games. The `words.txt` file can be found [on my Github repository](https://github.com/LaurentRosenfeld/thinkperl6/tree/master/Supplementary). The original list was contributed to the public domain by Internet activist Grady Ward in the context of the [Moby Project](https://en.wikipedia.org/wiki/Moby_Project). This word list is also mirrored at [Project Gutenberg](https://www.gutenberg.org/files/3201/files/). 

For the purpose of testing the programs below, the `words.txt` file is located in my current directory. 

The solution is essentially as follows: read the file of authorized words, normalize the words by putting their letters in alphabetical order and store in a `%word-list` hash the normalized versions as a key, and the original word as a value.

Store the available letter tiles in a `Bag`. Then pick seven tiles (or any other number) from the bag, use the `combinations` method to produce all tile combinations from the drawn letters, sort each combination alphabetically and look up for the result in the hash. If the result is found, compute its score and retain the word with the highest score so far. At the end, print the word with the highest score.

    use v6;
    
    constant %tile-values =  
        A => 1, B => 4, C => 5, D => 3, E => 2, 
        F => 3, G => 1, H => 5, I => 1, J => 2, 
        K => 10, L => 2, M => 5, N => 4, O => 5, 
        P => 3, Q => 10, R => 2, S => 1, T => 5, 
        U => 1, V => 2, W => 3, X => 1, Y => 2, Z => 1;
    
    constant %tile-count =
        A => 8, B => 5, C => 4, D => 3, E => 9, 
        F => 3, G => 3, H => 3, I => 5, J => 3, 
        K => 2, L => 3, M => 4, N => 4, O => 3, 
        P => 5, Q => 2, R => 3, S => 7, T => 5, 
        U => 5, V => 3, W => 5, X => 2, Y => 5, Z => 5;
    
    my $tile-bag = (map {$_ xx %tile-count{$_}}, keys %tile-count).Bag;
    
    sub MAIN (Int $count = 7) {
        my %word-list;
        for "words.txt".IO.lines -> $line {
            next if $line.chars > $count;
            my $ordered = $line.uc.comb.sort.join("");
            my $line-value = [+] $ordered.comb.map({%tile-values{$_}});
            %word-list{$ordered}<word> = $line;
            # Note we will keep only one word for anagrams, but 
            # that's OK since anagrams have the same value
            %word-list{$ordered}<value> = $line-value;
        }
        for 1..10 {
            my @picked-tiles = $tile-bag.pick($count);
            my $max-combination = "";
            my $max-value = 0;
            for @picked-tiles.combinations -> $candidate {
                my $ordered = $candidate.sort.join("");
                next unless %word-list{$ordered}:exists;
                if %word-list{$ordered}<value> > $max-value {
                    $max-value = %word-list{$ordered}<value>;
                    $max-combination = $ordered;
                }
            }
            say "The best candidate for list ", @picked-tiles.join(""), " is:"; 
            say "    No word found!" and next unless $max-value;
            say "    %word-list{$max-combination}<word> (score: $max-value)";
        }
    }

Note that the program is not very fast (2 to 3 seconds for 7 tiles), but that's mainly due to time required to read the 113k-word list and store the words into a hash. One the hash is populated, finding the best solution is quite fast. This is the reason for which I decided to run the solution-finding part ten times once the hash is populated. If I were going to make a real-life solution for the challenge, I would store the hash in a file, as I have shown previously, notably on the [word ladder challenge](http://blogs.perl.org/users/laurent_r/2019/05/perl-weekly-challenge-7-niven-numbers-and-word-ladders.html) in May of this year.

This is an example run:

    $ time perl6  scrabble.p6 7
    The best candidate for list MESWAAG is:
        wames (score: 12)
    The best candidate for list XPSPBAG is:
        paps (score: 8)
    The best candidate for list KISCPAC is:
        spick (score: 20)
    The best candidate for list BMRPSPU is:
        bumps (score: 14)
    The best candidate for list LZRYVBY is:
        byrl (score: 10)
    The best candidate for list KHEBLZP is:
        kelp (score: 17)
    The best candidate for list FHIOUHI is:
        foh (score: 13)
    The best candidate for list VXAWSJH is:
        wash (score: 10)
    The best candidate for list LIXMPGZ is:
        limp (score: 11)
    The best candidate for list AJSFBOF is:
        boffs (score: 16)
    
    real    0m2,751s
    user    0m0,000s
    sys     0m0,031s

I know that some words found above may seem funny or uncommon, but they belong to the `words.txt` file that is one of the official sources of words for word games.


## Alternative Solutions

[Arno Sommer](https://github.com/manwar/perlweeklychallenge-club/blob/master/challenge-038/arne-sommer/perl6/ch-2.p6) populated a `%value` hash and a `%count` hash with, respectively, the letter values and the time count. He then populated a `%dict` hash with the uppercase versions of the words of his word file. The program then generates an array of combinations of the picked tiles and keeps the combinations that exists in the dictionary, and finally look the the most valuable combination.

``` Perl 6
sub get-dictionary ($file where $file.IO.r)
{
  return $file.IO.lines.grep(* !~~ /\W/)>>.uc.Set;
}
my %dict = get-dictionary($dictionary);
my @letters = %value.keys.map({ $_ xx %count{$_} }).sort.flat;
my @legal-words = @letters.combinations(1 .. $length)>>.join.unique.grep({ %dict{$_} });
my %candidates;
for @legal-words -> $word
{
  %candidates{$word} = $word.comb.map({ %value{$_} }).sum;
}
my $max-val = %candidates.values.max;

say "Most valuable word(s) at $max-val points:";
say %candidates.keys.grep({ %candidates{$_} == $max-val }).sort.join(", "), ".";
```

I may misunderstand something, but some code lines seem to be missing from Arne's code on the GitHub repository, at least the one where the tiles are picked from the tiles bag. Also, I'm afraid this program misses some candidates: to me, either you must order the letters of words inserted in the `%dict` hash, or you must use the `permutations` method rather than the `combinations` method (using bags is another solution). Note, however, that Arne's [blog post](https://raku-musings.com/date-word.html) has much more than this code sample, so look at it.

[Daniel Mita](https://github.com/manwar/perlweeklychallenge-club/blob/master/challenge-038/daniel-mita/perl6/ch-2.p6) created a `%value` hash and a `%tiles` bag to store, respectively, the letter values and the time count. His program then picks some tiles, loads them in a bag, and reads the words file and keeps the words which are contained in or equal to the bag of picked letters. Finally, it sorts the candidates by value to find the most valuable one:

``` Perl 6
sub MAIN (
  Int $amount where * > 0 = 7, #= Number of tiles to pick (default: 7)
  --> Nil
) {
  given %tiles.pick($amount).Bag -> %picked {
    "Tiles: %picked.kxxv.join()".say;
    # source: https://www.wordgamedictionary.com/sowpods/download/sowpods.txt
    "Winner: $_.key() for $_.value()".say with
      $?FILE.IO.parent.add('sowpods.txt').slurp.uc.words
      .grep({ .chars ≤ $amount && .comb ⊆ %picked })
      .map(sub {
        given $^a => $a.comb.map({ %values{$_} }).sum {
          sprintf("%-{$amount}s: %u", |.kv).say;
          .return;
        }
      }).sort({
        given $^b.value <=> $^a.value {
          when Same { $a.key.chars <=> $b.key.chars }
          default { $_ }
        }
      }).first;
  }
} 
```

[Kevin Colyer](https://github.com/manwar/perlweeklychallenge-club/blob/master/challenge-038/kevin-colyer/perl6/ch-2.p6) wrote a fairly long program doing all kinds of interesting things, but I'll quote only the subroutine doing the most important work. Kevin's program first populates a `%points` hash and a `%tilebag` BagHash with letter values and tile counts. His program then loads the word list into a `%wordlist` hash where the keys are strings containing the words' sorted letters and the values the original word and the score. Kevin's program then uses the `drawTiles` subroutine which uses the `roll` method to select some tiles (using the `pick` method would have been easier). His program then sorts the picked letters, generates combinations and looks up the hash of presorted words:

``` Perl6
sub makeWords(@tiles) {
    my @result = "", 0;
    for @tiles.combinations -> @cand {
        next if @cand.elems < 2;
        my $cand=@cand.sort.join;
        next unless %wordlist{$cand}:exists;
        my ($s,$w)= %wordlist{$cand};
        if $s > @result[1] and $cand.chars => @result[0].chars {
            @result[0,1]=$w,$s;
        };
    }
    return @result;
}
```

[Noud](https://github.com/manwar/perlweeklychallenge-club/blob/master/challenge-038/noud/perl6/ch-2.p6) first populated a `%points` hash and a `%num_tiles` hash with letter values  and tile counts. Noud's program then reads sequentially the word file and retains all the words whose letters are a subset of Bag containing the picked letters. This is Noud's subroutine doing the bulk of the work:

``` Perl 6
sub get_best_word(%picked) {
    my @picked_words;
    for "/usr/share/dict/words".IO.slurp.uc.words -> $word {
        if ($word.comb ⊆ %picked) {
            @picked_words.push(((%points{$_} for $word.comb).sum, $word));
        }
    }

    sort(@picked_words)[*-1];
}
```

[Simon Proctor](https://github.com/manwar/perlweeklychallenge-club/blob/master/challenge-038/simon-proctor/perl6/ch-2.p6) first populated a constant `%SCORES` hash with the letter values and a constant `$BAG` Bag with the tile counts. He also built a `Tile` class providing a number of utility methods. He then picked some letters and inserted them in the `$match-bag` Bag. The bulk of the work is done in the `MAIN` subroutine:

``` Perl 6
sub MAIN(
    Int() $tile-count = 7 #= Number of tiles to draw from the bag (Default 7)
) {
     my @tiles = $BAG.pick( $tile-count );
     say "Tiles drawn {join(",", @tiles)} max possible score {[+] @tiles}";
     my $match-bag = Bag.new( @tiles );
     my $data-channel = Channel.new;
     my @p;
     @p.push( start check-words( $data-channel, $match-bag ) ) for ^3;
     $data-channel.send($_) for "/etc/dictionaries-common/words".IO.lines.grep(*.codes <= $tile-count);
     $data-channel.close;
     await @p;
     my $result = @p.sort( { $^b.result.value cmp $^a.result.value } ).head.result;
     $result.value ?? say "{$result.key} scores {$result.value}" !! say "I couldn't find a word";
}
sub check-words( Channel $input, Bag $match-bag ) {
    my $result = ( "" => 0 );
    react {
        whenever $input -> $word {
            my $checked = valid-word( $word, $match-bag );
            my $score = [+] $checked.kxxv;
            if $score > $result.value {
                $result = ( $word => $score );
            }
        }
    }
    return $result;
}
```

Note that Simon is using channels for parallel processing. In my tests, it took 2.7 seconds to process 10 letter selections (most of which presumably to load the word dictionary), so I'm not sure we really need parallel processing here, but it is always very interesting to look at these possibilities (I must admit that I haven't really worked with them over the last two or three years and that I don't really remember how to use them).

[Javier Luque](https://github.com/manwar/perlweeklychallenge-club/blob/master/challenge-038/javier-luque/perl6/ch-2.p6) first populated a `%tile_metadata` hash containing both the values and time counts. Most of the work is done in the following subroutine using the `permutations` method::

```Perl 6
sub find-best-word(@tiles) {
    my $top_score = 0;
    my $top_word;

    my @combos = @tiles.combinations: 1..7;
    for @combos -> $combo {
        for $combo.permutations -> $perms {
            my $word = $perms.join;

            if %valid_words.{$word} {
                my $score = calculate-score($word);

                # If this is the best word store it
                if ($score > $top_score) {
                    $top_score = $score;
                    $top_word  = $word;
                }
            }
        };
    }

    return $top_word, $top_score;
}
```

[Roger Bell West](https://github.com/manwar/perlweeklychallenge-club/blob/master/challenge-038/roger-bell-west/perl6/ch-2.p6) first populated a `%tilecount` and a `tilevalue` hashes. He then used the `grab` method (which I did not know about before) to pick the wanted number of tiles from the `%tilecount` hash. Then, he populated a `%w` hash with uppercase versions of the words in the word list having less characters that the wanted number of tiles. Finally, his program computes all permutations of the picked letters and tries them against `%w` word hash, and looks for the best score:

``` Perl 6
for @bag.permutations -> $n {
  my @candidate=$n.list;
  while (@candidate) {
    my $candidate=join('',@candidate);
    if (%tried{$candidate}:exists) {
      last;
    }
    %tried{$candidate}=1;
    if (%w{$candidate}:exists) {
      my $score=sum(map {%tilevalue{$_}}, @candidate);
      if ($score > $maxscore) {
        @maxcandidate=();
        $maxscore=$score;
      }
      if ($score == $maxscore) {
        @maxcandidate.push($candidate);
      }
      last;
    }
    @candidate.pop;
  }
}

print join('',sort @bag),"\n";
print "$maxscore: ",join(' ',sort @maxcandidate),"\n";
```

[Ruben Westerberg](https://github.com/manwar/perlweeklychallenge-club/blob/master/challenge-038/ruben-westerberg/perl6/ch-2.p6) also populated various data structures for letter values and letter counts, but did it in an impressively compact way:

``` Perl 6
my @l=comb "", "AGISUXZEJLRVYFDPWBNTOHMCKQ";
my @c=(8,3,5,7,5,2,5,9,3,3,3,3,5,3,3,5,5,5,4,5,3,3,4,4,2,2);
my @v=((1) xx 7, (2) xx 6,(3) xx 4,(4) xx 2,(5) xx 5,(10) xx 2).flat;

my BagHash $tileBag.=new-from-pairs((@l Z @c).flat.pairup); #Bag of all tiles
my %values=(@l Z @v).flat;	#Letter value map
my BagHash $drawBag;		#Bag of drawn tiles
```

Ruben's way of selecting tiles is impressively less concise:

``` Perl 6
for 1..7 {
	my $i=$tileBag.total.rand.Int;
	my $t=0;
	my $selected;
	for "A".."Z" {
		$t+=$tileBag{$_};
		if $t > $i {
			$tileBag{$_}--;
			$drawBag{$_}++;
			last;
		}
	}
}
```

Using the `pick` method could have reduced all this to a single code statement.

The bulk of the work is then done as follows:

```Perl 6
#Find all words which can be made from the drawn bag
"../words_alpha.txt".IO.lines.map({.uc}).grep({$_.chars <= 7}) ==>
grep({ .comb.BagHash (<=) $drawBag; }) ==> 
map({|($_, %values{.comb}.sum)})==>
my %contenders;

#Print sores of all possible words in asscending order
my @sorted=%contenders.keys.sort({%contenders{$^a} <=> %contenders{$^b}});

put "Contenders (word: score):";
put "$_: %contenders{$_}" for @sorted;
put "\nDrawn tiles: $drawBag";
```

[Ryan Thompson](https://github.com/manwar/perlweeklychallenge-club/blob/master/challenge-038/ryan-thompson/perl6/ch-2.p6) first populated a `%val` hash, a `@bag` array, and a `dict`hash with, respectively, the letter values, tile counts and words of the word list. The bulk of the work is then done in the following subroutine using permutations of the selected tiles:

``` Perl 6
sub best-word( @seven ) {
    my %best = ( word => '', score => 0 );

    for @seven.permutations -> @p {
        # Here we check every 1..7-length prefix of the permutation
        my $word = @p.join;
        while $word.chars {
            if %dict{$word}:exists {
                my $score = word-score($word);
                %best<word score> = $word, $score if $score > %best<score>;
            }
            $word = $word.chop;
        }
    }

    %best;
}
```

## See also

Only two blog posts (besides mine) this time:

* Arne Sommer: https://raku-musings.com/date-word.html;

* Javier Luque: https://perlchallenges.wordpress.com/2019/12/10/perl-weekly-challenge-038/.

## Wrapping up

Please let me know if I forgot any of the challengers or if you think my explanation of your code misses something important (send me an e-mail or just raise an issue against this GitHub page).

If you want to participate to the Perl Weekly Challenge, please connect to [this site](https://perlweeklychallenge.org/).



