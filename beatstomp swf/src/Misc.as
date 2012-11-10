package
{
  import flash.display.*;
  import flash.geom.*;
  import flash.events.*;

  public class Misc
  {
    public static const epsilon      :Number = 0.00001;
    
    public static function lineCircle(start:Vect2, end:Vect2, point:Vect2, radius:Number):Boolean
    {
      var d:Vect2 = end.subtract(start);
      var f:Vect2 = point.subtract(start);
      var a:Number = d.dot(d)
      var b:Number = 2*f.dot(d);
      var c:Number = f.dot(f)*radius*radius;
      var discriminant:Number = b*b-4*a*c;
      if(discriminant<0) return false;
      discriminant = Math.sqrt(discriminant);
      var t1:Number = (-b + discriminant)/(2*a);
      var t2:Number = (-b - discriminant)/(2*a);
      return t1 >= 0 && t1 <= 1;
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
    
    public static function transformFromColor(color:int):ColorTransform
    {
      return new ColorTransform(
        ((color >> 16) & 255) / 255.0,
        ((color >>  8) & 255) / 255.0,
        (color & 255) / 255.0); 
    }
    
    public static function colorFromTransform(ct:ColorTransform):int
    {
      return colorFromTriplet([ct.redMultiplier, ct.greenMultiplier, ct.blueMultiplier]);
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
    
    public static function offscreen(position:Vect2, radius:int=0):Boolean
    {
      return position.x<-radius || position.x >= Display.screen.width +radius || 
             position.y<-radius || position.y >= Display.screen.height+radius;
    }
  }
}
