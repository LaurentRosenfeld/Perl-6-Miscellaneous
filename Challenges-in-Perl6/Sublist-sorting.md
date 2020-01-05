# Sublist Sorting 

This is derived in part from my [blog post](http://blogs.perl.org/users/laurent_r/2019/12/perl-weekly-challenge-40-multiple-arrays-content-and-sublist-sorting.html) made in answer to the [Week 40 of the Perl Weekly Challenge](https://perlweeklychallenge.org/blog/perl-weekly-challenge-038/) organized by  <a href="http://blogs.perl.org/users/mohammad_s_anwar/">Mohammad S. Anwar</a> as well as answers made by others to the same challenge.

The challenge reads as follows:


*You are given a list of numbers and set of indices belong to the list. Write a script to sort the values belongs to the indices.*

*For example,*

	List: [ 10, 4, 1, 8, 12, 3 ]
	Indices: 0,2,5

*We would sort the values at indices 0, 2 and 5 i.e. 10, 1 and 3.*

*Final List would look like below:*

    List: [ 1, 4, 3, 8, 12, 10 ]

## My Solution

This is the perfect example for using array slices, which was the subject of a challenge a few weeks ago. We'll use slices twice: once as a *rvalue* to extract from the list the values to be sorted, and once again as a *lvalue* for inserting the sorted values back into the array at their proper position.

Note that Raku's sort procedure is clever enough to discover that it should perform numeric sort when it sees numbers (well, more accurately, it is the default [cmp](https://docs.raku.org/routine/cmp) operator used by `sort` which is smart enough to compare strings with string semantics and numbers with number semantics).

And we end up with a single line of code doing all the real work:

``` Perl6
use v6;

my @numbers = 10, 4, 1, 8, 12, 3;
my @indices = 0, 2, 5;

@numbers[@indices] = sort @numbers[@indices];
say @numbers;
```

This program displays the following output:

    $ perl6 sublists.p6
    [1 4 3 8 12 10]

## Alternative Solutions

[Arne Sommer](https://github.com/manwar/perlweeklychallenge-club/blob/master/challenge-040/arne-sommer/perl6/ch-2.p6) made a solution even simpler than mine and avoided to repeat the name of the array variable. The bulk of the work holds in a short code line:

``` Perl6
@array[@indices].=sort;
```

[Noud](https://github.com/manwar/perlweeklychallenge-club/blob/master/challenge-040/noud/perl6/ch-2.p6) offered a solution very similar to mine!

``` Perl6
sub subsort(@arr, @ind) {
    @arr[@ind] = @arr[@ind].sort; @arr;
}
say subsort([10, 4, 1, 8, 12, 3], [0, 2, 5]);
```

[Ryan Thompson](https://github.com/manwar/perlweeklychallenge-club/blob/master/challenge-040/ryan-thompson/perl6/ch-2.p6) also made a program quite similar to mine:

``` Perl6
@list[@idx] = @list[@idx].sort;
@list.say;
```

[Simon Proctor](https://github.com/manwar/perlweeklychallenge-club/blob/master/challenge-040/simon-proctor/perl6/ch-2.p6) used essentially the same technique:

``` Perl6
@list[@indices] = @list[@indices].sort;
```

[Burkhard Nickels](https://github.com/manwar/perlweeklychallenge-club/blob/master/challenge-040/burkhard-nickels/perl6/ch-2.p6) participated to the Raku challenge for the first time. His program is slightly more complicated than those seen so far, as it involves two steps, but it also relies on slices:

``` Perl6
my @a = (10,4,1,8,12,3);
my @i = (0,2,5);

print "Before:", join(" - ", @a), "\n";
my @d = @a[0,2,5];
@a[0,2,5] = @d.sort( { .Int } );
print "After: ", join(" - ", @a), "\n";
```

[Javier Luque](https://github.com/manwar/perlweeklychallenge-club/blob/master/challenge-040/javier-luque/perl6/ch-2.p6)'s program also also does the work in two steps: 

``` Perl6
my @list = (10, 4, 1, 8, 12, 3);
my @indices = (0, 2, 5);

my @sublist = @list[@indices].sort;

# Override the original array
my $i = 0;
for (@indices) -> $index {
    @list[$index] = @sublist[$i++];
}
say @list;
```

[Roger Bell West](https://github.com/manwar/perlweeklychallenge-club/blob/master/challenge-040/roger-bell-west/perl6/ch-2.p6) also wrote a program doing the work in two steps:

``` Perl6
my @list=(10, 4, 1, 8, 12, 3);
my @indices=(0,2,5);

my @s=(map {@list[$_]},@indices).sort;
map {@list[@indices[$_]]=@s[$_]},(0..@indices.end);

print join(', ',@list),"\n";
```

[Ruben Westerberg](https://github.com/manwar/perlweeklychallenge-club/blob/master/challenge-040/ruben-westerberg/perl6/ch-2.p6) clearly wins the conciseness prize on this task:

``` Perl6
put @a[@i].sort;
```

## See also

Only two blog posts (besides mine), or perhaps three, for this task:

* Arne Sommer: https://raku-musings.com/arrays.html;

* Javier Luque: https://perlchallenges.wordpress.com/2019/12/23/perl-weekly-challenge-040/.

Burkhard Nickels apparently blogged twice about the challenge, but I was unable to find his blog posts, as the links provided seem to be faulty.

## Wrapping up

Please let me know if I forgot any of the challengers or if you think my explanation of your code misses something important (send me an e-mail or just raise an issue against this GitHub page).

If you want to participate to the Perl Weekly Challenge, please connect to [this site](https://perlweeklychallenge.org/).


