using Toybox.WatchUi;
using Toybox.System as System;



// This class implements basic input handling.
class TackingMasterDelegate extends WatchUi.BehaviorDelegate {

    function initialize() {
        BehaviorDelegate.initialize();
    }

    function onMenu() {
        WatchUi.pushView(new Rez.Menus.MainMenu(), new TackingMasterMenuDelegate(), WatchUi.SLIDE_UP);
        return true;
    }

	// @param evt KEY_XXX enum value, KEY_DOWN, KEY_UP, KEY_ENTER, KEY_ESC
    // @return true if handled, false otherwise
    function onKey(keyEvent){
        System.println(keyEvent.getKey());
        
        if (keyEvent.getKey()==KEY_ENTER){
        	//Nothing happens on ENTER
        }
        else if (keyEvent.getKey()==KEY_UP){
	        //Press UP to increase WindDirection with 5 degrees
	        var WindDirection = Application.Storage.getValue("WindDirection");
        	WindDirection += 5;
        	Application.Storage.setValue("WindDirection", WindDirection);
//	        System.println("TackingMasterView.initialize - WindDirection=" + WindDirection);
        }
        else if (keyEvent.getKey()==KEY_DOWN){
	        //Press DOWN to decrease WindDirection with 5 degrees
	        var WindDirection = Application.Storage.getValue("WindDirection");
        	WindDirection -= 5;
        	Application.Storage.setValue("WindDirection", WindDirection);
//	        System.println("TackingMasterView.initialize - WindDirection=" + WindDirection);
        }
        else if (keyEvent.getKey()==KEY_ESC){
        }
    }
    
}