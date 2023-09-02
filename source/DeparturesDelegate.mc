//
// Copyright 2016-2021 by Garmin Ltd. or its subsidiaries.
// Subject to Garmin SDK License Agreement and Wearables
// Application Developer Agreement.
//

import Toybox.Communications;
import Toybox.Lang;
import Toybox.WatchUi;

//! Creates a web request on menu / select events
class DeparturesDelegate extends WatchUi.BehaviorDelegate {
    private var _notify as Method(args as Dictionary or String or Null) as Void;

    //! Set up the callback to the view
    //! @param handler Callback method for when data is received
    public function initialize(handler as Method(args as Dictionary or String or Null) as Void) {
        WatchUi.BehaviorDelegate.initialize();
        _notify = handler;
    }

    //! Make the web request
    public function makeRequest(limit as String, busStop as BusStop, showDepartures as Number) as Void {
        //var paramsId = "?filter=routeHeadingOnce&limit="+limit;
        var paramsId = "?limit="+limit;
        if(showDepartures > 1) {
            paramsId += "&aswIds[]="+busStop._aswId;
        }
        else {
            for(var i = 0; i < busStop._ids.size(); i++) {
                paramsId += "&ids[]=" + busStop._ids[i];
            }
        }

        var options = {
            :responseType => Communications.HTTP_RESPONSE_CONTENT_TYPE_JSON,
            :headers => {
                "Content-Type" => Communications.REQUEST_CONTENT_TYPE_URL_ENCODED,
                "X-Access-Token" => $.API_KEY
            }
        };

        Communications.makeWebRequest(
            "https://api.golemio.cz/v2/pid/departureboards" + paramsId,
            null,
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
            _notify.invoke("Failed to load\nError: " + responseCode.toString());
        }
    }
}