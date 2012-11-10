package state
{
  import flash.events.Event;
  import flash.events.MouseEvent;
  import flash.geom.Matrix;
  import flash.ui.Keyboard;
  import state.component.*;
  
  public class Title extends UIState
  { 
    static public var concept_art:Boolean = false;
    public var angle:Number = 0;
    
    public function Title()
    {
      MusicHandler.play(Assets.bpa, Assets.intro);
      addControl(Button.TextButton(new Vect2(320, 400), "Play Frog Infarctions!", true,
        function():void { Main.pushState(new Room()); }));
    }
    
    public override function draw():void
    {
      Assets.title.blit(Display.screen);
      super.draw();
    }
    
    public override function tick():void
    {
      /*if(concept_art && controls.length < 3)
        addControl(Button.TextButton(new Vect2(320, 430), "Concept art!",
          true, function():void { Main.pushState(new ConceptArt()); }));*/
      super.tick();
      //MusicHandler.play(Assets.jolly);
    }
  }
}