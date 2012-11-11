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
		
		private var player1Rocking:Number = 0;
	
		public function DataManager()
		{
			socketServer = new XMLSocket	;
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
			//trace(event);
			//trace(event.data);
			//trace((int)(event.data));
			var incoming:int = (int)(event.data);
			player1Rocking = incoming / 1000.0;
			//trace(player1Rocking);
			//player1Rocking = parseInt(event);
		}
		
		public function getPlayer1Rocking():Number
		{
			return player1Rocking;
		}
		
	}
}
