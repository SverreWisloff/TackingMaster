//using Toybox.WatchUi;
using Toybox.System as System;
using Toybox.Application as App;
using Toybox.Math;
using Toybox.Graphics;


//           0    
//           |    
//        4  |  1 
//270 --------------- 90
//        3  |  2 
//           |
//          180    
function Quadrant( degree )
{
	if      ( (degree>=  0.0) && (degree< 90.0) ) { return 1; }
	else if ( (degree>= 90.0) && (degree<180.0) ) { return 2; }
	else if ( (degree>=180.0) && (degree<270.0) ) { return 3; }
	else if ( (degree>=270.0) && (degree<360.0) ) { return 4; }
	else {return -1;}
}

class TackingMasterDynamics 
{
	var m_Size = 30; // standard 120 (2 min)
	var m_aData = [];
	var m_aDataSmooth = [];
	var m_NowPointer; 
	var m_PlotMaxData;
	var m_PlotMinData;
	var m_bCOG;

	var m_PrevWatchX;
	var m_PrevWatchY;

//------------------------------------------------------
// i     0    1    2    3    4    5    6    7    8    9
//COG  3.9  3.8  3.7  3.6  3.5  3.4  999  999  999  999
//                                L NowPointer (Last data-point)
//------------------------------------------------------
//
//

