package state
{
  import flash.display.Shape;
  import flash.geom.Rectangle;
  import state.component.*;
  
  public class Pause extends UIState
  {
    public function Pause()
    {
      addControl(Button.TextButton(new Vect2(320, 400), "Resume", true,
        function():void { Main.popState(); }));
    }
    
    override public function draw():void
    {
      Main.drawParent();
      var shape:Shape = new Shape();
      shape.graphics.beginFill(0xffffff, 0.4);
      shape.graphics.drawRect(0, 0, Display.screen_size.x,
        Display.screen_size.y);
      shape.graphics.endFill();
      Display.screen.bitmapData.draw(shape);
      super.draw();
    }
  }
}