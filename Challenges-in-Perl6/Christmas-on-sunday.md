# Christmas on Sunday


This is derived in part from my [blog post](http://blogs.perl.org/users/laurent_r/2019/10/perl-weekly-challenge-30-sunday-christmas-and-triplets.html) made in answer to the [Week 30 of the Perl Weekly Challenge](https://perlweeklychallenge.org/blog/perl-weekly-challenge-030/) organized by  <a href="http://blogs.perl.org/users/mohammad_s_anwar/">Mohammad S. Anwar</a> as well as answers made by others to the same challenge.

The challenge reads as follows:

*Write a script to list dates for Sunday Christmas between 2019 and 2100. For example, 25 Dec 2022 is Sunday.*

## My Solutions

In Perl 6/Raku, the `Date` data type offers the built-in methods we need for date computations, including finding day of week.

``` Perl6
use v6;
for 2019..2100 -> $year {
    say "Christmas of year $year falls on a Sunday." 
        if Date.new($year, 12, 25).day-of-week == 7;
}
```

which duly prints out:

    Christmas of year 2022 falls on a Sunday.
    Christmas of year 2033 falls on a Sunday.
    Christmas of year 2039 falls on a Sunday.
    Christmas of year 2044 falls on a Sunday.
    Christmas of year 2050 falls on a Sunday.
    Christmas of year 2061 falls on a Sunday.
    Christmas of year 2067 falls on a Sunday.
    Christmas of year 2072 falls on a Sunday.
    Christmas of year 2078 falls on a Sunday.
    Christmas of year 2089 falls on a Sunday.
    Christmas of year 2095 falls on a Sunday.

We could also do it in the form of a Perl 6 one-liner:

    $ perl6 -e 'say grep {Date.new($_, 12, 25).day-of-week == 7}, 2019..2100;'
    (2022 2033 2039 2044 2050 2061 2067 2072 2078 2089 2095)

 ## Alternate Solutions

 I did not keep track of the number of contributions, but it seems to me that, with 15 solutions, this might be the most successful challenge so far in Perl 6. This may have to do with the fact that the core Perl 6 has all built-in methods to easily solve the task.

 [Arne Sommer](https://github.com/manwar/perlweeklychallenge-club/blob/master/challenge-030/arne-sommer/perl6/ch-1.p6) suggested a solution quite similar to mine:

``` Perl6
unit sub MAIN (UInt :$from = 2019, UInt :$to = 2100);
for $from ... $to -> $year
{
  say "25 Dec $year is Sunday." if Date.new($year, 12, 25).day-of-week == 7;
}
```

[Kevin Colyer](https://github.com/manwar/perlweeklychallenge-club/blob/master/challenge-030/kevin-colyer/perl6/ch-1.p6) took essentially the same approach as my one-liner above, but using the `==>` forward feed operator to chain the statements:

``` Perl6
2019..2100 ==> map { Date.new($_,12,25) } ==> grep { $_.day-of-week==7} ==> map { say $_.yyyy-mm-dd };
```

[Mark Senn](https://github.com/manwar/perlweeklychallenge-club/blob/master/challenge-030/mark-senn/perl6/ch-1.p6) also used essentially the same idea:

``` Perl6
for (2019..2100) -> $year  {
    (Date.new(day =>25, month=>12, year=>$year).day-of-week == 7)
        and  say "25 Dec $year";
}
```

[Noud](https://github.com/manwar/perlweeklychallenge-club/blob/master/challenge-030/noud/perl6/ch-1.p6) worked along the same lines:

``` Perl6
for 2019 .. 2100 -> $year {
    if (Date.new($year, 12, 25).day-of-week == 7) {
        $year.say;
    }
}
```

[Simon Proctor](https://github.com/manwar/perlweeklychallenge-club/blob/master/challenge-030/simon-proctor/perl6/ch-1.p6)'s program is similar to most others seen so far:

``` Perl6
.say for (2019..2100).map( { Date.new( :year($_), :day(25), :month(12) ) } ).grep( *.day-of-week == 7 );
```

[Athanasius](https://github.com/manwar/perlweeklychallenge-club/blob/master/challenge-030/athanasius/perl6/ch-1.p6) made, as often, a relatively long full-fledged program, but using the same `Date` methods as other challengers:

``` Perl6

my UInt constant $START-YEAR    = 2019;
my UInt constant $END-YEAR      = 2100;
my UInt constant $DECEMBER      =   12;
my UInt constant $CHRISTMAS-DAY =   25;
my UInt constant $SUNDAY        =    7;
my Str  constant $FORMAT        = 'Between %d and %d (inclusive), Christmas ' ~
                                  "Day (%dth December) falls on a\nSunday "   ~
                                  "in %s, and %s\n";

sub MAIN()
{
    my UInt @years;
    for $START-YEAR .. $END-YEAR -> UInt $year
    {
        my Date $date = Date.new($year, $DECEMBER, $CHRISTMAS-DAY);

        @years.push: $year if $date.day-of-week == $SUNDAY;
    }
    my UInt $final-year = @years.pop;
    $FORMAT.printf:
        $START-YEAR, $END-YEAR, $CHRISTMAS-DAY, @years.join(', '), $final-year;
}
```

[Daniel Mita](https://github.com/manwar/perlweeklychallenge-club/blob/master/challenge-030/daniel-mita/perl6/ch-1.p6) planned some extra features, but, when removing them, the gist of his implementation is essentially along the same lines as most others:

``` Perl6
for 2019 .. 2100 -> $year {
    given Date.new( :$year, :12month, :25day ) {
      if .day-of-week == 7 { .say }
    }
}
```

[Jaldhar H. Vyas](https://github.com/manwar/perlweeklychallenge-club/blob/master/challenge-030/jaldhar-h-vyas/perl6/ch-1.sh) suggested the following one-liner:

    perl6 -e '"$_-12-25".say for (2019..2100).grep({Date.new($_,12,25).day-of-week==0;});'

which was apparently influenced by his Perl 5 implementation and doesn't work properly because it compares the return value of the `.day-of-week` method to 0, whereas it should be compared to 7. I guess it's simply a typo. Making that small change fixes the issue and enables the one-liner to work properly:

    $ ./perl6 -e '"$_-12-25".say for (2019..2100).grep({Date.new($_,12,25).day-of-week==7;});'
    2022-12-25
    2033-12-25
    (... lines omitted for brevity)
    2089-12-25
    2095-12-25

[Joelle Maslak](https://github.com/manwar/perlweeklychallenge-club/blob/master/challenge-030/joelle-maslak/perl6/ch-1.p6) also used the same general idea:

``` Perl6
sub MAIN(:$start = 2019, :$end = 2100) {
    my $christmasses = ($start..$end).map({ DateTime.new(:25day, :12month, :year($_)) });
    my $on-sunday = $christmasses.grep: *.day-of-week == 7;
    say $on-sunday».yyyy-mm-dd.join("\n");
}
```

[Markus Holzer](https://github.com/manwar/perlweeklychallenge-club/blob/master/challenge-030/markus-holzer/perl6/ch-1.p6) also used the same feature as others, with just a different syntax:

```Perl6
constant \SUNDAY = 7;
.say for
    ( 2019 .. 2100 )
    .map(  { DateTime.new( :$^year, month => 12, day => 25 ) })
    .grep( { .day-of-week == SUNDAY })
    .map(  { .year })
;
```

[Roger Bell West](https://github.com/manwar/perlweeklychallenge-club/blob/master/challenge-030/roger-bell-west/perl6/ch-1.p6) made a one-line version of the same:

```Perl6
map {say "$_"}, grep {Date.new($_,12,25).day-of-week==7}, (2019..2100);
```

[Ruben Westerberg](https://github.com/manwar/perlweeklychallenge-club/blob/master/challenge-030/ruben-westerberg/perl6/ch-1.p6) made yet another version of essentially the same:

```Perl6
(2020..2099).map({
	my $t=Date.new(year=>$_,month=>12,day=>25);
	$t.day-of-week==7??$t!!|();
})>>.put;
```

[Ulrich Rieke](https://github.com/manwar/perlweeklychallenge-club/blob/master/challenge-030/ulrich-rieke/perl6/ch-1.p6) also used the same basic technique:

```Perl6
my @dates ;
for (2019..2100) -> $year {
  my $d = Date.new( $year , 12 , 25 ) ;
  if ( $d.day-of-week == 7 ) {
      @dates.push( $d ) ;
  }
}
@dates.map( { say ~$_ } ) ;
```

[Yet Ebreo](https://github.com/manwar/perlweeklychallenge-club/blob/master/challenge-030/yet-ebreo/perl6/ch-1.p6) used essentially the same technique as most others:

```Perl6
for 2019..2100 -> $year {
    my $date = Date.new($year, 12, 25);
    if ($date.day-of-week == 7) {
        say "12/25/$year"
    }
}
```

## See also

Only two blog posts this time (in addition to mine):

Arne Sommer: https://perl6.eu/xmas-12.html;

Jaldhar H. Vyas: https://www.braincells.com/perl/2019/10/perl_weekly_challenge_week_30.html.

## Wrapping up

Please let me know if I forgot any of the challengers or if you think my explanation of your code misses something important (send me an e-mail or just raise an issue against this GitHub page).



