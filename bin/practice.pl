use Tunes;
use PracticeDates;

my $filename = "sol-tunes";

# Main documentation: http://docs.go-mono.com, particularly
# Gnome (for Gdk and Gtk) and Mono (for Cairo) libraries.
# See also: The X-Windows Disaster at http://www.art.net/~hopkins/Don/unix-haters/handbook.html

my $tunes = Tunes.new;
$tunes.Load($filename);
my $practice-dates = PracticeDates.new;
$practice-dates.Load($filename ~ ".dates");

constant $GTK  = "gtk-sharp, Version=2.12.0.0, Culture=neutral, PublicKeyToken=35e10195dab3c99f";
# constant $GDK  = "gdk-sharp, Version=2.12.0.0, Culture=neutral, PublicKeyToken=35e10195dab3c99f";
constant $GLIB = "glib-sharp, Version=2.12.0.0, Culture=neutral, PublicKeyToken=35e10195dab3c99f";
# use 'gacutil -l' to look up similar module details

constant $G_TYPE_STRING = CLR::("GLib.GType,$GLIB").String;
constant $G_TYPE_INT = CLR::("GLib.GType,$GLIB").Int;
constant $G_TYPE_BOOLEAN = CLR::("GLib.GType,$GLIB").Boolean;

constant Application      = CLR::("Gtk.Application,$GTK");
constant Window           = CLR::("Gtk.Window,$GTK");
constant Box              = CLR::("Gtk.Box,$GTK");
constant VBox             = CLR::("Gtk.VBox,$GTK");
constant Button           = CLR::("Gtk.Button,$GTK");
constant HButtonBox       = CLR::("Gtk.HButtonBox,$GTK");
constant CheckButton      = CLR::("Gtk.CheckButton,$GTK");
constant TreeView         = CLR::("Gtk.TreeView,$GTK");
constant TreeViewColumn   = CLR::("Gtk.TreeViewColumn,$GTK");
constant TreeIter         = CLR::("Gtk.TreeIter,$GTK");
constant ListStore        = CLR::("Gtk.ListStore,$GTK");
constant CellRenderer     = CLR::("Gtk.CellRenderer,$GTK");
constant CellRendererText = CLR::("Gtk.CellRendererText,$GTK");
constant CellRendererToggle = CLR::("Gtk.CellRendererToggle,$GTK");
# constant GdkCairoHelper = CLR::("Gdk.CairoHelper,$GDK");
constant GtkDrawingArea   = CLR::("Gtk.DrawingArea,$GTK");

Application.Init;
my $window = Window.new("Tune Reminder");
my $windowSizeX = 640; my $windowSizeY = 560;
$window.Resize($windowSizeX, $windowSizeY);  # TODO: resize at runtime NYI

my $vbox = VBox.new(False, 4);
my ($model, $view) = CreateTreeAndView($tunes, $practice-dates.Older(50).pick(10));
$vbox.Add($view);

my $hbb = HButtonBox.new;
my $refresh_button = Button.new("Refresh");
$refresh_button.add_Clicked(&RefreshEvent);
$hbb.Add($refresh_button);
my $exit_button = Button.new("Exit");
$exit_button.add_Clicked(&DeleteEvent);
$hbb.Add($exit_button);
$vbox.Add($hbb);
$window.Add($vbox);

$window.add_DeleteEvent(&DeleteEvent);
$window.ShowAll;
Application.Run;  # end of main program, it's all over when this returns

sub CreateTree($tunes, @elements) {
    my $store = ListStore.new($G_TYPE_INT, $G_TYPE_BOOLEAN, $G_TYPE_STRING, $G_TYPE_STRING, $G_TYPE_STRING);
    AddTunesToListStore($store, $tunes, @elements);
    $store;
}

sub AddTunesToListStore($store, $tunes, @elements) {
    for @elements -> $id {
        my $iter = $store.Append;
        $store.SetValue($iter, 0, $id);
        $store.SetValue($iter, 1, Bool::False);
        $store.SetValue($iter, 2, $tunes.GetTuneName($id));
        $store.SetValue($iter, 3, $tunes.GetTuneSnippet($id));
        $store.SetValue($iter, 4, $tunes.GetTuneComment($id));
    }
}

sub CreateView($model) {
    sub DoneToggled($renderer, $path) { #OK not used
        my $iter = TreeIter.default;
        $model.GetIterFromString($iter, $path.Path);
        my $value = $model.GetValue($iter, 1);
        $model.SetValue($iter, 1, $value.Equals(False));
    }

    my $view = TreeView.new($model);

    {
        my $renderer = CellRendererToggle.new;
        $renderer.add_Toggled(&DoneToggled);
        my $column = TreeViewColumn.new("Done", $renderer);
        $column.AddAttribute($renderer, "active", 1);
        $view.AppendColumn($column);
    }
    
    my @titles = <Tune Snippet Comment>;
    for @titles.kv -> $i, $title {
        my $renderer = CellRendererText.new;
        my $column = TreeViewColumn.new($title, $renderer);
        $column.AddAttribute($renderer, "text", $i + 2);
        $view.AppendColumn($column);
    }
    $view;
}

sub CreateTreeAndView($tunes, @elements) {
    my $model = CreateTree($tunes, @elements);
    my $view = CreateView($model);
    $model, $view;
}

sub DateStamp() {
    sprintf("%04d-%02d-%02d", 
            CLR::("System.DateTime").Now.Year,
            CLR::("System.DateTime").Now.Month,
            CLR::("System.DateTime").Now.Day);
}

sub ReportPraticed() {
    my $iter = TreeIter.default;
    my @ids;
    $model.GetIterFirst($iter);
    if $model.GetValue($iter, 1).Equals(True) {
        @ids.push($model.GetValue($iter, 0));
    }
    while ($model.IterNext($iter)) {
        if $model.GetValue($iter, 1).Equals(True) {
            @ids.push($model.GetValue($iter, 0));
        }
    }
    
    if +@ids {
        $practice-dates.Record(DateStamp(), @ids.map({ +($_.ToString) }));
    }
    # say DateStamp() ~ " " ~ @ids.join(" ");
}

sub DeletePraticed() {
    my $iter = TreeIter.default;
    $model.GetIterFirst($iter);
    
    my $count = 0;
    while $model.IterIsValid($iter) {
        if $model.GetValue($iter, 1).Equals(True) {
            $count++;
            $model.Remove($iter);
        } else {
            $model.IterNext($iter);
        }
    }
    $count;
}

sub RefreshEvent($obj, $args) {  #OK not used
    ReportPraticed;
    my $count = DeletePraticed;
    if $count {
        AddTunesToListStore($model, $tunes, $practice-dates.Older(50).pick($count));
    }
}

sub DeleteEvent($obj, $args) {  #OK not used
    ReportPraticed;
    Application.Quit;
};
