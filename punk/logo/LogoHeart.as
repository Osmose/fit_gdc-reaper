package punk.logo 
{
	import punk.Acrobat;
	
	public class LogoHeart extends Acrobat
	{
		[Embed(source = 'data/heart.png')] private const ImgLogoHeart:Class;
		
		private var
			_spdX:Number,
			_spdY:Number,
			_slow:Number,
			_par:Acrobat;
		
		public function LogoHeart(startx:int, starty:int, parent:Acrobat) 
		{
			sprite = FP.getSprite(ImgLogoHeart, 11, 9);
			delay = 4;
			loop = false;
			_spdX = 1 + Math.random() * 1;
			_spdY = -1 - Math.random();
			_slow = .02 + Math.random() * .03;
			_par = parent;
			x = startx;
			y = starty;
		}
		
		override public function update():void
		{
			x += _spdX;
			y += _spdY;
			if (_spdX > 0) _spdX -= _slow;
			else _spdX = 0;
			alpha = _par.alpha;
		}
	}
}