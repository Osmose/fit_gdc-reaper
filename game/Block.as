package game 
{
	import punk.Actor;
	
	public class Block extends Actor
	{
		[Embed(source = '../resources/block.png')] 
		private var imgBlock:Class;
		
		public function Block() 
		{
			sprite = FP.getSprite(imgBlock, 16, 16);
			setCollisionRect(16, 16, 0, 0);
			setCollisionType("solid");
		}
		
	}

}