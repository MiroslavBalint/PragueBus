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
}

class BusStop {
    var _name as String;
    var _lat as Double;
    var _lon as Double;
    var _dist as Number;
    var _departures as Array<Departure> or Null;
    var _i as Number;
    var _max as Number;

    function initialize(name, lat, lon, dist) {
        _name = name;
        _lat = lat;
        _lon = lon;
        _dist = dist;
        _departures = null;
        _i = 0;
        _max = 0;
    }
}