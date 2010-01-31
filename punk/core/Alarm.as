package punk.core 
{
	/// @info	Useful frame-based timer class, used for managing the game pace, timed events, etc.
	public class Alarm 
	{
		/// @info	[STATIC] Constants for different types of alarms you can set.
		public static const ONESHOT:int = 0;
		public static const LOOPING:int = 1;
		public static const PERSIST:int = 2;
		
		/// @info	How many frames it will take the alarm to fire when it starts.
		public var totalFrames:int;
		/// @info	How many more frames the alarm has to go before it fires.
		public var remainingFrames:int;
		/// @info	The function that the alarm will call when it fires.
		public var call:Function;
		/// @info	The alarm type, which specify what the alarm should do when it fires.
		public var type:int;
		
		/// @info	Constructor.
		/// @param	frames		How many frames the alarm should wait before firing.
		/// @param	call		The function that the alarm will call when it fires.
		/// @param	type		The alarm type, which specify what the alarm should do when it fires.
		public function Alarm(frames:int, call:Function, type:int = 0) 
		{
			_added = _running = false;
			totalFrames = remainingFrames = frames;
			this.call = call;
			this.type = type;
		}
		
		/// @info	Sets all the parameters of the alarm and resets it.
		/// @param	frames		How many frames the alarm should wait before firing.
		/// @param	call		The function that the alarm will call when it fires.
		/// @param	type		The alarm type, which specify what the alarm should do when it fires.
		public function set(frames:int, call:Function, type:int = 0):Alarm
		{
			remainingFrames = totalFrames = frames;
			this.call = call;
			this.type = type;
			return this;
		}
		
		/// @info	Starts the alarm, restarting it from the beginning if it has stopped or is already running.
		public function start():Alarm
		{
			_running = true;
			remainingFrames = totalFrames;
			return this;
		}
		
		/// @info	Resumes the alarm if it has stopped.
		public function resume():Alarm
		{
			if (type == LOOPING && !remainingFrames) remainingFrames = totalFrames;
			_running = true;
			return this;
		}
		
		/// @info	Stops the alarm while running, so it will not fire.
		public function stop():Alarm
		{
			_running = false;
			return this;
		}
		
		/// @info	Returns whether the alarm is running or not.
		public function get isRunning():Boolean
		{
			return _running;
		}
		
		/// @info	Returns whether the alarm has fired and is no longer running.
		public function get isFinished():Boolean
		{
			return !_running && !remainingFrames;
		}
		
		internal function update():void
		{
			var a:Alarm = this,
				n:Alarm = this;
			while (a)
			{
				n = a._next;
				if (a._running)
				{
					a.remainingFrames --;
					if (!a.remainingFrames)
					{
						a._entity.alarmLast = a;
						if (a.type == ONESHOT)
						{
							// stop and remove the alarm
							if (a._next) a._next._prev = a._prev;
							if (a._prev) a._prev._next = a._next;
							if (a._entity._alarmFirst == a) a._entity._alarmFirst = a._next;
							a._next = a._prev = null;
							a._entity = null;
							a._added = a._running = false;
						}
						else if (a.type == LOOPING)
						{
							// reset the alarm automatically
							a.remainingFrames = a.totalFrames;
						}
						else if (a.type == PERSIST)
						{
							// just stop the alarm, but keep it in the list
							a._running = false;
						}
						a.call();
					}
				}
				a = n;
			}
		}
		
		internal var _added:Boolean;
		internal var _running:Boolean;
		internal var _entity:Core;
		internal var _prev:Alarm;
		internal var _next:Alarm;
	}
}