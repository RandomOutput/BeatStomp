package  
{
  public class Fuse 
  {    
    public var frames_until_execution:int;
    private var callback:Function;
    public var label:String;
    public var remove:Boolean = false;
    
    private static var current_fuse:Fuse = null;
        
    public function Fuse(_frames_until_execution:int, _label:String,
                         _callback:Function) 
    {
      frames_until_execution = _frames_until_execution;
      callback = _callback;
      label = _label;
      //trace(label);
    }
    
    public function tick():void
    {
      if(--frames_until_execution <= 0)
      {
        current_fuse = this;
        callback();
        current_fuse = null;
        if(frames_until_execution == 0) remove = true;
      }
    }
    
    public static function retrigger(_frames_until_execution:int):void
    {
      current_fuse.frames_until_execution = _frames_until_execution;
    }    
  }
}
