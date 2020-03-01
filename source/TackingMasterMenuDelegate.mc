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


class TackingMasterMenuDelegate extends WatchUi.Menu2InputDelegate {

    function initialize() {
        Menu2InputDelegate.initialize();
    }

    function onSelect(item) {
        if( item.getId().equals("idSetPortWD") ) {
            // When the toggle menu item is selected, push a new menu that demonstrates
            // left and right toggles with automatic substring toggles.
            //Set port tack
	        var COG = getCOG();
	        var WindDirection = COG-45;
        	Application.Storage.setValue("WindDirection", WindDirection);
	        WatchUi.popView(WatchUi.SLIDE_DOWN);
        } else if ( item.getId().equals("idSetStarbWD") ) {
            //Set starboard tack
	        var COG = getCOG();
	        var WindDirection = COG+45;
        	Application.Storage.setValue("WindDirection", WindDirection);
	        WatchUi.popView(WatchUi.SLIDE_DOWN);
        } else if ( item.getId().equals("idSettings") ) {
            var settingsMenu = new WatchUi.Menu2({:title=>"Settings"});

    		var bDrawBoat = Application.Storage.getValue("DrawBoat");   	
        	System.println("Menu2SampleSubMenuDelegate::initialize - DrawBoat=" + bDrawBoat );
            settingsMenu.addItem(new WatchUi.ToggleMenuItem("Draw boat", {:enabled=>"show boat", :disabled=>"hide boat"}, "idDrawBoat", bDrawBoat, {:alignment=>WatchUi.MenuItem.MENU_ITEM_LABEL_ALIGN_LEFT}));
            WatchUi.pushView(settingsMenu, new Menu2SampleSubMenuDelegate(), WatchUi.SLIDE_UP );

    		var bDrawNWSE = Application.Storage.getValue("DrawNWSE");   	
        	System.println("Menu2SampleSubMenuDelegate::initialize - DrawNWSE=" + bDrawNWSE );
            settingsMenu.addItem(new WatchUi.ToggleMenuItem("Draw N+E+S+W", {:enabled=>"show north", :disabled=>"hide north"}, "idDrawNWSE", bDrawNWSE, {:alignment=>WatchUi.MenuItem.MENU_ITEM_LABEL_ALIGN_LEFT}));

            WatchUi.pushView(settingsMenu, new Menu2SampleSubMenuDelegate(), WatchUi.SLIDE_UP );
/*
        } else {
            WatchUi.requestUpdate();
*/
        }
    }
    
    function onBack() {
        WatchUi.popView(WatchUi.SLIDE_DOWN);
    }

}


//This is the menu input delegate shared by all the basic sub-menus in the application
class Menu2SampleSubMenuDelegate extends WatchUi.Menu2InputDelegate {
    function initialize() {
        Menu2InputDelegate.initialize();
    }

    function onSelect(item) {

        //Draw Boat
        var MenuItem = item.getId();
        System.println("Menu2SampleSubMenuDelegate::onSelect - iD=" + MenuItem + " enabled=" + item.isEnabled() );
        if (MenuItem.equals("idDrawBoat")){
	        System.println("Menu2SampleSubMenuDelegate::onSelect::DrawBoat");
    		Application.Storage.setValue("DrawBoat", item.isEnabled()); 
    	}
        if (MenuItem.equals("idDrawNWSE")){
	        System.println("Menu2SampleSubMenuDelegate::onSelect::DrawNWSE");
    		Application.Storage.setValue("DrawNWSE", item.isEnabled()); 
		}    	

        WatchUi.requestUpdate();
    }

    function onBack() {
        System.println("Menu2SampleSubMenuDelegate::onBack");
        WatchUi.popView(WatchUi.SLIDE_DOWN);
    }

    function onDone() {
        System.println("Menu2SampleSubMenuDelegate::onDone");
        WatchUi.popView(WatchUi.SLIDE_DOWN);
    }
}
