# Array and Hash Slices

This is derived in part from my [blog post](http://blogs.perl.org/users/laurent_r/2019/11/perl-weekly-challenge-34-array-and-hash-slices-and-dispatch-tables.html) made in answer to the [Week 34 of the Perl Weekly Challenge](https://perlweeklychallenge.org/blog/perl-weekly-challenge-034/) organized by  <a href="http://blogs.perl.org/users/mohammad_s_anwar/">Mohammad S. Anwar</a> as well as answers made by others to the same challenge.

The challenge, contributed by Dave Cross,  reads as follows:

*Write a program that demonstrates using hash slices and/or array slices.*

Slices are a way to access several values of an array or of a hash in one statement, by using multiple subscripts or keys.

## My solutions

If you have an `@array` containing for example some successive integers, you can obtain several values from it with the following syntax: `@array[3, 7, 2]` or even `@array[2..7]`. This is an example under the REPL:

    > my @array = 0..10;
    [0 1 2 3 4 5 6 7 8 9 10]
    > say @array[3, 7, 3]
    (3 7 3)
    > say @array[2..7]
    (2 3 4 5 6 7)

And you can do just about the same with a hash to obtain a bunch of values. Array and hash slices may also be used as *l-values*, i.e. on the left-hand side of an assignment, to populate a new array or a new hash.

``` Perl6
use v6;

my @array = 0..10;
my $count = 0;
my %hash  = map {$_ => ++$count}, 'a'..'j';

say "Array slice :  @array[3..7]";
say "Hash slice 1: ", join ' ', %hash{'b', 'd', 'c'};
say "Hash slice 2: ", join ' ', %hash{'b'..'d'};
say "Hash slice 3: ", join ' ', %hash<b c d>;

# Array slice a l-value
my @new-array = (1, 2);
@new-array[2, 3] = @array[6, 7];
say "New array: ", @new-array;
# Hash slice as l-value:
my @keys = qw/c d e/;
my %new-hash;
%new-hash{@keys} = %hash{@keys};
say "New hash: ", %new-hash;
```

This program produces the following output:

    $ perl6 hash_slices.p6
    Array slice :  3 4 5 6 7
    Hash slice 1: 2 4 3
    Hash slice 2: 2 3 4
    Hash slice 3: 2 3 4
    New array: [1 2 6 7]
    New hash: {c => 3, d => 4, e => 5}

## Alternative Solutions

Maybe it's me missing out something, but I'm a bit disappointed by several of the solutions, which is quite surprising for such a simple challenge. Several solutions just don't really fit the bill. And it seems I'm the only one who thought about using slices as l-values.

[Arne Sommer](https://github.com/manwar/perlweeklychallenge-club/blob/master/challenge-034/arne-sommer/perl6/ch-1.p6) provided a few nice examples of array slices, plus one example of a hash slice. Please run Arne's code to understand anything that isn't obvious to you.

``` Perl6
my @values = <zero one twice thrice four fifth VI seventh acht nine X>;

say @values[0 .. 10];
say @values[0 .. 12];
say @values[10 ... 0];
say @values[7, 4, 1];

my %values = @values.antipairs;

say %values<zero>;
say %values<zero VI nine>;
```

[Kevin Colyer](https://github.com/manwar/perlweeklychallenge-club/blob/master/challenge-034/kevin-colyer/perl6/ch-1.p6) contributed a quite long script, but I'm not quite sure he understood the task, as I fail to see any array or hash slice in his program, which seems to demonstrate complex data structure, such as hashes of hashes, but not slices.

[Simon Proctor](https://github.com/manwar/perlweeklychallenge-club/blob/master/challenge-034/simon-proctor/perl6/ch-1.p6) suggested a quite interesting program that illustrates various relatively advanced features of Raku including, but only marginally, slices, so that the slice features are a bit blurred by the other features. I extracted from his code two examples illustrating the slice feature:

``` Perl6
# Making an array from a Sequence using a slice (^100 is the Range 0..100)
my @fibto100 = (1,1,*+*...*)[^100];

# Use a simple slice to get the first 5 Fibonacci numbers
say "First five Fibonacci numbers {@fibto100[^5].join(",")}";
```

[Ulrich Rieke](https://github.com/manwar/perlweeklychallenge-club/blob/master/challenge-034/ulrich-rieke/perl6/ch-1.p6) also wrote a program that doesn't really convince me in terms of really illustrating hash slices: using `grep` and `:delete` is a good way to filter items of a hash, but that has little to do with slices.  His array slice example is much more convincing:

``` Perl6
#...and of array slices :
my @random_DNA_bases  ;
for (1..63 ) {
  @random_DNA_bases.push( <A C T G>.pick( 1 )) ;
}
my @tripletstarts = @random_DNA_bases[0,3,6...*] ;
say "...and the corresponding triplet starts:" ;
@tripletstarts.say ;
```

[Jaldhar H. Vyas](https://github.com/manwar/perlweeklychallenge-club/blob/master/challenge-034/jaldhar-h-vyas/perl6/ch-1.p6) implemented a recursive binary search algorithm that convincingly uses array slices to provide the arguments to the recursive subroutine calls:

``` Perl6
sub binarySearch(@haystack,  $needle) {
    if @haystack.elems {
        my $mid = (@haystack.elems / 2).Int; 

        if $needle eq @haystack[$mid] { 
            return True;
        }

        if $needle gt @haystack[$mid] { 
            return binarySearch(@haystack[$mid + 1 .. *], $needle);
        } 

        return binarySearch(@haystack[0 .. $mid - 1], $needle);
    }
    return False;
}
```

[Noud](https://github.com/manwar/perlweeklychallenge-club/blob/master/challenge-034/noud/perl6/ch-1.p6) provided a program demonstrating simple hash slices and various array slices:

``` Perl6
# Hash slices
#
# The idea behind hash slices is that you can assign multiple keys at the same
# time with a hash slice.
# Also see: https://docs.perl6.org/language/hashmap#Hash_slices

my %h;
%h<a b c d> = ^4;

say %h;
say %h<a c>;


# Slice indexing
#
# Similar, we can use slicing for extracting slices from an array.
# Also see: https://docs.perl6.org/language/list#Range_as_slice

my @a = ^10;

say @a[0..2];
say @a[^2];
say @a[0..*];
say @a[0..Inf-1];
say @a[0..*-1];
say @a[0..^*-1];
say @a[0..^*/2]; 
```

[Javier Luque](https://github.com/manwar/perlweeklychallenge-club/blob/master/challenge-034/javier-luque/perl6/ch-1.p6) made a very simple program illustrating well the central feature of array and hash slices:

``` Perl6
sub MAIN () {
    my @array = (0..Inf);
    my %hash = ( a => 1, b => 2, c => 3, d => 4 );
    say 'Array slice: ' ~ @array[0..5];
    say 'Hash slice: ' ~ %hash{'a','b'};
}
```

[Roger Bell West](https://github.com/manwar/perlweeklychallenge-club/blob/master/challenge-034/roger-bell-west/perl6/ch-1.p6) suggested a program illustrating array slices:

``` Perl6
my @data=map {rand}, (1..10);
my @ma=map {sum(@data[$_-1..$_+1])/3}, (1..@data.end-1);
unshift @ma,NaN;
push @ma,NaN;
my @out=map {[@data[$_],@ma[$_]]}, (0..@data.end);
say @out.perl;
```

[Ruben Westerberg](https://github.com/manwar/perlweeklychallenge-club/blob/master/challenge-034/ruben-westerberg/perl6/ch-1.p6) made a simple no-frills program illustrating very well array and hash slices:

``` Perl6
#Demonstate array and hash slicing
my @array=(0,1,2,3,4,5,6,7,8,9);
my %hash=(a=>0, b=>1, c=>2, e=>3);
say "Original Array: \n", @array;
say "Original Hash \n",%hash; 

say "Slicing Array with a range [0..3]: ";
say @array[0..3];

say "Slicing Array with duplicate index [0,0]: ";
say @array[0,0];

say 'Slicing hash into another hash %hash{qw<a b>}:kv.hash : ';
say %hash{qw<a b>}:kv.hash;

say 'Slicing hash in to value array %hash{qw<a b>}: ';
say %hash{qw<a b>};
```

[Steven Wilson](https://github.com/manwar/perlweeklychallenge-club/blob/master/challenge-034/steven-wilson/perl6/ch-1.p6), a new member of the challengers team, also provided a simple program illustrating array slices:

``` Perl6
my @numbers = <10 20 30 40 50 60 70 80 90>;
my ( $first_number, $last_number ) = @numbers[0, *-1];
put "First 4 numbers in the array are: @numbers[0 .. 3]";
```

## See Also

Three blog posts this time:

* Arne Sommer: https://raku-musings.com/sliced-dispatch.html;
* Jaldhar H. Vyas: https://www.braincells.com/perl/2019/11/perl_weekly_challenge_week_34.html;
* Javier Luque: https://perlchallenges.wordpress.com/2019/11/11/perl-weekly-challenge-034/

## Wrapping up

Please let me know if I forgot any of the challengers or if you think my explanation of your code misses something important (send me an e-mail or just raise an issue against this GitHub page).



