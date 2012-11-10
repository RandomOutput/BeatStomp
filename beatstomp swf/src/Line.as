package  
{
  import flash.display.Shape;
  import flash.geom.Point;
  public class Line 
  {   
    public var point:Vect2, normal:Vect2;
    public var other_point:Vect2;
    //private var distance:Number;
    
    public function Line(start:Vect2, end:Vect2) 
    {
      point = start.clone();
      other_point = end.clone();
      normal = start.subtract(end).perpendicular().normalize();
      //distance = normal.dot(point);
    }
    
    public function draw(shape:Shape, color:int):Shape
    {
      if(!shape) shape = new Shape();
      shape.graphics.lineStyle(2, color);
      shape.graphics.moveTo(other_point.x, other_point.y);
      shape.graphics.lineTo(point.x, point.y);
      var normal_point:Vect2 = point.add(normal.multiply(10));
      shape.graphics.lineTo(normal_point.x, normal_point.y);
      return shape;
    }
    
    /* Returns the "signed distance" from a point "center" to the line,
       first shifting the line by normal*size.

       This gives the effect of returning the signed distance from the line
       of an object located at center with dimensions of size*2 by size*2.
       The returned value will be positive if center is in front of the line,
       and negative if it is behind the line. */
    public function signedDistance(center:Vect2, size:Vect2=null):Number
    {
      if(size==null) size = new Vect2(0, 0);
      
      return normal.dot(center.subtract(
        new Vect2(point.x+normal.x*size.x, point.y+normal.y*size.y)));
    }
    
    public function distance(center:Vect2, size:Vect2=null):Number
    {
      return Math.abs(signedDistance(center, size));
    }
    
    public function intersection(start:Vect2, end:Vect2):Vect2
    {
      var start_distance:Number = signedDistance(start);
      var end_distance:Number = signedDistance(end);
      var abs_start_distance:Number = Math.abs(start_distance);
      var abs_end_distance:Number   = Math.abs(end_distance);
      
      // if points are on opposite sides of line
      if(Misc.sgn(start_distance) != Misc.sgn(end_distance))
        return start.add(end.subtract(start).multiply(
          abs_start_distance/(abs_start_distance-abs_end_distance)));
      
      var length:Number = start.distance(end);
      return start.add(end.subtract(start).normalize().multiply(
        length+abs_end_distance*length/(abs_start_distance-abs_end_distance)));
    }
  }
}
