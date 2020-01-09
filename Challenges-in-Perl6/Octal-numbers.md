# Octal Numbers

This is derived in part from my [blog post](http://blogs.perl.org/users/laurent_r/2020/01/perl-weekly-challenge-42-octal-numbers-and-balanced-parentheses.html) made in answer to the [Week 42 of the Perl Weekly Challenge](https://perlweeklychallenge.org/blog/perl-weekly-challenge-042/) organized by  <a href="http://blogs.perl.org/users/mohammad_s_anwar/">Mohammad S. Anwar</a> as well as answers made by others to the same challenge.

The challenge reads as follows:

*Write a script to print decimal number 0 to 50 in Octal Number System.*

*For example:*

    Decimal 0 = Octal 0
    Decimal 1 = Octal 1
    Decimal 2 = Octal 2
    [ ... ]

### My solution

Raku has a [base](https://docs.raku.org/routine/base) method to convert a number into a string representation in any base between 2 and 36.

With this, it is so easy that we can use a one-liner:

    $ perl6 -e 'say "Decimal: $_ \t=  Octal ", .base(8) for 0..50;'
    Decimal: 0      =  Octal 0
    Decimal: 1      =  Octal 1
    Decimal: 2      =  Octal 2
    Decimal: 3      =  Octal 3
    Decimal: 4      =  Octal 4
    Decimal: 5      =  Octal 5
    Decimal: 6      =  Octal 6
    Decimal: 7      =  Octal 7
    Decimal: 8      =  Octal 10
    Decimal: 9      =  Octal 11
    [ ... Lines omitted for brevity ... ]
    Decimal: 45     =  Octal 55
    Decimal: 46     =  Octal 56
    Decimal: 47     =  Octal 57
    Decimal: 48     =  Octal 60
    Decimal: 49     =  Octal 61
    Decimal: 50     =  Octal 62