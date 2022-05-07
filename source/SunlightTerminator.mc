using Toybox.Math as Math;
using Toybox.System as Sys;
using Toybox.WatchUi as Ui;
using Toybox.Graphics as Gfx;

// https://datawillconfess.blogspot.com/2016/03/open-source-connect-iq-face-for-garmin.html
// By using updateable_sunlight_terminator the terminator will be drawn, but it will
// only be recalculated every 300 seconds. The declination will be recalculated daily.
class SunlightTerminator {
    var earthx, earthy, width, height;
    var c_declination, t_declination; // day of month when last updated
    var c_sunlight, t_sunlight; // time in seconds of next update.

    var image;

    function initialize(earth_bitmap, w, h, x, y) {
        image = earth_bitmap;
       
        t_declination = -1;
        t_sunlight = -1;
       
        earthx = x;
        earthy = y;
        width = w;
        height = h;
       
    }
   
    function sun_declination(dateinfo) {
        var jul = julian( dateinfo.year,  dateinfo.month,  dateinfo.day);
        var radians = Math.PI/180.0;
        var lambda = ecliptic_longitude(jul, radians);
        var obliquity = 23.439 * radians - 0.0000004 * radians * jul;
        var delta = Math.asin(Math.sin(obliquity) * Math.sin(lambda));
        if (delta == 0) {
            return 0.000001;
        } else {
            return delta;       
        }
    }

    function updateable_sun_declination(dateinfo) {
        if (t_declination != dateinfo.day) {
            c_declination = sun_declination(dateinfo);
            t_declination = dateinfo.day;
        }
        return c_declination;
    }
   
    function ecliptic_longitude(jul, radians) {
        var meanlongitude = getAngle(280.461 * radians + 0.9856474 * radians * jul);
        var meananomaly = getAngle(357.528 * radians + .9856003 * radians * jul);
        return getAngle(meanlongitude + 1.915 * radians * Math.sin(meananomaly)
                        + 0.02 * radians * Math.sin(2.0 * meananomaly));
    }

    // returns a floating point angle in the range 0 .. 2*pi
    function getAngle(x) {
        var b = 0.5*x / Math.PI;
        var a = 2.0*Math.PI * (b - b.toNumber());
        if (a < 0) {
            a = 2.0*Math.PI + a;
        }
        return a;
    }
   
    // between 1901 to 2099
    function julian( y,  m,  d) {
        var a = (m + 9)/12.0;
        var b = (y + a.toNumber())/4.0;
        var c = 275*m/9.0;
        var l = -7 * b.toNumber() + c.toNumber() + d;
        l = l.toNumber() + y*367;
        return l - 730531;
    }
       
    function updateable_sunlight_terminator(dc, time_sec, dateinfo, time) {
        if (time_sec.value() > t_sunlight) {
            t_sunlight = time_sec.value()+300; // update interval of 300 seconds
   
            updateable_sun_declination(dateinfo);
            calc_sunlight_terminator(dc, c_declination, time, earthx, earthy, width, height);
            // updates c_sunlight array
        }
        // uses c_sunlight array
        draw_sunlight_terminator(dc, c_declination, time, earthx, earthy, width, height);
    }

    function draw_sunlight_terminator(dc, declination, time, earthx, earthy, width, height){
        dc.drawBitmap(earthx, earthy, image);
        //hide some unnecessary part of the map:
        dc.setColor(Gfx.COLOR_BLACK, Gfx.COLOR_WHITE);
        dc.drawLine(earthx,earthy,earthx+100,earthy);
        dc.fillRectangle(earthx,earthy+47,earthx+100,earthy+50);

        var x, x2;
        if (declination < 0) {
            for (x=1; x<=c_sunlight.size(); x+=1) {
                x2 = earthx + x*2 - 1;
                dc.drawLine(x2, earthy, x2, earthy+c_sunlight[x-1]);
            }
        } else {
            for (x=1; x<=c_sunlight.size(); x+=1) {
                x2 = earthx + x*2 - 1;
                dc.drawLine(x2, earthy+c_sunlight[x-1], x2, earthy+height);
            }
        }
   
    }
   
    function calc_sunlight_terminator(dc, declination, time, earthx, earthy, width, height) {
        var num_el = width / 2;
        c_sunlight = new [num_el.toNumber()];
       
        var hour = (((time.hour*3600-time.timeZoneOffset)%86400) - 43200 + time.min*60.0) / 3600.0;
        //var lat1 = -1.5708; // -pi/2
        //var lat2 = 1.5708; // pi/2
        //var latrange = lat2 - lat1;
        //lat1 = (-lat1+1.5708)/3.1416;

        var latrange = 3.1416;
        var lat1 = 1.0;

        var x, y, longitude, latitude, x2;
        x2 = 0;
        if (declination < 0) {
            for (x=2; x<=width; x+=2) {
                longitude = (x-1.0)/width*6.2832-3.1416+hour/24*6.2832;
                latitude = Math.atan(-Math.cos(longitude)/Math.tan(declination));
                y = (-latitude + 1.5708) / latrange - (1-lat1);
                y = y * height + 0.5;
                y = y.toNumber();
                //x2 = earthx + x - 1;
                //dc.drawLine(x2, earthy, x2, earthy+y);
                c_sunlight[x2] = y;
                x2 += 1;
            }
        } else {
            for (x=2; x<=width; x+=2) {
                longitude = (x-1.0)/width*6.2832-3.1416+hour/24*6.2832;
                latitude = Math.atan(-Math.cos(longitude)/Math.tan(declination));
                y = (-latitude + 1.5708) / latrange - (1-lat1);
                y = y * height + 0.5;
                y = y.toNumber();
                //x2 = earthx + x - 1;
                //dc.drawLine(x2, earthy+y, x2, earthy+height);
                c_sunlight[x2] = y;
                x2 +=1;
            }
        }
    }
 
   

}