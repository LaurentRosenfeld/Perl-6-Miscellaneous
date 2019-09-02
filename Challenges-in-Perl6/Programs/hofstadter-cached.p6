use v6;
use experimental :cached;

sub female (UInt:D $n) is cached {
    return 1 if $n == 0;   # base case
    return $n - male (female ($n - 1));
}
sub male (UInt:D $n) is cached {
    return 0 if $n == 0;   #base case
    return $n - female (male ($n - 1));
}
sub MAIN (UInt $input) {
    say "Female $input: ", female $input;
    say "Time taken: ", now - INIT now;
}