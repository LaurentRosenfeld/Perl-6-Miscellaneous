# Guest House

This is derived in part from my [blog post](http://blogs.perl.org/users/laurent_r/2019/12/perl-weekly-challenge-39-guest-house-and-reverse-polish-notation.html) made in answer to the [Week 39 of the Perl Weekly Challenge](https://perlweeklychallenge.org/blog/perl-weekly-challenge-038/) organized by  <a href="http://blogs.perl.org/users/mohammad_s_anwar/">Mohammad S. Anwar</a> as well as answers made by others to the same challenge.

The challenge reads as follows:

*A guest house had a policy that the light remain ON as long as the at least one guest is in the house. There is guest book which tracks all guest in/out time. Write a script to find out how long in minutes the light were ON.*

*The guest book looks as follows:*

    1) Alex    IN: 09:10 OUT: 09:45
    2) Arnold  IN: 09:15 OUT: 09:33
    3) Bob     IN: 09:22 OUT: 09:55
    4) Charlie IN: 09:25 OUT: 10:05
    5) Steve   IN: 09:33 OUT: 10:01
    6) Roger   IN: 09:44 OUT: 10:12
    7) David   IN: 09:57 OUT: 10:23
    8) Neil    IN: 10:01 OUT: 10:19
    9) Chris   IN: 10:10 OUT: 11:00

## My Solution

First, although the input data provided with the task spans over only 2 hours, I'll make the computation over a full day, from 00:00 to 23:59. One of the reasons for doing so is that I wanted to add a guest staying over more than two hours, in order to test the case where someone is in the guest house for more than two adjacent hours. Also, I did not want the guests to be male only. So, I added one female guest:

    10) Liz    IN: 12:07 OUT: 17:05

I can think of several ways to solve this task. I decided to create a hash of arrays covering every minute in the 00:00-23:59 range. It could have been an array of arrays, but I originally started with 09:00-11:00 range provided in the task, and that led to an array with empty slots, which I did not like too much because this is likely to generate warnings or require some special care to avoid such warnings (or runtime errors). The program then parses the input data and sets each minute in the presence ranges with 1. Populating the whole range with zeros before starting isn't strictly necessary, but it makes other things easier, as it is possible at the end to just add values without having to first check for definedness. 

We don't care about the guests' names, so when reading the input data, we only look at the time intervals.

Note that there is a slight ambiguity in the task description. If one guest arrives at 10:10 and leaves at 10:11, I consider that the light has to be on for 2 minutes, even though it may be argued that, by a simple subtraction, the guest staid only 1 minute. It is a matter of interpretation.

