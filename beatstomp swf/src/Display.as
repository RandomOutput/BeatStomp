package  
{
  import flash.display.Stage;
  import flash.geom.Matrix;
  
  public class Display 
  {
    public static var   stage        :Stage = null;
    public static const screen_size  :Vect2 = new Vect2(640, 480);
    public static const screen_center:Vect2 = screen_size.divide(2);
    public static var screen:Image = Image.blank(screen_size.x, screen_size.y);
    public static var ui_screen:Image = 
      Image.blank(screen_size.x, screen_size.y);
    
    public static var camera:Matrix = new Matrix(1, 0, 0, 1, 0, 0);
  }
}
