class Tunes {
    class TuneRecord {
        has $.id;
        has $.name;
        has $.snippet;
        has $.comment;

        multi method new($id, $name, $snippet, $comment?) {
            self.bless(*, :$id, :$name, :$snippet, :$comment);
        }
    }
    
    has @!tunes;

    method AddTune($name, $snippet, $comment?) {
        my $id = +@!tunes;
        my $record = TuneRecord.new($id, $name, $snippet, $comment);
        @!tunes[$id] = $record;
        $id;
    }
    
    method GetTuneName($id)    { @!tunes[$id].name; }
    method GetTuneSnippet($id) { @!tunes[$id].snippet; }
    method GetTuneComment($id) { @!tunes[$id].comment; }
    
    method Save($filename) {
        my $count = 0;
        my $file = open($filename, :w);
        for @!tunes.kv -> $id, $tune {
            $file.say: ($id, $tune.name, $tune.snippet, $tune.comment // "").join(" » ");
            $count++;
        }
        $file.close;
        $count;
    }
    
    method Load($filename) {
        my $count = 0;
        my $file = open($filename);
        for $file.lines -> $line {
            my ($id, $name, $snippet, $comment) = $line.split(" » ");
            @!tunes[$id] = TuneRecord.new($id, $name, $snippet, $comment);
            $count++;
        }
        $file.close;
        $count;
    }
}

