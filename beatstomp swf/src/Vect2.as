package  
{
  import flash.geom.Point;
  public class Vect2
  {
    public var x:Number, y:Number;
    
    public function Vect2(_x:Number, _y:Number) 
    {
      x = _x, y = _y;
    }
    
    public function clone():Vect2 { return new Vect2(x, y); }
    public function point():Point { return new Point(x, y); }
    
    public function perpendicular():Vect2
    {
      return new Vect2(-y, x);
    }

    public function offscreen(p:Vect2):Boolean
    {
      return x < 0 || y < 0 || x > Display.screen.width ||
        y > Display.screen.height;
    }

    public function dot(b:Vect2):Number
    {
      return x*b.x + y*b.y;
    }
    
    public function add(b:Vect2):Vect2
    {
      return new Vect2(x+b.x, y+b.y);
    }

    public function subtract(b:Vect2):Vect2
    {
      return new Vect2(x-b.x, y-b.y);
    }

    public function multiply(b:Number):Vect2
    {
      return new Vect2(x*b, y*b);
    }

    public function divide(b:Number):Vect2
    {
      return new Vect2(x/b, y/b);
    }
    
    public function angle():Number
    {
      return Math.atan2(x, y);
    }
    
    public function normalize(new_length:Number=1):Vect2
    {
      return multiply(new_length/length());
    }

    public function length():Number
    {
      return Math.sqrt(lengthSquared());
    }
    
    public function lengthSquared():Number
    {
      return distanceSquared(new Vect2(0, 0));
    }
    
    public function distanceSquared(b:Vect2):Number
    {
      return (x-b.x)*(x-b.x) + (y-b.y)*(y-b.y);
    }

    public function distance(b:Vect2):Number
    {
      return Math.sqrt(distanceSquared(b));
    }
  }
}