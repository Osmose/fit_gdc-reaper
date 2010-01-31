package punk 
{
	import flash.display.BitmapData;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import punk.core.*;
	import punk.font.*;
	
	
	/// @info	A game Entity designed for drawing text on the Screen in PixelFonts.
	public class Text extends Entity
	{
		/// @info	The size of the displayed text.
		public var width:int;
		public var height:int;
		
		/// @info	The last currently visible letter of the text.
		public function get lastLetter():String
		{
			return _string.charAt(_letters - 1);
		}
		/// @info	Whether the text is displayed completely or not.
		public function get isComplete():Boolean
		{
			return (_letters == _string.length);
		}
		
		/// @info	[STATIC] Constants used for various alignment properties.
		public static const ALIGN_LEFT:int = 0;
		public static const ALIGN_CENTER:int = 1;
		public static const ALIGN_RIGHT:int = 2;
		public static const ALIGN_TOP:int = 0;
		public static const ALIGN_MIDDLE:int = 1;
		public static const ALIGN_BOTTOM:int = 2;
		
		/// @info	Constructor.
		/// @param	str			The string to display.
		/// @param	alignH		The horizontal alignment style of the text. For example: FP.ALIGN_CENTER.
		/// @param	alignV		The vertical alignment style of the text. For example: FP.ALIGN_TOP.
		/// @param	startEmpty	If the text should start out fully displayed (false) or with no letters showing (true).
		/// @param	newLine		The character to use as a new line when printing out text.
		public function Text(str:String = "", alignH:int = 0, alignV:int = 0, startEmpty:Boolean = false, newline:String = "\n") 
		{
			_font = FP.font;
			if (!_font) _font = FP.setFont(FontDefault);
			_alignH = alignH;
			_alignV = alignV;
			_newline = newline;
			setString(str, startEmpty);
			active = false;
		}
		
		/// @info	Sets the display string.
		/// @param	str			The string to display.
		/// @param	startEmpty	If the text should start out fully displayed (false) or with no letters showing (true).
		public function setString(str:String, startEmpty:Boolean = false):void
		{
			if (str == _string) return;
			_string = "";
			// break up the string into lines and create a bitmap for each one
			_data = new Vector.<BitmapData>();
			_line = str.split(_newline);
			var data:BitmapData,
				line:String,
				i:int = 0,
				j:int,
				w:int;
			_lines = _line.length;
			_point.y = _rect.y = width = 0;
			height = (_font.charH + _font.spaceY) * _lines - _font.spaceY;
			_rect.height = _font.charH;
			if (_font.fixed)
			{
				// fixed-width fonts
				w = _font.charW + _font.spaceX;
				_rect.width = _font.charW;
				while (i < _lines)
				{
					if (!_line[i]) _line[i] = " ";
					line = _line[i];
					_string += line;
					_point.x = _font.stringWidth(line);
					_data[i] = data = new BitmapData(_point.x, _font.charH, true, 0);
					if (data.width > width) width = data.width;
					_point.x -= _font.charW;
					j = line.length;
					while (j --)
					{
						_rect.x = (line.charCodeAt(j) - _font.first) * _font.charW;
						data.copyPixels(_font, _rect, _point);
						_point.x -= w;
					}
					i ++;
				}
				_lastRect = data.rect.clone();
			}
			else
			{
				// variable-width fonts
				var letter:int;
				while (i < _lines)
				{
					if (!_line[i]) _line[i] = " ";
					line = _line[i];
					_string += line;
					w = _font.stringWidth(line);
					_data[i] = data = new BitmapData(w, _font.charH, true, 0);
					j = _point.x = 0;
					while (j < line.length)
					{
						letter = line.charCodeAt(j);
						_rect.x = (letter - _font.first) * _font.charW;
						_rect.width = _font.char[letter];
						data.copyPixels(_font, _rect, _point);
						_point.x += _font.char[letter] + _font.spaceX;
						j ++;
					}
					i ++;
				}
				_lastRect = data.rect.clone();
			}
			
			// set the alignment
			setAlign(_alignH, _alignV);
			
			// set the displayed letters
			if (startEmpty)
			{
				_letters = _showLines = _showLetters = 0;
				_lastRect.width = -_font.spaceX;
			}
			else
			{
				_letters = _string.length;
				_showLines = _lines;
				_showLetters = _line[_lines - 1].length;
			}
		}
		
		/// @info	Gets just the currently visible letters in the text.
		public function getStringDisplayed():String
		{
			var i:int = 0,
				s:String = "";
			if (_letters < _string.length)
			{
				while (i < _showLines) s += _line[i ++] + _newline;
				return s + _line[i].slice(0, _showLetters);
			}
			while (i < _lines)
			{
				s += _line[i];
				i ++
				if (i != _lines) s += _newline;
			}
			return s;
		}
		
		/// @info	Gets the entire display text.
		public function getStringComplete():String
		{
			var i:int = 0,
				s:String = "";
			while (i < _lines)
			{
				s += _line[i];
				i ++;
				if (i != _lines) s += _newline;
			}
			return s;
		}
		
		/// @info	Set the alignment style for the text.
		/// @param	alignH		The horizontal alignment style of the text. For example: FP.ALIGN_CENTER.
		/// @param	alignV		The vertical alignment style of the text. For example: FP.ALIGN_TOP.
		public function setAlign(alignH:uint = 0, alignV:uint = 0):void
		{
			if (!_xpos || _lines != _xpos.length) _xpos = new Vector.<int>(_lines);
			
			_alignH = alignH;
			if (_alignH > 2) _alignH = 2;
			_alignV = alignV;
			if (_alignV > 2) _alignV = 2;
			
			var i:int = _lines;
			switch (_alignH)
			{
				case 0:
					while (i --) _xpos[i] = 0;
					break;
				case 1:
					while (i --) _xpos[i] = int((width - _data[i].width * .5) - width * .5);
					break;
				case 2:
					while (i --) _xpos[i] = _data[i].width;
					break;
			}
			switch (_alignV)
			{
				case 0: _ypos = 0; break;
				case 1: _ypos = int(height * -.5); break;
				case 2: _ypos = -height; break;
			}
		}
		
		/// @info	Makes the next letter of the next appear and returns it. This will do nothing if the text is already fully displayed.
		/// @param	num		Optional, set this to the amount of letters you want to make appear. The final one is returned.
		public function addLetter(num:uint = 1):String
		{
			if (_letters == _string.length) return _string.charAt(_string.length - 1);
			if (num > _string.length - _letters) num = _string.length - _letters;
			while (num --)
			{
				var line:String;
				line = _line[_showLines];
				_letters ++;
				_lastRect.width += _font.char[line.charCodeAt(_showLetters)] + _font.spaceX;
				_showLetters ++;
				if (_showLetters == line.length)
				{
					_showLines ++;
					_showLetters = 0;
					_lastRect.width = -_font.spaceX;
				}
			}
			return (_string.charAt(_letters - 1));
		}
		
		override public function render():void
		{
			var i:int = 0,
				h:int = _font.charH + _font.spaceY;
			if (_letters == _string.length)
			{
				// draw each line
				_point.y = y + _ypos - FP.camera.y;
				while (i < _lines)
				{
					_point.x = x + _xpos[i] - FP.camera.x;
					FP.screen.copyPixels(_data[i], _data[i].rect, _point);
					_point.y += h;
					i ++;
				}
			}
			else
			{
				// draw each line up to the unfinished line
				_point.y = y + _ypos - FP.camera.y;
				while (i < _showLines)
				{
					_point.x = x + _xpos[i] - FP.camera.x;
					FP.screen.copyPixels(_data[i], _data[i].rect, _point);
					_point.y += h;
					i ++;
				}
				
				// draw only the showing letters of the unfinished line
				if (_showLetters)
				{
					_point.x = x + _xpos[_showLines] - FP.camera.x;
					FP.screen.copyPixels(_data[_showLines], _lastRect, _point);
				}
			}
		}
		
		internal var _point:Point = FP.point;
		internal var _rect:Rectangle = FP.rect;
		
		internal var _font:PixelFont;
		internal var _string:String;
		internal var _newline:String;
		internal var _alignH:int;
		internal var _alignV:int;
		internal var _data:Vector.<BitmapData>;
		internal var _xpos:Vector.<int>;
		internal var _ypos:int;
		internal var _line:Array;
		internal var _lines:int;
		internal var _letters:int;
		internal var _showLines:int;
		internal var _showLetters:int;
		internal var _lastRect:Rectangle;
	}
}