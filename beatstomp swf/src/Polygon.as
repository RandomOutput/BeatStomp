package  
{
  import flash.display.Shape;
  import flash.geom.Rectangle;
  public class Polygon 
  {   
    private var vertices:Vector.<Vect2>;
    private var lines:Vector.<Line>;
    private var color:int;
    public var bounds:Rectangle; 
    
    public function Polygon(vertices_:Vector.<Vect2>) 
    {
      setVertices(vertices_);
      color = 0xff00ff;
    }
    
    public static function fromArray(array:Array):Polygon
    {
      var vertices:Vector.<Vect2> = new Vector.<Vect2>();
      for each(var v:Array in array) vertices.push(new Vect2(v[0], v[1]));
      return new Polygon(vertices);
    }
    
    public function setVertices(vertices_:Vector.<Vect2>):void
    {
      vertices = vertices_;
      lines = new Vector.<Line>();
      var axials:Array = [false, false, false, false];
      var top_left    :Vect2 = vertices[0].clone(),
          bottom_right:Vect2 = vertices[0].clone();
      
      // for each vertex
      for(var i:int=0; i<vertices.length; i++)
      {
        var v:Vect2 = vertices[i];
        
        // find bounding box of polygon
        if(v.x <     top_left.x) top_left.x = v.x;
        if(v.y <     top_left.y) top_left.y = v.y;
        if(v.x > bottom_right.x) bottom_right.x = v.x;
        if(v.y > bottom_right.y) bottom_right.y = v.y;
        
        // find lines that enclose polygon
        var line:Line = new Line(v, vertices[(i+1)%vertices.length]);
        lines.push(line);
        //line.point = line.point.add(line.normal.multiply(20));
        
        // find which axis-aligned lines already exist
        if(line.normal.x ==  1) axials[0] = true;
        if(line.normal.y ==  1) axials[1] = true;
        if(line.normal.x == -1) axials[2] = true;
        if(line.normal.y == -1) axials[3] = true;
      }
      
      // create axis-aligned lines which don't already exist.
      // we need these to flatten out the points in expanded polygons
      if(!axials[0]) 
        lines.push(new Line(    top_left,     top_left.add(new Vect2( 1,  0))));
      if(!axials[1])
        lines.push(new Line(bottom_right, bottom_right.add(new Vect2( 0,  1))));
      if(!axials[2])
        lines.push(new Line(bottom_right, bottom_right.add(new Vect2(-1,  0))));
      if(!axials[3])
        lines.push(new Line(    top_left,     top_left.add(new Vect2( 0, -1))));
      
      bounds = new Rectangle(top_left.x, top_left.y,
        bottom_right.x-top_left.x, bottom_right.y-top_left.y);
    }
    
    public function flipChirality():void
    {
      vertices.reverse();
      setVertices(vertices);
    }
    
    public function centroid():Vect2
    {
      var sum:Vect2 = new Vect2(0, 0);
      for each(var v:Vect2 in vertices)
        sum = sum.add(v);
      return sum.divide(sum.length());
    }
    
    public function draw(shape:Shape, color:int, alpha:Number=1):Shape
    {
      if(!shape) shape = new Shape();
      var first:Boolean = true;
      shape.graphics.beginFill(color, alpha);
      for each(var v:Vect2 in vertices)
      {
        if(first) shape.graphics.moveTo(v.x, v.y);
        else      shape.graphics.lineTo(v.x, v.y);
        first = false;
      }
      shape.graphics.endFill();
      for each(var line:Line in lines) line.draw(shape, color);
      return shape;
    }
    
    public function contains(center:Vect2, size:Vect2 = null):Boolean
    {
      if(size==null) size = new Vect2(0, 0);
      
      for each(var line:Line in lines)
        if(line.signedDistance(center, size) > 0.001) return false;
      return true;
    }
    
    /*If the object's path intersects the polygon, return array containing
    in element 0 the line the object crossed to enter it, and in element 1 the
    intersection point.
    
    If the object starts inside the polygon, return array with element 0 null,
    and in element 1 the object's starting point.
    
    If the object doesn't enter the polygon, return null.*/
    public function intersection(start:Vect2, motion:Vect2, size:Vect2=null)
      :Array
    {
      if(size==null) size = new Vect2(0, 0); 
      if(contains(start, size)) return [null, start];
      
      for each(var line:Line in lines)
      {
        var start_distance:Number = line.signedDistance(start, size);
        var end_distance:Number = line.signedDistance(start.add(motion), size);
        
        // if path of motion crosses this line from the outside to the inside
        if(start_distance > -0.001 && end_distance < 0.001 &&
           start_distance != end_distance)
        {
          var intersection:Vect2 = start.add(motion.
            divide(start_distance-end_distance).multiply(start_distance));
          // if intersection point is inside the polygon
          if(contains(intersection, size))
            return [line, intersection];
        }
      }
      
      if(contains(start.add(motion), size))
        for each(line in lines)
        {
          start_distance = line.signedDistance(start, size);
          end_distance = line.signedDistance(start.add(motion), size);
          
          // if path of motion crosses this line from the outside to the inside
          if(start_distance > -0.0001 && end_distance < 0.0001 &&
             start_distance != end_distance)
          {
            intersection = start.add(motion.
              divide(start_distance-end_distance).multiply(start_distance));
            // if intersection point is inside the polygon
            if(contains(intersection, size))
              return [line, intersection];
          }
        }
      return null;
    }    
  }
}
