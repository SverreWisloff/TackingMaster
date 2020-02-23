using Toybox.WatchUi;
using Toybox.System as System;
using Toybox.Graphics;
using Toybox.Application as App;
using Toybox.Timer;
using Toybox.Position;
using Toybox.Math;

var screenShape;
//var m_WD; //Wind direction
var myCount =  0;
var m_TackAngle = 90;

function timerCallback() {
    myCount += 1;
    WatchUi.requestUpdate();
}

function reduse_deg(deg) {
	if (deg<0){
		deg += 360;
	}
	else if (deg>360){
		deg -= 360;
	}
	return deg;
}


class TackingMasterView extends WatchUi.View {

    function initialize() {
        View.initialize();
//        System.println("TackingMasterView.initialize");
        screenShape = System.getDeviceSettings().screenShape;

		// Get the WindDirection from the settings-storage
        var app = App.getApp();
        var WindDirection = Application.Storage.getValue("WindDirection");
        if (WindDirection==null){WindDirection=100;}
        Application.Storage.setValue("WindDirection", WindDirection);
//        System.println("TackingMasterView.initialize - WindDirection=" + WindDirection);
    }

    //=====================
    // Load your resources here
    //=====================
    function onLayout(dc) {
        setLayout(Rez.Layouts.MainLayout(dc));

		// Create a counter that increments by one each second
		var myTimer = new Timer.Timer();
		myTimer.start(method(:timerCallback), 1000, true);

    }

    //=====================
    // Called when this View is brought to the foreground. Restore
    // the state of this View and prepare it to be shown. This includes
    // loading resources into memory.
    //=====================
    function onShow() {
    }

    //=====================
    // Update the view
    //=====================
    function onUpdate(dc) {
        // Call the parent onUpdate function to redraw the layout
        //System.println("TackingMasterView.onUpdate");
        View.onUpdate(dc);
        
		// Draw the tick marks around the edges of the screen
        drawHashMarks(dc);

		// Draw laylines
		dc.setColor(Graphics.COLOR_BLUE, Graphics.COLOR_TRANSPARENT);
		dc.setPenWidth(2);
		dc.drawLine(dc.getHeight()/2, dc.getWidth()/2, 0, 0);
		dc.drawLine(dc.getHeight()/2, dc.getWidth()/2, dc.getHeight(), 0 );
        
		// Get Wind-dir
        var WindDirection = Application.Storage.getValue("WindDirection");
        WindDirection = Math.round(WindDirection);
        WindDirection = reduse_deg(WindDirection.toLong());
        var StarboardCloseDir = reduse_deg(WindDirection + (m_TackAngle/2) );
        var PortCloseDir = reduse_deg(WindDirection - (m_TackAngle/2) );

        // Draw North arrow
        drawNorth(dc, WindDirection);
        
		// Find COG & SOG
		var positionInfo = Position.getInfo();
		var COG_deg = 888;
		var Speed_kn = 888;
		if(positionInfo.heading!=null){
			COG_deg = reduse_deg((positionInfo.heading)/Math.PI*180);
		}
		if(positionInfo.speed!=null){
			Speed_kn = positionInfo.speed * 1.9438444924406;
		}

		// Draw wind directions
        dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_BLACK);
        dc.drawText(dc.getWidth()/2, dc.getHeight()/2-110, Graphics.FONT_TINY, WindDirection, Graphics.TEXT_JUSTIFY_CENTER);
        dc.drawText(dc.getWidth()/6, dc.getHeight()/2-80, Graphics.FONT_TINY, PortCloseDir, Graphics.TEXT_JUSTIFY_LEFT);
        dc.drawText(dc.getWidth()/6*5, dc.getHeight()/2-80, Graphics.FONT_TINY, StarboardCloseDir, Graphics.TEXT_JUSTIFY_RIGHT);

        // Draw COG-circle
		drawCOG(dc, WindDirection, COG_deg);

