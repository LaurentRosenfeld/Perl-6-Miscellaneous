use v6;

sub postfix:<!> (Int $n) {
    [*] 2..$n;
}
sub eul (Int $n) {
    [+] map { 1 / ($_!).FatRat}, 0..$n;
}
sub MAIN (Int $n) {
    say eul $n;
}
