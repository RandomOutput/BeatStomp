package entity
{
  import flash.display.*;
  import flash.geom.*;
  
  public class Particle extends Entity
  {
    private var drawable:IBitmapDrawable;
    private var offset:Vect2;
    private var gravity :Vect2 = new Vect2(0, 0.5);
    private var drag    :Vect2 = new Vect2(1, 1  );
    private var spin :Number=0, angle     :Number= 0;
    private var alpha:Number=1, fade      :Number=-0.01;
    private var scale:Number=1, scaledelta:Number=0;
    private var color_transform:ColorTransform = new ColorTransform();
    private var destination:Bitmap = Display.screen;
    
    public function Particle(_params:Object)
    {
      super(_params.position);
      for(var item:String in _params)
        this[item] = _params[item];
      if(!offset) offset = new Vect2(0, 0);
    }
    
    public override function tick():void
    {
      position = position.add(velocity);
      velocity = velocity.add(gravity);
      velocity.x *= drag.x;
      velocity.y *= drag.y;
      angle += spin;
      alpha += fade;
      scale += scaledelta;
      color_transform.alphaMultiplier = alpha;
      
      if(alpha <= 0) remove = true;
      if(scale <= 0) remove = true;
    }
    
    public override function draw():void
    {
      var matrix:Matrix = new Matrix(scale, 0, 0, scale, 0, 0);
      matrix.translate(offset.x, offset.y);
      matrix.rotate(angle);
      matrix.translate(position.x, position.y);
      matrix.concat(Display.camera);
      
      //var quality:String = Display.stage.quality;
      //Misc.stage.quality = StageQuality.LOW;
      destination.bitmapData.draw(drawable, matrix, color_transform);
      //Misc.stage.quality = quality;
    }
  }
}