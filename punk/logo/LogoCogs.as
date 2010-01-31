package punk.logo 
{
	import punk.Acrobat;
	
	public class LogoCogs extends Acrobat
	{
		[Embed(source = 'data/cogs.png')] private const ImgLogoCogs:Class;
		
		private var
			_spit:Boolean = false;
		
		public function LogoCogs() 
		{
			sprite = FP.getSprite(ImgLogoCogs, 68, 41);
			delay = 6;
			alpha = 0;
		}
		
		override public function update():void
		{
			if (alpha < 1) alpha += .01;
			if (!_spit && image == 3)
			{
				_spit = true;
				var heart:Acrobat = new LogoHeart(x + 58, y, this);
				heart.color = color;
				heart.alpha *= alpha;
				FP.world.add(heart);
			}
			if (image == 4) _spit = false;
		}
	}
}