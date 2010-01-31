package punk.core 
{
	import flash.display.Graphics;
	import flash.display.LineScaleMode;
	import flash.display.Sprite;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	
	/// @info	The base class for active game objects that should update, render, or use alarms.
	public class Core 
	{
		/// @info	When this is false, update() will not be called.
		public var active:Boolean = true;
		/// @info	When this is false, render() will not be called.
		public var visible:Boolean = true;
		/// @info	The last Alarm that was triggered for this object.
		public var alarmLast:Alarm;
		
		/// @info	Constructor.
		public function Core() 
		{
			
		}
		
		/// @info	Override this. Called every frame, override for game logic, controls, movement, etc.
		public function update():void
		{
			if (_alarmFirst) _alarmFirst.update();
		}
		
		/// @info	Override this. Called every frame, override for animation, rendering, etc.
		public function render():void
		{
			
		}
		
		/// @info	Adds an alarm to this object and returns it.
		/// @param	alarm	The Alarm object to add.
		public function addAlarm(alarm:Alarm):Alarm
		{
			if (alarm._added) return alarm;
			if (_alarmFirst) _alarmFirst._prev = alarm;
			alarm._next = _alarmFirst;
			alarm._added = true;
			alarm._entity = this;
			_alarmFirst = alarm;
			return alarm;
		}
		
		/// @info	Removes the alarm from this object.
		/// @param	alarm	The Alarm object to remove.
		public function removeAlarm(alarm:Alarm):void
		{
			if (!alarm._added) return;
			if (alarm._prev) alarm._prev._next = alarm._next;
			if (alarm._next) alarm._next._prev = alarm._prev;
			if (_alarmFirst == alarm) _alarmFirst = alarm._next;
			alarm._next = alarm._prev = null;
			alarm._entity = null;
			alarm._added = false;
		}
		
		/// @info	Removes all alarms from this object.
		public function removeAllAlarms():void
		{
			var a:Alarm;
			while (_alarmFirst)
			{
				_alarmFirst._prev = null;
				a = _alarmFirst;
				_alarmFirst = a._next;
				a._next = null;
				a._added = false;
			}
		}
		
		/// @info	Draws the SpriteMap to the Screen.
		/// @param	image		The image of the SpriteMap you want to draw.
		/// @param	x			The x-position in the World you want to draw it.
		/// @param	y			The y-position in the World you want to draw it.
		/// @param	flipX		If you want to draw the x-flipped version.
		/// @param	flipY		If you want to draw the y-flipped version.
		public function drawSprite(sprite:SpriteMap, image:int = 0, x:int = 0, y:int = 0, flipX:Boolean = false, flipY:Boolean = false):void
		{
			// get the image & drawing position
			_rect.x = flipX ? sprite.imageR - image * sprite.imageW : image * sprite.imageW;
			_rect.y = flipY ? sprite.imageB : 0;
			_rect.width = sprite.imageW;
			_rect.height = sprite.imageH;
			_point.x = x - FP.camera.x - sprite.originX;
			_point.y = y - FP.camera.y - sprite.originY;
			
			// draw onto the screen
			FP.screen.copyPixels(sprite, _rect, _point);
		}
		
		/// @info	Draws a filled rectangle to the Screen.
		/// @param	x		The x-position in the World to draw it.
		/// @param	y		The y-position in the World to draw it.
		/// @param	w		The width of the rectangle.
		/// @param	h		The height of the rectangle.
		/// @param	color	The fill-color of the rectangle.
		public function drawRect(x:int, y:int, w:int, h:int, color:uint = 0xFF000000):void
		{
			_rect.x = x - FP.camera.x;
			_rect.y = y - FP.camera.y;
			_rect.width = w;
			_rect.height = h;
			FP.screen.fillRect(_rect, color);
		}
		
		/// @info	Draws a smooth, antialiased line to the Screen.
		/// @param	x1		The starting x-position in the World.
		/// @param	y1		The starting y-position in the World.
		/// @param	x2		The ending x-position in the World.
		/// @param	y2		The ending y-position in the World.
		/// @param	color	The color to draw.
		/// @param	thick	The line's thickness.
		/// @param	alpha	The alpha blending factor.
		public function drawLine(x1:int, y1:int, x2:int, y2:int, color:uint = 0xFF000000, thick:Number = 1, alpha:Number = 1):void
		{
			_graphics.clear();
			_graphics.lineStyle(thick, color, alpha, false, LineScaleMode.NONE);
			_graphics.moveTo(x1 - FP.camera.x, y1 - FP.camera.y);
			_graphics.lineTo(x2 - FP.camera.y, y2 - FP.camera.y);
			FP.screen.draw(_line);
		}
		
		/// @info	Draws a pixelated, non-antialiased line to the Screen.
		/// @param	x1		The starting x-position in the World.
		/// @param	y1		The starting y-position in the World.
		/// @param	x2		The ending x-position in the World.
		/// @param	y2		The ending y-position in the World.
		/// @param	color	The color to draw.
		public function drawLinePixel(x1:int, y1:int, x2:int, y2:int, color:uint = 0xFF000000):void
		{
			// get the drawing positions
			x1 -= FP.camera.x;
			y1 -= FP.camera.y;
			x2 -= FP.camera.x;
			y2 -= FP.camera.y;
			
			// get the drawing difference
			var screen:Screen = FP.screen,
				X:Number = Math.abs(x2 - x1),
				Y:Number = Math.abs(y2 - y1),
				xx:int,
				yy:int;
			
			// draw a single pixel
			if (X == 0)
			{
				if (Y == 0)
				{
					screen.setPixel(x1, y1, color);
					return;
				}
				// draw a straight vertical line
				yy = y2 > y1 ? 1 : -1;
				while (y1 != y2)
				{
					screen.setPixel(x1, y1, color);
					y1 += yy;
				}
				screen.setPixel(x2, y2, color);
				return;
			}
			
			if (Y == 0)
			{
				// draw a straight horizontal line
				xx = x2 > x1 ? 1 : -1;
				while (x1 != x2)
				{
					screen.setPixel(x1, y1, color);
					x1 += xx;
				}
				screen.setPixel(x2, y2, color);
				return;
			}
			
			xx = x2 > x1 ? 1 : -1;
			yy = y2 > y1 ? 1 : -1;
			var c:Number = 0,
				slope:Number;
			
			if (X > Y)
			{
				slope = Y / X;
				c = .5;
				while (x1 != x2)
				{
					screen.setPixel(x1, y1, color);
					x1 += xx;
					c += slope;
					if (c >= 1)
					{
						y1 += yy;
						c -= 1;
					}
				}
				screen.setPixel(x2, y2, color);
				return;
			}
			else
			{
				slope = X / Y;
				c = .5;
				while (y1 != y2)
				{
					screen.setPixel(x1, y1, color);
					y1 += yy;
					c += slope;
					if (c >= 1)
					{
						x1 += xx;
						c -= 1;
					}
				}
				screen.setPixel(x2, y2, color);
				return;
			}
		}
		
		private var _point:Point = FP.point;
		private var _rect:Rectangle = FP.rect;
		private var _line:Sprite = FP.line;
		private var _graphics:Graphics = _line.graphics;
		
		internal var _alarmFirst:Alarm;
	}
}