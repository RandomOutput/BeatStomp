package state
{
  import flash.events.MouseEvent;
  import state.component.*;
    
  public class UIState extends State
  {
    public var controls:Array = new Array();
    public var offset:int = 0;
    private var sweep_done:Function = null;
    private var sweep_speed:int = 0;
    
    public function UIState() {}
    
    protected function addControl(control:Control):Control
    {
      controls.push(control);
      return control;
    }
    
    public function sweepOn(sweep_speed_:int = 20,
                            sweep_done_:Function=null):void
    {
      for each(var control:Control in controls)
        control.moveTo(control.top_left.add(new Vect2(640, 0)));
      offset = 640;
      sweep_speed = sweep_speed_;
      sweep_done = sweep_done_;
      //Assets.whoosh.play();
    }
    
    public function sweepOff(sweep_speed_:int = 20,
                             sweep_done_:Function=null):void
    {
      offset = 640;
      sweep_speed = sweep_speed_;
      sweep_done = sweep_done_;
      //Assets.whoosh.play();
    }
    
    public function addXOffset(amount:int):void
    {
      for each(var control:Control in controls) 
        control.moveTo(control.top_left.add(new Vect2(amount, 0)));
    }
    
    public override function tick():void
    {
      super.tick();
      if(offset > 0)
      {
        addXOffset(-sweep_speed);
        offset -= sweep_speed;
        if(offset <= 0)
        {
          offset = 0;
          if(sweep_done!=null) sweep_done();
          sweep_done = null;
        }
        return;
      }

      if(input.mouse_move!=null) mouseMove(input.mouse_position);
      if(input.mouse_pressed)    mouseDown(input.mouse_position);
      
      for each(var control:Control in controls) control.tick();      
    }
    
    public override function draw():void
    {
      for each(var control:Control in controls) control.draw();
    } 
    
    public override function background():void
    {
      Display.ui_screen.clear();
    }
        
    protected function mouseMove(where:Vect2):void
    {
      for each(var control:Control in controls) control.mouseMove(where);
    }
    
    protected function mouseDown(where:Vect2):void
    {
      for each(var control:Control in controls) 
        if(control.inside(where)) control.mouseDown();
    }
  }
}