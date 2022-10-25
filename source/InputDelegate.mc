//
// Copyright 2016-2021 by Garmin Ltd. or its subsidiaries.
// Subject to Garmin SDK License Agreement and Wearables
// Application Developer Agreement.
//

import Toybox.Lang;
import Toybox.System;
import Toybox.WatchUi;
import Toybox.Graphics;

//! Handles the behavior / input events
class InputDelegate extends WatchUi.BehaviorDelegate {
    private var _notify as Method() as Boolean;

    //! Constructor
    public function initialize(handler as Method() as Boolean) {
        BehaviorDelegate.initialize();
        _notify = handler;
    }

    public function onTap(clickEvent) as Boolean {
        _notify.invoke((clickEvent.getCoordinates()[1]) < (System.getDeviceSettings().screenHeight / 2));
        return true;
    }
}
