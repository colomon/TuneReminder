use Test;
use Tunes;

plan 12;

my $tunes = Tunes.new;
isa_ok $tunes, Tunes, "We created a Tunes object";
is $tunes.AddTune("Kevin Broderick's", "AB|:c2 B>A|GEDE|G>GGE"), 0, "First tune got index 0";
is $tunes.AddTune("Father's Jig", "E|:A2B c2d|e2f d2B|[M:9/8] A2d f2a g2f"), 1, "Second tune got index 1";
is $tunes.AddTune("Pamela's Lonely Nights", "Adde fdAF|D2 ef gfed", "Composed by Emile Benoit"), 2, 
   "Third tune got index 2, comment accepted";
is $tunes.GetTuneName(0), "Kevin Broderick's", "First tune's name stored correctly";
is $tunes.GetTuneSnippet(1), "E|:A2B c2d|e2f d2B|[M:9/8] A2d f2a g2f", "Second tune's snippet stored correctly";
is $tunes.GetTuneComment(2), "Composed by Emile Benoit", "Third tune's snippet stored correctly";

is $tunes.Save("t/test-data"), 3, "Save method returns number of records saved";

{
    my $tunes-clone = Tunes.new;
    is $tunes-clone.Load("t/test-data"), 3, "Load method returns number of records read";
    is $tunes-clone.GetTuneName(0), "Kevin Broderick's", "First tune's name stored correctly";
    is $tunes-clone.GetTuneSnippet(1), "E|:A2B c2d|e2f d2B|[M:9/8] A2d f2a g2f", "Second tune's snippet stored correctly";
    is $tunes-clone.GetTuneComment(2), "Composed by Emile Benoit", "Third tune's snippet stored correctly";
}


