use v6;

my @p = grep { .is-prime }, 1..*;   # Lazy infinite list of primes
sub mapper(UInt $i) {
    $i < 1 ?? 'Excluded' !!
    @p[$i] > (@p[$i - 1] + @p[$i + 1])/2 ?? 'Strong' !!
    @p[$i] < (@p[$i - 1] + @p[$i + 1])/2 ?? 'Weak'   !!
    'Balanced';
}
multi sub classify (&code, @a, &stopper) {
    my %classification;
    for @a.kv -> $key, $val {
        push %classification{&code($key)}, $val;
        &stopper(%classification);
    }
    return %classification;
}
my $stopper = { last if %^a{'Balanced'}.elems >= 10 };
my %categories = classify &mapper, @p, $stopper;
for sort keys %categories -> $key {
    next if $key eq 'Excluded';
    say "$key primes:  ", %categories{$key}[0..9];
}