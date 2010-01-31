package punk.core 
{
	import flash.display.BitmapData;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	
	/// @info	
	public class PixelFont extends BitmapData
	{
		/// @info	The width and height of the characters in the bitmap.
		public var charW:int;
		public var charH:int;
		/// @info	The horizontal and vertical spacing between characters.
		public var spaceX:int;
		public var spaceY:int;
		/// @info	The ascii value of the first character in the bitmap.
		public var first:int;
		/// @info	The total amount of characters in the bitmap.
		public var number:int;
		/// @info	If this font's characters have fixed-width spacing.
		public var fixed:Boolean;
		/// @info	For non fixed-width fonts, this Vector stores the width of each character from ascii 0 to 256.
		public var char:Vector.<int>;
		
		/// @info	Constructor. It is recommended that you extend this class, set the parameters with super(), and create the fonts with FP.getFont().
		/// @param	bitmap			The embedded Bitmap class representing the font's BitmapData.
		/// @param	charWidth		The width of the characters in the bitmap.
		/// @param	charHeight		The height of the characters in the bitmap.
		/// @param	firstChar		The ascii value of the first character in the bitmap.
		/// @param	charSpacing		The horizontal spacing between characters.
		/// @param	lineSpacing		The vertical spacing between lines of text.
		/// @param	fixedWidth		If this font's characters have fixed-width spacing.
		/// @param	alphaPoint		If your bitmap has no transparency, you can specify an optional Point on the bitmap representing the color to make transparent.
		public function PixelFont(bitmap:Class, charWidth:int, charHeight:int, firstChar:String = " ", charSpacing:int = 0, lineSpacing:int = 0, fixedWidth:Boolean = true, alphaPoint:Point = null) 
		{
			// get the font information
			var temp:BitmapData = (new bitmap).bitmapData;
			charW = charWidth;
			charH = charHeight;
			spaceX = charSpacing;
			spaceY = lineSpacing;
			number = (temp.width / charW) * (temp.height / charH);
			first = firstChar.charCodeAt();
			fixed = fixedWidth;
			
			// create the font bitmap and check for charsize errors
			super(charW * number, charH, true, 0);
			if ((temp.width % charW) != 0 || (temp.height % charH) != 0) throw new Error("Inappropriate character size.");
			
			// add transparency
			if (alphaPoint)
			{
				_point.x = _point.y = 0;
				temp.threshold(temp, temp.rect, _point, "==", temp.getPixel32(alphaPoint.x, alphaPoint.y), 0);
			}
			
			// copy the chars onto the font
			_rect.x = _rect.y = _point.x = _point.y = 0;
			_rect.width = charW;
			_rect.height = charH;
			while (_rect.y < temp.height)
			{
				while (_rect.x < temp.width)
				{
					copyPixels(temp, _rect, _point);
					_point.x += charW;
					_rect.x += charW;
				}
				_rect.y += charH;
				_rect.x = 0;
			}
			
			// get the width of each char for fixed fonts
			char = new Vector.<int>(256);
			if (!fixed)
			{
				var i:int = 0,
					l:int = 0,
					w:int = charW,
					xx:int = charW - 1,
					yy:int = 0;
				while (i < number)
				{
					while (xx >= l)
					{
						while (yy < charH)
						{
							if (getPixel32(xx, yy))
							{
								char[first + i] = w;
								xx = l;
								yy = charH;
								break;
							}
							yy ++;
						}
						w --;
						xx --;
						yy = 0;
					}
					if (!char[first + i]) char[first + i] = charW;
					i ++;
					l += charW;
					w = charW;
					xx = l + (charW - 1);
				}
			}
		}
		
		/// @info	Returns the width of a single line of text as represented by this font.
		/// @param	str		The string to emulate.
		public function stringWidth(str:String):int
		{
			if (!str) return 0;
			if (fixed) return (charW + spaceX) * str.length - spaceX;
			var i:int = str.length,
				w:int = -spaceX;
			while (i --) w += char[str.charCodeAt(i)] + spaceX;
			return w;
		}
		
		private var _point:Point = FP.point;
		private var _rect:Rectangle = FP.rect;
	}
}