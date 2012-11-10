package
{
  import flash.display.*;
  import flash.geom.*;

  public class Spriteset
  {
    public var frame_count:int;
    private var transformed_sets:Object = { n: 0 };

    public function Spriteset(source:Bitmap, frame_width:int)
    {
      var width:int = frame_width, height:int=source.bitmapData.height;
      
      // create the non-transformed set of sprites
      var null_key:Array = transformKey();
      transformed_sets[null_key] = [];
      
      // break up the sheet into individual sprites
      for(var i:int = 0; i<source.width; i+=frame_width)
      {
        var b:Bitmap = new Bitmap(new BitmapData(width, height, true, 0));
        b.bitmapData.copyPixels(source.bitmapData,
          new Rectangle(i, 0, width, height), new Point(0, 0));
        transformed_sets[null_key].push(b);
      }
      
      frame_count = transformed_sets[null_key].length;
    }
    
    // construct a Spriteset from a MovieClip
    static public function fromMovieClip(source:MovieClip, scale:Number=1)
      :Spriteset
    {
      // figure out the bounds we need to contain the entire clip
      var bounds:Rectangle = new Rectangle();
      for(var i:int=0; i<source.totalFrames; i++)
      {
        source.gotoAndStop(i);
        var rect:Rectangle = source.getBounds(Display.screen);
        if(rect.left   < bounds.left  ) bounds.left   = rect.left;
        if(rect.top    < bounds.top   ) bounds.top    = rect.top;
        if(rect.right  > bounds.right ) bounds.right  = rect.right;
        if(rect.bottom > bounds.bottom) bounds.bottom = rect.bottom;
      }
            
      var offset_x:int = -bounds.left   * scale;
      var offset_y:int = -bounds.top    * scale;
      var   size_x:int =  bounds.width  * scale;
      var   size_y:int =  bounds.height * scale;

      // render every frame in sequence to a bitmap
      var bitmap:Image = Image.blank(source.totalFrames*size_x, size_y);
      for(i=0; i<source.totalFrames; i++)
      {
        source.gotoAndStop(i);
        var matrix:Matrix = new Matrix(scale, 0, 0, scale, offset_x, offset_y);
        matrix.translate(i*size_x, 0);
        Misc.pushQuality(StageQuality.BEST);
        bitmap.bitmapData.draw(source, matrix);
        Misc.popQuality();
      }
      
      return new Spriteset(bitmap, size_x);
    }
    
    // accessor to retrieve a non-transformed frame for direct use
    public function frame(n:int):Bitmap
    {
      return transformed_sets[transformKey()][n];
    }
    
    /* Render into the destination bitmap using BitmapData.copyPixels().
       Build a transform set if none exists. */
    public function blit(dest:Bitmap, x:int, y:int, frame:int=0,
       h_flip:Boolean=false, v_flip:Boolean=false, rotate:int=0,
       scale:Number=1, color:ColorTransform=null):void
    {
      var key:Array = transformKey(h_flip, v_flip, rotate, scale, color);
      
      if(!transformed_sets[key])
      {
        //trace(++transformed_sets.n);
        buildTransformSet(key);
      }
      
      var bitmap:BitmapData = transformed_sets[key][frame].bitmapData;
      dest.bitmapData.copyPixels(bitmap, bitmap.rect,
        new Point(x-bitmap.width/2, y-bitmap.height/2), null, null, true);
    }
    
    /* Render into the destination using a one-off free-form transfrom;
       don't cache anything. */
    public function draw(dest:Bitmap, x:Number, y:Number, frame:int=0,
      scale_x:Number=1, scale_y:Number=1, angle:Number=0,
      color:ColorTransform=null, smoothing:Boolean=false):void
    {
      // get the frame out of the non-transformed set
      var bitmap:BitmapData = transformed_sets[transformKey()][frame].bitmapData;
      // build the transformation matrix with respect to the center of the image
      var m:Matrix = new Matrix();
      m.translate(-bitmap.width/2, -bitmap.height/2);
      m.scale(scale_x, scale_y);
      m.rotate(angle);
      m.translate(x, y);
      
      dest.bitmapData.draw(bitmap, m, color, null, null, smoothing);
    }
    
    private function transformKey(h_flip:Boolean=false, v_flip:Boolean=false,
      rotate:int=0, scale:Number=1, color:ColorTransform=null):Array
    {
      return [h_flip, v_flip, rotate%4, color, scale];
    }
    
    private function buildTransformSet(key:Array):void
    {
      transformed_sets[key] = [];
      var bitmap:Bitmap = transformed_sets[transformKey()][0];
      if(key[2]%2==0) var width:Number=bitmap.width, height:Number=bitmap.height;
      else width=bitmap.height, height=bitmap.width;
      
      width *= key[4], height *= key[4];
      
      for(var i:int=0; i<frame_count; i++)
      {
        var new_sprite:Bitmap =
          new Bitmap(new BitmapData(width, height, true, 0));
        draw(new_sprite, width/2, height/2, i, key[0]?-key[4]:key[4],
          key[1]?-key[4]:key[4], key[2]*Math.PI/2, key[3]);
        transformed_sets[key].push(new_sprite);
      }
      //trace(key[0]?-key[4]:key[4], key[1]?-key[4]:key[4]);
    }
  }
}
