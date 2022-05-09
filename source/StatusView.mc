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
  function drawDateString(dc, x, y) {
    var timeinfo = Gregorian.info(Time.now(), Time.FORMAT_LONG);
    var dateStr = Lang.format("$1$ $2$ $3$", [
      timeinfo.day_of_week,
      timeinfo.month,
      timeinfo.day,
    ]);

    dc.setColor(Gfx.COLOR_WHITE, Gfx.COLOR_TRANSPARENT);
    dc.drawText(x, y, Gfx.FONT_MEDIUM, dateStr, Gfx.TEXT_JUSTIFY_CENTER);
  }
  function max(a, b) {
    return a > b ? a : b;
  }

  function draw_status(dc as Dc) {
    var actinfo = ActivityMonitor.getInfo();
    var step = 0;
    var battery = Sys.getSystemStats().battery.toNumber();
    //var connect_icons = "";
    var icons = [];
    var max_percent = 0;
    var current_sec = Sys.getClockTime().sec ;

    // step
    if (actinfo has :stepGoal) {
      actinfo.stepGoal = actinfo.stepGoal ? actinfo.stepGoal : 10000;
      var percent = actinfo.steps.toFloat() / actinfo.stepGoal;
      step = draw_arc(dc, step, percent);
      //connect_icons = 'Q' + connect_icons;
      max_percent = max(max_percent, percent);

      icons.add({ "letter" => 'Q', "font_id" => 4, "percent" => percent });
    }
    // floors
    if (actinfo has :floorsClimbed && actinfo has :floorsClimbedGoal) {
      actinfo.floorsClimbedGoal = actinfo.floorsClimbedGoal
        ? actinfo.floorsClimbedGoal
        : 50;
      var percent = actinfo.floorsClimbed.toFloat() / actinfo.floorsClimbedGoal;
      step = draw_arc(dc, step, percent);
      //connect_icons = 'e' + connect_icons;
      max_percent = max(max_percent, percent);

      icons.add({ "letter" => 'e', "font_id" => 4, "percent" => percent });
    }
    // activities
    if (actinfo has :activeMinutesWeek && actinfo has :activeMinutesWeekGoal) {
      actinfo.activeMinutesWeekGoal = actinfo.activeMinutesWeekGoal
        ? actinfo.activeMinutesWeekGoal
        : 700;
      var percent =
        actinfo.activeMinutesWeek.total.toFloat() /
        actinfo.activeMinutesWeekGoal;
      step = draw_arc(dc, step, percent);
      //connect_icons = 'o' + connect_icons;
      max_percent = max(max_percent, percent);

      icons.add({ "letter" => 'o', "font_id" => 4, "percent" => percent });
    }
    // battery
    if (battery) {
      var percent = battery / 100.0;
      step = draw_arc(dc, step, percent);
      //connect_icons = 'T' + connect_icons;
      max_percent = max(max_percent, percent);

      icons.add({ "letter" => 'T', "font_id" => 4, "percent" => percent });
    }

    // seconds
    if (true) {
      var percent = current_sec.toFloat() / 60.0;
      step = draw_arc(dc, step, percent);
      //connect_icons = 'a' + connect_icons;
      max_percent = max(max_percent, percent);

      icons.add({ "letter" => 'a', "font_id" => 4, "percent" => percent });
    }

    //draw_icons(dc, step, connect_icons);

    draw_color_icons(dc, icons);
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
  function draw_color_icons(dc, icons) {
    var y_pos =
      dc.getHeight() / 2 +
      Math.sin(Math.toRadians(360 - degreeStart)) *
        get_radius(dc, icons.size());
    var font_id = getRsc().get_font(icons[0].get("font_id")); // rightest font
    var x_pos =
      get_rightest_point_on_circle(
        dc.getWidth() / 2,
        y_pos - 1 * dc.getFontHeight(font_id)
      ) + 0;

    for (var i = 0; i < icons.size(); i++) {
      font_id = getRsc().get_font(icons[i].get("font_id"));
      var str = icons[i].get("letter").toString();
      var dim = dc.getTextDimensions(str, font_id);
      x_pos -= dim[0];
      dc.setColor(
        getRsc().status_color_by_percent(icons[i].get("percent")),
        Gfx.COLOR_TRANSPARENT
      );
      dc.drawText(
        x_pos,
        y_pos - dc.getFontHeight(font_id),
        font_id,
        str,
        Gfx.TEXT_JUSTIFY_RIGHT
      );
    }
  }

  function draw_icons(dc, step, icons) {
    var r = get_radius(dc, step);
    //var font_id = Gfx.FONT_XTINY;
    var font_id = getRsc().get_font(4);
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
    var x_pos = dc.getWidth() / 2;
    var y_pos = dc.getHeight() / 2;
    var r = get_radius(dc, step);

    var prcnt = percent > 1 ? 1 : percent;
    var end_color_index = getRsc().status_index_by_percent(prcnt);
    //var min_degree = degreeStart - ( (degreeStart - degreeEnd) * prcnt ) ;
    var from_degree = degreeStart;
    var to_degree = degreeStart;

    dc.setPenWidth(pen_width - 1);

    for (var i = 0; i <= end_color_index; i++) {
      to_degree -= getRsc().status_angle_ratio(i) * (degreeStart - degreeEnd);
     // to_degree = to_degree > min_degree ? min_degree : to_degree  ;

      dc.setColor(
        i == -1 ? Gfx.COLOR_WHITE : getRsc().status_color(i),
        Gfx.COLOR_TRANSPARENT
      );
      dc.drawArc(x_pos, y_pos, r, Gfx.ARC_CLOCKWISE, from_degree, to_degree);
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
