package punk 
{
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import punk.core.Entity;
	
	/// @info	A game Entity designed for displaying a bitmap which tile images can be added to.
	public class TileMap extends Entity
	{
		/// @info	[READ ONLY] The BitmapData of this TileSet.
		public function get bitmapData():BitmapData
		{
			return _data;
		}
		/// @info	The size of the TileMap in pixels.
		public var width:int;
		public var height:int;
		
		/// @info	Constructor. Creates a blank TileMap.
		/// @param	width		The width in pixels.
		/// @param	height		The height in pixels.
		public function TileMap(width:int, height:int) 
		{
			this.width = width;
			this.height = height;
			_data = new BitmapData(width, height, true, 0);
			_dataRect = _data.rect;
		}
		
		/// @info	Adds a tile to the TileMap.
		/// @param	bitmap		An embedded Bitmap class to get the tile image from.
		///	@param	rect		A rectangle representing the tile in bitmap.
		/// @param	x			The x-position to place the tile in the TileMap.
		/// @param	y			The y-position to place the tile in the TileMap.
		public function add(bitmap:Class, rect:Rectangle, x:int, y:int):void
		{
			_point.x = x;
			_point.y = y;
			_data.copyPixels(FP.getBitmapData(bitmap), rect, _point);
		}
		
		/// @info	Loads tiles from a string.
		/// @param	bitmap			An embedded Bitmap class to get the tile images from.
		/// @param	tileWidth		The width of each tile in the bitmap.
		/// @param	tileHeight		The height of each tile in the bitmap.
		/// @param	str				A string representing the tilemap. For example, "1,2,0,2\n3,3,1,2" for a 2-row tileset.
		/// @param	columnSep		A char or string separating each tile on a row.
		/// @param	rowSet			A char or string marking the next row of tiles.
		public function loadFromString(bitmap:Class, tileWidth:int, tileHeight:int, str:String, columnSep:String = ",", rowSep:String = "\n"):void
		{
			_rect.width = tileWidth;
			_rect.height = tileHeight;
			var data:BitmapData = FP.getBitmapData(bitmap),
				row:Array = str.split(rowSep),
				rows:int = row.length,
				col:Array,
				cols:int,
				r:int = 0,
				c:int,
				tile:int,
				w:int = data.width,
				ww:int = w / tileWidth;
			_point.y = 0;
			while (r < rows)
			{
				col = row[r].split(columnSep);
				cols = col.length;
				c = _point.x = 0;
				while (c < cols)
				{
					tile = int(col[c]) - 1;
					if (tile >= 0)
					{
						_rect.x = (tile * tileWidth) % w;
						_rect.y = int(tile / ww) * tileHeight;
						_data.copyPixels(data, _rect, _point);
					}
					_point.x += tileWidth;
					c ++;
				}
				_point.y += tileHeight;
				_point.x = 0;
				r ++;
			}
		}
		
		/// @info	Clears the entire TileMap.
		/// @param	color		The color to clear the TileMap as, 0 is completely transparent.
		public function clear(color:uint = 0):void
		{
			_data.fillRect(_dataRect, color);
		}
		
		/// @info	Clears the rectangle on the Tilemap.
		/// @param	color		The color to clear the TileMap as, 0 is completely transparent.
		
		override public function render():void
		{
			_point.x = x - FP.camera.x;
			_point.y = y - FP.camera.y;
			FP.screen.copyPixels(_data, _dataRect, _point);
		}
		
		private var _data:BitmapData;
		private var _dataRect:Rectangle;
		private var _point:Point = FP.point;
		private var _rect:Rectangle = FP.rect;
	}
}