# Balanced Parentheses

This is derived in part from my [blog post](http://blogs.perl.org/users/laurent_r/2020/01/perl-weekly-challenge-42-octal-numbers-and-balanced-parentheses.html) made in answer to the [Week 42 of the Perl Weekly Challenge](https://perlweeklychallenge.org/blog/perl-weekly-challenge-042/) organized by  <a href="http://blogs.perl.org/users/mohammad_s_anwar/">Mohammad S. Anwar</a> as well as answers made by others to the same challenge.

The challenge reads as follows:

*Write a script to generate a string with random number of ( and ) brackets. Then make the script validate the string if it has balanced brackets.*

*For example:*

    () - OK
    (()) - OK
    )( - NOT OK
    ())() - NOT OK

Well, I have a slight problem with this task requirement. A script generating a random number of random brackets will almost never generate balanced brackets, except when the maximal number of brackets is really small (say 2 or 4). So, I changed the task to writing a script that checks that strings passed to it have properly balanced parentheses.

## My Solutions

### Balanced Parentheses Using a Grammar

I admit that this may be slight technological overkill, but seeing such a task leads me immediately to use grammars, which are naturally capable to manage such tasks, since their rules can easily be called recursively to parse any number of nested parentheses. So, this is my first solution:

``` Perl6
use v6;

grammar Parens {
    token TOP { \s* <paren-expr>+ \s* }
    token paren-expr { | \s* <paren-pair> \s*
                       | '(' \s* <paren-expr>+ \s* ')' }
    token paren-pair { [ '(' \s* ')' ]+ }
}

for "()", "(  )", "(())", "( ( ))", ")(", "())()", 
    "((( ( ()))))",  "()()()()", "(())(())" -> $expr {
    say "$expr - ", Parens.parse($expr) ?? "OK" !! "NOT OK";
}
```

The `TOP` token is any strictly positive number of `paren-expr`. A `paren-expr` is either a `paren-pair` or an opening parenthesis, followed by, recursively, another `paren-expr`, followed by a closing parenthesis. Note that this could most probably have been made simpler (only two tokens instead of three) if we had decided to remove all spaces of the string before parsing.

This script displays the following output:

    $ perl6 parens.p6
    () - OK
    (  ) - OK
    (()) - OK
    ( ( )) - OK
    )( - NOT OK
    ())() - NOT OK
    ((( ( ())))) - OK
    ()()()() - OK
    (())(()) - OK

### Balanced Parentheses Using a Stack

As I said, using grammars for such a simple task might be considered over-engineering. We had recently a challenge about reverse Polish notation that led us to use a stack. Recursion and stacks are intimately related. We could use a stack to perform the same task: push to the stack if we get a `(`, and pop from the stack if we get a `)`, unless the stack is empty; and, at the end, check that the stack is empty. Some people might think that this approach is conceptually simpler than a grammar. But I tend to think this is wrong. Except for a small typo, my grammar approach worked the first time I tested it. Not only is the stack code below significantly longer, but I had to debug the stack approach below for about 15 minutes before it got right:

``` Perl6
use v6;

sub check-parens (Str $expr) {
    my @stack;
    my $s = $expr;
    $s ~~ s:g/\s+//; # remove spaces;
    for $s.comb {
        when '(' { push @stack, $_; }
        when ')' {
            say "$expr: NOT OK" and return unless @stack;
            pop @stack;
        }
        default { say $s }
    }
    say "$expr: ", @stack.elems ?? "NOT OK" !! "OK";
}
for "()", "(  )", "(())", "( ( ))", ")(", "())()", 
    "((( ( ()))))",  "()()()()", "(())(())" {
        check-parens($_)
}
```

This is the output:

    $ perl6 parens.p6
    (): OK
    (  ): OK
    (()): OK
    ( ( )): OK
    )(: NOT OK
    ())(): NOT OK
    ((( ( ())))): OK
    ()()()(): OK
    (())(()): OK


### Replacing the Stack by a Counter

In fact, we don't really need a stack, as we can use a simple counter starting at 0, which we increment when we get an opening parenthesis, and decrement when we get a closing parenthesis. If we get a closing parenthesis when the counter is 0, or if the counter is not 0 at the end of the parsing, then the parens are not properly balanced. The `check-parens` subroutine is rewritten as follows:

``` Perl6
sub check-parens (Str $expr) {
    my $count;
    my $s = $expr;
    $s ~~ s:g/\s+//; # remove spaces;
    for $s.comb {
        when '(' { $count++ }
        when ')' {
            say "$expr: NOT OK" and return unless $count;
            $count--;
        }
        default { say $s }
    }
    say "$expr: ", $count ?? "NOT OK" !! "OK";
}

The output is the same as before.
```
