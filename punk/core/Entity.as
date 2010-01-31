package punk.core
{
	import flash.display.BitmapData;
	import flash.geom.*;
	import punk.util.*;
	import punk.*;
	
	/// @info	Basic game object which can be added to Worlds. They have an x/y position and functions for collision.
	public class Entity extends Core
	{	
		/// @info	The Entity's x-position in the World.
		public var x:Number = 0;
		/// @info	The Entity's y-position in the World.
		public var y:Number = 0;
		/// @info	If this Entity should respond to collision checks.
		public var collidable:Boolean = true;
		/// @info	The Entity's drawing depth (those with higher depth are rendered first). Treat this function as a property.
		public function get depth():int
		{
			return ~_depth + 1;
		}
		public function set depth(value:int):void
		{
			value = ~value + 1;
			if (_added && value != _depth)
			{
				var entity:Entity;
				if (value > _depth)
				{
					if (_renderNext && _renderNext._depth < value)
					{
						entity = _renderNext;
						while (entity._renderNext && entity._renderNext._depth < value) entity = entity._renderNext;
						// switch this one out
						if (_renderPrev) _renderPrev._renderNext = _renderNext;
						else FP.world._renderFirst = _renderNext;
						_renderNext._renderPrev = _renderPrev;
						// insert this one in after entity
						_renderNext = entity._renderNext;
						_renderPrev = entity;
						entity._renderNext = this;
						if (_renderNext) _renderNext._renderPrev = this;
					}
				}
				else
				{
					if (_renderPrev && _renderPrev._depth > value)
					{
						entity = _renderPrev;
						while (entity._renderPrev && entity._renderPrev._depth > value) entity = entity._renderPrev;
						// switch this one out
						_renderPrev._renderNext = _renderNext;
						if (_renderNext) _renderNext._renderPrev = _renderPrev;
						// insert this one in before entity
						_renderPrev = entity._renderPrev;
						_renderNext = entity;
						entity._renderPrev = this;
						if (_renderPrev) _renderPrev._renderNext = this;
						else FP.world._renderFirst = this;
					}
				}
			}
			_depth = value;
		}
		
		/// @info	Constructor.
		public function Entity() 
		{
			
		}
		
		/// @info	Enables the Entity, making it visible, active, and collidable.
		public function enable():void
		{
			active = visible = collidable = true;
		}
		
		/// @info	Disables the Entity, making it inisible, inactive, and non-collidable.
		public function disable():void
		{
			active = visible = collidable = false;
		}
		
		/// @info	Returns the first Entity that intersects this Entity when this Entity is at the specified position.
		/// @param	type	Only Entities of this search-type will be checked.
		/// @param	x		The x-position at which to emulate the collision.
		/// @param	y		The y-position at which to emulate the collision.
		public function collide(type:String, x:int, y:int):Entity
		{
			if (!_added) return null;
			var entity:Entity = FP.world._collisionFirst[type];
			while (entity)
			{
				if (entity.collidable && entity !== this
				&& x + _rectX + _rectW > entity.x + entity._rectX
				&& y + _rectY + _rectH > entity.y + entity._rectY
				&& x + _rectX < entity.x + entity._rectX + entity._rectW
				&& y + _rectY < entity.y + entity._rectY + entity._rectH)
				{
					if (!_mask && !entity._mask) return entity;
					_point.x = _rectX;
					_point.y = _rectY;
					_point2.x = entity._rectX + (entity.x - x);
					_point2.y = entity._rectY + (entity.y - y);
					if (_rectP.hitTest(_point, 1, entity._rectP, _point2, 1)) return entity;
				}
				entity = entity._collisionNext;
			}
			return null;
		}
		
		/// @info	Performs a function for each Entity that intersects this one when this one is at the specified position.
		/// @param	type		Only Entities of this search-type will be checked.
		/// @param	x			The x-position at which to emulate the collision.
		/// @param	y			The y-position at which to emulate the collision.
		/// @param	perform		Function to perform for each interection. The function must have a single e:Entity parameter to which each intersecting Entity will be passed.
		public function collideEach(type:String, x:int, y:int, perform:Function):void
		{
			if (!_added) return;
			var entity:Entity = FP.world._collisionFirst[type];
			while (entity)
			{
				if (entity.collidable && entity != this
				&& x + _rectX + _rectW > entity.x + entity._rectX
				&& y + _rectY + _rectH > entity.y + entity._rectY
				&& x + _rectX < entity.x + entity._rectX + entity._rectW
				&& y + _rectY < entity.y + entity._rectY + entity._rectH)
				{
					if (_mask || entity._mask)
					{
						_point.x = _rectX;
						_point.y = _rectY;
						_point2.x = entity._rectX + (entity.x - x);
						_point2.y = entity._rectY + (entity.y - y);
						if (_rectP.hitTest(_point, 1, entity._rectP, _point2, 1)) perform(entity);
					}
					else perform(entity);
				}
				entity = entity._collisionNext;
			}
		}
		
		/// @info	Returns whether the Entity intersects this one when this one is placed at the position.
		/// @param	entity	The Entity to check for intersection with.
		/// @param	x		The x-position at which to emulate the collision.
		/// @param	y		The y-position at which to emulate the collision.
		public function collideWith(entity:Entity, x:int, y:int):Boolean
		{
			if (!_added) return false;
			if (entity.collidable && entity !== this
			&& x + _rectX + _rectW > entity.x + entity._rectX
			&& y + _rectY + _rectH > entity.y + entity._rectY
			&& x + _rectX < entity.x + entity._rectX + entity._rectW
			&& y + _rectY < entity.y + entity._rectY + entity._rectH)
			{
				if (!_mask && !entity._mask) return true;
				_point.x = _rectX;
				_point.y = _rectY;
				_point2.x = entity._rectX + (entity.x - x);
				_point2.y = entity._rectY + (entity.y - y);
				return (_rectP.hitTest(_point, 1, entity._rectP, _point2, 1));
			}
			return false;
		}
		
		/// @info	Returns whether this Entity collides with a filled cell of the Grid.
		/// @param	grid		The Grid object to test against.
		/// @param	x			The x-position at which to emulate the collision.
		/// @param	y			The y-position at which to emulate the collision.
		public function collideGrid(grid:Grid, x:int, y:int):Boolean
		{
			x += _rectX;
			y += _rectY;
			var x2:int = (x + _rectW - 1) / grid._cellWidth,
				y2:int = (y + _rectH - 1) / grid._cellHeight,
				x1:int = x = x / grid._cellWidth,
				y1:int = y / grid._cellHeight;
			while (y1 <= y2)
			{
				while (x1 <= x2)
				{
					if (grid._data.getPixel(x1, y1)) return true;
					x1 ++;
				}
				y1 ++;
				x1 = x;
			}
			return false;
		}
		
		/// @info	Sets the rectangular collision area for this Entity.
		/// @param	width		The width of the rectangle.
		/// @param	height		The height of the rectangle.
		/// @param	xoffset		The offset of the rectangle from this Entity's x-position.
		/// @param	yoffset		The offset of the rectangle from this Entity's y-position.
		public function setCollisionRect(width:int, height:int, xoffset:int = 0, yoffset:int = 0):void
		{
			_rectW = width;
			_rectH = height;
			_rectX = xoffset;
			_rectY = yoffset;
			_rectP = new BitmapData(width, height, false, 0xFF000000);
			_mask = false;
		}
		
		/// @info	Sets a bitmap mask to use for collisions, so intersection between non-transparent pixels will be checked intead.
		/// @param	The offset of the mask from this Entity's x-position.
		/// @param	The offset of the mask from this Entity's y-position.
		public function setCollisionMask(mask:BitmapData, xoffset:int = 0, yoffset:int = 0):void
		{
			_rectX = xoffset;
			_rectY = yoffset;
			_rectW = mask.width;
			_rectH = mask.height;
			_rectP = mask;
			_mask = true;
		}
		
		/// @info	Sets the search-type, so this Entity will be checked when other Entities collide with this search-type.
		/// @param	The string search-type. For example: "enemy", "wall", etc.)
		public function setCollisionType(type:String):void
		{
			if (!_added)
			{
				_collisionType = type;
				return;
			}
			
			// remove it from its current type
			if (_collisionType && FP.world._collisionFirst[_collisionType])
			{
				if (FP.world._collisionFirst[_collisionType] == this) FP.world._collisionFirst[_collisionType] = _collisionNext;
				if (_collisionNext) _collisionNext._collisionPrev = _collisionPrev;
				if (_collisionPrev) _collisionPrev._collisionNext = _collisionNext;
			}
			
			_collisionType = type;
			if (!type) return;
			
			// insert it in as a new type
			if (FP.world._collisionFirst[type])
			{
				_collisionNext = FP.world._collisionFirst[type];
				_collisionNext._collisionPrev = this;
			}
			else _collisionNext = null;
			_collisionPrev = null;
			FP.world._collisionFirst[type] = this;
		}
		
		private var _point:Point = FP.point;
		private var _point2:Point = FP.point2;
		
		internal var _added:Boolean;
		internal var _depth:int = 0;
		
		internal var _updateNext:Entity;
		internal var _updatePrev:Entity;
		internal var _renderNext:Entity;
		internal var _renderPrev:Entity;
		
		internal var _collisionType:String;
		internal var _collisionNext:Entity;
		internal var _collisionPrev:Entity;
		
		internal var _rectX:int = 0;
		internal var _rectY:int = 0;
		internal var _rectW:int = 0;
		internal var _rectH:int = 0;
		internal var _rectP:BitmapData = null;
		
		internal var _mask:Boolean = false;
	}
}