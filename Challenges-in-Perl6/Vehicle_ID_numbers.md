# Vehicle Identification Numbers (VIN)

This is derived in part from my [blog post](http://blogs.perl.org/users/laurent_r/2019/05/perl-weekly-challenge-6-compact-number-ranges.html) made in answer to the [Week 6 of the Perl Weekly Challenge](https://perlweeklychallenge.org/blog/perl-weekly-challenge-036/) organized by  <a href="http://blogs.perl.org/users/mohammad_s_anwar/">Mohammad S. Anwar</a> as well as answers made by others to the same challenge.

The challenge reads as follows:

*Write a program to validate given Vehicle Identification Number (VIN). For more information, please checkout [wikipedia](https://en.wikipedia.org/wiki/Vehicle_identification_number).*

From the Wikipedia article, it appears that VINs are made up of 17 digits and upper-case letters, with the exception of letters I (i), O (o) and Q (q), to avoid confusion with numerals 0, 1, and 9. There are some additional rules that only applicable to certain areas of the world but are not internationally recognized.

## My Solutions

We write a simple `validate` subroutine that returns a true value if the passed parameter complies with the above rules for VINs and a false value otherwise. 

In addition, we write a test suite in the Raku [Test](https://docs.raku.org/language/testing) framework containing 16 test cases. The `ok` function is fine for checking if a Boolean value is true; contrary to the Perl 5 `Test::More` testing framework, the Raku `Test` framework also has a `nok` function that makes it possible to test directly a false Boolean value.

``` Perl6
use v6;
use Test;

sub validate ($vin) {
    return False if $vin ~~ /<[OIQ]>/;
    return True if $vin ~~ /^ <[A..Z0..9]> ** 17 $/;
    return False;
}

plan 16;

ok  validate("A" x 17),   "17 A's";
ok  validate(1 x 17),     "17 digits";
nok validate("AEIOU"),    "Five vowels";
nok validate(1234567890), "Ten digits";
nok validate("1234AEIOU5678901"),   "sixteen digits or letters";
ok  validate("12345678901234567"),  "17 digits";
nok validate("1234567890123456Q"),  "16 digits and a Q";
nok validate("1234567890123456O"),  "16 digits and a O";
nok validate("1234567890123456I"),  "16 digits and a I";
nok validate("Q1234567890123456"),  "A Q and 16 digits";
nok validate("I1234567890123456"),  "An I and 16 digits";
ok  validate("ABCD4567890123456"),  "17 digits and letters";
nok validate("ABef4567890123456"),  "Digits and some lower case letters";
nok validate("ABE?4567890123456"),  "A non alphanumerical character";
nok validate("ABCD4567 90123456"),  "A space";
nok validate("ABCD45678901234567"), "More than 17 characters";
```

Running the program shows that all test pass:

    $ perl6 vin.p6
    1..16
    ok 1 - 17 A's
    ok 2 - 17 digits
    ok 3 - Five vowels
    ok 4 - Ten digits
    ok 5 - sixteen digits or letters
    ok 6 - 17 digits
    ok 7 - 16 digits and a Q
    ok 8 - 16 digits and a O
    ok 9 - 16 digits and a I
    ok 10 - A Q and 16 digits
    ok 11 - An I and 16 digits
    ok 12 - 17 digits and letters
    ok 13 - Digits and some lower case letters
    ok 14 - A non alphanumerical character
    ok 15 - A space
    ok 16 - More than 17 characters

In North America, the ninth position in a VIN is a check digit i.e. a number calculated from all other characters. Although this is not explicitly requested in the task, we'll make a second version of our program also verifying the check digit, as a bonus. The `check-digit` subroutine splits the input string, translates the characters into numbers, multiplies each number by the weight assigned to its rank, sums up all the results, computes the remainder of its division by 11, and replaces the remainder by "X" if it is found to be 10.

``` Perl6
use v6;

sub validate (Str $vin) {
    return False if $vin ~~ /<[OIQ]>/;
    return False unless $vin ~~ /^ <[A..Z0..9]> ** 17 $/;
    return check-digit $vin;
}

sub check-digit (Str $vin) {
    my %translations = A => 1, B => 2, C => 3, D => 4, E => 5, F => 6, G => 7, H => 8,
        J => 1, K => 2, L => 3, M => 4, N => 5, P => 7, R => 9, S => 2,
        T => 3, U => 4, V => 5, W => 6, X => 7, Y => 8, Z => 9;
    %translations{$_} = $_ for 0..9;
    my @weights = 8, 7, 6, 5, 4, 3, 2, 10, 0, 9, 8, 7, 6, 5, 4, 3, 2;
    my $i = 0;
    my $sum = sum map { %translations{$_} * @weights[$i++]}, $vin.comb;
    my $mod = $sum % 11;
    $mod = 'X' if $mod == 10;
    return True if $mod eq substr $vin, 8, 1;
    return False;
}

sub MAIN (Str $vin = "1M8GDM9AXKP042788") {
    say validate($vin) ?? "Correct" !! "Wrong"; 
}
```

Running the program displays the following output:

    $ perl6 vin.p6
    Correct
    
    $ perl6 vin.p6 1M8GDM9AXKP042788
    Correct
    
    $ perl6 vin.p6 1M8GDM9AXKP042789
    Wrong

## Alternative Solutions

[Arne Sommer](https://github.com/manwar/perlweeklychallenge-club/blob/master/challenge-036/arne-sommer/perl6/ch-1.p6) provided a 300-line script telling me that, apparently, I must have missed a lot of the rules. Among other things, his code seems to be checking country codes, manufacturer codes (although a number of manufacturers appear to be missing, such as Citroen, Fiat, Renault, Skoda, Seat, Peugeot or several Chinese companies, but this is apparently because the list would have been too long, so Arne decided just to prune some of it) and construction year codes. I can't summarize here such a lengthy piece of code, please follow the link to his code just above (or look as his [blog](https://raku-musings.com/vin-knapsack.html)) if you want to know more.

Note that his `VINCHAR` regex:

``` Perl6
my regex VINCHAR { A | B | C | D | E | F | G | H | J | K | L | M | N | P | R | S | T | U | V | W | X | Y | Z | 1 | 2 | 3 | 4 | 5 | 6 | 7 | 8 | 9 | 0 };
```

might be expressed more conveniently (or, at least, more concisely), with a character class as something like this:

``` Perl6
my regex VINCHAR { < [A..Z0..9] - [IOQ] > };
```

[Javier Luque](https://github.com/manwar/perlweeklychallenge-club/blob/master/challenge-036/javier-luque/perl6/ch-1.p6) also implemented a lot of rules which I did not know about. This is his main VIN-checking subroutine:

``` Perl6
sub _check-vin(Str $vin) {
    my $vin_re = /<[A..HJ..NPR..Z0..9]>/;

    # Check for valid World Vin
    return Nil unless ($vin ~~ /
        ^^              # Start of string
        ($vin_re ** 3)  # World identification number
        ($vin_re ** 6)  # Vehicle descriptor section
        ($vin_re ** 8)  # Vehicle identifier section
        $$              # End of string
    /);

    # Capture parts of the vin
    my $win = $0; # World identification number
    my $vds = $1; # Vehicle descriptor section
    my $vis = $2; # Vehicle identifier section

    # 1st digit of the VIS can't be a U, Z or 0
    return Nil if ($vis ~~ /^^<[UZ0]>/);

    # Need to validate check digit
    # compulsory for vehicles
    # in North America and China,
    if ($win ~~ /^^<[1..5L]>/) {
        return Nil unless check-digit($vin);
    }

    # In america and china the last 5
    # digits of the vis is numeric
    if ($win ~~  /^^<[1..5L]>/) {
        return Nil unless ($vis ~~ /
            ^^             # Start of string
            $vin_re ** 3   # First 3
            \d  ** 5       # Last 5 digits
            $$             # End of string
        /);
    }

    return 1;
}
```



[Daniel Mita](https://github.com/manwar/perlweeklychallenge-club/blob/master/challenge-036/daniel-mita/perl6/ch-1.p6) wrote a small grammar to perform VIN validation:

``` Perl6
grammar VIN {
  token TOP  { <WMI> <VDS> <VIS> }
  token WMI  { <.char> ** 3 }
  token VDS  { <.char> ** 6 }
  token VIS  { <.char> ** 8 }
  token char { <[A..H J..N P R..Z 0..9]> }
}
```

That's quite nice, but, to tell the truth, since three of the tokens are just a number of `char` tokens, it seems to me that the grammar may slightly over-engineered, as this grammar:

``` Perl6
grammar VIN {
  token TOP  { <.char> ** 17 }
  token char { <[A..H J..N P R..Z 0..9]> }
}
```

should presumably yield the same result (unless you intend to do further things with the `<WMI>`, `<VDS>`, and `<VIS>` tokens).

[Kevin Colyer](https://github.com/manwar/perlweeklychallenge-club/blob/master/challenge-036/kevin-colyer/perl6/ch-1.p6), like me, checks the length of the VIN, also checks that it does not contains invalid letters (I, O, and Q), and it verifies the check digit:

``` Perl6
sub validateVIN($vin is copy) {
    my @v= $vin.uc.comb;
    return "invalid vin character: I,O or Q"     if $vin ~~ m:i/ <[ I O Q ]>+ /;
    return "invalid vin length {$vin.chars}" if $vin.chars != 17;

    my $check=@v[8];
    $check = 0  if $check eq '_';
    $check = 10 if $check eq 'X';
    my $i=0;

    for ^17 {
        $i += %value{@v[$_]} * @weight[$_];
    };

    return $i % 11 == $check ?? "valid" !! "invalid - failed checksum" ;
}
```

[Simon Proctor](https://github.com/manwar/perlweeklychallenge-club/blob/master/challenge-036/simon-proctor/perl6/ch-1.p6) basically checks the same things as Kevin:

``` Perl6
subset ValidVinStr of Str
    where m/^ <[A..Z 0..9] - [IOQ]> ** 9 <[A..Z 0..9] - [IOQUZ0]> <[A..Z 0..9] - [IOQ]> ** 7 $/;

#| Validate a North American VIN
sub MAIN (
    ValidVinStr $vin #= VIN to check
) {
    my %transliterator = ( ( "A".."Z" ) Z=> ( |(1..9),|(1..9),|(2..9) ) );

    my @combed = $vin.comb();
    my $check = @combed[8];
    my $calc-check = ( [+] (@combed[|(0..7),|(9..16)].map( { %transliterator{$_} // $_ } )) Z* (|(8...2),|(10...2)) ) % 11;
    $calc-check = "X" if $calc-check == 10;
    say $calc-check ~~ $check ?? "Valid VIN $vin" !! "Invalid VIN $vin";
}
```

[Ulrich Rieke](https://github.com/manwar/perlweeklychallenge-club/blob/master/challenge-036/ulrich-rieke/perl6/ch-1.p6) essentially checked the same things:

``` Perl6
sub validate_VIN_number( Str $vincode ) returns Bool {
  if ( $vincode ~~ / 'I' | 'Q' | 'O' / ) {
      return False ;
  }
  if ( $vincode.substr( 9 , 1 ) ~~ /<[IQOUZ0]>/ ) {
      return False ;
  }
  if ( $vincode.substr( 9 , 1) !~~ /<[A..Y1..9]>/ ) {
      return False ;
  }
  if ( $vincode ~~ /<[A..Z1..9]-[IOQ]> ** 17/ ) {
    return True ;
  }
  return True ;
}
```

However, his 37-line `test_check_digit` subroutine seems a bit too complicated to me.

[Jaldar H. Vyas](https://github.com/manwar/perlweeklychallenge-club/blob/master/challenge-036/jaldhar-h-vyas/perl6/ch-1.p6), on the other hand, made something a little bit too simple in my view, as it doesn't do any check on the forbidden `IOQ` letters (yet, adding that check would be very simple).

``` Perl6
sub validateVIN(Str $vin) {

    if ($vin.chars != 17) {
        return False;
    }

    if $vin !~~ /^
        <alnum> ** 3 # World Manufacturer Identifier
        <alnum> ** 6 # Vehicle Descriptor Section
        <alnum> ** 8 # Vehicle Identifier Section
    $/ {
        return False;
    }

    return True;
}
```

[Roger Bell West](https://github.com/manwar/perlweeklychallenge-club/blob/master/challenge-036/roger-bell-west/perl6/ch-1.p6) made some reasonable sense with the somewhat weird-looking translation table for the check-digit calculation:

``` Perl6
my %cvalue;
map {%cvalue{$_}=$_}, (0..9);
my $base=ord('A');
for (slip('A'..'H'),slip('J'..'N'),'P','R') -> $char {
  %cvalue{$char}=(ord($char)-$base)%9+1;
}
for ('S'..'Z') -> $char {
  %cvalue{$char}=(ord($char)-$base)%9+2;
}
my $valid='^<[' ~ join('',keys %cvalue) ~ ']>*$';
```
Also notice, on the last line above, how his program cleverly uses the keys of the `%cvalue` hash to build a `$valid` regex character class pattern for later use:

``` Perl6
unless ($vin ~~ /<$valid>/) {
    print "$vin contains invalid characters\n";
    next;
}
```
[Ruben Westerberg](https://github.com/manwar/perlweeklychallenge-club/blob/master/challenge-036/ruben-westerberg/perl6/ch-1.p6) made one of the most concise implementations:

``` Perl6
my @vins:=@*ARGS;
my %keys=((0..9 Z 0..9),("A".."H" Z 1..8), ("J".."N" Z 1..5), "P",7, "R",9,("S".."Z" Z 2..9)).flat;
my @weights=((2..8).reverse,10,0,(2..9).reverse).flat;

for @vins {
	my $i=0;
	print "Testing $_: ";
	my $result="OK";	

	$result ="Invalid digits present" unless /^<[A..Z]+[0..9]>**17$/;
	$result ="Incorrect length" if $_.chars != 17;

	if $result eq "OK"  {
		my $check=$_.comb.map({%keys{$_} * @weights[$i++]}).sum % 11;
		$check="X" if $check == 10;
		$result= "Invalid VIN number" if $check ne $_.substr(8,1);
	}
	put $result;
}
```

I especially like the innovative way in which Ruben constructs the `%key` character-translation hash and the `@weights` array used for computing the check digit, as well as the way he computes the check digit in just one statement.

## See Also

Three blog posts (besides mine) this time:

Arne Sommer: https://raku-musings.com/vin-knapsack.html;

Kevin Colyer wrote his first blog on the Perl Weekly Challenge: https://raku-musings.com/vin-knapsack.html; 

Javier Luque: https://perlchallenges.wordpress.com/2019/11/25/perl-weekly-challenge-036/.

## Wrapping up

Please let me know if I forgot any of the challengers or if you think my explanation of your code misses something important (send me an e-mail or just raise an issue against this GitHub page).

If you want to participate to the Perl Weekly Challenge, please connect to [this site](https://perlweeklychallenge.org/).
