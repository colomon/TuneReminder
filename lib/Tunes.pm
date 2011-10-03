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
}

