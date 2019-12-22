# Date Finder


This is derived in part from my [blog post](http://blogs.perl.org/users/laurent_r/2019/12/perl-weekly-challenge-38-date-finder-and-word-game.html) made in answer to the [Week 38 of the Perl Weekly Challenge](https://perlweeklychallenge.org/blog/perl-weekly-challenge-038/) organized by  <a href="http://blogs.perl.org/users/mohammad_s_anwar/">Mohammad S. Anwar</a> as well as answers made by others to the same challenge.

The challenge reads as follows:

*Create a script to accept a 7 digits number, where the first number can only be 1 or 2. The second and third digits can be anything 0-9. The fourth and fifth digits corresponds to the month i.e. 01,02,03…,11,12. And the last 2 digits represents the days in the month i.e. 01,02,03….29,30,31. Your script should validate if the given number is valid as per the rule and then convert into human readable format date.*

*Rules:*

*1) If 1st digit is 1, then prepend 20 otherwise 19 to the 2nd and 3rd digits to make it 4-digits year.*

*2) The 4th and 5th digits together should be a valid month.*

*3) The 6th and 7th digits together should be a valid day for the above month.*

*For example, the given number is 2230120, it should print 1923-01-20.*

## My Solutions

This time, rather than concentrating on a test suite, I decided to focus on trying to provide useful warnings and error messages when the input value is not valid, which led me to test the input data piece by piece. The following program is basically a port to Raku of the program I had initially written in Perl 5 for the same task:

``` Perl 6
use v6;

sub MAIN ($in where * ~~ /^\d ** 7$/ = '2230120') {
    my ($y1, $y2, $m, $d) = ($in ~~ /^(\d)(\d\d)(\d\d)(\d\d)/)[0..3];
    die "First digit should be 1 or 2\n" if $y1 !~~ /<[12]>/;
    my $year = $y1 == 1 ?? "20$y2" !! "19$y2";
    die "Digits 4 and 5 should be a valid month number\n" unless $m ~~ /(0 <[1..9]>) | (1 <[012]>)/;
    die "Digits 6 and 7 should be a valid day in month\n" unless $d ~~ /(<[012]> \d) | (3 <[01]>)/;
    try { 
        my $test = Date.new($year, $m, $d);
    }
    die "$in is equivalent to $year-$m-$d, which is an invalid date\n" if $!;
    say "$in is equivalent to $year-$m-$d.";
}
```
Running it with the default value produces the following output:

    $ perl6 date_finder.p6
    2230120 is equivalent to 1923-01-20.

This is the output with a correct argument:

    $ perl6 date_finder.p6 1191210
    1191210 is equivalent to 2019-12-10.

And with an invalid argument:

    $ perl6 date_finder.p6 1191310
    Digits 4 and 5 should be a valid month number
    
      in sub MAIN at date_finder.p6 line 7
      in block <unit> at date_finder.p6 line 1

We first validate that each data piece. For example, I've decided that the first digit should be 1 or 2 (although the requirement is not explicit about the possible second value). Then, digits 4 and 5 should be a valid month number, so it should be anything between `01` ad `12` and digits 6 and 7 should be a valid day within a month. After these checks, the program attempts to create a `Date` object within a [try block](https://docs.raku.org/language/exceptions#index-entry-try_blocks) and will die with the appropriate error message if the date is not valid (i.e. if an exception is caught into the `$!` error variable). The initial tests are not strictly necessary, as the creation of the `Date` object construction will catch any date error, but they make it possible to provide the user with a more explicit message about the input error. Having said that, I should add that the validation of the data pieces is not as exhaustive as it could be (for example `00` would pass the day digit test), but I didn't care too much about it, since the `try` block will catch any remaining error:

    $ perl6 date_finder.p6 2230100
    2230100 is equivalent to 1923-01-00, which is an invalid date

Rather than having the relatively complicated regexes above for checking the month and day digits, we have tried to use `subsets`, for example:

``` Perl6
subset Day of Str where * eq ("01" .. "31").any;
subset Month of Str where * eq ("01" .. "12").any;
```

But this turned out to be somewhat inconvenient, as it leads easily to pesky type check errors.

