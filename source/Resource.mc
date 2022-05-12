/*
 * @Author: Gabor Nemet
 * @Email: gbr.nmt@gmail.com
 * @Date: 2022-05-05 11:10:52
 * @Last Modified by:   Gabor Nemet
 * @Last Modified time: 2022-05-05 11:10:52
 * @Description: Description
 */
// https://garmin.watchfacebuilder.com/

using Toybox.System as Sys;
using Toybox.Application;
using Toybox.Lang;
using Toybox.Graphics as Gfx;

class Resource extends Application.AppBase {
  protected var dict = {};
  protected var fonts = [];
  protected var text_hours = [];
  protected var text_minutes = [];
  protected var color_palette = [];
  protected var status_colors = [
    { "percent" => 00, "angle_ratio" => 0.1, "color" => Gfx.COLOR_RED },
    { "percent" => 10, "angle_ratio" => 0.15, "color" => Gfx.COLOR_PURPLE },
    { "percent" => 30, "angle_ratio" => 0.15, "color" => Gfx.COLOR_PINK },
    { "percent" => 50, "angle_ratio" => 0.2, "color" => Gfx.COLOR_ORANGE },
    { "percent" => 70, "angle_ratio" => 0.15, "color" => Gfx.COLOR_YELLOW },
    { "percent" => 80, "angle_ratio" => 0.15, "color" => Gfx.COLOR_DK_GREEN },
    { "percent" => 90, "angle_ratio" => 0.1, "color" => Gfx.COLOR_GREEN },
    {
      "percent" => 100,
      "angle_ratio" => 0.0,
      "color" => Gfx.COLOR_TRANSPARENT,
    },
  ];

  var time_lines = [];

  function initialize() {
    AppBase.initialize();
  }

  function load() {
    dict["battery_font"] = loadResource(Rez.Fonts.Tahoma);

    fonts.add({
      "id" => 1,
      "name" => "Tahoma",
      "rsc" => loadResource(Rez.Fonts.Tahoma),
      "y_offset" => 0,
      "line_spacing" => 1.0,
    });
    fonts.add({
      "id" => 2,
      "name" => "watchtowerlaser",
      "rsc" => loadResource(Rez.Fonts.watchtowerlaser),
      "y_offset" => 5,
      "line_spacing" => 0.9,
    });
    fonts.add({
      "id" => 3,
      "name" => "australianshepherd",
      "rsc" => loadResource(Rez.Fonts.australianshepherd),
      "y_offset" => 0,
      "line_spacing" => 1.0,
    });
    fonts.add({
      "id" => 4,
      "name" => "welshterrier",
      "rsc" => loadResource(Rez.Fonts.welshterrier),
      "y_offset" => 0,
      "line_spacing" => 1.0,
    });
    fonts.add({
      "id" => 5,
      "name" => "connect",
      "rsc" => loadResource(Rez.Fonts.connect),
      "y_offset" => 0,
      "line_spacing" => 1.0,
    });
    fonts.add({
      "id" => 6,
      "name" => "fontello",
      "rsc" => loadResource(Rez.Fonts.fontello),
      "y_offset" => 0,
      "line_spacing" => 1.0,
    });
    fonts.add({
      "id" => 7,
      "name" => "connect24",
      "rsc" => loadResource(Rez.Fonts.connect24),
      "y_offset" => 0,
      "line_spacing" => 1.0,
    });

    dict["DisplayMode"] = loadResource(Rez.Strings.DisplayMode);

    // color_palette = loadResource(Rez.JsonData.GreenYellowRed);
    color_palette = loadResource(Rez.JsonData.Paletta64);

    // over write default colors
    status_colors[0].put("color", color_palette[6 * 8 + 0].toLongWithBase(16));
    status_colors[1].put("color", color_palette[6 * 8 + 5].toLongWithBase(16));
    status_colors[2].put("color", color_palette[7 * 8 + 0].toLongWithBase(16));
    status_colors[3].put("color", color_palette[7 * 8 + 5].toLongWithBase(16));
    status_colors[4].put("color", color_palette[5 * 8 + 5].toLongWithBase(16));
    status_colors[5].put("color", color_palette[1 * 8 + 1].toLongWithBase(16));
    status_colors[6].put("color", color_palette[1 * 8 + 6].toLongWithBase(16));

    // { "percent" => 00, "angle_ratio" => 0.10, "color" => Gfx.COLOR_RED },
    // { "percent" => 10, "angle_ratio" => 0.15, "color" => Gfx.COLOR_PURPLE },
    // { "percent" => 30, "angle_ratio" => 0.15, "color" => Gfx.COLOR_PINK },
    // { "percent" => 50, "angle_ratio" => 0.20, "color" => Gfx.COLOR_ORANGE },
    // { "percent" => 70, "angle_ratio" => 0.15, "color" => Gfx.COLOR_YELLOW },
    // { "percent" => 80, "angle_ratio" => 0.15, "color" => Gfx.COLOR_DK_GREEN },
    // { "percent" => 90, "angle_ratio" => 0.10, "color" => Gfx.COLOR_GREEN },

    // dict["minute_color"] = colors.get("MINUTE").toLongWithBase(16);
    // dict["second_color"] = colors.get("SECOND").toLongWithBase(16);
    // dict["hour_color"] = colors.get("HOUR").toLongWithBase(16);

    text_hours = loadResource(Rez.JsonData.hour);
    text_minutes = loadResource(Rez.JsonData.minute);
  }

  function status_count() {
    return status_colors.size();
  }

  function status_angle_ratio(i) {
    return status_colors[i].get("angle_ratio");
  }

  function status_color(i) {
    return status_colors[i].get("color");
  }

  function status_index_by_percent(percent) {
    for (var i = 0; i < status_count() - 1; i++) {
      var prcnt_from = status_colors[i].get("percent") / 100.0;
      var prcnt_to = status_colors[i + 1].get("percent") / 100.0;
      // return index if found in segment
      if (percent <= prcnt_to && percent >= prcnt_from) {
        return i;
      }
    }
    // error
    return null;
  }

  function status_color_by_percent(percent) {
    var i = status_index_by_percent(percent);

    return status_color(i);
  }

  function get_font_rsc(index) {
    return fonts[index].get("rsc");
  }

  function get_font_rsc_by_id(id) {
    return get_font_rsc(get_font_index(id));
  }

  function get_font_index(id) {
    for (var i = 0; i < fonts.size(); i++) {
      if (fonts[i].get("id") == id) {
        return i;
      }
    }
    // error
    return null;
  }
  function get_font_index_by_name(name) {
    for (var i = 0; i < fonts.size(); i++) {
      if (fonts[i].get("name") == name) {
        return i;
      }
    }
    // error
    return null;
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
    var clockTime = Sys.getClockTime();
    var hour = (
      Sys.getDeviceSettings().is24Hour
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
