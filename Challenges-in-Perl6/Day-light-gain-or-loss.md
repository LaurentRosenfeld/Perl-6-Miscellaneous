# Daylight Loss or Gain

This is derived in part from my [blog post](http://blogs.perl.org/users/laurent_r/2019/12/perl-weekly-challenge-37-week-days-in-each-month-and-daylight-gainloss.html) made in answer to the [Week 37 of the Perl Weekly Challenge](https://perlweeklychallenge.org/blog/perl-weekly-challenge-037/) organized by  <a href="http://blogs.perl.org/users/mohammad_s_anwar/">Mohammad S. Anwar</a> as well as answers made by others to the same challenge.

The challenge reads as follows:

*Write a script to find out the Daylight gain/loss in the month of December 2019 as compared to November 2019 in the city of London. You can find out sunrise and sunset data for [November 2019](https://www.timeanddate.com/sun/uk/london?month=11&year=2019) and [December 2019](https://www.timeanddate.com/sun/uk/london?month=12&year=2019) for London.*

A look at the links provided reveals that the linked pages provide not only sunrise and sunset data, but also daylight duration, which is really the input data we're looking for. Not only is it going to be slightly easier to use directly daylight duration, but daylight values are also sixty times more accurate: sunrise and sunset have an accuracy of a minute, whereas daylight duration are precise to the second (so that, in fact, it won't really be easier, since our calculations will need to be more accurate (and that's a bit of a pain in the neck when values are given in sexagesimal or base-60 notation).

Otherwise, the requirement is not very clear, but I'll take it to mean that we want to compute the daylight gain or loss between each day of December 2019 and the corresponding day in November 2019. Since November has only 30 days, we won't be able to say anything about December 31, 2019, as there is no corresponding day in November. We will also compute the average daylight gain or loss (well, it's obviously a loss, but we'll assume we don't know and will let the computer program find this out).

## My solutions

For the sake of this task, we just copied and pasted the data into two separate text files (one for November and one for December) and edited them to remove useless data and fix the format; and we then use those text files as input for my programs. The text file for November 2019 looks as follows:


    1	06h53 	16h34 	9:40:44	
    2	06h55 	16h32 	9:37:10	
    3	06h56 	16h30 	9:33:37	
    4	06h58 	16h28 	9:30:07	
    5	07h00 	16h27 	9:26:38	
    [ ... Lines omitted for brevity ...]
    28	07h38 	15h57 	8:18:24	
    29	07h40 	15h56 	8:16:09	
    30	07h41 	15h55 	8:13:59	

The December file has the same format. Even though the text file includes sunrise and sunset times, we'll use only the last column (day light duration) of these files, as it is more accurate.

In order to compute differences between values in sexagesimal notation (in base 60, i.e. expressed in hours/minutes/seconds), we will convert everything to seconds, perform arithmetic operations on values in seconds, and convert the result back into HMS sexagesimal values if needed. The `sec2hrs` and `hrs2sec` subroutines perform the necessary conversions from and to seconds. 

The program first reads through the input data and stores the daylight data into an `@nov`and an `@dec` arrays. Then it loops through the `1..30` range and, for each day, subtract the November daylight value from the December daylight value. The program also computes an average change over 30 days.

The `sec2hrs` subroutine is much simpler than what I had to do for solving the same task in Perl 5 because it uses the multiple modulo [polymod](https://docs.raku.org/routine/polymod) method to convert directly seconds into hours, minutes and seconds. Also, we used the `Z-` [zip](https://docs.raku.org/language/operators#index-entry-Z_(zip_metaoperator)) metaoperator along with the `-` subtract operator to compute all the duration differences in just one single statement.

``` Perl 6
use v6;
sub hrs2sec ($hms) {
    my ($hrs, $min, $sec) = split /\:/, $hms;
    return $hrs * 60² + $min * 60 + $sec;
}
sub sec2hrs (Numeric $sec) {
    my @duration = $sec.abs.polymod(60, 60);
    my $fmt = ($sec < 0 ?? "-" !! "") ~ "%d:%02d:%02d";
    return sprintf $fmt, @duration[2, 1, 0];
}
my @nov = 'november_2019.txt'.IO.lines[0..29].map({(.split(/\s+/))[3]});
my @dec = 'december_2019.txt'.IO.lines[0..29].map({(.split(/\s+/))[3]});
my @diff = @dec.map({hrs2sec $_}) Z- @nov.map({hrs2sec $_});
say "Daylight changes between Dec and Nov:";
for @diff.kv -> $k, $v { printf "%2d: %s\n", $k + 1, sec2hrs( $v) };
say "\nAverage change between Nov and Dec: ", sec2hrs ([+] @diff) / 30;
```

This program displays the following output:

    $ perl6  day_light.p6
    Daylight changes between Dec and Nov:
     1: -1:28:51
     2: -1:27:17
     3: -1:25:40
     4: -1:24:00
     5: -1:22:16
     6: -1:20:29
     7: -1:18:37
     8: -1:16:42
     9: -1:14:44
    10: -1:12:42
    11: -1:10:35
    12: -1:08:26
    13: -1:06:13
    14: -1:03:56
    15: -1:01:37
    16: -0:59:13
    17: -0:56:45
    18: -0:54:15
    19: -0:51:42
    20: -0:49:05
    21: -0:46:25
    22: -0:43:42
    23: -0:40:57
    24: -0:38:09
    25: -0:35:17
    26: -0:32:24
    27: -0:29:29
    28: -0:26:31
    29: -0:23:32
    30: -0:20:32
    
    Average change between Nov and Dec: -0:58:20

## Alternative Solutions

I said at the beginning that I found the requirement not to be very clear. This is confirmed by the fact that the challengers interpreted the task in at least three different ways.

[Arne Sommer](https://github.com/manwar/perlweeklychallenge-club/blob/master/challenge-037/arne-sommer/perl6/ch-2.p6) used the `LWP::Simple` module to retrieve the data directly from the Web page, but also cached the pages locally to avoid waste of time and resources. His program also converts durations in HMS into seconds to perform the calculations and back to HMS when needed (see the `hms2s `and `s2hms` subroutine below). This is the part of Arne's code for comparing the monthly data:

``` Perl 6
for 1..31 -> $day
{ 
  my $left-value  = %data{$left}{$day};
  my $right-value = %data{$right}{$day};
  ! $left-value && ! $right-value && last;
  print $day.fmt('%2d') ~ ' ';
  print $left-value
    ?? $left-value.fmt('%9s') ~ '  '
    !! ' ' x 11;
   print $right-value
   ?? $right-value.fmt('%9s') ~ '  '
   !! ' ' x 11;
  print "{ (s2hms( hms2s($right-value) - hms2s($left-value))).fmt('%10s') }" if $left-value && $right-value;
  say '';
}
sub hms2s ($hms)
{
  my @parts = $hms.split(':') // return 0;
  return @parts[0] * 60 * 60 + @parts[1] * 60 + @parts[2];
}
sub s2hms ($s is copy)
{
  my $sign = "";
  if $s < 0 { $s = -$s; $sign = "-"; } 
  my $h = $s div 3600; $s -=  $h * 3600;
  my $m = $s div   60; $s -=  $m *   60;
  return "$sign$h:{ $m.fmt('%02d') }:{ $s.fmt('%02d') }" if $h;
  return "$sign$m:{ $s.fmt('%02d') }" if $s;
  return "$sign$s";
}
```

[Kevin Colyer](https://github.com/manwar/perlweeklychallenge-club/blob/master/challenge-037/kevin-colyer/perl6/ch-2.p6) used the day-length difference data from the web pages and obviously did not understand the task in the same way as me and Arne: if I understand correctly, he computed the daylight gain or loss in the course of November (i.e. between Nov. 1 and Nov. 30) and likewise in December. This is his code doing the computations from the daily day-length difference column of the Web pages:

``` Perl 6
sub parse-duration($s) {
    my $sign=$s.substr(0,1);
    my @min-secs = $s.substr(1..*).split(":"); # assumes no hours... not robust!
    return ( @min-secs[0] * 60 + @min-secs[1] ) * ( $sign eq "-" ?? -1 !! 1 );
}

sub say-duration($d) {
    my $sign = $d < 0 ?? "-" !! "";
    # concats '-' if negative, then forces positive value, modular divides by 60 twice, reverses the list then sends each item to be formatted for printing and joins them with ':'. Phew!
    return $sign ~ $d.abs.polymod(60, 60).reverse>>.fmt("%02d").join(":");
}

say "Nov (gain/loss) hh:mm:ss " ~ say-duration [+] ( parse-duration $_ for %n.values ) ;
say "Dec (gain/loss) hh:mm:ss " ~ say-duration [+] ( parse-duration $_ for %d.values ) ;
```

[Richard Nuttall](https://github.com/manwar/perlweeklychallenge-club/blob/master/challenge-037/rnuttall/perl6/ch-2.p6), who is new to the challenge if I am not wrong, apparently also understood that the task was to compute the daylight loss in November and the daylight loss in December. He used the `LWP::Simple` and `HTML::Parser::XML` modules to fetch and parse the Web page data. This is his code to parse the input data and perform the relevant calculations:

``` Perl 6
sub GetDaytime($url,$fn --> Int:D) {
    my $parser  = HTML::Parser::XML.new;
    my $xmldoc  = $parser.parse(GetPage($url,$fn));
    my $daytime = 0;

    my $table = $xmldoc.root.elements(:TAG<table>, :RECURSE)[0]; # There is only one table
    for $table.elements(:TAG<tr>, :RECURSE) -> $tr {
        my $td = $tr.elements(:TAG<td>, :RECURSE);
        next unless $td.elems == 12;                             # Ignore header row
        my $daylen = $td[2].nodes[0].text;                       # Daylength is in 3rd column ...
        $td[2].nodes[0].text ~~ /(\d+) ':' (\d+) ':' (\d+)/;     # ... as HH:MM:SS
        $daytime += $0*60*60 + $1*60 + $2;
    }
    return $daytime;
}
sub MAIN($year = 2019) {
    my $daytimeDec = GetDaytime('https://www.timeanddate.com/sun/uk/london?month=12&year=2019','London-2019-12');
    my $daytimeNov = GetDaytime('https://www.timeanddate.com/sun/uk/london?month=11&year=2019','London-2019-11');

    say "December $year has a total of $daytimeDec seconds daylength in London";
    say "November $year has a total of $daytimeNov seconds daylength in London";
    my $diff = $daytimeNov - $daytimeDec;
    say "November is longer by $diff seconds, or ", ($diff.polymod(60, 60, 24, 7) Z <sec min hr d wk>).grep(*[0]).reverse.join(", ");
}
```

[Ulrich Rieke](https://github.com/manwar/perlweeklychallenge-club/blob/master/challenge-037/ulrich-rieke/perl6/ch-2.p6) apparently also understood that the task was to compute the daylight loss in November and the daylight loss in December. He created `DateTime` objects for sunrise and sunset on the first and last day of each month, for example:

``` Perl 6
my $novemberstart_sunrise = DateTime.new( year => 2019 ,
                                          month => 11 ,
                      day => 1 ,
                      hour => 6 ,
                      minute => 53 ,
                      second => 0 ,
                      timezone => 1 ) ;
```

and then simply used subtraction between `DateTime` objects to find the November and the December loss:

``` Perl 6
my $daylength1 = $novemberstart_sunset - $novemberstart_sunrise ;
my $daylength2 = $novemberend_sunset - $novemberend_sunrise ;
my $novemberloss = $daylength1 - $daylength2 ;
say "Loss of daylength in november : " ~ $novemberloss.Str ~ " seconds!" ;
$daylength1 = $decemberstart_sunset - $decemberstart_sunrise ;
$daylength2 = $decemberend_sunset - $decemberend_sunrise ;
my $decemberloss = $daylength1 - $daylength2 ;
say "Loss of daylength in december : " ~ $decemberloss.Str ~ " seconds!" ;
```

[Daniel Mita](https://github.com/manwar/perlweeklychallenge-club/blob/master/challenge-037/daniel-mita/perl6/ch-2.p6) apparently understood the challenge the same way as Kevin, Richard and Ulrich, but I'm not entirely sure, since his program uses a JSON file as source data, and I'm not quite sure where this JSON file is coming from and what it contains. Anyway, this is Daniel's code:

``` Perl6
my %data = 'sun-data.json'.IO.slurp.&from-json.map(|*);
my Duration ( $nov, $dec );

for %data.keys -> $k {
  my $d := Date.new($k);
  my &adder := -> $month is rw {
    $month += [-] %data{$k}<sunset sunrise>.map({ DateTime.new($_) })
  };

  given $d.month {
    when 11 {
      $nov.&adder;
    }
    when 12 {
      $dec.&adder;
    }
  }
}

say "Daylight in November: $nov seconds";
say "Daylight in December: $dec seconds";
say "Difference: {($nov - $dec).abs} seconds";
```

[Javier Luque](https://github.com/manwar/perlweeklychallenge-club/blob/master/challenge-037/javier-luque/perl6/ch-2.p6) understood yet some other thing. If I understand his program well, it computes the cumulated daylight time in November and in December, and then computes the difference between the two months. The main part of Javier's program is as follows:

``` Perl6
sub compare_lengths(Date $date1, Date $date2) {
    # Months
    my @mon = (
        'Jan', 'Feb', 'Mar', 'Apr',
        'May', 'Jun', 'Jul', 'Aug',
        'Sep', 'Oct', 'Nov', 'Dec'
    );

    # Get the data from the web
    my @date1_data =
        get-data($date1);
    my @date2_data =
        get-data($date2);

    # Calculate totals
    my $date1_total = calculate-daylight-total(@date1_data);
    my $date2_total = calculate-daylight-total(@date2_data);
    my $difference = $date1_total - $date2_total;

    # Print the output
    say @mon[$date1.month - 1] ~ ' ' ~ $date1.year ~ ' has ' ~
        convert-seconds-to-string($date1_total) ~
        ' of daylight.';

    # Print the output
    say @mon[$date2.month - 1] ~ ' ' ~ $date2.year ~ ' has ' ~
        convert-seconds-to-string($date2_total) ~
        ' of daylight.';

    say "The difference is: " ~
        convert-seconds-to-string($difference) ~ '.';
}

# Calculates the total daylight hours from data
sub calculate-daylight-total(@data) {
    my $total = 0;
    for (@data) -> $daylight {
        $total += convert-time-to-seconds($daylight).Int;
    }
    return $total
}
```

[Mark Anserson](https://github.com/manwar/perlweeklychallenge-club/blob/master/challenge-037/mark-anderson/perl6/ch-2.p6) used the `HTTP::UserAgent` and `DOM::Tiny`module to fetch and process the input data. His program is among the most concise ones:

``` Perl 6
use HTTP::UserAgent;
use DOM::Tiny;

my $dt = DateTime.new(secs(11) - secs(12));

say "Dec has " ~ ($dt.hour,$dt.minute,$dt.second).join(":") ~ " less daylight";

sub secs($month) {
    my $link = "https://www.timeanddate.com/sun/uk/london?month=$month&year=2019";

    my $ua = HTTP::UserAgent.new;

    my $dom = DOM::Tiny.parse($ua.get($link).content);

    # load the 'Length' column values
    my $c = $dom.find('td[class="c tr sep-l"]').map(*.text);

    # convert the hh::mm::ss to seconds and sum them
    $c.map({DateTime.new("1970-01-01T$_.subst(/^(\d):/, {0 ~ $0})").posix}).sum;
}
```

[Roger Bell West](https://github.com/manwar/perlweeklychallenge-club/blob/master/challenge-037/roger-bell-west/perl6/ch-2.p6) used the [Gombo](https://github.com/Skarsnik/perl6-gumbo) module, which is a binding to the C [Gombo](https://github.com/google/gumbo-parser) library to parse HTML5 and which I had not heard about before. This module provides a `parse-html` routine that parses an input HTML string and returns a `XML::Document` object. 

``` Perl 6
use Gumbo;

my @dtime;

for ('2019-11-london.html','2019-12-london.html') -> $file {
  my $dlt=0;
  my $fh=open :r,$file;
  my $text='';
  for $fh.lines {
    $text ~= $_;
  }
  close $fh;
  my $xml=parse-html($text);
  my $tab=$xml.root.elements(:TAG<table>, :RECURSE)[0];
  for $tab.elements(:TAG<tr>, :RECURSE) -> $tr {
    my @td=$tr.elements(:TAG<td>, :RECURSE);
    if (@td.elems==12) {
      my $dl=@td[2].nodes[0].text;
      $dl ~~ /(\d+) ':' (\d+) ':' (\d+)/;
      $dlt+=$0*3600+$1*60+$2;
    }
  }
  push @dtime,$dlt;
}
say 'delta ',@dtime[1]-@dtime[0],' s';
```

[Ruben Westerberg](https://github.com/manwar/perlweeklychallenge-club/blob/master/challenge-037/ruben-westerberg/perl6/ch-2.p6) used the `HTTP::UserAgent` module to fetch the two needed Web pages. Roger's interpretation of the task was apparently to compute the total day light duration in December with the total daylight duration in November (which is sort of unfair to November since it has one day less).

``` Perl 6
use HTTP::UserAgent;

print "Downloading November Data...\n";
my $res=HTTP::UserAgent.new.get("https://www.timeanddate.com/sun/uk/london?month=11&year=2019");
my $nov=$res.content;

print "Downloading December Data...\n";
$res=HTTP::UserAgent.new.get("https://www.timeanddate.com/sun/uk/london?month=12&year=2019");
my $dec= $res.content;

my $delta=extractDaylight($dec)- extractDaylight($nov);
my $sign= $delta>=0??"+"!!"-"; $delta=abs($delta);
my $hours=($delta / 3600).Int; $delta-=$hours*3600;
my $mins=($delta/60).Int; $delta-=$mins*60;

print "December gained $sign$hours:$mins:$delta (H:M:S) compared to November\n";

sub extractDaylight($text) {
	my $total =0;
	my @matches= $text~~ m:g/\<td\sclass\=\"c\str\ssep\-l\"[.*?]\>(.*?)\<\/td\>/;
	for @matches {
		my ($h,$m,$s)=split ":",$_[0].Str;
		$total+=$h*3600+$m*60+$s;
	}
	$total;
}
```


## See Also

Only two blog posts (besides mine) this time:

* Arne Sommer: https://raku-musings.com/weekdays-daylight.html;

* Javier Luque: https://perlchallenges.wordpress.com/2019/12/02/perl-weekly-challenge-037/.

## Wrapping up

Please let me know if I forgot any of the challengers or if you think my explanation of your code misses something important (send me an e-mail or just raise an issue against this GitHub page).

If you want to participate to the Perl Weekly Challenge, please connect to [this site](https://perlweeklychallenge.org/).