Another way to do it would be to use a grammar, for example:

    use v6;
    
    grammar My-custom-date {
        token TOP { <y1> <y2> <m> <d> }
        token y1  { <[12]> }
        token y2  { \d ** 2}
        token m   { 0 <[1..9]> | 1<[012]> }
        token d   { 0 <[1..9]> | <[12]> \d | 3<[01]> } 
    }
    
    sub MAIN ($in where * ~~ /^\d ** 7$/ = '2230120') {
        my $matched  = so My-custom-date.parse($in);
        say "Invalid input value $in" and exit unless $matched;
        my $year = $<y1> == 1 ?? "20$<y2>" !! "19$<y2>";
        try { 
            my $test = Date.new($year, $<m>, $<d>);
        }
        say "ERROR: $in is equivalent to $year-$<m>-$<d>, which is an invalid date\n" and exit if $!;
        say "$in is equivalent to $year-$<m>-$<d>.";
    }

But, in this case, the advantage of using a grammar is not obvious, except for the fact the parsing is possibly slightly clearer. It might even be argued that using a grammar for such a simple case is sort of a technological overkill. The example may still provide some guidance with a very simple example to anyone beginning with grammars.

These are some sample runs:

    $ perl6 date_finder.p6
    2230120 is equivalent to 1923-01-20.
    
    $ perl6 date_finder.p6 2230228
    2230228 is equivalent to 1923-02-28.
    
    $ perl6 date_finder.p6 2230229
    Use of Nil in string context
    ERROR: 2230229 is equivalent to 1923--, which is an invalid date
    
      in block  at date_finder.p6 line 17
    Use of Nil in string context
      in block  at date_finder.p6 line 17

## Alternative Solutions

TIMTOWTDI. Even for such a relatively simple task, the challengers have implemented the task in many different ways. For parsing the input string, people have used standard regexes, named captures, named rules, grammars (including even a grammar with an actions class), the `substr` built-in function and even the `polymod` method. Similarly, for catching an exception when creating a `date` object, challengers have used try block (with or without a `CATCH` clause within it), try prefix statements and bare `CATCH` blocks. There is really more than one way to do it in Raku.

