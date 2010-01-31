package punk.core 
{
	import flash.events.Event;
	import flash.media.Sound;
	import flash.media.SoundChannel;
	import flash.media.SoundTransform;
	
	public class SoundBox 
	{
		private var
			_id:int = 1,
			_soundID:Array,
			_sound:Vector.<Sound>,
			_soundTR:SoundTransform,
			_music:Sound,
			_musicTR:SoundTransform,
			_musicCH:SoundChannel,
			_playing:Boolean = false,
			_looping:Boolean = false,
			_paused:Boolean = false,
			_position:Number = 0,
			_musicVolume:Number = 1,
			_musicMute:Boolean = false,
			_end:Function = null;
			
		public var
			volume:Number = 1,			// global volume
			soundVolume:Number = 1,		// sound effects Volume
			mute:Boolean = false,		// if sounds are muted
			soundMute:Boolean = false;	// if sound effects are muted
		
		public function SoundBox() 
		{
			_soundID = [];
			_sound = new Vector.<Sound>(1);
			_sound[0] = new Sound();
			_soundTR = new SoundTransform();
			_musicTR = new SoundTransform();
		}
		
		// plays the particular sound with the volume and pan factor
		public function play(sound:Class, vol:Number = 1, pan:Number = 0):void
		{
			if (mute || soundMute) return;
			var id:int = _soundID[String(sound)];
			if (!id)
			{
				_soundID[String(sound)] = id = _id;
				_sound[_id ++] = new sound();
			}
			_soundTR.volume = vol * soundVolume * volume;
			_soundTR.pan = pan;
			_sound[id].play(0, 0, _soundTR);
		}
		
		// plays the particular sound as a music track, you can specify looping and an end-sound function call
		public function musicPlay(sound:Class, loop:Boolean = true, end:Function = null):void
		{
			musicStop();
			_music = new sound();
			_musicTR.volume = _musicVolume * volume;
			_musicCH = _music.play(0, loop ? 999 : 0, _musicTR);
			_musicCH.addEventListener(Event.SOUND_COMPLETE, musicEnd, false, 0, true);
			_playing = true;
			_looping = loop;
			_paused = false;
			_position = 0;
			_end = end;
		}
		
		// stops the current music track from playing, it will NOT play the end-sound function
		public function musicStop():void
		{
			if (!_playing) return;
			if (_musicCH.hasEventListener(Event.SOUND_COMPLETE))
				_musicCH.removeEventListener(Event.SOUND_COMPLETE, musicEnd, false);
			_musicCH.stop();
			_playing = _paused = false;
		}
		
		// pauses the current music track
		public function musicPause():void
		{
			if (_playing && !_paused)
			{
				_position = _musicCH.position;
				if (_musicCH.hasEventListener(Event.SOUND_COMPLETE))
					_musicCH.removeEventListener(Event.SOUND_COMPLETE, musicEnd, false);
				_musicCH.stop();
				_playing = false;
				_paused = true;
			}
		}
		
		// resumes the music track from the same position that it was paused at
		public function musicResume():void
		{
			if (_paused)
			{
				_musicCH = _music.play(_position, _looping ? 999 : 0, _musicTR);
				_musicCH.addEventListener(Event.SOUND_COMPLETE, musicEnd, false, 0, true);
				_playing = true;
				_paused = false;
			}
		}
		
		private function musicEnd(e:Event):void
		{
			if (_looping)
			{
				if (_musicCH.hasEventListener(Event.SOUND_COMPLETE))
					_musicCH.removeEventListener(Event.SOUND_COMPLETE, musicEnd, false);
				_musicCH = _music.play(0, 999, _musicTR);
				_musicCH.addEventListener(Event.SOUND_COMPLETE, musicEnd, false, 0, true);
			}
			else
			{
				_playing = false;
				_paused = false;
				_position = 0;
			}
			if (_end !== null) _end();
		}
		
		// sets the volume of the music
		public function set musicVolume(value:Number):void
		{
			var mute:Number = (_musicMute ? 0 : 1);
			_musicVolume = value < 0 ? 0 : value;
			_musicTR.volume = _musicVolume * mute;
			if (_musicCH) _musicCH.soundTransform = _musicTR;
		}
		
		// gets the volume of the music
		public function get musicVolume():Number
		{
			return _musicVolume;
		}
		
		// mutes the music (the volume value will not be changed)
		public function set musicMute(value:Boolean):void
		{
			var mute:Number = (value ? 0 : 1);
			_musicMute = value;
			_musicTR.volume = _musicVolume * mute;
			if (_playing) _musicCH.soundTransform.volume = _musicVolume * mute;
		}
		
		// returns whether the music is muted
		public function get musicMute():Boolean
		{
			return _musicMute;
		}
	}
}