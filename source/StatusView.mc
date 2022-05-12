/*
 * @Author: Gabor Nemet
 * @Email: gbr.nmt@gmail.com
 * @Date: 2022-05-05 11:11:03
 * @Last Modified by:   Gabor Nemet
 * @Last Modified time: 2022-05-05 11:11:03
 * @Description: Description
 */

using Toybox.Graphics as Gfx;
using Toybox.Lang;
using Toybox.Math;
using Toybox.System as Sys;
// using Toybox.Time;
using Toybox.Time.Gregorian;
using Toybox.WatchUi as Ui;
using Toybox.Activity as Act;
using Toybox.Application as App;
using Toybox.StringUtil as StringUtil;

// class Str extends Lang.String {
//   var this ;

//   function initialize() {
//     this = String.initialize();
//   }

//   function lead(a) as Str {
//     return a + this ;
//   }

//   function append(a) as Str {
//     return this + a;
//   }
// }

// This implements a Goal View for the Analog face
class StatusView extends Ui.WatchFace {
  private var pen_width = 4;
  private var degreeStart = 270 + 1 * 30;
  private var degreeEnd = 90 - 1 * 30;
  private var screenShape;

  function initialize() {
    WatchFace.initialize();
    screenShape = Sys.getDeviceSettings().screenShape;
  }

  function init(dc) {}
  function update(dc) {
    draw_status(dc);
  }

  // Draw the watch face background
  // onUpdate uses this method to transfer newly rendered Buffered Bitmaps
  // to the main display.
  // onPartialUpdate uses this to blank the second hand from the previous
  // second before outputing the new one.
  function drawFlags(dc) {
    var settings = Sys.getDeviceSettings();
    var systemStats = Sys.getSystemStats();
    var actinfo = Act.getInfo();
    var flags = "";

    if (settings.tonesOn) {
      flags = flags + "v";
    } else {
      flags = flags + "w";
    }

    if (settings.vibrateOn) {
      flags = flags + "h";
    }

    if (settings.phoneConnected) {
      flags = flags + "p";
    }

    if (settings.notificationCount > 0) {
      flags = flags + "l";
    }

    if (settings.alarmCount > 0) {
      flags = flags + "f";
    }

    if (actinfo.moveBarLevel > Act.MOVE_BAR_LEVEL_MIN) {
      flags = flags + "q";
    }

    if (actinfo.isSleepMode) {
      flags = flags + "i";
    }

    dc.setColor(Gfx.COLOR_BLUE, Gfx.COLOR_TRANSPARENT);

    //  dc.drawText(17, h - 37, fsyms, flags, Gfx.TEXT_JUSTIFY_LEFT);
  }

  // Draw the date string into the provided buffer at the specified location
  function drawDateString(dc, x, y, str) {
    var timeinfo = Gregorian.info(Time.now(), Time.FORMAT_LONG);
    var dateStr = Lang.format("$1$ $2$ $3$", [
      timeinfo.day_of_week,
      timeinfo.month,
      timeinfo.day,
    ]);

    var secStr = timeinfo.sec.format("%0d") + " - " + str;

    dc.setColor(Gfx.COLOR_WHITE, Gfx.COLOR_TRANSPARENT);
    // dc.drawText(x, y, Gfx.FONT_MEDIUM, dateStr, Gfx.TEXT_JUSTIFY_CENTER);
    dc.drawText(x, y, Gfx.FONT_MEDIUM, secStr, Gfx.TEXT_JUSTIFY_RIGHT);

    // Sys.println( secStr ) ;
  }
  function max(a, b) {
    return a > b ? a : b;
  }
  function draw_info(dc as Dc, icons) {
    var actinfo = ActivityMonitor.getInfo();
    var battery = Sys.getSystemStats().battery.toNumber();
    var current_sec = Sys.getClockTime().sec;
    var value_font_id = Gfx.FONT_SYSTEM_LARGE;
    var justification = Gfx.TEXT_JUSTIFY_RIGHT;
    var n = icons.size();
    var i = current_sec / (60 / n);
    var value_str = (icons[i].get("percent") * 100).format("%d") + "%";
    var symbol_str = icons[i].get("letter").toString();
    //var symbol_font_id = getRsc().get_font_rsc_by_id(icons[0].get("font_id"));
    var symbol_font_id = getRsc().get_font_rsc_by_id(7);

    switch (icons[i].get("name")) {
      case "seconds": {
        value_str = (icons[i].get("percent") * 60).format("%d");
        break;
      }
    }

    if (value_str) {
      Sys.println(value_str + " ... " + symbol_str);

      var x_pos = dc.getWidth() / 2;
      var dim = dc.getTextDimensions(value_str, value_font_id);
      var y_pos = dc.getHeight() / 2 - dim[1];

      // dc.setColor(Gfx.COLOR_GREEN, Gfx.COLOR_TRANSPARENT);
      dc.setColor(
        getRsc().status_color_by_percent(icons[i].get("percent")),
        Gfx.COLOR_TRANSPARENT
      );
      dc.drawText(x_pos, y_pos, value_font_id, value_str, justification);

      dc.drawText(
        x_pos,
        y_pos + dim[1],
        symbol_font_id,
        symbol_str,
        justification
      );
    }
  }

