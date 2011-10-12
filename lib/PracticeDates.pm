class PracticeDates {
    has $!filename;
    has @!latest-practice;
    has @!sorted-ids;
    
    method SetFilename($filename) {
        $!filename = $filename;
    }

    method Load($filename) {
        $!filename = $filename;
        
        my $file = open $!filename;
        for $file.lines -> $line {
            my ($date, @ids) = $line.words;
            for @ids -> $i {
                @!latest-practice[$i] = $date;
            }
        }
        $file.close;
        
        self.Sort;
    }
    
    method LatestPractice($id) {
        @!latest-practice[$id] // "1900-01-01";
    }
    
    method Sort() {
        my @ids = (0..+@!latest-practice).grep({ @!latest-practice[$_] });
        @!sorted-ids = @ids.sort({ @!latest-practice[$^a] leg @!latest-practice[$^b] });
    }
    
    method Older($percentage) {
        my $range = (+@!sorted-ids * ($percentage / 100)).Int;
        @!sorted-ids[0..^$range];
    }
    
    method Record($date, @ids) {
        for @ids -> $i {
            @!latest-practice[$i] = $date;
        }
        
        my $file = open $!filename, :a;
        $file.say: ($date, @ids).join(" ");
        $file.close;
        
        self.Sort;
    }
}