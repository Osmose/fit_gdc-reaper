package punk.core 
{
	import flash.display.BitmapData;
	import flash.geom.Matrix;
	import flash.geom.Point;
	import punk.font.*;
	import punk.util.*;
	
	public class GraphicsBox 
	{
		public const ALIGN_LEFT:int = 0;
		public const ALIGN_CENTER:int = 1;
		public const ALIGN_RIGHT:int = 2;
		public const ALIGN_TOP:int = 0;
		public const ALIGN_MIDDLE:int = 1;
		public const ALIGN_BOTTOM:int = 2;
		
		private var
			_matrix:Matrix = FP.matrix,
			_zero:Point = FP.zero,
			_sprite:Array = [],
			_bitmap:Array = [],
			_fonts:Array = [],
			_font:PixelFont;
		
		public function GraphicsBox() 
		{
			
		}
		
		// this creates a spritemap from the bitmap class, but will return a cached spritemap instead if one has already been created (to save memory)
		public function getSprite(bitmap:Class, imageW:int, imageH:int, flipX:Boolean = false, flipY:Boolean = false, originX:int = 0, originY:int = 0, useCache:Boolean = true):SpriteMap
		{
			var data:SpriteMap,
				temp:BitmapData,
				pos:String = String(bitmap),
				fX:Boolean,
				fY:Boolean;
				
			if (useCache && _sprite[pos])
			{
				var spr:SpriteMap = _sprite[pos];
				if ((!flipX || spr.flippedX) && (!flipY || spr.flippedY)) return _sprite[pos];
				fX = spr.flippedX;
				fY = spr.flippedY;
			}
			
			if (flipX || flipY || fX || fY)
			{
				temp = (new bitmap).bitmapData;
				var	w:int = flipX ? temp.width << 1 : temp.width,
					h:int = flipY ? temp.height << 1 : temp.height;
				data = new SpriteMap(w, h, imageW, imageH, temp.width / imageW, originX, originY);
				data.copyPixels(temp, temp.rect, _zero);
				_matrix.b = _matrix.c = 0;
				if (flipX || fX)
				{
					data.flippedX = true;
					data.imageR = w - imageW;
					_matrix.a = -1;
					_matrix.d = 1;
					_matrix.tx = w;
					_matrix.ty = 0;
					data.draw(temp, _matrix);
				}
				if (flipY || fY)
				{
					data.flippedY = true;
					data.imageB = h >> 1;
					_matrix.a = 1;
					_matrix.d = -1;
					_matrix.tx = 0;
					_matrix.ty = h;
					data.draw(temp, _matrix);
					if (flipX)
					{
						_matrix.a = -1;
						_matrix.tx = w;
						data.draw(temp, _matrix);
					}
				}
				if (useCache) _sprite[pos] = data;
				return data;
			}
			temp = (new bitmap).bitmapData;
			data = new SpriteMap(temp.width, temp.height, imageW, imageH, temp.width / imageW, originX, originY);
			data.copyPixels(temp, temp.rect, _zero);
			data.imageW = imageW;
			data.imageH = imageH;
			
			if (useCache) _sprite[pos] = data;
			return data;
		}
		
		// gets the bitmapData corresponding to the image
		public function getBitmapData(bitmap:Class):BitmapData
		{
			if (_bitmap[String(bitmap)]) return _bitmap[String(bitmap)];
			return (_bitmap[String(bitmap)] = (new bitmap()).bitmapData);
		}
		
		// choose which pixelfont class you want to use for text or textplus objects
		public function setFont(font:Class = null):PixelFont
		{
			if (!font) font = FontDefault;
			if (_fonts[String(font)]) return _fonts[String(font)];
			return (_font = _fonts[String(font)] = new font());
		}
		
		// returns the currently active pixelfont
		public function getFont():PixelFont
		{
			return _font;
		}
	}
}