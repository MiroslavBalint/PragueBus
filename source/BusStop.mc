import Toybox.Lang;

class Departure {
    var _type as String;
    var _name as String;
    var _headSign as String;
    var _time as String;

    function initialize(type, name, headSign, time) {
        _type = type;
        _name = name;
        _headSign = headSign;
        _time = time;
    }

    function isEmpty() {
        return _time.length() == 0;
    }
}

class BusStop {
    var _name as String;
    var _ids as Array<String>;
    var _aswId as String;
    var _lat as Double;
    var _lon as Double;
    var _dist as Number;
    var _departures as Array<Departure> or Null;
    var _i as Number;
    var _max as Number;

    function haveId(id as String) {
        for(var i = 0; i < _ids.size(); i++) {
            if(id.equals(_ids[i])) {
                return true;
            }
        }

        return false;
    }

    function getAswId(id as String) {
        var start = id.find("U");
        var stop = id.find("Z");
        var aswId = "";
        if(start != null && stop != null) {
            aswId = id.substring(start + 1, stop);
        }

        return aswId;
    }

    function addTrainPlatform() {
        var stop = _ids[0].find("Z");
        if(stop != null) {
            _ids.add(_ids[0].substring(0, stop + 1) + "301");
        }
    }

    function initialize(name, lat, lon, dist, id) {
        _name = name;
        _ids = [];
        _ids.add(id);
        _lat = lat;
        _lon = lon;
        _dist = dist;
        _departures = null;
        _i = 0;
        _max = 0;
        _aswId = getAswId(_ids[0]);
    }
}