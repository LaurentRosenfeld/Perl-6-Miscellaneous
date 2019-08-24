# Longest Common Substrings

This is derived from my [blog post](http://blogs.perl.org/users/laurent_r/2019/07/perl-weekly-challenge-18-longest-common-substrings-priority-queues-and-a-functional-object-system.html) made in answer to the [Week 18 of the Perl Weekly Challenge](https://perlweeklychallenge.org/blog/perl-weekly-challenge-018/) organized by  <a href="http://blogs.perl.org/users/mohammad_s_anwar/">Mohammad S. Anwar</a> as well as answers made by others to the same challenge.

The challenge reads as follows:

*Write a script that takes 2 or more strings as command line parameters and print the longest common substring. For example, the longest common substring of the strings “ABABC”, “BABCA” and “ABCBA” is string “ABC” of length 3. Other common substrings are “A”, “AB”, “B”, “BA”, “BC” and “C”. Please check this [wiki page](https://en.wikipedia.org/wiki/Longest_common_substring_problem) for details.*

I can see at least two ways to tackle the problem (to simplify, let's say between two strings). One is to have two nested loops, one on the letters of the first string and the second one on the letters of the second string, and to store the substrings (or, possibly, the longest so far). The other is to generate all the substrings of each word and then to compare them. I used the first approach for solving the challenge in Perl 5 and the second one in Perl 6 (because P6 has some functionalities making the second approach easy and interesting, and probably quite efficient). Since this blog is about Perl 6, I'll detail only the second approach.

Note that the program below will consider only extended ASCII strings for simplicity. A couple of very minor changes might be needed for dealing properly with full Unicode strings.

## My Solution

To generate all the substrings of a given string, we could use the regex engine with the `:exhaustive` adverb, to get all the overlapping matches. For example, consider this Perl 6 one-liner:

    perl6 -e 'say ~$_ for sort "ABC" ~~ m:exhaustive/.+/
    A
    AB
    ABC
    B
    BC
    C

So this seems to be dead simple. 

But I'll rather use the `rotor` built-in subroutine, which isn't mentioned very often although it is very powerful and expressive, because I wanted to use the opportunity experiment a bit with it.

These are two examples using `rotor` under the REPL:

    > 'abcd'.comb.rotor(1);
    ((a) (b) (c) (d))
    > 'abcd'.comb.rotor(2);
    ((a b) (c d))

In these examples, `rotor` groups the elements of the invocant into groups of 1 and 2 elements. We're a long way from generating all the substrings of a given string. But we can do better:

    > say 'abcd'.comb.rotor($_) for 1..4;;
    ((a) (b) (c) (d))
    ((a b) (c d))
    ((a b c))
    ((a b c d))

This is already much better, but we're still missing some of the desired substrings such as `bc` and `bcd`.

The `rotor` method can take as parameter a key-value pair, whose value (the second item) specifies a gap between the various matches:

    > (1..10).rotor(2 => 1)
    ((1 2) (4 5) (7 8))

As you can see, we obtain pairs of values, with a gap of 1 between the pairs (item 3, 6 and 9 are omitted from the list. Now, the gap can also be negative and, in that case, we get all successive pairs from the range:

    > (1..10).rotor(2 => -1)
    ((1 2) (2 3) (3 4) (4 5) (5 6) (6 7) (7 8) (8 9) (9 10))

The `rotor` subroutine can in fact do much more than that (check the [rotor documentation](https://docs.perl6.org/routine/rotor)), but I've basically shown the features that we'll use here.

The other Perl 6 functionality that we will use here is the the `Set` type and the associated intersection (`∩` or `(&)`) operator. This operator does exactly what set intersection does in the mathematical set theory: it returns the elements that are common to the two sets.

We can now code the largest common substring in Perl 6:

``` perl6
use v6;
use Test;

sub substrings (Str $in) {
    my @result = $in.comb;
    append @result,  map { .join('') }, $in.comb.rotor: $_ => 1-$_ for 2..$in.chars;
    return set @result;
}
sub largest-substring (@words) {
    my Set $intersection = substrings shift @words;
    while (my $word = shift @words) {
        $intersection ∩= substrings $word;
    }
    return $intersection.keys.max({.chars});
}
multi MAIN (*@words where *.elems > 1) {
    say largest-substring @words;
}
multi MAIN () {
    plan 2;
    my @words = <ABABC BABCA ABCBA>;
    cmp-ok largest-substring(@words), 'eq', 'ABC', "Testing 3 strings";
    @words = 'abcde' xx 5;
    cmp-ok largest-substring(@words), 'eq', 'abcde', "Testing identical strings";
}
```

Launching the program with no argument to run the tests produces this:

    $ perl6  substrings.p6
    1..2
    ok 1 - Testing 3 strings
    ok 2 - Testing identical strings

And with three strings, we get the longest substring:

    perl6  substrings.p6 ABABCTO BABCTO ABCTBA
    ABCT

My solution returns only one longest substring, even when there are two (or more) distinct longest substrings. After all, the challenge specification said "print the longest common substring," not "print the longest common substrings." Anyway, the program would require just one additional code line to return several longest substrings if needed. 

## Alternative Solutions

[Arne Sommer](https://github.com/manwar/perlweeklychallenge-club/blob/master/challenge-018/arne-sommer/perl6/ch-1.p6) decided to generate all possible substrings from each input string and then to incrementally build the set of common substrings using the `∩` set intersection operator (and find the longest common substring at the end). So, something quite similar to what I did above, except that, to generate all the substrings, he manually implemented a nested loop on the letter sequences of a given string.

[Mark Senn](https://github.com/manwar/perlweeklychallenge-club/blob/master/challenge-018/mark-senn/perl6/ch-1.p6) also used nested loops to find all the substrings of each of the input strings and stored them in an array `@set` of sets (well actually of 'SetHash' objects). That's a nice idea, but the true beauty of Mark's solution lies in the way he uses the set intersection operator within the reduction metaoperator and sorts the result by substring length to find the LCS and print it, all in one single code line:

``` perl6 
([(&)] @set).keys.sort({.chars}).tail.say;
```

I am really impressed. Congratulations, Mark, very good job! One possible minor improvement, though:  you didn't really need to sort the substrings and could have used the [max](https://docs.perl6.org/routine/max) function, for example `.max({.chars})`, which should presumably be more efficient.

[Ozzy](https://github.com/manwar/perlweeklychallenge-club/blob/master/challenge-018/ozzy/perl6/ch-2.p6) 

[Simon Proctor](https://github.com/manwar/perlweeklychallenge-club/blob/master/challenge-018/simon-proctor/perl6/ch-1.p6) also wrote a subroutine to generate all substrings of a given string. And he also cleverly thought about using the set intersection operator within the reduction metaoperator to find all the common substrings. Simon's final step is a bit more complex than Mark's, because his program finds all the longest common substrings when there is more than one:

``` perl6 
    my @word-subs = @words.map( &all-substrings );
    .say for ([(&)] @word-subs).keys.sort( { $^b.codes <=> $^a.codes } ).grep( { state $len = $_.codes; $_.codes == $len });
```

[Joelle Maslak](https://github.com/manwar/perlweeklychallenge-club/blob/master/challenge-018/joelle-maslak/perl6/ch-1.p6) also used a subroutine to find all substrings of a given string, and she also used the magical `[∩]` combination of the set intersection operator and reduction metaoperator to find all common substrings. And she also made sure to display several longest substrings when there is more than 1. Clearly one of the best contributions on this challenge.

[Athanasius](https://github.com/manwar/perlweeklychallenge-club/blob/master/challenge-018/athanasius/perl6/ch-1.p6) also wrote a subroutine to generate all substrings of a given string, using two nested loops. He also populated an array of sets, but he performed the intersection in a `for` loop.


[Veesh Goldman](https://github.com/manwar/perlweeklychallenge-club/blob/master/challenge-018/veesh-goldman/perl6/ch-1.p6) also reduced the intersection operator, but with a different syntax. He is the only one who used a regex with the `:ex` or `:exhaustive` adverb. Veesh is clearly the winner in terms of the most concise syntax:

``` perl6
sub MAIN ( *@strings where .elems > 1 ) {
  @strings.map( { m:ex/.+/>>.Str } ).reduce( { $^a ∩ $^b } ).keys.max(*.chars).say
}
```

And also certainly one of the best and most perl-sixish solutions, IMHO. I wish Veesh took part more often to the Perl 6 part of the challenge.

[Francis Whittle](https://github.com/manwar/perlweeklychallenge-club/blob/master/challenge-018/fjwhittle/perl6/ch-1.p6) also wrote a subroutine to generate all substrings of a given string, but he used the `hyper` method to accelerate his nested loops:

``` perl6
sub all-substrings(Str $in) {
  gather for (^($in.chars - 1)).hyper -> $i {
    for (1..^$in.chars).hyper -> $j {
      take $in.substr($i..$j) if $i <= $j;
    }
  }
}
```

This is quite clever, and I must admit that don't think about this easy possible performance enhancement most of the time. His `MAIN` code is also original, interesting and worth looking at.


[Noud](https://github.com/manwar/perlweeklychallenge-club/blob/master/challenge-018/noud/perl6/ch-1.p6) used two nested loops to find the longest substring or substrings between two strings. Noud's solution also covers the case where there are several longest substrings. The only problem is that the challenge said "2 or more strings" and Noud's solution can process only two input strings. And, as we'll see below, an LCS subroutine between two strings cannot properly find a LCS between 3 input strings.

[Ruben Westerberg](https://github.com/manwar/perlweeklychallenge-club/blob/master/challenge-018/ruben-westerberg/perl6/ch-1.p6)'s solution suffers of the same syndrome: it can process only two input strings. 

[Ozzy](https://github.com/manwar/perlweeklychallenge-club/blob/master/challenge-018/ozzy/perl6/ch-2.p6) orighinally implemented two nested loops to find the LCS between two strings. But this solution also can process only two input strings. However, he implemented [another solution](https://github.com/manwar/perlweeklychallenge-club/blob/master/challenge-018/ozzy/perl6/ch-2a.p6) which uses three nested `for`loops to find all the substrings of the input words (two or more) and then uses the intersection operator to find trhe common substrings. This second solution displays all the longest common substrings when there is more than one.

[Fench Chang] interestingly created an infix `LCS` operator. The good thing about creating such an operator is that you can then use it within the reduction operator `[]` to process more than two input strings. I'm afraid, though, that this approach will fail on some input strings. Suppose for example that you want to compare 3 strings, *ABCDEFUVWXY*,  *ABCDEFGHUVWX* and *ABUVWXY*. If I understand correctly, Feng's program first looks for the LCS between the first two strings, and finds *ABCDEF*; then, the script looks for the LCS between *ABCDEF* and *ABUVWXY*, and finds *AB*. But, in reality, *UVWX* was a longer substring common to the three input strings. Well, after having written the preceding sentences, I decided that I should better test to check. So, I copied Feng's `LCS` infix operator definition and tested it with the input strings of my example just above:

``` perl6
say [LCS] <ABCDEFUVWXY ABCDEFGHUVWX ABUVWXY>.flat;
```

and the program displayed "AB". So it seems that my analysis is correct.



## Enter Damian Conway

Damian Conway did not take part to the challenge, but wrote [Chopping substrings](http://blogs.perl.org/users/damian_conway/2019/07/chopping-substrings.html), a blog post, that says everything you've ever wanted to know about the subject, and probably even more than that.

I will not try to summarize Damian's master piece, you should really follow the link and read it, but I will only highlight a few points.

First, Damian says that the "best practice" solution for LCS is a relatively complex technique known as [suffix tree](https://en.wikipedia.org/wiki/Generalized_suffix_tree), but we can get very reasonable performance for strings up to hundreds of thousands of characters long using a much simpler approach.

The idea is to get sets of all substrings of each input word and then find the intersection of those sets. Damian further notes that there can be several longest substrings and insists on finding them all.

His first solution uses a regex with the `:ex` (exhaustive) adverb to find all the substrings and the `∩` set intersection operator, together with the reduction metaoperator, to find all the common substrings:

``` perl6
keys [∩] @strings».match(/.+/, :ex)».Str
```

We could then use the builtin `max` function (as I did in my solution), but that returns only one longest substring, whereas Damian wants to find them all. So he decided to augment the `max` function so that it takes a new adverb, `:all` to indicate that we want all the maxima, not just one:

``` perl6
# "Exhaustive" maximal...
multi max (:&by = {$_}, :$all!, *@list) {
    # Find the maximal value...
    my $max = max my @values = @list.map: &by;

    # Extract and return all values matching the maximal...
    @list[ @values.kv.map: {$^index unless $^value cmp $max} ];
}
```

So, with this revised version of `max`, finding the longest common substring*s* now looks like this:
``` perl6
max :all, :by{.chars}, keys [∩] @strings».match(/.+/, :ex)».Str
```

So, problem nicely solved! Except that this won't work when some bioinformaticist will try to compare DNA strands with 10,000 bases (or more). Finding all the substrings of a 10,000-letter string becomes highly unpractical. Damian goes on saying that it would be much easier if we knew what the length of the longest substring(s) was, because the number of possible substring would be much smaller. Of course, we don't know this length, but it can be found with a binary search algorithm. And this new algorithm scales incredibly better. I'll not describe further Damian's findings (and his additional optimization), as it would be much better for you to read directly what Damian wrote. So, please, follow [the link](http://blogs.perl.org/users/damian_conway/2019/07/chopping-substrings.html).

## See Also

Not too many blogs this time:

Arne Sommer: https://perl6.eu/substring-queues.html

Mark Senn: https://engineering.purdue.edu/~mark/pwc-018.pdf. Besides his explanations on the algorithm he used, I like Mark's introduction on code brevity. 

Damian Conway: http://blogs.perl.org/users/damian_conway/2019/07/chopping-substrings.html

## Wrapping up

Please let me know if I forgot any of the challengers or if you think my explanation of your code misses something important.

If you want to participate to the Perl Weekly Challenge, please connect to [this site](https://perlweeklychallenge.org/).
