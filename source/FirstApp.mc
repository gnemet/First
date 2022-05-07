/*
 * @Author: Gabor Nemet
 * @Email: gbr.nmt@gmail.com
 * @Date: 2022-05-05 11:10:23
 * @Last Modified by:   Gabor Nemet
 * @Last Modified time: 2022-05-05 11:10:23
 * @Description: Description
 */

import Toybox.Application;
import Toybox.Lang;
import Toybox.WatchUi;
using Toybox.Graphics as Gfx;
using Toybox.Application.Properties as Properties;

var AppResource = new Resource();

class FirstApp extends Application.AppBase {
  public var background_color as Gfx.ColorType = Gfx.COLOR_BLACK;
  public var hour_color as Gfx.ColorType = Gfx.COLOR_DK_BLUE;
  public var min_color as Gfx.ColorType = Gfx.COLOR_BLUE;
  public var sec_color as Gfx.ColorType = Gfx.COLOR_WHITE;
  public var time_display as Lang.Number = 2;
  public var time_font_id as Lang.Number = 1;

  function initialize() {
    AppBase.initialize();
    read_properties( false );
    AppResource.load();
  }

  // onStart() is called on application start up
  function onStart(state as Dictionary?) as Void {}

  // onStop() is called when your application is exiting
  function onStop(state as Dictionary?) as Void {}

  // Return the initial view of your application here
  function getInitialView() as Array<Views or InputDelegates>? {
    return [new FirstView()] as Array<Views or InputDelegates>;
  }

  // For this app all that needs to be done is trigger a WatchUi refresh
  // since the settings are only used in onUpdate().
  function onSettingsChanged() {
    try {
      read_properties( true );
    } catch (ex) {
      // Code to catch all execeptions
    } finally {
      // Code to execute when
    }

    WatchUi.requestUpdate();
  }

  function read_properties(bUseProperties) {
    if (bUseProperties) {
      background_color = Properties.getValue("BackgroundColor");
      hour_color = Properties.getValue("HourColor");
      min_color = Properties.getValue("MinColor");
      sec_color = Properties.getValue("SecColor");
      time_display = Properties.getValue("TimeDisplay");
      time_font_id = Properties.getValue("TimeFont").toNumber();
    }
  }
} // end of FirstApp

function getApp() as FirstApp {
  return Application.getApp() as FirstApp;
}

function getRsc() as Resource {
  return AppResource as Resource;
}
