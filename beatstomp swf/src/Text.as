package
{
  import flash.display.*;
  import flash.filters.BitmapFilter;
  import flash.geom.*;
  import flash.utils.Dictionary;

  public class Text
  {
    [Embed(source = "preloader/profont.png")] static private var Font:Class;
    static private var font:Bitmap = new Font();
    static private var scaled_fonts:Dictionary = new Dictionary();
    
    static public const ALIGN_LEFT:int = 1, ALIGN_RIGHT:int = 2,
                        ALIGN_CENTER:int = 3;
   
    static public function wrap(s:String, max_width:int):String
    {
      if(s.indexOf("\n")!=-1) return s;
      var output:String = "";
      var position:int = 0;
      var space:int;
      var current_width:int = 0;
      
      while(position < s.length)
      {
        space = s.indexOf(" ", position);
        if(space == -1) space = s.length;
        if(current_width + (space-position) > max_width)
        {
          output += "\n";
          current_width = 0;
        }
        output += s.substr(position, space-position) + " ";
        current_width += space+1-position;
        position = space+1;
      }
      
      return output;
    }
    
    static public function size(text:String):Vect2
    {
      var width:int=0, height:int=0;
      for each(var line:String in text.split("\n"))
      {
        height++;
        if(line.length > width) width = line.length;
      }
      return new Vect2(width*6, height*(font.height-1)+1);
    }
    
    static public function render(text:String, scale:int=2):Bitmap
    {
      var size:Vect2 = size(text);
      var bitmap:Bitmap = new Bitmap(
        new BitmapData(size.x*scale, size.y*scale, true, 0));
      renderTo(bitmap, text, 0, 0, scale);
      return bitmap;
    }

    static public function renderTo(dest:Bitmap, text:String, x:int=0, y:int=0,
      scale:int=2, align:int=ALIGN_LEFT):void
    {
      if(scale==1) var scaled_font:Bitmap = font;
      else scaled_font = scaled_fonts[scale];
      
      if(scaled_font == null)
      {
        scaled_font = new Bitmap(new BitmapData(font.width*scale,
                                                font.height*scale, true, 0));
        var matrix:Matrix = new Matrix(scale, 0, 0, scale, 0, 0);
        scaled_font.bitmapData.draw(font, matrix);
        scaled_fonts[scale] = scaled_font;
      }
      
      if(align == ALIGN_RIGHT ) x -= 6*scale*text.length;
      if(align == ALIGN_CENTER) x -= 3*scale*text.length;      
      
      var point:Point = new Point(x, y);
      var rect :Rectangle = new Rectangle(0, 0, 6*scale, scaled_font.height);
      var lines:int = 1;
      
      for(var i:int = 0; i<text.length; i++)
      {
        if(text.substr(i, 1) == "\n")
        {
          point.x = x;
          point.y += scaled_font.height-scale;
          lines++;
          continue;
        }
        var charcode:int = text.charCodeAt(i);
        if(text.substr(i, 1) == "~")
          charcode = text.charCodeAt(++i)- 96+126;
        rect.x = (charcode-33)*6*scale;
        dest.bitmapData.copyPixels(scaled_font.bitmapData,
          rect, point, null, null, true);
        point.x += 6*scale;
      }
    }
  }
}
