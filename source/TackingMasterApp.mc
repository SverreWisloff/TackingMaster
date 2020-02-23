using Toybox.Application;
using Toybox.WatchUi;
using Toybox.System as System;
using Toybox.Application as App;

class TackingMasterApp extends Application.AppBase {

    function initialize() {
        AppBase.initialize();
    }

    // onStart() is called on application start up
    function onStart(state) {
        System.println("TackingMasterView.onUpdate");

		// read our settings
		var WindDirection;
		WindDirection = Application.getApp().getProperty("WindDirection1");
		if (WindDirection==null){
			WindDirection = 180;
		}
     
    }

    // onStop() is called when your application is exiting
    function onStop(state) {
    	// Save settings to next time
		var WindDirection = Application.Storage.getValue("WindDirection");
		Application.getApp().setProperty("WindDirection1", WindDirection);
    }

    // Return the initial view of your application here
    function getInitialView() {
        return [ new TackingMasterView(), new TackingMasterDelegate() ];
    }

}
