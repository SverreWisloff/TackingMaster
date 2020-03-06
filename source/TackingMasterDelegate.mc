using Toybox.WatchUi;
using Toybox.System as System;



// This class implements basic input handling.
class TackingMasterDelegate extends WatchUi.BehaviorDelegate {

    function initialize() {
        BehaviorDelegate.initialize();
    }

    function onMenu() {
//        WatchUi.pushView(new Rez.Menus.MainMenu(), new TackingMasterMenuDelegate(), WatchUi.SLIDE_UP);

        // Generate a new Menu with a drawable Title
        var menu = new WatchUi.Menu2({:title=>new DrawableMenuTitle()});

        // Add menu items for demonstrating toggles, checkbox and icon menu items
        menu.addItem(new WatchUi.MenuItem(WatchUi.loadResource(Rez.Strings.menu_label_Port), WatchUi.loadResource(Rez.Strings.menu_label_Set_Direction), "idSetPortWD", null));
        menu.addItem(new WatchUi.MenuItem(WatchUi.loadResource(Rez.Strings.menu_label_Starb), WatchUi.loadResource(Rez.Strings.menu_label_Set_Direction), "idSetStarbWD", null));
        menu.addItem(new WatchUi.MenuItem(WatchUi.loadResource(Rez.Strings.menu_label_Settings), null, "idSettings", null));
        WatchUi.pushView(menu, new TackingMasterMenuDelegate(), WatchUi.SLIDE_UP );
        return true;
    }

	// @param evt KEY_XXX enum value, KEY_DOWN, KEY_UP, KEY_ENTER, KEY_ESC
    // @return true if handled, false otherwise
    function onKey(keyEvent){
        System.println(keyEvent.getKey());
        
        if (keyEvent.getKey()==KEY_ENTER){
        	//Nothing happens on ENTER
            System.println("KEY_ENTER");
        }
        else if (keyEvent.getKey()==KEY_UP){
	        //Press UP to increase WindDirection with 5 degrees
	        var WindDirection = Application.Storage.getValue("WindDirection");
        	WindDirection += 5;
        	Application.Storage.setValue("WindDirection", WindDirection);
	        System.println("TackingMasterView.initialize - WindDirection=" + WindDirection);
        }
        else if (keyEvent.getKey()==KEY_DOWN){
	        //Press DOWN to decrease WindDirection with 5 degrees
	        var WindDirection = Application.Storage.getValue("WindDirection");
        	WindDirection -= 5;
        	Application.Storage.setValue("WindDirection", WindDirection);
//	        System.println("TackingMasterView.initialize - WindDirection=" + WindDirection);
        }
        else if (keyEvent.getKey()==KEY_ESC){
            System.println("KEY_ESC");
        }
    }
    
}


// This is the custom drawable we will use for our main menu title
class DrawableMenuTitle extends WatchUi.Drawable {
    var mIsTitleSelected = false;

    function initialize() {
        Drawable.initialize({});
    }

    function setSelected(isTitleSelected) {
        mIsTitleSelected = isTitleSelected;
    }

    // Draw the application icon and main menu title
    function draw(dc) {
        var spacing = 2;
        var strMenu=WatchUi.loadResource(Rez.Strings.menu_label_Menu);
        var appIcon = WatchUi.loadResource(Rez.Drawables.LauncherIcon);
        var bitmapWidth = appIcon.getWidth();
        var labelWidth = dc.getTextWidthInPixels(strMenu, Graphics.FONT_MEDIUM);

        var bitmapX = (dc.getWidth() - (bitmapWidth + spacing + labelWidth)) / 2;
        var bitmapY = (dc.getHeight() - appIcon.getHeight()) / 2;
        var labelX = bitmapX + bitmapWidth + spacing;
        var labelY = dc.getHeight() / 2;

        var bkColor = mIsTitleSelected ? Graphics.COLOR_BLUE : Graphics.COLOR_BLACK;
        dc.setColor(bkColor, bkColor);
        dc.clear();

        dc.drawBitmap(bitmapX, bitmapY, appIcon);
        dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);
        dc.drawText(labelX, labelY, Graphics.FONT_MEDIUM, strMenu, Graphics.TEXT_JUSTIFY_LEFT | Graphics.TEXT_JUSTIFY_VCENTER);
    }
}
