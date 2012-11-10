package
{
  import flash.display.*;
  import flash.geom.*;
  import flash.events.*;

  public class Misc
  {
    public static const epsilon      :Number = 0.00001;
    public static var   point_zero   :Point  = new Point(0, 0);

    static public var recently_exhausted:Object = {};
    static public function randOfExhausted(name:String, fraction:Number,
      of:Array):Object
    {
      var recent:Array = recently_exhausted[name];
      if(!recent) recent = [];
      
      var choice:Object;
      do
      {
        choice = Input.randOf(of);
        var exists:Boolean = false;
        for each(var o:Object in recent) if(o == choice) exists = true;
      } while(exists);
      
      recent.push(choice);
      if(recent.length > of.length*fraction) recent.shift();
      
      recently_exhausted[name] = recent;
      return choice;
    }
    
    public static var quality_stack:Array = [];
    
    public static function pushQuality(s:String):void
    {
      quality_stack.push(Display.stage.quality);
      Display.stage.quality = s;
    }
    
    static public function popQuality():void
    {
      Display.stage.quality = quality_stack.pop();
    }
    
    public static function commafy(n:int):String
    {
      var s:String = "";
      var neg:Boolean = false;
      if(n < 0) neg = true, n = -n;
      
      while(n >= 1000)
      {
        var chunk:String = String(n%1000);
        while(chunk.length<3) chunk = "0"+chunk;
        s = "," + chunk + s;
        n /= 1000;
      }
      s = n+s;
      return (neg?"-":"") + s;
    }
    
    public static function near(a:Number, b:Number):Boolean
    {
      return Math.abs(a-b) < epsilon;
    }

    public static function sgn(n:Number):Number
    {
      if(n<0) return -1;
      if(n>0) return  1;
      return 0;
    }
    
    public static function colorFromTransform(c:ColorTransform):int
    {
      return colorFromTriplet([c.redMultiplier, c.greenMultiplier, c.blueMultiplier]);
    }
    
    public static function colorFromTriplet(a:Array):int
    {
      return ((a[0]*255)<<16) + ((a[1]*255)<<8) + a[2]*255;
    }
    
    public static function vectFromAngle(a:Number):Vect2
    {
      return new Vect2(Math.cos(a), Math.sin(a));
    }
    
    public static function clone(object:Object):Object
    {
      if(object is Array)
      {
        var a:Array = [];
        for each(var item:Object in object) a.push(item);
        return a;
      }
      var o:Object = {};
      for(var attr:String in object) o[attr] = object[attr];
      return o;
    }
    
    public static function bevelFill(bitmap:Bitmap):void
    {
      var rect:Rectangle = bitmap.bitmapData.rect;
      bitmap.bitmapData.fillRect(rect, 0xff8f8f8f);
      rect.top  += 2;
      rect.left += 2;
      bitmap.bitmapData.fillRect(rect, 0xff2f2f2f);
      rect.bottom -= 2;
      rect.right  -= 2;
      bitmap.bitmapData.fillRect(rect, 0xff5f5f5f);
    }
    
    public static function offscreen(position:Vect2, radius:int=0):Boolean
    {
      return position.x < -radius || position.x >= Display.screen_size.x+radius || 
             position.y < -radius || position.y >= Display.screen_size.y+radius;
    }
  }
}
