package punk.core 
{
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.utils.getTimer;
	import punk.TileMap;
	
	/// @info	A set of fixed-size cells which can be either empty or filled.
	public class Grid
	{
		/// @info	Constructor.
		/// @param	cellWidth		The width of each cell in the grid.
		/// @param	cellHeight		The height of each cell in the grid.
		/// @param	columns			The width (in cells) of the grid.
		/// @param	rows			The height (in cells) of the grid.
		public function Grid(cellWidth:int, cellHeight:int, columns:int = 0, rows:int = 0) 
		{
			_data = new BitmapData(columns, rows, true, 0);
			_width = columns;
			_height = rows;
			_cellWidth = cellWidth;
			_cellHeight = cellHeight;
			
			/* UNCOMMENT THIS FOR DEBUGGING */
			//var b:Bitmap = new Bitmap(_data);
			//b.scaleX = cellWidth * FP.screen.scale;
			//b.scaleY = cellHeight * FP.screen.scale;
			//FP.stage.addChild(b);
		}
		
		/// @info	Fills a particular cell.
		/// @param	col		The horizontal cell to fill (starting at 0).
		/// @param	row		The vertical cell to fill (starting at 0).
		/// @param	fill	Optionally set this to false to empty the cell.
		public function setCell(col:int, row:int, fill:Boolean = true):void
		{
			_data.setPixel32(col, row, fill ? 0xFFFFFFFF : 0);
		}
		
		/// @info	Fills the rectangle of cells.
		/// @param	col		The leftmost cell of the rectangle.
		/// @param	row		The topmost cell of the rectangle.
		/// @param	width	The horizontal amount of cells to fill.
		/// @param	height	The vertical amount of cells to fill.
		/// @param	fill	Optionally set this to false to empty the rectangle.
		public function setRect(col:int, row:int, width:int = 1, height:int = 1, fill:Boolean = true):void
		{
			_rect.x = col;
			_rect.y = row;
			_rect.width = width;
			_rect.height = height;
			_data.fillRect(_rect, fill ? 0xFFFFFFFF : 0);
		}
		
		public function clear():void
		{
			_data.fillRect(_data.rect, 0);
		}
		
		public function loadFromString(str:String, columnSep:String = ",", rowSep:String = "\n"):void
		{
			var row:Array = str.split(rowSep),
				rows:int = row.length,
				col:Array,
				cols:int,
				r:int = 0,
				c:int;
			while (r < rows)
			{
				col = row[r].split(columnSep);
				cols = col.length;
				c = 0;
				while (c < cols)
				{
					_data.setPixel32(c, r, int(col[c]) ? 0xFFFFFFFF : 0);
					c ++;
				}
				r ++;
			}
		}
		
		/// @info	Returns whether the position intersects with a filled cell.
		/// @param	x		The x-position to check.
		/// @param	y		The y-position to check.
		public function collidePoint(x:int, y:int):Boolean
		{
			return _data.getPixel(x / _cellWidth, y / _cellHeight) > 0;
		}
		
		/// @info	Returns whether the rectangle intersects with a filled cell.
		/// @param	x		The x-position of the rectangle.
		/// @param	y		The y-position of the rectangle.
		/// @param	w		The width of the rectangle.
		/// @param	h		The height of the rectangle.
		public function collideRect(x:int, y:int, w:int, h:int):Boolean
		{
			var x2:int = (x + w - 1) / _cellWidth,
				y2:int = (y + h - 1) / _cellHeight,
				x1:int = x = x / _cellWidth,
				y1:int = y / _cellHeight;
			while (y1 <= y2)
			{
				while (x1 <= x2)
				{
					if (_data.getPixel(x1, y1)) return true;
					x1 ++;
				}
				y1 ++;
				x1 = x;
			}
			return false;
		}
		
		private var _rect:Rectangle = FP.rect;
		private var _zero:Point = FP.zero;
		private var _point:Point = FP.point;
		private var _width:int;
		private var _height:int;
		
		internal var _data:BitmapData;
		internal var _cellWidth:int;
		internal var _cellHeight:int;
	}
}