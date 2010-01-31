package punk.logo 
{
	import punk.Acrobat;
	import punk.core.SpriteMap;
	
	public class LogoText extends Acrobat
	{
		[Embed(source = 'data/words.png')] private const ImgLogoText:Class;
		[Embed(source = 'data/scribble.mp3')] private const SndScribble:Class;
		[Embed(source = 'data/boing.mp3')] private const SndBoing:Class;
		
		private var
			_wait:int = 30,
			_state:int = 0,
			_punkSnd:Boolean = false;
			
		internal var
			_fadeOut:Boolean = false,
			_fadeWait:int = 0,
			_endWait:int = 0;
		
		public function LogoText() 
		{
			sprite = FP.getSprite(ImgLogoText, 51, 12);
			loop = false;
			anim = animEnd;
			delay = 0;
			y += 41;
		}
		
		override public function update():void
		{
			if (_fadeWait > 0)
			{
				_fadeWait --;
				if (_fadeWait == 0) _fadeOut = true;
			}
			
			if (_fadeOut)
			{
				if (alpha > 0) alpha -= .02;
				else
				{
					alpha = 0;
					_endWait ++;
				}
				return;
			}
			
			// countdown to start writing out the letters
			if (_wait > 0)
			{
				_wait --;
				if (_wait == 0)
				{
					_state ++;
					if (_state == 3)
					{
						delay = 6;
					}
					else
					{
						delay = 1;
						FP.play(SndScribble);
					}
				}
			}
			
			// play a sound during each letter of "Punk"
			if (image == 40 || image == 42 || image == 44 || image == 46)
			{
				if (!_punkSnd)
				{
					FP.play(SndBoing);
					_punkSnd = true;
				}
			}
			else _punkSnd = false;
			
			// pause for a moment after the first word
			if (_state == 1 && image == 39)
			{
				delay = 0;
				_wait = 10;
				_state ++;
			}
		}
		
		private function animEnd():void
		{
			_fadeWait = 60;
		}
	}
}