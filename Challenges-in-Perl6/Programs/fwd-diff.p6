use v6;

sub fwd-diff (*@in) { 
    map {$_[1] - $_[0]},  (@in).rotor(2 => -1)
}
sub MAIN (Int $order, *@values where @values.elems > $order) {
    my @result = @values;
    @result = fwd-diff @result for 1 .. $order;
    say "{$order}th forward diff of @values[] is: @result[]";
}    


