class PracticeDates {
    has $!filename;
    has @!latest-practice;
    has @!sorted-ids;
    
    method SetFilename($filename) {
        $!filename = $filename;
    }
    
    method LatestPractice($id) {
        @!latest-practice[$id] // "1900-01-01";
    }
    
    method Sort() {
        @!sorted-ids = (1..+@!sorted-ids).sort({ @!latest-practice[$^a] <=> @!latest-practice[$^b] });
    }
    
    method Load($filename) {
        my $file = open $filename;
        for $file.lines -> $line {
            my ($date, @ids) = $line.comb;
            @!latest-practice[@ids] = $date;
        }
    }
    
    method Record($date, @ids) {
        say $!filename;
        for @ids -> $i {
            @!latest-practice[$i] = $date;
        }
        
        my $file = open $!filename, :a;
        $file.say: ($date, @ids).join(" ");
        $file.close;
        
        self.Sort;
    }
}