There is no `DATA` section in Raku programming language as in Perl 5. Raku should have much more feature-rich capabilities using `pod` (plain old documentation) sections, but these are not implemented yet. We could use the [heredocs](https://docs.raku.org/syntax/heredocs%20:to) feature, but since TIMTOWTDI, we will simply use a multi-line string variable within standard double quote marks.

```Perl6
use v6;

my $input = 
   "1) Alex    IN: 09:10 OUT: 09:45
    2) Arnold  IN: 09:15 OUT: 09:33
    3) Bob     IN: 09:22 OUT: 09:55
    4) Charlie IN: 09:25 OUT: 10:05
    5) Steve   IN: 09:33 OUT: 10:01
    6) Roger   IN: 09:44 OUT: 10:12
    7) David   IN: 09:57 OUT: 10:23
    8) Neil    IN: 10:01 OUT: 10:19
    9) Chris   IN: 10:10 OUT: 11:00
    10) Liz    IN: 12:07 OUT: 17:05";

my %hm;
for 0..23 -> $hour {
    %hm{$hour}[$_] = 0 for 0..59;
}
for $input.lines {
    next unless /\S/;
    my ($in_h, $in_m, $out_h, $out_m) = map { +$_}, $/[0..3] if /(\d\d)':'(\d\d)\D+(\d\d)':'(\d\d)/;
    if ($out_h == $in_h) {
        %hm{$in_h}[$_] = 1 for $in_m..$out_m;
    } else {
        %hm{$in_h}[$_]  = 1 for $in_m..59; # end the first hour
        for $in_h + 1 .. $out_h -1 -> $hour {
            %hm{$hour}[$_] = 1 for 0..59; # If several hours
        }
        %hm{$out_h}[$_] = 1 for 0..$out_m; # Complete last hour
    }
}

my $total_on = 0;
for keys %hm -> $hour {
    $total_on += sum %hm{$hour};
}
say "Total time on: $total_on minutes.";
```

With the original input data set, the result was 111 seconds. With my modified data set, I obtain the following output:

    $ perl6 guesthouse.p6
    Total time on: 410 minutes.

## Alternative Solutions

[Arne Sommer](https://github.com/manwar/perlweeklychallenge-club/blob/master/challenge-039/arne-sommer/perl6/ch-1.p6) used his own [Time::Repeat::HHMM](https://github.com/arnesom/p6-time-repeat/blob/master/lib/Time/Repeat.pm6) Raku module. His implementation seems to rely on the fact that all time entries are on the same day, that they are all given in chronological order, and, it seems to me, that they all overlap (no gap between them). But Arne made several other implementations without these limitations, which you can read in his [blog post](https://raku-musings.com/reverse-guest.html).

[Daniel Mita](https://github.com/manwar/perlweeklychallenge-club/blob/master/challenge-039/daniel-mita/perl6/ch-1.p6) wrote a rather long program recording in the `%present` [SetHash](https://docs.raku.org/type/SetHash) the number of guests present for any minute between 9:00 and 11:00, and incrementing the `$light-duration` variable for any minute where there is at least one guest.

[Fernando Correa de Olievera](https://perlweeklychallenge.org/blog/recap-challenge-039/) provided the following solution using massively `multi` functions::

``` Perl 6
sub to-min(Str $str) {
    do given $str.comb(/\d+/) {
       60*.[0] + .[1]
    }
}
proto calc(Int $count,  Int $prev, @in,               @out --> Int) {*}
multi calc(0,           Int,       [],                []   --> 0)   {}
multi calc(Int,         Int,       [],                [])           { die "Finished with guest inside house" }
multi calc(0,           Int $prev, [Int $in, *@in],   @out where $in <= *.head)        { calc 1, $in, @in, @out }
multi calc(Int $count,  Int $prev, [Int $in, *@in],   @out where $in <= *.head)        { $in  - $prev + calc $count + 1, $in,  @in, @out }
multi calc(Int $count,  Int $prev, @in (Int $in, *@), [Int $out where $in > *, *@out]) { $out - $prev + calc $count - 1, $out, @in, @out }
multi calc(Int $count,  Int $prev, [],                [Int $out, *@out])               { $out - $prev + calc $count - 1, $out, [],  @out }

my (@in, @out) := ([[],[]], |lines).reduce: -> (@in, @out), $_ {
   my ($in, $out) = .comb(/\d+":"\d+/);
   [ |@in, to-min $in, ], [ |@out, to-min $out ]
}
say calc 0, 0, @in.sort, @out.sort
```

[Kevin Colyer](https://github.com/manwar/perlweeklychallenge-club/blob/master/challenge-039/kevin-colyer/perl6/ch-1.p6) also used a [SetHash](https://docs.raku.org/type/SetHash) to keep track of guests' presence for every minute in the interval between the arrival of the first guest and the departure of the last one. The number of items in the SetHash then represents the total number of minutes the light is on. Kevin's code is quite short:

``` Perl 6
my %minutes is SetHash;
for $housemates.lines -> $l {
        # parse list to get times
        $l ~~ / (\d\d) \: (\d\d) .+ (\d\d) \: (\d\d) /;
        my ($ih,$im,$oh,$om) = |$/;
        # add the time range to the set
        %minutes{$_}++ for ($ih*60+$im)..($oh*60+$om-1);
}
# count the elements
say %minutes.elems ~ " minutes the lights were on";
```

[Noud](https://github.com/manwar/perlweeklychallenge-club/blob/master/challenge-039/noud/perl6/ch-1.p6) used, just like me, a 24-hour clock. Instead of counting the number of minutes the light were on, he counted the minutes where the light are off (which is, I believe, equivalent):

``` Perl 6
for 'guestbook.txt'.IO.lines -> $line {
    my $rs = $line ~~ /(\d+)\:(\d+)\D+(\d+)\:(\d+)/;
    my $start = 60 * Int($rs[0]) + Int($rs[1]);
    my $end = 60 * Int($rs[2]) + Int($rs[3]);

    if ($time < $start) {
        $time_off += $start - $time;
    }

    $time = $end;
    $time_last = 24 * 60 - $end;
}

$time_off += $time_last;
my $time_on = 24 * 60 - $time_off;

say "The light was on for $time_on minutes";
```

[Ulrich Rielke](https://github.com/manwar/perlweeklychallenge-club/blob/master/challenge-039/ulrich-rieke/perl6/ch-1.p6) explains his program with the following comment: “The basic idea is to read in the file, to convert the access( IN ) and the departure times to minutes and to add a tag whether we move in( "i" ) or out ("o"). If we then order the times by minutes we can keep a count of people inside and determine the number of minutes that elapsed between first person arriving and last person leaving.“ This is the main part of Ulrich's program:

``` Perl 6
my @times = readFile( $filename ) ;
my @orderedTimes = orderByTime( @times ) ;
my $starttime = @orderedTimes[0] ;
my $people_Inside = 0 ;
my $minutes_On ;
for @orderedTimes -> $time {
    if ($time.substr( *-1 , 1 ) eq "i" ) {
        $people_Inside++ ;
    }
    else {
        $people_Inside-- ;
        if ( $people_Inside == 0 ) {
            $minutes_On = $time.substr(0 , $time.chars - 1 ).Int -
                $starttime.substr(0 , $starttime.chars - 1 ).Int ;
            last ;
        }
    }
}
say ("Longest time lights on is " ~ $minutes_On.Str ~ " minutes!") ;
```

[Javier Luque](https://github.com/manwar/perlweeklychallenge-club/blob/master/challenge-039/javier-luque/perl6/ch-1.p6) used a `%time-on` hash to record each minute during which there is at least one guest (pretty much the same basic algorithm as the one I used, but with some implementation differences here and there):

``` Perl6
# Calculate the minutes lights were on
sub calculate-lights-on {
    my %time_on; # Sample in minutes
    my $time_re = /\d\d\:\d\d/;

    for data().lines -> $line {
        next unless $line ~~
            /.*?($time_re).*?($time_re)/;

        # Get the time in absolute minutes
        my $t1 = absolute-minutes($0);
        my $t2 = absolute-minutes($1);

        %time_on{$t1 .. ($t2 -1)} = 1;
    }

    return %time_on.elems;
}
```

[Roger Bell West](https://github.com/manwar/perlweeklychallenge-club/blob/master/challenge-039/roger-bell-west/perl6/ch-1.p6) used an `%ev` hash to record the arrival and departure times. His program then reads again the hash (sorted by keys) and keeps track of periods where the light is on, using the `$laston` variable to know where the light was last switched on and the `ontime` variable to accumulate the duration light is on.

``` Perl 6
for $fh.lines {
  my @e=($_ ~~ m:g/(IN|OUT) ':' \s* (\d+) ':' (\d+)/);
  while (@e) {
    my @match=@e.shift.values;
    my $delta=(@match.shift eq 'IN')??1!!-1;
    my $t=(60*@match.shift)+@match.shift;
    %ev{$t}+=$delta;
  }
}

my $ontime=0;
my $occ=0;
my $laston=0;
for (%ev.keys.sort({$^a <=> $^b})) -> $t {
  my $lastocc=$occ;
  $occ+=%ev{$t};
  if ($lastocc==0 && $occ>0) {
    $laston=$t;
  } elsif ($lastocc>0 && $occ==0) {
    $ontime+=($t-$laston);
  }
}
```

[Ruben Westerberg](https://github.com/manwar/perlweeklychallenge-club/blob/master/challenge-039/ruben-westerberg/perl6/ch-1.p6) made the most concise program:

``` Perl 6
my @times=DATA().map({ |(for (m:g/(\d**2)\:(\d**2)/) {$_[0]*60+$_[1]*1 });});
put sprintf "Lights on for %d minutes", @times.max-@times.min;
```

But Ruben's program works only because there is no period with no guest between the first arrival and the last departure in the data provided with the task, since it does essentially a simple time subtraction between these two events. If there was a period with no guest, it would be overlooked.

[Ryan Thompson](https://github.com/manwar/perlweeklychallenge-club/blob/master/challenge-039/ryan-thompson/perl6/ch-1.p6) created a grammar to parse each input line:

``` Perl 6
grammar TimeData {
    rule  TOP   { <num> ")" <who> "IN:" <time> "OUT:" <time> }
    token num   { \d+   }
    token who   { \w+   }
    token hh    { 0\d | 1 <[012]> }
    token mm    { <[0..5]> \d     }
    token time  { <hh> ":" <mm>   }
}
```

Ryan's main code then parses the input line and populates an `%on` [SetHash](https://docs.raku.org/type/SetHash) with each minute a guest is present. At the end, the number of minutes the light was on is simply the number of items in the SetHash:

``` Perl 6

my %on is SetHash; # Minutes when the light was on
for (DATA().lines) {
    my $parse = TimeData.parse($_) or next;
    my ($in, $out) = $parse<time>.list;

    %on{ minutes($in) .. minutes($out) }»++;
}
say %on.elems;
```

## See also

Only two blog posts (besides mine) this time:

* Arne Sommer: https://raku-musings.com/reverse-guest.html;

* Javier Luque: https://perlchallenges.wordpress.com/2019/12/16/perl-weekly-challenge-039/;

## Wrapping up

Please let me know if I forgot any of the challengers or if you think my explanation of your code misses something important (send me an e-mail or just raise an issue against this GitHub page).
