package punk.core
{
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Sprite;
	import flash.display.Stage;
	import flash.events.Event;
	import flash.geom.ColorTransform;
	import flash.geom.Matrix;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.media.Sound;
	import flash.media.SoundChannel;
	import flash.media.SoundMixer;
	import flash.media.SoundTransform;
	import flash.utils.getQualifiedClassName;
	import flash.system.System;
	
	/// @info	A Playing stage that game Entities can be added to. Used for organization, example worlds: "Menu", "Level1", etc.
	public class World extends Core
	{
		/// @info	Constructor. Do not add or remove entities to a World in its constructor. Instead, override the init() function and do it there.
		public function World() 
		{
			FP.camera.x = FP.camera.y = 0;
		}
		
		/// @info	This is called when the World is initiated, has been assigned to FP.world, and will now be updated in the game loop.
		public function init():void
		{
			
		}
		
		/// @info	Override this. Called when the Flash Player gains focus.
		public function focusIn():void
		{
			
		}
		
		/// @info	Override this. Called when the Flash Player loses focus.
		public function focusOut():void
		{
			
		}
		
		/// @info	Adds an Entity to the World.
		/// @param	e		The Entity to add.
		public function add(e:Entity):Entity
		{
			if (e._added) return e;
			
			// add to update and render lists
			if (_updateFirst) _updateFirst._updatePrev = _renderFirst._renderPrev = e;
			e._updateNext = _updateFirst;
			e._renderNext = _renderFirst;
			e._updatePrev = e._renderPrev = null;
			_updateFirst = _renderFirst = e;
			_entityNum ++;
			
			// set information
			e._added = true;
			
			// set depth
			var d:int = e._depth;
			e._depth = int.MIN_VALUE;
			e.depth = ~d + 1;
			
			// set collision type
			if (e._collisionType) e.setCollisionType(e._collisionType);
			
			return e;
		}
		
		/// @info	Adds a Vector of Entities to the World.
		/// @param	v		The Vector of Entities to add.
		public function addVector(v:Vector.<Entity>):void
		{
			var i:int = v.length;
			while (i --) add(v[i]);
		}
		
		/// @info	Removes an Entity from the World.
		/// @param	e		The Entity to remove.
		public function remove(e:Entity):void
		{
			if (!e._added) return;
			
			// remove from update and render lists
			if (e == _updateFirst) _updateFirst = e._updateNext;
			if (e == _renderFirst) _renderFirst = e._renderNext;
			if (e._updateNext) e._updateNext._updatePrev = e._updatePrev;
			if (e._renderNext) e._renderNext._renderPrev = e._renderPrev;
			if (e._updatePrev) e._updatePrev._updateNext = e._updateNext;
			if (e._renderPrev) e._renderPrev._renderNext = e._renderNext;
			
			// remove collidable type
			if (e._collisionType)
			{
				if (_collisionFirst[e._collisionType] == e) _collisionFirst[e._collisionType] = e._collisionNext;
				if (e._collisionNext) e._collisionNext._collisionPrev = e._collisionPrev;
				if (e._collisionPrev) e._collisionPrev._collisionNext = e._collisionNext;
			}
			
			// set information
			_entityNum --;
			e._added = false;
		}
		
		/// @info	Removes a Vector of Entities from the World.
		/// @param	v		The Vector of Entities to remove.
		public function removeVector(v:Vector.<Entity>):void
		{
			var i:int = v.length;
			while (i --) remove(v[i]);
		}
		
		/// @info	Removes all Entities in the World.
		public function removeAll():void
		{
			var e:Entity = _updateFirst;
			while (e)
			{
				// remove the enitity
				e._collisionPrev = e._collisionNext = null;
				e._added = false;
				e = e._updateNext;
			}
			_renderFirst = _updateFirst = null;
			_collisionFirst = [];
			_entityNum = 0;
			System.gc();
			System.gc();
		}
		
		/// @info	How many Entities are in this World.
		public function get count():int
		{
			return _entityNum;
		}
		
		/// @info	Returns the amount of Entities of a specific Class type in this World.
		/// @param	c		The Class type to count.
		public function countClass(c:Class):int
		{
			var e:Entity = _updateFirst,
				n:int = 0;
			while (e)
			{
				if (e is c) n ++;
				e = e._updateNext;
			}
			return n;
		}
		
		/// @info	Returns a Vector of all Entities of a specific Class type in this World.
		/// @param	c		The Class type to add to the Vector.
		public function getClass(c:Class):Vector.<Entity>
		{
			var e:Entity = _updateFirst,
				v:Vector.<Entity> = new Vector.<Entity>(),
				n:int = 0;
			while (e)
			{
				if (e is c) v[n ++] = e;
				e = e._updateNext;
			}
			return v;
		}
		
		/// @info	Performs a function for each Entity of the specific Class type in this World.
		/// @param	c			The Class type to search for.
		/// @param	perform		The function to perform, which has a single parameter e:Entity to which each Entity is passed.
		public function withClass(c:Class, perform:Function):void
		{
			var e:Entity = _updateFirst;
			while (e)
			{
				if (e is c) perform(e as c);
				e = e._updateNext;
			}
		}
		
		/// @info	The x-position of the mouse in the World (use FP.screen.mouseX to get the position on the Screen)
		public function get mouseX():int
		{
			return _stage.mouseX / FP.screen.scale + FP.camera.x;
		}
		
		/// @info	The y-position of the mouse in the World (use FP.screen.mouseY to get the position on the Screen)
		public function get mouseY():int
		{
			return _stage.mouseY / FP.screen.scale + FP.camera.y;
		}
		
		/// @info	Returns the first Entity colliding with the position in the World.
		/// @param	type	Only Entities of this search-type will be checked.
		/// @param	x		The x-position in the World.
		/// @param	y		The y-position in the World.
		public function collidePoint(type:String, x:int, y:int):Entity
		{
			var entity:Entity = _collisionFirst[type];
			while (entity)
			{
				if (entity.collidable
				&& x >= entity.x + entity._rectX
				&& y >= entity.y + entity._rectY
				&& x <= entity.x + entity._rectX + entity._rectW
				&& y <= entity.y + entity._rectY + entity._rectH)
				{
					if (!entity._mask) return entity;
					x -= entity.x + entity._rectX,
					y -= entity.y + entity._rectY;
					if (entity._rectP.getPixel32(x, y) > 0) return entity;
				}
				entity = entity._collisionNext;
			}
			return null;
		}
		
		/// @info	Returns the first Entity colliding with the rectangle region in the World.
		/// @param	type	Only Entities of this search-type will be checked.
		/// @param	x		The x-position of the rectangle in the World.
		/// @param	y		The y-position of the rectangle in the World.
		/// @param	w		The width of the rectangle.
		/// @param	h		The height of the rectangle.
		public function collideRect(type:String, x:int, y:int, w:int, h:int):Entity
		{
			var entity:Entity = _collisionFirst[type],
				mask:BitmapData;
			while (entity)
			{
				if (entity.collidable
				&& x + w > entity.x + entity._rectX
				&& y + h > entity.y + entity._rectY
				&& x < entity.x + entity._rectX + entity._rectW
				&& y < entity.y + entity._rectY + entity._rectH)
				{
					if (!entity._mask) return entity;
					if (!mask) mask = new BitmapData(w, h, false, 0xFF000000);
					_point.x = entity._rectX + (entity.x - x);
					_point.y = entity._rectY + (entity.y - y);
					if (mask.hitTest(_zero, 1, entity._rectP, _point, 1)) return entity;
				}
				entity = entity._collisionNext;
			}
			return null;
		}
		
		// updates the world and calls its update() function (so entities are updated before the world)
		internal final function updateF():void
		{
			if (!active) return;
			var e:Entity = _updateFirst;
			while (e)
			{
				if (e.active) e.update();
				if (e._alarmFirst) e._alarmFirst.update();
				e = e._updateNext;
			}
			if (_alarmFirst) _alarmFirst.update();
			update();
		}
		
		// renders the world and calls its render() function (so entities are updated before the world)
		internal final function renderF():void
		{
			FP.camera.x = int(FP.camera.x);
			FP.camera.y = int(FP.camera.y);
			if (!visible) return;
			var e:Entity = _renderFirst;
			while (e)
			{
				if (e.visible) e.render();
				e = e._renderNext;
			}
			render();
		}
		
		private var _point:Point = FP.point;
		private var _zero:Point = FP.zero;
		private var _rect:Rectangle = FP.rect;
		private var _matrix:Matrix = FP.matrix;
		private var _stage:Stage = FP.stage;
		
		internal var _entityNum:int;
		internal var _updateFirst:Entity;
		internal var _renderFirst:Entity;
		
		internal var _collisionFirst:Array = [];
	}
}