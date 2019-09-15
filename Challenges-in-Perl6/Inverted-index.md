
# Inverted Index

This is derived from my [blog post](http://blogs.perl.org/users/laurent_r/2019/09/perl-weekly-challenge-24-smallest-script-and-inverted-index.html) made in answer to the [Week 24 of the Perl Weekly Challenge](https://perlweeklychallenge.org/blog/perl-weekly-challenge-024/) organized by  <a href="http://blogs.perl.org/users/mohammad_s_anwar/">Mohammad S. Anwar</a> as well as answers made by others to the same challenge.

The challenge reads as follows:

*Create a script to implement full text search functionality using Inverted Index. According to [wikipedia](https://en.wikipedia.org/wiki/Inverted_index):*

> In computer science, an inverted index (also referred to as a postings file or inverted file) is a database index storing a mapping from content, such as words or numbers, to its locations in a table, or in a document or a set of documents (named in contrast to a forward index, which maps from documents to content). The purpose of an inverted index is to allow fast full-text searches, at a cost of increased processing when a document is added to the database.

## My Solution

I do not find the Wikipedia explanation to be very clear, but I'll implement the following: I have on my file system a directory containing about 350 Perl 6 programs (with ".p6" or ".pl6" extensions).. My program will read all these files (line by line), split the lines into words and keep only words containing only alphanumerical characters (to get rid of operators and variables names with sigils) and with a length of at least 3 such characters. These words will be used to populate a hash (actually a HoH), so that for each such word, I'll be able to directly look up the name of all the files where this word is used. 

``` Perl6
use v6;

my @files = grep { /\.p6$/ or /\.pl6$/ }, dir('.');
my %dict;
for @files -> $file {
    for $file.IO.lines.words.grep({/^ \w ** 3..* $/}) -> $word {
        %dict{$word}{$file} = True;
    }
}
.say for %dict{'given'}.keys;
```

Note that we could possibly use a hash of sethashes instead of a hash of hashes, but I do not see any obvious benefit doing so.

The program duly prints out the list of files with the `given` keyword:

    $ perl6 inverted-index.p6
    mult_gram.p6
    calc_grammar.pl6
    calculator-exp.pl6
    VMS_grammar.p6
    ana2.p6
    calc_grammar2.pl6
    ArithmAction.pl6
    
    [... lines omitted for brevity]
    
    normalize_url.p6
    calculator.p6
    arithmetic.pl6
    json_grammar_2.pl6
    point2d.pl6
    arithmetic2.pl6
    forest.p6

## Alternate solutions

[Arne Sommer](https://github.com/manwar/perlweeklychallenge-club/blob/master/challenge-024/arne-sommer/perl6/make-inverted-index-fixed) uploaded a number of Perl 6 scripts on the challenge Github repository. It seems to me that that script linked to above is the interesting one, as it is the one that actually creates the index. Arne's program takes a list of files as argument and write the index to a text file. If we discard boiler plate code and exception handling on files opening, the index creation itself takes two code lines:

``` Perl6
my @words = (slurp $file).split(/<+[\W] - [\-] + [_] >+/);
@words.map({ %index{$_}.{$file} = True });
```

[Francis J. Whittle](https://github.com/manwar/perlweeklychallenge-club/blob/master/challenge-024/fjwhittle/perl6/ch-2.p6)'s program also takes a list of files as argument and  is also fairly concise. This is the index construction:

``` Perl6
for @file.map(*.?IO).grep({.?f && .?r}) -> $file {
  %index.push:
    $file.comb(/\w+/, :match).hyper.map({ .Str.fc => $($file.path => .pos,) });
}
```

Once the index has been populated, Francis's program prompts the user for a word to search and prints out the list of files with this word:

``` Perl6
while my $word = prompt 'Find? ' {
  %index{$word.fc}».say;
}
```

[Kevin Colyer](https://github.com/manwar/perlweeklychallenge-club/blob/master/challenge-024/kevin-colyer/perl6/ch-2.p6) created a fairly comprehensive OO program providing a full-fledged `DocumentStore` class with half a dozen methods and three attibutes: `@!documents`, `%!documentNames`, and `%!index`. The `indexDocument` private method does the bulk of the work of creating and populating the index:

``` Perl6
method !indexDocument($name){
    my Str $doc=@!documents[%!documentNames{$name}];
    my Int $i=0;
    my Str $word;
    while $i < $doc.chars  {
         $doc.substr($i) ~~ m/ (\W*) (\w+) /;
        $i+=$/[0].chars if $/[0] ;
        last unless $/[1];
        $word=$/[1].lc;
        %!index{$word}.push: "$name:$i";
        $i+=$word.chars;
    }
    return;
};
```

Kevin's program also implements a quite extended series of tests.

[Noud](https://github.com/manwar/perlweeklychallenge-club/blob/master/challenge-024/noud/perl6/ch-2.p6)'s program  also takes a list of files as argument and  is also fairly concise. This is the index construction:

``` Perl6
for @files -> $file {
    for $file.IO.words.unique -> $word {
        if %inv_index{$word}:exists {
            %inv_index{$word} = ($file, |(%inv_index{$word}));
        } else {
            %inv_index{$word} = ($file);
        }
    }
}
```

[Jaldhar M. Yvas](https://github.com/manwar/perlweeklychallenge-club/blob/master/challenge-024/jaldhar-h-vyas/perl6/ch-2.p6)'s program  also takes a list of files as argument and passes each file name to the `process` subroutine which populates the `%index` hash of arrays of hashes. Note that this subroutine stores the file name *and* line number where each word occurs:

``` Perl6
sub process($filename, %index) {
    my $lineno = 0;

    for $filename.IO.lines -> $line {
        $lineno++;
        for $line.words -> $word {
            %index{$word}.push({ document => $filename, line => $lineno });
        }
    }
}
```

[Joelle Maslak](https://github.com/manwar/perlweeklychallenge-club/blob/master/challenge-024/joelle-maslak/perl6/ch-2.p6) followed a two-step process: her program first build a `%docs` hash of lists of unique words for each input file, and then reprocesses the `%docs` hash to build `%index` inverted index:

``` Perl6
my %docs;

for @files -> $fn {
    %docs{$fn} = $fn.IO.words.unique;
}

# Build the index
my %index;
for %docs.keys.sort -> $fn {
    for @(%docs{$fn}) -> $word {
        %index{$word} = [] unless %index{$word}:exists;
        %index{$word}.push: $fn;
    }
}
```

 [Randy Lauen](https://github.com/manwar/perlweeklychallenge-club/blob/master/challenge-024/randy-lauen/perl6/ch-2.p6) used a hard-coded list of documents (really a `%documents` hash of famous book titles and strings containing small excerpts of such tiles). His `build_inverse_index` subroutine loops over the documents and uses a bag to record each word along with a word count. Then, it populates an `%index` hash of arrays of hashes with document name and frequency in that document for each word:

 ``` Perl6
for %documents.kv -> $name, $text {
    my $bag = bag $text.lc.words;
    for $bag.kv -> $word, $freq {
        %index{ $word }.push: %( doc => $name, freq => $freq );
    }
}
 ```

[Ruben Westerberg](https://github.com/manwar/perlweeklychallenge-club/blob/master/challenge-024/ruben-westerberg/perl6/ch-2.p6) populated a `%index` hash of hashes of hashes containing for each word a file path and for each file path a counter. His program syntax is somewhat unusual.

``` Perl6
$*ARGFILES.handles.map({
	.encoding('utf8');
	my $path=.path;
	my $line=1;
	sink .lines.map({
		sink .comb(/\w+/).  map({
			%index{$_}{$path}<count>++;
			%index{$_}{$path}<lines>.push($line);
		});
		$line++;
	});
});
```
[Simon Proctor](https://github.com/manwar/perlweeklychallenge-club/blob/master/challenge-024/simon-proctor/perl6/ch-2.p6) is the only challenger who used channels and promises to parallelize index construction. 

``` Perl6
multi sub MAIN (
    *@documents where { @documents.all ~~ FileExists }, #= List of documents to process
    Int :$min-length = 3, #= Minimum word length to count for inclusion in the index. Default is 3 characters.
) {
    my %index;
    my $word-channel = Channel.new;
    my @promises;
    
    for @documents -> $path {
        @promises.push(
            start {
                my $res-path = $path.IO.resolve.Str;
                for $path.IO.words -> $word is copy {
                    $word ~~ s:g!<[\W]>!!;
                    next unless $word.chars >= $min-length;
                    $word-channel.send( ( $word.fc, $res-path ) );
                }
            }
        );
    }
    
    my $reactor = start react {
        whenever $word-channel -> ( $word, $path ) {
            %index{$word} //= SetHash.new;
            %index{$word}.{$path} = True;
        }
    }
    await @promises;
    $word-channel.close;
    await $reactor;
    
    %index = %index.map( { $_.key => $_.value.keys } );
    say to-json( %index );
}
```

[Yet Embreo](https://github.com/manwar/perlweeklychallenge-club/blob/master/challenge-024/yet-ebreo/perl6/ch-2.p6)'s program  takes a list of files as argument (as well as a list of words to be searched) and builds the index like so:

``` Perl6
for @files -> $file {
    for $file.IO.lines -> $line {
        %index{ .lc }{ $file.subst(/^\.\\/,'') }++ for $line.split(/\W/).grep(/^ \w ** {$minimum_length..*} $/)
    }
}
```

## See Also

Not too many blogs this time:

* Arne Sommer: https://perl6.eu/small-inversions.html.

* Jaldhar H. Vyas: https://www.braincells.com/perl/2019/09/perl_weekly_challenge_week_24.html


## Wrapping up

Please let me know if I forgot any of the challengers or if you think my explanation of your code misses something important.

If you want to participate to the Perl Weekly Challenge, please connect to [this site](https://perlweeklychallenge.org/).


