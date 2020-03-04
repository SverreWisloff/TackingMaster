//using Toybox.WatchUi;
using Toybox.System as System;
using Toybox.Application as App;
using Toybox.Math;
using Toybox.Graphics;


class TackingMasterDynamics {

	var m_Size=30;
	var m_aData = [];
	var m_NowPointer; 
	var m_MaxData;

//------------------------------------------------------
// i     0    1    2    3    4    5    6    7    8    9
//COG  3.9  3.8  3.7  3.6  3.5  3.4  999  999  999  999
//                                L NowPointer (Last data-point)
//------------------------------------------------------
//
//

    function initialize() {
		var i;
		me.m_NowPointer = m_Size;
		//System.println("Dynamics::initialize() - m_Size=" + m_Size );
		for( i = 0; i < m_Size; i += 1 ) {
			m_aData.add(999.00001);
		}
		m_MaxData=6.0;
	}

	// Make som demodata and fill the hole array with data from 1 to 3 
	function fillDemData(){
		for( var i = 0; i < m_Size+3; i += 1 ) {
			var demodata = Math.PI*2.0;
			demodata = Math.sin( demodata * i / m_Size);
			demodata = demodata + 2;
			me.push( demodata );
		}	
	}
	
	// Insert latest data
	function push(newCog)
	{
		//System.println("Dynamics::push(" + newCog + ")  -- m_NowPointer=" + m_NowPointer);
		
		m_NowPointer+=1;
		if (m_NowPointer>=m_Size){
			m_NowPointer=0;
		}

		//System.println("Dynamics::push(" + newCog + ")  -- m_NowPointer=" + m_NowPointer);

		m_aData[m_NowPointer] = newCog;
	}

	function getData(sinceNow){
		if (sinceNow>m_Size || sinceNow<0){return 0.0;}

		var i = m_NowPointer-sinceNow;

		if (i<0){
			i = m_Size + (i);
		}

		if (i>m_Size || i<0){return 0.0;}

		return m_aData[i];
	}

	// Get smallest data-point
	function Min()
	{
		var Minimum=99;
		for( var i = 0; i < m_aData.size(); i += 1 ) {
        	if (m_aData[i]<Minimum){Minimum=m_aData[i];}
        }
        return Minimum;
	}

	// Get largest data-point
	function Max()
	{
		var Maximum=0;
		for( var i = 0; i < m_aData.size(); i += 1 ) {
        	if (m_aData[i]>Maximum){Maximum=m_aData[i];}
        }
        return Maximum;
	}

	function Print()
	{
		System.println("Dynamics::Print() - m_NowPointer=" + me.m_NowPointer );
		for( var i = 0; i < m_aData.size(); i += 1 ) {
        	System.print("Dynamics[" + i + "]=" + m_aData[i] + " ");
			if (i==me.m_NowPointer){
				System.println("<-");
			} else {
				System.println(" ");
			}
        }
	}

	function PrintReverse()
	{
		System.println("Dynamics::PrintReverse()" );
		for( var sinceNow = 0; sinceNow < m_Size; sinceNow += 1 ) {
        	var Data = getData(sinceNow);
			System.println("sinceNow=" + sinceNow + " Data=" + Data);
        }
	}

	//DX, DY : Upper left corner of plot
	//width, height: width and height of plot
	function drawPlot(DX, DY, width, height, dc)
	{
		var dotRadius=3;

	    //Draw Rectangle / axis / fill black bakground

//		dc.setColor(Graphics.COLOR_BLACK, Graphics.COLOR_BLACK);
//		dc.fillRectangle(DX, DY, width, height);
//		dc.setColor(Graphics.COLOR_DK_GRAY, Graphics.COLOR_LT_GRAY);
//		dc.drawRectangle(DX, DY, width, height);

		//draw data
		for( var sinceNow = 0; sinceNow < m_Size; sinceNow += 1 ) {
        	var Data = getData(sinceNow);
			var dataMax = 6.0;//me.Max();
			var dataMin = 0.0;//me.Min();
        	plotCoordToWatchCoord(dc, DX, DY, width, height, dataMax, dataMin, Data, sinceNow);
		}

	}

	function plotCoordToWatchCoord(dc, DX, DY, width, height, dataMax, dataMin, data, time){
		var dotRadius = 1;
		var WatchX;
		var WatchY;

		WatchX = DX + width - ((time.toFloat()/m_Size.toFloat())*width.toFloat());
		WatchY = DY + height * ((dataMax.toFloat()-data)/(dataMax.toFloat()-dataMin));

//        System.println("DX="+DX+ " DY="+DY+" width="+width+ " height="+height+ " dataMax="+dataMax+" dataMin="+dataMin+ " data="+data+ " time="+time + " m_Size=" + m_Size);

		dc.fillCircle(WatchX, WatchY, dotRadius);
	}

}
