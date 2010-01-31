package punk
{
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.geom.Matrix;
	import flash.display.BitmapData;
	import punk.core.Entity;
	import punk.core.Screen;
	import punk.core.SpriteMap;
	
	/// @info	A game Entity able to display and switch between animated sprites.
	public class Actor extends Entity
	{
		/// @info	The SpriteMap to display at this Actor's position. Get SpriteMaps with the FP.getSprite() function.
		public function get sprite():SpriteMap
		{
			return _sprite;
		}
		public function set sprite(value:SpriteMap):void
		{
			_sprite = value;
			_image %= _sprite.number;
		}
		/// @info	The image of the SpriteMap that is being displayed.
		public function get image():int
		{
			return _image;
		}
		public function set image(value:int):void
		{
			_image = value % _sprite.number;
		}
		/// @info	The frame-delay for each image of the SpriteMap animation. Increase to slow animation.
		public var delay:int = 1;
		/// @info	If the sprite should display flipped. The sprite must have pre-flipped images for this to work.
		public var flipX:Boolean = false;
		public var flipY:Boolean = false;
		/// @info	If the animation should start over when it ends (true) or stop and set delay to 0 on the last frame (false).
		public var loop:Boolean = true;
		/// @info	An optional function to have called when the animation ends or loops.
		public var anim:Function = null;
		
		/// @info	Constructor.
		public function Actor() 
		{
			
		}
		
		/// @info	If you override render, you update the animation cycle by calling this.
		public function updateImage(totalFrames:int):void
		{
			// animation cycle
			if (!delay) return;
			_count ++;
			if (_count >= delay)
			{
				_count = 0;
				_image ++;
				if (_image == totalFrames)
				{
					_image = loop ? 0 : _image - 1;
					if (anim !== null) anim();
				}
			}
		}
		
		override public function render():void
		{
			if (!_sprite) return;
			
			// get the image & drawing position
			_rect.x = flipX ? sprite.imageR - _image * sprite.imageW : _image * sprite.imageW;
			_rect.y = flipY ? sprite.imageB : 0;
			_rect.width = sprite.imageW;
			_rect.height = sprite.imageH;
			_point.x = x - FP.camera.x - sprite.originX;
			_point.y = y - FP.camera.y - sprite.originY;
			
			// draw onto the screen
			FP.screen.copyPixels(sprite, _rect, _point);
			
			// animation cycle
			if (!delay) return;
			_count ++;
			if (_count >= delay)
			{
				_count = 0;
				_image ++;
				if (_image == _sprite.number)
				{
					_image = loop ? 0 : _image - 1;
					if (anim !== null) anim();
				}
			}
		}
		
		internal var _point:Point = FP.point;
		internal var _zero:Point = FP.zero;
		internal var _rect:Rectangle = FP.rect;
		internal var _matrix:Matrix = FP.matrix;
		
		internal var _image:int = 0;
		internal var _count:int = 0;
		internal var _sprite:SpriteMap = null;
	}
}