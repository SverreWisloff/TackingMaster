//using Toybox.WatchUi;
using Toybox.System as System;
using Toybox.Application as App;
using Toybox.Math;
using Toybox.Graphics;


class TackingMasterDynamics {

	var m_Size = 120; // standard 120 (2 min)
	var m_aData = [];
	var m_aDataSmooth = [];
	var m_NowPointer; 
	var m_PlotMaxData;
	var m_PlotMinData;

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
			m_aDataSmooth.add(999.00001);
		}
		m_PlotMaxData=2.0;
		m_PlotMinData=0.0;
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
	function push(newData)
	{
		//System.println("Dynamics::push(" + newCog + ")  -- m_NowPointer=" + m_NowPointer);
		
		m_NowPointer+=1;
		if (m_NowPointer>=m_Size){
			m_NowPointer=0;
		}

		//System.println("Dynamics::push(" + newCog + ")  -- m_NowPointer=" + m_NowPointer);

		m_aData[m_NowPointer] = newData;

// Weighted moving average : Weights: 1-4-1
//Algorithm:
// Smoothed(prev) = (prevprev + prev*4 + this) / 6
// Smoothed(this) = This
		var PrevPointer;
		var PrevPrevPointer;
		var DataPrev;
		var DataPrevPrev;
		var SmootedDataPrev;

		// Find PrevPnt
		if (m_NowPointer==0){PrevPointer = m_Size-1;}
		else {PrevPointer = m_NowPointer-1;}
		
		// Find PrevPrevPnt
		if (PrevPointer==0){PrevPrevPointer = m_Size-1;}
		else {PrevPrevPointer = PrevPointer-1;}

		DataPrev = m_aData[PrevPointer];
		DataPrevPrev = m_aData[PrevPrevPointer];

		if (DataPrev>900){DataPrev=newData;}
		if (DataPrevPrev>900){DataPrevPrev=newData;}

		SmootedDataPrev = (DataPrevPrev + DataPrev*4.0 + newData) / 6.0;
		m_aDataSmooth [PrevPointer] = SmootedDataPrev;
		m_aDataSmooth [m_NowPointer] = newData;
	}


	// Compute Smooth-data
	// Weighted moving average : Weights: 1-4-1
	function Smooth()
	{
/*
		var DataPrev;
		var DataThis;
		var DataNext;
		var DataSmothed;

		for( var sinceNow = 0; sinceNow < m_aData.size(); sinceNow += 1 ) {
			if (sinceNow==0){
				//Siste registerte data
				DataThis = getData ( sinceNow );
			} else if (sinceNow==){
				//Første registerte data

			} else {

			}
			DataSmothed = (DataPrev + 4.0*DataThis + DataNext)/6.0;
        }
*/
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
	
	function getSmoothedData(sinceNow){
		if (sinceNow>m_Size || sinceNow<0){return 0.0;}

		var i = m_NowPointer-sinceNow;

		if (i<0){
			i = m_Size + (i);
		}

		if (i>m_Size || i<0){return 0.0;}

		return m_aDataSmooth[i];
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
        	if (m_aData[i]>Maximum && m_aData[i]<900){Maximum=m_aData[i];}
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
	    //Draw Rectangle / axis / fill black bakground
//		dc.setColor(Graphics.COLOR_BLACK, Graphics.COLOR_BLACK);
//		dc.fillRectangle(DX, DY, width, height);
//		dc.setColor(Graphics.COLOR_DK_GRAY, Graphics.COLOR_LT_GRAY);
//		dc.drawRectangle(DX, DY, width, height);

		var dataMin = me.Min();
		if (m_PlotMinData < dataMin){
			m_PlotMinData = m_PlotMinData + 0.1;
		} else {
			m_PlotMinData = dataMin; 
		}

		var dataMax = me.Max();
		if (m_PlotMaxData > dataMax){
			m_PlotMaxData = m_PlotMaxData - 0.1;
		} else {
			m_PlotMaxData = dataMax;
		}


		//draw data
		for( var sinceNow = 0; sinceNow < m_Size; sinceNow += 1 ) {
        	var Data = getSmoothedData(sinceNow);
			if (Data<900){
				plotCoordToWatchCoord(dc, DX, DY, width, height, m_PlotMaxData, m_PlotMinData, Data, sinceNow);
			}
		}
//		me.Print();
	}

	var m_PrevWatchX;
	var m_PrevWatchY;

	function plotCoordToWatchCoord(dc, DX, DY, width, height, dataMax, dataMin, data, time){
		var WatchX;
		var WatchY;

		WatchX = DX + width - ((time.toFloat()/m_Size.toFloat())*width.toFloat());
		WatchY = DY + height * ((dataMax.toFloat()-data)/(dataMax.toFloat()-dataMin));

//        System.println("DX="+DX+ " DY="+DY+" width="+width+ " height="+height+ " dataMax="+dataMax+" dataMin="+dataMin+ " data="+data+ " time="+time + " m_Size=" + m_Size);

		if (m_PrevWatchX==null){
			m_PrevWatchX = WatchX;
			m_PrevWatchY = WatchY;
		}
		if (time==0){
			m_PrevWatchX = WatchX;
			m_PrevWatchY = WatchY;
		} else if (time<m_Size-1){
			dc.drawLine(m_PrevWatchX, m_PrevWatchY, WatchX, WatchY);
		}

		m_PrevWatchX = WatchX;
		m_PrevWatchY = WatchY;
	}

}	
