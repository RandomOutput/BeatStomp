package  
{
  import flash.display.*;
  import flash.events.Event;
  import flash.geom.*;
  import flash.media.SoundChannel;
  import flash.utils.Dictionary;
  
  public class Tip 
  {
    private var bitmap:Bitmap;
    private var timeout:int;
    private var y:int = 0;
    private var text:String;
    private var time:Number = 0;

    private var display_pos:Number = 0;
    private var height:int = 0;
    
    private static var left_corner:Boolean = false;
    private static var tips:Array = new Array();
    private static var old_tips:Array = [];
    
    private static var tip_pool:Array = [];
    
    private static var time_since_tip:int = 0;
    
    public function Tip(text_:String) 
    {
      text = text_;
      
      text = Text.wrap(text, 18);
      var lines:Array = text.split("\n");
      var maxlength:int = 0;
      for each(var line:String in lines)
        if(line.length>maxlength) maxlength=line.length;
      timeout = 45*lines.length;
      bitmap = new Bitmap(new BitmapData(maxlength*12+12, 20*lines.length+16,
                                         true, 0));
      height = bitmap.height;
      var shape:Shape = new Shape();
      shape.graphics.lineStyle(3, 0xffffff, 0.75);
      shape.graphics.beginFill(0x808080, 0.5);
      shape.graphics.drawRect(0, 0, bitmap.width, bitmap.height);
      shape.graphics.endFill();
      bitmap.bitmapData.draw(shape);
      Text.renderTo(bitmap, text, 12, 6, 2);
    }
    
    public function tick():void
    {
      time_since_tip = 0;
      if(timeout > 0)
      {
        if(y < height) y+=4;
        else timeout--;
      }
      else
      {
        y -= 4;
        if(y < 0) tips.splice(0, 1);
      }
      
      time++;
    }
    
    public function draw():void
    {
      /*var frog_position:Vect2 = Main.game.frog.position;
      if(!left_corner)
      {
        if(frog_position.x > 640-bitmap.width-35 &&
           frog_position.y > 480-bitmap.height-35)
          left_corner = true;
      }
      else
      {
        if(frog_position.x < bitmap.width+35 &&
           frog_position.y > 480-bitmap.height-35)
          left_corner = false;
      }*/
      
      var x:int;
      if(left_corner) x=0;
      else x=640-bitmap.width;
      Display.ui_screen.bitmapData.copyPixels(bitmap.bitmapData,
        bitmap.bitmapData.rect, new Point(x, 480-y));
    }
    
    public static function randomTip(tip:String):void
    {
      tip_pool.push(tip);
    }
    
    public static function reset():void
    {
      old_tips = [];
      tips     = [];
    }
    
    public static function tick():void
    { 
      if(tips.length>0) tips[0].tick(); 
      if(++time_since_tip > 30*30 && tip_pool.length > 0)
      {
        var tip:String = Input.randOf(tip_pool) as String;
        tip_pool = tip_pool.filter(
          function(s:String, i:int, a:Array):Boolean { return s!=tip; });
        addTip(tip);
      }
    }
    public static function draw():void { if(tips.length>0) tips[0].draw(); }
    
    public static function addTip(text:String, asap:Boolean=false):Boolean
    {
      if(!asap && tips.length > 0) return false;
      if(old_tips.indexOf(text) > -1) return false;
      tips.push(new Tip(text));
      old_tips.push(text);
      return true;
    }
  }
}