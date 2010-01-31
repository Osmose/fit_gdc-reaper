package
{
	import punk.core.*;
	import game.*;
	
	[SWF(width = "640", height = "480")]
	[Frame(factoryClass = "punk.core.Factory")]
	
	public class Main extends Engine
	{
		public function Main()
		{
			super(320, 240, 60, 2, Level, false, true);
		}
	}
}