  function draw_status(dc as Dc) {
    var actinfo = ActivityMonitor.getInfo();
    var battery = Sys.getSystemStats().battery.toNumber();
    var icons = [];
    var current_sec = Sys.getClockTime().sec;
    var font_id = 5;
    var x_offset = 0;
    // step
    if (actinfo has :stepGoal) {
      actinfo.stepGoal = actinfo.stepGoal ? actinfo.stepGoal : 10000;
      icons.add({
        "name" => "step",
        "letter" => 'Q',
        "font_id" => font_id,
        "percent" => actinfo.steps.toFloat() / actinfo.stepGoal,
        "x_offset" => x_offset,
        "position" => "start",
      });
    }

    // floors
    if (actinfo has :floorsClimbed && actinfo has :floorsClimbedGoal) {
      actinfo.floorsClimbedGoal = actinfo.floorsClimbedGoal
        ? actinfo.floorsClimbedGoal
        : 50;
      icons.add({
        "name" => "floors",
        "letter" => 'e',
        "font_id" => font_id,
        "percent" => actinfo.floorsClimbed.toFloat() /
        actinfo.floorsClimbedGoal,
        "x_offset" => x_offset,
        "position" => "start",
      });
    }

    // activities
    if (actinfo has :activeMinutesWeek && actinfo has :activeMinutesWeekGoal) {
      actinfo.activeMinutesWeekGoal = actinfo.activeMinutesWeekGoal
        ? actinfo.activeMinutesWeekGoal
        : 700;
      icons.add({
        "name" => "activities",
        "letter" => 'o',
        "font_id" => font_id,
        "percent" => actinfo.activeMinutesWeek.total.toFloat() /
        actinfo.activeMinutesWeekGoal,
        "x_offset" => x_offset,
        "position" => "start",
      });
    }
    icons.add({
      "name" => "battery",
      "letter" => 'T',
      "font_id" => font_id,
      "percent" => battery / 100.0,
      "x_offset" => x_offset,
      "position" => "start",
    });
    icons.add({
      "name" => "seconds",
      "letter" => 'a',
      "font_id" => font_id,
      "percent" => current_sec / 59.0,
      "x_offset" => x_offset,
      "position" => "start",
    });

    // seconds
    if (false) {
      Sys.println(
        "Sec:" + current_sec.format("%02d") + " " + current_sec / 59.0 + ":"
      );
    }

    var count_of_arcs = icons.size();
    // draw all arcs
    for (var i = 0; i < count_of_arcs; i++) {
      draw_arc(dc, i, icons[i].get("percent"));
    }
    draw_color_icons(dc, icons, degreeStart, count_of_arcs);
    draw_info(dc, icons);

    // delete all elements
    icons = [];
    var settings = Sys.getDeviceSettings();
    var percent = 40 / 100.0;
    font_id = 6;
    x_offset = 2;

    // do-not-disturb
    icons.add({
      "name" => "do-not-disturb",
      "letter" => settings.doNotDisturb ? 'C' : 'A',
      "font_id" => font_id,
      "percent" => settings.doNotDisturb ? 0.0 : percent,
      "x_offset" => x_offset,
      "position" => "end",
    });
    // alarms
    icons.add({
      "name" => "alarmCount",
      "letter" => settings.alarmCount ? 'N' : 'M',
      "font_id" => font_id,
      "percent" => settings.alarmCount ? 0.0 : percent,
      "x_offset" => x_offset,
      "position" => "end",
    });

    // notification
    if (settings.notificationCount) {
      icons.add({
        "name" => "notificationCount",
        "letter" => settings.notificationCount ? 'D' : null,
        "font_id" => font_id,
        "percent" => percent,
        "x_offset" => x_offset,
        "position" => "end",
      });
    }
    // connectionAvailable
    if (settings.connectionAvailable) {
      icons.add({
        "name" => "connectionAvailable",
        "letter" => settings.connectionAvailable ? 'E' : null,
        "font_id" => font_id,
        "percent" => percent,
        "x_offset" => x_offset,
        "position" => "end",
      });
    }

    // connectionAvailable
    if (settings.phoneConnected) {
      icons.add({
        "name" => "phoneConnected",
        "letter" => settings.phoneConnected ? 'L' : null,
        "font_id" => font_id,
        "percent" => percent,
        "x_offset" => x_offset,
        "position" => "end",
      });
    }

    draw_color_icons(dc, icons, degreeEnd, count_of_arcs);
  }

  function draw_status_stick(dc, step, percent) {
    var stick_count = 4;
    var x_pos = dc.getWidth() / 2;
    var y_pos = dc.getHeight() / 2;
    var r = get_radius(dc, step);
    var angle = (degreeStart - degreeEnd) / stick_count;

    for (var i = 0; i <= stick_count; i++) {}
  }

  function get_radius(dc, step) {
    var r = (dc.getWidth() - pen_width) / 2 - step * pen_width;
    return r;
  }

