package entity
{
  import flash.display.Shape;
  import flash.geom.Matrix;
  import state.*;
  
  public class Entity 
  {
    public var position:Vect2, velocity:Vect2 = new Vect2(0, 0);
    public var radius:Number = 25;
    public var remove:Boolean = false;
    public var playfield:Playfield = null;
    public var foot_offset:int = 0;
    
    public function Entity(_position:Vect2)
    {
      position = _position;
    }
    
    public function draw():void
    {
      /*var shape:Shape = new Shape();
      shape.graphics.lineStyle(2, 0xff0000);
      shape.graphics.moveTo(-32, foot_offset);
      shape.graphics.lineTo(32, foot_offset);
      
      var matrix:Matrix = new Matrix();
      matrix.translate(position.x, position.y);  
      matrix.concat(Display.camera);
      Display.screen.bitmapData.draw(shape, matrix);*/
    }
    public function tick():void {}
  }
}