use Test;
use Tunes;

plan 4;

my $tunes = Tunes.new;
isa_ok $tunes, Tunes, "We created a Tunes object";
is $tunes.AddTune("Kevin Broderick's", "AB|:c2 B>A|GEDE|G>GGE"), 0, "First tune got index 0";
is $tunes.AddTune("Father's Jig", "E|:A2B c2d|e2f d2B|[M:9/8] A2d f2a g2f"), 1, "Second tune got index 1";
is $tunes.AddTune("Pamela's Lonely Nights", "Adde fdAF|D2 ef gfed", "Composed by Emile Benoit"), 2, 
   "Third tune got index 2, comment accepted";


