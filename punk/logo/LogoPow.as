package punk.logo 
{
	import punk.Acrobat;
	
	public class LogoPow extends Acrobat
	{
		[Embed(source = 'data/pow.png')] private var ImgLogoPow:Class;
		
		private var
			_cogs:LogoCogs,
			_text:LogoText,
			_state:int,
			_wait:int;
		
		public function LogoPow(cogs:LogoCogs, text:LogoText) 
		{
			sprite = FP.getSprite(ImgLogoPow, 56, 7);
			alpha = 0;
			x += 6;
			y += 48;
			_cogs = cogs;
			_text = text;
		}
		
		override public function update():void
		{
			if (_state == 0)
			{
				alpha += .1;
				if (alpha >= 1)
				{
					alpha = 1;
					_state = 1;
					_wait = 40;
				}
			}
			else if (_state == 1)
			{
				_wait --;
				if (_wait == 0) _state = 2;
			}
			else if (_state == 2)
			{
				alpha -= .1;
				if (alpha <= 0)
				{
					_state = 3;
					FP.world.add(_cogs);
					FP.world.add(_text);
					FP.world.remove(this);
				}
			}
		}
	}
}