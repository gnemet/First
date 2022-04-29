import Toybox.Graphics;
import Toybox.Lang;
import Toybox.System;
import Toybox.WatchUi;

class FirstView extends WatchUi.WatchFace {
  var isAwake = false;
  var is_round_screen = null;
  var resource = new Resource();

  function initialize() {
    WatchFace.initialize();
  }

  // Load your resources here
  // https://forums.garmin.com/developer/connect-iq/f/discussion/165912/custom-font-icon

  function onLayout(dc as Dc) as Void {
    //    setLayout(Rez.Layouts.WatchFace(dc));

    // load resources
    resource.load();
    is_round_screen =
      System.getDeviceSettings().screenShape == System.SCREEN_SHAPE_ROUND;
  }

  // Called when this View is brought to the foreground. Restore
  // the state of this View and prepare it to be shown. This includes
  // loading resources into memory.
  function onShow() as Void {
    isAwake = true;
  }

  // Update the view
  //  function onUpdate(dc as Dc) as Void {
  //    // Get and show the current time
  //    var clockTime = System.getClockTime();
  //    var timeString = Lang.format("$1$:$2$:$3$",
  //    [clockTime.hour.format("%02d"), clockTime.min.format("%02d"),
  //    clockTime.sec.format("%02d")]); var view =
  //    View.findDrawableById("TimeLabel") as Text; view.setText(timeString);
  //
  //    // Call the parent onUpdate function to redraw the layout
  //    View.onUpdate(dc);
  //  }

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
    var background_color = Application.getApp().getProperty("BackgroundColor");
    var hour_color = Application.getApp().getProperty("HourColor");
    var min_color = Application.getApp().getProperty("MinColor");
    var sec_color = Application.getApp().getProperty("SecColor");
    var time_display = Application.getApp().getProperty("TimeDisplay");

    var time_font = resource.get_font(
      Application.getApp().getProperty("TimeFont")
    );

    dc.setColor(background_color, background_color);
    dc.clear();

    var lines = resource.get_time_lines( time_display );


time_display = 2 ;


    switch (time_display) {
      case 1: {
        var lines_str = Lang.format("$1$:$2$\n$3$", [
          System.getClockTime().hour.format("%d"),
          System.getClockTime().min.format("%02d"),
          System.getClockTime().sec.format("%02d"),
        ]);

        var text_dimension = dc.getTextDimensions(lines_str, time_font);
        var x_offset = is_round_screen
          ? get_x_offset(dc.getWidth() / 2, text_dimension[1] / 2)
          : 0;
        var x_pos = dc.getWidth() + x_offset;
        var y_pos = (dc.getHeight() - text_dimension[1]) / 2;

        // display text lines
        dc.setColor(hour_color, Graphics.COLOR_TRANSPARENT);

        dc.drawText(
          x_pos,
          y_pos,
          time_font,
          lines_str,
          Graphics.TEXT_JUSTIFY_RIGHT
        );
        break;
      } // case 1
      case 2: {
        var num_of_lines = lines.size();
        var all_text_height = num_of_lines * dc.getFontHeight(time_font);
        var x_offset = is_round_screen
          ? get_x_offset(dc.getWidth() / 2, all_text_height / 2)
          : 0;
        var x_pos = dc.getWidth() + x_offset;
        var y_pos = dc.getHeight() / 2 - all_text_height / 2;

        for (var i = 0; i < num_of_lines; i++) {
          y_pos += (i ? 1 : 0) * dc.getFontHeight(time_font);

          var text_dimension = dc.getTextDimensions(lines[i], time_font);
          var y_offset = 10;
          var relative_text_height = text_dimension[1] - y_offset;
          var second = System.getClockTime().sec;
          var info_text = second.toString() + " " + i.toString();

          if (i) {
            // draw filled rectangle to represent text's color
            dc.setColor(min_color, min_color);
            dc.fillRectangle(
              x_pos - text_dimension[0] + 1,
              y_pos + 1,
              text_dimension[0],
              text_dimension[1]
            );

            // draw filled rectangle to represent second level
            dc.setColor(sec_color, sec_color);

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

            //        dc.setColor( Graphics.COLOR_ORANGE, Graphics.COLOR_ORANGE );
            //        dc.fillRectangle( 0 //x_pos - text_dimension[0] + 1
            //                        , y_pos + 1 + y_offset
            //                        , text_dimension[0]
            //                        , relative_text_height );

            info_text += " " + second_height.format("%0.0f");
          } // if i

          dc.setColor(
            i ? Graphics.COLOR_TRANSPARENT : hour_color,
            //Graphics.COLOR_TRANSPARENT
            background_color
          );
          dc.drawText(
            x_pos,
            y_pos,
            time_font,
            lines[i],
            Graphics.TEXT_JUSTIFY_RIGHT
          );

          //      dc.setColor( Graphics.COLOR_ORANGE, Graphics.COLOR_BLACK);
          //      dc.drawText( dc.getWidth() / 2, dc.getHeight() -
          //      dc.getFontHeight( resource.get( "battery_font" ) )
          //                 , resource.get( "battery_font" )
          //                 , info_text
          //                 , Graphics.TEXT_JUSTIFY_CENTER
          //                 );
        }
        break;
      } // case 2
      default: {
        dc.setColor(Graphics.COLOR_RED, Graphics.COLOR_BLACK);
        dc.drawText(
          0,
          0,
          time_font,
          "no display mode",
          Graphics.TEXT_JUSTIFY_LEFT
        );
        break;
      }
    } // switch time_display

    // display battery
    var battery = System.getSystemStats().battery.toLong();
    if (battery <= 15) {
      var battery_color_a = [
        0xfc0000, 0xfd1b01, 0xfd3501, 0xfe4b02, 0xfe5b02, 0xfe6f02, 0xff7b03,
        0xff8603, 0xff9203, 0xffa303,
      ];
      var battery_color_index = 7; // battery >= 0 && battery <
      // battery_color_a.size() ? battery : 0  ;

      dc.setColor(
        battery_color_a[battery_color_index],
        Graphics.COLOR_TRANSPARENT
      );
      dc.drawText(
        dc.getWidth() / 2,
        dc.getHeight() - dc.getFontHeight(resource.get("battery_font")),
        resource.get("battery_font"),
        battery_color_index.toString() + "%",
        Graphics.TEXT_JUSTIFY_CENTER
      );
    }

    // Call the parent onUpdate function to redraw the layout
    // View.onUpdate(dc);
  }

  function get_x_offset(r, h) {
    return Math.sqrt(Math.pow(r, 2) - Math.pow(h, 2)) - r;
  }
}
