package punk.core
{
	import flash.display.BitmapData;
	import flash.display.Stage;
	import flash.geom.ColorTransform;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	
	/// @info	The main screen BitmapData canvas. All Actors, Text, Backdrop, etc. draw to the Screen object.
	public class Screen extends BitmapData
	{
		/// @info	The background color of the screen.
		public var color:uint;
		
		/// @info	The scale of the screen.
		public var scale:Number = 1;
		
		/// @info	Constructor. This object is automatically created by Engine, and assigned to FP.screen, when the game starts.
		/// @param	width		The unscaled width of the screen.
		/// @param	height		The unscaled height of the screen.
		/// @param	color		The background color of the screen.
		/// @param	scale		The scale of the screen.
		public function Screen(width:int, height:int, color:uint = 0xFF202020, scale:int = 1)
		{
			super(width, height, false, color);
			this.color = color;
			_cover = new BitmapData(width, height, true, 0xFF000000);
			_rect = _cover.rect;
			this.scale = scale;
		}
		
		/// @info	Draws a rectangle over the entire screen.
		/// @param	color		The color to draw.
		/// @param	alpha		The alpha blending factor to draw.
		public function drawClear(color:uint = 0xFF000000, alpha:Number = 1):void
		{
			if (alpha >= 1)
			{
				fillRect(_rect, color);
				return;
			}
			_color.alphaMultiplier = alpha;
			_cover.fillRect(_rect, color);
			_cover.colorTransform(_rect, _color);
			copyPixels(_cover, _rect, _zero);
		}
		
		private var _point:Point = FP.point;
		private var _stage:Stage = FP.stage;
		private var _color:ColorTransform = FP.color;
		private var _zero:Point = FP.zero;
		
		internal var _cover:BitmapData;
		internal var _rect:Rectangle = FP.rect;
	}
}