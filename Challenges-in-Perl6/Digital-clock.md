# A Digital Clock

This is derived in part from my [blog post](http://blogs.perl.org/users/laurent_r/2019/10/perl-weekly-challenge-28-file-type-and-digital-clock.html) made in answer to the [Week 28 of the Perl Weekly Challenge](https://perlweeklychallenge.org/blog/perl-weekly-challenge-028/) organized by  <a href="http://blogs.perl.org/users/mohammad_s_anwar/">Mohammad S. Anwar</a> as well as answers made by others to the same challenge.

The challenge reads as follows:

*Write a script to display Digital Clock. Feel free to be as creative as you can when displaying digits. We expect bare minimum something like “14:10:11”.*

## My Solutions

We can use a Perl 6 one-liner:

    $ perl6 -e 'loop { my $d = DateTime.now; printf "\r%02d:%02d:%02d", $d.hour, $d.minute, $d.second; sleep 1;'
    14:35:06

Two interesting things to say about it: first, we use the `\r` (carriage return) to go back to the first column of the screen and overwrite the previously displayed time with the new one each time we want to display a new time. This useless `\r` carriage return character (dating from old typewriters) is often a pain in the neck when dealing with Windows-generated files under Unix or Linux (or the other way around), I'm happy that I could find here some useful purpose for this pesky and usually useless character. Also note that this program uses `printf` with a formatting string to make sure that each number is printed over two characters (with a leading zero when needed). This program will run "forever", until you kill it with a `Ctrl C` command. It would be easy to add a counter to stop it after a while, if needed.

This can actually be made simpler:

    $ ./perl6 -e 'loop {print "\r", DateTime.now.hh-mm-ss;}'
    14:38:06

So, job done? Yes, sure, we're displaying a digital clock. But the task specification suggests to feel free to be creative when displaying the digits. So, let's try to get a nicer output. We could probably use some graphical library such as `Tk`, but I haven't used it for a fairly long time and I'm also not sure how to use it in Perl 6. We could also possibly use an HTML display, but I fear that would require to run a Web server, and I don't want to run into annoying environment problems. 

So I decided to use ASCII art to implement a [seven-segment display](https://en.wikipedia.org/wiki/Seven-segment_display) device:

``` Perl6
use v6;

my @digit_strings = (
' _  -   - _  -_  -    - _  - _  - _  - _  - _  -     ',
'| | - | - _| -_| -|_| -|_  -|_  -  | -|_| -|_| -  O  ',
'|_| - | -|_  -_| -  | - _| -|_| -  | -|_| - _| -  O  ',
'    -   -    -   -    -    -    -    -    -    -     ');

my @digits = map { [split /\-/, $_] }, @digit_strings;

sub display_time (Str $time) {
    my @pieces = $time.comb;
    for 0..3 -> $line {
        for @pieces <-> $digit {
            $digit = 10 if $digit eq ":";
            print @digits[$line][$digit];
        }
    say "";
    }
}

my $clear_screen = ($*VM.osname ~~ m:i/cyg | lin/) ?? "clear" !! "cls";
loop {
    my $d = DateTime.now;
    my $time_str = sprintf "%02d:%02d:%02d", $d.hour, $d.minute, $d.second; 
    shell $clear_screen;
    display_time $time_str;
    sleep 1; 
}

=finish

Example of displayed time:
    _        _   _        _   _
 |   |   O  | | |_|   O  | |  _|
 |   |   O  |_|  _|   O  |_| |_
```

## Alternative Solutions

Quite a few of the solutions below used system-specific features that did not work for me, despite trying them under Windows, Linux and Cygwin. The fact that I wasn't able to run a solution doesn't mean that it is a bad solution

[Arne Sommer](https://github.com/manwar/perlweeklychallenge-club/blob/master/challenge-028/arne-sommer/perl6/ch-2.p6) also used ASCII art to display a digital clock, but his digits are much more elaborated than mine:


       ,a8888a,         88           88  888888888888               ,d8        88  
     ,8P"'  `"Y8,     ,d88  888    ,d88          ,8P'  888        ,d888      ,d88  
    ,8P        Y8,  888888  888  888888         d8"    888      ,d8" 88    888888  
    88          88      88           88       ,8P'            ,d8"   88        88  
    88          88      88           88      d8"            ,d8"     88        88  
    `8b        d8'      88  888      88    ,8P'        888  8888888888888      88  
     `8ba,  ,ad8'       88  888      88   d8"          888           88        88  
       "Y8888P"         88           88  8P'                         88        88  


[Athanasius](https://github.com/manwar/perlweeklychallenge-club/blob/master/challenge-028/athanasius/perl6/ch-2.p6) wrote a `while` loop using the `\r` carriage return character to overwrite the previous display with the new one each time, just as in my one-liners:

``` Perl6
while 1
{
    sleep 1;

    if ++$sec >= 60
    {
        $sec = 0;

        if ++$min == 60
        {
            $min  = 0;
            $hour = 0 if ++$hour == 24;
        }
    }

    "%02d:%02d:%02d\r".printf($hour, $min, $sec);
}
```

[Daniel Mita](https://github.com/manwar/perlweeklychallenge-club/blob/master/challenge-028/daniel-mita/perl6/ch-2.p6) suggested a program which I don't fully understand and which I could not run (perhaps not the right terminal):

``` Perl6
my @num-groups = (^0x20000)
  .map( { .chr } )
  .grep( { .uniprop eq "Nd" } )
  .rotor(10)
  .map( { ( ^10 Z=> $_ ).Hash } );

loop {
  run 'clear';
  given DateTime.now -> $t {
    for @num-groups -> %nums {
      once {print ' ' x 8 ~ "\t"}
      print $t.hh-mm-ss.comb.map( { %nums{$_}
        || do given %nums{0}.uniprop('Block') {
          when 'Arabic' {'؛'}
          when 'NKo'    {'߸'}
          default       {':'}
        }} ).join;
      print $++ % 3 ?? "\t" !! "\n";
    }
    sleep 0.1 while $t.whole-second == DateTime.now.whole-second;
  }
}
```

I also could not run [Markus Holzer](https://github.com/manwar/perlweeklychallenge-club/blob/master/challenge-028/markus-holzer/perl6/ch-2.p6) solution, probably for similar reasons:

``` Perl6

subset CoordStr of Str where / ^ \d+ \, \d+ $ /;

my @numbers = map *.comb(3).Array,
    "╻━╻┃ ┃╹━╹", "  ╻  ┃  ╹", "╺━╻╻━╹╹━╸", "╺━╻╺━┃╺━╹", "╻ ╻╹━┃  ╹",
    "╻━╸╹━╻╺━╹", "╻━╸┃━╻╹━╹", "╺━╻  ┃  ╹", "╻━╻┃━┃╹━╹", "╻━╻╹━┃╺━╹";

sub MAIN( CoordStr :$at = "2,2" )
{
    my ($x, $y) = $at.Str.split(',');

    react {
        whenever Supply.interval(1) -> $v {
            print clear-screen;
            display-time( $x, $y, DateTime.now.hh-mm-ss );
            print go-to(0,0);
        }

        whenever signal(SIGINT) { exit 0; }
    }
}

sub display-time( $x, $y, $time )
{
    for $time.comb.kv -> $column, $part
    {
        if $part ~~ /\d/
        {
            for |@numbers[$part].kv -> $idx, $line
            {
                print go-to( $x + ($column * 3), $y + $idx ) ~ $line;
            }
        }
        else
        {
            print go-to( $x + ($column * 3) , $y + 1) ~ " : ";
        }
    }
}

sub clear-screen() { escape("2J") ~ escape(";H"); }
sub go-to( $column, $row ) { escape( "$row;$column" ~ "H" ); }
sub escape( $value ) { "\e[" ~ $value; }
```

[Kevin Colyer](https://github.com/manwar/perlweeklychallenge-club/blob/master/challenge-028/kevin-colyer/perl6/ch-2.p6) wrote a bare-bone program essentially similar to one of my one-liners:

``` Perl6
sub MAIN() {
    # bare minimum
    say DateTime.now.hh-mm-ss;
}
```

[Simon Proctor](https://github.com/manwar/perlweeklychallenge-club/blob/master/challenge-028/simon-proctor/perl6/ch-2.p6) used the `\r` carriage-return character to do something similar to my one-liners:

``` Perl6
multi sub MAIN() {
    END say "";
    loop {
        print "{DateTime.now.hh-mm-ss}";
        sleep 1;
        print "\r";
    }
}
```

[Ulrich Rieke](https://github.com/manwar/perlweeklychallenge-club/blob/master/challenge-028/ulrich-rieke/perl6/ch-2.p6)'s solution uses an external `figlet` command which I do not know and can't test adequately:

``` Perl6
use v6 ;
run 'figlet' , "{DateTime.now.Str.substr(11,8)}" ;
```

[Feng Chang](https://github.com/manwar/perlweeklychallenge-club/blob/master/challenge-028/feng-chang/perl6/ch-2.p6) also suggested a solution which I am not able to run:

``` Perl6
my $clock = Supply.interval: 1;
$clock.tap: { print "\r", DateTime.now.hh-mm-ss };

signal(SIGINT).tap({ put "\r{ DateTime.now.hh-mm-ss }  "; exit 0; });
sleep ∞;
```

[Joelle Maslak](https://github.com/manwar/perlweeklychallenge-club/blob/master/challenge-028/joelle-maslak/perl6/ch-2.p6) used a solution similar to one of my one-liners:

``` Perl6
sub MAIN() {
    say DateTime.now.hh-mm-ss;
}
```

[Ruben Westerberg](https://github.com/manwar/perlweeklychallenge-club/blob/master/challenge-028/ruben-westerberg/perl6/ch-2.p6) provided code using supplies, `react` and `whenever` features and I must admit that I get an idea of what it is doing, but don't fully understand it:

``` Perl6
my $offset=0;
#my @codes=("\x1b[{$offset}D"
react { whenever Supply.interval(.1) {
	print "=";
} 
	whenever Supply.interval(1) {
		print "\x1b[2K";
		 print "\x1b[1000D";
		print DateTime.now.hh-mm-ss;
	 }
}
```

[Yet Ebreo](https://github.com/manwar/perlweeklychallenge-club/blob/master/challenge-028/yet-ebreo/perl6/ch-2.p6) provided an ASCII art solution:

``` Perl6
my @ascii_num= (
    ["  0000  "," 00  00 "," 00  00 "," 00  00 ","  0000  "],
    ["   11   ","   11   ","   11   ","   11   ","   11   "],
    [" 222222 ","     22 "," 222222 "," 22     "," 222222 "],
    [" 333333 ","     33 "," 333333 ","     33 "," 333333 "],
    [" 44  44 "," 44  44 "," 444444 ","     44 ","     44 "],
    [" 555555 "," 55     "," 555555 ","     55 "," 555555 "],
    [" 666666 "," 66     "," 666666 "," 66  66 "," 666666 "],
    [" 777777 ","     77 ","     77 ","     77 ","     77 "],
    [" 888888 "," 88  88 "," 888888 "," 88  88 "," 888888 "],
    [" 999999 "," 99  99 "," 999999 ","     99 "," 999999 "],
    ["    "," :: ","    "," :: ","    "],
    ["    ","    ","    ","    ","    "]
);
my $toggler = 1;
loop {
    my $dig_time = DateTime.now;
    my @printline;
    
    $toggler = !$toggler;
    for $dig_time.hh-mm-ss.split("",:skip-empty) -> $x {
        for (0 .. 4) -> $i {
            @printline[$i] ~= @ascii_num[ ($x~~/\:/) ?? ( $toggler ?? 10 !! 11) !! $x ][$i];
        }
    }

    #This might cause flicker
    shell (($*DISTRO.name eq 'mswin32') ?? 'cls' !! 'clear');

    for (0 .. 4) -> $i {
        say @printline[$i];
    }

    say "\nToday is "~qw|Monday Tuesday Wednesday Thursday Friday Saturday Sunday|[$dig_time.day-of-week-1]
    ~": "~qw|January February March April May June July August September October November December|[$dig_time.month-1]
    ~" "~$dig_time.day~","
    ~" "~$dig_time.year;
    sleep .5
}
```

which produces output like so:

     222222  333333      44  44   0000       333333   0000
         22      33  ::  44  44  00  00  ::      33  00  00
     222222  333333      444444  00  00      333333  00  00
     22          33  ::      44  00  00  ::      33  00  00
     222222  333333          44   0000       333333   0000

[Jaldhar H. Vyas](https://www.braincells.com/perl/2019/10/perl_weekly_challenge_weeks_27-28.html) was away in a location with poor Internet access and therefore unable to complete the challenge in time. He nonetheless completed the challenge afterwards. His program uses a supply (a data type implementing a thread-safe, asynchronous data streams used for concurrent programming) that fires every one second interval. At that point it is "tapped" by calling the tick() subroutine which prints the correct time. 

``` Perl6
sub tick() {
    my $now = DateTime.now;
    print "\b" x 8,
        sprintf("%02d:%02d:%02d", $now.hour, $now.minute , $now.second);
}

my $supply = Supply.interval(1);

$supply.tap( -> $v { tick; } );

tick();
sleep;
```

## See Also

Only two blog posts (besides mine) this time, as far as I can say from Mohammad's recap and from the GitHub repository:

Arne Sommer: https://perl6.eu/binary-clock.html;

Jaldhar H. Vyas:https://www.braincells.com/perl/2019/10/perl_weekly_challenge_weeks_27-28.html.

## Wrapping up

Please let me know if I forgot any of the challengers or if you think my explanation of your code misses something important (send me an e-mail or just raise an issue against this GitHub page).

