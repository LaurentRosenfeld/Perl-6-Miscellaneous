# Formatted Multiplication Table

This is derived in part from my [blog post](http://blogs.perl.org/users/laurent_r/2019/11/perl-weekly-challenge-33-count-letters-and-multiplication-tables.html) made in answer to the [Week 33 of the Perl Weekly Challenge](https://perlweeklychallenge.org/blog/perl-weekly-challenge-033/) organized by  <a href="http://blogs.perl.org/users/mohammad_s_anwar/">Mohammad S. Anwar</a> as well as answers made by others to the same challenge.

The challenge reads as follows:

*Write a script to print 11x11 multiplication table, only the top half triangle.*

    x|   1   2   3   4   5   6   7   8   9  10  11
    ---+--------------------------------------------
    1|   1   2   3   4   5   6   7   8   9  10  11
    2|       4   6   8  10  12  14  16  18  20  22
    3|           9  12  15  18  21  24  27  30  33
    4|              16  20  24  28  32  36  40  44
    5|                  25  30  35  40  45  50  55
    6|                      36  42  48  54  60  66
    7|                          49  56  63  70  77
    8|                              64  72  80  88
    9|                                  81  90  99
    10|                                     100 110
    11|                                         121

## My Solution

## Formatted Multiplication Table in Raku (Perl 6)

To obtain the desired format and easily right-align the numbers, the simplest is to use the `printf` built-in function when needed:

    use v6;
    sub MAIN (UInt $max = 11) {
        print-table($max);
    }
    sub print-table ($max) {
        # Print header
        printf "%2s |", "x";
        printf "%4d", $_ for 1..$max;
        say "\n---|", "-" x 4 * ($max);
        # Print table lines
        for 1..$max -> $i {
            printf "%2d |%s", $i, ' ' x 4 * ($i - 1);
            for $i..$max -> $j {
                printf "%4d", $i * $j;
            }
            say "";
        }
    }

This script prints out the following:

    $ perl6 mult-table.p6
     x |   1   2   3   4   5   6   7   8   9  10  11
    ---|--------------------------------------------
     1 |   1   2   3   4   5   6   7   8   9  10  11
     2 |       4   6   8  10  12  14  16  18  20  22
     3 |           9  12  15  18  21  24  27  30  33
     4 |              16  20  24  28  32  36  40  44
     5 |                  25  30  35  40  45  50  55
     6 |                      36  42  48  54  60  66
     7 |                          49  56  63  70  77
     8 |                              64  72  80  88
     9 |                                  81  90  99
    10 |                                     100 110
    11 |                                         121

This is not exactly the output shown in the task description, but this is deliberate, as I think this looks slightly better.

Just in case you want to know, this works equally well when passing a parameter other than 11:

    $ perl6 mult-table.p6 20
     x |   1   2   3   4   5   6   7   8   9  10  11  12  13  14  15  16  17  18  19  20
    ---|--------------------------------------------------------------------------------
     1 |   1   2   3   4   5   6   7   8   9  10  11  12  13  14  15  16  17  18  19  20
     2 |       4   6   8  10  12  14  16  18  20  22  24  26  28  30  32  34  36  38  40
     3 |           9  12  15  18  21  24  27  30  33  36  39  42  45  48  51  54  57  60
     4 |              16  20  24  28  32  36  40  44  48  52  56  60  64  68  72  76  80
     5 |                  25  30  35  40  45  50  55  60  65  70  75  80  85  90  95 100
     6 |                      36  42  48  54  60  66  72  78  84  90  96 102 108 114 120
     7 |                          49  56  63  70  77  84  91  98 105 112 119 126 133 140
     8 |                              64  72  80  88  96 104 112 120 128 136 144 152 160
     9 |                                  81  90  99 108 117 126 135 144 153 162 171 180
    10 |                                     100 110 120 130 140 150 160 170 180 190 200
    11 |                                         121 132 143 154 165 176 187 198 209 220
    12 |                                             144 156 168 180 192 204 216 228 240
    13 |                                                 169 182 195 208 221 234 247 260
    14 |                                                     196 210 224 238 252 266 280
    15 |                                                         225 240 255 270 285 300
    16 |                                                             256 272 288 304 320
    17 |                                                                 289 306 323 340
    18 |                                                                     324 342 360
    19 |                                                                         361 380
    20 |                                                                             400

Of course, the nice formatting starts to break when passing a parameter higher than 31 (because some results start to exceed 1,000 and to have more than 3 digits), but the initial requirement was just an `11*11` multiplication table. It would not be difficult to change the script to make it work with larger values (we could even dynamically adapt the formatting strings to the maximal output number), but nobody needs commonly a larger multiplication table.

## Alternative Solutions

Again quite a high number of solutions (17) this time.

[Arne Sommer](https://github.com/manwar/perlweeklychallenge-club/blob/master/challenge-033/arne-sommer/perl6/ch-2.p6) chose the simple strategy of hard coding the header, and then used two nested `for`loops for computing the products. He used the built-in [fmt](https://docs.perl6.org/routine/fmt#class_Cool) formatting function, which, for numbers, essentially works in the same way as the `sprintf` function (or `printf`, except that `fmt` does not print the result but only returns the formatted string, so you have to add the print statement): 

``` Perl6
say "  x|   1   2   3   4   5   6   7   8   9  10  11";
say "---+--------------------------------------------";

for 1 .. 11 -> $row
{
  print $row.fmt('%3d') ~ "|";
  print "    " x $row - 1;

  for $row .. 11 -> $col
  {
    print ($row * $col).fmt('%4d');
  }
  print "\n";
}
```

[Mark Senn](https://github.com/manwar/perlweeklychallenge-club/blob/master/challenge-033/mark-senn/perl6/ch-2.p6) also hard-coded the printing of the header. He used two `for` loops for computing the results and the `printf` function for formatting the products:

``` Perl6
print q:to/END/;
  x|   1   2   3   4   5   6   7   8   9  10  11
---+--------------------------------------------
END

# Print rest of table.
my $n = 11;
for (1..$n) -> $row
{
    "%3d|".printf($row);
    for (1..$n) -> $col
    {
        ($col < $row)
        ??  "    ".print
        !!  "%4d".printf($row*$col);
    }
    ''.say;
}
```

[Daniel Mita](https://github.com/manwar/perlweeklychallenge-club/blob/master/challenge-033/daniel-mita/perl6/ch-2.p6) also used two `for` loops for computing the results and used the built-in [sprintf](https://docs.perl6.org/routine/sprintf) function to format the output:

``` Perl6
sub MAIN (
  Int $max where * > 0 = 11, #= The max number of the multiplication table (defaults to 11)
  --> Nil
) {
  my @range   = 1 .. $max;
  my $spacing = @range[*-1]².chars + 1;

  print ' x|';
  print sprintf('%' ~ $spacing ~ 's', $_) for @range;
  print "\n";
  print '--+';
  say [x] «
    -
    $spacing
    @range.elems()
  »;

  for @range -> $a {
    print sprintf('%2s|', $a);
    for @range -> $b {
      print sprintf('%' ~ $spacing ~ 's', $a ≤ $b ?? $a * $b !! '');
    }
    print "\n";
  }
}
```

[Kevin Colyer](https://github.com/manwar/perlweeklychallenge-club/blob/master/challenge-033/kevin-colyer/perl6/ch-2.p6) also used two `for` loops for computing the results and the `sprintf` function to format the results:

```
sub MAIN($table=11) {

    # header
    print "  x|";
    print frmt($_) for 1..$table;
    print "\n";
    print "---+";
    say   "----" x $table;

    # body
    for 1..$table -> $i {
        print frmt($i,3) ~ "|";
        print "    "      for 1..$i-1;
        print frmt($i*$_) for $i..$table;
        print "\n";
    }
}

sub frmt($i, $pad=4, --> Str) {
    return sprintf("%{$pad}s",$i);
}
```

[Markus Holzer](https://github.com/manwar/perlweeklychallenge-club/blob/master/challenge-033/markus-holzer/perl6/ch-2.p6) created two subroutines, `header` and `line`, to manage the various types of output. His program uses a single `for` loop to run the `line` subroutine *n* times, each time with a different multiplier, and the `line` subroutine uses the range operator to create *n* multiplicands and store the products in an array. Quite a nice and imaginative solution in my view:

``` Perl6
sub MAIN( Int $n = 11 )
{
    my $ln = ( $n * $n ).chars + 1;
    my $li = $n.chars + 1;

    header;
    line $_ for ( 1 .. $n );

    sub line( $i )
    {
        my @n = ( ( $i .. $n ) X* $i ).map({ sprintf( "%{$ln}s", $_ ) });
        my @e = ( ' ' xx ( $ln * ( $i - 1 ) ) );
        say sprintf( "%{$li}s", $i ), '|', @e.join,  @n.join;
    }

    sub header
    {
        my @h = ( 1 .. $n ).map({ sprintf( "%{$ln}s", $_ ) });
        say sprintf( "%{$li}s", "x" ), '|', @h.join;
        say ( '-' xx $li ).join, "+", ( '-' xx ( $n * $ln ) ).join;
    }
}
```

[Noud](https://github.com/manwar/perlweeklychallenge-club/blob/master/challenge-033/noud/perl6/ch-2.p6) contributed a program that, contrary to my solution, can print out the multiplication tables for any upper value, since it first dynamically calculates the needed gap between numbers.

``` perl6
sub print_mult_table($size) {
    # Determine the gap between the numbers.
    my $gap = ceiling(log10($size * $size)) + 1;

    print " " x $gap - 1;
    print "x|";
    for 1..$size -> $i {
        print($i.fmt('%' ~ $gap ~ 'd'));
    }
    print "\n";

    print "-" x $gap ~ "+" ~ "-" x $size * $gap ~ "\n";

    for 1..$size -> $i {
        print $i.fmt('%' ~ $gap ~ 'd') ~ "|" ~ " " x ($i - 1) * $gap;
        for $i..$size -> $j {
            print ($i * $j).fmt('%' ~ $gap ~ 'd');
        }
        print "\n";
    }
}
```

As an example, this is the output for multiplication tables up to 33 (which wouldn't work proprely with my solution):

        x|    1    2    3    4    5    6    7    8    9   10   11   12   13   14   15   16   17   18   19   20   21   22   23   24   25   26   27   28   29   30   31   32   33
    -----+---------------------------------------------------------------------------------------------------------------------------------------------------------------------
        1|    1    2    3    4    5    6    7    8    9   10   11   12   13   14   15   16   17   18   19   20   21   22   23   24   25   26   27   28   29   30   31   32   33
        2|         4    6    8   10   12   14   16   18   20   22   24   26   28   30   32   34   36   38   40   42   44   46   48   50   52   54   56   58   60   62   64   66
        3|              9   12   15   18   21   24   27   30   33   36   39   42   45   48   51   54   57   60   63   66   69   72   75   78   81   84   87   90   93   96   99
        4|                  16   20   24   28   32   36   40   44   48   52   56   60   64   68   72   76   80   84   88   92   96  100  104  108  112  116  120  124  128  132
        5|                       25   30   35   40   45   50   55   60   65   70   75   80   85   90   95  100  105  110  115  120  125  130  135  140  145  150  155  160  165
        6|                            36   42   48   54   60   66   72   78   84   90   96  102  108  114  120  126  132  138  144  150  156  162  168  174  180  186  192  198
        7|                                 49   56   63   70   77   84   91   98  105  112  119  126  133  140  147  154  161  168  175  182  189  196  203  210  217  224  231
        8|                                      64   72   80   88   96  104  112  120  128  136  144  152  160  168  176  184  192  200  208  216  224  232  240  248  256  264
        9|                                           81   90   99  108  117  126  135  144  153  162  171  180  189  198  207  216  225  234  243  252  261  270  279  288  297
       10|                                               100  110  120  130  140  150  160  170  180  190  200  210  220  230  240  250  260  270  280  290  300  310  320  330
       11|                                                    121  132  143  154  165  176  187  198  209  220  231  242  253  264  275  286  297  308  319  330  341  352  363
       12|                                                         144  156  168  180  192  204  216  228  240  252  264  276  288  300  312  324  336  348  360  372  384  396
       13|                                                              169  182  195  208  221  234  247  260  273  286  299  312  325  338  351  364  377  390  403  416  429
       14|                                                                   196  210  224  238  252  266  280  294  308  322  336  350  364  378  392  406  420  434  448  462
       15|                                                                        225  240  255  270  285  300  315  330  345  360  375  390  405  420  435  450  465  480  495
       16|                                                                             256  272  288  304  320  336  352  368  384  400  416  432  448  464  480  496  512  528
       17|                                                                                  289  306  323  340  357  374  391  408  425  442  459  476  493  510  527  544  561
       18|                                                                                       324  342  360  378  396  414  432  450  468  486  504  522  540  558  576  594
       19|                                                                                            361  380  399  418  437  456  475  494  513  532  551  570  589  608  627
       20|                                                                                                 400  420  440  460  480  500  520  540  560  580  600  620  640  660
       21|                                                                                                      441  462  483  504  525  546  567  588  609  630  651  672  693
       22|                                                                                                           484  506  528  550  572  594  616  638  660  682  704  726
       23|                                                                                                                529  552  575  598  621  644  667  690  713  736  759
       24|                                                                                                                     576  600  624  648  672  696  720  744  768  792
       25|                                                                                                                          625  650  675  700  725  750  775  800  825
       26|                                                                                                                               676  702  728  754  780  806  832  858
       27|                                                                                                                                    729  756  783  810  837  864  891
       28|                                                                                                                                         784  812  840  868  896  924
       29|                                                                                                                                              841  870  899  928  957
       30|                                                                                                                                                   900  930  960  990
       31|                                                                                                                                                        961  992 1023
       32|                                                                                                                                                            1024 1056
       33|                                                                                                                                                                 1089

In theory, you could use any larger upper range values, but you'll be quickly limited by your screen width.

[Ryan Thompson](https://github.com/manwar/perlweeklychallenge-club/blob/master/challenge-033/ryan-thompson/perl6/ch-2.p6) contributed a quite creative solution that can also handle large multipliers, since its `$fmt` formating string is dynamically adapted to the size of the largest product. His program uses the `fmt`function for format the output.

``` Perl6
use v6;

sub MAIN(Int $max = 11) {
    my $w     = ($max*$max).chars;  # Maximum width in table
    my $fmt   = "%{$w}s";           # Evenly sized columns
    my @n     = 1..$max;            # Trivial to change this to, say, primes

    ('',       ' | ', @n                                    ).fmt($fmt).say;
    ('-' x $w, '-+-', '-' x $w xx $max                      ).fmt($fmt).say;
    
    for @n -> $n {
        ($n,   ' | ', @n.map: { $n > $^m ?? '' !! $n * $^m }).fmt($fmt).say;
    }
}
```

With an input value of 33, Ryan's program displays almost the same as the output of Noud's program just above.

[Richard Nuttall](https://github.com/manwar/perlweeklychallenge-club/blob/master/challenge-033/rnuttall/perl6/ch-2.p6) made a fairly concise solution using a `for` loop and a range, and a single format string for everything:

``` Perl6
sub MAIN($lim = 11) {
    my         $fmt = "%3s%1s" ~ "%4s" x $lim ~ "\n";
    printf     $fmt,  'x', '|',        1..$lim;
    printf     $fmt, '---','+', '----' xx $lim;
    for 1..$lim -> $x {
        printf $fmt,  $x,  '|', ' ' xx $x-1, ($x..$lim) «*» $x;
    }
}
```

[Simon Proctor](https://github.com/manwar/perlweeklychallenge-club/blob/master/challenge-033/simon-proctor/perl6/ch-2.p6) made, as often, a quite verbose solution with several multi `MAIN` subroutines, as well as a `format-row`, a `get-header`, and a `get-row` subroutines. This is part of his solution:

``` Perl6
multi sub MAIN(
    UInt $max = 11 #= Max number to print the table to
) {
    my &formater = format-row( $max );
    .say for get-header( $max, &formater );
    .say for (1..$max).map( { get-row( $max, &formater, $_) } );
}

sub format-row( UInt $max ) {
    my $max-width = ($max*$max).codes;
    my $row = " %{$max.codes}s |{" %{$max-width}s" x $max}";
    return sub ( *@data ) {
        sprintf $row, @data;
    }
}

sub get-header( UInt $max, &formater ) {
    my $max-width = ($max*$max).codes;
    ( &formater( "x", |(1..$max) ), "-" x ( 3 + $max.codes + ( $max * ($max-width+1) ) ) );
}
```

[Adam Russel](https://github.com/manwar/perlweeklychallenge-club/blob/master/challenge-033/adam-russell/perl6/ch-2.p6) also hard-coded the header and otherwise used the [form](https://github.com/perl6/form) module to emulate the Perl 5 `format` fix-width output templating features for the header. For the result lines, his program uses a quite creative solution: it iterates over the `1..11` range and, for each value, creates an array `@a` of zeros followed by integers from the values to 11. For example, for `$x` value equal to 5, it would generate this array: `[0 0 0 0 5 6 7 8 9 10 11]`. The program then uses two chained `map` statements that multiply the non-zero integers by the value being used and the zeros by an empty string, so that the result `@b` array for value 5 is this: `["", "", "", "", 25, 30, 35, 40, 45, 50, 55]`. Finally, the program uses `sprintf` to properly format this array.

``` Perl6
sub print_table11 {
    my ($x,$x1,$x2,$x3,$x4,$x5,$x6,$x7,$x8,$x9,$x10,$x11);
    my $header = form
        '    x|   1   2   3   4   5   6   7   8   9   10   11',
        '  ---+----------------------------------------------';
    print $header;
    for 1 .. 11 -> $x {
        my @a;
        @a = (0) xx ($x -1) if $x > 1;
        @a.append($x .. 11);
        my @b = map({$_ ==  0 ?? "" !! $_}, map({ $x * $_ }, @a));
        print sprintf '%5s|', $x;
        my $s = sprintf '%4s%4s%4s%4s%4s%4s%4s%4s%4s%5s%5s', @b;
        say $s;
    }
}
```

[Jaldhar H. Vyas](https://github.com/manwar/perlweeklychallenge-club/blob/master/challenge-033/jaldhar-h-vyas/perl6/ch-2.p6) also contributed a quite creative solution. His program uses the `X` cross operator, chained with a `grep` and a `map`, to generate an array `@table` of all the products to be displayed in the multiplication table. It finally iterates over the multiplier range, picks up the desired array slice with the `splice` built-in function, format the results with `fmt` function and finally outputs them with the `printf` function:

``` Perl6
constant $N = 11;

say '  x|', (1 .. $N).fmt('% 4s', q{}), "\n", '---+', ('----' x $N);
my @table = (1 .. $N X 1 .. $N).grep({ $_[1] >= $_[0]}).map({ $_[0] * $_[1] });
for (1 .. $N) {
    printf "% 3s|%s%s\n",
        $_,
        q{ } x 4 * ($_ - 1), 
        @table.splice(0, $N - $_ + 1).fmt('% 4s', q{});
};
```

[Athanasius](https://github.com/manwar/perlweeklychallenge-club/blob/master/challenge-033/athanasius/perl6/ch-2.p6) used two straight forward `for` loops for computing the values and `printf` for formatting the output: 

``` Perl6
# Print the multipliers
'  x|'.print;
' %3d'.printf: $_ for 1 .. $MAX;
    ''.say;

# Print the horizontal divider
"---+%s\n".printf: '-' x (4 * $MAX);

# Print the body of the multiplication table
for 1 .. $MAX -> UInt $row
{
    # Print one row: the multiplicand, followed by those products for which
    #                the multiplier does not exceed the multiplicand

    '%3d|'.printf: $row;
   ' %3s' .printf: $row > $_ ?? '' !! $row * $_ for 1 .. $MAX;
        ''.say;
}
```

[Javier Luque](https://github.com/manwar/perlweeklychallenge-club/blob/master/challenge-033/javier-luque/perl6/ch-2.p6) created a `generate-x-table` subroutine looping over the multipliers range and two multi `table-content` subroutines, one to produce the header and the other to generate and format the results, using the `sprintf` function:

``` Perl6
# Generates the multiplication table
sub generate-x-table (Int $num) {
    table-content($_, $num).say for (0..$num);
}

# Returns the table head string
multi table-content(Int $current where { $current == 0}, Int $num) {
    my $line = "%4s|".sprintf("x");
    $line ~= "%4i".sprintf($_) for (1..$num);
    return $line ~ "\n" ~ '----+' ~ '----' x $num;
}

# Returns the table row string for $i
multi table-content(Int $current, Int $num) {
    my $line = "%4i|".sprintf($current);

    for (1..$num) -> $i {
        $line ~= ($current <= $i) ??
            "%4i".sprintf($i * $current) !! ' ' x 4;
    }

    return $line;
}
```

[Joelle Maslak](https://github.com/manwar/perlweeklychallenge-club/blob/master/challenge-033/joelle-maslak/perl6/ch-2.p6) used two nested `for` loops to generate the results and the `fmt` built-in function to format them:

``` Perl6
sub MAIN(UInt:D $max = 11) {
    die "Max must be ≥ 1" if $max < 1;

    my $maxlen  = (~ $max).chars;
    my $prodlen = (~ $max²).chars;

    # Header line
    print "x".fmt("%{$maxlen+1}s") ~ "|";
    say (1..$max)».fmt("%{$prodlen+1}d").join;

    # Seperator line
    say '-' x ($maxlen+1) ~ '+' ~ '-' x $max*($prodlen+1);

    for 1..$max -> $i {
        # New row
        print $i.fmt("%{$maxlen+1}d") ~ '|';

        for 1..$max -> $j {
            if ($i ≤ $j) {
                print ($i*$j).fmt("%{$prodlen+1}d");
            } else {
                print " " x ($prodlen+1);
            }
        }

        print "\n";
    }
}
```

[Ruben Westerberg](https://github.com/manwar/perlweeklychallenge-club/blob/master/challenge-033/ruben-westerberg/perl6/ch-2.p6) also used two nested `for` loops to compute the values, and he used `sprintf` to format the output:

``` Perl6
my $limit=@*ARGS[0]//11;
my $maxWidth=1+(chars $limit**2);
printRow "", (1..$limit), $maxWidth;
put "-" x (($limit+2)*$maxWidth);
for 1..$limit {
	my $i=$_;
	my @row;
	my $header=$_;
	for 1..$limit {
		if $_ >= $i {
			push @row, $i*$_;
		}
		else {
			push @row, "";
		}
	}
	printRow($header,@row,$maxWidth);
}

sub printRow($header, $data, $minWidth) {
	my $output="";
	for @$data {
		$output ~= sprintf "%"~$minWidth~"s",$_;
	}
	printf "%"~$minWidth~"s|%s\n",$header,$output;
}
```

[Roger Bell West](https://github.com/manwar/perlweeklychallenge-club/blob/master/challenge-033/roger-bell-west/perl6/ch-2.p6) also used two nested `for` loops and used the `printf` function to format and output the results:

``` Perl6
my $n=11;
my $m1=$n.chars+1;
my $m2=($n*$n).chars+1;
my $fmt='%' ~ $m1 ~ 's%1s' ~ (('%' ~ $m2 ~ 's') xx $n) ~ "\n";
printf($fmt,'x','|',(1..$n));
printf($fmt,'-' x $m1,'+',('-' x $m2) xx $n);
for 1 .. $n -> $row {
  my @a=($row,'|');
  for 1 .. $n -> $column {
    if ($column < $row) {
      push @a,'';
    } else {
      push @a,$row*$column;
    }
  }
  printf($fmt,@a);
}
```

[Ulrich Rieke](https://github.com/manwar/perlweeklychallenge-club/blob/master/challenge-033/ulrich-rieke/perl6/ch-2.p6) also used two nested `for` loops and used the `sprintf` function to format the output:

``` Perl6
sprintf("%4s" , "x|" ).print ;
for (1..11) -> $num {
  sprintf("%4d" , $num ).print ;
}
print "\n" ;
say "-" x 48 ;
for (1..11) -> $num {
  sprintf("%4s" , "$num|" ).print ;
  if ( $num > 1 ) {
      print " " x ( ($num - 1 ) * 4 ) ;
  }
  for ( $num..11 ) -> $mult {
      sprintf("%4d", $num * $mult ).print ;
  }
  print "\n" ;
}
```

## See also

Five blog posts this time:

* Arne Sommer: https://raku-musings.com/add-mul.html;

* Adam Russell: https://adamcrussell.livejournal.com/11383.html;

* Jaldhar H. Vyas: https://www.braincells.com/perl/2019/11/perl_weekly_challenge_week_33.html;

* Javier Luque: https://perlchallenges.wordpress.com/2019/11/05/perl-weekly-challenge-033/;

* Roger Ball West: https://blog.firedrake.org/archive/2019/11/Perl_Weekly_Challenge_33.html.


## Wrapping up

Please let me know if I forgot any of the challengers or if you think my explanation of your code misses something important (send me an e-mail or just raise an issue against this GitHub page).

