use v6;

sub split-str ($in) {
    my $prev = "";
    my $tmp-str = "";
    my @out;
    for $in.comb -> $letter {
        if $letter eq $prev {
            $tmp-str ~= $letter;
        } else {
            push @out, $tmp-str if $tmp-str ne "";
            $tmp-str = $letter;
            $prev = $letter;
        }
    }
    push @out, $tmp-str;
    return join ", ", @out;
}

sub MAIN (Str $input = "ABBBCDEEF") {
    say split-str $input;
}