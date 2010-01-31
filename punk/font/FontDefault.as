package punk.font 
{
	import flash.display.Bitmap;
	import flash.geom.Point;
	import punk.core.PixelFont;
	
	/// @info	The default PixelFont, showing how to create a specific in-game font using an embedded Bitmap.
	public class FontDefault extends PixelFont
	{
		[Embed(source = 'default.png')] private const BmpDefault:Class;
		
		/// @info	Constructor. It's recommended that you create PixelFont objects with FP.setFont() rather creating them yourself.
		public function FontDefault() 
		{
			super(BmpDefault, 6, 12, " ", 1, 0, false, new Point(0, 0));
		}
	}
}