import Toybox.Application;
import Toybox.Application.Storage;
import Toybox.Lang;
import Toybox.Position;
import Toybox.WatchUi;
import Toybox.System;
import Toybox.Timer;
import Toybox.Activity;

class PragueBusApp extends Application.AppBase {

    private var _pragueBusView as PragueBusView;
    private var _busStopDelegate as BusStopDelegate;
    private var _departuresDelegate as DeparturesDelegate;
    private var _busStopPositions as Array<BusStop>;
    private var _index as Number;
    private var _pos as Position.Location or Null;
    private var _accuracy as Number;
    private var _departureStartIndex as Number;
    private var _timer;
    private var _refreshSeconds as Number;
    private var _showDepartures as Number;

    function initialize() {
        AppBase.initialize();
        _pragueBusView = new $.PragueBusView();
        _busStopDelegate = new $.BusStopDelegate(method(:onReceive));
        _departuresDelegate = new $.DeparturesDelegate(method(:onReceiveDepartures));
        _index = 0;
        _busStopPositions = [];
        _departureStartIndex = 0;
        _refreshSeconds = Properties.getValue("refreshSeconds_prop").toNumber();
        _showDepartures = Properties.getValue("showDepartures_prop").toNumber();
        _timer = new Timer.Timer();
        _accuracy = 0;
        _pos = null;
    }

    // onStart() is called on application start up
    function onStart(state as Dictionary?) as Void {
        if(!System.getDeviceSettings().phoneConnected) {
            _pragueBusView.setText(["Phone not connected"]);
            return;
        }
        _pragueBusView.setText(["Wait for location","Tap from weather"]);
        if(Properties.getValue("useWeatherPosition_prop")) {
            onPosition(Weather.getCurrentConditions().observationLocationPosition, 9);
        }
        else {
            var info = Activity.getActivityInfo();
            if(info != null) {
                _pos = info.currentLocation;
            }
            if(_pos != null) {
                onPosition(_pos, info.currentLocationAccuracy);
            }
        else {
            Position.enableLocationEvents( Position.LOCATION_ONE_SHOT, method(:onPositionInfo));
        }
    }
}

    // onStop() is called when your application is exiting
    function onStop(state as Dictionary?) as Void {
        Position.enableLocationEvents(Position.LOCATION_DISABLE, method(:onPositionInfo));
        _timer.stop();
    }

    public function onPosition(pos as Position.Location, accuracy as Position.Quality or Number) {
        _pos = pos;
        _accuracy = accuracy.toNumber();
        _busStopDelegate.makeRequest(_pos, Properties.getValue("aroundMeters_prop").toNumber());
    }

    //! Update the current position
    //! @param info Position information
    public function onPositionInfo(info as Position.Info) as Void {
        onPosition(info.position, info.accuracy);
    }

    public function getInfo() {
        if(_busStopPositions.size() == 0) {
            return;
        }

        var currStop = _busStopPositions[_index];
        _departuresDelegate.makeRequest(Properties.getValue("maxDepartures_prop").toString(), currStop, _showDepartures);
        _pragueBusView.setInfo(currStop, _departureStartIndex);
    }

    function degrees_to_radians(deg) {
        return deg * Math.PI / 180;
    }

    function Geodetic_distance_deg(lat1, lon1, lat2, lon2) {
        lat1 = degrees_to_radians(lat1);
        lon1 = degrees_to_radians(lon1);
        lat2 = degrees_to_radians(lat2);
        lon2 = degrees_to_radians(lon2);

        return Geodetic_distance_rad(lat1, lon1, lat2, lon2);
    }

