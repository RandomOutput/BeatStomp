package  
{
  public class FuseGroup 
  {
    private var fuses:Array = [];
    
    public function exists(name:String):Boolean
    {
      for each(var f:Fuse in fuses)
        if(f.label==name) return true;
      return false;
    }
    
    public function cancel(label:String = ""):void
    {
      for each(var f:Fuse in fuses)
        if(label=="" || f.label == label) f.remove = true;
    }
    
    public function add(fuse:Fuse):void
    {
      fuses.push(fuse);
    }
    
    public function tick():void
    {
      var removed:Boolean = false;
      for(var i:int=0; i<fuses.length; i++)
        if(fuses[i].remove)
        {
          fuses.splice(i, 1);
          removed = true;
        }
      for each(var f:Fuse in fuses) f.tick();
    }
    
    public function toString():String
    {
      var out:String = "- ";
      for each(var f:Fuse in fuses)
      {
        if(f.remove) continue;
        out += f.label.toString()+", "+f.frames_until_execution.toString() + "; ";
      }
      return out;
    }    
  }
}