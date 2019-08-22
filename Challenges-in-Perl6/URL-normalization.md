# URL Normalization

This is derived from my [blog post](http://blogs.perl.org/users/laurent_r/2019/08/perl-weekly-challenge-21-eulers-number-and-url-normalizing.html) made in answer to the [Week 21 of the Perl Weekly Challenge](https://perlweeklychallenge.org/blog/perl-weekly-challenge-021/) organized by  <a href="http://blogs.perl.org/users/mohammad_s_anwar/">Mohammad S. Anwar</a> as well as answers made by others to the same challenge.

The challenge reads as follows:

*Write a script for URL normalization based on [rfc3986](https://en.wikipedia.org/wiki/URL_normalization). This task was shared by Anonymous Contributor.*

*According to Wikipedia, URL normalization is the process by which URLs are modified and standardized in a consistent manner. The goal of the normalization process is to transform a URL into a normalized URL so it is possible to determine if two syntactically different URLs may be equivalent.*

## My Solution

URL normalization does not appear to be a well normalized process. Some of the changes may be useful for some purposes and unwanted in others. In the scripts suggested below, I have limited the changes to [normalizations that preserve semantics](https://en.wikipedia.org/wiki/URL_normalization#Normalizations_that_preserve_semantics) plus removing dot-segments among the [normalizations that usually preserve semantics](https://en.wikipedia.org/wiki/URL_normalization#Normalizations_that_usually_preserve_semantics). Other normalization rules are often unwanted (depending on the specific circumstances) or poorly defined.

To summarize, we will perform the following normalization actions:

* Converting to lower case,
* Capitalizing letters in escape sequences,
* Decoding percent-encoded octets of unreserved characters,
* Removing the default port,
* Removing dot-segments.

We will simply apply a series of successive regex substitutions to the URL, one (or in one case two) for each of the normalization actions.

In the `normalize` subroutine of the program below, we topicalize the URL (with the `given` keyword), so that we can use directly the regex substitution operator on the topical `$_` variable. This simplifies the substitutions. We can write simply:

    s:g/'/./'/\//;

instead of having to write, for each of the substitutions, something like:

    $url ~~ s:g/'/./'/\//;

Each of the substitutions in the program below is commented to explain to which normalization action it refers to.


    use v6;
    use Test;

    sub normalize (Str $url is copy) {
        constant $unreserved = (0x41..0x5A, 0x61..0x7A, 0x2D, 0x2E, 0x5F, 0x7E).Set;
        given $url {
            s:g/(\w+)/{lc $0}/;      # Lowercase letters
            s:g/('%'\w\w)/{uc $0}/;  # Capitalizing letters in escape sequences
            s:g/'%'(<xdigit>**2)     # Decoding percent-encoded octets
               <?{ (+"0x$0") (elem) $unreserved }>    # code assertion
               /{:16(~$0).chr}/;
            s/':' 80 '/'/\//;        # Removing default port
            s:g/'/../'/\//;          # Removing two-dots segments
            s:g/'/./'/\//;           # Removing dot segments
        }
        return $url;
    }

    plan 5;
    for < 1 HTTP://www.Example.com/              
            http://www.example.com/
          2 http://www.example.com/a%c2%b1b      
            http://www.example.com/a%C2%B1b
          3 http://www.example.com/%7Eusername/  
            http://www.example.com/~username/
          4 http://www.example.com:80/bar.html   
            http://www.example.com/bar.html
          5 http://www.example.com/../a/../c/./d.html 
            http://www.example.com/a/c/d.html
        > -> $num, $source, $target {
            cmp-ok normalize($source), 'eq', $target, "Test $num";
    }

The five test cases work fine:

    $ perl6  normalize_url.p6
    1..5
    ok 1 - Test 1
    ok 2 - Test 2
    ok 3 - Test 3
    ok 4 - Test 4
    ok 5 - Test 5

The decoding of percent-encoded octets is a bit more complicated than the others and it might help to explain it a bit further. The first line:

        s:g/'%'(<xdigit>**2)     # Decoding percent-encoded octets
        
looks for a literal `%` character followed by two hexadecimal digits. But the match really occurs only if the code assertion immediately thereafter:

           <?{ (+"0x$0") (elem) $unreserved-range }> # code assertion

is successful, that is essentially if the two hexadecimal digits found belong to the `$unreserved` set of unreserved characters populated at the top of the subroutine. As a result, the substitution occurs only for the octets listed in that set.

Here, we have used five test cases, one for each of the normalization actions, because we don't have detailed specifications, but a real test plan would require more test cases based on actual specs.


## Alternative Solutions

It seems that this challenge encountered limited enthusiasm, since only 6 of the challengers (including myself) suggested Perl 6 solutions. Having said that, I should add that reviewing them took me quite some time, since some of the solutions are fairly long.

Some participants wrote full-fledged grammars, while others used a series of regexes. A grammar is most probably better than my poor 6 regexes. I actually thought about writing a grammar, but was a bit too lazy for that (although I already wrote a grammar for URLs in the context of Perl Weekly Challenge 17 and could have partly reused that). I also thought that regexes would be good enough in this case - in a real world situation, I would certainly also write a grammar. Anyway, once the URL is split up in various components (scheme, user info, host, port, etc.), it is obviously safer and more robust to apply the changes to the various parts, rather than applying blindly regexes to the whole URL. 

[Arne Sommer](https://github.com/manwar/perlweeklychallenge-club/blob/master/challenge-021/arne-sommer/perl6/ch-2.p6) wrote a full grammar to parse the various components of a URL. 

[Joelle Maslak](https://github.com/manwar/perlweeklychallenge-club/blob/master/challenge-021/joelle-maslak/perl6/ch-2.p6) also used a grammar, albeit a seemingly simpler one. On the other hand, I feel that she could have used a more concise way of processing the `$encoding` in the `normalize-percent` subroutine which has a number of code repetitions.

[Kevin Colyer](https://github.com/manwar/perlweeklychallenge-club/blob/master/challenge-021/kevin-colyer/perl6/ch-2.p6) also used a full grammar to parse the various components of a URL and even went further, since he also wrote an actions class to perform some of the normalization actions, as well as an 90 line test plan. Altogether, his program has 279 code lines!

[Noud](https://github.com/manwar/perlweeklychallenge-club/blob/master/challenge-021/noud/perl6/ch-2.p6) and [Ruben Westerberg](https://github.com/manwar/perlweeklychallenge-club/blob/master/challenge-021/ruben-westerberg/perl6/ch-2.p6) used a series a regexes similar in spirit to what I did.


## See Also

Only one blog post on this subject and related to Perl 6, but well worth reading:

* Arne Sommer: https://perl6.eu/eulers-url.html


## Wrapping up

Please let me know if I forgot any of the challengers or if you think my explanation of your code misses something important.

If you want to participate to the Perl Weekly Challenge, please connect to [this site](https://perlweeklychallenge.org/).
