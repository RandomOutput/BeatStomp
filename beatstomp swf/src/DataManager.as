package{
  import flash.errors.IOError;
  import flash.events.*;
  import flash.net.*;
  import flash.utils.getTimer;
  
  /*
   *Socket Server Tutorial from:  http://a.parsons.edu/~lik43/wirelesstoy/?p=625
   * 
   */
  
  public class DataManager 
  {
    private var hostName:String = "127.0.0.1";
    private var port:uint = 9002;
    private var socketServer:XMLSocket;
    
    private var state_change_callback:Function = null;
    
    private var player_states:Array = null;
  
    public function DataManager(callback:Function)
    {
      state_change_callback = callback;
      player_states = new Array(0, 0, 0, 0);
      socketServer = new XMLSocket  ;
      configure(socketServer);
      socketServer.connect(hostName, port);
    }
    
    private function configure(disp:IEventDispatcher):void
    {
      trace("config");
      disp.addEventListener(Event.CLOSE, closeHandler);
      disp.addEventListener(Event.CONNECT, connectHandler);
      disp.addEventListener(DataEvent.DATA, dataHandler);
      disp.addEventListener(IOErrorEvent.IO_ERROR, ioErrorHandler);
    }
    
    private function closeHandler(event:Event):void
    {
      trace("closeHandler: " + event);
    }
    
    private function connectHandler(event:Event):void
    {
      trace("connectHandler: " + event);
    }
    
    private function ioErrorHandler(event:IOErrorEvent):void
    {
      trace("ioErrorHandler: " + event);
    }
    
    private function dataHandler(event:DataEvent):void
    {
      //trace(getTimer());
      socketServer.send("A");
      var incoming:int = (int)(event.data);
      trace(incoming);
      for (var i:int = 0; i < 4; ++i) {
        player_states[i] = ((incoming & (1 << i)) != 0);
      }
      state_change_callback(player_states);
    }
  }
}
