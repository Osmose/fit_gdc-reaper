package punk.core
{
	import flash.system.System;
	import flash.display.Sprite;
	import flash.display.Bitmap;
	import flash.events.Event;
	import flash.events.TimerEvent;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.utils.Timer;
	import flash.utils.getTimer;
	import punk.util.*;
	import punk.logo.*;
	
	/// @info	The FlashPunk base engine, runs your game loop and updates/renders your World.
	public class Engine extends Sprite
	{
		/// @info	Constructor.
		/// @param	width			Unscaled width of your screen.
		/// @param	height			Unscaled height of your screen.
		/// @param	fps				Speed of your game loop (frames per second).
		/// @param	scale			Scale of your screen.
		/// @param	world			The class to initiate as the opening World, and so it must extend World.
		/// @param	runUnfocused	If the game loop should pause when the Flash Player loses focus.
		/// @param	showSplash		If the FlashPunk splash screen should be displayed before the game starts.
		/// @param	logoBack		The background color of the FlashPunk splash screen.
		/// @param	logoFront		The color of the FlashPunk logo in the splash screen.
		public function Engine(width:int = 320, height:int = 240, fps:int = 60, scale:int = 1, world:Class = null, runUnfocused:Boolean = false, showSplash:Boolean = true, logoBack:uint = 0x202020, logoFront:uint = 0xFF3366)
		{
			if (world == null) world = World;
			_start = world;
			_width = width;
			_height = height;
			FP.FPS = fps;
			_scale = scale;
			_runUnfocused = runUnfocused;
			
			_splash = showSplash;
			_logoBack = logoBack;
			_logoFront = logoFront;
			
			if (stage) init();
			else addEventListener(Event.ADDED_TO_STAGE, onStage);
		}
		
		/// @info	Get the average framerate over the last second.
		public function get FPS():int
		{
			return _frameRate;
		}
		
		/// @info	Override this. Called when the game starts, right before init() is called for the opening World.
		public function init():void
		{
			
		}
		
		private function onStage(e:Event = null):void
		{
			removeEventListener(Event.ADDED_TO_STAGE, onStage);
			stage.frameRate = 60;
			
			_rate = 1000 / FP.FPS;
			_skip = _rate * 10;
			_last = getTimer();
			_current = _last;
			_delta = 0;
			_timer = new Timer(4);
			_timer.addEventListener(TimerEvent.TIMER, tick);
			_timer.start();
			
			_frame = 0;
			_frameTime = 0;
			_frameRate = FP.FPS;
			_frameTimer = new Timer(1000);
			_frameTimer.addEventListener(TimerEvent.TIMER, frameTick);
			_frameTimer.start();
			
			FP.stage = stage;
			FP.engine = this;
			FP.camera = new Point();
			
			FP.screen = _screen = new Screen(_width, _height, _logoBack, _scale);
			_screenRect = FP.screen.rect;
			_bitmap = new Bitmap(FP.screen);
			_bitmap.scaleX = _scale;
			_bitmap.scaleY = _scale;
			addChild(_bitmap);
			
			Input.enable(stage);
			
			if (_splash) FP.world = _world = new Splash(_start, _logoBack, _logoFront);
			else FP.world = _world = new _start();
			
			stage.addEventListener(Event.ACTIVATE, focusGain);
			stage.addEventListener(Event.DEACTIVATE, focusLose);
			
			init();
			_world.init();
		}
		
		// when the game gains focus
		private function focusGain(e:Event):void
		{
			_focus = true;
			if (_world !== null) _world.focusIn();
			if (!_timer.running)
			{
				_last = getTimer();
				_timer.start();
			}
		}
		
		// when the game loses focus
		private function focusLose(e:Event):void
		{
			_focus = false;
			if (_world !== null) _world.focusOut();
		}
		
		// this uses a delta-timer, so your game-loop will automatically adjust to compensate for slowdown
		private function tick(e:TimerEvent):void
		{
			_current = getTimer();
			_delta += _current - _last;
			_last = _current;
			
			if (_delta >= _rate)
			{
				_frame ++;
				_delta %= _skip;	// avoid too many frame-skips
				
				// game update
				while (_delta >= _rate)
				{
					_delta -= _rate;
					_world.updateF();
					Input.update();
				}
				
				// game render
				_screen.lock();
				_screen.fillRect(_screenRect, FP.screen.color);
				_world.renderF();
				_screen.unlock();
				e.updateAfterEvent();
				
				// switch worlds
				if (FP.goto) switchWorld();
				
				// freeze game when unfocused
				if (!_focus && !_runUnfocused) _timer.stop();
			}
		}
		
		// switches the active world
		private function switchWorld():void
		{
			FP.world.removeAll();
			FP.world = _world = FP.goto;
			FP.goto.init();
			FP.goto = null;
			System.gc();
			System.gc();
		}
		
		private function frameTick(e:TimerEvent):void
		{
			_frameRate = _frame;
			_frame = 0;
		}
		
		private var _width:int;
		private var	_height:int;
		private var	_scale:int;
		
		private var	_world:World;
		private var	_screen:Screen;
		
		private var	_rate:Number;
		private var	_skip:Number;
		private var	_last:Number;
		private var	_current:Number;
		private var	_delta:Number;
		private var	_timer:Timer;
		
		private var	_frame:int;
		private var	_frameTime:Number;
		private var	_frameRate:int;
		private var	_frameTimer:Timer;
		
		private var	_start:Class;
		private var	_splash:Boolean;
		private var	_logoBack:uint;
		private var	_logoFront:uint;
		
		private var _focus:Boolean = true; 		// if the stage is in focus
		private var	_runUnfocused:Boolean; 		// if the game should run while unfocused
		
		internal var _bitmap:Bitmap;
		internal var _screenRect:Rectangle;
	}
}