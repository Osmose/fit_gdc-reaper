package punk.core 
{
	import flash.display.BitmapData;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	
	/// @info	A special BitmapData class that can contain multiple sprite images and other useful rendering information.
	public class SpriteMap extends BitmapData
	{
		/// @info	The width and height of the sprite images.
		public var imageW:int;
		public var imageH:int;
		/// @info	Used by Actor, etc. when accessing the x and y flipped images.
		public var imageR:int;
		public var imageB:int;
		/// @info	The center position of each image.
		public var imageCX:int;
		public var imageCY:int;
		/// @info	The origin position of the images.
		public var originX:int;
		public var originY:int;
		/// @info	Whether horizontally or vertically flipped images are available.
		public var flippedX:Boolean;
		public var flippedY:Boolean;
		/// @info	The number of images in the sprite.
		public var number:int;
		
		/// @info	Constructor. It is recommended that you create SpriteMaps with the FP.getSprite() function rather than calling this.
		/// @param	width		The width of the entire SpriteMap.
		/// @param	height		The height of the entire SpriteMap.
		/// @param	imageWidth	The width of the sprite's images.
		/// @param	imageHeight	The height of the sprite's images.
		/// @param	imageNum	How many images are in the sprite.
		///	@param	originX		The x-origin of the sprite, determines the offset position when drawing it.
		///	@param	originY		The y-origin of the sprite, determines the offset position when drawing it.
		public function SpriteMap(width:int, height:int, imageWidth:int = 0, imageHeight:int = 0, imageNum:int = 1, originX:int = 0, originY:int = 0) 
		{
			super(width, height, true, 0);
			imageW = imageWidth > 0 ? imageWidth : width;
			imageH = imageHeight > 0 ? imageHeight : height;
			imageCX = imageW >> 1;
			imageCY = imageH >> 1;
			imageR = width;
			imageB = height;
			number = imageNum;
			this.originX = originX;
			this.originY = originY;
		}
		
		/// @info	Returns a rectangle corresponding to the specific image's position in the SpriteMap.
		/// @param	image		A specific image of the sprite.
		/// @param	flipX		If you want the horizontally flipped image.
		/// @param	flipY		If you want the vertically flipped image.
		public function getRect(image:int = 0, flipX:Boolean = false, flipY:Boolean = false):Rectangle
		{
			_rect.x = flipX ? imageR - image * imageW : image * imageW;
			_rect.y = flipY ? imageB : 0;
			_rect.width = imageW;
			_rect.height = imageH;
			return _rect;
		}
		
		/// @info	Returns the specific image of the SpriteMap as a new BitmapData.
		/// @param	image		A specific image of the sprite.
		/// @param	flipX		If you want the horizontally flipped image.
		/// @param	flipY		If you want the vertically flipped image.
		public function getImage(image:int = 0, flipX:Boolean = false, flipY:Boolean = false):BitmapData
		{
			var data:BitmapData = new BitmapData(imageW, imageH, true, 0);
			image %= number;
			_rect.x = flipX ? imageR - image * imageW : image * imageW;
			_rect.y = flipY ? imageB : 0;
			_rect.width = imageW;
			_rect.height = imageH;
			data.copyPixels(this, _rect, _zero);
			return data;
		}
		
		private var _rect:Rectangle = FP.rect;
		private var _zero:Point = FP.zero;
	}
}