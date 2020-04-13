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
//            System.println("TackingMasterMenuDelegate::onSelect() - idSetPortWD");
	        var COG = getCOG();
	        var WindDirection = COG-45;
        	Application.Storage.setValue("WindDirection", WindDirection);
	        WatchUi.popView(WatchUi.SLIDE_DOWN);
        } else if ( item.getId().equals("idSetStarbWD") ) {
            //Set starboard tack
//          System.println("TackingMasterMenuDelegate::onSelect() - idSetStarbWD");
	        var COG = getCOG();
	        var WindDirection = COG+45;
        	Application.Storage.setValue("WindDirection", WindDirection);
	        WatchUi.popView(WatchUi.SLIDE_DOWN);
        } else if ( item.getId().equals("idSettings") ) {
//          System.println("TackingMasterMenuDelegate::onSelect() - idSettings");
            var settingsMenu = new WatchUi.Menu2({:title=>WatchUi.loadResource(Rez.Strings.menu_label_Settings)});

			//Get string resources for Settings-menu
			var strDrawBoat = WatchUi.loadResource(Rez.Strings.menu_label_DrawBoat);
			var strShow = WatchUi.loadResource(Rez.Strings.menu_label_Show);
			var strHide = WatchUi.loadResource(Rez.Strings.menu_label_Hide);
			var strDrawNWSE = WatchUi.loadResource(Rez.Strings.menu_label_DrawNWSE);
			var strDrawSpeedPlot = WatchUi.loadResource(Rez.Strings.menu_label_DrawSpeedPlot);
			var strDrawPolarCogPlot = WatchUi.loadResource(Rez.Strings.menu_label_DrawPolarCogPlot);

    		// Get settings
    		var bDrawBoat = Application.Storage.getValue("DrawBoat");   	
    		if (bDrawBoat!=false) {bDrawBoat = true;} 
    			else {bDrawBoat = false;}
    		var bDrawNWSE = Application.Storage.getValue("DrawNWSE");   
    		if (bDrawNWSE!=false) {bDrawNWSE = true;} 
    			else {bDrawNWSE = false;}
    		var bDrawSpeedPlot = Application.Storage.getValue("DrawSpeedPlot");   
    		if (bDrawSpeedPlot!=false) {bDrawSpeedPlot = true;} 
    			else {bDrawSpeedPlot = false;}
    		var bDrawPolarCogPlot = Application.Storage.getValue("DrawPolarCogPlot");   
    		if (bDrawPolarCogPlot!=false) {bDrawPolarCogPlot = true;} 
    			else {bDrawPolarCogPlot = false;}


			//Build the settings-menu
            settingsMenu.addItem(new WatchUi.ToggleMenuItem(strDrawBoat, {:enabled=>strShow, :disabled=>strHide}, "idDrawBoat", bDrawBoat, {:alignment=>WatchUi.MenuItem.MENU_ITEM_LABEL_ALIGN_LEFT}));
            WatchUi.pushView(settingsMenu, new Menu2SampleSubMenuDelegate(), WatchUi.SLIDE_UP );
            settingsMenu.addItem(new WatchUi.ToggleMenuItem(strDrawNWSE, {:enabled=>strShow, :disabled=>strHide}, "idDrawNWSE", bDrawNWSE, {:alignment=>WatchUi.MenuItem.MENU_ITEM_LABEL_ALIGN_LEFT}));
            WatchUi.pushView(settingsMenu, new Menu2SampleSubMenuDelegate(), WatchUi.SLIDE_UP );
            settingsMenu.addItem(new WatchUi.ToggleMenuItem(strDrawSpeedPlot, {:enabled=>strShow, :disabled=>strHide}, "idDrawSpeedPlot", bDrawSpeedPlot, {:alignment=>WatchUi.MenuItem.MENU_ITEM_LABEL_ALIGN_LEFT}));
            WatchUi.pushView(settingsMenu, new Menu2SampleSubMenuDelegate(), WatchUi.SLIDE_UP );
            settingsMenu.addItem(new WatchUi.ToggleMenuItem(strDrawPolarCogPlot, {:enabled=>strShow, :disabled=>strHide}, "idDrawPolarCogPlot", bDrawPolarCogPlot, {:alignment=>WatchUi.MenuItem.MENU_ITEM_LABEL_ALIGN_LEFT}));
            WatchUi.pushView(settingsMenu, new Menu2SampleSubMenuDelegate(), WatchUi.SLIDE_UP );
/*
        } else {
            WatchUi.requestUpdate();
*/
        }
    }
    
    function onBack() {
//        System.println("TackingMasterMenuDelegate::onBack()");
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
 //       System.println("Menu2SampleSubMenuDelegate::onSelect() - iD=" + MenuItem + " enabled=" + item.isEnabled() );
        if (MenuItem.equals("idDrawBoat")){
//	        System.println("Menu2SampleSubMenuDelegate::onSelect()::DrawBoat");
    		Application.Storage.setValue("DrawBoat", item.isEnabled()); 
    	} else if (MenuItem.equals("idDrawNWSE")){
//	        System.println("Menu2SampleSubMenuDelegate::onSelect()::DrawNWSE");
    		Application.Storage.setValue("DrawNWSE", item.isEnabled()); 
		} else if (MenuItem.equals("idDrawSpeedPlot")){
//	        System.println("Menu2SampleSubMenuDelegate::onSelect()::DrawSpeedPlot");
    		Application.Storage.setValue("DrawSpeedPlot", item.isEnabled()); 
		} else if (MenuItem.equals("idDrawPolarCogPlot")){
//	        System.println("Menu2SampleSubMenuDelegate::onSelect()::DrawPolarCogPlot");
    		Application.Storage.setValue("DrawPolarCogPlot", item.isEnabled()); 
		} else {
//	        System.println("Menu2SampleSubMenuDelegate::onSelect()::else");
        }

        WatchUi.requestUpdate();
    }

    function onBack() {
//        System.println("Menu2SampleSubMenuDelegate::onBack()");
        WatchUi.popView(WatchUi.SLIDE_DOWN);
        WatchUi.popView(WatchUi.SLIDE_DOWN);
        WatchUi.popView(WatchUi.SLIDE_DOWN);
        WatchUi.popView(WatchUi.SLIDE_DOWN);
    }

    function onDone() {
        System.println("Menu2SampleSubMenuDelegate::onDone()");
        WatchUi.popView(WatchUi.SLIDE_DOWN);
    }
}