    // Dummy-value i data-array = 999.0
	// bCOG=true: 360 deg-data
	function initialize(Size, bCOG) {
		var i;
		m_Size = Size;
		m_bCOG = bCOG;
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

	// Weighted moving average : Weights: 1-2-1
	//Algorithm:
	// Smoothed(prev2) = (prev4 + prev3*2 + prev2*3 + prev1*2 + this) / 4
	// Smoothed(prev1) = (prev2 + prev1*2 + this) / 4
	// Smoothed(this) = This
		var Prev1Pointer;
		var Prev2Pointer;
		var Prev3Pointer;
		var Prev4Pointer;
		var DataPrev1;
		var DataPrev2;
		var DataPrev3;
		var DataPrev4;
		var SmootedDataPrev1;
		var SmootedDataPrev2;

		// Find Prev1Pnt
		if (m_NowPointer==0){Prev1Pointer = m_Size-1;}
		else {Prev1Pointer = m_NowPointer-1;}
		
		// Find Prev2Pnt
		if (Prev1Pointer==0){Prev2Pointer = m_Size-1;}
		else {Prev2Pointer = Prev1Pointer-1;}

		// Find Prev3Pnt
		if (Prev2Pointer==0){Prev3Pointer = m_Size-1;}
		else {Prev3Pointer = Prev2Pointer-1;}

		// Find Prev4Pnt
		if (Prev3Pointer==0){Prev4Pointer = m_Size-1;}
		else {Prev4Pointer = Prev3Pointer-1;}

		DataPrev1 = m_aData[Prev1Pointer];
		DataPrev2 = m_aData[Prev2Pointer];
		DataPrev3 = m_aData[Prev3Pointer];
		DataPrev4 = m_aData[Prev4Pointer];

		if (DataPrev1>900){DataPrev1=newData;}
		if (DataPrev2>900){DataPrev2=newData;}
		if (DataPrev3>900){DataPrev3=newData;}
		if (DataPrev4>900){DataPrev4=newData;}

		if (m_bCOG)
		{
			var Quad0 = Quadrant(newData);
			var Quad1 = Quadrant(DataPrev1);
			var Quad2 = Quadrant(DataPrev2);
			var Quad3 = Quadrant(DataPrev3);
			var Quad4 = Quadrant(DataPrev4);
			
			//Er alle COG-data som skal brukes i glatting i quadrant 1 eller 4?
			if ( (Quad0==1 || Quad0==4) 
				&& (Quad1==1 || Quad1==4)
				&& (Quad2==1 || Quad2==4)
				&& (Quad3==1 || Quad3==4)
				&& (Quad4==1 || Quad4==4) )
			{
					if (Quad0==1) { newData = newData + 360.0; }
					if (Quad1==1) { DataPrev1 = DataPrev1 + 360.0; }
					if (Quad2==1) { DataPrev2 = DataPrev2 + 360.0; }
					if (Quad3==1) { DataPrev3 = DataPrev3 + 360.0; }
					if (Quad4==1) { DataPrev4 = DataPrev4 + 360.0; }
			}	
		}
		
		SmootedDataPrev2 = (DataPrev4*1.5 + DataPrev3*2.0 + DataPrev2*3.0 + DataPrev1*2.0 + newData*1.5) / 10.0;
		SmootedDataPrev1 = (DataPrev2 + DataPrev1*2.0 + newData) / 4.0;
		m_aDataSmooth [Prev2Pointer] = SmootedDataPrev2;
		m_aDataSmooth [Prev1Pointer] = SmootedDataPrev1;
		m_aDataSmooth [m_NowPointer] = newData;
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

	
	//Draw smoothed data as a line in a polar diagram
	function drawPolarPlot(dc, width, height, WindDirection)
	{
		//draw data
		for( var sinceNow = 0; sinceNow < m_Size; sinceNow += 1 ) {
        	var Data = getSmoothedData(sinceNow);
			if (Data<900){
				plotPolarCoordToWatchCoord(dc, width, height, WindDirection, Data, sinceNow);
			}
		}

	}
	function plotPolarCoordToWatchCoord(dc, width, height, WindDirection, Data, sinceNow)
	{
		// X,Y refers to origo i face-centre
		var i = -(WindDirection+90-Data)/180.0 * Math.PI;
        var X = ((width  / 2)-5) * ((m_Size.toFloat()-sinceNow)/m_Size) * Math.cos(i);
        var Y = ((height / 2)-5) * ((m_Size.toFloat()-sinceNow)/m_Size) * Math.sin(i);
		var WatchX = X + (width / 2);
		var WatchY = Y + (height / 2);

		if (m_PrevWatchX==null){
			m_PrevWatchX = WatchX;
			m_PrevWatchY = WatchY;
		}
		if (sinceNow==0){
			m_PrevWatchX = WatchX;
			m_PrevWatchY = WatchY;
		} else if (sinceNow<m_Size-1){
			dc.drawLine(m_PrevWatchX, m_PrevWatchY, WatchX, WatchY);
//    	dc.fillCircle(X + (width/2), Y + (height/2), 2);
		}

		m_PrevWatchX = WatchX;
		m_PrevWatchY = WatchY;
	}

	//Draw smoothed data as a line in a trad. orthogonal diagram
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
		var dataMax = me.Max();

		if (m_PlotMinData < dataMin  ){
			m_PlotMinData = m_PlotMinData + 0.1;
		} else {
			m_PlotMinData = dataMin; 
		}

		if ( (m_PlotMaxData > dataMax)  ){
			m_PlotMaxData = m_PlotMaxData - 0.1;
		} else {
			m_PlotMaxData = dataMax;
		}

//		System.println("dataMax="+ dataMax + " dataMin="+ dataMin + " m_PlotMaxData=" + m_PlotMaxData);
		
		//draw data
		for( var sinceNow = 0; sinceNow < m_Size; sinceNow += 1 ) {
        	var Data = getSmoothedData(sinceNow);
			if (Data<900){
				plotCoordToWatchCoord(dc, DX, DY, width, height, m_PlotMaxData, m_PlotMinData, Data, sinceNow);
			}
		}
//		me.Print();
	}


	function plotCoordToWatchCoord(dc, DX, DY, width, height, dataMax, dataMin, data, time){
		var WatchX;
		var WatchY;

		if ( (dataMax.toFloat()-dataMin) == 0.0  ){
			//!!!!
			return;
		} else {
			WatchX = DX + width - ((time.toFloat()/m_Size.toFloat())*width.toFloat());
			WatchY = DY + height * ((dataMax.toFloat()-data)/(dataMax.toFloat()-dataMin));
		}
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
