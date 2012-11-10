package state
{
  import flash.display.*;
  import flash.events.MouseEvent;
  import flash.filters.ColorMatrixFilter;
  import state.component.*;
  
  public class GameOver extends UIState
  {    
    public function GameOver()
    {
      addControl(Button.TextButton(new Vect2(320, 400), "Back to Title", true,
        function():void { Main.clearStates(); }));
    }
  }
}