using Toybox.System as System;
using Toybox.Application as App;
using Toybox.Math;


class TackingMasterDynamics {

	var m_Size=10;
	var m_aCog = [];
	var m_NowPointer; 

    function initialize() {
		var i;
		me.m_NowPointer = m_Size;
		//System.println("Dynamics::initialize() - m_Size=" + m_Size );
		for( i = 0; i < m_Size; i += 1 ) {
			m_aCog.add(0);
		}
	}
	
	function push(newCog)
	{
		//System.println("Dynamics::push(" + newCog + ")  -- m_NowPointer=" + m_NowPointer);
		
		m_NowPointer+=1;
		if (m_NowPointer>=m_Size){
			m_NowPointer=0;
		}

		//System.println("Dynamics::push(" + newCog + ")  -- m_NowPointer=" + m_NowPointer);

		m_aCog[m_NowPointer] = newCog;
	}

	function Min()
	{
		var Minimum=99;
		for( var i = 0; i < m_aCog.size(); i += 1 ) {
        	if (m_aCog[i]<Minimum){Minimum=m_aCog[i];}
        }
        return Minimum;
	}

	function Max()
	{
		var Maximum=0;
		for( var i = 0; i < m_aCog.size(); i += 1 ) {
        	if (m_aCog[i]>Maximum){Maximum=m_aCog[i];}
        }
        return Maximum;
	}

	function Print()
	{
		System.println("Dynamics::Print() - m_NowPointer=" + me.m_NowPointer );
		for( var i = 0; i < m_aCog.size(); i += 1 ) {
        	System.println("Dynamics[" + i + "]=" + m_aCog[i]);
        }
	}

}
