package
{
  import flash.display.*;
  import flash.events.Event;
  import flash.utils.getTimer;
  import flash.filters.DropShadowFilter;
  
  import state.*;

  public class Main extends Sprite
  {
    static public var input:Input;
    static public var fuses:FuseGroup = new FuseGroup();
    
    static private var states:Vector.<State> = new Vector.<State>();
    static private var current_state:int;
    
    static public var show_tips:Boolean = true;
    
    public function Main():void
    {
      if(stage) init();
      else addEventListener(Event.ADDED_TO_STAGE, init);
    }
    
    private var song_data:Array = 
    [
      12, [1], 1.5, [0], 0.5, [3], 1, [0, 3], 1, [0], 
      1, [1], 0.5, [3], 1, [1], 0.5, [0], 0.5, [1], 
      0.5, [3], 0.5, [1], 1, [2], 1, [1], 0.5, [0], 
      0.5, [1], 0.5, [0, 1], 1, [3, 2], 1, [0], 0.5, [2], 
      0.5, [3], 0.5, [2], 0.5, [0], 0.5, [1], 0.5, [3], 
      0.5, [2], 1, [3], 0.5, [1], 0.5, [0], 0.5, [0], 
      1, [3], 0.5, [2], 1, [0], 0.5, [1], 0.5, [3], 
      0.5, [2], 0.5, [1], 0.5, [2], 0.5, [0], 1, [0], 
      0.5, [1], 1, [3], 1, [1], 0.5, [3], 0.5, [2], 
      0.5, [3], 0.5, [0], 0.5, [1], 0.5, [3], 1, [2], 
      0.5, [1], 1, [3], 0.5, [0], 0.5, [2], 1, [3, 0], 
      1, [2, 3], 2.5, [2, 0], 1.5, [3, 1], 1, [0, 3], 2, [2, 0], 
      1.5, [3, 1], 1.5, [1, 0], 0.5, [2, 3], 1.5, [0, 1], 1.5, [3, 1], 
      1.5, [0, 2], 1, [1, 3], 1.5, [0], 0.5, [3, 2], 1, [0, 3], 
      1, [3, 0], 1, [1, 0], 1, [3], 0.5, [2, 0], 1.5, [3, 1], 
      1, [0, 2], 2, [2, 3], 1, [2], 0.5, [2, 0], 1.5, [0, 3], 
      1, [3, 1], 1, [1, 3], 1, [3], 1, [1, 0], 1, [2, 0], 
      1, [2, 0], 1, [3], 1, [3, 2], 1, [3, 1], 1, [3, 1], 
      1, [1], 1, [3, 0], 1, [0, 2], 1, [0, 2], 1, [0], 
      1, [2, 3], 0.5, [0], 0.5, [3], 0.5, [0], 0.5, [2], 
      0.5, [1], 0.5, [2], 0.5, [2, 0], 1, [1], 0.5, [3], 
      0.5, [1], 0.5, [0], 0.5, [2], 0.5, [0], 0.5, [3, 1], 
      1, [3], 0.5, [2], 0.5, [3], 0.5, [0], 0.5, [1], 
      0.5, [0], 0.5, [0, 1], 1, [1], 0.5, [2], 0.5, [1], 
      0.5, [3], 0.5, [0], 0.75, [2], 0.75, [0], 0.5, [0], 
      1, [1], 0.5, [3], 1, [1], 0.5, [0], 0.5, [1], 
      0.5, [3], 0.5, [1], 1, [2], 1, [1], 0.5, [0], 
      0.5, [1], 0.5, [0, 1], 1, [3, 2], 1, [0], 0.5, [2], 
      0.5, [3], 0.5, [2], 0.5, [0], 0.5, [1], 0.5, [3], 
      0.5, [2], 1, [3], 0.5, [1], 0.5, [0], 0.5, [0], 
      1, [3], 0.5, [2], 1, [0], 0.5, [1], 0.5, [3], 
      0.5, [2], 0.5, [1], 0.5, [2], 0.5, [0], 1, [0], 
      0.5, [1], 1, [3], 1, [1], 0.5, [3], 0.5, [2], 
      0.5, [3], 0.5, [0], 0.5, [1], 0.5, [3], 1, [2], 
      0.5, [1], 1, [3], 0.5, [0], 0.5, [2], 0.5, [0], 
      1, [1], 0.5, [3], 1, [1], 0.5, [0], 0.5, [1], 
      0.5, [3], 0.5, [1], 1, [2], 1, [1], 0.5, [0], 
      0.5, [1], 0.5, [0, 1], 1, [3, 2], 1, [0], 0.5, [2], 
      0.5, [3], 0.5, [2], 0.5, [0], 0.5, [1], 0.5, [3], 
      0.5, [2], 1, [3], 0.5, [1], 0.5, [0], 0.5, [0], 
      1, [3], 0.5, [2], 1, [0], 0.5, [1], 0.5, [3], 
      0.5, [2], 0.5, [1], 0.5, [2], 0.5, [0], 1, [0], 
      0.5, [1], 1, [0], 0.5, [0], 0.5, [0], 0.5, [1], 
      0.5, [3], 0.5, [1], 0.5, [0], 0.5, [1], 0.5, [2], 
      0.5, [2], 0.5, [2], 0.5, [3], 0.5, [1], 0.5, [0], 
      0.5, [1], 0.5, [3], 0.5, [0, 3]
    ];
    
    private function init(e:Event = null):void
    {
      Display.stage = stage;
      
      removeEventListener(Event.ADDED_TO_STAGE, init);
      addChild(Display.screen);
      addChild(Display.ui_screen);
      Display.ui_screen.filters = [new DropShadowFilter(5, 45, 0, 1, 5, 5)];
      
      input = new Input();
      
      pushState(new Stomper(song_data, Assets.wif, 151));
      
      stage.addEventListener(Event.ENTER_FRAME, frame);
    }
    
    static private function frame(event:Event):void
    { 
      if(!topState()) pushState(new Title());
      for each(var s:State in states) s.input = Input.emptyState();
      topState().input = input.state();
      
      Display.screen.clear();
      Display.ui_screen.clear();
      
      var time:Number = getTimer();
      current_state = states.length; tickParent();
      current_state = states.length; drawParent();
      
      if(show_tips)
      {
        Tip.tick();
        Tip.draw();
      }
      
      fuses.tick();
      
      Text.renderTo(Display.screen, (getTimer()-time).toString(), 0,
        Display.screen_size.y-22);      
    }
    
    static public function clearStates():void
    {
      while(states.length > 0) popState();
    }
    
    static public function topState():State
    {
      if(states.length == 0) return null;
      return states[states.length-1];
    }
    
    static public function tickParent():void
    {
      if(current_state > 0) states[--current_state].tick();
    }
    
    static public function drawParent():void
    {
      if(current_state > 0) states[--current_state].draw();
    }
    
    static public function pushState(w:State):void
    {
      if(states.length > 0) states[states.length-1].background();
      states.push(w);
      w.foreground();
    }

    static public function popState():void
    {
      states.pop().background();
      if(states.length > 0) states[states.length-1].foreground();
    }
    
    static public function replaceTopState(s:State):void
    {
      states.pop().background();
      states.push(s);
      s.foreground();
    }
  }
}