		// Draw COG
        dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);
        dc.drawText(dc.getWidth()/2, dc.getHeight()/2+10, Graphics.FONT_TINY, COG_deg.toNumber() + " deg", Graphics.TEXT_JUSTIFY_CENTER);

		// Draw SOG
        dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);
        dc.drawText(dc.getWidth()/2, dc.getHeight()/2+40, Graphics.FONT_TINY, Speed_kn.format("%.1f") + " kn", Graphics.TEXT_JUSTIFY_CENTER);

		// Draw Time
		var myTime = System.getClockTime(); // ClockTime object
		var myTimeText = myTime.hour.format("%02d") + ":" + myTime.min.format("%02d") + ":" + myTime.sec.format("%02d");
        dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);
        dc.drawText(dc.getWidth()/2, dc.getHeight()/2+70, Graphics.FONT_XTINY, myTimeText, Graphics.TEXT_JUSTIFY_CENTER);
		
    }

    // Called when this View is removed from the screen. Save the
    // state of this View here. This includes freeing resources from
    // memory.
    function onHide() {
    }

    // Draws the clock tick marks around the outside edges of the screen.
    function drawHashMarks(dc) {
        var width = dc.getWidth();
        var height = dc.getHeight();

		dc.setColor(Graphics.COLOR_BLUE, Graphics.COLOR_TRANSPARENT);
		dc.setPenWidth(2);

        // Draw hashmarks differently depending on screen geometry.
        if (System.SCREEN_SHAPE_ROUND == screenShape) {
            var sX, sY;
            var eX, eY;
            var outerRad = width / 2;
            var innerRad = outerRad - 7;
            // Loop through each 15 minute block and draw tick marks.
            for (var i = 0; i < 2 * Math.PI ; i += (Math.PI / 48)) {
                sY = outerRad + innerRad * Math.sin(i);
                eY = outerRad + outerRad * Math.sin(i);
                sX = outerRad + innerRad * Math.cos(i);
                eX = outerRad + outerRad * Math.cos(i);
                dc.drawLine(sX, sY, eX, eY);
            }
        } else {
            var coords = [0, width / 4, (3 * width) / 4, width];
            for (var i = 0; i < coords.size(); i += 1) {
                var dx = ((width / 2.0) - coords[i]) / (height / 2.0);
                var upperX = coords[i] + (dx * 10);
                // Draw the upper hash marks.
                dc.fillPolygon([[coords[i] - 1, 2], [upperX - 1, 12], [upperX + 1, 12], [coords[i] + 1, 2]]);
                // Draw the lower hash marks.
                dc.fillPolygon([[coords[i] - 1, height-2], [upperX - 1, height - 12], [upperX + 1, height - 12], [coords[i] + 1, height - 2]]);
            }
        }
    }

    
    //=====================
    // Draws North
    //=====================
    function drawNorth(dc, WindDirection) {
        var width = dc.getWidth();
        var height = dc.getHeight();
    	dc.setColor(Graphics.COLOR_BLUE, Graphics.COLOR_TRANSPARENT);

		var i = -(WindDirection+90)/180.0 * Math.PI;
        var X = ((width/2)-20) * Math.cos(i);
        var Y = ((width/2)-20) * Math.sin(i);
		
//		System.println("drawNorth : WindDirection=" + WindDirection + " i="+i);
		
    	dc.drawText(X + (width/2), Y + (width/2) - 12, Graphics.FONT_TINY, "N", Graphics.TEXT_JUSTIFY_CENTER);
 		//12 = Halv font-høyde
    }

    //=====================
    // Draws COG
    //=====================
    function drawCOG(dc, WindDirection, COG) {
        var width = dc.getWidth();
        var height = dc.getHeight();
    	dc.setColor(Graphics.COLOR_RED, Graphics.COLOR_TRANSPARENT);

		var i = -(WindDirection+90-COG)/180.0 * Math.PI;
        var X = ((width/2)-8) * Math.cos(i);
        var Y = ((width/2)-8) * Math.sin(i);
		
//		System.println("drawNorth : WindDirection=" + WindDirection + " i="+i);
		
    	dc.fillCircle(X + (width/2), Y + (width/2), 8);

    }
}
