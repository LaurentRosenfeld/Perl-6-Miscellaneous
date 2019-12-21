# Week Days in Each Month

This is derived in part from my [blog post](http://blogs.perl.org/users/laurent_r/2019/12/perl-weekly-challenge-37-week-days-in-each-month-and-daylight-gainloss.html) made in answer to the [Week 37 of the Perl Weekly Challenge](https://perlweeklychallenge.org/blog/perl-weekly-challenge-037/) organized by  <a href="http://blogs.perl.org/users/mohammad_s_anwar/">Mohammad S. Anwar</a> as well as answers made by others to the same challenge.

The challenge reads as follows:

*Write a script to calculate the total number of weekdays (Mon-Fri) in each month of the year 2019.*

    Jan: 23 days
    Feb: 20 days
    Mar: 21 days
    [... Lines omitted for brevity ...]
    Nov: 21 days
    Dec: 22 days

Although the challenge speaks only of year 2019, I'll expand it a bit to compute the total number of weekdays in each month of any year passed as a parameter (defaulted to 2019 if no year is passed).

## My solutions

Raku (formerly known as Perl 6) has many expressive and efficient built-in features for date manipulations in the [Date](https://docs.raku.org/type/Date) class.

This is an example under the REPL:

    > my $date = Date.new(2019, 1, 1)
    2019-01-01
    > say $date.month;
    1
    > say $date.day-of-week;
    2

So, Jan., 1st, 2019 fell on a Tuesday (day-in-week 2), and it is the first month (January).

Thus, using the `Date` methods demonstrated above, we could write simple a one-liner (formatted here over 2 lines to make more readable on this blog post) to find the result:

    $ perl6 -e 'my @a; for Date.new(2019, 1, 1) .. Date.new(2019, 12, 31) -> $day
    > { @a[$day.month]++ if $day.day-of-week == (1..5).any}; say @a[1..12];
    '
    (23 20 21 22 23 20 23 22 21 23 21 22)

For every date in the year, we increment a counter for the date's month if that data is a weekday. Note the use of the `(1..5).any` junction to simplify comparisons with the `1..5` range.

We could even add a little bit of sugar to improve the output:

    $ perl6 -e 'my @a; for Date.new(2019, 1, 1) .. Date.new(2019, 12, 31) -> $day
    > { @a[$day.month]++ if $day.day-of-week == (1..5).any}; 
    >  for @a[1..12].kv -> $k, $v {printf "%02d/2019: %d week days\n", $k+1, $v};
    > '
    01/2019: 23 week days
    02/2019: 20 week days
    03/2019: 21 week days
    04/2019: 22 week days
    05/2019: 23 week days
    06/2019: 20 week days
    07/2019: 23 week days
    08/2019: 22 week days
    09/2019: 21 week days
    10/2019: 23 week days
    11/2019: 21 week days
    12/2019: 22 week days

But that's perhaps getting a bit long for a one-liner. Let's do a real program. But, for the sake of  fun, we'll use a different method that doesn't need to iterate over every single day of the year.

If we have the number of days for each month of any year (including February), then it is fairly easy to compute the day in the week of any date in the year. We don't really need to do that for every single date because any month, including February, has four weeks, and thus 20 weekdays, between the 1st and the 28th day. Thus, we only need to figure out the day in week of days between the 29th day and the month end.

We will iterate only over the days after the 28th day of any month to find the number of weekdays in that interval, and the `Date` class has numerous numerous method to make this simple. The `Date` class also provides a [days-in-month method](https://docs.raku.org/type/Date#(Dateish)_method_days-in-month) returning directly what we need: the number of days in a given month.

The program is very simple:

``` Perl6
use v6;

sub MAIN (UInt $yr = 2019) {
    for 1..12 -> $mth {
        my $weekdays = 20;
        for 29..Date.new($yr, $mth, 1).days-in-month -> $day {
            $weekdays++ if Date.new($yr, $mth, $day).day-of-week == (1..5).any;
        }
        printf "%02d/%d has $weekdays week days.\n", $mth, $yr;
    }
}
```

This program displays the following output:

    $ perl6 weekdays.p6 2019
    01/2019 has 23 week days.
    02/2019 has 20 week days.
    03/2019 has 21 week days.
    04/2019 has 22 week days.
    05/2019 has 23 week days.
    06/2019 has 20 week days.
    07/2019 has 23 week days.
    08/2019 has 22 week days.
    09/2019 has 21 week days.
    10/2019 has 23 week days.
    11/2019 has 21 week days.
    12/2019 has 22 week days.

And it works fine with another year passed as an argument. If no argument is passed, the program correctly displays the result for the default input value, year 2019. Note that I didn't care about writing the month names in English, but it would be very simple to create an array with the month names in order to convert from month numbers to month names.

## Alternative Solutions

[Arne Sommer](https://github.com/manwar/perlweeklychallenge-club/blob/master/challenge-037/arne-sommer/perl6/ch-1.p6) used the `day-of-week` and `later` methods of the `Date` class and iterated over all the days of the year, similarly to what I did in my one-liner solutions:

``` Perl6
unit sub MAIN (Int $year = 2019, Bool :$sum);

my @day-count;
my @month-name = ("", "Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec");
my $date = Date.new($year, 1, 1); 

while $date.year == $year
{
  @day-count[$date.month]++ if $date.day-of-week <= 5;
  $date.=later(days => 1);
}
say "Year: $year" unless $year == 2019;
say "@month-name[$_]: @day-count[$_] days" for 1 .. 12;
say "Total: { @day-count.sum}" if $sum;
```

[Kevin Colyer](https://github.com/manwar/perlweeklychallenge-club/blob/master/challenge-037/kevin-colyer/perl6/ch-1.p6) did something similar using the `day-of-week` and `later` methods of the `DateTime` class to iterate over all days of the each month:

``` Perl6
my @month-abbrv=<Jan Feb Mar Apr May Jun Jul Aug Sep Oct Nov Dec>;

sub weekdays-in-month(DateTime $date) {
    my $count=0;
    for ^$date.days-in-month -> $day {
        $count++ unless $date.later(days => $day).day-of-week >= 6;
    }
    return $count;
}

for 1..12 -> $month {
    say sprintf "%s: %02d days", @month-abbrv[$month-1],  weekdays-in-month(DateTime.new(year => 2019, month=> $month, day => 1 ));
}
```

[Noud](https://github.com/manwar/perlweeklychallenge-club/blob/master/challenge-037/noud/perl6/ch-1.p6) also used the `day-of-week` and `later` methods of the `Date` class to iterate over all days of the year:

``` Perl6
my @a = [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0];
for ^365 -> $day {
    my $now = Date.new(2019, 1, 1).later(days => $day);
    if (0 < $now.day-of-week < 6) {
        @a[$now.month - 1]++;
    }
}

for <Jan Feb Mar Apr May Jun
     Jul Aug Sep Oct Nov Dec> Z @a -> ($month, $work-days) {
    say "$month: $work-days days";
}
```

[Richard Nuttall](https://github.com/manwar/perlweeklychallenge-club/blob/master/challenge-037/rnuttall/perl6/ch-1.p6), who is new to the challenge if I am not wrong, wrote a nice data pipeline computing for each month the number of days in the month in a single chained-methods statement. Note the interesting use of the `strftime` function of the [DateTime::Format](https://github.com/supernovus/perl6-datetime-format/blob/master/lib/DateTime/Format.pm6) module to provide the month names.

``` Perl6
use v6;
use DateTime::Format;

sub MAIN(Int() $year = Date.today().year()) {
    for 1..12 -> $month {
        my $d    = DateTime.new(year => $year, month => $month, day => 1);
        say strftime('%b', $d) ~ ": " ~
                map({Date.new(2019, $month, $_).day-of-week()},1 .. $d.days-in-month())
                .grep({$_ <= 5})
                .elems;
    }
}
```

[Simon Proctor](https://github.com/manwar/perlweeklychallenge-club/blob/master/challenge-037/simon-proctor/perl6/ch-1.p6) also wrote a data pipeline of chained methods. Note the use of the `weekday-of-month` method of the [Dateish](https://docs.raku.org/type/Dateish#method_weekday-of-month) role:

``` Perl 6
constant %MONTHS := Map.new( (1..12) Z <Jan Feb Mar Apr May Jun Jul Aug Sep Oct Nov Dec> );

sub MAIN(
    Int() $year = Date.today().year() #= Year to display data for, defaults to this year
) {
    for (1..12) -> $month {
        my $end = Date.new( :1day, :$month, :$year ).days-in-month();
        my $total = [+] (0..6).map( { Date.new( :day($end-$_), :$month, :$year ) } ).grep( { $_.day-of-week !~~ 6|7 } ).map( { $_.weekday-of-month } );
        say "{%MONTHS{$month}} : {$total} days";
    }
}
```

[Ulrich Rielke](https://github.com/manwar/perlweeklychallenge-club/blob/master/challenge-037/ulrich-rieke/perl6/ch-1.p6) wrote two nested loops (over months and over days of the month) to iterate over all days of the year and used the `day-of-week` method of the `Date` class to populate a weekday counter for each month:

``` Perl 6
my %daycount = "Jan" => 31 , "Feb" => 28 , "Mar" => 31 , "Apr" => 30 ,
  "May" => 31 , "Jun" => 30 , "Jul" => 31 , "Aug" => 31 , "Sep" => 30 ,
  "Oct" => 31 , "Nov" => 30 , "Dec" => 31 ;
my @months = <Jan Feb Mar Apr May Jun Jul Aug Sep Oct Nov Dec> ;
my %weekdaycount ;
my $weekdays ;
for (1..12) -> $month {
  my $mon = @months[ $month - 1 ] ;
  for (1..%daycount{$mon}) -> $day {
      my $date = Date.new( 2019 , $month , $day ) ;
      if ( 1 <= $date.day-of-week <= 5 ) {
    $weekdays++ ;
      }
  }
  %weekdaycount{ $mon } = $weekdays ;
  $weekdays = 0 ;
}
for @months -> $month {
  say "$month: {%weekdaycount{ $month }} days" ;
}
```

[Daniel Mita](https://github.com/manwar/perlweeklychallenge-club/blob/master/challenge-037/daniel-mita/perl6/ch-1.p6)'s solution is quite innovative in several respects, and I must admit that I have some trouble understanding parts of his solution. I leave it to you to discover it: 

``` Perl 6
enum Months «
  :Jan(1) Feb Mar
   Apr    May Jun
   Jul    Aug Sep
   Oct    Nov Dec
»;
"$_.key(): $_.value()".say for (gather {
  given Date.new(:2019year) {
    take Months(.month) if .day-of-week ≠ 6|7;
    &?BLOCK(.succ) if .succ.year == .year;
  }
}).Bag.pairs.sort({ ::{$^a.key} <=> ::{$^b.key} });
```
This is probably the first time that I see an enumeration used in Perl 6 (well at least in real code whose purpose is not to demonstrate enumerations).

[Javier Luque](https://github.com/manwar/perlweeklychallenge-club/blob/master/challenge-037/javier-luque/perl6/ch-1.p6) wrote a program that iterates over all day of the year and increments a counter in a hash of monthly counters each time a date corresponds to a week day:

``` Perl 6
sub show-weekdays-per-year(Int $year) {
    my $current = Date.new($year, 1, 1);
    my %months{Int};

    my @mon = (
        'Jan', 'Feb', 'Mar', 'Apr',
        'May', 'Jun', 'Jul', 'Aug',
        'Sep', 'Oct', 'Nov', 'Dec'
    );

    while ($current.year == $year) {
        %months{$current.month}++
            if ($current.day-of-week == (1 .. 5).any);
        $current++;
    }

    for %months.keys.sort -> $key {
        say @mon[$key - 1] ~ ': ' ~
            %months{$key} ~ ' days';
    }
}
```

[Mark Anderson](https://github.com/manwar/perlweeklychallenge-club/blob/master/challenge-037/mark-anderson/perl6/ch-1.p6) used two nested `while` loops to iterate over each day of each month and the `day-of-week` method of the `Date` class to increment a counter for each weekday. Note the use of the [Date::Names](https://github.com/tbrowder/Date-Names-Perl6) module to handle month names. 

``` Perl 6
use Date::Names;

my $dt = DateTime.new(year => 2019, month => 1);
my $dn = Date::Names.new;

while ($dt.year == 2019) {
    my $count = 0;
    my $mon = $dn.mon($dt.month, 3);

    while ($dn.mon($dt.month, 3) eq $mon) {
        if ($dt.day-of-week < 6) {
            $count++;
        }

        $dt = $dt.later(:day1);
    }

    say "$mon:$count days";
}
```

[Roger Bell West](https://github.com/manwar/perlweeklychallenge-club/blob/master/challenge-037/roger-bell-west/perl6/ch-1.p6) made a program based on the same observation as I did for my last solution: any month had 20 weekdays in its first 28 days, and it is therefore sufficient to count the weekdays after the 28th of each month, using the `day-of-week` method (starting the counter at 20). This being said, his detailed implementation is quite different from mine and works its way backward from the last day of the month using the `earlier` method:

``` Perl 6
my $y=2019;
for (1..12) -> $m {
  my $mm=$m+1;
  my $yy=$y;
  if ($mm>12) {
    $mm-=12;
    $yy++;
  }
  my $d=Date.new($yy,$mm,1).earlier(:1day);
  my $wd=20;
  while ($d.day>28) {
    if ($d.day-of-week < 6) {
      $wd++;
    }
    $d=$d.earlier(:1day);
  }
  say "$m: $wd days";
}
```

[Ruben Westerberg](https://github.com/manwar/perlweeklychallenge-club/blob/master/challenge-037/ruben-westerberg/perl6/ch-1.p6) made one of shortest implementations among the challengers, despite the fact that his use of the `DateTime` class made it slightly more complicated than it would have been using the `Date` class.

``` Perl 6
my $t=DateTime.new(:2019year);
my %months;
my @names= <January February March April May June July August September October November December>;
while $t.year == 2019 {
	$t+=Duration.new(60*60*24);;
	%months{@names[$t.month-1]}++ if $t.day-of-week == any (1..5);
}
for  @names {
	put "$_: %months{$_} week days"
}
```

## See Also

Only two blog posts (besides mine) this time:

* Arne Sommer: https://raku-musings.com/weekdays-daylight.html;

* Javier Luque: https://perlchallenges.wordpress.com/2019/12/02/perl-weekly-challenge-037/.

## Wrapping up

Please let me know if I forgot any of the challengers or if you think my explanation of your code misses something important (send me an e-mail or just raise an issue against this GitHub page).

If you want to participate to the Perl Weekly Challenge, please connect to [this site](https://perlweeklychallenge.org/).


