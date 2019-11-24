# Dispatch Tables

This is derived in part from my [blog post](http://blogs.perl.org/users/laurent_r/2019/11/perl-weekly-challenge-34-array-and-hash-slices-and-dispatch-tables.html) made in answer to the [Week 34 of the Perl Weekly Challenge](https://perlweeklychallenge.org/blog/perl-weekly-challenge-034/) organized by  <a href="http://blogs.perl.org/users/mohammad_s_anwar/">Mohammad S. Anwar</a> as well as answers made by others to the same challenge.

The challenge, contributed by Dave Cross,  reads as follows:

*Write a program that demonstrates a dispatch table.*

A dispatch table is a table (e.g. an array or more commonly a hash) of subroutine references or other code objects.

## My Solution

For this task, we want to do a bit more than simply demonstrate the syntax: we will try to do something (moderately) useful with it.

Suppose we have a text file and want to feed each word from the file into 26 files (one per letter of the alphabet) depending on the first letter of the word. This could be done with a monstrous `if ... elsif ... else` or `given ... when` construct, or we could use a dispatch table, in this case a hash containing for each letter a code reference printing the word into the proper file. As we will see, this produces much shorter and simpler code. We will even use a dynamic dispatch table, i.e. only create the hash entries (and files) that are needed with the input file. 

We first write a `function_builder` subroutine that acts as a function factory. It receives a letter as a parameter, creates a file name for that letter, opens the corresponding file in `:w`  (write) mode, and it returns an anonymous code block (actually a closure) that writes its argument to the file handle. This anonymous code block will be stored into the dispatch table.

In the `MAIN` subroutine , the program reads the words of the input file, fold them to lower case, and finds the first character of each such word. To avoid file name problems with special characters, we only keep words starting with a letter. If the dispatch table has no entry yet for this letter, the program calls `function_builder` subroutine to open the proper file and stores the code reference returned by that subroutine in the dispatch table. Finally, the program calls the code reference stored in the dispatch table for word's first letter.

``` Perl6
use v6;

sub function_builder (Str $letter) {
    my $file_name = "letter_$letter.txt";
    my $fh = open "./$file_name", :w;
    return { $fh.say($^a) }
}

multi sub MAIN (Str $file where *.IO.f) {
    my %dispatch;
    for $file.IO.words.map({.lc}) -> $word {
        my $letter = substr $word, 0, 1;
        next if $letter !~~ /^<[a..z]>/; 
        %dispatch{$letter} = function_builder $letter unless defined %dispatch{$letter};
        %dispatch{$letter}($word);
    }
}
```

Running the program and passing it the `hash_slices.p6` file (the [script](https://github.com/LaurentRosenfeld/Perl-6-Miscellaneous/blob/master/Challenges-in-Perl6/Array-and-hash-slices.md) of task # 1 of this week) produced the following files in the default directory:

    -rwxr-xr-x  1 Laurent Aucun       5 11 nov.  18:26  letter_u.txt
    -rwxr-xr-x  1 Laurent Aucun       5 11 nov.  18:26  letter_v.txt
    -rwxr-xr-x  1 Laurent Aucun       3 11 nov.  18:26  letter_c.txt
    -rwxr-xr-x  1 Laurent Aucun       6 11 nov.  18:26  letter_q.txt
    -rwxr-xr-x  1 Laurent Aucun       5 11 nov.  18:26  letter_e.txt
    -rwxr-xr-x  1 Laurent Aucun      72 11 nov.  18:26  letter_s.txt
    -rwxr-xr-x  1 Laurent Aucun      29 11 nov.  18:26  letter_m.txt
    -rwxr-xr-x  1 Laurent Aucun      18 11 nov.  18:26  letter_j.txt
    -rwxr-xr-x  1 Laurent Aucun      19 11 nov.  18:26  letter_l.txt
    -rwxr-xr-x  1 Laurent Aucun      13 11 nov.  18:26  letter_h.txt
    -rwxr-xr-x  1 Laurent Aucun       8 11 nov.  18:26  letter_d.txt
    -rwxr-xr-x  1 Laurent Aucun      22 11 nov.  18:26  letter_a.txt

This is the file generated for letter "a":

    $ cat letter_a.txt
    array
    a
    array:
    as

## Alternative Solutions

My initial idea, when I started to consider this challenge, was to implement some form of an arithmetic calculator. I'm happy that I chose something else, as not less than three challengers chose to implement such an arithmetic calculator.

[Arne Sommer](https://github.com/manwar/perlweeklychallenge-club/blob/master/challenge-034/arne-sommer/perl6/ch-2.p6) implemented a program with a user interface in which the user is prompted to enter a command and the program executes the subroutine associated with that command in a `%dispatch` hash:

``` Perl6
my $value = 0;
my %dispatch =
(
  q      => &last,
  quit   => &last, 
  d      => &double,
  double => &double,
  h      => &half,
  half   => &half,
  c      => &clear,
  clear  => &clear,
  help   => &help,
);
loop
{
  my $command = prompt "[$value]: ";

  if %dispatch{$command}     { %dispatch{$command}(); }
  elsif $command ~~ /^(\d)$/ { set($0.Int); }
}
sub last
{
  exit;
}
sub double
{
  $value *= 2;
}
sub half
{
  $value /= 2;
}
sub clear
{
  $value = 0;
}
sub set ($new)
{
  $value = $new;
}
sub help
{
  say "Please consult a doctor.";
}
```

[Kevfin Colyer](https://github.com/manwar/perlweeklychallenge-club/blob/master/challenge-034/kevin-colyer/perl6/ch-2.p6) also implemented a user interface for a game in which the user is prompted to enter a command and the program executes the subroutine associated with that command in a `%dispatch` hash:

``` Perl6
my %dispatch =
    debug => &_debug,
    test => &_test,

    save => &_savegame,

    help => &help,
    h => &help,
    north => &north,
    n => &north,
    south => &south,
    s => &south,
    east => &east,
    e => &east,
    west => &west,
    w => &west,
    quit => &quit,
    q => &quit,
    examine => &examine,
    x => &examine,
    look => &look,
    l => &look,
    score => &score,
    inventory => &inventory,
    i => &inventory,
    get => &get,
    take => &get,
    drop => &drop,
    drink => &drink,
;
```
Kevin then provides the code for all the subroutines listed in the dispatch table. I'll quote only a few of them:

``` Perl6
sub score($v,$a,$n) { "You have scored {%flags<score>} out of a possible {%flags<max_score>} points." };

sub _debug($v,$a,$n) { %flags<_debug>= $n~~ "on" ?? True !! False; "debug on: " ~ %flags<_debug> };

sub _test($v,$a,$n) { "testing here!" };

sub _savegame($v,$a,$n) {my $f= "save.game"; $f.IO.spurt: { flags => %flags, objects => %objects, rooms => %rooms }.perl; "Saved to file [$f]" };
```

[Noud](https://github.com/manwar/perlweeklychallenge-club/blob/master/challenge-034/noud/perl6/ch-2.p6) suggested a simple `%dispatch` table with three items:

``` Perl6
sub hello() {
    "Hello";
}
sub fib($n) {
    if ($n < 1) {
        return 0;
    }
    if ($n == 1) {
        return 1;
    }
    return fib($n - 1) + fib($n - 2);
}
my %dispatch = (
    hello => &hello,
    world => sub { "World"; },
    fib => &fib
);
say %dispatch{"hello"}() ~ " " ~ %dispatch{"world"}();
say %dispatch{"fib"}(20);
```

[Simon Proctor](https://github.com/manwar/perlweeklychallenge-club/blob/master/challenge-034/simon-proctor/perl6/ch-2.p6) contributed a program that can be launched with two parameters, an action and an integer value. As you might have guessed, the authorized actions are stored in a `%commands` dispatch table. His program then performs action required by the first argument on the second argument:

``` Perl6
# Possible actions
sub doubler ( Int $x ) { $x * 2 }
sub halver ( Int $x ) { $x / 2 }
sub squarer ( Int $x ) { $x * $x }
sub reverser ( Int $x ) { $x.flip.Int }
sub zeroer ( Int $x ) { 0 }

# Despatch table
my %commands = (
    "double"  => &doubler,
    "halve"   => &halver,
    "square"  => &squarer,
    "reverse" => &reverser,
    "zero"    => &zeroer,
);

#| Help
multi sub MAIN( Bool :h(:$help) where so * ) {
    say $*USAGE;
}

#| Use despatch table to run the given command
multi sub MAIN(
    Str $command where { %commands{$command}:exists }, #= Valid command from double, halve, square, reverse, zero
    Int() $value #= Value to apply command to
) {
    say "{$command}( {$value} ) => {%commands{$command}($value)}"; 
}
```

[Ulrich Rieke](https://github.com/manwar/perlweeklychallenge-club/blob/master/challenge-034/ulrich-rieke/perl6/ch-2.p6) provided a program with a user interface in which the user is prompted to enter a code for an arithmetic operation and two numbers. The program then uses a `%dispatcher` table to perform the requested operation:

``` Perl6
#demonstrating the use of a dispatcher, without much of input validation

sub add( Numeric $a , Numeric $b ) {
  return $a + $b ;
}

sub subtract( Numeric $a , Numeric $b ) {
  return $a - $b ;
}

sub multiply( Numeric $a , Numeric $b ) {
  return $a * $b ;
}

sub divide( Numeric $a , Numeric $b ) {
  return $a / $b ;
}

say "Enter a number from 1 to 4 to indicate what you want to do!" ;
say "1) add" ;
say "2) subtract" ;
say "3) multiply" ;
say "4) divide" ;
my $answer = $*IN.get ;
my $choice = $answer.substr(0, 1 ) ;
while ( +$choice < 1 || +$choice > 4 )  {
  say "Enter a number from 1 to 4 to indicate what you want to do!" ;
  say "1) add" ;
  say "2) subtract" ;
  say "3) multiply" ;
  say "4) divide" ;
  $answer = $*IN.get ;
  $choice = $answer.substr(0, 1 ) ;
}
say "Enter your 2 operands: ( 2 in a row separated by spaces )" ;
my $numberline = $*IN.get ;
my @numbers = $numberline.split(/\s+/) ;
while @numbers.elems < 2 {
  say "Enter your 2 operands: (2 in a row separated by spaces)" ;
  my $numberline = $*IN.get ;
  my @numbers = $numberline.split(/\s+/) ;
}
my %dispatcher = '1' => &add , '2' => &subtract , '3' => &multiply,
  '4' => &divide ;
if ( 1 <= +$choice <= 3 ) {
  say "The result is {%dispatcher{$choice}(+@numbers[0] , +@numbers[1]) }!" ;
}
if (+$choice == 4 ) {
  if (+@numbers[1] == 0) {
      say "Illegal division by 0!" ;
  }
  else {
      say "The result is {%dispatcher{'4'}(+@numbers[0] , +@numbers[1]) }!" ;
  }
}
```

Note that since the user is prompted to enter an integer code for the arithmetic operation, this is a case where the dispatch table could have been implemented as a simple array instead of a hash.

[Javier Luque](https://github.com/manwar/perlweeklychallenge-club/blob/master/challenge-034/javier-luque/perl6/ch-2.p6) also used a dispatch table to implement arithmetic operations:

``` Perl6
sub MAIN () {
    my %dispatch_table = (
        '+' => &add,
        '-' => &subtract,
        'x' => sub ($a , $b) { $a * $b },
        '/' => -> $a , $b { $a / $b },
    );

    my @equations = ('2 + 2', '10 - 4', '3 x 3', '25 / 5');
    for (@equations) -> $equation {
        ($equation ~~ /^(\d+)\s*(\+|\-|x|\/)\s*(\d+)$/);
        say $equation ~ ' = ' ~
            %dispatch_table{$1}($0, $2);
    }
}

sub add(Num() $a, Num() $b)      { return ($a + $b); }
sub subtract(Num() $a, Num() $b) { return ($a - $b); }
```

Note that Javier is the only challenger who used an anonymous subroutine reference and an anonymous code block defined directly in the dispatch table (for the multiplication and the division), although Ruben Westerberg did something vaguely similar. This is an interesting syntax, as it tends to make the code simpler and more concise (at least when the subroutine is simple enough).

[Roger Bell West](https://github.com/manwar/perlweeklychallenge-club/blob/master/challenge-034/roger-bell-west/perl6/ch-2.p6) also implemented an arithmetic calculator, but in the form of a stack machine. His dispatch table looks like this:

``` Perl6
my %op=(
  add => &add,
  '+' => &add,
  sub => &sub,
  '-' => &sub,
  mul => &mul,
  '*' => &mul,
  div => &div,
  '/' => &div,
  neg => &neg,
  dup => &dup,
  pop => &pop,
  exch => &exch,
    );
```

[Jaldhar H. Vyas](https://github.com/manwar/perlweeklychallenge-club/blob/master/challenge-034/jaldhar-h-vyas/perl6/ch-2.p6) implemented a rock, paper, and scissors game simulation:

``` Perl6
my @choices = ( &chose_paper, &chose_scissors, &chose_rock );

my @outcomes = (
    (    &draw,              &scissors_loss,     &paper_win,    ),
    (    &scissors_win,      &draw,              &rock_loss,    ),
    (    &paper_loss,        &rock_win,          &draw,         )
);   

my @winners = ( &winner_A, &winner_B );

sub chose_paper($chooser) {
    say "$chooser chose Paper.";
}
sub chose_scissors($chooser) {
    say "$chooser chose Scissors.";
}
sub chose_rock($chooser) {
    say "$chooser chose Rock.";
}
sub paper_win {
    say "Paper covers Rock.  ";
    @winners[0]();
}
sub paper_loss {
    say "Paper covers Rock.  ";
    @winners[1]();
}
sub scissors_win {
    say "Scissors cuts Paper.  ";
    @winners[0]();
}
sub scissors_loss {
    say "Scissors cuts Paper.  ";
    @winners[1]();
}
sub rock_win {
    say "Rock smashes Scissors.  ";
    @winners[0]();
}
sub rock_loss {
    say "Rock smashes Scissors.  ";
    @winners[1]();
}
sub draw {
    say "It's a draw.";
}
sub winner_A {
    say "A wins.";
}
sub winner_B {
    say "B wins.";
}
sub MAIN() {
    my $achoice = (0..2).roll;
    my $bchoice = (0..2).roll;

    @choices[$achoice]('A');
    @choices[$bchoice]('B');

    @outcomes[$achoice][$bchoice]();
}
```
[Ruben Westerberg](https://github.com/manwar/perlweeklychallenge-club/blob/master/challenge-034/ruben-westerberg/perl6/ch-2.p6) implemented an array of 10 anonymous subroutines called randomly:

``` Perl6
my @dispatch= (1..10).map( { my $i=$_;sub { templateSub($i)}});

@dispatch[@dispatch.elems.rand.Int]() for @dispatch;

sub templateSub($i) {
	put "Hello from function $i";
}
```

## See Also

Three blog posts this time:

* Arne Sommer: https://raku-musings.com/sliced-dispatch.html;
* Jaldhar H. Vyas: https://www.braincells.com/perl/2019/11/perl_weekly_challenge_week_34.html;
* Javier Luque: https://perlchallenges.wordpress.com/2019/11/11/perl-weekly-challenge-034/

## Wrapping up

Please let me know if I forgot any of the challengers or if you think my explanation of your code misses something important (send me an e-mail or just raise an issue against this GitHub page).



