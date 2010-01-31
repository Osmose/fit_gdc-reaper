package punk
{
	import flash.display.BitmapData;
	import flash.geom.ColorTransform;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.geom.Matrix;
	import punk.core.SpriteMap;
	
	/// @info	A special Actor class with advanced drawing capabilities, such as drawing with alpha, scaling, rotation, or colored.
	public class Acrobat extends Actor
	{	
		/// @info	The alpha blending factor.
		public var alpha:Number = 1;
		/// @info	Set this to draw the sprite in a single blank colour. Set to 0 to draw normally.
		public var color:uint = 0;
		/// @info	The scale factor.
		public var scaleX:Number = 1;
		public var scaleY:Number = 1;
		/// @info	The angle of rotation in degrees. Set to 0 for no rotation, increase to rotate counter-clockwise.
		public var angle:Number = 0;
		/// @info	If it should pivot the sprite around the center of the sprite (true) or around the sprite's origin (false).
		public var center:Boolean = true;
		
		/// @info	Constructor.
		public function Acrobat() 
		{
			
		}
		
		override public function render():void
		{
			if (!_sprite) return;
			
			// check if the buffer needs updated
			if (_update || _image !== _img || flipX !== _flipX || flipY !== _flipY || alpha !== _alpha)
			{
				// get the image
				_rect.x = flipX ? sprite.imageR - _image * sprite.imageW : _image * sprite.imageW;
				_rect.y = flipY ? sprite.imageB : 0;
				_rect.width = sprite.imageW;
				_rect.height = sprite.imageH;
				
				// update the buffer
				_update = false;
				_img = _image;
				_flipX = flipX;
				_flipY = flipY;
				_alpha = _color.alphaMultiplier = alpha;
				_buffer.copyPixels(_sprite, _rect, _zero);
				if (_alpha < 1 || color)
				{
					if (color) _color.color = color;
					_buffer.colorTransform(_buffer.rect, _color);
					_color.redMultiplier = _color.greenMultiplier = _color.blueMultiplier = _color.alphaMultiplier = 1;
					_color.redOffset = _color.greenOffset = _color.blueOffset = _color.alphaOffset = 0;
				}
			}
			
			// draw without transformation
			if (angle == 0 && scaleX == 1 && scaleY == 1)
			{
				// get the drawing position
				_point.x = x - FP.camera.x - sprite.originX;
				_point.y = y - FP.camera.y - sprite.originY;
				
				// draw the buffer to the screen
				FP.screen.copyPixels(_buffer, _bufferRect, _point);
				
				// animation cycle
				if (!delay) return;
				_count ++;
				if (_count >= delay)
				{
					_count = 0;
					_image ++;
					if (_image == sprite.number) _image = loop ? 0 : _image - 1;
					else if (anim !== null && _image == sprite.number - 1) anim();
				}
				return;
			}
			
			// transformation matrix
			_matrix.a = scaleX;
			_matrix.d = scaleY;
			_matrix.b = _matrix.c = 0;
			if (center)
			{
				_matrix.tx = -sprite.imageCX * scaleX;
				_matrix.ty = -sprite.imageCY * scaleY;
				if (angle != 0) _matrix.rotate(angle * _DEG);
				_matrix.tx += x - FP.camera.x - sprite.originX + sprite.imageCX;
				_matrix.ty += y - FP.camera.y - sprite.originY + sprite.imageCY;
			}
			else
			{
				_matrix.tx = -sprite.originX * scaleX;
				_matrix.ty = -sprite.originY * scaleY;
				if (angle != 0) _matrix.rotate(angle * _DEG);
				_matrix.tx += x - FP.camera.x;
				_matrix.ty += y - FP.camera.y;
			}
			
			// draw buffer transformed
			FP.screen.draw(_buffer, _matrix);
			
			// animation cycle
			if (!delay) return;
			_count ++;
			if (_count >= delay)
			{
				_count = 0;
				_image ++;
				if (_image == sprite.number) _image = loop ? 0 : _image - 1;
				else if (anim !== null && _image == sprite.number - 1) anim();
			}
		}

		override public function get sprite():SpriteMap
		{
			return _sprite;
		}
		override public function set sprite(value:SpriteMap):void
		{
			_sprite = value;
			_image %= _sprite.number;
			if (!_buffer || _sprite.imageW > _buffer.width || _sprite.imageH > _buffer.height)
			{
				_buffer = new BitmapData(_sprite.imageW, _sprite.imageH, true, 0);
				_bufferRect = _buffer.rect;
			}
			else _buffer.fillRect(_buffer.rect, 0);
			_update = true;
			// TODO: instead of keeping the _buffer, track a different buffer for each different sprite
		}
		
		private const _DEG:Number = -Math.PI / 180;
		
		private var _color:ColorTransform = FP.color;
		private var _buffer:BitmapData;
		private var _bufferRect:Rectangle;
		private var _update:Boolean = true;
		private var _img:int;
		private var _flipX:Boolean;
		private var _flipY:Boolean;
		private var _alpha:Number;
	}
}