package state 
{
  import entity.*;
  import flash.display.Bitmap;
  import flash.display.ColorCorrection;
  import flash.display.Shape;
  import flash.geom.ColorTransform;
  import flash.geom.Matrix;
  import flash.geom.Rectangle;
  import flash.media.SoundTransform;
  import flash.ui.*;
  
  public class Room extends Playfield
  {
    public var display_bitmap:Image = Image.blank(640, 480);
    public var collide_bitmap:Image = Image.blank(640, 480);
    public var trail_bitmaps:Array = [];
    //:Image = Image.blank(640, 480);
    private var nearby_geometry:Array;
    private var room_timer:int = 30*30;
    public var angle:Number = 0;
    private var fruit_timer:int = 15;
    public var gameover:Boolean = false;
    
    public function Room(mode:int=0):void
    {
      addEntity(new Frog(new Vect2(320, 400)));
      addEntity(new Heart());
      draw_order = [Heart, Fruit, Frog, Bullet];
    }
    
    public function solid(q:Vect2):Boolean
    {
      var p:Vect2 = q.clone();
      if(p.x<0) p.x+=640;
      if(p.x>640) p.x-=640;
      if(p.y<0) p.y+=480;
      if(p.y>480) p.y-=480;
      
      var pixel:int = collide_bitmap.bitmapData.getPixel32(p.x, p.y);
      var alpha:int = pixel >> 24;
      return alpha < 0 || alpha > 64;
    }
    
    override public function tick():void
    {
      if(gameover) 
      {       
        if(input.keys[Keyboard.SPACE]) Main.replaceTopState(new Room());
        return;
      }
      
      super.tick();
      if(--fruit_timer == 0)
      {
        fruit_timer = 1.5*30;
        addEntity(new Fruit(new Vect2(Input.randInt(0, 640), Input.randInt(0, 480))));
      }
    }
    
    override public function draw():void
    {
      Assets.background.blit(Display.screen);
      collide_bitmap.blit(Display.screen);
      super.draw();
      if(gameover)
      {
        Text.renderTo(Display.ui_screen, "Game Over", 320, 230, 2, Text.ALIGN_CENTER);
        Text.renderTo(Display.ui_screen, "Push space to restart", 320, 250, 2, Text.ALIGN_CENTER);
      }
    }
  }
}