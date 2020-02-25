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
var m_posnInfo = null;
var m_width;
var m_height;


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

    function setPosition(info) {
        m_posnInfo = info;
        WatchUi.requestUpdate();
    }
    //=====================
    // Update the view
    //=====================
    function onUpdate(dc) {
        m_width = dc.getWidth();
        m_height = dc.getHeight();

        // Call the parent onUpdate function to redraw the layout
        //System.println("TackingMasterView.onUpdate");
        View.onUpdate(dc);
        
		// Get Wind-dir
        var WindDirection = Application.Storage.getValue("WindDirection");
        WindDirection = Math.round(WindDirection);
        WindDirection = reduse_deg(WindDirection.toLong());
        var StarboardCloseDir = reduse_deg(WindDirection + (m_TackAngle/2) );
        var PortCloseDir = reduse_deg(WindDirection - (m_TackAngle/2) );
        
 		// Get COG & SOG
		//var positionInfo = Position.getInfo();
		var COG_deg;
		var Speed_kn;
		if(m_posnInfo!=null	){ 
			COG_deg = reduse_deg((m_posnInfo.heading)/Math.PI*180);
		}
		else{
			COG_deg = 0;
		}
		if(m_posnInfo!=null){
			Speed_kn = m_posnInfo.speed * 1.9438444924406;
		}
		else {
			Speed_kn = 0;
		}
/*        if (m_posnInfo!=null){
        	var acc=0;
        	acc = m_posnInfo.accuracy;
        	System.println("TackingMasterView.onUpdate");
        	System.println("setPosition : accuracy=" + acc );
        	Position.QUALITY_GOOD
        }
*/
        // Draw the tick marks around the edges of the screen
        drawHashMarks(dc);

        // Draw North arrow
        drawNorth(dc, WindDirection);
        
        // Draw COG-circle and boat
		drawCogBoat(dc, WindDirection, COG_deg);

		// Draw laylines
		dc.setColor(Graphics.COLOR_BLUE, Graphics.COLOR_BLACK);
		dc.setPenWidth(2);
		dc.drawLine(m_width/2, m_height/2, 0, 0);
		dc.drawLine(m_width/2, m_height/2, m_height, 0 );
		dc.drawArc( m_width/2, m_height/2, m_height/2-20, dc.ARC_CLOCKWISE, 135, 45);
        
		// Draw wind directions
        dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_BLACK);
        dc.drawText(m_width/2, m_height/2-115, Graphics.FONT_TINY, WindDirection, Graphics.TEXT_JUSTIFY_CENTER);
        dc.drawText(m_width/5, m_height/2-70, Graphics.FONT_TINY, PortCloseDir, Graphics.TEXT_JUSTIFY_LEFT);
        dc.drawText(m_width/5*4, m_height/2-70, Graphics.FONT_TINY, StarboardCloseDir, Graphics.TEXT_JUSTIFY_RIGHT);

		// Draw COG
        dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);
        dc.drawText(m_width/2, m_height/2+10, Graphics.FONT_TINY, COG_deg.toNumber() + " deg", Graphics.TEXT_JUSTIFY_CENTER);

		// Draw SOG
        dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);
        dc.drawText(m_width/2, m_height/2+40, Graphics.FONT_TINY, Speed_kn.format("%.1f") + " kn", Graphics.TEXT_JUSTIFY_CENTER);

		// Draw Time
		var myTime = System.getClockTime(); // ClockTime object
		var myTimeText = myTime.hour.format("%02d") + ":" + myTime.min.format("%02d") + ":" + myTime.sec.format("%02d");
        dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);
        dc.drawText(m_width/2, m_height/2+70, Graphics.FONT_XTINY, myTimeText, Graphics.TEXT_JUSTIFY_CENTER);
		
    }

    // Called when this View is removed from the screen. Save the
    // state of this View here. This includes freeing resources from
    // memory.
    function onHide() {
    }

    // Draws the clock tick marks around the outside edges of the screen.
    function drawHashMarks(dc) {

		dc.setColor(Graphics.COLOR_BLUE, Graphics.COLOR_TRANSPARENT);
		dc.setPenWidth(2);

        // Draw hashmarks differently depending on screen geometry.
        if (System.SCREEN_SHAPE_ROUND == screenShape) {
            var sX, sY;
            var eX, eY;
            var outerRad = m_width / 2;
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
            var coords = [0, m_width / 4, (3 * m_width) / 4, m_width];
            for (var i = 0; i < coords.size(); i += 1) {
                var dx = ((m_width / 2.0) - coords[i]) / (m_height / 2.0);
                var upperX = coords[i] + (dx * 10);
                // Draw the upper hash marks.
                dc.fillPolygon([[coords[i] - 1, 2], [upperX - 1, 12], [upperX + 1, 12], [coords[i] + 1, 2]]);
                // Draw the lower hash marks.
                dc.fillPolygon([[coords[i] - 1, m_height-2], [upperX - 1, m_height - 12], [upperX + 1, m_height - 12], [coords[i] + 1, m_height - 2]]);
            }
        }
    }

    
    //=====================
    // Draws North
    //=====================
    function drawNorth(dc, WindDirection) {
		dc.setColor(Graphics.COLOR_BLUE, Graphics.COLOR_BLACK);

		var i = -(WindDirection+90)/180.0 * Math.PI;
        var X = ((m_width/2)-20) * Math.cos(i);
        var Y = ((m_height/2)-20) * Math.sin(i);
		
//		System.println("drawNorth : WindDirection=" + WindDirection + " i="+i);
		
    	dc.drawText(X + (m_width/2), Y + (m_height/2) - 12, Graphics.FONT_TINY, "N", Graphics.TEXT_JUSTIFY_CENTER);
 		//12 = Halv font-høyde
    }

    //=====================
    // Draws COG and Boat
    //=====================
    function drawCogBoat(dc, WindDirection, COG) {
        var dotSize = 8;
    	dc.setColor(Graphics.COLOR_RED, Graphics.COLOR_TRANSPARENT);

		// X,Y refers to origo i face-centre
		var i = -(WindDirection+90-COG)/180.0 * Math.PI;
        var X = ((m_width/2)-dotSize) * Math.cos(i);
        var Y = ((m_height/2)-dotSize) * Math.sin(i);
		
//		System.println("drawNorth : WindDirection=" + WindDirection + " i="+i);
		
    	dc.fillCircle(X + (m_width/2), Y + (m_height/2), dotSize);
    	
    	//Draw Boat
    	dc.setPenWidth(3);
    	dc.setColor(Graphics.COLOR_DK_GRAY, Graphics.COLOR_TRANSPARENT);

//    	moveTo( dc, (width/2), (height/2) );
//    	lineTo( dc, (width/2) + 40*Math.cos(i),     (width/2) + 40*Math.sin(i) );

//X = x*Math.cos(i) - y*Math.sin(i)
//Y = x*Math.sin(i) + y*Math.cos(i)

		i = i + Math.PI/2;
		
		moveToOrigoC( dc, (+  0 * Math.cos(i) ) - (- 50 * Math.sin(i) ), +  0 * Math.sin(i) - 50 * Math.cos(i) );    	
		lineToOrigoC( dc, (+  6 * Math.cos(i) ) - (- 40 * Math.sin(i) ), +  6 * Math.sin(i) - 40 * Math.cos(i) );
		lineToOrigoC( dc, (+ 10 * Math.cos(i) ) - (- 30 * Math.sin(i) ), + 10 * Math.sin(i) - 30 * Math.cos(i) );
		lineToOrigoC( dc, (+ 13 * Math.cos(i) ) - (- 20 * Math.sin(i) ), + 13 * Math.sin(i) - 20 * Math.cos(i) );
		lineToOrigoC( dc, (+ 15 * Math.cos(i) ) - (- 10 * Math.sin(i) ), + 15 * Math.sin(i) - 10 * Math.cos(i) );
		lineToOrigoC( dc, (+ 16 * Math.cos(i) ) - (-  0 * Math.sin(i) ), + 16 * Math.sin(i) -  0 * Math.cos(i) );
		lineToOrigoC( dc, (+ 17 * Math.cos(i) ) - (+ 20 * Math.sin(i) ), + 17 * Math.sin(i) + 20 * Math.cos(i) );
		lineToOrigoC( dc, (+ 17 * Math.cos(i) ) - (+ 30 * Math.sin(i) ), + 17 * Math.sin(i) + 30 * Math.cos(i) );
		lineToOrigoC( dc, (+ 16 * Math.cos(i) ) - (+ 40 * Math.sin(i) ), + 16 * Math.sin(i) + 40 * Math.cos(i) );
		lineToOrigoC( dc, (+ 13 * Math.cos(i) ) - (+ 50 * Math.sin(i) ), + 13 * Math.sin(i) + 50 * Math.cos(i) );
		lineToOrigoC( dc, (- 13 * Math.cos(i) ) - (+ 50 * Math.sin(i) ), - 13 * Math.sin(i) + 50 * Math.cos(i) );
		lineToOrigoC( dc, (- 16 * Math.cos(i) ) - (+ 40 * Math.sin(i) ), - 16 * Math.sin(i) + 40 * Math.cos(i) );
		lineToOrigoC( dc, (- 17 * Math.cos(i) ) - (+ 30 * Math.sin(i) ), - 17 * Math.sin(i) + 30 * Math.cos(i) );
		lineToOrigoC( dc, (- 17 * Math.cos(i) ) - (+ 20 * Math.sin(i) ), - 17 * Math.sin(i) + 20 * Math.cos(i) );
		lineToOrigoC( dc, (- 16 * Math.cos(i) ) - (-  0 * Math.sin(i) ), - 16 * Math.sin(i) -  0 * Math.cos(i) );
		lineToOrigoC( dc, (- 15 * Math.cos(i) ) - (- 10 * Math.sin(i) ), - 15 * Math.sin(i) - 10 * Math.cos(i) );
		lineToOrigoC( dc, (- 13 * Math.cos(i) ) - (- 20 * Math.sin(i) ), - 13 * Math.sin(i) - 20 * Math.cos(i) );
		lineToOrigoC( dc, (- 10 * Math.cos(i) ) - (- 30 * Math.sin(i) ), - 10 * Math.sin(i) - 30 * Math.cos(i) );
		lineToOrigoC( dc, (-  6 * Math.cos(i) ) - (- 40 * Math.sin(i) ), -  6 * Math.sin(i) - 40 * Math.cos(i) );
		lineToOrigoC( dc, (-  0 * Math.cos(i) ) - (- 50 * Math.sin(i) ), -  0 * Math.sin(i) - 50 * Math.cos(i) );    	
     	
	
    }

	// ==========================================
	// DrawLine functions in origo ref-syst
	// ==========================================
	var prevX=0;
	var prevY=0;
    function moveToOrigoC(dc, x, y) {
		prevX=x;
		prevY=y;
    }
    function lineToOrigoC(dc, nextX, nextY) {
    	dc.drawLine( (m_width/2) + prevX, (m_height/2) + prevY, (m_width/2) +nextX, (m_height/2) + nextY);
		prevX=nextX;
		prevY=nextY;
    }
}
