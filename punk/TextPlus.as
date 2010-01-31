package punk 
{
	import flash.display.BitmapData;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.geom.ColorTransform;
	import flash.geom.Matrix;
	import punk.core.*;
	import punk.font.*;
	
	/// @info	A Text class that can display alpha blended, scaled, or rotated text to the Screen.
	public class TextPlus extends Text
	{
		/// @info	The alpha blending factor.
		public var alpha:Number = 1;
		/// @info	The wash-out color. Set to -1 to draw normally.
		public var color:int = -1;
		/// @info	The scale factor.
		public var scaleX:Number = 1;
		public var scaleY:Number = 1;
		/// @info	The angle of rotation in degrees. Set to 0 for no rotation, increase to rotate counter-clockwise.
		public var angle:Number = 0;
		
		/// @info	Constructor.
		/// @param	str			The string to display.
		/// @param	alignH		The horizontal alignment style of the text. For example: FP.ALIGN_CENTER.
		/// @param	alignV		The vertical alignment style of the text. For example: FP.ALIGN_TOP.
		/// @param	startEmpty	If the text should start out fully displayed (false) or with no letters showing (true).
		/// @param	newLine		The character to use as a new line when printing out text.
		public function TextPlus(str:String = "", alignH:int = 0, alignV:int = 0, startEmpty:Boolean = false, newline:String = "\n") 
		{
			super(str, alignH, alignV, startEmpty, newline);
			_centerX = int(width * .5);
			_centerY = int(height * .5);
		}
		
		/// @info	Sets the pivot point for the text to rotate on. Default is the center.
		/// @param	x		Relative x-position to pivot on (0 is the left).
		/// @param	y		Relative y-position to pivot on (0 is the top).
		public function setPivot(x:int, y:int):void
		{
			_centerX = x;
			_centerY = y;
		}
		
		override public function render():void
		{
			// check if the buffer needs updated
			if (_update || _alpha != alpha || _angle != angle || _scaleX != scaleX || _scaleY != scaleY)
			{
				_update = false;
				_angle = angle;
				_scaleX = scaleX;
				_scaleY = scaleY;
				_alpha = _color.alphaMultiplier = alpha;
				
				var i:int = 0,
					h:int = _font.charH + _font.spaceY;
				if (_letters == _string.length)
				{
					// draw each line
					_point.y = 0;
					while (i < _lines)
					{
						_point.x = _xpos[i];
						_buffer.copyPixels(_data[i], _data[i].rect, _point);
						_point.y += h;
						i ++;
					}
				}
				else
				{
					// draw each line up to the unfinished line
					_point.y = 0;
					while (i < _showLines)
					{
						_point.x = _xpos[i];
						_buffer.copyPixels(_data[i], _data[i].rect, _point);
						_point.y += h;
						i ++;
					}
					
					// draw only the showing letters of the unfinished line
					if (_showLetters)
					{
						_point.x = _xpos[_showLines];
						_buffer.copyPixels(_data[_showLines], _lastRect, _point);
					}
				}
				
				if (_alpha < 1) _buffer.colorTransform(_buffer.rect, _color);
			}
			
			// transformation matrix
			_matrix.a = _scaleX;
			_matrix.d = _scaleY;
			_matrix.b = _matrix.c = 0;
			_matrix.tx = int(-_centerX * _scaleX);
			_matrix.ty = int(-_centerY * _scaleY);
			if (angle != 0) _matrix.rotate(angle * _DEG);
			_matrix.tx += int(x - FP.camera.x + (_offX + _centerX) * _scaleX);
			_matrix.ty += int(y - FP.camera.y + (_offY + _centerY) * _scaleY);
			
			// draw buffer transformed
			FP.screen.draw(_buffer, _matrix);
		}
		
		override public function setString(str:String, startEmpty:Boolean = false):void
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
				var letter:int;
				while (i < _lines)
				{
					if (!_line[i]) _line[i] = " ";
					line = _line[i];
					_string += line;
					w = _font.stringWidth(line);
					_data[i] = data = new BitmapData(w, _font.charH, true, 0);
					if (data.width > width) width = data.width;
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
			
			setAlign(_alignH, _alignV);
			
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
			
			_buffer = new BitmapData(width, height, true, 0);
			_update = true;
		}
		
		override public function setAlign(alignH:uint = 0, alignV:uint = 0):void
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
					_offX = 0;
					break;
				case 1:
					while (i --) _xpos[i] = int((width - _data[i].width) * .5);
					_offX = int(width * -.5);
					break;
				case 2:
					while (i --) _xpos[i] = width - _data[i].width;
					_offX = -width;
					break;
			}
			switch (_alignV)
			{
				case 0: _offY = 0; break;
				case 1: _offY = int(height * -.5); break;
				case 2: _offY = -height; break;
			}
		}
		
		override public function addLetter(num:uint = 1):String
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
			_update = true;
			return (_string.charAt(_letters - 1));
		}
		
		private const _DEG:Number = -Math.PI / 180;
		
		private var _zero:Point = FP.zero;
		private var _matrix:Matrix = FP.matrix;
		private var _color:ColorTransform = FP.color;
		
		private var _buffer:BitmapData;
		private var _update:Boolean = true;
		private var _angle:Number;
		private var _alpha:Number;
		private var _scaleX:Number;
		private var _scaleY:Number;
		
		private var _centerX:int;
		private var _centerY:int;
		private var _offX:int;
		private var _offY:int;
	}
}