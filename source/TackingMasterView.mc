using Toybox.WatchUi;
using Toybox.System as System;
using Toybox.Graphics;
using Toybox.Application as App;
using Toybox.Timer;
using Toybox.Position;
using Toybox.Math;

var myCount =  0;


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

	//Member variables
	var m_screenShape;
	var m_TackAngle = 90;
	var m_posnInfo = null;
	var m_width;
	var m_height;
	var m_WindDirection;
    var m_WindDirStarboard;
    var m_WindDirPort;
    var m_CogDotSize = 8;
	var m_COG_deg;
	var m_Speed_kn;
	var m_bDrawBoat;
	var m_bDrawNWSE;
	var m_bDrawSpeedPlot;
	var m_bDrawOrthogonalCogPlot;
	var m_bDrawPolarCogPlot;
	var m_boatScale=1.2;
	var m_SpeedHistory = new TackingMasterDynamics(120,false); // standard 120 (2 min)
	var m_CogHistory = new TackingMasterDynamics(120, true);   // standard 120 (2 min)

    function initialize() {
        View.initialize();
//        System.println("TackingMasterView.initialize");
        m_screenShape = System.getDeviceSettings().screenShape;

		// Get the WindDirection from the settings-storage
        var app = App.getApp();
        var WindDirection = Application.Storage.getValue("WindDirection");
        
        if (WindDirection==null){
        	WindDirection=100;
        }
        Application.Storage.setValue("WindDirection", WindDirection);
//        System.println("TackingMasterView.initialize - WindDirection=" + WindDirection);
   		
   		m_bDrawBoat = Application.Storage.getValue("DrawBoat");
   		if (m_bDrawBoat==null){m_bDrawBoat = true;}   	
   		
   		m_bDrawNWSE = Application.Storage.getValue("DrawNWSE");
   		if (m_bDrawNWSE==null){m_bDrawNWSE = false;}   	

   		m_bDrawSpeedPlot = Application.Storage.getValue("DrawSpeedPlot");
   		if (m_bDrawSpeedPlot==null){m_bDrawSpeedPlot = true;}   	

 		m_bDrawPolarCogPlot = Application.Storage.getValue("DrawPolarCogPlot");
 		if (m_bDrawPolarCogPlot==null){m_bDrawPolarCogPlot = false;}   	

		m_bDrawOrthogonalCogPlot=false;

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
    	//Update after changing settings
   		m_bDrawBoat = Application.Storage.getValue("DrawBoat");
   		if (m_bDrawBoat==null){m_bDrawBoat = true;}

   		m_bDrawNWSE = Application.Storage.getValue("DrawNWSE");
   		if (m_bDrawNWSE==null){m_bDrawNWSE = false;}
   		
   		m_bDrawSpeedPlot = Application.Storage.getValue("DrawSpeedPlot");
   		if (m_bDrawSpeedPlot==null){m_bDrawSpeedPlot = true;}

 		m_bDrawPolarCogPlot = Application.Storage.getValue("DrawPolarCogPlot");
 		if (m_bDrawPolarCogPlot==null){m_bDrawPolarCogPlot = false;}
//		System.println("TackingMasterView.onShow() - m_bDrawPolarCogPlot=" + m_bDrawPolarCogPlot); 
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
        m_WindDirection = Application.Storage.getValue("WindDirection");
        m_WindDirection = Math.round(m_WindDirection);
        m_WindDirection = reduse_deg(m_WindDirection.toLong());
        m_WindDirStarboard = reduse_deg(m_WindDirection + (m_TackAngle/2) );
        m_WindDirPort = reduse_deg(m_WindDirection - (m_TackAngle/2) );
        
 		// Get COG & SOG
		if(m_posnInfo!=null	){ 
			m_COG_deg = reduse_deg((m_posnInfo.heading)/Math.PI*180);
		}
		else{
			m_COG_deg = 0;
		}
		if(m_posnInfo!=null){
			m_Speed_kn = m_posnInfo.speed * 1.9438444924406;
		}
		else {
			m_Speed_kn = 0;
		}

		//Update Speed-History-array
		if (m_Speed_kn>-0.000001 && m_Speed_kn<99.9){
				m_SpeedHistory.push(m_Speed_kn);
		}

		//Update COG-History-array
		m_CogHistory.push(m_COG_deg);

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
        drawNorth(dc);
        
        // Draw boat
		drawBoat(dc);

		// Draw laylines
		dc.setColor(Graphics.COLOR_BLUE, Graphics.COLOR_BLACK);
		dc.setPenWidth(2);
		moveToOrigoC(dc, -m_width*Math.sin(Math.PI/4), -m_height*Math.sin(Math.PI/4));
		lineToOrigoC(dc, 0, 0);
		lineToOrigoC(dc,  m_width*Math.sin(Math.PI/4), -m_height*Math.sin(Math.PI/4));
		dc.drawArc( m_width/2, m_height/2, m_height/2-20, dc.ARC_CLOCKWISE, 180-m_TackAngle/2, m_TackAngle/2);
        
		// Draw numbers for wind directions
        dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_BLACK);
        dc.drawText(m_width/2, m_height/2-115, Graphics.FONT_TINY, m_WindDirection, Graphics.TEXT_JUSTIFY_CENTER);
        dc.drawText(m_width/5, m_height/2-70, Graphics.FONT_TINY, m_WindDirPort, Graphics.TEXT_JUSTIFY_LEFT);
        dc.drawText(m_width/5*4, m_height/2-70, Graphics.FONT_TINY, m_WindDirStarboard, Graphics.TEXT_JUSTIFY_RIGHT);

        // Draw COG-circle 
		drawCogDot(dc);

		//Draw Cog-curve 
		drawCogPlot(dc);

		//Draw speed-curve and SOG-text
		drawSpeedPlot(dc);

		// Draw COG-text in a circle
		var fontHeight = dc.getFontHeight(Graphics.FONT_TINY); 
		dc.setColor(Graphics.COLOR_BLACK, Graphics.COLOR_BLACK);
		dc.fillCircle(m_width/2, m_height/2, 25);
		dc.setColor(Graphics.COLOR_BLUE, Graphics.COLOR_BLUE);
        dc.drawCircle(m_width/2, m_height/2, 25);
        
        dc.setColor(Graphics.COLOR_YELLOW, Graphics.COLOR_BLACK);
        dc.drawText(m_width/2, m_height/2-fontHeight/2, Graphics.FONT_TINY, m_COG_deg.toNumber() , Graphics.TEXT_JUSTIFY_CENTER);

		// Draw Time-text
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
	// ==========================================================================
    function drawHashMarks(dc) {
		dc.setColor(Graphics.COLOR_BLUE, Graphics.COLOR_TRANSPARENT);
		dc.setPenWidth(2);

        // Draw hashmarks differently depending on screen geometry.
        if (System.SCREEN_SHAPE_ROUND == m_screenShape) {
            var sX, sY;
            var eX, eY;
            var outerRad = m_width / 2;
            var innerRad = outerRad - 9;
            
            // draw 10-deg tick marks.
            for (var i = 0; i < 2 * Math.PI ; i += (Math.PI / 18)) {
                sY = outerRad + innerRad * Math.sin(i);
                eY = outerRad + outerRad * Math.sin(i);
                sX = outerRad + innerRad * Math.cos(i);
                eX = outerRad + outerRad * Math.cos(i);
                dc.drawLine(sX, sY, eX, eY);
            }

            // draw 10-deg tick marks.
            innerRad = outerRad - 5;
            for (var i = 0; i < 2 * Math.PI ; i += (Math.PI / 90)) {
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
    function drawNorth(dc) {
    	if (m_bDrawNWSE==false){
    		return;
    	}
    	
		dc.setColor(Graphics.COLOR_BLUE, Graphics.COLOR_BLACK);
		var fontHeight = dc.getFontHeight(Graphics.FONT_TINY); 

		var i = -(m_WindDirection+90)/180.0 * Math.PI;
        var X = ((m_width/2)-20) * Math.cos(i);
        var Y = ((m_height/2)-20) * Math.sin(i);
    	dc.drawText(X + (m_width/2), Y + (m_height/2) - fontHeight/2, Graphics.FONT_TINY, "N", Graphics.TEXT_JUSTIFY_CENTER);
 		
		i = -(m_WindDirection)/180.0 * Math.PI;
        X = ((m_width/2)-20) * Math.cos(i);
        Y = ((m_height/2)-20) * Math.sin(i);
    	dc.drawText(X + (m_width/2), Y + (m_height/2) - fontHeight/2, Graphics.FONT_TINY, "E", Graphics.TEXT_JUSTIFY_CENTER);

		i = -(m_WindDirection-90)/180.0 * Math.PI;
        X = ((m_width/2)-20) * Math.cos(i);
        Y = ((m_height/2)-20) * Math.sin(i);
    	dc.drawText(X + (m_width/2), Y + (m_height/2) - fontHeight/2, Graphics.FONT_TINY, "S", Graphics.TEXT_JUSTIFY_CENTER);

		i = -(m_WindDirection+180)/180.0 * Math.PI;
        X = ((m_width/2)-20) * Math.cos(i);
        Y = ((m_height/2)-20) * Math.sin(i);
    	dc.drawText(X + (m_width/2), Y + (m_height/2) - fontHeight/2, Graphics.FONT_TINY, "W", Graphics.TEXT_JUSTIFY_CENTER);
    }

    //=====================
    // Draws COG-dot 
    //=====================
    function drawCogDot(dc) {
    	dc.setColor(Graphics.COLOR_YELLOW, Graphics.COLOR_TRANSPARENT);

		// X,Y refers to origo i face-centre
		var i = -(m_WindDirection+90-m_COG_deg)/180.0 * Math.PI;
        var X = ((m_width/2)-m_CogDotSize) * Math.cos(i);
        var Y = ((m_height/2)-m_CogDotSize) * Math.sin(i);
		
//		System.println("drawNorth : WindDirection=" + WindDirection + " i="+i);
		
    	dc.fillCircle(X + (m_width/2), Y + (m_height/2), m_CogDotSize);
    }	
    //=====================
    // Draws  Boat
    //=====================
    function drawBoat(dc) {
    
    	if (!m_bDrawBoat){
	    	return;
		}
		
		// X,Y refers to origo i face-centre
		var WD = -(m_WindDirection+90-m_COG_deg)/180.0 * Math.PI;
		WD = WD + Math.PI/2;
		
    	//Draw Boat
    	dc.setPenWidth(5);
    	dc.setColor(Graphics.COLOR_DK_GRAY, Graphics.COLOR_TRANSPARENT);

		var arrayBoat = [ 
				[+  0,- 50], 
				[+  6,- 40], 
				[+ 10,- 30], 
				[+ 13,- 20], 
				[+ 15,- 10], 
				[+ 16,-  0], 
				[+ 17,+ 20], 
				[+ 17,+ 30], 
				[+ 16,+ 40], 
				[+ 13,+ 50], 
				[- 13,+ 50], 
				[- 16,+ 40], 
				[- 17,+ 30], 
				[- 17,+ 20], 
				[- 16,-  0], 
				[- 15,- 10], 
				[- 13,- 20], 
				[- 10,- 30], 
				[-  6,- 40], 
				[-  0,- 50] 
			];

		//Scaling the size of the boat
		m_boatScale=1.2;
		for (var i=0; i<arrayBoat.size(); i+=1){
			arrayBoat[i][0] = arrayBoat[i][0] * m_boatScale;
			arrayBoat[i][1] = arrayBoat[i][1] * m_boatScale;
		}
		
		var X = arrayBoat[0][0];
		var Y = arrayBoat[0][1];
		var COS = Math.cos(WD);
		var SIN = Math.sin(WD); 

		moveToOrigoC( dc, (X*COS) - (Y*SIN), (X*SIN) + (Y*COS) );    	
		
		for( var i = 1; i < 20; i += 1 ) {
			X = arrayBoat[i][0];
			Y = arrayBoat[i][1];
			lineToOrigoC( dc, (X*COS) - (Y*SIN), (X*SIN) + (Y*COS) );
		}

    }

    //================================
    // Draws speed-histoy-plot
	//================================
	function drawSpeedPlot(dc){
		var plotWidth=m_width/2;
		var plotHeight=35;

		dc.setColor(Graphics.COLOR_DK_GREEN, Graphics.COLOR_TRANSPARENT);
		dc.setPenWidth(3);

    	if (m_bDrawSpeedPlot){
//			m_SpeedHistory.drawPlot(m_width/2-plotWidth/2-40, m_height/2+35, plotWidth, plotHeight, dc);
			m_SpeedHistory.drawPlot(10, m_height/2+33, plotWidth, plotHeight, dc);

			dc.setColor(Graphics.COLOR_GREEN, Graphics.COLOR_TRANSPARENT);
			dc.drawText(m_width*0.70, m_height/2+33, Graphics.FONT_SMALL, m_Speed_kn.format("%.1f") + " kn", Graphics.TEXT_JUSTIFY_CENTER);
		} else {
			dc.setColor(Graphics.COLOR_GREEN, Graphics.COLOR_TRANSPARENT);
			dc.drawText(m_width/2, m_height/2+33, Graphics.FONT_SMALL, m_Speed_kn.format("%.1f") + " kn", Graphics.TEXT_JUSTIFY_CENTER);
		}
	}

    //================================
    // Draws Cog-histoy-plot
	//================================
	function drawCogPlot(dc){
		var plotWidth=m_width/2;
		var plotHeight=35;

		dc.setColor(Graphics.COLOR_YELLOW, Graphics.COLOR_TRANSPARENT);
		dc.setPenWidth(2);

		//Draw orthogonal COG-plot
    	if (m_bDrawOrthogonalCogPlot){
			m_CogHistory.drawPlot(10, m_height/2+33, plotWidth, plotHeight, dc);
		}

		//Draw polar COG-plot
    	if (m_bDrawPolarCogPlot){
			m_CogHistory.drawPolarPlot(dc, m_width, m_height, m_WindDirection);
		}
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
