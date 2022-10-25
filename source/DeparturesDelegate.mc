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
    //public const API_KEY = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJlbWFpbCI6Im1pcm8uYmFsaW50QGdtYWlsLmNvbSIsImlkIjoxNDY1LCJuYW1lIjpudWxsLCJzdXJuYW1lIjpudWxsLCJpYXQiOjE2NjUwMDUwNTgsImV4cCI6MTE2NjUwMDUwNTgsImlzcyI6ImdvbGVtaW8iLCJqdGkiOiIyMjliODExYS1jYTBmLTRmNDEtODYyNi0wNTk5YjhmN2I5M2UifQ.pf9nev6hAAI0tc8ejAd70GJRuxpZ-3t5bKTHw_bwEaQ";

    //! Set up the callback to the view
    //! @param handler Callback method for when data is received
    public function initialize(handler as Method(args as Dictionary or String or Null) as Void) {
        WatchUi.BehaviorDelegate.initialize();
        _notify = handler;
    }

    //! Make the web request
    public function makeRequest(limit as String, name as String) as Void {
        var params = {
                "limit" => limit,
                "names[]" => name
        };

        var options = {
            :responseType => Communications.HTTP_RESPONSE_CONTENT_TYPE_JSON,
            :headers => {
                "Content-Type" => Communications.REQUEST_CONTENT_TYPE_URL_ENCODED,
                "X-Access-Token" => $.API_KEY
            }
        };

        Communications.makeWebRequest(
            "https://api.golemio.cz/v2/pid/departureboards",
            params,
            options,
            method(:onReceive)
        );
    }

    //! Receive the data from the web request
    //! @param responseCode The server response code
    //! @param data Content from a successful request
    public function onReceive(responseCode as Number, data as Dictionary?) as Void {
        if (responseCode == 200) {
            _notify.invoke(data);
        } else {
            _notify.invoke("Failed to load\nError: " + responseCode.toString());
        }
    }
}