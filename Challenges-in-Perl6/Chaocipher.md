# Implementation of the Chaocipher Algorithm

This is derived from my [blog post](http://blogs.perl.org/users/laurent_r/2019/09/perl-weekly-challenge-25-pokemon-sequence-and-chaocipher.html) made in answer to the [Week 25 of the Perl Weekly Challenge](https://perlweeklychallenge.org/blog/perl-weekly-challenge-025/) organized by  <a href="http://blogs.perl.org/users/mohammad_s_anwar/">Mohammad S. Anwar</a> as well as answers made by others to the same challenge.

The challenge reads as follows:
*Create script to implement __Chaocipher__. Please checkout [wiki page](https://en.wikipedia.org/wiki/Chaocipher) for more information.*

According to the linked Wikipedia page, the Chaocipher is a cipher method invented by John Francis Byrne in 1918 and described in his 1953 autobiographical *Silent Years*. He believed Chaocipher was simple, yet unbreakable. He offered cash rewards for anyone who could solve it (but, apparently, no one succeeded). In May 2010, the Byrne family donated all Chaocipher-related papers and artifacts to the National Cryptologic Museum in Ft. Meade, Maryland, USA. This led to the disclosure of the Chaocipher algorithm in a paper entitled [Chaocypher Revealed: the Algorithm](http://www.chaocipher.com/ActualChaocipher/Chaocipher-Revealed-Algorithm.pdf) (2010), by Moshe Rubin.

### How the Chaocipher works

The Chaocipher system consists of two alphabets, with the "right" alphabet used for locating the plaintext letter while the other ("left") alphabet is used for reading the corresponding ciphertext letter. In other words, the basis of the method is a simple substitution. The novel idea in the Chaocipher algorithm, however, is that the two alphabets are partly reshuffled after each input plaintext letter is enciphered. This leads to nonlinear and highly diffused alphabets as encryption progresses. 

Although Byrne had in mind a physical model with rotating wheels, we will follow Rubin's algorithmic explanation of the method and represent each of the two alphabets as a 26-character string consisting of a permutation of the standard alphabet, for example:

                +            *
    LEFT (ct):  HXUCZVAMDSLKPEFJRIGTWOBNYQ 
    RIGHT (pt): PTLNBQDEOYSFAVZKGJRIHWXUMC 

The place marked with a `+` sign and a `*` sign are called by Byrne the *zenith* and *nadir* points and they correspond to the first and the fourteenth positions in the alphabet. They are important for the alphabet permutation that will be performed after each ciphering and deciphering step.

The right alphabet (bottom) is used for finding the plain text letter, while the left alphabet (top) is used for finding the corresponding cipher text letter. 

To encipher the plaintext letter "A," we simply look for this letter in the right alphabet and take the corresponding letter ("P") in the left alphabet (*ct* and *pt* stand for cipher text and plain text).

Each time a letter has been encrypted (or decrypted), we proceed with permutations of the alphabets.  To permute the left alphabet, we will:

* Shift the whole alphabet cyclically, so that the letter just enciphered ("P") is moved to the zenith (first) position;

                
        
    LEFT (ct):  PEFJRIGTWOBNYQHXUCZVAMDSLK
         
    Remove temporarily the letter in the second position (or zenith + 1), "E" in our example, leaving a "hole" in this position:
     
        LEFT (ct):  P.FJRIGTWOBNYQHXUCZVAMDSLK
        
    Shift one position to the left all letters between the second position and the nadir position, leaving a hole in the nadir position:
    
                    +            *
        LEFT (ct):  PFJRIGTWOBNYQ.HXUCZVAMDSLK
    
* And finally insert the letter that has been removed ("E") in the nadir position:

                
        
        LEFT (ct):  PFJRIGTWOBNYQEHXUCZVAMDSLK

Permuting the right alphabet is a similar process, but with some small but important differences that I will not describe here: please refer to Rubin's document to find the details (or look at Kevin Colyer's `permuteRightWheel` subroutine below).

After the permutation of the right alphabet, the two alphabets look like this:

                +            *
    LEFT (ct):  PFJRIGTWOBNYQEHXUCZVAMDSLK
    RIGHT (pt): VZGJRIHWXUMCPKTLNBQDEOYSFA

With these new alphabets, we are now ready to encrypt the second letter of the plain text. Then we permute again both alphabets and proceed with the third letter of the plain text. And so on.

Deciphering the cipher text is the same process, except of course that we need to locate the first letter of the cipher text in the left alphabet and pick up the corresponding letter in the right alphabet. Alphabet permutations then follow exactly the same rules as when enciphering the plain text.

The strength of the Chaocipher is that the encryption key (the two alphabets) is changed each time a letter of the input text is processed, and the way it is changed depends on the content of the input message. In effect, this is an advanced form of an [autokey cipher](https://en.wikipedia.org/wiki/Autokey_cipher) that is very difficult to break.

## My Solution

For our alphabets, we could use strings of characters, arrays of letters or even possibly hashes. Operations on strings of characters are usually reasonably fast and efficient, so I settled for that. Since both alphabets need to be permuted at the same time, I decided to write only one subroutine (`permute_alphabets`) to permute both alphabets at the same time: at least, there is no risk to permute one and forget to permute the other. I included some tests based on Rubin's paper examples.

We will use multi `MAIN` subroutines to decide on whether to run tests or to process a string passed to the program. We declare an uppercase subset of the string type to provide some limited validation of subroutine arguments. And we fold the case of the program arguments to what is needed.

    use v6;
    subset UcStr of Str where /^<[A..Z]>+$/;
    
    sub permute-alphabets (UcStr $left is copy, UcStr $right is copy, UInt $pos) {
        $left = substr($left, $pos) ~ substr $left, 0, $pos;
        $left = substr($left, 0, 1) ~ substr($left, 2, 12) 
                ~ substr($left, 1, 1) ~ substr $left, 14;
        
        $right = substr($right, $pos+1) ~ substr $right, 0, $pos+1;
        $right = substr($right, 0, 2) ~ substr($right, 3, 11) 
                 ~ substr($right, 2, 1) ~ substr $right, 14;
        return ($left, $right);
    }
    
    sub run_tests {
        use Test; 
        plan 4;
        my $left  = 'HXUCZVAMDSLKPEFJRIGTWOBNYQ';
        my $right = 'PTLNBQDEOYSFAVZKGJRIHWXUMC';
        my $position = index $right, 'A';
        my ($newleft, $newright) = permute-alphabets $left, $right, $position;
        is $newleft, 'PFJRIGTWOBNYQEHXUCZVAMDSLK', "Left alphabet: $newleft";
        is $newright, 'VZGJRIHWXUMCPKTLNBQDEOYSFA', "Right alphabet: $newright";
        my $plaintext = "WELLDONEISBETTERTHANWELLSAID";
        my $ciphertext = encipher($plaintext, $left, $right);
        is $ciphertext, 'OAHQHCNYNXTSZJRRHJBYHQKSOUJY', "Testing enciphering: $ciphertext";
        my $deciphered = decipher($ciphertext, $left, $right);
        is $deciphered, $plaintext, "Roundtrip: $deciphered";
    }
    
    sub encipher (UcStr $plaintext, UcStr $left is copy, UcStr $right is copy) {
        my $ciphertext = "";
        for $plaintext.comb -> $let {
            my $position = index $right, $let;
            $ciphertext ~= substr $left, $position, 1;
            ($left, $right) = permute-alphabets $left, $right, $position;
        }
        return $ciphertext;
    }
    
    sub decipher (UcStr $ciphertext, UcStr $left is copy, UcStr $right is copy) {
        my $plaintext = "";
        for $ciphertext.comb -> $let {
            my $position = index $left, $let;
            $plaintext ~= substr $right, $position, 1;
            ($left, $right) = permute-alphabets $left, $right, $position;
        }
        return $plaintext;
    }
    
    multi MAIN () {
        run_tests;
    } 
    multi MAIN (Str $mode, Str $text, Str $left, Str $right) {  
        if $mode.lc eq 'encipher' {
            say encipher $text.uc, $left.uc, $right.uc;
        } elsif $mode.lc eq 'decipher' {
            say decipher $text.uc, $left.uc, $right.uc;
        } else {
            die "Invalid mode $mode: must be 'encipher' or 'decipher'.\n";
        }
    }

And this is a sample output with various arguments:       

    $ perl6 chaocipher.p6 encipher WELLDONEISBETTERTHANWELLSAID HXUCZVAMDSLKPEFJRIGTWOBNYQ PTLNBQDEOYSFAVZKGJRIHWXUMC
    OAHQHCNYNXTSZJRRHJBYHQKSOUJY
    
    $ perl6 chaocipher.p6  decipher OAHQHCNYNXTSZJRRHJBYHQKSOUJY HXUCZVAMDSLKPEFJRIGTWOBNYQ PTLNBQDEOYSFAVZKGJRIHWXUMC
    WELLDONEISBETTERTHANWELLSAID
    
    $ perl6 chaocipher.p6
    1..4
    ok 1 - Left alphabet: PFJRIGTWOBNYQEHXUCZVAMDSLK
    ok 2 - Right alphabet: VZGJRIHWXUMCPKTLNBQDEOYSFA
    ok 3 - Testing enciphering: OAHQHCNYNXTSZJRRHJBYHQKSOUJY
    ok 4 - Roundtrip: WELLDONEISBETTERTHANWELLSAID

## Alternate Solutions

Only six challengers (well, seven including myself) provided solutions for this task. Even though they are implemented in different ways, they tend to look similar since they all necessarily follow the algorithm provided by Moshe Rubin in his 2010 paper.

[Arne Sommer](https://github.com/manwar/perlweeklychallenge-club/blob/master/challenge-025/arne-sommer/perl6/ch-2.p6) first created custom types for single `A..Z` letters, for words composed of these letters and for complete alphabets. His program uses an array of letters for the two alphabets. This makes it possible to use the awesome `rotate` build-in function in the context of alphabet permutations.

[Kevin Colyer](https://github.com/manwar/perlweeklychallenge-club/blob/master/challenge-025/kevin-colyer/perl6/ch-2.p6) also used arrays for his alphabets. Since I did not detail the permutation of the right alphabet, let me quote Kevin's well commented subroutine to do so: 

``` Perl6
sub permuteRightWheel(@r is copy,$j) {
    # 1. Shift the entire right alphabet cyclically so the plaintext letter just enciphered is positioned at the zenith.
    # 2. Now shift the entire alphabet one more position to the left (i.e., the leftmost letter moves cyclically to the far right), moving a new letter into the zenith position.
    @r=@r.rotate($j+1);

    # 3. Extract the letter at position zenith+2, taking it out of the alphabet, temporarily leaving an unfilled ‘hole’.
    my $extract=@r[zenith+2];
    @r[zenith+2]=" ";

    # 4. Shift all letters beginning with zenith+3 up to, and including, the nadir (zenith+13), moving them one position to the left.

    @r[zenith+2..nadir-1]=@r[zenith+3..nadir];

    # 5. Insert the just-extracted letter into the nadir position (zenith+13).
    @r[nadir]=$extract;

    return @r;
}
```

[Joelle Maslak](https://github.com/manwar/perlweeklychallenge-club/blob/master/challenge-025/joelle-maslak/perl6/ch-2.p6) also used arrays for her alphabets (well, at least to manipulate the letters when enciphering or deciphering text and when permuting the alphabets). She managed to use the same `endecrypt` subroutine to both encrypt and decrypt the input text, with only two code lines depending on whether the program is decrypting or encrypting. This leads to minimal code repetition and a good example of the DRY (don't repeat yourself) principle.

[Ruben Westerberg](https://github.com/manwar/perlweeklychallenge-club/blob/master/challenge-025/ruben-westerberg/perl6/ch-2.p6) also used arrays for the alphabets. Ruben's alphabets include all upper case and lower case letters and a few punctuation signs. His code is very concise:

``` Perl6
sub MAIN (Bool :$decode=False) {	
	$*OUT.out-buffer=0;
	my @alpha=("a".."z","A".."Z"," ", <? ! . : >)[*;*];
	my @alpha1=@alpha;
	my @alpha2=@alpha;
	for $*IN.lines {
		put join "", .comb.map: { chaochiper(@alpha1,@alpha2, $_, :$decode) };
	};
}	

sub chaochiper(@alpha1,@alpha2,  $c, :$decode=False){
	my $p=($decode??@alpha2!!@alpha1).grep($c,:k)[0];
	my $ct=($decode??@alpha1!!@alpha2)[$p];	

	given @alpha1 {
		.=rotate($p+1);
		.splice(.elems div 2, 0, .splice(2,1));
	}
	given @alpha2 {
		.=rotate($p);
		.splice(.elems div 2, 0, .splice(1,1));
	}
	$ct;
}
```

[Yet Ebreo](https://github.com/manwar/perlweeklychallenge-club/blob/master/challenge-025/yet-ebreo/perl6/ch-2.p6) also used "bigger wheels" (larger alphabets with upper case and lower case letters). He also used arrays for the alphabets (so it turns out that I'm the only challenger who used strings throughout the whole process). His `rot` subroutine to perform alphabet substitutions is very compact:

``` Perl6
sub rot ($rcount, @arr, $from?, $to?) {
    if (!(defined $to && defined $from)) {
        @arr = @arr.rotate($rcount);
    } else {
        my $r = ($rcount + $from) % (@arr.end()+1);
        @arr  = (@arr[0..$from-1],@arr[$from..$to].rotate($rcount),@arr[$to+1..@arr.end]).flat;
    }
}
```

[Yaldhar H. Vyas](https://github.com/jaldhar/perlweeklychallenge-club/blob/master/challenge-025/jaldhar-h-vyas/perl6/ch-2.p6) had a very busy week and provided his solution too late for the official Sunday deadline, but he nonetheless provided a complete (both Perl 5 and Perl 6) contribution. His program uses strings for the alphabet when enciphering or deciphering texts (using the `index` built-in function, as I did), but it uses arrays for the alphabet permutations. Jaldhar's program uses two multi MAIN subroutines to take care of enciphering or deciphering cases. Multi subroutines are a very nice and clean feature of Perl 6, but I'm sometimes worried that they can also lead to some code repetition, which goes against the DRY (don't repeat yourself) tenet.

## See Also

Only three blog posts this time:

Arne Sommer: https://perl6.eu/pokemon-chiao.html

Yet Ebreo: http://blogs.perl.org/users/yet_ebreo/2019/09/perl-weekly-challenge-w025---pokemon-nameschaocipher.html

Jaldhar H. Vyas: https://www.braincells.com/perl/2019/09/perl_weekly_challenge_week_25.html

## Wrapping up

Please let me know if I forgot any of the challengers or if you think my explanation of your code misses something important (you can just file an issue against this GitHub page).

If you want to participate to the Perl Weekly Challenge, please connect to [this site](https://perlweeklychallenge.org/).

