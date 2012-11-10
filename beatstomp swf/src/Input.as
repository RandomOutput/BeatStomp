package  
{
  import flash.events.*;
  
  public class Input 
  {
    private var keys:Array = new Array(256);
    private var mouse_position:Vect2 = new Vect2(0, 0);
    public var mouse_down:Boolean = false;
    
    private var last_keys:Array = new Array(256);
    private var last_mouse_position:Vect2 = new Vect2(0, 0);
    private var last_mouse_down:Boolean = false;
    
    static private var random_seed:uint = 31337;

    private var update_count:int = 0;
    private var playback_position:int = 0;
    
    private var recorded_input:Array = [];
    
    public function Input() 
    {
      if(recorded_input.length == 0)
      {
        Display.stage.addEventListener(MouseEvent.MOUSE_DOWN,  mouseDown);
        Display.stage.addEventListener(MouseEvent.MOUSE_UP,    mouseUp  );
        Display.stage.addEventListener(MouseEvent.MOUSE_MOVE,  mouseMove);
        Display.stage.addEventListener(KeyboardEvent.KEY_DOWN, keyDown  );
        Display.stage.addEventListener(KeyboardEvent.KEY_UP,   keyUp    );
        Display.stage.addEventListener(Event.DEACTIVATE, unFocus);
      }
      
      reset();    
    }
    
    public function unFocus(event:Event):void
    {
      reset();
      if(Main.topState()) Main.topState().unFocus();
      //trace("recorded_input[recorded_input.length-1].reset = true;");
      
      //var output:String = "recorded_input.push({state: "+(update_count++)+", ";
    }
     
    public static function rand():Number
    {
      return Math.random();
      random_seed = (random_seed * 16807) % 2147483647;
      return (random_seed)/0x7FFFFFFF+0.000000000233;
    }
    
    public static function randInt(min:int, max:int):int
    {
      return Math.floor(rand()*(max-min+1))+min;
    }

    public static function randBetween(from:Number, to:Number):Number
    {
      return rand() * (to-from) + from;
    }
    
    public static function randOf(array:Array):Object
    {
      return array[int(rand()*array.length)];
    }
    
    public function reset():void
    {
      for(var i:int=0; i<256; i++) keys[i] = false, last_keys[i] = false;
      mouse_down = false;
    }
    
    public function state():Object
    {
      if(recorded_input.length > 0)
      {
        while(recorded_input[playback_position].state < update_count)
        {
          var pb:Object = recorded_input[playback_position];
          if(pb.mouse_move) mouse_position = pb.mouse_move;
          if(pb.hasOwnProperty("mouse_down")) mouse_down = pb.mouse_down;
          if(pb.keys_up  ) for each(var k:int in pb.keys_up  ) keys[k] = false;
          if(pb.keys_down) for each(    k     in pb.keys_down) keys[k] = true;
          playback_position++;
        }
      }
      
      var keys_up:Array = [], keys_down:Array = [];
      for(var i:int=0; i<256; i++)
      {
        if( keys[i] && !last_keys[i]) keys_down.push(i), last_keys[i] = true;
        if(!keys[i] &&  last_keys[i]) keys_up  .push(i), last_keys[i] = false;
      }

      var input:Object =
      {
        keys:           keys,
        keys_up:        keys_up,
        keys_down:      keys_down,
        mouse_position: mouse_position,
        mouse_down:     mouse_down,
        mouse_move:     last_mouse_position.x != mouse_position.x ||
                        last_mouse_position.y != mouse_position.y,
        mouse_pressed:  mouse_down && !last_mouse_down,
        mouse_released: !mouse_down && last_mouse_down
      };
            
      var output:String = "recorded_input.push({state: "+(update_count++)+", ";
      var len:int = output.length;
      if(keys_up  .length > 0) output +=   "keys_up: ["+keys_up  +"], ";
      if(keys_down.length > 0) output += "keys_down: ["+keys_down+"], ";
      if(input.mouse_move    )
        output += "mouse_move: new Vect2("+mouse_position.x+","+mouse_position.y+"), ";
      if(input.mouse_pressed ) output += "mouse_down: true, ";
      if(input.mouse_released) output += "mouse_down: false, ";
      //if(len != output.length) trace(output.substr(0, output.length-2)+" });");
      
      last_mouse_position = mouse_position.clone();
      last_mouse_down = mouse_down;
      
      if(pb!=null && pb.reset) unFocus(null);
      //trace(input.mouse_down, input.mouse_pressed);
      return input;
    }
    
    static public function emptyState():Object
    {
      return {
        keys:           [],
        keys_up:        [],
        keys_down:      [],
        mouse_position: new Vect2(0, 0),
        mouse_down:     false,
        mouse_move:     false,
        mouse_pressed:  false,
        mouse_released: false
      };
    }
    
    protected function keyDown(e:KeyboardEvent):void
    {
      keys[e.keyCode] = true;
    }
    
    protected function keyUp(e:KeyboardEvent):void
    {
      keys[e.keyCode] = false;
    }
    
    protected function mouseMove(e:MouseEvent):void
    {
      mouse_position.x = e.stageX;
      mouse_position.y = e.stageY;
    }
    
    protected function mouseDown(e:MouseEvent):void
    {
      mouseMove(e);
      mouse_down = true;
    }
    
    protected function mouseUp(e:MouseEvent):void
    {
      mouseMove(e);
      mouse_down = false;
    }

  }
}