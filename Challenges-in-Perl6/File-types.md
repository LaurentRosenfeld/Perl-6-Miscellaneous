# File Types

This is derived in part from my [blog post](http://blogs.perl.org/users/laurent_r/2019/10/perl-weekly-challenge-28-file-type-and-digital-clock.html) made in answer to the [Week 28 of the Perl Weekly Challenge](https://perlweeklychallenge.org/blog/perl-weekly-challenge-028/) organized by  <a href="http://blogs.perl.org/users/mohammad_s_anwar/">Mohammad S. Anwar</a> as well as answers made by others to the same challenge.

The challenge reads as follows:

*Write a script to check the file content without explicitly reading the content. It should accept file name with path as command line argument and print “The file content is binary.” or else “The file content is ascii.” accordingly.*

On most operating systems (VMS is an exception to a certain extent), there is no 100%-reliable algorithm to know whether a file is text (ASCII or UTF-8) or binary, but only some heuristic guesses. Usually, programs that attempt to find out whether a file is text or binary read a raw block of bytes (often 4096 bytes) and make some statistics on the number of bytes corresponding to ASCII printable and space characters versus non-printable characters. If the number of non-printable character exceeds a certain fraction of the whole (for example one third, or 10%, or whatever), then the file is deemed to be binary. Also, any file containing a zero byte in the examined portion is considered a binary file.

In Perl 5, the `-T` and `-B` file test operators more or less work as described above. 

## My Solution

Perl 6 has most of the Perl 5 test file operators (albeit with a slightly different syntax), but operators equivalent to Perl 5 `-T` and `-B` file test operators currently do not exist (or are not yet implemented). We will use the existing file test operators (`-e`, `-z` and `-f`) to check, respectively, that the file exists, that it is not empty and that it is a regular file, but we have to roll out our own `is-binary` subroutine to try to mimic the Perl 5 `-T` and `-B` operators. This subroutine will read a raw block of the first 4096 bytes of the file and examine each byte in turn to make some statistics on space characters and printable characters versus non-printable characters.

The slight difficulty, though, is to determine exactly what should be considered a non-printable character. For lack of a standard definition of such characters, I've decided to consider that byte decimal values 0 to 8 and 14 to 31 correspond to ASCII non-printable characters. Those values will be stored in a set. With such a small number of non-printable characters compared to the full extended ASCII, the proportion of non-printable character would be around 10% on a random bytes binary file. I have decided to consider that a file shall be deemed to be text (ASCII) if there is less than one byte out of 32 that is non-printable, and binary otherwise. In addition, any file for which the buffer contains at least one null byte (value 0) is considered to be binary.

``` Perl6
use v6;

sub is-binary ($file) {
    my constant non-printable-bytes = (0..8).Set (|) (14..31).Set;
    my constant block-size = 4096;
    my $fh = $file.IO.open(:r, :bin);
    my $buf = $fh.read(block-size);
    $fh.close;
    my ($printable, $non-printable) = 0, 0;
    for $buf.list -> $byte {
        return True if $byte == 0; # null byte
        if $byte (elem) non-printable-bytes {
            $non-printable++;
        } else {
            $printable++;
        }
    }
    return True if $non-printable * 31 > $printable;
    False;
}

sub MAIN ($file) {
    die "File $file does not exist" unless $file.IO ~~ :e;
    die "File $file is empty" if $file.IO ~~ :z;
    die "File $file isn't a plain file" unless $file.IO ~~ :f;
    say is-binary($file) ?? "File content is binary" !! "File content is text (ASCII)";
}
```

This appears to work as desired:

    $ perl6 file-type.p6
    Usage:
      file-type.p6 <file>
    
    $ perl6 file-type.p6 foobar.baz
    File foobar.baz does not exist
      in sub MAIN at file-type.p6 line 23
      in block <unit> at file-type.p6 line 1


    $ perl6 file-type.p6 file-type.p6
    File content is text (ASCII)
    
    $ perl6 file-type.p6 amazon.pl.gz
    File content is binary

## Alternative Solutions

[Arne Sommer](https://github.com/manwar/perlweeklychallenge-club/blob/master/challenge-028/arne-sommer/perl6/ch-1.p6) used the `is-text` subroutine exported by Jonathan Worthington's [Data::TextOrBinary](https://github.com/jnthn/p6-data-textorbinary) module, which applies more or less the same heuristics as the one I used above. Using such a module makes the code pretty simple:

``` Perl6
use Data::TextOrBinary;

sub MAIN ($file, :$test-bytes = 4096)
{
  if $file.IO.d
  {
    say "Directory.";
  }
  elsif $file.IO.e
  {
    say is-text($file.IO, :$test-bytes)
      ?? "Text file."
      !! "Binary file.";
  }
  else
  {
    say "File doesn't exist.";
  }
}
```

Note that Arne's [blog post](https://perl6.eu/binary-clock.html) has an extended discussion about the subject, including original 7-bit ASCII versus extended 8-bit ASCII, and so on.

[Yet Ebreo](https://github.com/manwar/perlweeklychallenge-club/blob/master/challenge-028/yet-ebreo/perl6/ch-1.p6) also used the `is-text` function of the [Data::TextOrBinary](https://github.com/jnthn/p6-data-textorbinary) module:

``` Perl6
use Data::TextOrBinary;

sub MAIN (
    *@files #= Files to check if ascii/binary
) {
    for @files -> $x {
        if (is-text($x.IO)) {
            say "[$x]: The file content is ascii.";
        } else {
            say "[$x]: The file content is binary.";
        }
    }
}
```

[Athanasius](https://github.com/manwar/perlweeklychallenge-club/blob/master/challenge-028/athanasius/perl6/ch-1.p6) chose to use the Perl 5 [File::Util](https://metacpan.org/pod/File::Util) module within Perl 6, which provides a good example on how Perl 6 can benefit from the Perl 5 ecosystem:

``` Perl6
use File::Util:from<Perl5> <file_type>;

BEGIN say '';

#===============================================================================
sub MAIN(Str:D $path)
#===============================================================================
{
    my Str $description = ! .e ?? 'This does not exist'      !!
                            .d ?? 'This is a directory'      !!
                          ! .f ?? 'This is not a plain file' !!
                            .z ?? 'The file is empty'        !! 'OK'
               given $path.IO;

    if $description eq 'OK'
    {
        my Str @types = file_type($path);

        if @types.elems == 2 && @types[0] eq 'PLAIN'
        {
            my Str $t1   = @types[1];
            $description = $t1 eq 'TEXT'   ?? 'The file content is text'   !!
                           $t1 eq 'BINARY' ?? 'The file content is binary' !!
                      'ERROR: The file content is neither text nor binary';
        }
        else
        {
            $description = 'ERROR: Unexpected file types: ' ~ @types.join(', ');
        }
    }

    qq{"$path": $description}.say;
}
```

[Kevin Colyer](https://github.com/manwar/perlweeklychallenge-club/blob/master/challenge-028/kevin-colyer/perl6/ch-1.p6) decided to read a single byte using the `getc` method in a `try` block in order to decide whether a file is ASCII or binary. I'm not convinced this is very reliable, but Kevin's program uses some interesting Perl 6 features:

``` Perl6
use Test;

sub MAIN(Str $file where *.IO.e) {
    my $fh = $file.IO.open;
    LEAVE try close $fh;

    # attempt a single byte read explicitly in ascii
    $fh.encoding: 'ascii';

    try {
        $fh.getc;
    }
    if $! { say “The file content is binary.”}
    else  { say “The file content is ascii.” };
}
```

[Ulrich Rieke](https://github.com/manwar/perlweeklychallenge-club/blob/master/challenge-028/ulrich-rieke/perl6/ch-1.p6), who is a new member of the team (welcome, Ulrich), used a solution similar to Kevin's:

``` Perl6
sub MAIN( Str $filename ) {
  my $fh = open $filename , :r ;
  try $fh.get ;
  if ( $! ) {
      say "The file is binary." ;
  }
  else {
      say "The file is ascii." ;
  }
}
```

[Markus Holzer](https://github.com/manwar/perlweeklychallenge-club/blob/master/challenge-028/kevin-colyer/perl6/ch-1.p6) used the [file](http://gnuwin32.sourceforge.net/packages/file.htm) external GNU Windows utility:

``` Perl6
sub MAIN( $file )
{
    my $magic = run( "file", $file, :out ).out.slurp;
    say "The file content is ", ($magic ~~ / \s text \, / ?? "ascii" !! "binary");
}
```

[Feng Chang](https://github.com/manwar/perlweeklychallenge-club/blob/master/challenge-028/feng-chang/perl6/ch-1.p6) chose to read 16 bytes from the file and apply the `is-ascii` subroutine, which checks for bytes numeric ranges 9 to 13 and 32 to 126:

``` Perl6
sub is-ascii(uint8 $c --> Bool) { 
    9 <= $c <= 13 or 32 <= $c <= 126 
}
sub MAIN(Str:D $file-name where *.IO.e) {
    print 'the file content is ';
    say   ([and] open($file-name, :r).read(16).list».&{ is-ascii($_) }) ??
              'ascii' !! 'binary';
}
```

[Joelle Maslak](https://github.com/manwar/perlweeklychallenge-club/blob/master/challenge-028/joelle-maslak/perl6/ch-1.p6) wrote a `File-Info` class, which considers bytes 7, 9 to 13 and 32 to 126 to be printable ASCII characters. Her program reads 512 bytes from the file and deems the file to be *possibly* ASCII if less that one third of the characters are non printable.

``` Perl6
class File-Info {
    my uint8 @print-default;
    BEGIN {
        @print-default.push:   7; # Backspace is considered a printable for this routine's purposes
        @print-default.push:   9; # Horizontal tab
        @print-default.push:  10; # Line Feed
        @print-default.push:  12; # Form Feed
        @print-default.push:  13; # Carriage Return
        @print-default.push: |(32..126);  # All other printables
    }

    has Str:D  $.filename is required;
    has UInt:D $.bytes-to-examine = 512;
    has Set:D  $.printables = Set.new(@print-default);
    has buf8   $!start-block;

    method TWEAK() {
        my $fh = $.filename.IO.open: :r, :bin;
        $!start-block = $fh.read($!bytes-to-examine);
        $fh.close;
    }

    method possibly-ascii-printable(-->Bool:D) {
        return False if 0 ∈ $!start-block;  # Nul chars are automatic binary

        my $unprintable = $!start-block.grep( * ∈ @($!printables) ).elems;
        return False if ($unprintable * 3) > $!start-block.elems;

        # It's possibly ascii.
        return True;
    }
} 
```

[Ruben Westerberg](https://github.com/manwar/perlweeklychallenge-club/blob/master/challenge-028/ruben-westerberg/perl6/ch-1.p6) based his determination of the file type on the file extension:

``` Perl6
#!/usr/bin/env perl6
my %ext;
data.lines.map({
	my @f=.split(/\s|\,/,:skip-empty);
	my $type= /^text\// ?? "text" !! "binary" given @f.shift;
	%ext{$_}=$type for @f;
});

@*ARGS.map({
	my $type=%ext{.IO.extension};
	$type="binary" if !$type;
	put "$_: The file content is $type";
});

#emulate perl5 DATA section... sort of..
sub data() {
	q:to/END/
	text/html                                        html htm shtml
	text/css                                         css
	text/xml                                         xml
	text/mathml                                      mml
	text/plain                                       txt
	text/vnd.sun.j2me.app-descriptor                 jad
	text/vnd.wap.wml                                 wml
	text/x-component                                 htc
	END	
}
```

## See Also

Only one blog post (besides mine) this time, as far as I can say from Mohammad's recap and from the GitHub repository:

Arne Sommer: https://perl6.eu/binary-clock.html.

## Wrapping up

Please let me know if I forgot any of the challengers or if you think my explanation of your code misses something important (send me an e-mail or just raise an issue against this GitHub page).

If you want to participate to the Perl Weekly Challenge, please connect to [this site](https://perlweeklychallenge.org/).

