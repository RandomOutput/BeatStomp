package state.component
{
  import flash.display.IBitmapDrawable;
  import flash.display.Shape;
  import flash.display.StageQuality;
  import flash.geom.ColorTransform;
  import flash.geom.Matrix;
  
  public class Button extends Control
  {
    private var drawable:IBitmapDrawable;
    private var color:int = 0;
    public var size:Vect2 = null;
    public var disabled:Boolean;
    
    public function Button(_position:Vect2, _name:String, _size:Vect2,
                           _drawable:IBitmapDrawable, _on_click:Function,
                           _on_hover:Function=null, _on_dehover:Function=null)
    { 
      var hover:Function =
        function(name:String):void 
        {
          color = 0x606090;
          var hover_sound:Boolean = true;
          if(_on_hover!=null) hover_sound = _on_hover(name);
          //if(hover_sound) Assets.hover.play();
        };
      var dehover:Function =
        function():void { color = 0; if(_on_dehover!=null) _on_dehover(); };
        
      drawable = _drawable;
      super(_position, _name, _size,
        function():void { if(disabled) return; /*Assets.click.play();*/ _on_click(_name); },
        hover, dehover);
      size = _size;  
      
    }
    
    static public function TextButton(_position:Vect2, text:String,
      centered:Boolean, _on_click:Function, _on_hover:Function=null,
      _on_dehover:Function=null):Button
    {
      var size:Vect2 = Text.size(text);
      if(centered) _position = _position.subtract(size);
      return new Button(_position, text, size.multiply(2), Text.render(text),
                        _on_click, _on_hover, _on_dehover);
    }
    
    public function setDrawable(_drawable:IBitmapDrawable):void
    {
      drawable = _drawable;
    }
    
    public function setColor(_color:int):void { color = _color; }
    
    public override function draw():void
    {
      var shape:Shape = new Shape;
      shape.graphics.beginFill(disabled?0:color, 0.75);
      shape.graphics.drawRoundRect(top_left.x-7, top_left.y-5, size.x+11, size.y+10, 10, 10);
      shape.graphics.endFill();
      var quality:String = Display.stage.quality;
      Display.stage.quality = StageQuality.HIGH;
      render_dest.bitmapData.draw(shape);
      Display.stage.quality = quality;
      render_dest.bitmapData.draw(drawable,
        new Matrix(1, 0, 0, 1, top_left.x, top_left.y));
    }
  }
}