    function Geodetic_distance_rad(lat1, lon1, lat2, lon2) {
        var dy = (lat2-lat1);
        var dx = (lon2-lon1);

        var sy = Math.sin(dy / 2);
        sy *= sy;

        var sx = Math.sin(dx / 2);
        sx *= sx;

        var a = sy + Math.cos(lat1) * Math.cos(lat2) * sx;

        // you'll have to implement atan2
        var c = 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1-a));

        var R = 6371000; // radius of earth in meters
        return R * c;
    }

    public function split(str as String, delim as Char) as Array<String> {
        var arr = [] as Array<String>;
        while(str.find(delim.toString()) != null)
        {
            var pos = str.find(delim.toString());
            if(pos == 0)
            {
                str = str.substring(1, str.length());
            }
            else
            {
                arr.add(str.substring(0, pos));
                str = str.substring(pos, str.length());
            }
        }
        arr.add(str);
        return arr;
    }

    private function busStopExists(s as String) as Boolean {
        for(var i = 0; i < _busStopPositions.size(); i++) {
            if(_busStopPositions[i]._name == s) {
                return true;
            }
        }
        return false;
    }

    public function compareByDist(a, b) as Boolean {
        return a._dist > b._dist;
    }

    // A function to implement bubble sort
    function bubbleSort(arr as Array, compare) {
        var n = arr.size();
        for (var i = 0; i < n - 1; i++) {
            // Last i elements are already in place
            for (var j = 0; j < n - i - 1; j++) {
                if (compare.invoke(arr[j], arr[j + 1])) {
                    var tmp = arr[j + 1];
                    arr[j + 1] = arr[j];
                    arr[j] = tmp;
                }
            }
        }
    }

    private function addBusStop(name, lat, lon, id) {
        if(id == null) {
            return;
        }
        
        if(_showDepartures > 0) {
            for(var i = 0; i < _busStopPositions.size(); i++) {
                if(_busStopPositions[i]._name == name) {
                    _busStopPositions[i]._ids.add(id);
                    return;
                }
            }
        }

        if(_busStopPositions.size() < 20) {
            var dist = Math.round(Geodetic_distance_deg(_pos.toDegrees()[0], _pos.toDegrees()[1], lat, lon)).toNumber();
            var busStop = new $.BusStop(name, lat, lon, dist, id);
            if(_showDepartures > 0) {
                busStop.addTrainPlatform();
            }
            _busStopPositions.add(busStop);
        }
    }

    //! Show the result or status of the web request
    //! @param args Data from the web request, or error message
    public function onReceive(args as Dictionary or String or Null) as Void {
        if(args instanceof Dictionary)
        {
            for(var i = 0; i < args["elements"].size(); i++) {
                var elements = args["elements"] as Array<Dictionary>;
                var busStop = elements[i] as Dictionary;
                var busStopTag = busStop["tags"] as Dictionary;
                addBusStop(busStopTag["name"].toString(), busStop["lat"].toDouble(), busStop["lon"].toDouble(), busStopTag["ref:PID"].toString());
            }
        }

        if(_busStopPositions.size() == 0) {
            _pragueBusView.setText(["Not found", _pos.toDegrees()[0].toString(), _pos.toDegrees()[1].toString(), _accuracy.toString()]);
        }
        else {
            bubbleSort(_busStopPositions, method(:compareByDist));
            for(var i = 0; i < _busStopPositions.size(); i++) {
                _busStopPositions[i]._i = i + 1;
                _busStopPositions[i]._max = _busStopPositions.size();
            }
            getInfo();
            
            if(_refreshSeconds > 0) {
                _timer.start(method(:getInfo), _refreshSeconds * 1000, true);
            }
        }
    }

    private function typeToString(type as Number) as String {
        switch(type) {
            case 0:
                return "TRAM";

            case 1:
                return "METRO";

            case 2:
                return "TRAIN";

            case 3:
                return "BUS";

            case 4:
                return "FERRY";

            case 7:
                return "FUNICULAR";

            case 11:
                return "TROLEYBUS";
        }

        return "";
    }

    //! Show the result or status of the web request
    //! @param args Data from the web request, or error message
    public function onReceiveDepartures(args as Dictionary or String or Null) as Void {
        if (args instanceof Dictionary) {
            // Print the arguments duplicated and returned by jsonplaceholder.typicode.com
            for(var i = 0; i < _busStopPositions.size(); i++) {
                var stops = args["stops"] as Array<Dictionary>;
                var departureAswId = stops[0]["asw_id"] as Dictionary;
                if(_busStopPositions[i]._aswId.equals(departureAswId["node"].toString())) {
                    _busStopPositions[i]._departures = [] as Array<Departure>;
                    var departures = args["departures"] as Array<Dictionary>;
                    for (var j = 0; j < departures.size(); j++) {
                        var d = departures[j] as Dictionary;
                        var route = d["route"] as Dictionary;
                        var trip = d["trip"] as Dictionary;
                        var departureTimestamp = d["departure_timestamp"] as Dictionary;
                        var dep = new $.Departure(typeToString(route["type"]), route["short_name"], trip["headsign"], departureTimestamp["minutes"]);
                        _busStopPositions[i]._departures.add(dep);
                    }

                    if(_busStopPositions[i]._departures.size() == 0) {
                        var dep = new $.Departure("", "", "", "");
                        _busStopPositions[i]._departures.add(dep);
                    }
                    
                    _pragueBusView.setInfo(_busStopPositions[_index], _departureStartIndex);
                    break;
                }
            }
        }
    }

    public function onSelect(clickUp as Boolean) as Boolean {
        if(!System.getDeviceSettings().phoneConnected) {
            return true;
        }

        if(_pos == null) {
            Position.enableLocationEvents(Position.LOCATION_DISABLE, method(:onPositionInfo));
            _pragueBusView.setText(["Use cached location"]);
            onPosition(Weather.getCurrentConditions().observationLocationPosition, 9);
            return true;
        }

        if(_busStopPositions.size() == 0) {
            return true;
        }

        if(clickUp) {
            _departureStartIndex = 0;
            _index = _index + 1;
            if(_index >= _busStopPositions.size()) {
                _index = 0;
            }
        }
        else {
            var dep = _busStopPositions[_index]._departures;
            if(dep != null && dep.size() > 0) {
                _departureStartIndex = _departureStartIndex + 3;
                if(_departureStartIndex >= dep.size()) {
                    _departureStartIndex = 0;
                }
            }
        }

        getInfo();
        return true;
    }

    // Return the initial view of your application here
    function getInitialView() as [Views] or [Views, InputDelegates] {
        var inputDelegate = new $.InputDelegate(method(:onSelect));
        return [ _pragueBusView, inputDelegate ];
    }

}

function getApp() as PragueBusApp {
    return Application.getApp() as PragueBusApp;
}