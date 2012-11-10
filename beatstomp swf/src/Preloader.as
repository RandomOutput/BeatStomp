package
{
  import flash.display.*;
  import flash.events.*
  import flash.geom.Point;
  import flash.geom.Rectangle;
  import flash.media.*;
  import flash.utils.getDefinitionByName;
   
  [SWF(width = "640", height = "480", backgroundColor = "#000000")]
  
  public class Preloader extends MovieClip
  {
    public static var screen:Bitmap =
      new Bitmap(new BitmapData(640, 480, false, 0));
      
    [Embed (source="preloader/twinbeard.png")]
      private static const Twinbeard:Class;
    [Embed (source="preloader/logo soundtrack.mp3")]
      private static const Logosound:Class;
    private static const twinbeard:Bitmap = new Twinbeard();
    private static const logosound:Sound  = new Logosound();
    private var logosound_channel:SoundChannel = null;
    private var sound_pos:Number = 0;
    private var sound_played:Boolean = false;
    private var loaded_percent:int = 0;    
    
    private var mouse_down:Boolean = false;

    public function Preloader()
    {
      addEventListener(Event.ENTER_FRAME, onFrame);
      loaderInfo.addEventListener(ProgressEvent.PROGRESS, progress);
      stage.addEventListener(MouseEvent.MOUSE_DOWN, mouseDown);
      stage.addEventListener(MouseEvent.MOUSE_UP,   mouseUp );
      addChild(screen);
    }
    
    private function progress(e:ProgressEvent):void
    {
      loaded_percent = int(e.bytesLoaded/e.bytesTotal*100);
    }
    
    private function mouseDown(e:MouseEvent):void { mouse_down = true;  }
    private function mouseUp  (e:MouseEvent):void { mouse_down = false; }
    
    private function drawFrame(n:int, x:int, y:int):void
    {
      screen.bitmapData.copyPixels(twinbeard.bitmapData,
        new Rectangle(n*150, 0, 150, twinbeard.height), new Point(x, y));
    }
    
    private function onFrame(e:Event):void
    {
      if(currentFrame == totalFrames && (mouse_down || sound_pos >= 9.5))
      {
        startup();
        return;
      }
      screen.bitmapData.fillRect(screen.bitmapData.rect, 0);
      
      if(!sound_played) logosound_channel = logosound.play();
      sound_played = true;
      
      if(logosound_channel) sound_pos = logosound_channel.position / 1000.0;
      else sound_pos += 1/30.0;
      
      if(sound_pos < 1.5) drawFrame(1, 245+Math.random()*3, 50+Math.random()*3);
      else if(sound_pos < 2.83) drawFrame(1, 245, 50);
      else if(sound_pos < 3.66) drawFrame(2, 245, 50);
      else if(sound_pos < 4.5 ) drawFrame(3, 245, 50);
      else if(sound_pos < 5.33) drawFrame(4, 245, 50);
      else if(sound_pos < 6.5 ) drawFrame(5, 245, 50);
      else drawFrame(6, 245, 50);
      
      var text_x:int = 640, text_y:int = 455;
      if(loaded_percent == 100)
        Text.renderTo(screen, "[Click to continue]", text_x, text_y, 2,
                      Text.ALIGN_RIGHT);
      else
        Text.renderTo(screen, "Loading: "+loaded_percent.toString()+ "%",
                      text_x, text_y, 2, Text.ALIGN_RIGHT);
    }
    
    private function startup():void
    {
      stop();
      if(logosound_channel) logosound_channel.stop();
      removeEventListener(Event.ENTER_FRAME, onFrame);
      stage.removeEventListener(MouseEvent.MOUSE_DOWN, mouseDown);
      stage.removeEventListener(MouseEvent.MOUSE_UP,   mouseUp);
      loaderInfo.removeEventListener(ProgressEvent.PROGRESS, progress);
      removeChild(screen);
      
      var main:Class = Class(getDefinitionByName("Main"));
      addChildAt(new main() as DisplayObject, 0);
    }
  }
}
