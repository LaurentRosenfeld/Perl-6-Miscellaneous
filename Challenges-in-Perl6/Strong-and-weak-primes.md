



# Strong and Weak Prime Numbers

This is derived in part from my [blog post1](http://blogs.perl.org/users/laurent_r/2019/07/perl-weekly-challenge-15-strong-and-weak-primes-and-vigenere-encryption.html) and [blog post2](http://blogs.perl.org/users/laurent_r/2019/07/functional-programming-in-perl-strong-and-weak-primes-perl-weekly-challenge.html) made in answer to the [Week 15 of the Perl Weekly Challenge](https://perlweeklychallenge.org/blog/perl-weekly-challenge-015/) organized by  <a href="http://blogs.perl.org/users/mohammad_s_anwar/">Mohammad S. Anwar</a> as well as answers made by others to the same challenge.

The challenge reads as follows:

*Write a script to generate first 10 strong and weak prime numbers.*

    For example, the nth prime number is represented by p(n).
    
      p(1) = 2
      p(2) = 3
      p(3) = 5
      p(4) = 7
      p(5) = 11
    
      Strong Prime number p(n) when p(n) > [ p(n-1) + p(n+1) ] / 2
      Weak   Prime number p(n) when p(n) < [ p(n-1) + p(n+1) ] / 2

A *strong prime* is a prime number that is greater than the arithmetic mean of the nearest primes above and below (in other words, it's closer to the following than to the preceding prime). A *weak prime* is a prime number that is less than the arithmetic mean of the nearest prime above and below. Obviously, a prime number cannot both strong and weak, but some prime numbers, such as 5 or 53 (we'll see more of them later), are neither strong, nor weak (they're called *balanced* primes): for example, 5 is equal to the arithmetic mean of 3 and 7. Therefore, the fact that a prime is not strong doesn't mean that it is weak.

## My Solutions

### First Steps

We don't know in advance how many prime numbers we'll need to check to find 10 strong and 10 weak primes. This is a typical situation where using Perl 6's infinite lazy lists is very convenient.

In the first code example below, we first build a lazy infinite list of prime numbers, and then use `grep` to filter the strong (and weak) primes, so as to construct lazy infinite lists of strong and weak primes, and we finally print out the first 10 numbers of each such list. This is fairly straight forward:

```  Perl6
use v6;

my @p = grep { .is-prime }, 1..*;   #Lazy infinite list of primes
my @strong = map { @p[$_] }, 
    grep { @p[$_] > (@p[$_ - 1] + @p[$_ + 1]) / 2 }, 1..*;
my @weak = map { @p[$_] }, 
    grep { @p[$_] < (@p[$_ - 1] + @p[$_ + 1]) / 2 }, 1..*;
say "Strong primes: @strong[0..9]";
say "Weak primes: @weak[0..9]";
```

This script displays the following output:

    $ perl6 strong_primes.p6
    Strong primes: 11 17 29 37 41 59 67 71 79 97
    Weak primes: 3 7 13 19 23 31 43 47 61 73

We don't really need to build the intermediate `@strong` and `@weak` lazy infinite lists, but can print out the results directly:


``` Perl6
use v6;

my @p = grep { .is-prime }, 1..*;   # Lazy infinite list of primes
say "Strong primes: ", (map { @p[$_] }, 
	grep { @p[$_] > (@p[$_ - 1] + @p[$_ + 1]) / 2 }, 1..*)[0..9];
say "Weak primes: ", (map { @p[$_] }, 
    grep { @p[$_] < (@p[$_ - 1] + @p[$_ + 1]) / 2 }, 1..*)[0..9];
```

This prints out the same lists as before:

    perl6 strong_primes.p6
    Strong primes: (11 17 29 37 41 59 67 71 79 97)
    Weak primes: (3 7 13 19 23 31 43 47 61 73)

We're now down to three code lines instead of five (except that I have to format each of the two last code lines over two typographical lines to fit cleanly on my editor screen or on this blog post).

### Categorizing or Classifying Primes

One slight problem with the implementation above is that, once we have generated our list of primes, we need to go through it twice with the `map ... grep` chained statements, one for the strong primes and once for the weak primes; and we'd need to visit the prime list a third time for finding balanced primes. Although the script runs very fast, it would be better if we could do the categorizing in one go. Perl 6 has two built-in routines to do that, `categorize` and `classify`. Let's try to use the first one:

``` Perl6
use v6;

my @p = grep { .is-prime }, 1..*;   # Lazy infinite list of primes
sub mapper(UInt $i) {
    @p[$i] > (@p[$i - 1] + @p[$i + 1])/2 ?? 'Strong' !!
    @p[$i] < (@p[$i - 1] + @p[$i + 1])/2 ?? 'Weak'   !!
    'Balanced';
}
my %categories = categorize &mapper, 1..120;
for sort keys %categories -> $key {
    say "$key primes:  ", map {@p[$_]}, %categories{$key}[0..9];
}
```

Running this program produces the following output:

    $ perl6 strong_primes.p6
    Balanced primes:  (5 53 157 173 211 257 263 373 563 593)
    Strong primes:  (11 17 29 37 41 59 67 71 79 97)
    Weak primes:  (3 7 13 19 23 31 43 47 61 73)

Here, we define a `mapper` subroutine to find out whether a given prime is strong, weak or balanced. Then, we pass to `categorize` two arguments: the `mapper`subroutine and a range of subsequent integers (the indexes of the `@p` prime number list) starting with 1 (the first prime cannot be weak or strong or balanced, since it has no predecessor) and store the result in the `%categories` hash, which is in fact a hash of arrays with three keys (one for each type of primes) and values being the index in the `@p` prime array of primes belonging to the corresponding type.

For example, with an input range of `1..30`, the `%categories` hash has the following contents:

    { 
        Balanced => [2 15], 
        Strong => [4 6 9 11 12 16 18 19 21 24 25 27 30], 
        Weak => [1 3 5 7 8 10 13 14 17 20 22 23 26 28 29]
    }

Remember that the numbers in the three lists above are obviously not the primes, but the indexes of the primes in the `@p` array.

Then, the `for` loop extracts 10 numbers from each key of hash (with a full input range of `1..120`).

This `categorize` built-in is very useful and practical for cases where you want to split some input data into different categories, but it isn't well adapted to our case in point, because it does not work with *lazy* lists. And since balanced primes are much less common than strong and weak primes, I was forced to use a relatively large range of `1..120` to make sure that I would get 10 balanced primes. For this specific problem, the `classify` built-in subroutine works essentially as `categorize` and also reports the `Cannot classify a lazy list` error message when trying to use it on a lazy infinite list. The difference between `categorize` and `classify` is that the latter returns a scalar whereas the former can return a list; so, in our example, it might have been slightly better to use `classify` rather than `categorize`, but the difference between the two built-ins is insignificant in our case. 

We will come back to this later.

### Using Functional Programming

I want to use the opportunity of this challenge to illustrate once more some possibilities of functional programming in Perl

In fact, the first solution suggested above is in fact already largely functional in spirit. We're using a data pipeline programming model. The code lines with `map` and `grep` statements should be read from bottom to top (when they are formatted over more than one line)  and from right to left. For example, to understand this code line:

``` Perl6
my @strong = map $p[$_], 
    grep { $p[$_] - $p[$_-1] > $p[$_+1] - $p[$_] } 1..25;
```

one needs to start from the `1..25` range, which is fed to the `grep` statement, whose role is to filter the range values and keep those which satisfy the condition within the `grep` block. This means, in this case, to keep the indexes of values in the `@p` array of prime numbers for which the current prime number is closer to the next prime than to the previous prime. These indexes are then fed to the `map` statement in order to populate the `@strong` array with such primes.

This implementation works fine, but we saw that there is a weakness: we're scanning the `@p` array of prime numbers twice (or even three times if we want to also identify the balanced primes). And the other solution using `categorize`  or `classify` removed that weakness, but was not entirely satisfactory because we could no longer use lazy infinite lists for our input values.

Note that these weaknesses don't matter very much, since we're dealing with small ranges anyway, but that's not really satisfactory to the mind, as we know that these programs wouldn't scale too well for larger ranges. Let's see whether we can improve these programs.

I hate to say that, but an easy solution is to write a non (or less) functional solution using an infinite loop.

For example, this could be something like this:

``` Perl6
use v6;

my @p = grep { .is-prime }, 1..*;   # Lazy infinite list of primes
my (@strong, @weak, @balanced);
for 1..* -> $i {
    if @p[$i] > (@p[$i - 1] + @p[$i + 1])/2 { 
        push @strong, @p[$i];
    } 
    elsif @p[$i] < (@p[$i - 1] + @p[$i + 1])/2 {
        push @weak, @p[$i];
    } else {
        push @balanced, @p[$i];
    }
    last if @balanced.elems >= 10;
}
say "Strong primes: @strong[0..9]";
say "Weak primes: @weak[0..9]";
say "Balanced primes: @balanced[]";
```

This script produces the following output:

    $ perl6 strong_primes.p6
    Strong primes: 11 17 29 37 41 59 67 71 79 97
    Weak primes: 3 7 13 19 23 31 43 47 61 73
    Balanced primes: 5 53 157 173 211 257 263 373 563 593

Note that in the code above, we use the fact that we know from previous tests that balanced primes are much less frequent than either strong or weak primes, so that we can stop the `for` loop when we have 10 balanced primes (if we did not know that, we would have had to test the three arrays) . Also note that this works fine because, in Perl 6, a `for` loop is lazy. There may be some possible minor improvements, for example avoiding multiple dereferencing of the `@p` values, but I'm not really interested here with micro-optimizations.

This new version works fine, but that's really not the way I would like to go: I would like to have a more functional version , not a less functional version. 

Let's come back to the `categorize` and `classify` built-in functions. As already noted, they're perfect for what we want to do, but don't work with infinite lists. 

Let's see if we can write our own version of  `categorize` or `classify` which would have the same calling syntax and be able to handle infinite lists. Our version of this function will be called `distribute`.

``` Perl6
@p = grep { .is-prime }, 1..*;   # Lazy infinite list of primes
    sub mapper(UInt $i) {
        @p[$i] > (@p[$i - 1] + @p[$i + 1])/2 ?? 'Strong' !!
        @p[$i] < (@p[$i - 1] + @p[$i + 1])/2 ?? 'Weak'   !!
        'Balanced';
    }
    sub distribute (&code, @primes) {
        my %distribution;
        for @primes.kv -> $key, $val {
            next if $key == 0;
            push %distribution{&code($key)}, $val;
            last if %distribution{'Balanced'}.elems >= 10;
        }
        return %distribution;
    }
    my %categories = distribute &mapper, @p;
    for sort keys %categories -> $key {
        say "$key primes:  ", %categories{$key}[0..9];
    }
```

Note that, contrary to the previous version, the `%distribution` and `%categories` hashes now contain the primes, not the prime indexes in the prime array.

And we no longer need to estimate the number of input values to get the desired output. 

I am not fully satisfied, though, because our `distribute` subroutine is tailored to our problem at hand and is not generic enough:

- We need to skip (`next if ...`) the first prime of the list , because it is neither strong, nor weak, nor balanced, since it has no predecessor (and we would get an out-of-range index error or something similar if we kept it); we can solve that by tagging the first index (0) as `'Excluded'` in the `mapper` subroutine, and by excluding that new category from the final output.
-  The stopping condition (`last if ...`) is hard-coded in the `distribute` subroutine. Well, we can pass to `distribute` a third argument, another code block (`$stopper`), to stop the iteration.

These two changes  will make our `distribute` subroutine more generic:

``` Perl6
use v6;

my @p = grep { .is-prime }, 1..*;   # Lazy infinite list of primes
sub mapper(UInt $i) {
    $i < 1                               ?? 'Excluded' !!
    @p[$i] > (@p[$i - 1] + @p[$i + 1])/2 ?? 'Strong'   !!
    @p[$i] < (@p[$i - 1] + @p[$i + 1])/2 ?? 'Weak'     !!
    'Balanced';
}
sub distribute (&code, @primes, &stopper) {
    my %distribution;
    for @primes.kv -> $key, $val {
        push %distribution{&code($key)}, $val;
        &stopper(%distribution);
    }
    return %distribution;
}
my $stopper = { last if %^a{'Balanced'}.elems >= 10 };
my %categories = distribute &mapper, @p, $stopper;
for sort keys %categories -> $key {
    next if $key eq 'Excluded';
    say "$key primes:  ", %categories{$key}[0..9];
}
```
The only trick here if that the `$stopper` code block uses a self-declared positional parameter (or placeholder), `%^a`. And we pass the `%distribution` hash as a parameter to `&stopper` when we run it within the `distribute` subroutine. Thus, the calling code doesn't have to know the name of the hash within the `distribute` subroutine, which is now generic. To be frank, I wasn't fully convinced that this would work until I ran it.

The output is what we want:

    $ perl6 strong_primes.p6
    Balanced primes:  (5 53 157 173 211 257 263 373 563 593)
    Strong primes:  (11 17 29 37 41 59 67 71 79 97)
    Weak primes:  (3 7 13 19 23 31 43 47 61 73)

A final comment on all this. I called `distribute` my new version of the `classify` or `categorize` subroutines because I did not want to mess around the semantics of those existing functions. But it works to define the `distribute` subroutine as a `multi sub classify` subroutine:

``` Perl6
use v6;

my @p = grep { .is-prime }, 1..*;   # Lazy infinite list of primes
sub mapper(UInt $i) {
    # same code as just above
}
multi sub classify (&code, @a, &stopper) {
    my %distribution;
    for @a.kv -> $key, $val {
        push %distribution{&code($key)}, $val;
        &stopper(%distribution);
    }
    return %distribution;
}
my $stopper = { last if %^a{'Balanced'}.elems >= 10 };
my %categories = classify &mapper, @p, $stopper;
for sort keys %categories -> $key {
    next if $key eq 'Excluded';
    say "$key primes:  ", %categories{$key}[0..9];
}
```

I no longer get the `Cannot classify a lazy list` error message, this code works fine and it outputs the same result as before. This was just to test that this could be done syntactically and would work, but I wouldn't want to do that in actual production code without first very closely looking at the semantics of the built-in `classify` subroutine: I do not want to create a monster with a different meanings depending on the circumstances.

## Alternative Solutions

[Arne Sommer](https://github.com/manwar/perlweeklychallenge-club/blob/master/challenge-015/arne-sommer/perl6/ch-1.p6) first generated a lazy infinite list of prime numbers. Then, his program iterates over successive integers and, for each such integer, determines whether the prime having that index in the prime array is strong or weak (or neither), and pushes those in the right array. The loop stops when both the `@strong` and `@weak` arrays have at least 10 elements. It then prints 10 elements of each array.

It is worth noting that Arne used a sigil-less variable, `p`, for his array of primes, as well as for his `for` loop iteration variable (`n`), so that his code to compute whether a prime is strong or weak looks almost exactly the same as the math formulas of the challenge specification:

``` Perl6
if p[n] > ( p[n-1] + p[n+1] ) / 2 { # ...
```

That's quite a nice feature, because the code can be understood and possibly even checked (to a certain degree) by domain experts, not just software engineers or CS scientists (even though, or course, we're talking here about rather trivial examples).

[Athanasius](https://github.com/manwar/perlweeklychallenge-club/blob/master/challenge-015/athanasius/perl6/ch-1.p6) used a `next-prime` subroutine that acts essentially as an iterator: each time it is called, it returns a new prime number (keeping track of the last one that was provided). Otherwise, his program maintains a hash of 2 arrays (strong and weak primes). Then, while we don't have enough primes of each category, the program calls `next-prime` to get another prime (`$next`) and stores into one of the categories, if it meets the criteria. The program also maintains a `$previous` prime and a `current` prime to be able to perform the proper comparisons.

[Jaldhar M. Vyas](https://github.com/manwar/perlweeklychallenge-club/blob/master/challenge-015/jaldhar-h-vyas/perl6/ch-1.p6) created first a lazy infinite list of primes, and then use a `grep` to create a lazy infinite list of strong primes and a lazy infinite list of weak primes, and finally printed the first ten items of each of those two last lists. Essentially the same thing as my first solution, except that Jaldhar's program is using chained method invocations (where mine uses chained function calls). Here is the example for the strong primes:

``` Perl6
my @strongPrimes = (1 .. ∞)
   .grep({ @primes[$_] > (@primes[$_ - 1] + @primes[$_ + 1]) / 2 })
   .map({ @primes[$_] });
```

[Joelle Maslak](https://github.com/manwar/perlweeklychallenge-club/blob/master/challenge-015/joelle-maslak/perl6/ch-1.p6) also created a lazy infinite list of primes. Then, she created the lists of strong and weak primes using a `lazy gather/take` block. For example for the strong primes:

``` Perl6
my @strong = lazy gather {
    for 1..∞ -> $i {
        take @primes[$i] if @primes[$i] > @primes[$i-1,$i+1].sum / 2
    };
}
```

[Ruben Westerberg](https://github.com/manwar/perlweeklychallenge-club/blob/master/challenge-015/ruben-westerberg/perl6/ch-1.p6) also created a lazy infinite list of primes. Then, while iterating over successive integers, his program populates a kind of circular buffer (`@ps`) of three primes and does the required computations on this circular buffer. This works, but seems a bit contrived to me: why not making directly the computations on the previous, current and next elements of the `@primes` array, since we have an index that can be used on that array?

## See Also

Only two blog posts on the strong and weak primes, as far as can say:

* Arne Sommer: https://perl6.eu/prime-vigenere.html.
* Jaldhar M. Vyas: https://www.braincells.com/perl/2019/07/perl_weekly_challenge_week_15.html. As of this reading (Aug. 2019), Jaldhar's post has a small Unicode rendering problem in a sentence on ironically the Unicode subject:  "(By the way, I love how you can use unicode symbols as syntax in Perl6. But if your editor can't cope, you can use * instead of âˆž.)" Jaldhar is speaking about the `∞` infinity symbol. The same problem occurs in the relevant code sample of the blog post. This being said, note that the ∞ symbol  is rendered correctly in his code samples on Github, it is only in the blog post that there is a problem. 


## Wrapping up

Please let me know if I forgot any of the challengers or if you think my explanation of your code misses something important.

If you want to participate to the Perl Weekly Challenge, please connect to [this site](https://perlweeklychallenge.org/).




