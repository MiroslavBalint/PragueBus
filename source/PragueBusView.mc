import Toybox.Lang;
import Toybox.Graphics;
import Toybox.Math;
import Toybox.WatchUi;

class PragueBusView extends WatchUi.View {

    private var _lines = [] as Array<String>;
    private var _drawTable as Boolean;

    function initialize() {
        View.initialize();
        _drawTable = false;
    }

    // Called when this View is brought to the foreground. Restore
    // the state of this View and prepare it to be shown. This includes
    // loading resources into memory.
    function onShow() as Void {
    }

    // Update the view
    function onUpdate(dc as Dc) as Void {
        // Call the parent onUpdate function to redraw the layout
        View.onUpdate(dc);
        // Set background color
        dc.setColor(Graphics.COLOR_TRANSPARENT, Graphics.COLOR_BLACK);
        dc.clear();
        dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);

        var x = dc.getWidth() / 2;
        var y = dc.getHeight() / 2;

        var font = Graphics.FONT_SMALL;
        var textHeight = dc.getFontHeight(font);

        y -= (_lines.size() * textHeight) / 2;

        if(_drawTable) {
            for(var yy = y; yy < dc.getHeight(); yy += 2 * textHeight) {
                dc.drawLine(0, yy, dc.getWidth(), yy);
            }
        }

        for (var i = 0; i < _lines.size(); ++i) {
            dc.drawText(x, y, Graphics.FONT_SMALL, _lines[i], Graphics.TEXT_JUSTIFY_CENTER);
            y += textHeight;
        }
    }

    public function setText(t as Array<String>) {
        _drawTable = false;
        _lines = t;
        WatchUi.requestUpdate();
    }

    private function min(a, b) as Number {
        if(a < b) {
            return a;
        }
        else {
            return b;
        }
    } 

    //! Show the result or status of the web request
    //! @param args Data from the web request, or error message
    public function setInfo(info as BusStop, start as Number) as Void {
        _drawTable = true;
        _lines = [] as Array<String>;
        // Print the arguments duplicated and returned by jsonplaceholder.typicode.com
        _lines.add(info._dist + " m " + info._i + "/" + info._max);
        _lines.add(info._name);
        if(info._departures != null) {
            for(var i = start; i < min(start + 3, info._departures.size()); i++) {
                var d = info._departures[i];
                _lines.add(d._time + " min " + d._type + " " + d._name);
                _lines.add(d._headSign);
            }
        }

        while(_lines.size() < 8) {
            _lines.add("");
        }
        WatchUi.requestUpdate();
    }

    // Called when this View is removed from the screen. Save the
    // state of this View here. This includes freeing resources from
    // memory.
    function onHide() as Void {
    }

}
