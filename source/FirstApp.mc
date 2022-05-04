import Toybox.Application;
import Toybox.Lang;
import Toybox.WatchUi;
using Toybox.Graphics as Gfx;
using Toybox.Application.Properties as Properties;

var AppResource = new Resource();

class FirstApp extends Application.AppBase {
  public var background_color as Gfx.ColorType = Gfx.COLOR_BLACK;
  public var hour_color as Gfx.ColorType;
  public var min_color as Gfx.ColorType;
  public var sec_color as Gfx.ColorType;
  public var time_display = null;
  public var time_font_id as Lang.Number;

  function initialize() {
    AppBase.initialize();
    read_properties();
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
      read_properties();
    } catch (ex) {
      // Code to catch all execeptions
    } finally {
      // Code to execute when
    }

    WatchUi.requestUpdate();
  }

  function read_properties() {
    background_color = Properties.getValue("BackgroundColor");
    hour_color = Properties.getValue("HourColor");
    min_color = Properties.getValue("MinColor");
    sec_color = Properties.getValue("SecColor");
    time_display = Properties.getValue("TimeDisplay");
    time_font_id = Properties.getValue("TimeFont").toNumber();

    if (true) {
      background_color = 0x000000;
      hour_color = 0x007cc3;
      min_color = 0x185be8;
      sec_color = 0x00b0fc;
      time_display = 2;
      time_font_id = 1;
    }
  }
} // end of FirstApp

function getApp() as FirstApp {
  return Application.getApp() as FirstApp;
}

function getRsc() as Resource {
  return AppResource as Resource;
}
