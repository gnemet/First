/*
created: 
*/
using Toybox.Graphics as Gfx;
using Toybox.WatchUi as Ui;
using Toybox.Application as App;
using Toybox.System as Sys;
using Toybox.Math as Math;

import Toybox.Lang;

class FirstView extends Ui.WatchFace {
  var isAwake = false;
  var is_round_screen = null;
  var status = new StatusView();

  function initialize() {
    WatchFace.initialize();
  }

  // Load your resources here
  // https://forums.garmin.com/developer/connect-iq/f/discussion/165912/custom-font-icon

  function onLayout(dc as Dc) as Void {
    //    setLayout(Rez.Layouts.WatchFace(dc));
    status.init(dc);
    is_round_screen =
      Sys.getDeviceSettings().screenShape == Sys.SCREEN_SHAPE_ROUND;
  }

  // Called when this View is brought to the foreground. Restore
  // the state of this View and prepare it to be shown. This includes
  // loading resources into memory.
  function onShow() as Void {
    isAwake = true;
  }

  // Called when this View is removed from the screen. Save the
  // state of this View here. This includes freeing resources from
  // memory.
  function onHide() as Void {}

  // The user has just looked at their watch. Timers and animations may be
  // started here.
  function onExitSleep() as Void {
    isAwake = true;
  }

  // Terminate any active timers and prepare for slow updates.
  function onEnterSleep() as Void {
    isAwake = false;
  }

  // Update the view
  function onUpdate(dc as Dc) as Void {
    dc.setColor(getApp().background_color, getApp().background_color);
    dc.clear();

    draw_time(dc);
    //draw_battery(dc);
    draw_doNotDisturb(dc);
    status.update(dc);

    // Call the parent onUpdate function to redraw the layout
    // View.onUpdate(dc);
  }

  // Handle the partial update event
  // function onPartialUpdate(dc) {
  //   status.drawBackground(dc);
  // }

  function draw_doNotDisturb(dc as Dc) {
    // If this device supports the Do Not Disturb feature,
    // load the associated Icon into memory.
    var dndIcon =
      Sys.getDeviceSettings() has :doNotDisturb
        ? Ui.loadResource(Rez.Drawables.DoNotDisturbIcon)
        : null;
    var dndBuffer as Gfx.BufferedBitmap = null;

    // check to see if device has BufferedBitmap enabled
    dndBuffer =
      null != dndIcon && Toybox.Graphics has :BufferedBitmap
        ? new Gfx.BufferedBitmap({
            :width => dndIcon.getWidth(),
            :height => dndIcon.getHeight(),
            :bitmapResource => dndIcon,
            :palette => [
              Gfx.COLOR_DK_GRAY,
              Gfx.COLOR_LT_GRAY,
              Gfx.COLOR_BLACK,
              Gfx.COLOR_RED,
              Gfx.COLOR_WHITE,
            ],
          }) /* create an off-screen buffer with a palette of four colors */
        : null; /* handle devices without BufferedBitmap */

    // if ( dndBuffer ) {
    //   dc.drawBitmap(100, 100, dndBuffer );
    // }

    // Draw the do-not-disturb icon if we support it and the setting is enabled
    if (null != dndIcon && Sys.getDeviceSettings().doNotDisturb) {
      dc.drawBitmap((dc.getWidth() - dndIcon.getWidth()) / 2, 0, dndIcon);
    }
  }

  function draw_time(dc as Dc) {
    var app = getApp();
    var time_font = getRsc().get_font(app.time_font_id);
    var time_font_heigth =
      dc.getFontHeight(time_font) * getRsc().get_line_spacing(app.time_font_id);

    var lines = getRsc().get_time_lines(app.time_display);
    var num_of_lines = lines.size();
    var all_text_height = num_of_lines * time_font_heigth;
    var x_offset = is_round_screen
      ? get_x_offset(dc.getWidth() / 2, all_text_height / 2)
      : 0;
    var x_pos = dc.getWidth() + x_offset;
    var y_pos = dc.getHeight() / 2 - all_text_height / 2;

    for (var i = 0; i < num_of_lines; i++) {
      y_pos += i ? time_font_heigth : 0;

      var text_dimension = dc.getTextDimensions(lines[i], time_font);
      var y_offset = getRsc().get_y_offset(app.time_font_id);
      var relative_text_height = text_dimension[1] - y_offset;
      var second = Sys.getClockTime().sec;
      var info_text = second.toString() + " " + i.toString();

      if (i) {
        // draw filled rectangle to represent text's color
        dc.setColor(app.min_color, app.min_color);
        dc.fillRectangle(
          x_pos - text_dimension[0] + 1,
          y_pos + 1,
          text_dimension[0],
          text_dimension[1]
        );

        // draw filled rectangle to represent second level
        dc.setColor(app.sec_color, app.sec_color);

        var min_line = num_of_lines == 3 ? 2 : 1;
        var second_height = relative_text_height * (second / 60.0);

        if (i == 1 && min_line == 2) {
          second_height =
            second < 30 ? 2 * second_height : relative_text_height;
        } else if (i == 2 && min_line == 2) {
          second_height =
            second > 30 ? 2 * second_height - relative_text_height : 0;
        }

        dc.fillRectangle(
          x_pos - text_dimension[0] + 1,
          y_pos + 1 + y_offset,
          text_dimension[0],
          second_height
        );

        //        dc.setColor( Gfx.COLOR_ORANGE, Gfx.COLOR_ORANGE );
        //        dc.fillRectangle( 0 //x_pos - text_dimension[0] + 1
        //                        , y_pos + 1 + y_offset
        //                        , text_dimension[0]
        //                        , relative_text_height );

        info_text += " " + second_height.format("%0.0f");
      } // if i

      dc.setColor(
        i ? Gfx.COLOR_TRANSPARENT : app.hour_color,
        app.background_color
      );
      dc.drawText(x_pos, y_pos, time_font, lines[i], Gfx.TEXT_JUSTIFY_RIGHT);
    } // end of for ( i )
  }

  function draw_battery(dc as Dc) {
    // display battery
    var battery = Sys.getSystemStats().battery.toNumber();

    if (battery <= 15) {
      // var battery_color_a = [
      //   0xfc0000, 0xfd1b01, 0xfd3501, 0xfe4b02, 0xfe5b02, 0xfe6f02, 0xff7b03,
      //   0xff8603, 0xff9203, 0xffa303,
      // ];

      dc.setColor(0xff7b03, Gfx.COLOR_TRANSPARENT);
      dc.drawText(
        dc.getWidth() / 2,
        dc.getHeight() - dc.getFontHeight(getRsc().get("battery_font")) - 20,
        getRsc().get("battery_font"),
        (battery + 0.5).toNumber().toString() + "%",
        Gfx.TEXT_JUSTIFY_CENTER
      );
    }
  }

  function get_x_offset(r, h) {
    return Math.sqrt(Math.pow(r, 2) - Math.pow(h, 2)) - r;
  }
}
