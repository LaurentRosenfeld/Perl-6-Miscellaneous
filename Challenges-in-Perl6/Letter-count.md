# Letter Count

This is derived in part from my [blog post](http://blogs.perl.org/users/laurent_r/2019/11/perl-weekly-challenge-33-count-letters-and-multiplication-tables.html) made in answer to the [Week 33 of the Perl Weekly Challenge](https://perlweeklychallenge.org/blog/perl-weekly-challenge-033/) organized by  <a href="http://blogs.perl.org/users/mohammad_s_anwar/">Mohammad S. Anwar</a> as well as answers made by others to the same challenge.

The challenge reads as follows:

*Create a script that accepts one or more files specified on the command-line and count the number of times letters appeared in the files.*

*So with the following input file sample.txt:*

    The quick brown fox jumps over the lazy dog.

*the script would display something like:*

    a: 1
    b: 1
    c: 1
    d: 1
    e: 3
    f: 1
    g: 1
    h: 2
    i: 1
    j: 1
    k: 1
    l: 1
    m: 1
    n: 1
    o: 4
    p: 1
    q: 1
    r: 2
    s: 1
    t: 2
    u: 2
    v: 1
    w: 1
    x: 1
    y: 1
    z: 1

This is not specified explicitly, but from the example, we gather that what is desired here is a case-insensitive letter count (in the example, both "T" and "t" count as "t"). So we will apply the `lc` (lower case) built-in function to the input.

## My Solution

When solving the same task in Perl 5 for the weekly challenge, we used a hash as an histogram, i.e. as a collection of counters. We could do the same in Raku (formerly known as Perl 6). In Raku, however, we can also use a `Bag`, named `$histo`, rather than a hash, to easily implement an histogram. With just a little bit of work, we're able to populate the bag in just one statement, without any explicit loop. Also, if a letter does not exist in the `$histo` bag, the bag will report 0, so that, contrary to the hash solution, we don't need any special code to avoid an `undefined` warning for such an edge case. All this makes the code much more concise than its Perl 5 counterpart.

``` Perl6
use v6;

sub MAIN (*@files) {
    my $histo = (map {.IO.comb».lc}, @files).Bag;
    say "$_ : ", $histo{$_} for 'a'..'z';
}
```

Used with one input file, the program displays the following:

    $ perl6 histo_let.p6 intersection.pl
    a : 96
    b : 46
    c : 25
    d : 22
    e : 72
    f : 19
    g : 20
    h : 4
    i : 77
    j : 0
    k : 0
    [... Lines omitted for brevity ...]
    y : 31
    z : 0

And it works similarly with several input files:

    $ ./perl6 histo_let.p6 intersection.pl histo*
    a : 199
    b : 154
    c : 123
    d : 111
    e : 271
    f : 99
    g : 37
    h : 49
    i : 170
    j : 4
    k : 11
    [... Lines omitted for brevity ...]
    y : 68
    z : 9

Note that we're not trying to filter alphabetical characters when populating the `$histo` bag: we're simply printing out only the bag entries for the `'a'..'z'` range.

## Alternative Approaches

Not less than 17 solutions were submitted for this task, which is probably the largest count so far.

[Arne Sommer](https://github.com/manwar/perlweeklychallenge-club/blob/master/challenge-033/arne-sommer/perl6/ch-1.p6) provided a very compact solution, at least in terms of the way of populating a `Bag` of counters:

``` Perl6
my %result = $*ARGFILES.comb>>.lc.grep(* ~~ /<:L>/).Bag;

for %result.keys.sort -> $key
{
  say "$key: %result{$key}";
}
```

[Mark Senn](https://github.com/manwar/perlweeklychallenge-club/blob/master/challenge-033/mark-senn/perl6/ch-1.p6) also suggested a fairly concise solution, using a hash:

``` Perl6
my %count;
$*ARGFILES.lines.lc.comb(/<[a..z]>/).map({%count{$_}++});
%count.keys.sort.map({"$_: %count{$_}".say});
```

[Markus Holzer](https://github.com/manwar/perlweeklychallenge-club/blob/master/challenge-033/markus-holzer/perl6/ch-1.p6) also contributed a rather compact solution (even though it does not look so at first glance because of its formatting), holding in just one statement:

``` Perl6
sub MAIN( *@files )
{
    .say for @files
        .map({ |.IO.lines.lc.comb( /\w/ ) })
        .Bag
        .sort
        .map({  "{.key}: {.value}" })
    ;
}
```

[Daniel Mita](https://github.com/manwar/perlweeklychallenge-club/blob/master/challenge-033/daniel-mita/perl6/ch-1.sh) made an even more compact solution in the form of a Raku one-liner also using a `Bag`:

    perl6 -e '.say for @*ARGS ?? slurp.lc.comb(/<[a..z]>/).Bag.sort !! "give at least 1 filename"'

[Ryan Thompson](https://github.com/manwar/perlweeklychallenge-club/blob/master/challenge-033/ryan-thompson/perl6/ch-1.p6) also used a `Bag` and provided perhaps the most concise solution of all:

``` Perl6
.fmt('%s: %d').say for $*ARGFILES.comb».lc.Bag{'a'..'z'}:p;
```

[Kevin Colyer](https://github.com/manwar/perlweeklychallenge-club/blob/master/challenge-033/kevin-colyer/perl6/ch-1.p6) went the other way around and provided a comprehensive  solution using a `count` subroutine to populate a temporary and anonymous `BagHash` for each input file, and then merging the result into a final `BagHash`:

``` Perl6
sub count($text) {
    return BagHash.new( $text.lc.comb.grep: * ~~ / <alpha> / );
}

multi MAIN(*@files) {
    my BagHash $bag;
    for @files -> $f {
        next unless $f.IO:f;
        $bag{.key}+=.value for count($f.IO.slurp); # Add returned bag to bag hash
    }
    $bag{"_"}:delete;
    say "$_: {$bag{$_}}" for $bag.keys.collate;
}
```

Kevin's program iterates over the values of the `HashBag` returned by the `count` subroutine to add the values associated with each letter. I suppose it would have been slightly simpler to use the infix `(+)` (or `⊎`) [baggy addition operator](https://docs.perl6.org/language/operators#infix_(+),_infix_%E2%8A%8E) (see Richard Nutall's solution below for an example of this). 

Note that Kevin also provided a `pod` outlining the challenge task and an alternate multi `MAIN` subroutine to run a test suite.

[Richard Nutall](https://github.com/manwar/perlweeklychallenge-club/blob/master/challenge-033/rnuttall/perl6/ch-1.p6), a new member of the Perl Weekly Challenge, used the infix `⊎` baggy addition operator together with the assignment operator to populate his `Bag` of counters in just one statement:

``` Perl6
sub MAIN(*@files) {
    #Task 1 - a Test of Bag and Bag addition
    my Bag $counts = bag { 'a' .. 'z' => 0 };

    # Create a bag for each file and add counts using Bag addition ⊎ or (+)
    $counts ⊎= $_.IO.slurp.lc.comb.Bag for @files;

    say "$_: $counts{$_}"              for 'a' .. 'z';
}
```
Note that I don't think that the loop to initialize the 'a' to 'z' counters of the bag to 0 is necessary: if a letter isn't available in a bag, its count will be reported to be 0 without any error or warning.

[Noud](https://github.com/manwar/perlweeklychallenge-club/blob/master/challenge-033/noud/perl6/ch-1.p6) also supplied a comprehensive detailed solution using a hash:

``` Perl6
sub MAIN(*@files) {
    my %letter_count;
    %letter_count<a b c d e f g h i j k l m
                  n o p q r s t u v w x y z> = 0 xx *;

    for @files -> $file {
        for $file.IO.comb -> $letter {
            if (%letter_count{$letter.lc}:exists) {
                %letter_count{$letter.lc}++;
            }
        }
    }

    for %letter_count.sort(*.key)>>.kv -> ($letter, $count) {
        say "$letter: $count";
    }
}
```

[Simon Proctor](https://github.com/manwar/perlweeklychallenge-club/blob/master/challenge-033/simon-proctor/perl6/ch-1.p6) also went for a quite comprehensive program. He created a `read-files` subroutine to do almost all the work with a `Bag`, as well as three multi `MAIN` subroutines to handle various possible arguments passed to the program:

``` Perl6
multi sub MAIN( Bool :h($help) where so * ) {
    say $*USAGE;
}

#| Read data from standard in.
multi sub MAIN() {
    read-files( IO::CatHandle.new( $*IN ) );
}

#| Given a list of filenames reads each in turn
multi sub MAIN(
    *@files where all(@files) ~~ ValidFile, #= Files to read
) {
    read-files( IO::CatHandle.new( @files ) );
}

sub read-files( IO::CatHandle $files ) {
    my %results := $files.words.map(*.lc.comb()).flat.grep( { $_ ~~ m!<[a..z]>! } ).Bag;  
    .say for ("a".."z").map( { "{$_} : {%results{$_}}" } );
} 
```

[Adam Russell](https://github.com/manwar/perlweeklychallenge-club/blob/master/challenge-033/adam-russell/perl6/ch-1.p6) used a hash for storing the counters and a `for` loop to iterate over the lines of the input:

``` Perl6
sub MAIN {
    my %letter_count; 
    for $*IN.lines() -> $line {
        my @characters = $line.split("");
        for @characters -> $c {
            %letter_count{$c}++ if $c~~m/<alpha>/; 
        } 
    } 
    for sort keys %letter_count -> $key {
        print "$key: %letter_count{$key}\n";
    }  
}
```

[Athanasius](https://github.com/manwar/perlweeklychallenge-club/blob/master/challenge-033/athanasius/perl6/ch-1.p6) is not a challenger from whom I have come to expect very terse programs. As usual, his program, which uses a hash to host the counters, is quite comprehensive:

``` Perl6
sub MAIN
(
    Bool:D :$count = False,         #= Order by letter counts (highest first)
    Bool:D :$help  = False,         #= Print usage details and exit
           *@filenames,             #= Name(s) of file(s) containing text data
)
{
    if $help || @filenames.elems == 0
    {
        $*USAGE.say;
    }
    else
    {
        my UInt %counts;

        for @filenames -> Str $filename
        {
            for $filename.IO.lines -> Str $line
            {
                ++%counts{ .lc } for $line.split('').grep({ rx:i/ <[a..z]> / });
            }
        }

        my &sort-by = $count ?? sub { %counts{ $^b } <=> %counts{ $^a } ||
                                       $^a cmp $^b }
                             !! sub {  $^a cmp $^b };

        "%s: %d\n".printf: $_, %counts{ $_ } for %counts.keys.sort: &sort-by;
    }
}
```

[Jaldhar H. Vyas](https://github.com/manwar/perlweeklychallenge-club/blob/master/challenge-033/jaldhar-h-vyas/perl6/ch-1.p6)  also used a hash to store the counters:

```Perl6
sub MAIN(
    *@files
) {
    my %totals;

    if @files.elems {
        for @files -> $file {
            $file.IO.comb.map({ %totals{$_.lc}++; });
        }
    } else {
        $*IN.comb.map({ %totals{$_.lc}++; });
    }

    %totals.keys.grep({ / <lower> / }).sort.map({
        say "$_: %totals{$_}";
    });
}
```

[Javier Luque](https://github.com/manwar/perlweeklychallenge-club/blob/master/challenge-033/javier-luque/perl6/ch-1.p6) also used a hash for his letter histogram:

``` Perl6
sub MAIN (*@filenames) {
    my %counts;

    # Loop through each file
    for @filenames -> $filename {
        my $fh = $filename.IO.open orelse .die;

        # Increment count for each word char
        while (my $char = $fh.getc) {
            %counts{$char.lc}++ if ($char.lc ~~ /\w/);
        }
    }

    # Print each char and count
    for %counts.keys.sort -> $item {
        "%2s %5i\n".printf($item, %counts{$item});
    }
}
```

[Joelle Maslak](https://github.com/manwar/perlweeklychallenge-club/blob/master/challenge-033/joelle-maslak/perl6/ch-1.p6) also used a hash for storing the counters, but the original side of her solution is that it is Unicode compliant and that it uses graphemes matching the `<alpha>` character class to define its letters:

``` Perl6
sub MAIN(+@filenames) {
    my %letters;
    for @filenames -> $fn {
        my @chars = $fn.IO.lines.comb: /<alpha>/;
        for @chars -> $char {
            %letters{$char.fc}++;
        }
    }

    for %letters.keys.sort -> $key {
        say "$key: {%letters{$key}}";
    }
}
```

[Ruben Westerberg](https://github.com/manwar/perlweeklychallenge-club/blob/master/challenge-033/ruben-westerberg/perl6/ch-1.p6) also used a hash for hosting the counters, and he took special care on the formatting of his output (right-aligning the counters having more than one digit):

``` Perl6
my %letters;
for lines() {
	for $_.split("",:skip-empty) {
		%letters{$_}++ if /<[a..zA..Z]>/;
	}
}

my $m=max map {chars %letters{$_}}, keys %letters;
for sort keys %letters {
	printf "%s: %"~$m~"s\n", $_, %letters{$_};
}
```

This is a sample of this program output with a relatively large input file:

    B:     1
    E:     1
    S:     1
    T:     1
    a: 27904
    b:  2496
    c:  6656
    d:  5376
    e: 22848
    ... (rest omitted for brevity)

[Roger Bell West](https://github.com/manwar/perlweeklychallenge-club/blob/master/challenge-033/roger-bell-west/perl6/ch-1.p6) also used a hash for the counters:

``` Perl6
my %o;

for lines() {
  my $a=lc($_);
  $a ~~ s:g /<-[a .. z]>//;
  map {%o{$_}++}, split '',$a;
}

for sort keys %o -> $k {
  print "$k: %o{$k}\n";
}
```

[Ulrich Rieke](https://github.com/manwar/perlweeklychallenge-club/blob/master/challenge-033/ulrich-rieke/perl6/ch-1.p6) also used a hash for storing the counters:

``` Perl6
sub MAIN( *@ARGS )  {
  for @ARGS -> $file {
      if $file.IO.e {
    my %lettercount ;
    my @words ;
    for $file.IO.lines -> $line {
        @words = $line.split( /\s+/ ) ;
        for @words -> $word {
          my $lowletter = $word.lc ;
          $lowletter ~~ s:g/<-[a..z]>// ;
          my @letters = $lowletter.comb ;
          for @letters -> $letter {
          %lettercount{ $letter }++ ;
          }
        }
    }
    my @sorted = %lettercount.keys.sort( { $^a leg $^b } ) ;
    say "letter frequency in file $file :" ;
    for @sorted -> $letter {
        say "$letter: %lettercount{ $letter }" ;
    }
      }
      else {
    say "Couldn't open file $file!" ;
      }
  }
}
```
I must say that I dislike Ulrich's program inconsistent indentation (this may be due to a problem of tabulations and spaces between his editor and the Github format, but it looks quite bad IMHO) and that his code isn't very perlish (or shall we say "rakuish"?) and sort of looks like C written in Raku. As a minimal attempt to rewrite this fixing the formatting, I would suggest this:

``` Perl6
use v6;

sub MAIN( *@ARGS )  {
    for @ARGS -> $file {
        die "Couldn't open file $file!" unless $file.IO.e;
        my %lettercount;
        for $file.IO.lines -> $line {
            my @words = $line.split( /\s+/ ) ;
            for @words -> $word {
                my $lowletter = $word.lc ;
                $lowletter ~~ s:g/<-[a..z]>// ;
                my @letters = $lowletter.comb ;
                for @letters -> $letter {
                    %lettercount{ $letter }++ ;
                }
            }
        }
        my @sorted = %lettercount.keys.sort( { $^a leg $^b } );
        say "letter frequency in file $file :";
        for @sorted -> $letter {
            say "$letter: %lettercount{ $letter }";
        }
    }
}
```
And, trying to make it look more idiomatic while still keeping the original logic:

``` Perl6
use v6;

sub MAIN( *@ARGS )  {
    my %lettercount;
    for @ARGS -> $file {
        die "Couldn't open file $file!" unless $file.IO.e;        
        for $file.IO.lines.lc.comb -> $char {
            %lettercount{ $char }++ if $char ~~ /<[a..z]>/;
        }
    }
    say "$_: ", %lettercount{$_}//0 for 'a'..'z';
}
```

## See also

Five blog posts this time:

* Arne Sommer: https://raku-musings.com/add-mul.html;

* Adam Russell: https://adamcrussell.livejournal.com/11383.html;

* Jaldhar H. Vyas: https://www.braincells.com/perl/2019/11/perl_weekly_challenge_week_33.html;

* Javier Luque: https://perlchallenges.wordpress.com/2019/11/05/perl-weekly-challenge-033/;

* Roger Ball West: https://blog.firedrake.org/archive/2019/11/Perl_Weekly_Challenge_33.html.


## Wrapping up

Please let me know if I forgot any of the challengers or if you think my explanation of your code misses something important (send me an e-mail or just raise an issue against this GitHub page).




