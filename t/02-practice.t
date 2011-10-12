use Test;
use PracticeDates;

plan 6;

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

