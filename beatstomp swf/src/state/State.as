package state
{
  import flash.display.*;
  import flash.events.*;

  public class State
  {
    public var focus:Boolean = false;
    public var fuses:FuseGroup = new FuseGroup();
    public var input:Object = Input.emptyState();
    
    public function State() {}
    
    public function tick():void { fuses.tick(); }
    public function draw():void {}

    public function foreground():void
    {
      focus = true;
    }

    public function background():void
    {
      focus = false;
    }
    
    public function unFocus():void {}
  }
}
