## Perl 6/Raku Solutions to the Perl Weekly Challenge

I have created this series of blog posts to provide a review of the various Raku (formerly known as Perl 6) solutions to the [Perl Weekly Challenge](https://perlweeklychallenge.org/) organized by  <a href="http://blogs.perl.org/users/mohammad_s_anwar/">Mohammad S. Anwar</a>.

These posts are in part derived from the [blog posts](http://blogs.perl.org/users/laurent_r/) I wrote (with both Perl 5 and Raku solutions) on the challenges. So, in order to reuse part of the material, I'll first describe my own solution or solutions and then review solutions written by others, as well as provide links to other blog posts.

Note that many of these posts were written before Perl 6 was renamed into Raku (in October 2019), so they use the older name of the language.

At this point, the following posts are available:

* [Knapsack Problem](./Knapsack-problem.md) (PWC # 35);
* [Vehicle Identification Numbers (VIN)](./Vehicle_ID_numbers.md) (PWC # 35);
* [Binary-Encoded Morse Code](./Binary-encoded-Morse.md) (PWC # 35, tasks 1 and 2);
* [Dispatch Tables](./Dispatch-tables.md) (PWC # 34);
* [Array and Hash Slices](./Array-and-hash-slices.md) (PWC # 34);
* [Formatted Multiplication Tables](./Formatted-multiplication-tables.md) (PWC # 33);
* [Letter Count](./Letter-count.md) (PWC # 33);
* [ASCII Bar Chart](./ASCII-chart.md) (PWC # 32);
* [Word-Histogram](./Word-histogram.md) (PWC # 32);
* [Dynamic Variable Name](./Dynamic-variable-name.md) (PWC # 31);
* [Illegal Division by Zero](./Illegal-division-by-zero.md) (PWC 31);
* [Integer Triplets whose Sum is 12](./Number-triplets-whose-sum-is-12.md) (PWC 30);
* [Christmas on Sunday](./Christmas-on-sunday.md) (PWC # 30);
* [Calling C code from Perl 6](./Calling-c-code-from-Perl6.md) (PWC # 29);
* [Brace Expansion](./Brace-expansion.md) (PWC # 29);
* [Digital Clock](./Digital-clock.md) (PWC # 28);
* [File Types](./File-types.md) (PWC # 28));
* [Displaying Historical Values](./Historical-values.md) (PWC # 27);
* [Intersection of Two Straight Lines](./Intersection-point.md) (PWC # 27);
* [Mean Angles](./mean-angles.md) (PWC # 26);
* [Common Letter Count](./common-letter-count.md) (PWC # 26);
* [Longest Pokémon Sequences](./Longest-Pokemon-sequence.md) (PWC # 25);
* [Implementation of the Chaocipher Algorithm](./Chaocipher.md) (PWC # 25);
* [Inverted Index](./Inverted-index.md) (PWC # 24);
* [Smallest Script With No Execution Error](./Smallest-script.md) (PWC # 24);
* [Prime Factor Decomposition](./Prime-factorization.md) (PWC # 23)
* [*N*th Order Difference Series](./n-order-forward-difference.md) (PWC # 23)
* [LZW Compression Algorithm](./Compression-algorithm.md) (PWC # 22);
* [Sexy Prime Pairs](./Sexy-primes-pairs.md) (PWC # 22);
* [Euler's number](./Euler-number.md) (PWC # 21);
* [URL Normalization](./URL-normalization.md) (PWC 21);
* [Splitting Strings on Character Change](./Splitting-strings.md) (PWC # 20);
* [Amicable Numbers](./Amicable-numbers.md) ((PWC # 20));
* [Months with Five Weekends](./Five-weekends-in-a-month.md) (PWC # 19);
* [Wrapping Lines](./wrapping-lines.md) (PWC # 19);
* [Longest substring](./Longest-substring.md) (PWC # 18);
* [Priority queues](./Priority-queues.md) (PWC # 18);
* [Parsing URLs](Parsing-URL.md) (PWC # 17);
* [Pythagoras Pie](./Pytagoras-Pie.md) (PWC # 16);
* [Strong and Weak Prime Numbers](./Strong-and-weak-primes.md) (PWC # 15);
* [Vigenère Cypher](./Vigenere-cypher.md) (PWC # 15);
* [Van Eck Sequence](./Van-eck-sequence.md) (PWC # 14);
* [Mutually Recursive Subroutines](./Mutually-recursive-subroutines.md) (PWC # 13);
* [Euclid Numbers](./Euclid-numbers.md) (PWC # 12);
* [Displaying the Identity Matrix](./Identity-matrix.md) (PWC # 11);
* [Roman Numerals](./Roman-numerals.md) (PWC # 10);
* [Squares with Five Distinct Digits](./Squares-with-5-distinct-digits.md) (PWC # 9);
* [Perfect Numbers](./Perfect-numbers.md) (PWC # 8);
* [Niven (or Harshad) Numbers](./Niven-numbers.md) (PWC # 7);
* [Compact Number Ranges](./Compact-number-ranges.md) (PWC # 6);
* [Ramanujan's Constant](./Ramanujan-constant.md) (PWC # 6);
* [Anagrams-of-a-word.md](./Anagrams-of-a-word.md) (PWC # 5);
* [Computing Pi Digits](./Pi-digits.md) (PWC # 4);
* [Five-smooth or Hamming Numbers](./Five-smooth-numbers.md) (PWC # 3).

I've been reviewing solutions for past challenges and will try to continue to do so, as time permits, but giving priority to those which are (IMHO) the most interesting ones.

<a rel="license" href="http://creativecommons.org/licenses/by-sa/4.0/"><img alt="Creative Commons License" style="border-width:0" src="https://i.creativecommons.org/l/by-sa/4.0/88x31.png" /></a><br />This work is licensed under a <a rel="license" href="http://creativecommons.org/licenses/by-sa/4.0/">Creative Commons Attribution-ShareAlike 4.0 International License</a>.

