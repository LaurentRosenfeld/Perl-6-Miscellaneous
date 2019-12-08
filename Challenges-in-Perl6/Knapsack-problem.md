# The Knapsack Problem

This is derived in part from my [blog post](http://blogs.perl.org/users/laurent_r/2019/05/perl-weekly-challenge-6-compact-number-ranges.html) made in answer to the [Week 6 of the Perl Weekly Challenge](https://perlweeklychallenge.org/blog/perl-weekly-challenge-036/) organized by  <a href="http://blogs.perl.org/users/mohammad_s_anwar/">Mohammad S. Anwar</a> as well as answers made by others to the same challenge.

The challenge reads as follows:

*Write a program to solve Knapsack Problem.*

*There are 5 color coded boxes with varying weights and amounts in GBP. Which boxes should be chosen to maximize the amount of money while still keeping the overall weight under or equal to 15 kg?*
    R: (weight = 1 kg, amount = £1)
    B: (weight = 1 kg, amount = £2)
    G: (weight = 2 kg, amount = £2)
    Y: (weight = 12 kg, amount = £4)
    P: (weight = 4 kg, amount = £10)

*Bonus task, what if you were allowed to pick only 2 boxes or 3 boxes or 4 boxes? Find out which combination of boxes is the most optimal?*

The *knapsack problem* or *rucksack problem* is a well-known problem in combinatorial optimization: given a set of items, each with a weight and a value, determine the number of each item to include in a collection so that the total weight is less than or equal to a given limit and the total value is as large as possible. It derives its name from the problem faced by someone who is constrained by a fixed-size knapsack and must fill it with the most valuable items. In this specific case, this is what is sometimes called the *0-1 knapsack problem*, where you can chose only one of each of the listed items.

I will directly take the "bonus" version of the problem, as it seems simpler to take this constraint in consideration right from the beginning.

The *knapsack problem* is known to be a at least an NP-Complete problem (and the optimization problem is NP-Hard). This means that there is no known polynomial algorithm which can tell, given a solution, whether it is optimal. There are, however, some algorithms that can solve the problem in pseudo-polynomial time, using dynamic programming. 

However, with a set of only five boxes, we can run a so-called brute-force algorithm, that is try all possible solutions to find the best. A better algorithm would probably be needed to manage 30 or more boxes, but we're given only 5 boxes, and trying to find a better algorithm for only five boxes would be, in my humble view, a case of over-engineering.

## My Solutions

To start with, we'll populate a `%boxes` hash of hashes with the box colors as keys, and their respective weights and values:

``` Perl6
constant %boxes = (
    "R" => { "w" => 1,  val => 1  },
    "B" => { "w" => 1,  val => 2  },
    "G" => { "w" => 2,  val => 2  },
    "Y" => { "w" => 12, val => 4  },
    "P" => { "w" => 4,  val => 10 },
);
​```
```

### A Recursive Solution

The most immediate solution to test all boxes combinations would be to use five nested loops, but that's tedious and ugly, and we would need to neutralize some of the loops for satisfying the bonus task with only 2, 3, or 4 boxes. And it doesn't scale: it would break if we were given 6 boxes. I prefer to implement a recursive solution which can work independently of the number of boxes (at least for a start, as this is the idea of the solution I implemented originally for the Perl 5 solution to the challenge, we will see later a simpler solution in Raku).

We want to look at combinations (i.e. subsets of the data where the order in which the boxes are selected doesn't matter) and not permutations (where the order  matters) to avoid doing unnecessary work. To get combinations, we can just retain only permutations that are in a given order, for example in alphabetic order, and filter out the others. One parameter to our recursive subroutine, `$last-box-used`, enables us to compare each `box` in the `for` loop with the previous one and to keep only those where `box` comes after in the alphabetic order. And we make our first call of the `try-one`subroutine with a dummy parameter, "A", which comes before any of the boxes.

I prefer to implement a recursive solution where the parameters to the recursive `try-one` subroutine govern the number of loops that will be performed. These parameters are as follows:
* Current cumulative weight of the selected boxes;
* Current total value of the selected boxes;
* Maximum number of boxes to be selected (for the bonus)
* A string listing the boxes used so far in the current solution;
* Name of the last used box (to get only combinations);
* A list of the boxes still available;

For the first call of `try-one` recursive subroutine, we have the following parameters: 0 for the weight, 0 for the value, the maximum number of boxes to be used is passed as a parameter to the script (or, failing a parameter, defaulted to 5), an empty string for the list of boxes, "A" for the last box used, and the list of box colors.

The recursion base case (where recursion should stop) is reached when the current weight exceed 15 or when the number of available boxes left reaches 0.

``` Perl6
use v6;

constant %boxes = (
    "R" => { "w" => 1,  val => 1  },
    "B" => { "w" => 1,  val => 2  },
    "G" => { "w" => 2,  val => 2  },
    "Y" => { "w" => 12, val => 4  },
    "P" => { "w" => 4,  val => 10 },
);

sub MAIN (UInt $start-nb-boxes = 5) {
    my @boxes = keys %boxes;
    my $*max-val = 0;
    my $*max-boxes = "";
    try-one(0, 0, $start-nb-boxes, "", "A", @boxes);        
    say "Max: $*max-val, Boxes:  $*max-boxes";
    say now - INIT now;
}

sub try-one ($cur-weight, $cur-val, $num-boxes, $boxes-used, $last-box-used, @boxes-left) {
    if $cur-val > $*max-val {
        $*max-val = $cur-val;
        $*max-boxes = $boxes-used;
    }
    for @boxes-left -> $box {
        next if $box lt $last-box-used;
        my $new-cur-weight = $cur-weight + %boxes{$box}{'w'};
        next if $new-cur-weight > 15 or $num-boxes <= 0;
        my @new-boxes-left = grep { $_ ne $box}, @boxes-left;
        my $new-box-used = $boxes-used ?? $boxes-used ~ "-$box" !! $box;
        try-one $new-cur-weight, $cur-val + %boxes{$box}{'val'}, $num-boxes -1, $new-box-used, $box, @new-boxes-left;
    }
}
```

This are some examples of output:

    $ perl6 boxes.p6
    Max: 15, Boxes:  B-G-P-R
    0.0099724
    
    $ perl6 boxes.p6 4
    Max: 15, Boxes:  B-G-P-R
    0.0209454
    
    $ perl6 boxes.p6 3
    Max: 14, Boxes:  B-G-P
    0.01895075
    
    $ perl6 boxes.p6 2
    Max: 12, Boxes:  B-P
    0.0109711

### A Solution Taking Advantage of Raku's Built-in Features

As mentioned earlier, the recursive solution above was inspired by our Perl 5 solution.

But Raku offers the built-in [combinations](https://docs.raku.org/routine/combinations) routine that can make our program shorter and simpler. It will return a list (really a [Seq](https://docs.raku.org/type/Seq)) of all possible combinations of the input list or array. You can even specify the number of items, or, even better, a range for the numbers of items in each combinations; this will enable us to answer the bonus question by specifying the maximal number of boxes, and also to remove from the output the empty list (which may otherwise generate errors or warnings). The `find-best` subroutine does most of the work: the first statement populates a `@valid-candidates` array with combinations not exceeding the maximal weight, along with their total respective values, and the next statement returns the maximal value combination.

    use v6;
    
    constant %boxes = (
        "R" => { "w" => 1,  val => 1  },
        "B" => { "w" => 1,  val => 2  },
        "G" => { "w" => 2,  val => 2  },
        "Y" => { "w" => 12, val => 4  },
        "P" => { "w" => 4,  val => 10 },
    );
    sub MAIN (UInt $max-nb = 5) {
        my ($best, $max) = find-best %boxes.keys.combinations: 1..$max-nb;
        say "Max: $max; ", $best;
    }
    sub find-best (@candidates) {
        my @valid-candidates = gather for @candidates -> $cand {
            take [ $cand, $cand.map({ %boxes{$_}{'val'}}).sum ] 
                if $cand.map({ %boxes{$_}{'w'}}).sum <= 15;
        }
        return  @valid-candidates.max({$_[1]});
    }

The output is the same as before:

    $ perl6 boxes2.p6
    Max: 15; (R G B P)
    
    $ perl6 boxes2.p6 5
    Max: 15; (R P B G)
    
    $ perl6 boxes2.p6 4
    Max: 15; (B G P R)
    
    $ perl6 boxes2.p6 3
    Max: 14; (B G P)
    
    $ perl6 boxes2.p6 2
    Max: 12; (P G)

The actual code is about twice shorter with the `combinations` routine.

## Alternative Solutions

[Arne Sommer](https://github.com/manwar/perlweeklychallenge-club/blob/master/challenge-036/arne-sommer/perl6/ch-2.p6) also used the `combinations` built-in routine, but with a slightly different, more procedural, approach:

``` Perl6
for @boxes.combinations.grep(0 < *.elems <= $boxcount) -> @list
{
  my $key    = @list.join;

  next if %w{$key}.defined;

  my $weight = @list.map({ %weight{$_} }).sum;
  my $value  = @list.map({ %value{$_}  }).sum;

  if $weight <= $maxweight
  {
    %w{$key} = $weight; 
    %v{$key} = $value;
    
    say "{ @list } -> $weight kg -> £ $value" if $verbose;
  }
  elsif $verbose
  {
    say "{ @list } -> $weight kg -> £ $value (> $maxweight kg; ignored)";
  }
}
my $max = %v.values.max;
```

[Daniel Mita](https://github.com/manwar/perlweeklychallenge-club/blob/master/challenge-036/daniel-mita/perl6/ch-2.p6) also used the `combinations` built-in routine and made a very concise program using a data pipeline to solve the problem. Note that I originally tried to use a single data pipeline with `grep`, `map`, `sum` and `max`, but I did not succeed to get it to work properly (it tends to be more difficult that in Perl 5, because type mismatches get in the way), so I decided to change it to a `gather ... take` construct. So, I wish to congratulate Daniel for having succeeded to do it. Anyway, here it is:

``` Perl6
my @boxes = <R B G Y P>.map({ $_ => %( :weight((1..10).roll), :amount((1..100).roll) ) });

.say for |@boxes, '';

.Hash.keys.say for @boxes
  # Generate all possible combinations of boxes
  .combinations(1 .. ∞)
  # Grep the ones with valid weights
  .grep(*.map(*.value<weight>).sum ≤ 15)
  # Sort them by total value
  .sort({ $_($^b) <=> $_($^a) given *.map(*.value<amount>).sum });
```

[Simon Proctor](https://github.com/manwar/perlweeklychallenge-club/blob/master/challenge-036/simon-proctor/perl6/ch-2.p6) created a very simple `box` class:

``` Perl6
class Box {
    has Int $.weight;
    has Int $.worth;

    method gist { "{$!weight}kg worth £{$!worth}" }
}
```

Note the definition of a `gist` method to pretty print `Box` objects: this works because the `say` routine invokes the `gist` method to format its output; therefore, if you redefine `gist` in a class, then `say` will use the redefined `gist` method on any object of that class to obtain the string representation of such objects.

Otherwise, I extend my congratulations to Simon, who also wrote a single data pipeline to do the bulk of the work:

``` Perl6
my @options = @boxes.combinations().grep( *.elems <= $max-boxes ).grep( { ([+] $_.map( *.weight )) <= $max-weight } ).sort( { ( [+] $^b.map( *.worth ) ) cmp ( [+] $^a.map( *.worth ) ) } );
```

[Kevin Colyer](https://github.com/manwar/perlweeklychallenge-club/blob/master/challenge-036/kevin-colyer/perl6/ch-2.p6) also created a very simple `box` class to manage the colors, weights and values:

``` Perl6
class box {
    has Str $.colour;
    has Int $.weight;
    has Int $.amount;
}
```

He then used the `combinations` built-in routine to create all possible box combinations, filtered out combinations with too many boxes or overweight combinations and finally sorted the combinations to retain the largest value:

``` Perl6
sub knapsack(@combinations,@boxes,$max_weight,$max_boxes) {
    my @cands= gather for @combinations -> @c {

        # prune combinations with more than max boxes
        next unless @c.elems <= $max_boxes;

        my $w= @boxes[@c]>>.weight.sum;

        # prune overweight combinations
        next unless $w <= $max_weight;

        # cache for later
        my %wv= comb => @c, w => $w, v => @boxes[@c]>>.amount.sum;
        take %wv;
    }
    # sort in descending order - highest value first.
    @cands.=sort({$^a<v> <= $^b<v>});

    return @cands[0];
}
```

[Ulrich Rieke](https://github.com/manwar/perlweeklychallenge-club/blob/master/challenge-036/ulrich-rieke/perl6/ch-2.p6) also used the `combinations` built-in routine several times:

``` Perl6
my @combis1 = "RBGYP".comb.combinations( 4 ).Array ;
my @combis2 = "RBGYP".comb.combinations( 3 ).Array ;
my @combis3 = "RBGYP".comb.combinations( 2 ).Array ;
for @combis1 -> $sublist {
  @results.push( computeSubsums( $sublist.join )) ;
}
for @combis2 -> $sublist {
  @results.push( computeSubsums( $sublist.join )) ;
}
for @combis3 -> $sublist {
  @results.push( computeSubsums( $sublist.join )) ;
}
my @withinWeight = @results.grep( { $_[1] <= 15 }) ;
my @sorted = @withinWeight.sort( {$^b[2] <=> $^a[2] } ) ;
```

It seems that Ulrich did not know that you can pass a range to the [combinations](https://docs.raku.org/routine/combinations) routine, as shown here under the REPL (some output combinations omitted for brevity):

    > say "RBGYP".comb.combinations: 2..4;
    ((R B) (R G) ... (G Y) (G P) (Y P) (R B G) (R B Y) ... (R G Y P) (B G Y P))

I believe this could have made his code shorter and simpler.

[Javier Luque](https://github.com/manwar/perlweeklychallenge-club/blob/master/challenge-036/javier-luque/perl6/ch-2.p6) did not use the `combinations` built-in routine and, as a result, his `knapsack` subroutine is (like my initial recursive solution) significantly longer and more complex than many other solutions:

``` perl6
sub knapsack (%boxes, Int $max_weight, Num() $max_boxes) {
    my $total_weight = 0;
    my $total_boxes  = 0;
    my $total_amount = 0;
    my $set_of_boxes = '';

    for %boxes.keys.sort(&sort-value-weight) -> $key {
        my $box = %boxes.{$key};

        # While there is space or weight left
        while (1) {
            # Check for space or weight
            last unless
                $total_weight + $box.{'weight'} <=
                $max_weight;

            last unless
                !$max_boxes ||
                ($max_boxes && $total_boxes + 1 <=
                 $max_boxes);

            $total_boxes++;
            $set_of_boxes ~= $key;
            $total_weight += $box.{'weight'};
            $total_amount += $box.{'amount'};
        }
    }

    say 'Max weight: ' ~ $max_weight ~
        ', max boxes: ' ~ $max_boxes ~
        '. Boxes in knapsack: ' ~
        $set_of_boxes ~
        ' ' ~ $total_weight ~ 'kg ' ~
        '£' ~ $total_amount;
}
```

Also, Javier uses a 22-code-line subroutine (not shown here) for the purpose of sorting the boxes by values and then by weight, where as it can be done in just one statement, as shown in this example under the Raku REPL implementing a descending order sort by value and then by weight:

    > my %boxes = (
    *     R => { weight => 1,  amount => 1  },
    *     B => { weight => 1,  amount => 2  },
    *     G => { weight => 2,  amount => 2  },
    *     Y => { weight => 12, amount => 4  },
    *     P => { weight => 4,  amount => 10 },
    * );
    {B => {amount => 2, weight => 1}, G => {amount => 2, weight => 2}, P => {amount => 10, weight => 4}, R => {amount => 1, weight => 1}, Y => {amount => 4, weight => 12}}
    > my @sorted-keys = %boxes.keys.sort({%boxes{$^b}<amount> <=> %boxes{$^a}<amount> || %boxes{$^b}<weight> <=> %boxes{$^a}<weight>});
    [P Y G B R]

And, by the way, I'm not entirely convinced it is really useful to sort the boxes in such a way.

[Roger Bell West](https://github.com/manwar/perlweeklychallenge-club/blob/master/challenge-036/roger-bell-west/perl6/ch-2.p6) also did not use the `combinations` built-in routine and his solution is also quite long. This is the part of his code doing the bulk of the work:

``` Perl6
for (1..2**(@k.elems)-1) -> $map {
  my $b=0;
  my $v=0;
  my $w=0;
  for (0..@k.end) -> $ci {
    if ($map +& @v[$ci]) {
      $v += %box{@k[$ci]}{'v'};
      $w += %box{@k[$ci]}{'w'};
      $b++;
    }
    if ($b>$maxb || $w>$maxw) {
      $v=-1;
      last;
    }
  }
  if ($v>0) {
    if ($v>$bestv || ($v==$bestv && $w>$maxw)) {
      $bestv=$v;
      $bestw=$w;
      $bestid=$map;
    }
  }
}

for (0..@k.end) -> $ci {
  if ($bestid +& @v[$ci]) {
    print @k[$ci],"\n";
  }
}
```

[Ruben Westerberg](https://github.com/manwar/perlweeklychallenge-club/blob/master/challenge-036/ruben-westerberg/perl6/ch-2.p6) also did not use the `combinations` routine, but he nonetheless succeeded to keep his code relatively small. I can see several interesting ideas in his code. First, he uses hash slices to populate his data structure:

``` Perl6
my %boxes;
%boxes{<R B G Y P>}=({c=>1,w=>1,},{c=>2, w=>1},{c=>2,w=>2},{c=>4,w=>12},{c=>10,w=>4});
```

Then, his program sorts the data by the value/weight ratio:

``` Perl6
.value<r>=.value<c>/.value<w> for %boxes;
my @b= %boxes.keys.sort( ->$a,$b { %boxes{$b}<r> <=> %boxes{$a}<r>});
```

It's a clever idea in terms of possible optimization, but, again, I'm not entirely sure that sorting the data in this way is really useful here if you want to test all possible combinations (it's a bit late on Sunday evening, and I don't have time to really test because I want to submit this review in time for Mohammad to be able to announce it tonight ot tomorrow morning).  

Otherwise, his loop to find the best knapsack is quite concise:

``` Perl6
while (@b) {
	state $rem=$limit;
	my $tmp=$rem - %boxes{@b[0]}<w>;
	if $tmp < 0 {
		@b.shift;
		next;
	}
	@selected.push: @b[0];
	$rem=$tmp;
}
```


## See Also

Three blog posts (besides mine) this time:

Arne Sommer: https://raku-musings.com/vin-knapsack.html;

Kevin Colyer wrote his first blog on the Perl Weekly Challenge: https://raku-musings.com/vin-knapsack.html; 

Javier Luque: https://perlchallenges.wordpress.com/2019/11/25/perl-weekly-challenge-036/.

## Wrapping up

Please let me know if I forgot any of the challengers or if you think my explanation of your code misses something important (send me an e-mail or just raise an issue against this GitHub page).

If you want to participate to the Perl Weekly Challenge, please connect to [this site](https://perlweeklychallenge.org/).


