# Leonardo Numbers


This is derived in part from my [blog post](http://blogs.perl.org/users/laurent_r/2020/01/perl-weekly-challenge-41-attractive-numbers-and-leonardo-numbers.html) made in answer to the [Week 41 of the Perl Weekly Challenge](https://perlweeklychallenge.org/blog/perl-weekly-challenge-041/) organized by  <a href="http://blogs.perl.org/users/mohammad_s_anwar/">Mohammad S. Anwar</a> as well as answers made by others to the same challenge.

The challenge reads as follows:

*Write a script to display first 20 Leonardo Numbers. Please checkout [wiki page](https://en.wikipedia.org/wiki/Leonardo_number) for more information.*

*For example:*
    L(0) = 1
    L(1) = 1
    L(2) = L(0) + L(1) + 1 = 3
    L(3) = L(1) + L(2) + 1 = 5

*and so on.*

So, basically, Leonardo numbers are very similar to Fibonacci numbers, except that 1 gets added to the sum each time we go from one step to the next.

## My Solutions

We start with the iterative plain-vanilla approach: 

``` Perl6
use v6

my @leo = 1, 1;
push @leo, @leo[*-1] + @leo[*-2] + 1 for 1..18;
say @leo;
```

which duly prints:

    [1 1 3 5 9 15 25 41 67 109 177 287 465 753 1219 1973 3193 5167 8361 13529]

Or we could use a recursive approach. But Leonardo numbers have the same problem as Fibonacci numbers with a recursive approach when the searched number becomes relatively large (e.g. 40 or 45): computing them becomes extremely slow (this is not really a problem here, since we've been requested to compute the first 20 Leonardo numbers, but let's try to make a program that scales well to higher values). To avoid that problem with large input values, we *memoize* or *cache* manually our recursion, using the `@leo` array (for inputs larger than what is requested by the task):

``` Perl6
use v6;
my @leo = 1, 1;
sub leonardo (Int $in) {
    return @leo[$in] if defined @leo[$in];
    @leo[$in] = [+] 1, leonardo($in - 1), leonardo($in -2);
}
sub MAIN (Int $input = 19) {
    leonardo $input;
    say @leo;
}
```

Note that this program hard-codes the first two Leonardo numbers in the `@leo` cache to provide the base case stopping the recursion.

If we run the program without providing a parameter (i.e. with a default value of 19) we get the same list as before:

    [1 1 3 5 9 15 25 41 67 109 177 287 465 753 1219 1973 3193 5167 8361 13529]

And if we run it with a parameter of 98, we obtain the following output:

    [1 1 3 5 9 15 25 41 67 109 177 287 465 753 1219 1973 3193 5167 8361 13529 21891 35421 57313 92735 150049 242785 392835 635621 1028457 1664079 2692537 4356617 7049155 11405773 18454929 29860703 48315633 78176337 126491971 204668309 331160281 535828591 866988873 1402817465 2269806339 3672623805 5942430145 9615053951 15557484097 25172538049 40730022147 65902560197 106632582345 172535142543 279167724889 451702867433 730870592323 1182573459757 1913444052081 3096017511839 5009461563921 8105479075761 13114940639683 21220419715445 34335360355129 55555780070575 89891140425705 145446920496281 235338060921987 380784981418269 616123042340257 996908023758527 1613031066098785 2609939089857313 4222970155956099 6832909245813413 11055879401769513 17888788647582927 28944668049352441 46833456696935369 75778124746287811 122611581443223181 198389706189510993 321001287632734175 519390993822245169 840392281454979345 1359783275277224515 2200175556732203861 3559958832009428377 5760134388741632239 9320093220751060617 15080227609492692857 24400320830243753475 39480548439736446333 63880869269980199809 103361417709716646143 167242286979696845953 270603704689413492097 437845991669110338051]

The program ran in less than 0.3 second:

    real    0m0,272s
    user    0m0,031s
    sys     0m0,016s

Without memoization, the expected execution time would be several millions years (except, of course, that the program would die long before that because of a number of other reasons, including, but not limited to, memory shortage, CPU breakdown, power outages, planned obsolescence, and quite possibly global warming or thermonuclear Armageddon).

## Alternative Solutions

[Arne Sommer](https://github.com/manwar/perlweeklychallenge-club/blob/master/challenge-041/arne-sommer/perl6/ch-2.p6) built an infinite sequence of Leonardo numbers:

``` Perl6
my $leonardo := (1, 1, { $^a + $^b +1 } ... Inf);
unit sub MAIN ($limit = 20);
say "$_: $leonardo[$_]" for ^$limit;
```

I'm angry against myself that I did not think about using a sequence, probably because I first solved the task in Perl 5 and then lazily translated the P5 code into Raku. Arne's solution is in my opinion obviously better than mines.

[Jo Christian Oterhals](https://github.com/manwar/perlweeklychallenge-club/blob/master/challenge-041/jo-christian-oterhals/perl6/ch-2.p6) made a come-back in the Perl Weekly Challenge after an extended absence. Welcome back, Jo Christian. He also built an infinite sequence of Leonardo number and his program is just one code line:

``` Perl 6
.say for (1, 1, * + * + 1 ... Inf).[^20];
```

[Markus Holzer](https://github.com/manwar/perlweeklychallenge-club/blob/master/challenge-041/markus-holzer/perl6/ch-2.p6) is also coming back to the Perl Weekly Challenge after a pause. Welcome back, Markus. His solution is almost exactly the same as Jo Christian's:

``` Perl 6
.say for (1, 1, * + * + 1 ... *)[^20];
```

[Javier Luque](https://github.com/manwar/perlweeklychallenge-club/blob/master/challenge-041/javier-luque/perl6/ch-2.p6) also used an infinite sequence:

``` Perl6
sub MAIN () {
    my @leonardo = 1, 1, * + * + 1 ... *;
    say "L($_) = " ~ @leonardo[$_]
        for (1 .. 20);
}
```

[Ulrich Rieke](https://github.com/manwar/perlweeklychallenge-club/blob/master/challenge-041/ulrich-rieke/perl6/ch-2.p6) also used an infinite sequence:

``` Perl6
my @leonardos = (1 , 1 , 3 , * + * + 1 ...^ *) ;
.say for @leonardos[^20] ;
```

[Kevin Colyer](https://github.com/manwar/perlweeklychallenge-club/blob/master/challenge-041/kevin-colyer/perl6/ch-2.p6) used multi subroutines to take care of the first two input numbers, and a cached (or memoized) recursive subroutine otherwise:

``` Perl 6
my @cache;
multi sub Leonardo(Int:D $n where * == 0) { 1 }
multi sub Leonardo(Int:D $n where * == 1) { 1 }
multi sub Leonardo(Int:D $n where * > 1 )  {
   return @cache[$n] if @cache[$n];
   return @cache[$n] = Leonardo($n-1)+Leonardo($n-2)+1;
}
say "$_ -> "~Leonardo($_) for ^21;
```

[Noud Aldenhoven](https://github.com/manwar/perlweeklychallenge-club/blob/master/challenge-041/noud/perl6/ch-2.p6) built an infinite sequence of *Fibonacci numbers* and then used a mathematical relation between Fibonacci and Leonardo numbers:

    leonardo(n) = 2 * fib(n + 1) - 1

His code is as follows:

``` Perl6
constant @fib = 0, 1, * + * ... *;

sub leonardo(Int $n) {
    2 * @fib[$n + 1] - 1;
}
say "First 20 Leonardo numbers:";
for ^20 -> $n {
    leonardo($n).say;
}
```

[Simon Proctor](https://github.com/manwar/perlweeklychallenge-club/blob/master/challenge-041/simon-proctor/perl6/ch-2.p6) used a cached recursive subroutine:

``` Perl6
# Combining multi subs and cached went badly
sub L( Int \n --> Int ) is pure is cached {
    return 1 if n == 0|1;
    return L(n-2) + L(n-1) + 1;
}
```

[Colin Crain](https://github.com/manwar/perlweeklychallenge-club/blob/master/challenge-041/colin-crain/perl6/ch-2.p6)'s solution starts with a long comment explaining basically that recursion is not needed and that it is possible to compute the Leonardo numbers from the previously computed numbers. Of course, Colin is absolutely right (and my first "plain vanilla" approach is such an iterative example). The fact that the Fibonacci numbers (whose construction is very similar to the Leonardo numbers) have need abundantly used (and perhaps even sometimes abused) in computer science to illustrate recursion doesn't mean that you have to use recursion, or even that recursion is the best solution. This is Colin's `make_leonardo` iterative subroutine to build a list of Leonardo numbers:

``` Perl6
sub make_leonardo ( Int:D $quan where {$quan > 0} ){
    my @list = [1];                             ## L1 = 1
    @list.push: 1 if $quan > 1 ;                ## L2 = 1
    while ( @list.elems <= $quan-1 ) {
        @list.push: [+] flat @list.tail(2), 1;  ## reduce sum flattened list of last two elems and 1
    }
    return @list;
}
```

[Roger Bell West](https://github.com/manwar/perlweeklychallenge-club/blob/master/challenge-041/roger-bell-west/perl6/ch-2.p6)'s solution confirms Colin Crain's remarks: he suggested just another iterative approach using a stack:

``` Perl6
my @stack;
for (0..19) -> $i {
  if ($i < 2) {
    push @stack,1;
  } else {
    push @stack,1+@stack[@stack.end]+@stack[@stack.end-1];
    shift @stack;
  }
  say @stack[@stack.end];
}
```

[Ruben Westerberg](https://github.com/manwar/perlweeklychallenge-club/blob/master/challenge-041/ruben-westerberg/perl6/ch-2.p6) used a cached recursive approach:

``` Perl6
*put (0..19).map({ "n: $_ l: "~l($_)}).join("\n");

sub l($i) {
	state @cache=(1,1);
	@cache.push(@cache[*-1,*-2].sum+1) while !@cache[$i].defined;
	@cache[$i];
}
```

[Ryan Thompson](https://github.com/manwar/perlweeklychallenge-club/blob/master/challenge-041/ryan-thompson/perl6/ch-2.p6) suggested three solutions; a plain recursive approach, a manually memoized recursive version and an infinite sequence solution:

``` Perl6
use experimental :cached;

# Cached version
sub leo( Int $n ) is cached { $n < 2 ?? 1 !! 1 + leo($n - 1) + leo($n - 2) }

# Manually memoized solution
sub leo_my_memo( Int $n ) {
    state @leo = (1, 1);
    @leo[$n] //= 1 + leo_my_memo($n - 1) + leo_my_memo($n - 2);
}

# Lazily evaluated version
my @leo = 1, 1, 1+*+* ... ∞;

.say for @leo[0..20];
```

## See also

Three blog posts this time:

* Arne Sommer: https://raku-musings.com/numbers.html;

* Javier Luque: https://perlchallenges.wordpress.com/2019/12/30/perl-weekly-challenge-041/;

* Ryan Thompson: http://www.ry.ca/2020/01/leonardo-numbers/.

## Wrapping up

Please let me know if I forgot any of the challengers or if you think my explanation of your code misses something important (send me an e-mail or just raise an issue against this GitHub page).

If you want to participate to the Perl Weekly Challenge, please connect to [this site](https://perlweeklychallenge.org/).





