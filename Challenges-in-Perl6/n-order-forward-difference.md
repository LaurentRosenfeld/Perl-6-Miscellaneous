# *n*th Order Difference Series


This is derived from my [blog post](http://blogs.perl.org/users/laurent_r/2019/08/perl-weekly-challenge-23-difference-series-and-prime-factorization.html) made in answer to the [Week 23 of the Perl Weekly Challenge](https://perlweeklychallenge.org/blog/perl-weekly-challenge-023/) organized by  <a href="http://blogs.perl.org/users/mohammad_s_anwar/">Mohammad S. Anwar</a> as well as answers made by others to the same challenge.

The challenge reads as follows:

*Create a script that prints nth order forward difference series. You should be a able to pass the list of numbers and order number as command line parameters. Let me show you with an example.*

*Suppose we have list (X) of numbers: 5, 9, 2, 8, 1, 6 and we would like to create 1st order forward difference series (Y). So using the formula Y(i) = X(i+1) - X(i), we get the following numbers: (9-5), (2-9), (8-2), (1-8), (6-1). In short, the final series would be: 4, -7, 6, -7, 5. If you noticed, it has one less number than the original series. Similarly you can carry on 2nd order forward difference series like: (-7-4), (6+7), (-7-6), (5+7) => -11, 13, -13, 12.*

## My Solution

I would have liked to be able to use a pointy block syntax with two parameters, but that does not work because the loop will consume two values at each step, as shown under the REPL:

    > for <5 9 2 8 1 6> -> $a, $b {say $b - $a}
    4
    6
    5

So we would need to pre-process the input data in order to get twice all values except those at both ends of the input list.

We'll use the `rotor` built-in function which I have previously presented in the [longest substring](./Longest-substring.md) blog post.

These are two examples using `rotor` under the REPL:

    > <5 9 2 8 1 6>.rotor(1)
    ((5) (9) (2) (8) (1) (6))
    > <5 9 2 8 1 6>.rotor(2)
    ((5 9) (2 8) (1 6))

In these examples, `rotor` groups the elements of the invocant into groups of 1 and 2 elements respectively.

The `rotor` method can take as parameter a key-value pair, whose value (the second item) specifies a gap between the various matches:

    > (1..10).rotor(2 => 1)
    ((1 2) (4 5) (7 8))

As you can see, we obtain pairs of values, with a gap of 1 between the pairs (item 3, 6 and 9 are omitted from the list). Now, the gap can also be negative and, with a gap of -1, we get all successive pairs from the range:

    > <5 9 2 8 1 6>.rotor(2 => -1)
    ((5 9) (9 2) (2 8) (8 1) (1 6))

This is exactly what we need: we can now subtract the first item from the second one in each sublist.

Continuing under the REPL, we can define the `fwd-diff` subroutine and use it as follows:

    > sub fwd-diff (*@in) { map {$_[1] - $_[0]},  (@in).rotor(2 => -1)}
    &fwd-diff
    > say fwd-diff <5 9 2 8 1 6>
    [4 -7 6 -7 5]
    >

OK, enough experimenting with the REPL, we now know how to solve the challenge and can write our program:

``` Perl6
use v6;

sub fwd-diff (*@in) { 
    map {$_[1] - $_[0]},  (@in).rotor(2 => -1)
}
sub MAIN (Int $order, *@values) {
    if @values.elems <= $order {
        die "Can't compute {$order}th series of {@values.elems} values";
    }
    my @result = @values;
    for 1 .. $order {
        @result = fwd-diff @result;
    }
    say "{$order}th forward diff of @values[] is: @result[]";
}
```

Testing with 6 values the forward difference series with orders 1 to 6 displays the following output:

    $ fwd-diff.p6 1 5 9 2 8 1 6
    1th forward diff of 5 9 2 8 1 6 is: 4 -7 6 -7 5
    
    $ fwd-diff.p6 2 5 9 2 8 1 6
    2th forward diff of 5 9 2 8 1 6 is: -11 13 -13 12
    
    $ fwd-diff.p6 3 5 9 2 8 1 6
    3th forward diff of 5 9 2 8 1 6 is: 24 -26 25
    
    $ fwd-diff.p6 4 5 9 2 8 1 6
    4th forward diff of 5 9 2 8 1 6 is: -50 51
    
    $ fwd-diff.p6 5 5 9 2 8 1 6
    5th forward diff of 5 9 2 8 1 6 is: 101
    
    $ fwd-diff.p6 6 5 9 2 8 1 6
    Can't compute 6th series of 6 values
      in sub MAIN at fwd-diff.p6 line 9
      in block <unit> at fwd-diff.p6 line 1

Note that I had been hoping to get rid of the `if @values.elems <= $order` test and related `die` block by using a constraint in the signature of the `MAIN` subroutine, for example something like this:

``` Perl6
sub MAIN (Int $order, *@values where @values.elems > $order) { # ...
```

but that did not appear to work properly when  I tested the code for answering the challenge (and that's also what I said in my [original blog post](http://blogs.perl.org/users/laurent_r/2019/08/perl-weekly-challenge-23-difference-series-and-prime-factorization.html) about a week ago). I guess that I must have made a silly mistake at the time, since trying again with that same syntax when preparing this blog post a week later proved successful:

``` Perl6
use v6;

sub fwd-diff (*@in) { 
    map {$_[1] - $_[0]},  (@in).rotor(2 => -1)
}
sub MAIN (Int $order, *@values where @values.elems > $order) {
    my @result = @values;
    @result = fwd-diff @result for 1 .. $order;
    say "{$order}th forward diff of @values[] is: @result[]";
}    
```

This works as before, for example:

    $ perl6 fwd-diff.p6 4 5 9 2 8 1 6
    4th forward diff of 5 9 2 8 1 6 is: -50 51



## Alternative Solutions

For this challenge, we had in total 13 solutions (more than usual) and they look mostly very different. Really, TIMTOWTDI.

[Kevin Colyer](https://github.com/manwar/perlweeklychallenge-club/blob/master/challenge-023/kevin-colyer/perl6/ch-1.p6) used two nested loops. If the order is stored in `$n`, the outer loop iterates `$n` times over the `@X` array of the previous results (or the input array at the first iteration). The inner loop uses a `gather/take` block to populate `@Y` array of results with the forward differences; after that, the content `@Y` is copied onto `@X` to prepare the next outer iteration. His subroutine computing forward differences is as follows:

``` Pedrl6
sub NthOrderForwardDifference(@X is copy,$n) {
    my @Y;
    return @Y if $n >= @X.elems;
    for ^$n ->$j {
        @Y = gather for ^(@X.elems-1) -> $i {
            take @X[$i+1]-@X[$i];
        }
        @X=@Y;
    }
    return @Y;
}
```

[Mark Senn](https://github.com/manwar/perlweeklychallenge-club/blob/master/challenge-023/mark-senn/perl6/ch-1.p6)  used the hyperoperators with the `-` minus operator, `<<->>`, to combine two versions of the input list, one shifted of one position compared to the other, to obtain the sequence of differences. This fairly clever solution leads to very concise code:
``` Perl6
my$i = 1;
while   @x.elems > 1 &&$i  <=$order   {
    @x = @x [1..*]  <<->> @x [0..^* -1];
    say "order {$i++}: {@x}";
}
```

[Noud](https://github.com/manwar/perlweeklychallenge-club/blob/master/challenge-023/noud/perl6/ch-1.p6) managed to offer an even more concise solution:

``` Perl6
sub grad(@arr, $step=1) {
    (1..(@arr.elems - $step)).map({ @arr[$_ + $step] - @arr[$_] });
}
```
But I don't understand how it works, and actually have some doubts that it really works properly.

[Simon Proctor](https://github.com/manwar/perlweeklychallenge-club/blob/master/challenge-023/simon-proctor/perl6/ch-1.p6) used the built-in `rotor` function, just as I did, and with the same parameters (`2=>-1`). His solution is more compact than mine, though. This is his main loop doing all the real work:

``` Perl6
for ^$n {
    @vals = @vals.rotor(2=>-1).map( { [R-] |$_ } )
}
```
How does it work? You remember that, applied to a list of values such as `<5 9 2 8>`, the `rotor` function with the `2=>-1` parameters produces a list of lists: `((5 9) (9 2) (2 8))`. Then, `R` is the reverse operator, which reverses the arguments of an operator. So, when given the `(5 9)` list, `[R-]` computes 9 - 5, which is what we need for the forward difference series.


[Arne Sommer](https://github.com/manwar/perlweeklychallenge-club/blob/master/challenge-023/arne-sommer/perl6/ch-1.p6) implemented a fairly compact forward difference subroutine using a `gather/take` construct:

``` Perl6
sub forward-difference (@list)
{
  return gather take @list[$_] - @list[$_ -1] for 1 .. @list.end;
}
```
This computes the first order forward difference series. Arne's program then just calls this subroutine the number of times needed for the degree received as a parameter.

[Athanasius](https://github.com/manwar/perlweeklychallenge-club/blob/master/challenge-023/athanasius/perl6/ch-1.p6) used essentially two nested loops. His code for computing the first order forward difference series (the inner loop) is fairly straight forward:

``` Perl6
@new-series.push(@series[$_] - @series[$_ - 1]) for 1 .. $max-index;
```

The outer loop calls the code above the number of times needed for the degree received as a parameter. Athanasius's code is often very thorough. For this challenge, he has quite detailed code for checking the arguments, and even wrote code for providing the proper English suffixes to ordinal numbers: "th", "st", "nd" or "rd," depending on the last digit in the number.

[Jaldhar M. Vyas](https://github.com/manwar/perlweeklychallenge-club/blob/master/challenge-023/jaldhar-h-vyas/perl6/ch-1.p6) used a `for` loop and a `map` to build a very concise and yet very easy to follow solution:

``` Perl6
for 0 ..^ $n {
    @series = (1 ..^ @series.elems).map({ @series[$_] - @series[$_ - 1] });
}
```

[Roger Bell West](https://github.com/manwar/perlweeklychallenge-club/blob/master/challenge-023/roger-bell-west/perl6/ch-1.p6) also used a `for` loop and a `map` to build a very concise and simple solution:

``` Perl6
for (1..$depth) {
  my @o=map {@seq[$_+1]-@seq[$_]}, (0..@seq.end-1);
  @seq=@o;
}
```

[Ruben Westerberg](https://github.com/manwar/perlweeklychallenge-club/blob/master/challenge-023/ruben-westerberg/perl6/ch-1.p6) similarly used a `for` loop and a `map`. His code for building the forward difference series holds in one single statement:

``` Perl6
@values= map( { [-] @values[$_,$_-1]}, @values.keys[1..*-1]) for ^$order ;
```

[Yet Ebreo](https://github.com/manwar/perlweeklychallenge-club/blob/master/challenge-023/yet-ebreo/perl6/ch-1.p6)'s solution also uses a `for` loop and a `map` and his main code also holds in a single line:

``` Perl6
(@list = map {@list[$_]-@list[$_-1]},1..@list.end) for 1..$n;
```

[Joelle Maslak](https://github.com/manwar/perlweeklychallenge-club/blob/master/challenge-023/joelle-maslak/perl6/ch-1.p6) implemented simply two nested loops for a straight-forward  solution:

``` Perl6
my @in = @sequence;
for 1..$nth {
    @sequence = ();
    my $last;
    for @in -> $num {
        @sequence.push: $num - $last if $last.defined;
        $last = $num;
    }
    @in = @sequence;
}
```

[Randy Lauen](https://github.com/manwar/perlweeklychallenge-club/blob/master/challenge-023/randy-lauen/perl6/ch-1.p6) used a for loop (for the orders) and an hyperoperator with the minus sign to build the forward difference series:

``` Perl6
sub MAIN( Int :$order!, *@numbers where *.elems > 0 ) {
    for 1 .. $order -> $i {
        @numbers = @numbers.tail(*-1) >>->> @numbers;
        say "$i: @numbers.join(', ')";
        last if @numbers.elems == 1;
    }
}
```

## See Also

Five blog posts on the forward difference series, quite a good score:

* Mark Senn: https://engineering.purdue.edu/~mark/pwc-023-1.pdf

* Arne Sommer: https://perl6.eu/forward-prime.html

* Jaldhar M. Vyas: https://www.braincells.com/perl/2019/09/perl_weekly_challenge_week_23.html

* Roger Bell West: https://blog.firedrake.org/archive/2019/08/Perl_Weekly_Challenge_23.html

* Yet Ebreo: https://blog.firedrake.org/archive/2019/08/Perl_Weekly_Challenge_23.html


## Wrapping up

Please let me know if I forgot any of the challengers or if you think my explanation of your code misses something important.

If you want to participate to the Perl Weekly Challenge, please connect to [this site](https://perlweeklychallenge.org/).




