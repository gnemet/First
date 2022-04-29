import Toybox.Application;
import Toybox.Lang;

class Resource extends Application.AppBase {
  protected var dict = {
    // "hour_color" => 0x0000ff,
    // "minute_color" => 0x00ff00,
    // "second_color" => 0xff0000,
  };
  protected var fonts = [];
  protected var hours = [];
  protected var minutes = [];
  var time_lines = [];

  function initialize() {
    AppBase.initialize();
  }

  function load() {
    dict["battery_font"] = loadResource(Rez.Fonts.Tahoma);

      fonts.add( { "rsc" => loadResource( Rez.Fonts.Tahoma ), "y_offset" => 0} );
      fonts.add( { "rsc" => loadResource( Rez.Fonts.watchtowerlaser ), "y_offset" => 10});
      fonts.add( { "rsc" => loadResource( Rez.Fonts.australianshepherd ), "y_offset" => 0});
      fonts.add( { "rsc" => loadResource( Rez.Fonts.welshterrier ), "y_offset" => 0});


    dict["DisplayMode"] = loadResource(Rez.Strings.DisplayMode);

    // https://coolors.co/00b0fc-0c87f2-185be8-2434df-2924db-2f0dd6
    var colors = loadResource(Rez.JsonData.FR945);

    // dict["minute_color"] = colors.get("MINUTE").toLongWithBase(16);
    // dict["second_color"] = colors.get("SECOND").toLongWithBase(16);
    // dict["hour_color"] = colors.get("HOUR").toLongWithBase(16);

    hours = loadResource(Rez.JsonData.hour);
    minutes = loadResource(Rez.JsonData.minute);
  }

  function get_font(font_id) {
    return fonts[font_id].get( "rsc" );
  }

  function get_y_offset(font_id) {
    return fonts[font_id].get( "y_offset" );
  }

  function get(name) {
    return dict[name];
  }

  function get_time_lines( time_display ) {
    // get current time
    var clockTime = System.getClockTime();
    var hour = (
      System.getDeviceSettings().is24Hour
        ? clockTime.hour
        : clockTime.hour % 12
        ? clockTime.hour % 12
        : 12
    ).toNumber();

    var minute = clockTime.min;
    var separator = time_display == 1 ? 0 : minutes[minute].find(":");
    time_lines = [
      time_display == 1 ? hour.format( "%d" ) : hours[hour],
      time_display == 1 ? minute.format( "%02d" ) : minutes[minute].substring(0, separator ? separator : 100),
    ];
    if (separator) {
      time_lines.add(minutes[minute].substring(separator + 1, 100));
    }

    return time_lines;
  }
}
