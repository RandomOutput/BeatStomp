package state.component
{
  import flash.display.Shape;
  public class UIText extends Control 
  {
    public var text:String = null;
    
    public function UIText(_text:String, _position:Vect2, _name:String = "",
                           _size:Vect2 = null) 
    {
      if(_size==null) _size = new Vect2(0, 0);
      super(_position, _name, _size);
      text = _text;
    }
    
    static public function Centered(_text:String, _position:Vect2):UIText
    {
      var _size:Vect2 = Text.size(_text).multiply(2);
      _position = _position.subtract(_size.divide(2));
      return new UIText(_text, _position, "", _size);
    }
    
    public override function draw():void
    {
      //Misc.surroundText(Misc.screen, text, top_left, 0);
      Text.renderTo(render_dest, text, top_left.x, top_left.y);
    }
    
    public function updateText(_text:String):void
    {
      text = _text;
    }
  }
}