
/* Generated code! */
package
{
  import flash.display.*;
  import flash.media.*;
  
  public class Assets
  { 


    [Embed (source="assets/arrow-gradient.png")] private static const ArrowGradient:Class;
    public static const arrowgradient:Image = new Image(new ArrowGradient().bitmapData);
    [Embed (source="assets/debateroom.jpg")] private static const Debateroom:Class;
    public static const debateroom:Image = new Image(new Debateroom().bitmapData);

    [Embed(source = "assets/arrows-hollow.png")] public static const ArrowsHollow:Class;
    public static const arrowshollow:Spriteset = new Spriteset(new ArrowsHollow(), 32);
      
    [Embed(source = "assets/arrows.png")] public static const Arrows:Class;
    public static const arrows:Spriteset = new Spriteset(new Arrows(), 32);
      
    [Embed(source = "assets/shards.png")] public static const Shards:Class;
    public static const shards:Spriteset = new Spriteset(new Shards(), 64);
      

    [Embed(source = "assets/wif.mp3")] public static const Wif:Class;
    public static const wif:Sound = new Wif();


  }
} 