  function draw_color_icons(dc, icons, degree_position, count_of_arcs) {
    var y_pos =
      dc.getHeight() / 2 +
      Math.sin(Math.toRadians(360 - degree_position)) *
        get_radius(dc, count_of_arcs);

    var font_id = getRsc().get_font_rsc_by_id(icons[0].get("font_id")); // rightest font
    var x_pos =
      get_rightest_point_on_circle(
        dc.getWidth() / 2, // radius
        y_pos + (degree_position > 180 ? -1 : 1) * dc.getFontHeight(font_id)
      ) + 0;

    for (var i = 0; i < icons.size(); i++) {
      font_id = getRsc().get_font_rsc_by_id(icons[i].get("font_id"));
      var str = icons[i].get("letter").toString();
      var x_offset = icons[i].get("x_offset");
      var dim = dc.getTextDimensions(str, font_id);
      x_pos -= dim[0] + x_offset;
      dc.setColor(
        getRsc().status_color_by_percent(icons[i].get("percent")),
        Gfx.COLOR_TRANSPARENT
      );
      if (false) {
        dc.drawPoint(
          x_pos,
          y_pos + (degree_position > 180 ? -1 : 0) * dc.getFontHeight(font_id)
        );
      }
      if (str) {
        dc.drawText(
          x_pos,
          y_pos + (degree_position > 180 ? -1 : 0) * dc.getFontHeight(font_id),
          font_id,
          str,
          Gfx.TEXT_JUSTIFY_RIGHT
        );
      }
    }
  }

  function draw_icons(dc, step, icons) {
    var r = get_radius(dc, step);
    //var font_id = Gfx.FONT_XTINY;
    var font_id = getRsc().get_font_rsc_by_id(5);
    var x_pos =
      dc.getWidth() / 2 + Math.cos(Math.toRadians(360 - degreeStart)) * r;
    var y_pos =
      dc.getHeight() / 2 +
      Math.sin(Math.toRadians(360 - degreeStart)) * r -
      dc.getFontHeight(font_id);

    //dc.setColor(Gfx.COLOR_WHITE, Gfx.COLOR_TRANSPARENT);
    dc.setColor(getApp().sec_color, Gfx.COLOR_TRANSPARENT);
    dc.drawText(x_pos, y_pos, font_id, icons, Gfx.TEXT_JUSTIFY_CENTER);

    //dc.setColor(Gfx.COLOR_RED, Gfx.COLOR_TRANSPARENT);
    //dc.drawPoint(x_pos, y_pos);
  }

  function draw_arc(dc as Dc, step as Lang.Long, percent as Lang.float) {
    var center = [dc.getWidth() / 2, dc.getHeight() / 2];
    var r = get_radius(dc, step);
    var full_arc_degree = degreeStart - degreeEnd;

    // max 100%, min 5%
    var prcnt = percent > 1 ? 1 : percent == 0 ? 0.05 : percent;

    // calculate last segment
    var end_color_index = getRsc().status_index_by_percent(prcnt);

    var last_degree = degreeStart - full_arc_degree * prcnt;

    // start values
    var from_degree = degreeStart;
    var to_degree = degreeStart;

    dc.setPenWidth(pen_width - 1);

    for (var i = 0; i <= end_color_index; i++) {
      to_degree -= getRsc().status_angle_ratio(i) * full_arc_degree;
      if (false && step == 4) {
        // sec
        Sys.println(from_degree + " " + to_degree + " " + last_degree);
      }
      // last segment
      if (false && from_degree >= last_degree && to_degree < last_degree) {
        to_degree = last_degree;
      }

      dc.setColor(
        i == -1 ? Gfx.COLOR_WHITE : getRsc().status_color(i),
        Gfx.COLOR_TRANSPARENT
      );
      dc.drawArc(
        center[0],
        center[1],
        r,
        Gfx.ARC_CLOCKWISE,
        from_degree,
        to_degree
      );
      from_degree = to_degree;
    }

    return step + 1;
  }

  function get_rightest_point_on_circle(radius, y) {
    var right_x =
      Math.sqrt(Math.pow(radius, 2) - Math.pow(y - radius, 2)) + radius;

    // https://mathworld.wolfram.com/Circle-LineIntersection.html

    // var x1 = p_x1 - dc.getWidth() / 2 ;
    // var y1 = p_y1 - dc.getHeight() / 2 ;
    // var x2 = x1 + 1000 /* infiniti line */;
    // var y2 = y1 ;
    // var r = dc.getWidth() / 2 ;
    // var dx = x2 - x1 ;
    // var dy = y2 - y1 ;
    // var dr = Math.sqrt( Math.pow( dx, 2) + Math.pow( dy, 2) ) ;
    // var D = x1*y2 - x2*y1 ;

    // var xi = ( D*dy + dx * Math.sqrt( Math.pow( r, 2) * Math.pow( dr, 2) - Math.pow( D, 2) ) ) / ( Math.pow( dr, 2) ) + dc.getWidth() / 2;
    // var yi = ( -D*dx + dy * Math.sqrt( Math.pow( r, 2) * Math.pow( dr, 2) - Math.pow( D, 2) ) ) / ( Math.pow( dr, 2) ) + dc.getHeight() / 2;

    return right_x;
  }
}
