# Five Weekends in a Month

This is derived from my [blog post](http://blogs.perl.org/users/laurent_r/2019/07/perl-weekly-challenge-19-weekends-and-wrapping-lines.html) made in answer to the [Week 19 of the Perl Weekly Challenge](https://perlweeklychallenge.org/blog/perl-weekly-challenge-019/) organized by  <a href="http://blogs.perl.org/users/mohammad_s_anwar/">Mohammad S. Anwar</a> as well as answers made by others to the same challenge.

The challenge reads as follows:

*Write a script to display months from the year 1900 to 2019 where you find 5 weekends i.e. 5 Friday, 5 Saturday and 5 Sunday.*

## My Solution

My first idea was to loop over each month in the range 1900-2019. For each month, find the first Friday and then count the number of Sundays after that in the month. Then, even before I started to code that, it came to my mind that I didn't need to loop over all the days of the month, but just to count how many days there were in the month after the first Friday: there will five weekends if there are more than 29 days (4 weeks plus 1 day) after that first Friday of the month.

``` perl6
use v6;

for 1900..2019 -> $year {
    for 1..12 -> $month {
        my $day = 1;
        my $date = Date.new($year, $month, $day);
        my $last-day-of-month = 
            $date.later(month => 1).earlier(day => 1);
        ++$date until $date.day-of-week == 5;
        say $year, "-", $month.fmt("%02d"), " has 5 weekends" 
            if $last-day-of-month - $date > 29;
    }
}
```

That works fine:

    1901-03 has 5 weekends
    1902-08 has 5 weekends
    1903-05 has 5 weekends
    1904-01 has 5 weekends
    ...
    (lines omitted for brevity)
    ...
    2016-01 has 5 weekends
    2016-07 has 5 weekends
    2017-12 has 5 weekends
    2019-03 has 5 weekends

Then, I started to check the result and looked at a calendar, and it immediately became obvious to me that it is actually even much simpler than that: to have 5 full weekends (Friday through Sunday), a month needs to have 31 days (so January, March, May, etc.) *and* to start with a Friday. So this is my new simpler script:

``` perl6
use v6;

for 1900..2019 -> $year {
    for 1, 3, 5, 7, 8, 10, 12 -> $month {
        say "$year-{$month.fmt("%02d")} has 5 weekends." 
            if Date.new($year, $month, 1).day-of-week == 5;
    }
}
```

This prints the same as before, there no point repeating the output.

## Alternative Solutions

[Arne Sommer](https://github.com/manwar/perlweeklychallenge-club/blob/master/challenge-019/arne-sommer/perl6/ch-1.p6), [Francis Whittle](https://github.com/manwar/perlweeklychallenge-club/blob/master/challenge-019/fjwhittle/perl6/ch-1.p6), [Jo Christian Oterhals](https://github.com/manwar/perlweeklychallenge-club/blob/master/challenge-019/jo-christian-oterhals/perl6/ch-1.p6), [Noud](https://github.com/manwar/perlweeklychallenge-club/blob/master/challenge-019/noud/perl6/ch-1.p6), [Ozzy](https://github.com/manwar/perlweeklychallenge-club/blob/master/challenge-019/ozzy/perl6/ch-1.p6), [Feng Chang](https://github.com/manwar/perlweeklychallenge-club/blob/master/challenge-019/feng-chang/perl6/ch-1.p6), [Jaldhar H. Vyas](https://github.com/manwar/perlweeklychallenge-club/blob/master/challenge-019/jaldhar-h-vyas/perl6/ch-1.p6), [Roger Bell West](https://github.com/manwar/perlweeklychallenge-club/blob/master/challenge-019/roger-bell-west/perl6/ch-1.p6), and [Ruben Westerberg](https://github.com/manwar/perlweeklychallenge-club/blob/master/challenge-019/ruben-westerberg/perl6/ch-1.p6) also all picked up that only months with 31 days and starting on a Friday can contain five full weekends. The main difference between their solutions is that some (like me) hard-coded the months with 31 days, where others used the `day-in-months` method to let the program find out. Strangely, none of those who used the `day-in-months` method thought about caching the list of eligible months in an array to speed up the rest of the process, so they ended up making many more checks than really needed. Having said that, I should add that all this is very fast and most of the time taken is for printing out the results.

[Randy Lauen](https://github.com/manwar/perlweeklychallenge-club/blob/master/challenge-019/randy-lauen/perl6/ch-1.p6) also knows about months with 31 sdays starting on a Friday, but his solution is quite original as he created a role with two methods (including `has-five-full-weekends`) to fulfill the requirement. Interesting and instructive approach, worth looking at, but perhaps a little bit over-engineered for such a simple task, in my humble opinion.

[Athanasius](https://github.com/manwar/perlweeklychallenge-club/blob/master/challenge-019/athanasius/perl6/ch-1.p6) has also found out that a month needs to have 31 days to be able to have five full weekends, but looked at whether the 29th day of each such month is a Friday to decide whether there are five weekends in that month. This is obviously equivalent to finding whether the first day of the month is a Friday, but a bit unexpected.

[Joelle Maslak](https://github.com/manwar/perlweeklychallenge-club/blob/master/challenge-019/joelle-maslak/perl6/ch-1.p6) took another equivalent approach: for a month to have five full weekends, the month must have 31 days and *end on a Sunday*.

[Simon Proctor](https://github.com/manwar/perlweeklychallenge-club/blob/master/challenge-019/simon-proctor/perl6/ch-1.p6) used a different approach actually counting the number of weekends for each month.

## See Also

See also the following blog posts:

* Arne Sommer: https://perl6.eu/word-wrapped-weekends.html
* Francis Whittle: https://rage.powered.ninja/2019/07/29/best-months.html
* Jo Christian Oterhals: https://medium.com/@jcoterhals/perl-6-small-stuff-21-its-a-date-or-learn-from-an-overly-complex-solution-to-a-simple-task-cf469252724f
* Jaldhar H. Vyas: https://www.braincells.com/perl/2019/08/perl_weekly_challenge_week_19.html
* Roger Bell West: https://blog.firedrake.org/archive/2019/08/Perl_Weekly_Challenge_19.html

## Wrapping up

Please let me know if I forgot any of the challengers or if you think my explanation of your code misses something important.

If you want to participate to the Perl Weekly Challenge, please connect to [this site](https://perlweeklychallenge.org/).

