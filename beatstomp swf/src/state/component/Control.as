package state.component
{
  import flash.display.Bitmap;
  
  public class Control 
  {
    public var name:String;
    public var top_left:Vect2, bottom_right:Vect2;
    protected var on_click:Function, on_hover:Function, on_dehover:Function;
    protected var hovering:Boolean = false;
    protected var render_dest:Bitmap = Display.ui_screen;
    private var size:Vect2;

    public function Control(_position:Vect2, _name:String, _size:Vect2,
                            _on_click:Function=null, _on_hover:Function=null,
                            _on_dehover:Function=null)
    { 
      top_left = _position;
      name = _name;
      size = _size;
      bottom_right = top_left.add(_size);
      on_click   = _on_click;
      on_hover   = _on_hover;
      on_dehover = _on_dehover;
    }
    
    public function moveTo(pos:Vect2):void
    {
      top_left = pos;
      bottom_right = top_left.add(size);
    }
    
    public function draw():void {}
    
    public function inside(p:Vect2):Boolean
    {
      return p.x >     top_left.x-5 && p.y >     top_left.y-5 &&
             p.x < bottom_right.x+5 && p.y < bottom_right.y+5;
    }
    
    public function mouseMove(p:Vect2):void
    {
      if(inside(p)) mouseIn();
      else mouseOut();
    }
    
    public function mouseIn():void
    { 
      if(!hovering && on_hover!=null)
      {
        on_hover(name);
        hovering = true;
      }
    }
    
    public function mouseOut ():void
    {
      if(hovering && on_dehover!=null) on_dehover();
      hovering = false;
      
    }
    public function mouseDown():void { if(hovering) click(); }
    
    public function click():void { if(on_click!=null) on_click(name); }
    
    public function tick():void {}
  }
}