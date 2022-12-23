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
    private var _notify as Method(clickUp as Boolean) as Boolean;

    //! Constructor
    public function initialize(handler as Method(clickUp as Boolean) as Boolean) {
        BehaviorDelegate.initialize();
        _notify = handler;
    }

    public function onTap(clickEvent) as Boolean {
        _notify.invoke((clickEvent.getCoordinates()[1]) < (System.getDeviceSettings().screenHeight / 2));
        return true;
    }

    //! Handle a physical button being pressed and released
    //! @param evt The key event that occurred
    //! @return true if handled, false otherwise
    public function onKeyReleased(evt as KeyEvent) as Boolean {
        var key = evt.getKey();
        switch(key)
        {
            case KEY_UP:
                _notify.invoke(true);
                break;
            
            case KEY_DOWN:
                _notify.invoke(false);
                break;

            case KEY_ENTER:
                _notify.invoke(true);
                break;
        }
        return false;
    }
}
