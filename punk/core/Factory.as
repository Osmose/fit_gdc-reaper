package punk.core
{
	import flash.events.Event;
	import flash.display.MovieClip;
	import flash.display.DisplayObject;
	import flash.display.StageAlign;
	import flash.display.StageQuality;
	import flash.display.StageScaleMode;
	import flash.display.StageDisplayState;
	import flash.utils.getDefinitionByName;
	
	/// @info	The MovieClip class that operates while the game is loading. Extend this to create a unique preloader.
	public class Factory extends MovieClip
	{
		/// @info	Constructor.
		///	@param	mainClass	The name of your Engine class. If you extend this class, your class's constructor must have the same property and pass it to super().
		public function Factory(mainClass:String = "Main") 
		{
			stop();
			
			_main = mainClass;
			
			stage.align = StageAlign.TOP_LEFT;
			stage.quality = StageQuality.HIGH;
			stage.scaleMode = StageScaleMode.NO_SCALE;
			stage.displayState = StageDisplayState.NORMAL;
			
			addEventListener(Event.ENTER_FRAME, enterFrame);
		}
		
		/// @info	Override this. This function is called every frame while the game is loading, and can be used as a temporary game loop.
		/// @param	percent		A value from 0 to 1 representing the percentage of the game that has loaded. Use for loading bars, etc.
		public function loading(percent:Number):void
		{
			
		}
		
		private function enterFrame(e:Event):void
		{
			if (framesLoaded == totalFrames)
			{
				removeEventListener(Event.ENTER_FRAME, enterFrame);
				nextFrame();
				var main:Class = Class(getDefinitionByName(_main));
				if (main)
				{
					var mainObject:Object = new main();
	                addChild(mainObject as DisplayObject);
				}
			}
			else
			{
				var percent:Number = root.loaderInfo.bytesLoaded / root.loaderInfo.bytesTotal;
				loading(percent);
			}
		}
		
		private var _main:String;
	}
}