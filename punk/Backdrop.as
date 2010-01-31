package punk
{
	import flash.display.BitmapData;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import punk.core.Entity;
	
	/// @info	A game Entity designed for drawing repeated and/or scrolling background layers.
	public class Backdrop extends Entity
	{
		/// @info	Constructor.
		/// @param	bitmap		The embedded Bitmap class to use as the background texture.
		/// @param	scrollX		The horizontal scroll factor. From sitting still (0) to following the screen (1).
		/// @param	scrollY		The vertical scroll factor. From sitting still (0) to following the screen (1).
		/// @param	repeatX		If the texture should infinitely repeat horizontally.
		/// @param	repeatY		If the texture should infinitely repeat vertically.
		public function Backdrop(bitmap:Class, scrollX:Number = 0, scrollY:Number = 0, repeatX:Boolean = true, repeatY:Boolean = true) 
		{
			var data:BitmapData = FP.getBitmapData(bitmap),
				w:int = data.width,
				h:int = data.height;
			if (repeatX) w += FP.screen.width;
			if (repeatY) h += FP.screen.height;
			
			_data = new BitmapData(w, h);
			_rect = data.rect;
			
			_scrollW = data.width;
			_scrollH = data.height;
			_repeatX = repeatX;
			_repeatY = repeatY;
			
			_point.x = _point.y = 0;
			while (_point.y < _data.height + data.height)
			{
				while (_point.x < _data.width + data.width)
				{
					_data.copyPixels(data, _rect, _point);
					_point.x += data.width;
				}
				_point.x = 0;
				_point.y += data.height;
			}
			
			_scrollX = 1 - scrollX;
			_scrollY = 1 - scrollY;
			_rect = _data.rect;
			depth = 0xFFFFFF;
		}
		
		override public function render():void
		{
			if (!_data) return;
			
			// find x position
			if (_repeatX)
			{
				_point.x = (x - FP.camera.x * _scrollX) % _scrollW;
				if (_point.x > 0) _point.x -= _scrollW;
			}
			else _point.x = (x - FP.camera.x * _scrollX);
			
			// find y position
			if (_repeatY)
			{
				_point.y = (y - FP.camera.y * _scrollY) % _scrollH;
				
				if (_point.y > 0) _point.y -= _scrollH;
			}
			else _point.y = (y - FP.camera.y * _scrollY);
			
			// draw to the screen
			FP.screen.copyPixels(_data, _rect, _point);
		}
		
		private var _point:Point = FP.point;
		private var _rect:Rectangle;
		private var _data:BitmapData;
		private var _scrollX:Number;
		private var _scrollY:Number;
		private var _scrollW:int;
		private var _scrollH:int;
		private var _repeatX:Boolean;
		private var _repeatY:Boolean;
	}
}