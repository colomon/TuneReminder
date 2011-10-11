use Tunes;

# Main documentation: http://docs.go-mono.com, particularly
# Gnome (for Gdk and Gtk) and Mono (for Cairo) libraries.
# See also: The X-Windows Disaster at http://www.art.net/~hopkins/Don/unix-haters/handbook.html

my $tunes = Tunes.new;
$tunes.Load("t/test-data");

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
constant Button           = CLR::("Gtk.Button,$GTK");
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

my $button = CheckButton.new("My Button");
$button.add_Clicked(&DeleteEvent);
# $window.Add($button);

my $view = CreateTreeAndView($tunes, [0, 2, 1]);

$window.Add($view);

# my $drawingarea = GtkDrawingArea.new;
# $drawingarea.add_ExposeEvent(&ExposeEvent);
$window.add_DeleteEvent(&DeleteEvent);
# $window.Add($drawingarea);
$window.ShowAll;
Application.Run;  # end of main program, it's all over when this returns

sub CreateTree($tunes, @elements) {
    my $store = ListStore.new($G_TYPE_INT, $G_TYPE_BOOLEAN, $G_TYPE_STRING, $G_TYPE_STRING, $G_TYPE_STRING);
    for @elements -> $id {
        my $iter = $store.Append;
        $store.SetValue($iter, 0, $id);
        $store.SetValue($iter, 1, Bool::False);
        $store.SetValue($iter, 2, $tunes.GetTuneName($id));
        $store.SetValue($iter, 3, $tunes.GetTuneSnippet($id));
        $store.SetValue($iter, 4, $tunes.GetTuneComment($id));
    }
    $store;
}

sub CreateView($model) {
    sub DoneToggled($, $path) {
        my $iter = TreeIter.Zero;
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
    $view;
}

sub DeleteEvent($obj, $args) {  #OK not used
    Application.Quit;
};

# sub ExposeEvent($obj, $args)
# {
#     $args;  # suppress "declared but not used" "Potential difficulties"
#     my $cc = GdkCairoHelper.Create($obj.GdkWindow);  # Cairo Context
#     my $windowX=0; my $windowY=0; my $windowWidth=0; my $windowHeight=0; my $windowDepth=0;
#     $obj.GdkWindow.GetGeometry($windowX, $windowY, $windowWidth, $windowHeight, $windowDepth);
#     $cc.SetSourceRGB(0.6, 1, 0.6); $cc.Paint;  # pale green background
#     # Start the recursive drawing process
#     my $x0=0; my $y0=0; my  $x1=$windowWidth-1; my $y1=$windowHeight/2;
#     my $x2=0; my $y2=$windowHeight-1;
#     my $depth = Sierpinski($cc, $x0, $y0, $x1, $y1, $x2, $y2, True, 1);
#     my $text = sprintf("%d x %d, %d levels", $windowWidth, $windowHeight, $depth);
#     $cc.SetSourceRGB(0.6, 0.6, 1);  # pale blue
#     $cc.SetFontSize($windowWidth * 0.07);
#     my $textWidth  = $cc.TextExtents($text).Width;
#     my $textHeight = $cc.TextExtents($text).Height;
#     $cc.MoveTo($windowWidth*0.98 - $textWidth, $windowHeight*0.01 + $textHeight);
#     $cc.ShowText($text);
#     $cc.Target.Dispose;
#     $cc.dispose-hack; # Should be $cc.Dispose but CLR interop cannot call that
#     # Tracked as https://github.com/sorear/niecza/issues/56
# };
