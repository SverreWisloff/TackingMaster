using Toybox.WatchUi;
using Toybox.System;
using Toybox.Position as Position;
using Toybox.Math;


// Find COG / Heading
//===================
function getCOG() {
	var positionInfo = Position.getInfo();
	var Heading_deg = 0;
	if(positionInfo!=null){
		Heading_deg = (positionInfo.heading)/Math.PI*180;
	}
	return Heading_deg;
}

class TackingMasterMenuDelegate extends WatchUi.MenuInputDelegate {

    function initialize() {
        MenuInputDelegate.initialize();
    }

    function onMenuItem(item) {
        if (item == :item_1) {
            System.println("Set port tack");
            //Set port tack
	        var COG = getCOG();
	        var WindDirection = COG-45;
        	Application.Storage.setValue("WindDirection", WindDirection);
            
        } else if (item == :item_2) {
            System.println("Set starboard tack");
            //Set starboard tack
	        var COG = getCOG();
	        var WindDirection = COG+45;
        	Application.Storage.setValue("WindDirection", WindDirection);
        }
    }

}