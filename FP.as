package
{
	import flash.display.Bitmap;
	import flash.display.Graphics;
	import flash.display.Sprite;
	import flash.display.Stage;
	import flash.display.BitmapData;
	import flash.events.Event;
	import flash.media.Sound;
	import flash.media.SoundChannel;
	import flash.media.SoundTransform;
	import flash.geom.Point;
	import flash.geom.Matrix;
	import flash.geom.Rectangle;
	import flash.geom.ColorTransform;
	import punk.core.*;
	import punk.util.*;
	import punk.font.*;
	
	/// @info	Global FlashPunk class. Provides access to important game objects, such as World, Camera, etc. Also has useful functions for working with graphics and sound.
	public class FP
	{
		/// @info	[STATIC] The target FPS that FlashPunk will try to run at. Set the FPS in the Engine constructor, not by assigning this variable.
		public static var FPS:int;
		/// @info	[STATIC] The Currently active FlashPunk World, access for useful functions, etc.
		public static var world:World;
		/// @info	[STATIC] Change the active World by assigning this variable, do not assign FP.world yourself as the Engine needs to do some clean-up when switching.
		public static var goto:World;
		/// @info	[STATIC] Global FlashPunk Screen object, which acts as the screen buffer.
		public static var screen:Screen;
		/// @info	[STATIC] Point representing the top-left position of the Screen in the World.
		public static var camera:Point;
		/// @info	[STATIC] The currently set PixelFont that will be applied to new Text and TextPlus objects.
		public static var font:PixelFont;
		
		/// @info	[STATIC] Global factors used for controlling volume, values from 0 to 1.
		public static var volume:Number = 1;
		/// @info	[STATIC] Global factors used for controlling volume, values from 0 to 1.
		public static var soundVolume:Number = 1;
		/// @info	[STATIC] Global factors used for controlling volume, values from 0 to 1.
		public static function get musicVolume():Number
		{
			return _musicVolume;
		}
		public static function set musicVolume(value:Number):void
		{
			var mute:Number = (_musicMute ? 0 : 1);
			_musicVolume = value < 0 ? 0 : value;
			_musicTR.volume = _musicVolume * mute;
			if (_musicCH) _musicCH.soundTransform = _musicTR;
		}
		
		/// @info	[STATIC] Global flags used for muting sound.
		public static var mute:Boolean = false;
		/// @info	[STATIC] Global flags used for muting sound.
		public static var soundMute:Boolean = false;
		/// @info	[STATIC] Global flags used for muting sound.
		public static function get musicMute():Boolean
		{
			return _musicMute;
		}
		public static function set musicMute(value:Boolean):void
		{
			var mute:Number = (value ? 0 : 1);
			_musicMute = value;
			_musicTR.volume = _musicVolume * mute;
			if (_playing) _musicCH.soundTransform.volume = _musicVolume * mute;
		}
		
		/// @info	[STATIC] Global Flash DisplayObjects, you normally won't need to access these.
		public static var stage:Stage;
		public static var engine:Engine;
		
		/// @info	[STATIC] Global objects used commonly in rendering, collisions, etc.
		public static var point:Point = new Point();
		public static var point2:Point = new Point();
		public static var zero:Point = new Point();
		public static var matrix:Matrix = new Matrix();
		public static var rect:Rectangle = new Rectangle();
		public static var color:ColorTransform = new ColorTransform();
		
		
		/// @info	[STATIC] Dummy Sprite used for functions that use certain vector renderer functions.
		public static var line:Sprite = new Sprite();
		
		/// @info	Returns a stored SpriteMap with the corresponding properties, or creates a new one and stores it if it doesn't exist.
		///	@param	bitmap		The embedded Bitmap class to create the SpriteMap from.
		///	@param	imageW		The width of each image in the SpriteMap. Set to 0 to use the width of the bitmap.
		///	@param	imageH		The height of each image in the SpriteMap. Set to 0 to use the height of the bitmap.
		///	@param	flipX		If a horizontally-flipped version of this bitmap should be prepared.
		///	@param	flipY		If a vertically-flipped version of this bitmap should be prepared.
		///	@param	originX		The x-origin of the sprite, determines the offset position when drawing it.
		///	@param	originY		The y-origin of the sprite, determines the offset position when drawing it.
		///	@param	useCache	If the function should check for an existing SpriteMap (true), or just create a new one (false).
		public static function getSprite(bitmap:Class, imageW:int, imageH:int, flipX:Boolean = false, flipY:Boolean = false, originX:int = 0, originY:int = 0, useCache:Boolean = true):SpriteMap
		{
			var data:SpriteMap,
				temp:BitmapData,
				arr:Array = _sprite,
				pos:String = String(bitmap),
				fX:Boolean,
				fY:Boolean;
				
			if (useCache && arr[pos])
			{
				var spr:SpriteMap = arr[pos];
				if ((!flipX || spr.flippedX) && (!flipY || spr.flippedY)) return arr[pos];
				fX = spr.flippedX;
				fY = spr.flippedY;
			}
			
			if (flipX || flipY || fX || fY)
			{
				temp = (new bitmap).bitmapData;
				if (!imageW) imageW = temp.width;
				if (!imageH) imageH = temp.height;
				var	w:int = flipX ? temp.width << 1 : temp.width,
					h:int = flipY ? temp.height << 1 : temp.height;
				data = new SpriteMap(w, h, imageW, imageH, temp.width / imageW, originX, originY);
				data.copyPixels(temp, temp.rect, zero);
				matrix.b = matrix.c = 0;
				if (flipX || fX)
				{
					data.flippedX = true;
					data.imageR = w - imageW;
					matrix.a = -1;
					matrix.d = 1;
					matrix.tx = w;
					matrix.ty = 0;
					data.draw(temp, matrix);
				}
				if (flipY || fY)
				{
					data.flippedY = true;
					data.imageB = h >> 1;
					matrix.a = 1;
					matrix.d = -1;
					matrix.tx = 0;
					matrix.ty = h;
					data.draw(temp, matrix);
					if (flipX)
					{
						matrix.a = -1;
						matrix.tx = w;
						data.draw(temp, matrix);
					}
				}
				if (useCache) arr[pos] = data;
				return data;
			}
			
			temp = (new bitmap).bitmapData;
			if (!imageW) imageW = temp.width;
			if (!imageH) imageH = temp.height;
			data = new SpriteMap(temp.width, temp.height, imageW, imageH, temp.width / imageW, originX, originY);
			data.copyPixels(temp, temp.rect, zero);
			data.imageW = imageW;
			data.imageH = imageH;
			
			if (useCache) arr[pos] = data;
			return data;
		}
		
		/// @info	Returns a stored BitmapData. Useful if you have multiple classes that use the same embedded bitmap file.
		/// @param	bitmap		The embedded Bitmap class corresponding to the BitmapData.
		public static function getBitmapData(bitmap:Class):BitmapData
		{
			var arr:Array = _bitmap;
			if (arr[String(bitmap)]) return arr[String(bitmap)];
			return (arr[String(bitmap)] = (new bitmap()).bitmapData);
		}
		
		/// @info	Sets the PixelFont class to be used by Text and TextPlus objects, returns the stored PixelFont object.
		///	@param	bitmap		The Bitmap class to assign the new PixelFont.
		public static function setFont(fontClass:Class = null):PixelFont
		{
			if (!fontClass) fontClass = FontDefault;
			if (_font[String(fontClass)]) return (font = _font[String(fontClass)]);
			return (font = _font[String(fontClass)] = new fontClass());
		}
		
		/// @info	Plays a sound effect.
		/// @param	sound	The embedded Sound class to play.
		/// @param	vol		The volume factor, a value from 0 to 1.
		/// @param	pan		The panning factor, from -1 (left speaker) to 1 (right speaker).
		public static function play(sound:Class, vol:Number = 1, pan:Number = 0):void
		{
			if (mute || soundMute) return;
			var id:int = _soundID[String(sound)];
			if (!id)
			{
				_soundID[String(sound)] = id = _id;
				_sound[_id ++] = new sound();
			}
			_soundTR.volume = vol * soundVolume * volume;
			_soundTR.pan = pan;
			_sound[id].play(0, 0, _soundTR);
		}
		
		/// @info	Plays the sound as a music track.
		/// @param	sound		The embedded Sound class to play.
		/// @param	loop		Whether the track should loop or not.
		/// @param	end			An optional function to call when the track finishes or loops.
		public static function musicPlay(sound:Class, loop:Boolean = true, end:Function = null):void
		{
			musicStop();
			_music = new sound();
			_musicTR.volume = _musicVolume * volume;
			_musicCH = _music.play(0, loop ? 999 : 0, _musicTR);
			_musicCH.addEventListener(Event.SOUND_COMPLETE, musicEnd, false, 0, true);
			_playing = true;
			_looping = loop;
			_paused = false;
			_position = 0;
			_end = end;
		}
		
		/// @info	Stops the music track (will not trigger the end-sound function).
		public static function musicStop():void
		{
			if (!_playing) return;
			if (_musicCH.hasEventListener(Event.SOUND_COMPLETE))
				_musicCH.removeEventListener(Event.SOUND_COMPLETE, musicEnd, false);
			_musicCH.stop();
			_playing = _paused = false;
		}
		
		/// @info	Pauses the music track (will not trigger the end-sound function).
		public static function musicPause():void
		{
			if (_playing && !_paused)
			{
				_position = _musicCH.position;
				if (_musicCH.hasEventListener(Event.SOUND_COMPLETE))
					_musicCH.removeEventListener(Event.SOUND_COMPLETE, musicEnd, false);
				_musicCH.stop();
				_playing = false;
				_paused = true;
			}
		}
		
		/// @info	Resumes the music track from the position at which it was paused.
		public static function musicResume():void
		{
			if (_paused)
			{
				_musicCH = _music.play(_position, _looping ? 999 : 0, _musicTR);
				_musicCH.addEventListener(Event.SOUND_COMPLETE, musicEnd, false, 0, true);
				_playing = true;
				_paused = false;
			}
		}
		
		/// @info	Returns a randomly chosen Object from the parameters.
		/// @param	objs		The Objects you want to randomly choose from. Can be ints, Numbers, Points, etc.
		public static function choose(...objs):*
		{
			return objs[int(objs.length * Math.random())];
		}
		
		/// @info	Returns the sign of the value, so -1 for negative, 1 for positive, and 0 when 0.
		/// @param	value		The Number to evaluate.
		public static function sign(value:Number):int
		{
			return value < 0 ? -1 : (value > 0 ? 1 : 0);
		}
		
		/// @info	Finds the angle (in degrees) from point 1 to point 2.
		/// @param	x1		The first x-position.
		/// @param	y1		The first y-position.
		/// @param	x2		The second x-position.
		/// @param	y2		The second y-position.
		public static function angle(x1:Number, y1:Number, x2:Number = 0, y2:Number = 0):Number
		{
			var a:Number = Math.atan2(y2 - y1, x2 - x1) * _DEG;
			return a < 0 ? a + 360 : a;
		}
		
		/// @info	Returns FP.point with the values set to a vector corresponding to the angle and distance provided.
		/// @param	angle		The angle of the vector (in degrees).
		/// @param	length		The distance to the vector from (0, 0).
		public static function anglePoint(angle:Number, length:Number = 1):Point
		{
			point.x = Math.cos(angle * _RAD) * length;
			point.y = Math.sin(angle * _RAD) * length;
			return point;
		}
		
		/// @info	Returns the distance between the two points.
		/// @param	x1		The first x-position.
		/// @param	y1		The first y-position.
		/// @param	x2		The second x-position.
		/// @param	y2		The second y-position.
		public static function distance(x1:Number, y1:Number, x2:Number = 0, y2:Number = 0):Number
		{
			return Math.sqrt((x2 - x1) * (x2 - x1) + (y2 - y1) * (y2 - y1));
		}
		
		/// @info	Returns the value clamped to the scale.
		/// @param	value		The Number to evaluate.
		/// @param	min			The minimum range. The return value will be between this and max.
		/// @param	max			The maximum range. The return value will be between this and min.
		public static function clamp(value:Number, min:Number, max:Number):Number
		{
			if (max > min)
			{
				value = value < max ? value : max;
				return value > min ? value : min;
			}
			value = value < min ? value : min;
			return value > max ? value : max;
		}
		
		/// @info	Transfers a value from one scale to another scale. For example, scale(.5, 0, 1, 10, 20) == 15, and scale(3, 0, 5, 100, 0) == 40.
		/// @param	value		The value on the first scale.
		/// @param	min			The minimum range of the first scale.
		/// @param	max			The maximum range of the first scale.
		/// @param	min2		The minimum range of the second scale.
		/// @param	max2		The maximum range of the second scale.
		public static function scale(value:Number, min:Number, max:Number, min2:Number, max2:Number):Number
		{
			return min2 + ((value - min) / (max - min)) * (max2 - min2);
		}
		
		/// @info	Transfers a value from one scale to another scale, but clamps the return value within the second scale.
		/// @param	value		The value on the first scale.
		/// @param	min			The minimum range of the first scale.
		/// @param	max			The maximum range of the first scale.
		/// @param	min2		The minimum range of the second scale. The return value will be between this and max2.
		/// @param	max2		The maximum range of the second scale. The return value will be between this and min2.
		public static function scaleClamp(value:Number, min:Number, max:Number, min2:Number, max2:Number):Number
		{
			value = min2 + ((value - min) / (max - min)) * (max2 - min2);
			if (max2 > min2)
			{
				value = value < max2 ? value : max2;
				return value > min2 ? value : min2;
			}
			value = value < min2 ? value : min2;
			return value > max2 ? value : max2;
		}
		
		// function for the end-sound soundEvent to trigger
		private static function musicEnd(e:Event):void
		{
			if (_looping)
			{
				if (_musicCH.hasEventListener(Event.SOUND_COMPLETE))
					_musicCH.removeEventListener(Event.SOUND_COMPLETE, musicEnd, false);
				_musicCH = _music.play(0, 999, _musicTR);
				_musicCH.addEventListener(Event.SOUND_COMPLETE, musicEnd, false, 0, true);
			}
			else
			{
				_playing = false;
				_paused = false;
				_position = 0;
			}
			if (_end !== null) _end();
		}
		
		// used for rad-to-deg and deg-to-rad conversion
		private static const _DEG:Number = -180 / Math.PI;
		private static const _RAD:Number = Math.PI / -180;
		
		// storage arrays
		private static var _sprite:Array = [];	// SpriteMaps
		private static var _bitmap:Array = [];	// BitmapDatas
		private static var _font:Array = [];	// PixelFonts
		
		// variables for playing sounds/music
		private static var _id:int = 0;
		private static var _soundID:Array = [];
		private static var _sound:Vector.<Sound> = new Vector.<Sound>();
		private static var _soundTR:SoundTransform = new SoundTransform();
		private static var _music:Sound;
		private static var _musicTR:SoundTransform = new SoundTransform();
		private static var _musicCH:SoundChannel;
		private static var _playing:Boolean = false;
		private static var _looping:Boolean = false;
		private static var _paused:Boolean = false;
		private static var _position:Number = 0;
		private static var _musicVolume:Number = 1;
		private static var _musicMute:Boolean = false;
		private static var _end:Function = null;
	}
}