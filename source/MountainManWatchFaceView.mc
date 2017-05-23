using Toybox.WatchUi as Ui;
using Toybox.Graphics as Gfx;
using Toybox.System as Sys;
using Toybox.Lang as Lang;
using Toybox.Math as Math;
using Toybox.Time as Time;
using Toybox.Time.Gregorian as Calendar;
using Toybox.Activity as Act;

class MountainManWatchFaceView extends Ui.WatchFace {

    var font;
    var isAwake;
    var screenShape;
    var dndIcon;
    var sensorInfo = null;
    var altitude = null;
    var battery = null;
    var height;
    var width;
    var paddingFromEdge;
    var halfHeight;
    var halfWidth;
    var quarterHeight;
    var quarterWidth;
    var threeQuarterHeight;
    var threeQuarterWidth;
    var smallFontHeight;
	var tinyFontHeight;

    function initialize() {
        WatchFace.initialize();
        screenShape = Sys.getDeviceSettings().screenShape;
        altitude = Act.getActivityInfo().altitude;
        battery = Sys.getSystemStats().battery.toNumber();
    }

    function onLayout(dc) {
        font = Ui.loadResource(Rez.Fonts.id_font_black_diamond);
        height = dc.getHeight();
	    width = dc.getWidth();
	    paddingFromEdge = 2;
	    halfHeight = height / 2;
	    halfWidth = width / 2;
	    quarterHeight = height / 4;
	    quarterWidth = width / 4;
	    threeQuarterHeight = quarterHeight * 3;
	    threeQuarterWidth = quarterWidth * 3;
	    smallFontHeight = Gfx.getFontHeight(Gfx.FONT_SMALL);
	    tinyFontHeight = Gfx.getFontHeight(Gfx.FONT_TINY);
    }

    // Draw the watch hand
    // @param dc Device Context to Draw
    // @param angle Angle to draw the watch hand
    // @param length Length of the watch hand
    // @param width Width of the watch hand
    function drawHand(dc, angle, length, width) {
        // Map out the coordinates of the watch hand
        var coords = [[-(width / 2),0], [-(width / 2), -length], [width / 2, -length], [width / 2, 0]];
        var result = new [4];
        var cos = Math.cos(angle);
        var sin = Math.sin(angle);

        // Transform the coordinates
        for (var i = 0; i < 4; i += 1) {
            var x = (coords[i][0] * cos) - (coords[i][1] * sin);
            var y = (coords[i][0] * sin) + (coords[i][1] * cos);
            result[i] = [halfWidth + x, halfHeight + y];
        }

        // Draw the polygon
        dc.fillPolygon(result);
        dc.fillPolygon(result);
    }
 
