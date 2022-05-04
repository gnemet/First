using Toybox.Graphics as Gfx;
using Toybox.Lang;
using Toybox.System as Sys;
// using Toybox.Time;
// using Toybox.Time.Gregorian;
using Toybox.WatchUi as Ui;
using Toybox.Application as App;
using Toybox.StringUtil as StringUtil;

// This implements a Goal View for the Analog face
class StatusView extends Ui.WatchFace {
  private var pen_width = 4;
  private var degreeStart = 270 + 1 * 30;
  private var degreeEnd = 60;

  function initialize() {
    WatchFace.initialize();
  }

  function draw_arc(dc as Dc) {
    var info = ActivityMonitor.getInfo();
    var step = 0;
    var battery = Sys.getSystemStats().battery.toNumber();
    var connect_icons = [] as Lang.Array<Lang.Char>;

    // step
    if (info has :stepGoal) {
      info.stepGoal = info.stepGoal ? info.stepGoal : 10000;
      var percent = info.steps.toFloat() / info.stepGoal;
      step = draw_status(dc, step, percent);
      connect_icons.add('Q');
    }
    // floors
    if (info has :floorsClimbed && info has :floorsClimbedGoal) {
      info.floorsClimbedGoal = info.floorsClimbedGoal
        ? info.floorsClimbedGoal
        : 50;
      var percent = info.floorsClimbed.toFloat() / info.floorsClimbedGoal;
      step = draw_status(dc, step, percent);
      connect_icons.add('e');
    }
    // activities
    if (info has :activeMinutesWeek && info has :activeMinutesWeekGoal) {
      info.activeMinutesWeekGoal = info.activeMinutesWeekGoal
        ? info.activeMinutesWeekGoal
        : 700;
      var percent =
        info.activeMinutesWeek.total.toFloat() / info.activeMinutesWeekGoal;
      step = draw_status(dc, step, percent);
      connect_icons.add('o');
    }

    // battery
    if (battery) {
      step = draw_status(dc, step, battery / 100.0);
      // connect_icons.add('S');
      connect_icons.add('T');
    }

    draw_icons(dc, step, connect_icons);
  }

  function get_radius(dc, step) {
    var r = (dc.getWidth() - pen_width) / 2 - step * pen_width;
    return r;
  }

  function draw_icons(dc, step, icons) {
    var r = get_radius(dc, step);
    //var font_id = Gfx.FONT_XTINY;
    var font_id = getRsc().get_font( 4 ) ;
    var x_pos =
      dc.getWidth() / 2 + Math.cos(Math.toRadians(360 - degreeStart)) * r;
    var y_pos =
      dc.getHeight() / 2 +
      Math.sin(Math.toRadians(360 - degreeStart)) * r -
      dc.getFontHeight(font_id);
    var str = "" ;

    for ( var i = icons.size() - 1; i >= 0 ; i-- ){
      str += icons[i] ;
    }

    //dc.setColor(Gfx.COLOR_WHITE, Gfx.COLOR_TRANSPARENT);
    dc.setColor( getApp().sec_color, Gfx.COLOR_TRANSPARENT);
    dc.drawText(
      x_pos,
      y_pos,
      font_id,
      // StringUtil.charArrayToString(icons),
      str,
      Gfx.TEXT_JUSTIFY_CENTER
    );

    //dc.setColor(Gfx.COLOR_RED, Gfx.COLOR_TRANSPARENT);
    //dc.drawPoint(x_pos, y_pos);
  }

  function draw_status(dc as Dc, step as Lang.Long, percent as Lang.float) {
    var x_pos = dc.getWidth() / 2;
    var y_pos = dc.getHeight() / 2;
    var r = get_radius(dc, step);
    var prcnt = percent != 0 ? (percent > 1 ? 1 : percent) : 0.05;
    var color_index = (prcnt * getRsc().get_count_of_colors() + 0.5).toNumber();
    var angle = (degreeStart - degreeEnd) / getRsc().get_count_of_colors();

    dc.setPenWidth(pen_width - 1);
    for (var i = 0; i < color_index; i++) {
      dc.setColor(
        i == -1 ? Gfx.COLOR_WHITE : getRsc().get_color(i, 1),
        Gfx.COLOR_TRANSPARENT
      );
      dc.drawArc(
        x_pos,
        y_pos,
        r,
        Gfx.ARC_CLOCKWISE,
        degreeStart - i * angle,
        degreeStart - (i + 1) * angle
      );
    }

    return step + 1;
  }
}
