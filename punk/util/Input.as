package punk.util 
{
	import flash.display.Stage;
	import flash.events.KeyboardEvent;
	import flash.events.MouseEvent;
	
	/// @info	Static class updated by Engine. Use for defining and checking keyboard/mouse input.
	public class Input
	{
		/// @info	[STATIC] If the mouse button is currently held down.
		public static var mouseDown:Boolean = false;
		/// @info	[STATIC] If the mouse button is currently up.
		public static var mouseUp:Boolean = true;
		/// @info	[STATIC] If the mouse button was pressed this frame.
		public static var mousePressed:Boolean = false;
		/// @info	[STATIC] If the mouse button was released this frame.
		public static var mouseReleased:Boolean = false;
		/// @info	The x-position of the mouse on the screen.
		public static function get mouseX():int
		{
			return FP.stage.mouseX / FP.screen.scale;
		}
		/// @info	The y-position of the mouse on the screen.
		public static function get mouseY():int
		{
			return FP.stage.mouseY / FP.screen.scale;
		}
		
		/// @info	Defines a new input type. For example: Input.define("shoot", Key.CONTROL, Key.SPACE, Key.A);
		/// @param	name		The name of the input.
		/// @param	...keys		The keys representing this input
		public static function define(name:String, ...keys):void
		{
			_control[name] = Vector.<int>(keys);
		}
		
		/// @info	Returns whether a key is held down.
		/// @param	name	The name of the input type to check.
		public static function check(name:String):Boolean
		{
			var v:Vector.<int> = _control[name],
				i:int = v.length;
			while (i --)
			{
				if (_key[v[i]]) return true;
			}
			return false;
		}
		
		/// @info	Returns whether a key was pressed this frame.
		/// @param	name	The name of the input type to check.
		public static function pressed(name:String):Boolean
		{
			var v:Vector.<int> = _control[name],
				i:int = v.length;
			while (i --)
			{
				if (_press.indexOf(v[i]) >= 0) return true;
			}
			return false;
		}
		
		/// @info	Returns whether a key was released this frame.
		/// @param	name	The name of the input type to check.
		public static function released(name:String):Boolean
		{
			var v:Vector.<int> = _control[name],
				i:int = v.length;
			while (i --)
			{
				if (_release.indexOf(v[i]) >= 0) return true;
			}
			return false;
		}
		
		/// @info	Returns an array representing the keys for the input type.
		/// @param	name	The name of the input type.
		public static function keys(name:String):Vector.<int>
		{
			return _control[name] as Vector.<int>;
		}
		
		/// @info	Called by Engine when the game starts to enable the keyboard and mouse event listeners.
		/// @param	stage	The Flash Stage object.
		public static function enable(stage:Stage):void
		{
			if (!_enabled)
			{
				stage.addEventListener(KeyboardEvent.KEY_DOWN, onKeyDown);
				stage.addEventListener(KeyboardEvent.KEY_UP, onKeyUp);
				stage.addEventListener(MouseEvent.MOUSE_DOWN, onMouseDown);
				stage.addEventListener(MouseEvent.MOUSE_UP, onMouseUp);
				_enabled = true;
			}
		}
		
		/// @info	Called by Engine to update the mouse and key states.
		public static function update():void
		{
			while (_pressNum --) _press[_pressNum] = -1;
			_pressNum = 0;
			while (_releaseNum --) _release[_releaseNum] = -1;
			_releaseNum = 0;
			if (mousePressed) mousePressed = false;
			if (mouseReleased) mouseReleased = false;
		}
		
		private static function onKeyDown(e:KeyboardEvent):void
		{
			var code:int = e.keyCode;
			if (!_key[code])
			{
				_key[code] = true;
				_keyNum ++;
				_press[_pressNum ++] = code;
			}
		}
		
		private static function onKeyUp(e:KeyboardEvent):void
		{
			var code:int = e.keyCode;
			if (_key[code])
			{
				_key[code] = false;
				_keyNum --;
				_release[_releaseNum ++] = code;
			}
		}
		
		private static function onMouseDown(e:MouseEvent):void
		{
			if (!mouseDown)
			{
				mouseDown = true;
				mouseUp = false;
				mousePressed = true;
				mouseReleased = false;
			}
		}
		
		private static function onMouseUp(e:MouseEvent):void
		{
			mouseDown = false;
			mouseUp = true;
			mousePressed = false;
			mouseReleased = true;
		}
		
		private static var _enabled:Boolean = false;
		private static var _key:Vector.<Boolean> = new Vector.<Boolean>(256);
		private static var _keyNum:int = 0;
		private static var _press:Vector.<int> = new Vector.<int>(256);
		private static var _release:Vector.<int> = new Vector.<int>(256);
		private static var _pressNum:int = 0;
		private static var _releaseNum:int = 0;
		
		private static var _control:Array = [];
	}
}