package game 
{
	import punk.*;
	import punk.core.*;
	import punk.util.*;
	
	public class Player extends Actor
	{
		[Embed(source = '../resources/reaper.png')] 
		private var imgReaper:Class;
		
		private var xspeed:Number = 0;
		private var yspeed:Number = 0;
		private var aspeed:Number = 0.2;
		private var gspeed:Number = 0.2;
		private var fspeed:Number = 0.4;
		private var mspeed:Number = 1;
		private var jspeed:Number = 3.6;
		private var bscythe:Boolean = true;
		
		public function Player() 
		{
			sprite = FP.getSprite(imgReaper, 16, 16, true);
			delay = 12;
			setCollisionRect(12, 15, 0, 1);
			setCollisionType("player");
			
			Input.define("right", Key.RIGHT);
			Input.define("left", Key.LEFT);
			Input.define("jump", Key.X);
			Input.define("weapon", Key.SPACE);
		}
		
		override public function update():void {
			if(Input.check("right")) {
				xspeed += aspeed;
				flipX = false;
			}
			if(Input.check("left")) {
				xspeed -= aspeed;
				flipX = true;
			}
			if(Input.check("jump") && collide("solid",x,y+1)) {
				yspeed = -jspeed;
			}
			
			
			if (Input.check("weapon")) {
				if (bscythe) {
					var e:Entity;
					FP.world.add(e = new Scythe());
					e.x = x;
					e.y = y;
					bscythe = false;
				}
			} else {
				bscythe = true;
			}
			
			for (var i:int = 0; i < Math.abs(xspeed); i += 1) {
				if (!collide("solid", x + FP.sign(xspeed), y)) {
					x += FP.sign(xspeed);
				} else { 
					xspeed = 0; 
					break;
				}
			}
			
			for (i = 0; i < Math.abs(yspeed); i += 1) {
				if (!collide("solid", x, y + FP.sign(yspeed))) {
					y += FP.sign(yspeed);
				} else {
					yspeed = 0;
					break;
				}
			}
			
			yspeed += gspeed;
			
			if (!Input.check("right") && !Input.check("left")) {
				xspeed -= FP.sign(xspeed) * fspeed;
				if (Math.abs(xspeed) < 0.2) { xspeed = 0; }
				image = 0;
			}
			
			if (Math.abs(xspeed) > mspeed) { xspeed = FP.sign(xspeed) * mspeed; }
			
			if (!Input.check("jump") && yspeed < 0) {
				yspeed += gspeed;
			}
			
			FP.camera.x = x - 320 / 2;
		}
		
	}

}