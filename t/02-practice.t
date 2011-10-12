use Test;
use PracticeDates;

plan 14;

my $test-filename = "t/test-data.dates";

# unlink $test-filename;

my $pd = PracticeDates.new();
isa_ok $pd, PracticeDates, "We created a PracticeDates object";
$pd.SetFilename($test-filename);

$pd.Record("1970-10-06", [0, 1, 2, 3, 4]);
is $pd.LatestPractice(1), "1970-10-06", "Latest practice correctly registered";
is $pd.LatestPractice(100), "1900-01-01", "Unregistered id gets 1/1/1900 as date";

$pd.Record("1970-10-19", [3, 17]);
is $pd.LatestPractice(1), "1970-10-06", "Latest practice still correctly registered";
is $pd.LatestPractice(3), "1970-10-19", "Latest practice still correctly registered";
is $pd.LatestPractice(10), "1900-01-01", "Unregistered id gets 1/1/1900 as date";

my @older = $pd.Older(50);
is +@older.grep(3 | 17), 0, "The two recent ones were not included";
ok @older.grep(0 | 1 | 2 | 4) > 1, "At least two of the old ones were included";

{
    my $pd2 = PracticeDates.new();
    isa_ok $pd2, PracticeDates, "We created a PracticeDates object";
    $pd2.Load($test-filename);
    is $pd2.LatestPractice(1), "1970-10-06", "Latest practice still correctly registered";
    is $pd2.LatestPractice(3), "1970-10-19", "Latest practice still correctly registered";
    is $pd2.LatestPractice(10), "1900-01-01", "Unregistered id gets 1/1/1900 as date";

    my @older2 = $pd2.Older(50);
    is +@older2.grep(3 | 17), 0, "The two recent ones were not included";
    ok @older2.grep(0 | 1 | 2 | 4) > 1, "At least two of the old ones were included";
}

