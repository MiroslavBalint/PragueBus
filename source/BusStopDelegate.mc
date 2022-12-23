//
// Copyright 2016-2021 by Garmin Ltd. or its subsidiaries.
// Subject to Garmin SDK License Agreement and Wearables
// Application Developer Agreement.
//

import Toybox.Communications;
import Toybox.Lang;
import Toybox.WatchUi;
import Toybox.Position;

//! Creates a web request on menu / select events
class BusStopDelegate extends WatchUi.BehaviorDelegate {
    private var _notify as Method(args as Dictionary or String or Null) as Void;

    //! Set up the callback to the view
    //! @param handler Callback method for when data is received
    public function initialize(handler as Method(args as Dictionary or String or Null) as Void) {
        WatchUi.BehaviorDelegate.initialize();
        _notify = handler;
    }

    //! On a menu event, make a web request
    //! @return true if handled, false otherwise
    public function onMenu() as Boolean {
        return true;
    }

    //! On a select event, make a web request
    //! @return true if handled, false otherwise
    public function onSelect() as Boolean {
        return true;
    }

    //! Make the web request
    public function makeRequest(pos as Location, around as Number) as Void {
        var options = {
            //:responseType => Communications.HTTP_RESPONSE_CONTENT_TYPE_TEXT_PLAIN,
            :responseType => Communications.HTTP_RESPONSE_CONTENT_TYPE_JSON,
            :headers => {
                "Content-Type" => Communications.REQUEST_CONTENT_TYPE_URL_ENCODED
            }
        };

        // TODO: csv use less data, but as now it is not working on my garmin device.
        // var params = {
        //     "data" => "[out:csv('name',::lat,::lon;false;'|')];node(around:"+around.toString()+","+pos.toDegrees()[0].toString()+","+pos.toDegrees()[1].toString()+")['public_transport'='platform'];out;"
        // };

        var params = {
            "data" => "[out:json];node(around:"+around.toString()+","+pos.toDegrees()[0].toString()+","+pos.toDegrees()[1].toString()+")['public_transport'='platform'];out;"
        };

        Communications.makeWebRequest(
            "https://overpass.kumi.systems/api/interpreter",
            params,
            options,
            method(:onReceive)
        );
    }

    //! Receive the data from the web request
    //! @param responseCode The server response code
    //! @param data Content from a successful request
    public function onReceive(responseCode as Number, data as Null or Dictionary or String) as Void {
        if (responseCode == 200) {
            _notify.invoke(data);
        } else {
            _notify.invoke("Error: " + responseCode.toString());
        }
    }
}