package  
{
  import entity.*;
  import flash.geom.*;
  
  public class CollideMesh
  {
    public var mesh:Array = null;
    
    private const polygons:Array =
    [
      [],                                 // 0000
      [[1, 0], [1, 1], [0, 1]],           // 0001
      null,                               // 0010
      [[-1, 0], [1, 0], [1, 1], [-1, 1]], // 0011
      null,                               // 0100
      null,                               // 0101
      null,                               // 0110
      [[-1, 0], [0, -1], [1, -1], [1, 1], [-1, 1]],         // 0111
      null, // 1000
      [[-1, -1], [0, -1], [1, 0], [1, 1], [0, 1], [-1, 0]], // 1001
      null, // 1010
      null, // 1011
      null, // 1100
      null, // 1101
      null, // 1110
      [[-1, -1], [1, -1], [1, 1], [-1, 1]] // 1111
    ];
    
    public function CollideMesh(image:Image, grid_size:int) 
    {
      createSymmetricPolygons();
      mesh = geometryFromImage(image, grid_size);
    }
    
    private function createSymmetricPolygons():void
    {
      polygons[2]  = rotate(polygons[1 ]);
      polygons[8]  = rotate(polygons[2 ]);
      polygons[4]  = rotate(polygons[8 ]);
      
      polygons[10] = rotate(polygons[3 ]);
      polygons[12] = rotate(polygons[10]);
      polygons[5]  = rotate(polygons[12]);
      
      polygons[6]  = rotate(polygons[9 ]);
      
      polygons[11] = rotate(polygons[7 ]);
      polygons[14] = rotate(polygons[11]);
      polygons[13] = rotate(polygons[14]);
    }
    
    private function solid(data:Image, x:int, y:int):Boolean
    {
      if(x<0) x = 0;
      if(y<0) y = 0;
      if(x>=data.bitmapData.rect.right ) x = data.bitmapData.rect.right -1;
      if(y>=data.bitmapData.rect.bottom) y = data.bitmapData.rect.bottom-1;
      return (data.bitmapData.getPixel32(x, y) & 0xff000000) != 0;
    }
      
    private function formFit(polygon:Array, grid_size:Number, source:Image):Array
    {
      //return polygon;
      var output:Array = [];
      var min:Number, max:Number, ave:Number;
      var min_on:Boolean, max_on:Boolean, ave_on:Boolean;
      
      for each(var point:Array in polygon)
      {
        var new_point:Array = Misc.clone(point) as Array;
        //trace(new_point);
        if(new_point[0] == int(new_point[0]))
        {
          min = new_point[0]-0.5;
          max = new_point[0]+0.5;
          do
          {
            ave = (min+max)/2;
            min_on = solid(source, min*grid_size, new_point[1]*grid_size);
            max_on = solid(source, max*grid_size, new_point[1]*grid_size);
            ave_on = solid(source, ave*grid_size, new_point[1]*grid_size);
            if(min_on == max_on)
              trace(min*grid_size, max*grid_size, new_point[1]*grid_size);
            if     (min_on == ave_on) min = ave;
            else if(max_on == ave_on) max = ave;            
          } while(Math.abs(min-max) > 1.0/grid_size);
          new_point[0] = (min+max)/2;
        }
        else if(new_point[1] == int(new_point[1]))
        {
          min = new_point[1]-0.5;
          max = new_point[1]+0.5;
          do
          {
            ave = (min+max)/2;
            min_on = solid(source, new_point[0]*grid_size, min*grid_size);
            max_on = solid(source, new_point[0]*grid_size, max*grid_size);
            ave_on = solid(source, new_point[0]*grid_size, ave*grid_size);
            if(min_on == max_on)
              trace(min*grid_size, max*grid_size, new_point[0]*grid_size);
            if     (min_on == ave_on) min = ave;
            else if(max_on == ave_on) max = ave;            
          } while(Math.abs(min-max) > 1.0/grid_size);
          new_point[1] = (min+max)/2;
        }
        output.push(new_point);
      }
      return output;
    }
    
    private function scale(polygon:Array, scale:Number):Array
    {
      var output:Array = [];
      for each(var point:Array in polygon)
        output.push([point[0]*scale, point[1]*scale]);
      return output;
    }
    
    private function translate(polygon:Array, x:Number, y:Number):Array
    {
      var output:Array = [];
      for each(var point:Array in polygon)
        output.push([point[0]/2+x, point[1]/2+y]);
      return output;
    }
    
    private function rotate(polygon:Array):Array
    {
      var output:Array = [];
      for each(var point:Array in polygon)
        output.push([-point[1], point[0]]);
      return output;
    }
    
    private function geometryFromImage(source:Image, grid_size:int=32):Array
    {
      var output:Array = [];
      
      for  (var x:Number = -1; x<=Display.screen_size.x/grid_size+1; x++)
        for(var y:Number = -1; y<=Display.screen_size.y/grid_size+1; y++)
        {
          //if(Math.random()>0.3) continue;
          var tl:Boolean = solid(source, x*grid_size-grid_size/2, y*grid_size-grid_size/2);
          var tr:Boolean = solid(source, x*grid_size+grid_size/2, y*grid_size-grid_size/2);
          var bl:Boolean = solid(source, x*grid_size-grid_size/2, y*grid_size+grid_size/2);
          var br:Boolean = solid(source, x*grid_size+grid_size/2, y*grid_size+grid_size/2);
          var index:int = (tl?8:0) + (tr?4:0) + (bl?2:0) + (br?1:0);
          if(index == 0) continue;
          var polygon:Array = polygons[index];
          if(index == 15)
          {
            output.push(Polygon.fromArray(scale(translate(polygon, x, y), grid_size)));
            continue;
          }
          polygon = scale(formFit(translate(polygon, x, y), grid_size, source), grid_size);
          if(polygon.length > 0)
            output.push(Polygon.fromArray(polygon));
        }
        
      return output;
    }
  }
}