package game 
{
	import punk.Acrobat;
	
	public class Scythe extends Acrobat
	{
		[Embed(source = '../resources/scythe.png')] 
		private var imgScythe:Class;
		
		private var xspeed:Number = 1;
		
		public function Scythe() 
		{
			sprite = FP.getSprite(imgScythe, 8, 8, true);
			delay = 12;
			setCollisionRect(7, 8, 1, 0);
			setCollisionType("weapon");
		}
		
		override public function update():void {
			
			for (var i:int = 0; i < Math.abs(xspeed); i += 1) {
				if (!collide("solid", x + FP.sign(xspeed), y)) {
					x += FP.sign(xspeed);
					angle += -25;
				} else { 
					xspeed = 0;
					FP.world.remove(this);
					break;
				}
			}
			
		}
	}

}