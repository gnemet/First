import Toybox.Application;
import Toybox.Lang;
import Toybox.WatchUi;
using Toybox.Graphics as Gpx;

class FirstApp extends Application.AppBase {
  public var background_color as Graphics.ColorType = Gpx.COLOR_BLACK;

  function initialize() {
    AppBase.initialize();
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
      background_color = getProperty("BackgroundColor");
    } catch (ex) {
      // Code to catch all execeptions
    } finally {
      // Code to execute when
    }

    WatchUi.requestUpdate();
  }
}

function getApp() as FirstApp {
  return Application.getApp() as FirstApp;
}
