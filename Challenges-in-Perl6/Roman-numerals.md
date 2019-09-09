# Roman Numerals

This is derived from my [blog post](http://blogs.perl.org/users/laurent_r/2019/05/perl-weekly-challenge-10-roman-numerals-and-jaro-winkler-distance.html) made in answer to the [Week 10 of the Perl Weekly Challenge](https://perlweeklychallenge.org/blog/perl-weekly-challenge-010/) organized by  <a href="http://blogs.perl.org/users/mohammad_s_anwar/">Mohammad S. Anwar</a> as well as answers made by others to the same challenge.

The challenge reads as follows:

_Write a script to encode/decode Roman numerals. For example, given Roman numeral CCXLVI, it should return 246. Similarly, for decimal number 39, it should return XXXIX. Checkout [Wikipedia page](https://en.wikipedia.org/wiki/Roman_numerals) for more information._

Most people know more or less how Roman numerals work. They use Latin letters to represent numbers:

| Symbol |  I  |  V  |  X  |  L  |  C  |  D  |  M   |
|--------|-----|-----|-----|-----|-----|-----|------|
| Value  |  1  |  5  |  10 |  50 | 100 | 500 | 1000 |

In general, Roman numerals use *additive notation*: for example, MCLXXIII means `1000 + 100 + 50 + 20 + 3 = 1173`. Or, at least, this is so when the symbols are written from left to right in decreasing value order.

If, however, a given symbol has a smaller value than a symbol placed on its right, then this is an example of *subtractive notation*: in that case, the smaller symbol is subtracted from the one its right. For example, IV means 1 subtracted from 5, i.e. `5 - 1 = 4`. Similarly, IX and XC respectively mean `10 - 1 = 9` and `100 - 10 = 90`. And MCMXLIX corresponds to `1000 + ( 1000 - 100) + (50 - 10) + (10 - 1) = 1949`.

The overall problem, though, is that there is no general standard for Roman numerals. Applying the rules above makes it possible to decode more or less unambiguously any Roman numeral coded according to such aforesaid rules, but there may be several different possible ways to encode a number into a Roman numeral. For example, 99 could be encoded as XCXI or IC (or even XCVIIII or possibly LXXXXVIIII). The first transcription (XCXI) seems to be the most frequent one, so this is the one we will chose when encoding to Roman numerals. Still, IC seems to be a valid Roman numeral for 99, so we will try at least to be able to decode it if we find it.

Note that there is no Roman numeral for zero and the largest possible Roman numeral with the above rules is 3,999.

## My Solutions

If Roman numerals only had the additive notation, it would be very easy: for converting a Roman numeral, just pick up each of the symbols in turn, add them up, and you're done. The trouble comes with subtractive notation.

So my first idea to decode a Roman numeral was to remove any subtractive notation part from the input Roman numeral and replace it temporarily with an additive notation. For example, given the numeral MCIX, I would replace IX with VIIII, thus yielding MCVIIII; it is now very easy to add the symbols' values to find 1009. We can use a series of regex substitutions for that:

``` Perl6
sub remove_subtractive (Str $roman is copy) {
    my $roman = shift;
    for ($roman) {
        s/IV/IIII/;             # 4
        s/IX/VIIII/;            # 9    
        s/IL/XLVIIII/;          # 49
        s/XL/XXXX/;             # 40 to 49
        s/IC/LXXXXVIIII/;       # 99
        s/XC/LXXXX/;            # 90 to 98
        s/ID/XDVIIII/;          # 499
        s/XD/CDLXXXX/;          # 490 to 499
        s/CD/CCCC/;             # 400 to 499
        s/IM/CMLXXXXVIIII/;     # 999
        s/XM/CMLXXXX/;          # 990 to 998
        s/CM/DCCCC/;            # 900 to 999
    }
    return $roman;
}
```

Once these substitutions are performed, it is easy to read the individual letters of the modified Roman numeral and add the corresponding values to find the Arabic equivalent. 

But that's of course way too complicated. As soon as I started typing the first few of these regex substitutions in the `remove_subtractive` subroutine, I knew I wanted to find a better way to decode Roman numerals. I nonetheless completed it, because I wanted to show it on the blog. I also tested it quite thoroughly, and it seems to work properly. But I really want something simpler.

The new idea is to read the symbols one by one from left to right and to add the values, keeping track of the previously seen value. If the current value is larger than the previous value, then we were in a case of a subtractive combination at the previous step, and we need to subtract twice the previous value (once because it is a subtractive combination, and once again because we have previously erroneously added it). That's actually quite simple (see how the code of the `from_roman` subroutine below is much shorter and simpler than what we had tried above).

For encoding Arabic numerals to Roman numerals, the easiest is to perform integer division with decreasing values corresponding to Roman numerals (i.e. `M D C L X V I`). For example, suppose we want to encode 2019. We first try to divide by 1,000 (corresponding to M). We get 2, so the start of the string representing the Roman numeral will be MM. Then we continue with the remainder, i.e. 19. We try integer division successively with 500, 100 and 50 and get 0, so don't do anything with the result. Next we try with 10 and get 1, so the temporary result is now MMX. The remainder is 9; if we continue the same way with 9, we would divide by 5, add V to our string, and eventually obtain MMXVIIII, which is a correct (simplistic) Roman numeral for 2019, but not really what we want, since we want to apply the subtractive combination and get MMXIX.

Rather than reprocessing VIIII into IX (we've seen before how tedious this could be with regexes), we can observe that if our list of decreasing Roman values also includes IX (9), then it will work straight without any need to reprocess the result. So, our list of decreasing values corresponding to Roman numerals needs to be augmented with subtractive cases to `M CM D CD C XC L XL X IX V IV I` (corresponding to numbers 1000, 900, 500, 100, 90, 50, 40, 10, 9, 5, 4, 1). Using this list instead of the original one removes any need for special processing for subtractive combinations: we just need to keep doing integer divisions with the decreasing values and continue the processing with the remainder. This what the `to_roman` subroutine below does.

``` Perl6
use v6;

subset Roman-str of Str where $_ ~~ /^<[IVXLCDMivxlcdm]>+$/;

my %rom-tab = < I 1   V 5   X 10   L 50   C 100  D 500  M 1000 
               IV 4  IX 9   XL 40  XC 90  CD 400   CM 900 >;
my @ordered_romans = reverse sort { %rom-tab{$_} }, keys %rom-tab;

sub from-roman (Roman-str $roman) {
    my $numeric = 0;
    my $prev_letter = "M";
    for $roman.uc.comb -> $letter {
        $numeric -= 2 * %rom-tab{$prev_letter} 
            if %rom-tab{$letter} > %rom-tab{$prev_letter};
        $numeric += %rom-tab{$letter};
        $prev_letter = $letter;
    }
    return $numeric;
}

sub to-roman (Int $arabic is copy where  { 0 < $_ < 4000 }) {
    my $roman = "";
    for @ordered_romans -> $key {
        my $num = ($arabic / %rom-tab{$key}).Int;
        $roman ~= $key x $num;
        $arabic -= %rom-tab{$key} * $num; 
    }
    return $roman;
}
```

I'm fairly happy that all the specific properties of Roman numerals are implemented in the `%rom-tab` and `@ordered_romans` variable, so that the rest of the code is mostly generic.

For checking input Roman numerals, I created the `Roman-str` subtype (well, really, a subset) which accepts strings that are made only with the seven letters used in Roman numerals (both lower and upper cases). This makes it possible to validate (to a certain extent) the argument passed to the `from-roman` subroutine. Of course, some strings made of these letters may still be invalid Roman numerals, but, at least, we'll get an exception if we inadvertently pass an Arabic number or an invalid letter to it.

Similarly, since, according to our rules, Roman numerals can represent numbers between 1 and 3,999, the signature of the `to-roman` subroutine only accepts integers larger than 0 and less than 4,000.

### Testing our Program

For testing, we use the core [Test module](https://docs.perl6.org/type/Test). 

``` Perl6

use Test;
plan 45;

say "\nFrom Roman to Arabic";
for < MM 2000 MCM 1900 LXXIII 73 XCIII 93 IC 99 XCIX 99 xv 15> -> $roman, $arabic {
    is from-roman($roman), $arabic, "$roman => $arabic";
}
isnt from-roman("VII"), 8, "OK: VII not equal to 8";
for <12 foo bar MCMA> -> $param {
    dies-ok {from-roman $param}, "Caught exception OK in from-roman: wrong parameter";
}
say "\nFrom Arabic to Roman";
my %test-nums = map { $_[0] => $_[1] }, (
    <19 42 67 90 97 99 429 498 687 938 949 996 2145 3597> Z 
    <XIX XLII LXVII XC XCVII XCIX CDXXIX CDXCVIII DCLXXXVII 
     CMXXXVIII CMXLIX CMXCVI MMCXLV MMMDXCVII>);
for %test-nums.keys -> $key {
    is to-roman($key.Int), %test-nums{$key}, "$key => %test-nums{$key}";
}
for 0, 4000, "foobar", 3e6 -> $param {
    dies-ok { to-roman $param}, "Caught exception OK in to-roman: wrong parameter";
}
say "\nSome round trips: from Arabic to Roman to Arabic";
for %test-nums.keys.sort -> $key {
    is from-roman(to-roman $key.Int), $key, "Round trip OK for $key";
}
my $upper-bound = 3999;
say "\nSanity check (round trip through the whole range 1 .. $upper-bound range)";

lives-ok {
    for (1..$upper-bound) -> $arabic {
        die "Failed round trip on $arabic" if from-roman(to-roman $arabic) != $arabic;
    }
}, "Passed round trip on the full 1..$upper-bound range";
```

The second line above says that we're going to run 45 test cases (the last test case, the sanity check round trip, is actually testing 3,999 subcases, but it counts as only 1 case).

The `is` function test for equality of its first two arguments (and `isnt` tests reports "ok" is the values are not equal). The `dies-ok` checks that the code being tested throws an exception (good here to check that invalid subroutine arguments are rejected) and the `lives-ok` check that the code block being tested does not throw any exception.

These tests produce the following output:

    1..45
    
    From Roman to Arabic
    ok 1 - MM => 2000
    ok 2 - MCM => 1900
    ok 3 - LXXIII => 73
    ok 4 - XCIII => 93
    ok 5 - IC => 99
    ok 6 - XCIX => 99
    ok 7 - xv => 15
    ok 8 - OK: VII not equal to 8
    ok 9 - Caught exception OK in from-roman: wrong parameter
    ok 10 - Caught exception OK in from-roman: wrong parameter
    ok 11 - Caught exception OK in from-roman: wrong parameter
    ok 12 - Caught exception OK in from-roman: wrong parameter
    
    From Arabic to Roman
    ok 13 - 687 => DCLXXXVII
    ok 14 - 97 => XCVII
    ok 15 - 938 => CMXXXVIII
    ok 16 - 498 => CDXCVIII
    ok 17 - 19 => XIX
    ok 18 - 429 => CDXXIX
    ok 19 - 3597 => MMMDXCVII
    ok 20 - 2145 => MMCXLV
    ok 21 - 67 => LXVII
    ok 22 - 90 => XC
    ok 23 - 99 => XCIX
    ok 24 - 996 => CMXCVI
    ok 25 - 949 => CMXLIX
    ok 26 - 42 => XLII
    ok 27 - Caught exception OK in to-roman: wrong parameter
    ok 28 - Caught exception OK in to-roman: wrong parameter
    ok 29 - Caught exception OK in to-roman: wrong parameter
    ok 30 - Caught exception OK in to-roman: wrong parameter
    
    Some round trips: from Arabic to Roman to Arabic
    ok 31 - Round trip OK for 19
    ok 32 - Round trip OK for 2145
    ok 33 - Round trip OK for 3597
    ok 34 - Round trip OK for 42
    ok 35 - Round trip OK for 429
    ok 36 - Round trip OK for 498
    ok 37 - Round trip OK for 67
    ok 38 - Round trip OK for 687
    ok 39 - Round trip OK for 90
    ok 40 - Round trip OK for 938
    ok 41 - Round trip OK for 949
    ok 42 - Round trip OK for 97
    ok 43 - Round trip OK for 99
    ok 44 - Round trip OK for 996
    
    Sanity check (round trip through the whole range 1 .. 3999 range)
    ok 45 - Passed round trip on the full 1..3999 range


Note that, in the Roman to Arabic conversion, both IC and XCIX return 99, as expected, whereas, in the opposite conversion, 99 returns XCIX.

## Alternative Solutions

[Arne Sommer](https://github.com/manwar/perlweeklychallenge-club/blob/master/challenge-010/arne-sommer/perl6/ch-1.p6) implemented several versions of his program, you can check them in this [Github directory](https://github.com/manwar/perlweeklychallenge-club/blob/master/challenge-010/arne-sommer/perl6) or read [his blog](https://perl6.eu/roman.html). I will detail only one of the solutions. His program has to multi `MAIN` subroutines that detect in which direction to perform the conversion based on the arguments passed to the program and, as the case maybe, call the `to-roman` or `from-roman` subroutine. His `to-roman` subroutine is essentially a succession of `while` and `if` conditional statements:

``` Perl6
my $string = "";
while $number >= 1000 { $string ~= "M";  $number -= 1000; }
if $number >= 900     { $string ~= "CM"; $number -= 900; }
if $number >= 500     { $string ~= "D";  $number -= 500; }
if $number >= 400     { $string ~= "CD"; $number -= 400; }
while $number >= 100  { $string ~= "C";  $number -= 100; }
if $number >= 90      { $string ~= "XC"; $number -= 90; }
if $number >= 50      { $string ~= "L";  $number -= 50; }
#  rest of code omitted for the sake of brevity
```

His `from-roman` uses a hash mapping Roman symbols to numbers:
``` Perl6
my %value = ( I => 1, V => 5, X => 10, L => 50, C => 100, D => 500, M => 1000);
```

and is otherwise essentially a `while` loop on the `@digits` array of individual letters of a Roman numeral:

``` Perl6
while @digits
{
  my $current = @digits.shift;
  if @digits.elems
  {
    if %value{@digits[0]} > %value{$current}
    {
      $number += %value{@digits.shift} - %value{$current}; # [1]
      next;
    }
  }
  $number += %value{$current}; # [1]
}
```
Arne's [blog post](https://perl6.eu/roman.html) has very interesting additional considerations on how to add methods to the `Int` type for processing with Roman numerals, adding specific `base` methods and dealing with Roman Unicode symbols. Really worth reading.

[Daniel Mita](https://github.com/manwar/perlweeklychallenge-club/blob/master/challenge-010/daniel-mita/perl6/ch-1.p6) wrote a full-fledged [RomanNumeral](https://github.com/manwar/perlweeklychallenge-club/blob/master/challenge-010/daniel-mita/perl6/RomanNumerals.pm6) module, including one role and three exception classes. There are lots of very interesting ideas in this module, and I learned a few things from reading Daniel's code, but it is a bit too complex and long to be detailed here. Follow the link, you might learn quite a few things as well reading it.

[Feng Chang](https://github.com/manwar/perlweeklychallenge-club/blob/master/challenge-010/feng-chang/perl6/ch-1.p6) also has two multi `MAIN` subroutines to figure out which conversion to perform. Feng's code to convert from Roman to Arabic is quite concise:

``` Perl6
my %r2a = 'I' => 1, 'V' => 5, 'X' => 10, 'L' => 50, 'C' => 100, 'D' => 500, 'M' => 1000;
my @a = $p.comb.map:{ %r2a{ $_ } };
my $sum = [+] (0 .. (@a.elems - 2)).map:{ @a[$_] < @a[$_ + 1] ?? -@a[$_] !! @a[$_] };
$sum += @a[* - 1];
```

Feng's code for converting from Arabic to Roman is quite interesting, but a bit too long for this blog post. Follow the link if you want to know more.

[Francis J. Whittle](https://github.com/manwar/perlweeklychallenge-club/blob/master/challenge-010/fjwhittle/perl6/ch-1.p6) implemented a full-fledged grammar (and an actions class) to parse Roman numerals and convert them to Arabic numerals. Please, check Francis's code if you want to know more. For conversion from integer to Roman numeral, Francis implemented a hash (similar to mine) to map numbers to Roman symbols or subtractive symbol combination:

``` Perl6
my @nmap = (1000 => 'M', 900 => 'CM', 500 => 'D', 400 => 'CD',
             100 => 'C',  90 => 'XC',  50 => 'L',  40 => 'XL',
              10 => 'X',   9 => 'IX',   5 => 'V',   4 => 'IV',
               1 => 'I');
```

[Jaldhar M. Vyas](https://github.com/manwar/perlweeklychallenge-club/blob/master/challenge-010/jaldhar-h-vyas/perl6/ch-1.p6) also implemented a full-fledged grammar (and associated actions class) to parse Roman numeral). But I'm not convinced by his program. IMHO, his grammar probably works, but is far too complex. Similarly, his `toRoman` subroutine is also much too complex (the overall program has 191 code lines). Sorry, Jaldhar, your solution is almost 10 times longer than the solutions proposed by some other challengers, I think this is a little problem.

[Joelle Maslak](https://github.com/manwar/perlweeklychallenge-club/blob/master/challenge-010/joelle-maslak/perl6/ch-1.p6) used three multi `MAIN` subroutines, one for each conversion plus one for running tests. Her `roman-to-number` subroutine reads each Roman letter in turn and adds the value associated with the previous symbol, when the latter is larger than or equal to the current value, and subtract its when it is smaller. 

``` Perl6
my $last  = 0;
my $total = 0;
for $roman.comb -> $digit {
    my $val = %roman-digits{$digit};
    if $val ≤ $last {
        $total += $last;
    } else {
        $total -= $last;
    }
    $last = $val;
}
$total += $last;
```

Her `decimal-to-roman` uses an array of pairs in which the six subtractive pairs of symbols are coded (for example `IV => 4`). The main loop in this subroutine is very simple:

``` Perl6
for @conversions -> $pair {
    while $decimal ≥ $pair.value {
        $decimal -= $pair.value;
        $str     ~= $pair.key;
    }
}
```

[Ruben Westerberg](https://github.com/manwar/perlweeklychallenge-club/blob/master/challenge-010/ruben-westerberg/perl6/ch-1.p6)'s `decimalToRoman` subroutine processes the input Arabic number as a string and processes each digit one by one, leading to relatively complex code that I won't detail here. His `romanToDecimal` loops over each letter of the input Roman numeral and takes different actions to compute a `$sum` variable depending on whether next one is larger than the current one:

``` Perl6
for @c.kv -> $k, $v {
	if $k+1 < @c {
		if (%r{@c[$k+1]} > %r{$v}) {
			$diff=%r{$v};
		}
		else {
			$sum+=%r{$v}- $diff;
			$diff=0;
		}
	}
	else {
		$sum+=%r{$v}- $diff;
	}
}
```

[Simon Proctor](https://github.com/manwar/perlweeklychallenge-club/blob/master/challenge-010/simon-proctor/perl6/ch-1.p6)'s program manages both ASCII Latin letters and specific Unicode symbols for Roman numerals. Here, we'll leave aside Unicode symbols for Roman numerals for the sake of simplicity. Simon's `to-roman` subroutine uses an array or pairs:

``` Perl6
my @values = ( :1000M, :900CM, :500D, :400CD, :100C, :90XC, :50L, :40XL, :10X, :9IX, :5V, :4IV, :1I );
```

with the subtractive combinations to convert integers to Roman numerals. Note that the colon pair syntax `:1000M` is equivalent to `M => 1000`. The `to-roman` subroutine is then straight forward:

``` Perl6
for @values -> $pair {
    my ( $sigil, $num ) = $pair.kv;
    while ( $number >= $num ) {
        $out ~= $sigil;
        $number -= $num;
    }
}
```
Simon's `from-roman` subroutine looks quite long and complicated at first view because it handles a number of Unicode symbols, but it is in fact quite simple. The subroutine uses a regex with longest alternations to split the Roman numeral into pieces of one or two letters and then uses a `%roman-map` hash with essentially the same content as the `@values` array of pairs above to convert to Arabic numbers.  Removing the Unicode part, Simon's subroutine main code can be boiled down to this quite concise and clever loop:

``` Perl6
my $out = 0;
while my $match = $roman ~~ s/ M | CM | D | CD | C | XC | L | XL | X | IX | V | IV | I // {
    $out += %roman-map{$match};
} 
```

## See Also

Three blog posts this time:

* Arne Sommer: https://perl6.eu/roman.html

* Francis J. Whittle: https://rage.powered.ninja/2019/06/02/obiective-romanos-grammaticam.html

* Joelle Maslak: https://rage.powered.ninja/2019/06/02/obiective-romanos-grammaticam.html




## Wrapping up

Please let me know if I forgot any of the challengers or if you think my explanation of your code misses something important.

If you want to participate to the Perl Weekly Challenge, please connect to [this site](https://perlweeklychallenge.org/).

