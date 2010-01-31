package punk.logo
{
	import punk.core.*;
	
	public class Splash extends World
	{
		private var
			_world:Class = null,	// world class to create when the splash-screen ends
			_backColor:uint,		// the background color for the splash-screen
			_logoColor:uint,		// the logo color for the splash-screen
			_logoX:int,				// x-position of the logo (set in the init() function)
			_logoY:int,				// y-position of the logo (set in the init() function)
			_cogs:LogoCogs,
			_text:LogoText,
			_pow:LogoPow;
		
		public function Splash(world:Class = null, back:uint = 0x202020, front:uint = 0xFF3366) 
		{
			if (world == null) world = World;
			_world = world;
			_backColor = back;
			_logoColor = front;
		}
		
		override public function init():void
		{
			// set the screen's background color
			FP.screen.color = _backColor;
			
			// center the position of the logo
			_logoX = (FP.screen.width / 2) - 34;
			_logoY = (FP.screen.height / 1.5) - 27;
			
			// create the logo cogs
			_cogs = new LogoCogs();
			_cogs.color = _logoColor;
			_cogs.x += _logoX;
			_cogs.y += _logoY;
			
			// create the logo text
			_text = new LogoText();
			_text.color = _logoColor;
			_text.x += _logoX;
			_text.y += _logoY;
			
			// create & add the "powered by" text
			_pow = new LogoPow(_cogs, _text);
			_pow.color = _logoColor;
			_pow.x += _logoX;
			_pow.y += _logoY;
			add(_pow);
		}
		
		override public function update():void
		{
			if (_text._fadeOut) _cogs.alpha = _text.alpha;
			if (_text._endWait > 9) FP.goto = new _world();
		}
		
		override public function render():void
		{
			
		}
	}
}