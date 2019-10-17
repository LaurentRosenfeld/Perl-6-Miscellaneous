# Brace Expansion

This is derived in part from my [blog post](http://blogs.perl.org/users/laurent_r/2019/10/perl-weekly-challenge-29-file-type-and-digital-clock.html) made in answer to the [Week 28 of the Perl Weekly Challenge](https://perlweeklychallenge.org/blog/perl-weekly-challenge-029/) organized by  <a href="http://blogs.perl.org/users/mohammad_s_anwar/">Mohammad S. Anwar</a> as well as answers made by others to the same challenge.

The challenge reads as follows:

*Write a script to demonstrate brace expansion. For example, script would take command line argument Perl {Daily,Weekly,Monthly,Yearly} Challenge and should expand it and print like below:*

    Perl Daily Challenge
    Perl Weekly Challenge
    Perl Monthly Challenge
    Perl Yearly Challenge

The specification is not very detailed, and we will not attempt to provide a full-fledged templating system, as this already exists. So we will limit our implementation to the following: an initial sentence fragment, followed by a single list of options between curly brackets, followed by a final sentence fragment.

## My Solution

We will supply a command line argument in the form of a string between quote marks, and provide for a default value for the purpose of testing. The program also attempts to normalize spaces in the output, since it is difficult to predict the exact format (number of spaces) supplied by the user.

``` Perl6
use v6;

sub MAIN (Str $input = 'Perl {Daily,Weekly,Monthly,Yearly} Challenge') {
    my $match = $input ~~ /(<-[{]>+) '{' (<-[}]>+) '}' (.+)/;
    my ($start, $options, $end) = map { ~$_ }, $match[0 .. 2];
    s:g/^ \h+ | \h+ $// for $start, $options, $end;
    say "$start $_ $end" for $options.split(/\s*','\s*/);
}
```

Running the program using the default value and with a poorly formatted input string displays the following satisfactory results:

    $ perl6 brace-expansion.p6
    Perl Daily Challenge
    Perl Weekly Challenge
    Perl Monthly Challenge
    Perl Yearly Challenge
    
    $ ./perl6 brace-expansion.p6 "Perl {Daily,  Weekly  ,  Monthly,Yearly   }   Challenge"
    Perl Daily Challenge
    Perl Weekly Challenge
    Perl Monthly Challenge
    Perl Yearly Challenge

## Alternate Solutions

It appears that I was a bit lazy with my bare-bone solution: many challengers contributed solutions that were richer with features, especially the ability to process several groups of braces, using either grammars or recursive subroutines (or both).

[Arne Sommer](https://github.com/manwar/perlweeklychallenge-club/blob/master/challenge-029/arne-sommer/perl6/ch-1.p6) contributed a fairly concise and clever program. Consider his multi `MAIN` subroutine doing the first pattern matching within the signature and the loop to split the pattern within braces in the body of the function, *and* calling itself recursively in the event there are more brace patterns to be processed:

``` Perl6
multi MAIN ($string where $string ~~ /^(.*?) \{ (.*?) \} (.*)/)
{
  MAIN("$0$_$2") for $1.Str.split(",");
}
multi MAIN ($string)
{
  say $string;
}
```
The second multi `Main` subroutine is called only when there are no more brace subpatterns to be processed. Quite impressive and really nice. Congrats, Arne.

[Noud](https://github.com/manwar/perlweeklychallenge-club/blob/master/challenge-029/noud/perl6/ch-1.p6)'s solution is also quite concise:

``` Perl6
sub brace_expansion(Str $s) {
    if ($s ~~ /(.*)\{(.*)\}(.*)/) {
        ["$_[0]$_[1]$2" for brace_expansion(Str($0)) X $1.split(',')];
    } else {
        [$s];
    }
}
```
I'm impressed by Noud's main code line:
``` Perl6
        ["$_[0]$_[1]$2" for brace_expansion(Str($0)) X $1.split(',')];
```
which does quite a lot in a single statement (I like especially the use of the `X` cross product operator in this context). Yes, Perl 6 can be very expressive when used by such talented people as Arne and Noud.


[Daniel Mita](https://github.com/manwar/perlweeklychallenge-club/blob/master/challenge-029/daniel-mita/perl6/ch-1.p6) used quite clever nested `given` statements to process several input phrases:

``` Perl6
sub MAIN (
  *@phrase where * > 0,
  --> Nil
) {
  given @phrase.join: ' ' -> $str {
    given $str.match: /^ ( .*? ) '{' ( .* ) '}' ( .*? ) $/ {
      when .[1].so {
        for .[1].split: ',' -> $split {
          "$_[0]$split$_[2]".say;
        }
      }
      default { $str.say }
    }
  }
}
```

[Kevin Colyer](https://github.com/manwar/perlweeklychallenge-club/blob/master/challenge-029/kevin-colyer/perl6/ch-1.p6) also wrote a program able to handle several brace expansions. This is his `expand` subroutine doing the bulk of the work:

``` Perl6
sub expand(*@texts) {
    my @expanded;
    for @texts -> $t {
        if $t.starts-with: '{' and $t.ends-with: '}' {
             @expanded.push: [ $t.substr(1,*-1).split(',') ];
        } else {
            @expanded.push:  [ $t ];
        }
    }
    # reduce array using cross multiplier
    return [X] @expanded;
}
```

[Mark Senn](https://github.com/manwar/perlweeklychallenge-club/blob/master/challenge-029/mark-senn/perl6/ch-1.p6)'s program is accompanied with interesting and lengthy comments that I would urge you to read from the linked page (and possibly provide some answers to his questions), but will omit these comments from this review. 

``` Perl6
sub MAIN(*@arg);
{
    (@arg.elems)
        or  @arg = 'Perl', '{Daily,Weekly,Monthly,Yearly}', 'Challenge';

    # Convert the @arg array to a @term array.
    my @term = ();
    for @arg  {
        if  /^^ \{ (.*?) \} $$/  {
            push @term, $0.split(',');
        }  else  {
            push @term, $_;
        }
    }
    # I like the following line the best.
    ([X] @term).map({.join(' ').say});
}
```

[Markus Holzer](https://github.com/manwar/perlweeklychallenge-club/blob/master/challenge-029/markus-holzer/perl6/ch-1.p6) wrote a very complete program, including a full-fledged grammar for brace expansion and a detailed test plan. Markus's program is too long to quote here (but I would really advise you to follow the link and look in detail to his solution). Anyway, I arbitrarily decided to quote only his grammar (since we haven't discussed so many grammars in our reviews so far):

``` Perl6
grammar BraceExpansion
{
    regex TOP           { <start-txt> [ <list> | <range> ] <end-txt> }
    regex start-txt     { .* <?before [<list> || <range>]> }
    regex end-txt       { <save-char>*? }
    regex save-char     { <-[ \" \& \( \) \` \' \; \< \> \| \{ \} ]> }
    regex list-element  { <list> | <-[ \" \! \$ \& \( \) \` \' \; \< \> \|]>  }
    regex a-to-z        { <[ a..z A..Z ]> }
    regex num           { \-? <[ 0..9 ]>+ }
    regex range         { <alpha-range> | <num-range> }
    regex num-range     { \{ <num>  \. \. <num> [ \. \. <num> ]? \} }
    regex alpha-range   { \{ <a-to-z> \. \. <a-to-z> [ \. \.<num> ]? \} }
    regex list          { \{ <list-element>+ % ',' \} }
}
```

[Ozzy](https://github.com/manwar/perlweeklychallenge-club/blob/master/challenge-029/ozzy/perl6/ch-1.p6) also wrote a grammar to parse the input string. Ozzy also used quite cleverly the `X~` cross product operator and concatenation operator:

``` Perl6
sub MAIN ( Str $string = 'Perl {Daily,Weekly,Monthly,Yearly} Challenge' ) {

    grammar G {
        token TOP           { ( <h> \{ <alt>+ % ',' \} <t> )+ }
        token h             { <[\w\s]>* }
        token alt           { <[\w\s]>+ }
        token t             { <[\w\s]>* }
    }

    my @m = G.parse($string)[0];
    my @r = "";

    for ^@m.elems -> $i {
        @r = (@r X~ @m[$i]<h> X~ @m[$i]<alt> X~ @m[$i]<t>);
    }
    .say for @r;
} 
```

[Joelle Maslak](https://github.com/manwar/perlweeklychallenge-club/blob/master/challenge-029/joelle-maslak/perl6/ch-1.p6) wrote an awesome program handling both juxtaposed and nested curly braces. Of course, she used a grammar for this, then recursively exploring the parse tree. Joelle's Grammar is as follows:

``` Perl6
grammar Expansion {
    rule TOP      {
        ^
        <element>*
        $
    }
    token element  { <string> | <curly> }
    token string   { <-[ \{ \} ]>+ }
    token curly    { \{ <option>+ % ',' \} }
    token option   { <innerele>* }
    token innerele { <innerstr> | <curly> }
    token innerstr { <-[ \{ \} \, ]>+ }
}
```

But, while the grammar is in a sense the most powerful feature used by Joelle, the real work of her program is done in this subroutine:

``` Perl6
sub expansion(@arr is copy, $tree) {
    if $tree<element>:exists {
        # Handle each element.
        for @($tree<element>) -> $ele {
            @arr = expansion(@arr, $ele);
        }
        return @arr;
    } elsif $tree<innerele>:exists {
        for @($tree<innerele>) -> $ele {
            @arr = expansion(@arr, $ele);
        }
        return @arr;
    } elsif $tree<string>:exists {
        return @arr.map: { $_ ~ $tree<string> };
    } elsif $tree<innerstr>:exists {
        return @arr.map: { $_ ~ $tree<innerstr> };
    } elsif $tree<curly>:exists {
        my @arr-copy = @arr;
        @arr = [];
        for @($tree<curly><option>) -> $ele {
            @arr.append: expansion(@arr-copy, $ele);
        }
        return @arr;
    } else {
        die;
    }
}
```

[Ruben Westerberg](https://github.com/manwar/perlweeklychallenge-club/blob/master/challenge-029/ruben-westerberg/perl6/ch-1.p6) has an `expand` subroutine making most of the work:

``` Perl6
$_= @*ARGS.join(" ");
my $matches=m:g/\{.*?\}/;
my @entries;
@entries.push:	[.Str.split: /<[\{\}\,]>/, :skip-empty] for $matches.list;

expand($_,[],@entries,$matches.list).map(*.say);

sub expand($line,@stack,@entries, @positions) {
        my @results;
        if (@stack == @entries ) {
                my $l=$line;
                my $offset=0;
                for @stack.keys {
                        $l.substr-rw(@positions[$_].from-$offset, @positions[$_].chars)=@stack[$_];
                        $offset+=@positions[$_].chars-@stack[$_].chars;
                }
                return ($l,);
        }
        else {
                my @s;
                my @e=|@entries[@stack.elems];
                for @e  {
                        @s= (|@stack[], |$_);
                        @results.push( |expand($line, @s,@entries, @positions));
                }
                return @results;
        }
}
```

[Ulrich Rieke](https://github.com/manwar/perlweeklychallenge-club/blob/master/challenge-029/ulrich-rieke/perl6/ch-1.p6) provided a fairly concise script:

``` Perl6
#works only if there are no spaces in the expansion bracket!
sub MAIN( **@ARGS ) {
  my $howoften = @ARGS.elems - 2 ;
  for (1..$howoften) -> $i {
      say "@ARGS[0] @ARGS[$i] @ARGS[*-1]" ;
  }
}
```

[Yet Ebreo](https://github.com/manwar/perlweeklychallenge-club/blob/master/challenge-029/yet-ebreo/perl6/ch-1.p6)'s solution is using a recursive `expand` subroutine and is also quite concise once you remove lengthy comments as I did here (but follow the link if you want to read the comments):

``` Perl6
sub expand ($string) {
    my $mstring = $string;
    if ($mstring ~~ /\{(<-[{}]>*)\}/) {
        my ($l,$m,$r) = ($/.prematch,$0,$/.postmatch);
        for ($m.split(",")) {
            expand($l~$_~$r);
        }
    } else {
         say $mstring;
    }
}
```
To me, the code tends to be clearer without these comments, but that may just be me, YMMV.

## See Also

Only two blog posts (besides mine) this time:

Arne Sommer: https://perl6.eu/bracen-c.html;

Yet Ebrao: https://doomtrain14.github.io/pwc/2019/10/13/pwc_brace_expansion.html. Yet's blog post really relates to his Perl 5 implementation of the challenge, but it still does shed some light on his Perl 6 implementation.

## Wrapping up

Please let me know if I forgot any of the challengers or if you think my explanation of your code misses something important (send me an e-mail or just raise an issue against this GitHub page).

