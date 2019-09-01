# Vigenère Cipher

This is derived in part from my [blog post](http://blogs.perl.org/users/laurent_r/2019/07/perl-weekly-challenge-15-strong-and-weak-primes-and-vigenere-encryption.html) made in answer to the [Week 15 of the Perl Weekly Challenge](https://perlweeklychallenge.org/blog/perl-weekly-challenge-015/) organized by  <a href="http://blogs.perl.org/users/mohammad_s_anwar/">Mohammad S. Anwar</a> as well as answers made by others to the same challenge.

The challenge reads as follows:

*Write a script to implement Vigenère cipher. The script should be able encode and decode. Checkout [wiki page](https://en.wikipedia.org/wiki/Vigen%C3%A8re_cipher) for more information.*

The Vigenère cipher is actually a misnomer: in the nineteenth century, it has been mis-attributed to French diplomat and cryptographer Blaise de Vigenère, who published the method in 1586, and this is how it acquired its present name. But the method usually associated with Vigenère's name had been described more than three decades earlier (in 1553) by Italian cryptanalyst Giovan Battista Bellaso. It essentially resisted all attempts to break it until 1863, three centuries later. This being said, Vigenère is certainly a great figure in the history of cryptography, since he invented a very significant enhancement of that method that is not usually associated with Vigenère's name, but is usually named [autokey cypher](https://en.wikipedia.org/wiki/Autokey_cipher), but that's another story.

To understand the Vigenère cipher, we can first consider what is known as the *Caesar cipher*, in which each letter of the alphabet is shifted along some number of places. For example, in a Caesar cipher of shift 3, A would become D, B would become E, Y would become B and so on. So, for instance, "cheer" rotated by 7 places is "jolly" and "melon" rotated by -10 (or + 16) is "cubed". In the movie *A Space Odyssey*, the ship's computer is called HAL, which is IBM rotated by -1. One famous such cipher is *ROT13*, which is a Caesar cipher with rotation 13. Since 13 is half the number of letters in our alphabet, applying rotation 13 twice returns the original message, so that the same routine can be used for both encoding and decoding in rotation 13. Rotation 13 has been used very commonly on the Internet to hide potentially offensive jokes or to weakly hide the solution to a puzzle.

A Caesar cipher is very easy to break through letter frequency analysis.

In Edgar Allan Poe’s short story *The Gold Bug*, one of the characters, William Legrand, uses letter frequencies to crack a cipher. He explains:

> Now, in English, the letter which most frequently occurs is e. Afterwards, the succession runs thus: a o i d h n r s t u y c f g l m w b k p q x z. E however predominates so remarkably that an individual sentence of any length is rarely seen, in which it is not the prevailing character.

Edgar Poe's character is slightly wrong on part of the succession of letters: for example, he grossly underestimated the frequency of letter t, which is the second most common letter in English. But what he says about letter E is correct.

So, if you want to decipher a message encoded with a Caesar cipher in English, one way is to find out the most common letter in the encoded text, and that most common letter is likely to be an E. From there, you can figure out by which value each letter has shifted and decipher the whole message. If you were unlucky, just give a try with the second most common letter, and then the third. You're very likely to quickly succeed. Another possibility is brute force attack by trying all 26 possible values by which the letter are shifted. This is easy by hand, and very fast with a computer. A Caesar cipher is a very weak encryption system.

The idea of the Vigenère cipher is to shift each of the letters of the message by a different number of places. For example, if your encryption code is 1452, you rotate the first letter by one place, the second one by 4 places, the third by 5 places, the fourth by 2 places; if you have more letters to encode in your message, then your start again with the beginning of the code, and so on. For example, if you want to encode the word "peace," you get:

    p + 1 => q
    e + 4 => i
    a + 5 => f
    c + 2 => e
    e + 1 => f
    Encoded message: qifef.

In brief, a Vigenère cipher is using a series of interwoven Caesar ciphers. With such a system, frequency analysis becomes extremely difficult because, as we can see in the example above, the letter E is encoded into I in the first instance, and into F in the second instance. In fact, if the encryption key is a series of truly random bytes and is at least as long as the message to be encoded (and is thus used only once), the code is essentially unbreakable. In practice, a Vigenère cipher is usually not using a number as encryption key, but generally a password or a pass-phrase: the letters of the password are converted to a series of numbers according to their rank in the alphabet and those numbers are used as above to rotate the letters of the message to be encoded. Since the encryption code is no longer truly random, it becomes theoretically possible to break the code, but this is still very difficult, and that's the reason the Vigenère cipher has been considered unbreakable for about three centuries.

## My Solution

For this challenge, we will use the built-in functions `ord`, which converts a character to a numeric code (Unicode code point), and `chr` which converts such numeric code back to a characters. Letters of the alphabet are encoded in alphabetic order, so that, for example, testing under the Perl 6 REPL:

    > say ord('c') - ord('a');
    2

because 'c' is the second letter after 'a'. 

Originally, I kept letters within the `a..z` range (folding the input message to lowercase), because the numeric codes for uppercase letters are different, in order to keep as close as possible to the original Vigenère cipher. But the original cipher was limited to this range only because of the way encoding was done manually at the time. With a computer, there is no reason to limit ourselves to such range. So, the script below use the full range of an octet (0..255), i.e. the full extended ASCII range. This way we can also encode spaces, punctuation symbols, etc. Of course, this implies that the partner uses the same alphabet and scheme.

In this script, the bulk of the work is done in the `rotate-msg` and `rotate-one-letter` subroutines. The `encode` and `decode` subroutines are only calling them with the proper arguments. And the `create-code` subroutine is used to transform the password into an array of numeric values.

``` Perl6
use v6;

subset Letter of Str where .chars == 1;

sub create-code (Str $passwd) {
    # Converts password to a list of numeric codes
    # where 'a' corresponds to a shift of 1, etc.
    return $passwd.comb(1).map: {.ord - 'a'.ord + 1}
}
sub rotate-one-letter (Letter $letter, Int $shift) {
    # Converts a single letter and deals with cases 
    # where applying the shift would get out of range
    constant $max = 255;
    my $shifted = $letter.ord + $shift;
    $shifted = $shifted > $max ?? $shifted - $max !!
        $shifted < 0 ?? $shifted + $max !!
        $shifted;
    return $shifted.chr;
}
sub rotate-msg (Str $msg, @code) {
    # calls rotate-one-letter for each letter of the input message
    # and passes the right shift value for that letter
    my $i = 0;
    my $result = "";
    for $msg.comb(1) -> $letter {
        my $shift = @code[$i];
        $result ~= rotate-one-letter $letter, $shift;
        $i++; 
        $i = 0 if $i >= @code.elems;
    }
    return $result;
}
sub encode (Str $message, @key) {
    rotate-msg $message, @key;
}
sub decode (Str $message, @key) {
    my @back-key = map {- $_}, @key;
    rotate-msg $message, @back-key;
}
multi MAIN (Str $message, Str $password) {
    my @code = create-code $password;
    my $ciphertext = encode $message, @code;
    say "Encoded cyphertext: $ciphertext";
    say "Roundtrip to decoded message: {decode $ciphertext, @code}";
}
multi MAIN ("test") {
    use Test; # Minimal tests for providing an example
    plan 6;
    my $code = join "", create-code("abcde");
    is $code, 12345, "Testing create-code";
    my @c = create-code "password";
    for <foo bar hello world> -> $word {
        is decode( encode($word, @c), @c), $word, 
            "Round trip for $word";
    }
    my $msg = "One small step for man, one giant leap for mankind!";
    my $ciphertext = encode $msg, @c;
    is decode($ciphertext, @c), $msg, 
        "Message with spaces and punctuation";
}    
```

In the script above, we have two MAIN multi subroutines. When the single argument is "test", the script runs a series of basic tests (which would probably have to be expanded in a real life project); when the arguments are two strings (a message to be encoded and a password), the script runs with the input arguments.

This is an example run with the "test" argument:

    $ perl6  vigenere.p6 test
    1..6
    ok 1 - Testing create-code
    ok 2 - Round trip for foo
    ok 3 - Round trip for bar
    ok 4 - Round trip for hello
    ok 5 - Round trip for world
    ok 6 - Message with spaces and punctuation

and with two arguments:

    $ perl6  vigenere.p6 AlphaBeta password
    Encoded cyphertext: Qm┬â{xQwxq
    Roundtrip to decoded message: AlphaBeta

In the [autokey cypher](https://en.wikipedia.org/wiki/Autokey_cipher) improvement of the Vigenère cypher mentioned at the beginning of this post (which is the true invention made by Vigenère), the key is not repeated, but used only once, and the rest of the message is encoded using the message itself as the key. The fact that the key is no longer repeated in the coding process defeats most of the first known methods to break the traditional Vigenère cypher.

## Alternate Solutions

[Arne Sommer](https://github.com/manwar/perlweeklychallenge-club/blob/master/challenge-015/arne-sommer/perl6/ch-2.p6) made a very simple and very concise implementation of the cypher dealing only with uppercase letters (as in Vigenère's original cypher). His program loops on the input string's numerical codes and at the same time on the key's numerical codes. It adds the key's codes when encrypting and subtract them when decrypting.

``` Perl6
subset UCASE of Str where * ~~ /^<[A .. Z]>+$/;

unit sub MAIN (UCASE $uppercase-string, UCASE $key, :$decrypt = False);

my $base = "A".ord;
my $key-length = $key.chars;

my @string = $uppercase-string.comb.map({ $_.ord - $base });
my @key    = $key.comb.map({ $_.ord - $base });

for ^@string.elems -> $p
{
  my $k = $p mod $key-length;

  $decrypt
    ?? print ($base + (@string[$p] - @key[$k] + 26) mod 26).chr
    !! print ($base + (@string[$p] + @key[$k]) mod 26).chr;
}
```

[Francis J. Whittle](https://github.com/manwar/perlweeklychallenge-club/blob/master/challenge-015/fjwhittle/perl6/ch-2.p6) first wrote an `ordinate` helper subroutine to transform the password or the message into a list of numeric codes. Once this is done, encoding a message boils down to:

``` Perl6
put ordinate($message).rotor(@key.elems, :partial).map({ (($_ Z+ @key) X% 26) X+ 'A'.ord})».Slip».chr.join
```
and decoding an encrypted message to:
``` Perl6
put ordinate($message).rotor(@key.elems, :partial).map({ (($_ Z- @key) X% 26) X+ 'A'.ord})».Slip».chr.join
```
Wow, that's quite impressive! And also a little bit cryptic: it took me quite a few minutes to understand these code lines.

[Kevin Colyer](https://github.com/manwar/perlweeklychallenge-club/blob/master/challenge-015/kevin-colyer/perl6/ch-2.p6) also limited the input text and the key to uppercase letters, and his program also loops on the input string's numeric codes and at the same time on the key's numerical codes. It multiplies the key numerical codes by -1 when decrypting. His central subroutine is also fairly simple and looks as follows:

``` Perl6
sub VigenereCipher($text,$key,$encode) {
    my $offset="A".ord;
    my @t = $text.uc.comb.map(*.ord-$offset);
    my @k = $key .uc.comb.map(*.ord-$offset);
    my @result;
    my $EorD = $encode==True ?? 1 !! -1;

    my $i=0;

    for ^@t -> $j {
        @result.push: chr($offset + ( (@t[$j]+ $EorD*@k[$i]) mod 26) );
        $i=($i+1) mod @k.elems;

    }
    return @result.join ;
}
```
One little surprising thing is that Kevin decided to abort his program when the key passed to it is longer than the message. I do not see any reason to do so, quite to the contrary: the code is much more difficult to break when the key has a length equal to or larger than the message (the repeating of the key is the main weakness of the Vigenère cypher).

[Athanasius](https://github.com/manwar/perlweeklychallenge-club/blob/master/challenge-015/athanasius/perl6/ch-2.p6) wrote two helper subroutines, `str2num` and `num2str`, to convert a string into an array of numerical items and back, which can be used both for the input string and the key. Before starting to encode or decode, the program copies the key numeric codes as many times as needed to obtain a final key equal to or longer than the text. At this point, encrypting a message from the array of its numeric codes becomes fairly easy:

``` Perl6
while @plain
    {
        my $m = @plain.shift;
        my $k = @key.shift;`
        @cipher.push: ($m + $k) % @ALPHABET.elems;
    }
    return num2str(@cipher);
}
```
and decrypting is just about the same with a minus sign instead of a plus.

[Jaldhar H. Vyas](https://github.com/manwar/perlweeklychallenge-club/blob/master/challenge-015/jaldhar-h-vyas/perl6/ch-2.p6) chose an unexpected and uncommon approach: he actually wrote a *tabula recta*: 

![Tabula recta](https://upload.wikimedia.org/wikipedia/commons/thumb/9/9a/Vigen%C3%A8re_square_shading.svg/330px-Vigen%C3%A8re_square_shading.svg.png)

i.e. Vigenère's original table of alphabets written out 26 times, each time shifted by one letter, in the form of hash of strings: `A => ABCDEFGHIJKLMNOPQRSTUVWXYZ, B => BCDEFGHIJKLMNOPQRSTUVWXYZA, ...`. Once this preparation work is done, this encrypt subroutine becomes quite concise:

``` Perl6
sub encrypt(@key, $keylength, %tabulaRecta, $c) {
    state $i = 0;

    return substr(%tabulaRecta{@key[$i++ % $keylength]}, ord($c) - ord('A'), 1);
}
```

[Joelle Maslak](https://github.com/manwar/perlweeklychallenge-club/blob/master/challenge-015/joelle-maslak/perl6/ch-2.p6) decided to accept upper case and lower case alphabetical characters for the input message. She managed the array of letters representing the key as a circular buffer: at each step during encoding or decoding, her program moves the first letter of the key to the end of the array, so that, for coding or decoding a message, her program always picks up the letter of the array.

[Ruben Westerberg](https://github.com/manwar/perlweeklychallenge-club/blob/master/challenge-015/ruben-westerberg/perl6/ch-2.p6) decided to use an alphabet containing upper case and lower case ASCII letters plus spaces and a few punctuation symbols. His program reads line by line from a file and writes to a file. It uses heavily the `>>` hyper-operator to encode in just one statement the input array of integer ASCII codes into an array of encoded numbers. I must say that it took me a while to understand that statement.

``` Perl6
sub MAIN ( Str $key, Bool :$decode, Str :$file ) {	
	my $f=$decode??1!!-1;
	$*OUT.out-buffer=0;
	my @alpha=("a".."z","A".."Z"," ", <? ! . : >)[*;*];
	my @a=@alpha.keys;
	my @k=$key.comb.map(-> $c {|@alpha.grep($c,:k)});
	for $*IN.lines -> $line {
		my @in= $line.comb.map(->$c {|@alpha.grep($c,:k)});
		my @t= (@in >>+>> (@k >>*>> $f)) >>%>> @a.elems;
		put  join "", @alpha[@t];
	}
}	
```

## See Also

Three blog posts on the Vigenère Cypher:

* Arne Sommer: https://perl6.eu/prime-vigenere.html.

* Jaldhar M. Vyas: https://www.braincells.com/perl/2019/07/perl_weekly_challenge_week_15.html.

* Damian Conway: http://blogs.perl.org/users/damian_conway/2019/07/vigenere-vs-vigenere.html. This blog post is truly awesome, as usual, you should really follow the link.


## Wrapping up

Please let me know if I forgot any of the challengers or if you think my explanation of your code misses something important.

If you want to participate to the Perl Weekly Challenge, please connect to [this site](https://perlweeklychallenge.org/).


