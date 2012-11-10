package  
{
  import flash.display.*;
  import flash.filters.BitmapFilter;
  import flash.geom.Point;
  import Vect2;
  
  public class Image extends Bitmap
  {
    public function Image(bitmapdata:BitmapData)
    {
      super(bitmapdata);
    }
    
    static public function blank(width:int, height:int):Image
    {
      return new Image(new BitmapData(width, height, true, 0));
    }
    
    public function clear(color:int=0):void
    {
      bitmapData.fillRect(bitmapData.rect, color);
    }
    
    public function filter(f:BitmapFilter):void
    {
      bitmapData.applyFilter(bitmapData, bitmapData.rect, new Point(0, 0), f);
    }
    
    public function blit(destination:Bitmap, where:Vect2=null):void
    {
      if(where == null) where = new Vect2(0, 0);
      destination.bitmapData.copyPixels(bitmapData, bitmapData.rect,
        where.point(), null, null, true);
    }
  }
}