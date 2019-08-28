# The Lempel–Ziv–Welch (LZW) Compression Algorithm

This is derived from my [blog post](http://blogs.perl.org/users/laurent_r/2019/08/perl-weekly-challenge-22-sexy-prime-pairs-and-compression-algorithm.html) made in answer to the [Week 22 of the Perl Weekly Challenge](https://perlweeklychallenge.org/blog/perl-weekly-challenge-022/) organized by  <a href="http://blogs.perl.org/users/mohammad_s_anwar/">Mohammad S. Anwar</a> as well as answers made by others to the same challenge.

The challenge reads as follows:

*Write a script to implement Lempel–Ziv–Welch (LZW) compression algorithm. The script should have method to encode/decode algorithm. The [wiki page](https://en.wikipedia.org/wiki/Lempel%E2%80%93Ziv%E2%80%93Welch) explains the compression algorithm very nicely.*

Lempel–Ziv–Welch (LZW) is a lossless data compression algorithm created by Abraham Lempel, Jacob Ziv, and Terry Welch. It was published by Welch in 1984 as an improved implementation of the [LZ78](https://en.wikipedia.org/wiki/LZ77_and_LZ78) algorithm published by Lempel and Ziv in 1978.

The scenario described by Welch encodes sequences of 8-bit data as fixed-length 12-bit codes. The codes from 0 to 255 represent 1-character sequences consisting of the corresponding 8-bit character, and the codes 256 through 4095 are created in a dictionary for sequences encountered in the data as it is encoded. At each stage in compression, input bytes are gathered into a sequence until the next character would make a sequence with no code yet in the dictionary. The code for the sequence (without that character) is added to the output, and a new code (for the sequence with that character) is added to the dictionary.

For encoding (or, really, compressing) a string, we buffer input the characters in a sequence `$ω` (note that we use here the variables names from the Wikipedia page to facilitate understanding) until the next `$ω` is not in the `%dict` hash.  At this point, emit the code for `$ω`, and add `$ω` plus the next character to the hash. Start buffering again with the next character. Concretely, we first populate the `%dict` hash with the single possible letters. Then, we traverse the input string character by character and build the sequence as long as it exists in the `dict` hash. When the new sequence to be built does not exist in the hash, we add the previous sequence to the result, add the new one to the hash and start a new sequence with the last visited character.

For decoding (decompressing), we use the same initial hash as when encoding (we don't need the final hash, so we don't need to transmit the final dictionary; the start dictionary is all we need and can be hard coded).  Additional entries can be reconstructed as they are always simply concatenations of previous entries. Concretely, we populate `%dict` hash as before, but inverting keys and values. Then we go through the codes one by one; if a code exists in the hash, we just convert it and add it to the output; else, we build the new sequence, add it to the output and add the sequence concatenated with the sequence's first character to the hash.

Note that the Wikipedia description specifies a stop character (`#`) to indicate the end of a message, but we don't really need it. 

### My Solution

For a start, we will use an input string ('TOBEORNOTTOBEORTOBEOR...') consisting only of capital letters (`'A'..'Z'`), as in the Wikipedia article, and populate our initial hash `%dict` with corresponding numeric codes between 0 and 25. Then we start at looking at the string to be encoded. The first letter *T* exists in `%dict`, so we look for a two letter sequence, *TO*, which does not exists in the hash; at this point we add the code for *T* to the result and add to `%dict` a new code (in this case 26) corresponding to *TO*. And so on.

The beginning of the compressed sequence might be as follows:

    T  O  B E O  R  N  O  T  TO BE 
    19 14 1 4 14 17 13 14 19 26 28 


When decoding, we first build the same initial hash, but with keys and values inverted. The first 9 codes (all between 0 and 25) will be decoded with the initial hash. When we find code 26, which is not in our hash, we know it is the first sequence of letters at the start of the part of the string that we have already decoded, so it is *TO*, and we can add that to our `%dict` hash. The next (28) will be *BE* (since code 27, not appearing so far in our codes, will have been taken by *OB*). And so on. Except that, in reality, you don't wait for a code not present in your hash to add an entry to the `%dict` hash: you start doing it as soon as you start decoding the first letters, so that, in effect, the `encode` and `decode` subroutines populate the dictionary in exactly the same way.

    use v6;

    constant $start-dict-size = 26;

    sub encode (Str $in) {
        my %dict = map { $_[0] => $_[1] }, 
            ( ('A'..'Z') Z (^$start-dict-size) );
        my $ω = "";
        my @result = gather {
            for $in.comb -> $c {
                my $ωc = $ω ~ $c;
                if %dict{$ωc}:exists {
                    $ω = $ωc;
                } else {
                    take %dict{$ω};
                    %dict{$ωc} = +%dict;
                    $ω = $c;
                }
            }
            take %dict{$ω} if $ω.chars;
        }
        # say %dict;
        return @result;
    }
    sub decode (@encoded) {
        my $dict-size = $start-dict-size;
        my %dict = map { $_[1] => $_[0] }, 
            ( ('A'..'Z') Z (^$start-dict-size) );
        my $ω = %dict{shift @encoded};
        my @result = gather {
            take $ω; 
            for @encoded -> $i {
                my $str;
                if %dict{$i}:exists {
                    $str = %dict{$i};
                } elsif  $i == $dict-size {
                    $str = $ω ~ $ω.substr(0,1) 
                }
                take $str;
                %dict{$dict-size++} = $ω ~ $str.substr(0,1);
                $ω = $str;
            }
        }
        return join "", @result;
    }
                    
    my $input_str = 'TOBEORNOTTOBETOBEORNOTTOBETOBEORNOTTOBE';
    my @encoded = encode $input_str;
    say @encoded;
    say decode @encoded;

Running this code produces a correct round trip and displays the following output:

    $ perl6 LZW_compression.p6
    [19 14 1 4 14 17 13 14 19 26 28 35 29 31 33 37 37 30 32 34 27 4]
    TOBEORNOTTOBETOBEORNOTTOBETOBEORNOTTOBE

The encoded (compressed) code has 22 numbers that could each be encoded over 6 bits, so that's a total of 132 bits. The input string had 39 bytes, i.e. 312 bits. In other words, we obtain a compression ratio of 2.36. Admittedly, we could have used a fixed-length encoding scheme and encoded each character of the input string over 5 bits, which would have led to a total of 195 bits, leading to a compression ratio of 1.6. We still get an LZW compression ratio which is 1.47 times better than a fixed-length encoding. 

The reason for this better compression ratio is that many of our numeric codes represent two letters of the input, and some of them even more letters; for example, numeric code (35) stands for 3 letters, "TOB", and code 37 stands for 4 letters, "TOBE":

    19 14 1 4 14 17 13 14 19 26 28 35  29 31 33 37   37   30 32 34 27 4
    T  O  B E O  R  N  O  T  TO BE TOB EO RN OT TOBE TOBE OR NO TT OB E

Encoding only ASCII upper case letters is of course very limited. Leaving aside Unicode, we would like at least to be able to compress bytes encoded over 256 bits. For this, we only need to change the `$start-dict-size` constant to 256 and to populate the initial `%dict` hash accordingly. For example, this way for the `encode` subroutine:

    my %dict = map { .chr => $_ }, ^$start-dict-size;

And this way in the `decode` subroutine:

    my %dict = map { $_ => .chr }, ^$start-dict-size;

The compressed code still has 22 numbers, but the compression rate would fall down, because these numbers would now need to be encoded over more bits:

    [84 79 66 69 79 82 78 79 84 256 258 265 259 261 263 267 267 260 262 264 257 69]

And we can now compress data not comprising only of capital ASCII letters. For example, with the following input string:

    To be or not to be, to be or not to be, that's the question

we obtain the following output:

    perl6 LZW_compression.p6
    [84 111 32 98 101 32 111 114 32 110 111 116 32 116 257 259 44 268 270 260 262 264 266 
    273 258 101 272 116 104 97 116 39 115 268 104 260 113 117 101 115 116 105 111 110]
    To be or not to be, to be or not to be, that's the question

Here, we have 44 the compressed codes for an input string of 59 bytes; i.e. a compression ration of about 0.74. 

In a real implementation, we would need to set some limit to the dictionary size, because memory is limited and, also, it doesn't really make sense to keep adding longer and longer sequences of characters as, the longer they grow, the more unlikely we will find repetitions. On course, the `encode` and `decode` subroutines have to agree on that size limit. There was no reason to implement such a size limit for our tiny toy examples.

If you're interested with data compression techniques, you might also want to take a look at the exercise on Huffman coding (as well as its solutions) at the end of chapter 10 of my *Think Perl 6* book, which can be downloaded for free in PDF format on this [same github repository](https://github.com/LaurentRosenfeld/thinkperl6/tree/master/PDF).

## Alternative Solutions

The description of the LZW algorithm is a fairly detailed specification that leaves relatively little room for imagination. Therefore, the solutions suggested by the challengers are mostly looking very similar, usually only implementation details outside the algorithm itself vary.

[Arne Sommer](https://github.com/manwar/perlweeklychallenge-club/blob/master/challenge-022/arne-sommer/perl6/ch-2.p6) started with an alphabet and a hash consisting only of the letters occurring in the string to be compressed. This make a smaller alphabet and initial dictionary size, but this means that the alphabet needs to be transmitted to the decoding subroutine. Besides that, the algorithm is essentially the same, except that Arne converts the compressed message into a binary string (i.e. a string comprised of 0 and 1 characters).

[Roger Bell West](https://github.com/manwar/perlweeklychallenge-club/blob/master/challenge-022/ruben-westerberg/perl6/ch-2.p6) also started with a dictionary consisting only of the letters occurring in the string to be compressed. His `encode` subroutine does what it is supposed to do. But his `decode` subroutine uses the full dictionary prepared by `encode` as a parameter, so that it does not have anything to do other than a simple dictionary lookup:

```Perl6
sub decode(@dict, @in, @out) {
	for @in {
		push @out, @dict[$_];
	}
}
```
OK, fair enough, this is simple and it works, but, IMHO, that's not really the spirit of the LZW algorithm, in which the decoder is supposed to rebuild the dictionary in the same way as the coder originally populated it. 

[Kevin Colyer](https://github.com/manwar/perlweeklychallenge-club/blob/master/challenge-022/kevin-colyer/perl5/ch-2.pl) used a dictionary hardset to ASCII upper case, as I did in my initial solution. Also to be noted; Kevin used an array and not a hash for his dictionary, so that letter sequence lookup is a bit tedious in his `encode` subroutine.

[Ozzy](https://github.com/manwar/perlweeklychallenge-club/blob/master/challenge-022/ozzy/perl6/ch-2.p6) used a dictionary with the full extended ASCII range. Ozzy's code provides a nice graphical description of the way the algorithm works for the sample string "yadayada," which I think is worth quoting, just in case my description above wasn't clear or concise enough in your eyes:

    # Encoding
    # String      : yadayada
    # Code points : [121 97 100 97 121 97 100 97]
    #
    #     Output       Code      New dict. entry
    #          y        121            ya  [256]
    #          a         97            ad  [257]
    #          d        100            da  [258]
    #          a         97            ay  [259]
    #         ya        256           yad  [260]
    #         da        258
    #
    # Decoding
    # Code points : [121 97 100 97 256 258]
    #
    #     Output       Code      New dict. entry
    #          y        121
    #          a         97             ya [256]
    #          d        100             ad [257]
    #          a         97             da [258]
    #         ya        256             ay [259]
    #         da        258            yad [260]

[Simon Proctor](https://github.com/manwar/perlweeklychallenge-club/blob/master/challenge-022/simon-proctor/perl6/ch-2.p6) created a program with not less than 8 multi MAIN subroutines, to provide possibilities to encode or decode from a passed argument, from STDIN, from a file, etc. He used an alphabet somewhat intermediate between only upper case ASCII letters and full extended ASCII range, with all alphanumerical characters and some additional punctuation and other signs:

``` Perl6
subset ValidToEncode of Str where m/^<[a..z A..Z 0..9 \  _ \n \. , ]>* \n?$/;
```

This subset is used in the signature of the `encode-data` multi method to accept or reject input. The output of that method is a string of space separated numbers.

[Athanasius](https://github.com/manwar/perlweeklychallenge-club/blob/master/challenge-022/athanasius/perl6/ch-2.p6) compressed the input into an array of numeric codes. His starting dictionary contains all extended ASCII or ISO-8859-1) codes between 0 and 255. His program nicely outputs some statistics about the compression, for example (with a highly repetitive input string):

    Number of characters
      Original: 15
      Encoded:   9
      Decoded:  15

    Encoding/decoding successful
      Compression ratio:  1.7
      Space savings:      40.0%
      Dictionary entries: 264
  
[Jaldar H. Vyas](https://github.com/manwar/perlweeklychallenge-club/blob/master/challenge-022/jaldhar-h-vyas/perl6/ch-2.p6)'s starting alphabet also contains all extended ASCII characters with codes between 0 and 255, although his test uses a string with only a few upper case ASCII letters (`A..Z`).

[Yet Ebreo](https://github.com/manwar/perlweeklychallenge-club/blob/master/challenge-022/yet-ebreo/perl6/ch-2.p6) also started with a dictionary containing all extended ASCII characters with codes between 0 and 255. His encoded result is an array of integers, as for many of us. For someone who had never written any script in Perl 6 just days before, Yet's code is pretty clean and even often quite idiomatic (although some syntax constructs are obviously influenced by his knowledge of Perl 5, but I guess you could probably say the same thing about me). 

[Joelle Maslak](https://github.com/manwar/perlweeklychallenge-club/blob/master/challenge-022/joelle-maslak/perl6/ch-2.p6) wrote a full OOP program with three classes, `Dictionary`,  `Bitwise-Write`, and `Bitwise-Read`. Her solution is the most complete one, as it is one of the only two that actually perform binary encoding of the compressed data.

[Randy Lauen](https://github.com/manwar/perlweeklychallenge-club/blob/master/challenge-022/randy-lauen/perl6/ch-2.p6) is the other most complete solution that provides actual binary encoding of the compressed data. For this, it uses lizmat's [P5pack](https://github.com/lizmat/P5pack) module, which implements in Perl 6 the Perl 5 `pack` and `unpack` built-ins. He used this module presumably because he found it easier since his P6 version is a port of his earlier P5 implementation.

## See Also

Only two blog posts on LZW compression:

Arne Sommer: https://perl6.eu/prime-lzw.html.

Jaldar H. Vyas: https://www.braincells.com/perl/2019/08/perl_weekly_challenge_week_22.html


## Wrapping up

Please let me know if I forgot any of the challengers or if you think my explanation of your code misses something important.

If you want to participate to the Perl Weekly Challenge, please connect to [this site](https://perlweeklychallenge.org/).






