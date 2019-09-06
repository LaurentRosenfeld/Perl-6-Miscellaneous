#  Euclid's Numbers

This is derived from my [blog post](http://blogs.perl.org/users/laurent_r/2019/06/perl-weekly-challenge-12-euclids-numbers-and-directories.html) made in answer to the [Week 12 of the Perl Weekly Challenge](https://perlweeklychallenge.org/blog/perl-weekly-challenge-012/) organized by  <a href="http://blogs.perl.org/users/mohammad_s_anwar/">Mohammad S. Anwar</a> as well as answers made by others to the same challenge.

The challenge reads as follows:

_The numbers formed by adding one to the products of the smallest primes are called the Euclid Numbers (see [wiki](https://en.wikipedia.org/wiki/Euclid_number)). Write a script that finds the smallest Euclid Number that is not prime._

For example, the first two prime numbers are 2 and 3. Their product is 6; The second Euclid number is 6 + 1 = 7. Similarly, the third Euclid number is (2 × 3 × 5) + 1 = 31.

A little bit of terminology, to help us expressing things in a simpler fashion, before we start. The product of the *n* first prime numbers is called the *n*th *primorial*. In other words, the *n*th Euclid number is equal to the *n*th primorial + 1. A number that is not prime is composed of at least two factors, and is said to be *composite*. 

## My Solutions

For solving this task, we can use two infinite (lazy) lists: one for the primes and one for Euclid's numbers, and then pick up the first Euclid's number that is not prime:

``` Perl6
use v6;

my @primes = grep {.is-prime}, 1..*;
my @euclids = map {1 + [*] @primes[0..$_]}, 0..*;
say @euclids.first(not *.is-prime);
```

which prints 30031 (which is not prime as it is the product 59 × 509). 30031 is the sixth Euclid  number and is equal to ( 2 ×  3 ×  5 × 7 × 11 × 13) + 1.

It could be argued that this method is somewhat inefficient because are doing the same multiplications again and again, where we could keep the running product of the first *n* primes. For example, we could use a loop in which we compute the next primorial by multiplying the previous primorial by the next prime number, thus making only one multiplication at each step. Yes, it would probably be more efficient, but the computation with the program above is so fast that I will not bother trying to optimize the performance. See Feng Chang's and Jaldhar M. Vyas's solutions below for some implementations using this method. Joelle Maslak's solution is also keeping the running product of primes, not in a loop, but with a `map`. 

Coming back to the program above, note that we don't really need to populate an intermediate temporary array with Euclid's numbers and can find directly the first such number that is not prime:

    use v6;
    
    my @primes = grep {.is-prime}, 1..*;
    say (map {1 + [*] @primes[0..$_]}, 0..*).first(not *.is-prime);

But it probably wouldn't make much sense to also try to get rid of the `@primes` array, because we are in fact using it many times in the process of computing Euclid's numbers, so it is probably better to cache the primes.

When there is a backslash before the operator within a reduction metaoperator, Perl 6 generates all the intermediate results. This is an example under the REPL:

    > say [+] 1..4;
    10
    > say [\+] 1..4; # prints 1,  1 + 2,  1 + 2 + 3,  1 + 2 + 3 + 4
    (1 3 6 10)

We could use this feature to generate directly a lazy infinite list of primorials:

``` Perl6
my @primorials = [\*] grep { .is-prime}, 1..*;
```
Printing the first 10 items of this infinite list of primorials displays this:

    (2 6 30 210 2310 30030 510510 9699690 223092870 6469693230)

We only need to add 1 to each item of this list to get the first 10 Euclid numbers.

``` Perl6
say map { $_ + 1 }, @primorials;
```

With all this in mind, we can now find the first Euclid number that is not prime in just one code line:

``` Perl6
say ([\*] grep {.is-prime}, 1..*).map({$_ + 1}).first(not *.is-prime);
```
which duly prints 30031. 

At this point, we can even solve the challenge with just a simple Perl 6 one-liner:

    $ perl6 -e 'say ([\*] grep {.is-prime}, 1..*).map({$_ + 1}).first(not *.is-prime);'
    30031

## Alternative Solutions

[Aaron Sherman](https://github.com/manwar/perlweeklychallenge-club/blob/master/challenge-012/aaron-sherman/perl6/ch-1.p6) created subroutines that return lazy lists of primes and of Euclid numbers:
``` Perl6
sub primes() { (2,3,*+2...*).grep: *.is-prime }
sub euclids() {
    gather for primes() -> $p {
        take ((state $t=1) *= $p) + 1;
    }
}
```
His program then finally prints the first composite (non prime) Euclid number using the `first` method in the same way I did in my first solution.

[Arne Sommer](https://github.com/manwar/perlweeklychallenge-club/blob/master/challenge-012/arne-sommer/perl6/euclid-nonprime) defined an infinite lists of primes and then iterates over them with a `for` loop to compute the corresponding Euclid number; when his program has found a composite Euclid number, it prints it and exit the loop.

``` Perl6
my $primes := (1 .. *).grep(*.is-prime);
for 1 .. *
{
  my $sum =  1 + [*] $primes[^$_];

  unless $sum.is-prime
  {
    say "Smallest non-prime Euclid Number: $sum";
    last;
  }
}

```

[Athanasius](https://github.com/manwar/perlweeklychallenge-club/blob/master/challenge-012/athanasius/perl6/ch-1.p6) used the `factor` and `pn_primorial` functions of the Perl 5 `Math::Prime::Util` module. This is a great feature of Perl 6: you can use most of the Perl 5 modules and thus take advantage of Perl 5 vast ecosystem.  His program implements an infinite `for` loop to generate successive Euclid numbers (with the `pn_primorial` function) and breaks out of the loop when a non prime Euclid number has been found.

[Feng Chang](https://github.com/manwar/perlweeklychallenge-club/blob/master/challenge-012/feng-chang/perl6/ch-1.p6) implemented a `for` loop computing each primorial from the previous one:

``` Perl6
my $euc = (^∞).grep: *.is-prime;
my $prod = 1;
for 0 .. ∞ -> Int $i {
    $prod *= $euc[$i];
    last unless ($prod + 1).is-prime;
    LAST { say $prod + 1 }
}
```
Note the use of a `LAST` phaser to print the result right before exiting the loop. This is a bit cleaner and clearer than what I sometimes tend to do in such cases: `say $prod + 1 and last unless ...`, to avoid creating a new conditional block.

[Jaldhar M. Vyas](https://github.com/manwar/perlweeklychallenge-club/blob/master/challenge-012/jaldhar-h-vyas/perl6/ch-1.p6) apparently did not know at the time of the challenge that Perl 6 has a built-in (very fast) `is-prime` function, as he implemented his own `isPrime` subroutine. Or perhaps he simply wanted to solve that himself as part of the challenge. Otherwise, he also implemented `for` loop computing each primorial from the previous one:

``` Perl6
my $primorial = 1;
for 1 .. * -> $n {
    if isPrime($n) {
        $primorial *= $n;
        my  $euclidNumber = $primorial + 1;
        if !isPrime($euclidNumber) {
            say $euclidNumber;
            return;
        }
    }
}
```

[Joelle Maslak](https://github.com/manwar/perlweeklychallenge-club/blob/master/challenge-012/joelle-maslak/perl6/ch-1.p6) also implemented a solution computing a primorial from the previous one, but not in a `for` loop as the two previous challengers: her program cleverly uses a `map` to compute directly an infinite list of Euclid numbers:

``` Perl6
my $product = 1;
my $euclids = (2..∞).grep(*.is-prime).map( { ($product *= $_).succ } );
say $euclids.first(! *.is-prime);
```

[Francis J. Whittle](https://github.com/manwar/perlweeklychallenge-club/blob/master/challenge-012/fjwhittle/perl6/ch-1.p6) first created a lazy infinite list `P` of primes. Then, his program generates an infinite list of non-prime Euclid numbers, and finally prints the first one, all this in a single chained method invocation statement:

``` Perl6
(^Inf).map(-> $i { ([*] P[0..$i]) + 1})\
      .grep(!*.is-prime)[0]\ # filtering by the first non-prime,
      .put; # and output.
```

[Kevin Colyer](https://github.com/manwar/perlweeklychallenge-club/blob/master/challenge-012/kevin-colyer/perl6/ch-1.p6) first also created a lazy infinite list of primes. His program then implements an infinite `for` loop to compute each successive Euler number. When a non prime Euler number is found, the program prints it and break out of the loop.

``` Perl6
for ^∞ -> $n {
    my $i = ( [*] @primes[0..$n] ) + 1;
    if ! $i.is-prime {
        say "12.1) (first $n primes + 1) -> $i is not prime";
        last;
    }
};
```

[Mark Senn](https://github.com/manwar/perlweeklychallenge-club/blob/master/challenge-012/mark-senn/perl6/ch-1.p6) generated an array of primes between 2 and 1,000. His program then uses a `for` loop (over the indexes of the array) to generate each Euclid number in turn and exit the loop when a composite Euclid number is found.

``` Perl6
for (^@prime.elems) -> $i
{
    my $e = ([*] @prime[0..$i]) + 1;
    ($e.is-prime)  or  $e.say,  last;
}
```

Mark notes in a comment that the program could be optimized by keeping a running product of the first *n* primes, and adds: "But, 'Premature optimization is the root of all evil' -- Donald Erwin Knuth." I agree.

[Ozzy](https://github.com/manwar/perlweeklychallenge-club/blob/master/challenge-012/ozzy/perl6/ch-1.p6) first constructed an infinite array of primes in a quite unusual way, using `gather/take` in an infinite loop:

``` Perl6
my @primes = lazy gather {           # Define a lazy array with prime numbers
    my $a=0;
    loop { take $a if (++$a).is-prime };
}
```

His program then iterates over indexes of this array, computes each Euclid number and stops on the first non prime one:

``` Perl6
for 1..100 -> $i {
    my $Euclid = ([*] @primes[0..($i-1)]) +1;           # Calculate the $i-th Euclid number.
    say "E_$i = $Euclid";                               # For inspection: show the numbers...

    if ! $Euclid.is-prime {                             # Print number and exit if it is not-prime.
        say "$Euclid is not prime!";
        exit;
    }
}
```

[Ruben Westerberg](https://github.com/manwar/perlweeklychallenge-club/blob/master/challenge-012/ruben-westerberg/perl6/ch-1.p6) built successively three infinite lists: one of prime numbers, one of primorials (using the same `[\*]` operator as I did in my last solution), and  one of Euclid numbers. His program finally loops over the infinite array of Euclid numbers, exits the loop when the current number is not prime, and prints its value out with a `LAST` phaser.

``` Perl6
my @p=(0..*).grep: *.is-prime;
my @pp=[\*] @p;
my @e=@pp.map: *+1;
for @e {
	last unless .is-prime;
	LAST .say;
}
```
Again a nice use of the `LAST` phaser to do something after a `last` statement to break out of a loop. I'm definitely going to do that more often. Having said that, I have a minor quibble with Ruben coding style: I wish that he would use more meaningful variable names and include spaces around operators: IMHO, that would make his code more readable. For example:

``` Perl6
my @primes = (0..*).grep: *.is-prime;
my @primorials = [\*] @primes;
my @euclid-numbers = @primorials.map: *+1;
for @euclid-numbers {
	last unless .is-prime;
	LAST .say;
}
```

[Simon Proctor](https://github.com/manwar/perlweeklychallenge-club/blob/master/challenge-012/simon-proctor/perl6/ch-1.p6) also built successively three infinite lists, but not exactly the same as Ruben: a list of primes, a list of Euclid numbers, and a list of composite Euclid numbers. The program can then simply display the first item of this last list.

``` Perl6
my @primes = (1...*).grep(*.is-prime);
my @euclid = (0...*).map( -> $i { ( [*] @primes[0..$i] ) + 1 } );
my @non-prime-euclid = @euclid.grep( ! *.is-prime );
say @non-prime-euclid[0];
```

## See Also

Three blog posts on Euclid's numbers:

* Arne Sommer: https://perl6.eu/euclid-path.html.

* Joelle Maslak: https://digitalbarbedwire.com/2019/06/16/perl-weekly-challenge-12-euclid-numbers/.

* Mark Senn: https://engineering.purdue.edu/~mark/pwc-012.pdf.


## Wrapping up

Please let me know if I forgot any of the challengers or if you think my explanation of your code misses something important.

If you want to participate to the Perl Weekly Challenge, please connect to [this site](https://perlweeklychallenge.org/).

