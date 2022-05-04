import Toybox.Application;
import Toybox.Lang;

class Resource extends Application.AppBase {
  protected var dict = {};
  protected var fonts = [];
  protected var text_hours = [];
  protected var text_minutes = [];
  protected var colors = [];

  var time_lines = [];

  function initialize() {
    AppBase.initialize();
  }

  function load() {
    dict["battery_font"] = loadResource(Rez.Fonts.Tahoma);

    fonts.add({
      "rsc" => loadResource(Rez.Fonts.Tahoma),
      "y_offset" => 0,
      "line_spacing" => 1.0,
    });
    fonts.add({
      "rsc" => loadResource(Rez.Fonts.watchtowerlaser),
      "y_offset" => 5,
      "line_spacing" => 0.9,
    });
    fonts.add({
      "rsc" => loadResource(Rez.Fonts.australianshepherd),
      "y_offset" => 0,
      "line_spacing" => 1.0,
    });
    fonts.add({
      "rsc" => loadResource(Rez.Fonts.welshterrier),
      "y_offset" => 0,
      "line_spacing" => 1.0,
    });
    fonts.add({
      "rsc" => loadResource(Rez.Fonts.connect),
      "y_offset" => 0,
      "line_spacing" => 1.0,
    });

    dict["DisplayMode"] = loadResource(Rez.Strings.DisplayMode);

    colors = loadResource(Rez.JsonData.GreenYellowRed);

    // dict["minute_color"] = colors.get("MINUTE").toLongWithBase(16);
    // dict["second_color"] = colors.get("SECOND").toLongWithBase(16);
    // dict["hour_color"] = colors.get("HOUR").toLongWithBase(16);

    text_hours = loadResource(Rez.JsonData.hour);
    text_minutes = loadResource(Rez.JsonData.minute);
  }

  function get_count_of_colors() {
    return colors.size();
  }

  function get_color(index_of_color, is_reverse) {
    var i = is_reverse
      ? get_count_of_colors() - index_of_color - 1
      : index_of_color;

    return colors[i].toLongWithBase(16);
  }

  function get_font(font_id) {
    return fonts[font_id].get("rsc");
  }

  function get_y_offset(font_id) {
    return fonts[font_id].get("y_offset");
  }

  function get_line_spacing(font_id) {
    return fonts[font_id].get("line_spacing");
  }

  function get(name) {
    return dict[name];
  }

  function get_time_lines(time_display) {
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
    var separator = time_display == 1 ? 0 : text_minutes[minute].find(":");
    time_lines = [
      time_display == 1 ? hour.format("%d") : text_hours[hour],
      time_display == 1
        ? minute.format("%02d")
        : text_minutes[minute].substring(0, separator ? separator : 100),
    ];
    if (separator) {
      time_lines.add(text_minutes[minute].substring(separator + 1, 100));
    }

    return time_lines;
  }
}
