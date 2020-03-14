using Toybox.Application;
using Toybox.WatchUi;
using Toybox.System as System;
using Toybox.Application as App;
using Toybox.Position as Position;

//Main master-class
class TackingMasterApp extends Application.AppBase {

	var m_TackingMasterView;
	var m_TackingMasterDelegate;
	var m_bDrawPolarCogPlot;

    function initialize() {
        AppBase.initialize();
    }

    // onStart() is called on application start up 
    function onStart(state) {
//        System.println("TackingMasterView.onUpdate"); 

        //Start GPS
        Position.enableLocationEvents( Position.LOCATION_CONTINUOUS, method(:onPosition) );

		// read our settings
		var WindDirection;
		WindDirection = Application.getApp().getProperty("WindDirection_prop");
		if (WindDirection==null){
			WindDirection = 180;
		}

		m_bDrawPolarCogPlot = Application.getApp().getProperty("DrawPolarCogPlot_prop");
		if (m_bDrawPolarCogPlot==null){
			m_bDrawPolarCogPlot = false;
		}
        System.println("TackingMasterView.onUpdate() - m_bDrawPolarCogPlot=" + m_bDrawPolarCogPlot); 
     
    }

    // onStop() is called when your application is exiting
    function onStop(state) {

        //Stop GPS
        Position.enableLocationEvents(Position.LOCATION_DISABLE, method(:onPosition));

    	// Save settings to next time
		var WindDirection = Application.Storage.getValue("WindDirection");
		Application.getApp().setProperty("WindDirection_prop", WindDirection);

		var bDrawPolarCogPlot = Application.Storage.getValue("DrawPolarCogPlot");
		Application.getApp().setProperty("WindDirection_prop", bDrawPolarCogPlot);
        System.println("TackingMasterView.onStop() - bDrawPolarCogPlot=" + bDrawPolarCogPlot); 

    }

    function onPosition(info) { 
        m_TackingMasterView.setPosition(info);
    }
	
    // Return the initial view of your application here
    function getInitialView() {
		m_TackingMasterView = new TackingMasterView();
		m_TackingMasterDelegate = new TackingMasterDelegate();

        m_TackingMasterView.m_bDrawPolarCogPlot = m_TackingMasterView;
        
        return [ m_TackingMasterView, m_TackingMasterDelegate ];
    }

}