[Arne Sommer](https://github.com/manwar/perlweeklychallenge-club/blob/master/challenge-038/arne-sommer/perl6/ch-1.p6) used [named captures](https://docs.raku.org/language/regexes#index-entry-regex__Named_captures-Named_captures) to collect the input data pieces and a `try` statement prefix followed by a `Date` object creation to perform date validation:


``` Perl 6
if $date ~~ /^
    $<century> = (<[12]>)
    $<year>    = (<[0..9]><[0..9]>)
	$<month>   = (<[01]><[0..9]>)
	$<day>     = (<[0123]><[0..9]>)
    $/
{
    my $datestring = "{ $<century> == 1 ?? '20' !! '19' }{ $<year> }-{ $<month> }-{ $<day> }";

    if try Date.new($datestring)
    {
        say $datestring;
        exit;
    }
}
say "Not a valid date.";
```

Note that Arne provided several other implementations, together with a detailed test suite, in his interesting [blog post](https://raku-musings.com/date-word.html).

[Daniel Mita](https://github.com/manwar/perlweeklychallenge-club/blob/master/challenge-038/daniel-mita/perl6/ch-1.p6) used a named rule:

``` Perl 6
my token date-number {
  ^
  ( ( <[12]> ) ( <[0..9]> ** 2 ) )
  ( <[0..9]> ** 2 ) ** 2
  $
}
```
to parse the input data, and then used the [make](https://docs.raku.org/routine/make) and [made](https://docs.raku.org/routine/made) methods of the Raku [Match](https://docs.raku.org/type/Match) class to handle the necessary transformations:

``` Perl 6
sub MAIN(
  $number where * ~~ &date-number, #= 7 digit number starting with 1 or 2 followed by YYMMDD
  --> Nil
) {
  given $0[0] {
    when 1 { .make(19) }
    when 2 { .make(20) }
  }
  Date.new(
    year  => $0[0].made ~ $0[1],
    month => $1[0],
    day   => $1[1],
  ).say;
}
```
So far, I had always used the `make` and `made` methods solely in the context of grammars, and had just not realized that it could be used on any match object. Quite an interesting discovery for me. Thank you, Daniel.

[Kevin Colyer](https://github.com/manwar/perlweeklychallenge-club/blob/master/challenge-038/kevin-colyer/perl6/ch-1.p6) wrote a `validate` subroutine to check the input data, and constructed a `DateTime` object within a `try` block with a `CATCH` clause to validate the date:

``` Perl 6
sub validate($d where *>0) {
    my $s=$d.Str;
    return "Input must be only 7 digits in length" if $d.chars!==7;
    my ($day,$month,$year,$mill) = $d.polymod(100,100,100);
    return "First digit must be either 1 or 2" if 0 > $mill > 2;
    $year+=$mill==1 ?? 2000 !! 1900 ;
    my $date;
    try     { $date = DateTime.new(year => $year, month => $month, day => $day);
        CATCH   { return .Str }
    };
    return $date.Date;
}
```

I find that using the [polymod](https://docs.raku.org/routine/polymod) method to split the input into data pieces is a quite interesting idea which I did not think about. Kevin also made a small test suite to test the `validate` subroutine.

[Noud](https://github.com/manwar/perlweeklychallenge-club/blob/master/challenge-038/noud/perl6/ch-1.p6) used a grammar with a `ConvDate` actions class to handle the input data:

``` Perl 6
grammar DATE {
    token TOP { <century> <year> <month> <day> }
    regex century { 1 | 2 }
    regex year { <digit>**2 }
    regex month { <digit>**2 }
    regex day { <digit>**2 }
}
class ConvDate {
    method TOP ($/) { make (if ($<century> == 1) { 20 } else { 19 }) ~ $<year>
                      ~ '-' ~ $<month> ~ '-' ~ $<day>; }
}
say DATE.parse(2230120, actions => ConvDate).made;
```

[Simon Proctor](https://github.com/manwar/perlweeklychallenge-club/blob/master/challenge-038/simon-proctor/perl6/ch-1.p6) used named captures within a constant regex and also was able to use a subset without encountering the problems I mentioned above. He then constructed a `Date` object and used a `CATCH` block to catch any error.

``` Perl6
constant $DATE-MATCH = rx/^ $<century>=(<[12]>) $<year>=(<[0..9]>**2) $<month>=("01"|"02"|"03"|"04"|"05"|"06"|"07"|"08"|"09"|"10"|"11"|"12") $<day>=(<[0..3]><[0..9]>) $/;
subset PossData of Str where * ~~ $DATE-MATCH;
multi sub MAIN($s) is hidden-from-USAGE {
    say "{$s} doesn't match the valid string condition\n$*USAGE";
}
#| Parse the data string format
multi sub MAIN(
    PossData $date #= Date in the format (1/2 2000/1900), year, month, day 
) {
    my $match = ( $date ~~ $DATE-MATCH );
    my $result;
    {
        $result = Date.new( :year( $match.<year> + ( $match.<century> ~~ 1 ?? 2000 !! 1900 ) ), :month( $match<month> ), :day( $match<day> ) );  
        CATCH {
            default {
                say "{$date} is not a valid date\n$*USAGE";
                exit;
            }
        }
    }
    say $result;
}
```

[Javier Luque](https://github.com/manwar/perlweeklychallenge-club/blob/master/challenge-038/javier-luque/perl6/ch-1.p6) used a regex to parse the input data and constructed a `Date`  object within a `try` block with a `CATCH` block to validate the date:

``` Perl 6
sub parse-date(Int $date) {
    # Regex to test date format
    return "Invalid date format"
        unless ($date ~~ /
            ^^            # Start of string
            (<[12]>)      # 1 or 2
            (\d\d)        # year 00-99
            (0<[1..9]> || # month 1-12
             1<[0..2]>)
            (0<[1..9]> || # day 1-31
             <[1..2]>\d||
             3<[01]>)
            $$            # End of string
        /);

    # The date string
    my $date_string =
        ( ($0 == 1) ?? '20' ~ $1  !! '19' ~ $1 )
        ~ '-' ~ $2 ~ '-' ~ $3;

    # Make sure the date is valid
    # even if it passed the format check
    try {
        my $date_check = Date.new($date_string);

        CATCH {
            return "Invalid date";
        }
    }

    return $date_string;
}
```

[Roger Bell West](https://github.com/manwar/perlweeklychallenge-club/blob/master/challenge-038/roger-bell-west/perl6/ch-1.p6) used a series of regexes to check the input data and then constructed a `Date` object within a `CATCH` block to validate the date:

``` Perl 6
for @*ARGS -> $dc {
  unless ($dc.chars==7) {
    warn "$dc is wrong length\n";
    next;
  }
  unless ($dc ~~ /^<[0..9]>+$/) {
    warn "$dc has non-digit characters\n";
    next;
  }
  $dc ~~ /^(.)(..)(..)(..)$/;
  my ($cen,$year,$month,$day)=($0,$1,$2,$3);
  if ($cen==2) {
    $year+=1900;
  } elsif ($cen==1) {
    $year+=2000;
  } else {
    warn "$dc has invalid century digit $cen\n";
    next;
  }
  if ($month < 1 || $month > 12) {
    warn "$dc has invalid month $month\n";
    next;
  }
  my $d;
  CATCH {
    $d=Date.new($year,$month,$day);
  }
  unless (defined $d) {
    warn "$dc has invalid day $day\n";
    next;
  }
  say $d.yyyy-mm-dd;
}
```

[Ruben Westerberg](https://github.com/manwar/perlweeklychallenge-club/blob/master/challenge-038/ruben-westerberg/perl6/ch-1.p6) used a quite interesting method to construct his regexes:

``` Perl 6
my $m=(1..12)>>.fmt("%02d").join("|");
```

Just in case you don't get it, the value of `$m` is now:

    01|02|03|04|05|06|07|08|09|10|11|12

He also used the same method for building a regex for days in the `01..31` range. Ruben's program is fairly compact:

``` Perl 6
my $m=(1..12)>>.fmt("%02d").join("|");
my $d=(1..31)>>.fmt("%02d").join("|");

for @*ARGS {
	if /(1|2)(<[0..9]>**2)(<$m>)(<$d>)/ { 
		put "Input $_ OK";
		put ($0==1??"20$1"!!"19$1",$2,$3).join("-");
		next;
	}
	print "Input $_ invalid";
}
```

[Ryan Thompson](https://github.com/manwar/perlweeklychallenge-club/blob/master/challenge-038/ryan-thompson/perl6/ch-1.p6) rolled out manually the whole validation process:

``` Perl 6
sub MAIN( Int $date ) {
    $date ~~ /^
        $<cent> = [ <[12]> ]                         # Century (1:1900,2:2000)
        $<yy>   = [ \d \d  ]                         # Year    (2-digit)
        $<mm>   = [ 0<[1..9]> | 1<[012]> ]           # Month   (01..12)
        $<dd>   = [ 0<[1..9]> | <[12]>\d | 3<[01]> ] # Day     (01..31)
    $/ or die "Usage: $*PROGRAM Cyymmdd";

    my Int $yyyy = ($<cent> + 18 ~ $<yy>).Int;

    die "$yyyy-$<mm> does not have $<dd> days"
        if days-in($yyyy, $<mm>.Int) < $<dd>;

    say "$yyyy-$<mm>-$<dd>";

}

# Return the number of days in the given month (with year specified so
# we can check if it is a leap year)
sub days-in( Int $y, Int $m ) {
    my @days = (0, 31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31);
    @days[2]++ if leap-year($y);
    @days[$m];
}
```

I skipped the code of the `leap-year`subroutine (probably copied from Ryan's Perl 5 implementation of the same task), since it could be replaced with the [is-leap-year](https://docs.raku.org/routine/is-leap-year) built-in function provided by Raku.

## See also

Only two blog posts (besides mine) this time:

* Arne Sommer: https://raku-musings.com/date-word.html;

* Javier Luque: https://perlchallenges.wordpress.com/2019/12/10/perl-weekly-challenge-038/.

## Wrapping up

Please let me know if I forgot any of the challengers or if you think my explanation of your code misses something important (send me an e-mail or just raise an issue against this GitHub page).

If you want to participate to the Perl Weekly Challenge, please connect to [this site](https://perlweeklychallenge.org/).

