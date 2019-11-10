# ASCII Bar Chart

This is derived in part from my [blog post](http://blogs.perl.org/users/laurent_r/2019/10/perl-weekly-challenge-30-word-histogram-and-ascii-bar-chart.html) made in answer to the [Week 32 of the Perl Weekly Challenge](https://perlweeklychallenge.org/blog/perl-weekly-challenge-032/) organized by  <a href="http://blogs.perl.org/users/mohammad_s_anwar/">Mohammad S. Anwar</a> as well as answers made by others to the same challenge.

The challenge reads as follows:

*Write a function that takes a hashref where the keys are labels and the values are integer or floating point values. Generate a bar graph of the data and display it to stdout.*

*The input could be something like:*

    $data = { apple => 3, cherry => 2, banana => 1 };
    generate_bar_graph($data);

*And would then generate something like this:*

     apple | ############
    cherry | ########
    banana | ####

*If you fancy then please try this as well: (a) the function could let you specify whether the chart should be ordered by (1) the labels, or (2) the values.*

There is really nothing complicated in generating the bars of the chart: we just need to use the `x` string repetition operator with the fruit values. However, I would like to standardize somehow the size of output, irrespective of the absolute values.  For this, the program loops over the hash a first time to collect the minimum and maximum values, and  computes a scaling factor as `10 / ($max - $min)`, and then uses that `$scale_factor` for standardizing the length of the bars, so that the bar graph has about the same size for values of 4, 6, and 9 as for values of 40, 60 and 90. The hard coded value of 10 arbitrarily chosen here simply means that the spread between the smallest and the largest value will be represented by 10 units (concretely, 10 `#` characters). I could have chosen another value, but I wanted the bar graphs to keep relatively small to make sure they remain correctly formatted within the limited page width of this blog post.

This could lead to the following approach:

``` Perl6
use v6;

sub generate_chart (%data) {
    my ($max, $min);
    for keys %data -> $key {
        ($max, $min) = (%data{$key}, %data{$key}) unless defined $max;
        $max = %data{$key} if %data{$key} > $max;
        $min = %data{$key} if %data{$key} < $min;
    }
    my $scale_factor = 10 / ($max - $min);
    for sort { %data{$^b} <=> %data{$^a} }, keys %data -> $key {
        printf "%15s | %s\n", $key, "#" x (%data{$key} * $scale_factor);
    }
}
my $data = { apple => 3, cherry => 6, banana => 1, pear => 4 };
generate_chart $data;
```

Note that, compared too Perl 5, Raku has no real difference between hashes and hash references in most cases.

This produces the following output:

    $ perl6 ascii_chart.p6
             cherry | ############
               pear | ########
              apple | ######
             banana | ##



#### Ordering the Bar Chart in Accordance with Labels or Values

We will use anonymous code references as the first argument to the `sort` built-in function.

``` Perl6
use v6;

sub generate_chart (%data) {
    my ($max, $min);
    for keys %data -> $key {
        ($max, $min) = (%data{$key}, %data{$key}) unless defined $max;
        $max = %data{$key} if %data{$key} > $max;
        $min = %data{$key} if %data{$key} < $min;
    }
    my $scale_factor = 10 / ($max - $min);
    my &sort_routine = ($*sort-type ~~ m:i/val/) 
        ?? { %data{$^b} <=> %data{$^a} } 
        !! {$^a cmp $^b }; 
    for sort &sort_routine, keys %data -> $key {
        printf "%15s | %s\n", $key, "#" x (%data{$key} * $scale_factor);
    }
}
sub MAIN (Str $*sort-type) {
    my $data = { apple => 3, cherry => 6, banana => 1, pear => 4 };
    generate_chart $data;
}
```

This works as expected:

    $ perl6 ascii_chart2.p6 val
             cherry | ############
               pear | ########
              apple | ######
             banana | ##
    
    $ perl6 ascii_chart2.p6 lab
              apple | ######
             banana | ##
             cherry | ############
               pear | ########

## Alternative Solutions

[Arne Sommer](https://github.com/manwar/perlweeklychallenge-club/blob/master/challenge-032/arne-sommer/perl6/ch-2.p6) wrote a `generate_bar_graph` subroutine doing the sort according to the labels or the values in a `if ... else` conditional statement and storing the result in an array of keys, and then using this array to output the result:

``` Perl6
sub generate_bar_graph ($data, $sort)
{
  my $max = %($data).keys>>.chars.max;
  my @keys = %($data).keys;

  if $sort eq "values"
  {
    @keys = @keys.sort({ %($data){$^b} cmp %($data){$^a} });
  }
  elsif $sort eq "labels"
  {
    @keys = @keys.sort;
  }
  for  @keys -> $label
  {
    say "{ " " x ($max - $label.chars) }$label | { "#" x 4 * %($data){$label} }"; 
  }
}
```

[Noud](https://github.com/manwar/perlweeklychallenge-club/blob/master/challenge-032/noud/perl6/ch-2.p6) similarly wrote a `generate_bar_graph` subroutine which populates a temporary array of sorted keys:

``` Perl6
sub generate_bar_graph(%data, $sort-on="value") {
    my $vmin = %data.values.min - 1;
    my $vmax = %data.values.max;
    constant $width = 79;

    my @count_array;
    if ($sort-on === "value") {
        @count_array = %data.sort(-*.value)>>.kv;
    } elsif ($sort-on === "key") {
        @count_array = %data.sort(*.key)>>.kv;
    } else {
        die "Unknown sorting argument: $sort-on";
    }

    for @count_array -> ($word, $count) {
        my $times = Int(($count - $vmin) / ($vmax - $vmin) * $width);
        say "$word:\t" ~ "#" x $times;
    }
}
```

Note that, like me, Noud is computing a scaling factor to standardize the bar graph width.

[Jaldhar H. Vyas](https://github.com/manwar/perlweeklychallenge-club/blob/master/challenge-032/jaldhar-h-vyas/perl6/ch-2.p6) also wrote a `generate_bar_graph` subroutine that populates an array of sorted keys:

``` Perl6
sub generate_bar_graph(%data, Bool $bylabels = False) {
    constant $SCALE = 4;

    my @labels = %data.keys.sort({ %data{$^b} <=> %data{$^a} });
    my $smallest = %data{@labels[@labels.end]};

    if ($bylabels) {
        @labels = @labels.sort;
    }

    my $width = @labels.sort({$^b.chars <=> $^a.chars}).first.chars;
    my $bar_graph = q{};

    for @labels -> $label {
        my $bar = (%data{$label} / $smallest) * $SCALE;
        if %data{$label} !%% $smallest {
            $bar += $SCALE / 2;
        }
        $bar_graph ~= sprintf("% -*s | %s\n", $width, $label, '#' x $bar);
    }

    return $bar_graph;
}
```

[Kevin Colyer](https://github.com/manwar/perlweeklychallenge-club/blob/master/challenge-032/kevin-colyer/perl6/ch-2.p6) also wrote a `generate_bar_graph` subroutine which similarly populates an array with sorted keys:

``` Perl6
sub generate_bar_graph(%data, Bool :$sortByLabel=False, Bool :$sortDescending=False, Int :$graphWidth=20) {
    my $lableWidth=[max] %data.keys>>.chars;
    my $max=1+[max] %data.values;
    my $min=[min] %data.values;
    my $multiplier=1/$max*$graphWidth;

    die "not sure I want to display negative values" if $min < 0;

    my @sorted = $sortByLabel==True ?? %data.sort(*.key) !! %data.sort(*.value);
    @sorted.=reverse if $sortDescending;

    for @sorted -> (:$key,:$value) {
        say sprintf("%{$lableWidth}s | ", $key ) ~ "#" x $value*$multiplier;
    };
};
```
I especially like the simple way Kevin's program is doing the sort by passing `*.key` or `*.value` to the `sort` built-in function:

``` Perl6
my @sorted = $sortByLabel==True ?? %data.sort(*.key) !! %data.sort(*.value);
```

although comparing `$sortByLabel` to `True` isn't really needed, as the `?? ... !!` operator coerces a Boolean evaluation and this should work the same way:

``` Perl6
my @sorted = $sortByLabel ?? %data.sort(*.key) !! %data.sort(*.value);
```

[Javier Luque](https://github.com/manwar/perlweeklychallenge-club/blob/master/challenge-032/javier-luque/perl6/ch-2.p6) also wrote a `generate_bar_graph` subroutine, which creates a `$sort_func` code object to sort according to values or names, depending on the input parameter:

``` Perl6
sub generate_bar_graph (%data, %params) {
    my $sort_func;

    # Sorting function - just 2 for now
    {
        when (%params.{'order_by'} eq 'size') {
            $sort_func = sub { %data.{$^b} <=> %data.{$^a} };
        }

        when (%params.{'order_by'} eq 'name') {
            $sort_func = sub { fc($^a) cmp fc($^b) };
        }
    }

    # Print the chart
    for %data.keys.sort($sort_func) -> $key {
        "%10s | %s \n".printf($key, '#' x (4 * %data.{$key}));
    }
}
```

[Markus Holzer](https://github.com/manwar/perlweeklychallenge-club/blob/master/challenge-032/markus-holzer/perl6/ch-1-and-2.pl6) used a nice `$format` string and `&sorter` subroutine to achieve the desired result:

``` Perl6
    my $lngst   = max $weights.keys.map( *.chars );
    my $format  = $csv   ?? "%s, %s"           !! 
                  $graph ?? "%{$lngst}s | %s " !!
                  "%-{$lngst}s %s "             ;
 
    my &sorter  = $sort-by-label 
                  ?? { $^a.key   cmp $^b.key   } 
                  !! { $^b.value <=> $^a.value };

    .say for $weights
        .sort( &sorter )
        .map({ .key => $graph ?? "#" x .value !! .value })
        .map({ sprintf $format, .key, .value });
```

[Simon Proctor](https://github.com/manwar/perlweeklychallenge-club/blob/master/challenge-032/simon-proctor/perl6/ch-2.p6) made a fairly long program that I'll quote only in part:

``` Perl6 
sub draw-graph( %data, SortType $sort-type, SortDir $sort-dir ) {
    my $k-width = %data.keys.map(*.codes).max;
    my $max-val = %data.values.max;
    my $screen-width = get-screen-width();

    my &sorter = make-sorter( $sort-type, $sort-dir );
    
    my $available = $screen-width - $k-width - 5;
    .say for %data.sort( &sorter ).map( { sprintf( "% -{$k-width}s  |  %s", $_.key, get-bar( $available, $max-val, $_.value ) ) } );
} 

sub make-sorter( SortType $sort-type, SortDir $sort-dir ) {
    given $sort-dir {
        when asc {
            -> $a, $b { $a.^lookup($sort-type)($a) cmp $b.^lookup($sort-type)($b) }
        }
        when desc {
            -> $a, $b { $b.^lookup($sort-type)($b) cmp $a.^lookup($sort-type)($a) }
        }
    }
}

sub get-bar( Int $available, $max, $value ) {
    '#' x ceiling( $available * ( $value / $max ) );
}

sub get-screen-width() {
    my $result;
    try {
        $result = run("tput","cols",:out).out.slurp.chomp;
    }
    # Fallback incase tput not available
    return $result || 100;
}

sub parse-space-sep( Str $line ) {
    if ( my $match = $line ~~ m!^ (\S+) \s+ (\S+) $! ) {
        return $match[0], $match[1];
    }
    die "Line parser didn't work on $line";
}

sub parse-csv( Str $line ) {
    if ( my $match = $line ~~ m!^ (\"?) (.+) $0 "," (.+) $! ) { #" Editor bug
       return $match[1], $match[2];
    }
    die "Lazy CSV parser didn't work on $line";
}   
```

[Athanasius](https://github.com/manwar/perlweeklychallenge-club/blob/master/challenge-032/athanasius/perl6/ch-2.p6) also wrote a lengthy program from which I'll only quote a small part:

``` Perl6
    my Str @keys = %data.keys;

    if $by-values   # Order by values
    {
        @keys = @keys.sort:
                {
                    %data{$^b} <=> %data{$^a}       # Descending
                    ||                              #    then
                    $^a cmp $^b                     # Lexicographical
                };
    }
    else            # Order by labels
    {
        @keys = @keys.sort;                         # Lexicographical only
    }

    my UInt $width = @keys.map( { .chars } ).max;
    my Str  $graph = '';

    for @keys -> Str $key
    {
        my Str $bar = $BAR-CHARACTER x ($BAR-MULTIPLIER * %data{$key});
        $graph     ~= "  %*s | %s\n".sprintf: $width, $key, $bar;
    }

    return $graph;
```

[Adam Russell](https://github.com/manwar/perlweeklychallenge-club/blob/master/challenge-032/adam-russell/perl6/ch-2.p6) used the interesting [term](https://docs.perl6.org/routine/term:%3C%3E) feature of Raku that I did not know about to populate a constant:

``` Perl6 
sub term:<MAX-LENGTH> { 10 }; 
```

Otherwise, his program sorts the data to find the min/max values in order to scale the bar graph (using the `min` and `max` built-in functions might be more efficient, but it probably doesn't matter very much unless the data is very large):

``` Perl6
sub MAIN($input) {
    my %data = from-json $input; 
    my @sorted = %data.sort(*.value);
    my $min = @sorted[0].value;
    my $max = @sorted[@sorted.end].value;
    for %data.sort(*.value).reverse -> $pair {
        print $pair.key ~ "\t| "; 
        say "#" x ($pair.value - $min + 1) / ($max  - $min) * MAX-LENGTH;
    }  
} 
```

[Joelle Maslak](https://github.com/manwar/perlweeklychallenge-club/blob/master/challenge-032/joelle-maslak/perl6/ch-2.p6) scaled the graph according to the spread between the min  and max values:

``` Perl6
    my $spread    = $max-value - $min-value;            # How far apart are max and min?
    my $max-bar   = $screen-width - $max-len - 4;       # How big the bar can be, we don't use last column
    my $unit-size = $max-bar ?? ($spread / $max-bar) !! 0;  # What a '#' represents

    for @words -> $ele {
        my $hashes = (($ele[1] - $min-value) / $unit-size).Int;
        $hashes = $max-bar if $unit-size == 0;

        say $ele[0].fmt("%-{$max-len}s") ~ " | " ~ "#" x $hashes;
    }
```

[Ruben Westerberg](https://github.com/manwar/perlweeklychallenge-club/blob/master/challenge-032/ruben-westerberg/perl6/ch-2.p6) wrote a `histogram` subroutine that sorts the keys of the hash and then sorts them again if the `$valueSort` parameter is `True`.

``` Perl6
sub histogram(%h,$valueSort,$chart) {
	my @keys=%h.keys.sort;#(*.chars < *.chars);
	my $maxKeyLength=@keys>>.chars.max;
	put "";
	if ($valueSort) {
		@keys=%h.keys.sort(-> $a,$b {%h{$a} < %h{$b}});
	}
	for @keys {
		my $v=%h{$_}.Str;
		$v="#" x %h{$_} if $chart;
		printf("%"~$maxKeyLength~"s| %s\n",$_,$v);
	}
}
```

## See also

Four blog posts this time:

* Arne Sommer: https://raku-musings.com/instance-bar.html;

* Adam Russell: https://adamcrussell.livejournal.com/10802.html;

* Jaldhar H. Vyas: https://www.braincells.com/perl/2019/11/perl_weekly_challenge_week_32.html;

* Javier Luque: https://perlchallenges.wordpress.com/2019/10/31/perl-weekly-challenge-032/;


## Wrapping up

Please let me know if I forgot any of the challengers or if you think my explanation of your code misses something important (send me an e-mail or just raise an issue against this GitHub page).