    // Handle the update event
    function onUpdate(dc) {
        var clockTime = Sys.getClockTime();
        var hourHand;
        var minuteHand;
        var secondHand;
        var secondTail;
  
        altitude = Act.getActivityInfo().altitude;
        battery = Sys.getSystemStats().battery.toNumber();
        
        var activityInformation = ActivityMonitor.getInfo();

        // Clear the screen
        dc.setColor(Gfx.COLOR_BLACK, Gfx.COLOR_WHITE);
        dc.fillRectangle(0, 0, width, height);
        dc.setColor(Gfx.COLOR_LT_GRAY, Gfx.COLOR_TRANSPARENT);

        // Draw the date - center right
        var dateContainerSize = 74;
        dc.setColor(Gfx.COLOR_DK_GRAY, Gfx.COLOR_LT_GRAY); 
        dc.drawRoundedRectangle(width - dateContainerSize - paddingFromEdge, halfHeight - (smallFontHeight/2 - 1), dateContainerSize, smallFontHeight+2, 2);
        var now = Time.now();
        var info = Calendar.info(now, Time.FORMAT_LONG);
        var dateStr = Lang.format("$1$ | $2$", [info.day_of_week, info.day]);
        dc.setColor(Gfx.COLOR_LT_GRAY, Gfx.COLOR_TRANSPARENT);        
        dc.drawText(width - paddingFromEdge - 4, (halfHeight)-12, Gfx.FONT_SMALL, dateStr, Gfx.TEXT_JUSTIFY_RIGHT);
        
        // Draw the steps - bottom center
		var stepContainerSize = 30;
		dc.setColor(Gfx.COLOR_DK_GRAY, Gfx.COLOR_TRANSPARENT);
		dc.drawCircle(halfWidth, height - (stepContainerSize) - paddingFromEdge, stepContainerSize);
		dc.drawText(halfWidth, height - (stepContainerSize) - paddingFromEdge - (tinyFontHeight - 4), Gfx.FONT_XTINY, "STEPS:", Gfx.TEXT_JUSTIFY_CENTER);
        dc.setColor(Gfx.COLOR_LT_GRAY, Gfx.COLOR_TRANSPARENT);
        dc.drawText(halfWidth, height - (stepContainerSize) - paddingFromEdge - 4, Gfx.FONT_SMALL, activityInformation.steps, Gfx.TEXT_JUSTIFY_CENTER);
        
        // Draw the altitude - top center
		var altitudeContainerSize = 38;
		dc.setColor(Gfx.COLOR_DK_GRAY, Gfx.COLOR_TRANSPARENT);
		dc.drawCircle(halfWidth, (altitudeContainerSize) + paddingFromEdge, altitudeContainerSize);
		dc.drawText(halfWidth, (altitudeContainerSize) - paddingFromEdge - (tinyFontHeight - 4), Gfx.FONT_XTINY, "ALTITUDE:", Gfx.TEXT_JUSTIFY_CENTER);		
        dc.setColor(Gfx.COLOR_LT_GRAY, Gfx.COLOR_TRANSPARENT);
        dc.drawText(halfWidth, (stepContainerSize/2) + paddingFromEdge + tinyFontHeight - 4, Gfx.FONT_SMALL, altitude.format("%1.0f"), Gfx.TEXT_JUSTIFY_CENTER);
        
        // Draw the battery - center left
		var batteryContainerSize = 26;
		dc.setColor(Gfx.COLOR_DK_GRAY, Gfx.COLOR_TRANSPARENT);
		dc.drawCircle(batteryContainerSize + paddingFromEdge, halfHeight, batteryContainerSize);
		dc.drawText(batteryContainerSize + paddingFromEdge, halfHeight - (tinyFontHeight - 4), Gfx.FONT_XTINY, "BATT:", Gfx.TEXT_JUSTIFY_CENTER);
        dc.setColor(Gfx.COLOR_LT_GRAY, Gfx.COLOR_TRANSPARENT);
        dc.setColor(Gfx.COLOR_LT_GRAY, Gfx.COLOR_TRANSPARENT);dc.drawText(batteryContainerSize + paddingFromEdge, halfHeight - 4, Gfx.FONT_SMALL, battery + "%", Gfx.TEXT_JUSTIFY_CENTER);
        
        // Draw the connection status
		dc.setColor(Gfx.COLOR_DK_GRAY, Gfx.COLOR_TRANSPARENT);
		dc.drawCircle(threeQuarterWidth, threeQuarterHeight, 9);
   
        var phoneConnected = Sys.getDeviceSettings().phoneConnected;
        if(phoneConnected){
			dc.setColor(Gfx.COLOR_LT_GRAY, Gfx.COLOR_TRANSPARENT);
			dc.fillCircle(threeQuarterWidth, threeQuarterHeight, 5);
		}
		        
        // Draw the secondary time
        var timeContainerSize = 48;
        dc.setColor(Gfx.COLOR_DK_GRAY, Gfx.COLOR_LT_GRAY); 
        dc.drawRoundedRectangle(quarterWidth - (timeContainerSize/2) - paddingFromEdge + 2, threeQuarterHeight - (tinyFontHeight/2), timeContainerSize, tinyFontHeight+2, 2);
        dc.setColor(Gfx.COLOR_LT_GRAY, Gfx.COLOR_TRANSPARENT);
        //TODO: clean up - what is the source of my second time UTC or current?
        var utcNow = Time.now();
        var utcInfo = Calendar.info(utcNow, Time.FORMAT_LONG);
        var utcStr = Lang.format("$1$:$2$", [utcInfo.hour.format("%02d"), utcInfo.min.format("%02d")]);
        dc.setColor(Gfx.COLOR_LT_GRAY, Gfx.COLOR_TRANSPARENT);
        dc.drawText(quarterWidth, threeQuarterHeight - (tinyFontHeight / 2), Gfx.FONT_TINY, utcStr, Gfx.TEXT_JUSTIFY_CENTER);
                
        // Draw the hour. Convert it to minutes and compute the angle.
        dc.setColor(Gfx.COLOR_RED, Gfx.COLOR_TRANSPARENT);
        hourHand = (((clockTime.hour % 12) * 60) + clockTime.min);
        hourHand = hourHand / (12 * 60.0);
        hourHand = hourHand * Math.PI * 2;
        drawHand(dc, hourHand, 60, 5);

        // Draw the minute
        minuteHand = (clockTime.min / 60.0) * Math.PI * 2;
        drawHand(dc, minuteHand, 100, 4);

        // Draw the second
        if (isAwake) {
            dc.setColor(Gfx.COLOR_RED, Gfx.COLOR_TRANSPARENT);
            secondHand = (clockTime.sec / 60.0) * Math.PI * 2;
            secondTail = secondHand - Math.PI;
            drawHand(dc, secondHand, 60, 2);
            drawHand(dc, secondTail, 20, 2);
        }

        // Draw the arbor
        dc.setColor(Gfx.COLOR_LT_GRAY, Gfx.COLOR_BLACK);
        dc.fillCircle(halfWidth, halfHeight, 7);
        dc.setColor(Gfx.COLOR_BLACK,Gfx.COLOR_BLACK);
        dc.drawCircle(halfWidth, halfHeight, 7);
    }

    function onEnterSleep() {
        isAwake = false;
        Ui.requestUpdate();
    }

    function onExitSleep() {
        isAwake = true;
    }

}
