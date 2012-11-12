package state 
{
  import flash.display.Bitmap;
  import flash.display.Shape;
  import flash.geom.Matrix;
  import flash.media.Sound;
  import flash.ui.*;
  import entity.*;
  import mx.core.ILayoutDirectionElement;
  
  public class Stomper extends Playfield 
  {
    static public var latency_ms:Number = -16;
    static public var ms_per_frame:Number = 1000.0/60;
    
    private var song_time_ms:Number = -1;
    private var song_time_beats:Number = 0;
    private var last_reported_position_ms:Number = -1;
    
    private var song_notes:Object = {};
    private var song_sound:Sound = null;
    private var song_tempo:Number = 0;
    
    private var hang_times:Array = [ 0.0, 0.0, 0.0, 0.0 ];
    private var scores:Array = [ 0, 0, 0, 0 ];
    
    private const center_circle_radius:int = 30;
    private const player_circle_radius:int = 15;
    private const note_radius:int = 15;
    public static const note_distance_px:int = 425;
    private const note_distance_beats:int = 4;
    private const hang_time_growth:Number = 60;
    private const base_note_score:int = 250;
    private const hang_time_score_bonus:Number = 750;
    private const hit_leeway:Number = 0.3;
	
    private var data_manager:DataManager = null;

    public static const direction_vectors:Array =
    [
      new Vect2(-1,  -1).normalize(),
      new Vect2(-1,   1).normalize(),
      new Vect2( 1,  -1).normalize(),
      new Vect2( 1,   1).normalize()
    ];
    
    public function Stomper(song_data:Array, sound:Sound, tempo:Number)
    {
      song_sound = sound;
      song_tempo = tempo;
      
      var time:Number = 0;
      for(var i:int=0; i<song_data.length; i+=2)
      {
        time+=song_data[i];
        if(song_data[i+1]==4)
          song_notes[time] = [0, 1, 2, 3];
        else
          song_notes[time] = song_data[i+1];
      }
    }
    
    override public function draw():void
    {
      super.draw();
      
      var b:Number = 1-(song_time_beats-Math.floor(song_time_beats))/2.0;
      var color:int = Misc.colorFromTriplet([b, b, b]);
      
      Text.renderTo(Display.screen, song_time_beats.toString(), 5, 5);
      var shape:Shape = new Shape();
      shape.graphics.lineStyle(3, color);
      shape.graphics.drawCircle(Display.screen_center.x, Display.screen_center.y,
        center_circle_radius);
        
      for(var i:int=0; i<4; i++)
      {
        var circle_pos:Vect2 = direction_vectors[i].multiply(note_distance_px)
          .add(Display.screen_center);
        shape.graphics.drawCircle(circle_pos.x, circle_pos.y,
          player_circle_radius+hang_time_growth*hang_times[i]);
      }

      const direction_map:Array = [ 1, 0, 2, 3 ];
      for(i=0; i<4; i++)
      {
        var score_display:Bitmap = Text.render(int(scores[direction_map[i]]).toString()); 
        var matrix:Matrix = new Matrix();
        matrix.translate(-score_display.width/2, -score_display.height/2);
        matrix.rotate(Math.sin(song_time_beats*Math.PI/2)/5);
        matrix.translate(75, 300+Math.sin(song_time_beats*Math.PI)*4);
        matrix.rotate(i*Math.PI/2+Math.PI/4);
        matrix.translate(400, 400);
        Display.screen.bitmapData.draw(score_display, matrix);
      }
      
      for(var p:String in song_notes)
      {
        var position:Number = Number(p);
        if(position < song_time_beats-note_distance_beats ||
           position > song_time_beats+note_distance_beats)
          continue;
        
        if(song_notes[p].length == 4)
        {
          var a:Array = song_notes[p];
          if(a[0]==0 || a[1]==1 || a[2]==2 || a[3]==3)
            for each(var note:int in song_notes[p])
            {
              shape.graphics.lineStyle(16, color);
              var beat_position:Number = position - song_time_beats;
              shape.graphics.drawCircle(Display.screen_center.x, Display.screen_center.y,
                note_distance_px-beat_position*(note_distance_px/note_distance_beats));
              shape.graphics.lineStyle(3, color);
            }
        }
        for each(note in song_notes[p])
        {
          if(note==-1) continue;
          var direction:Vect2 = direction_vectors[note];
          
          beat_position = position - song_time_beats;
          var screen_position:Vect2 =
            Display.screen_center.add(direction.multiply(note_distance_px-
              beat_position*(note_distance_px/note_distance_beats)));
          shape.graphics.beginFill(Misc.colorFromTriplet([b, b, b]), 1);
          shape.graphics.drawCircle(screen_position.x, screen_position.y, 
            note_radius);
          shape.graphics.endFill();
        }
      }
      
      Display.screen.bitmapData.draw(shape);
    }
    
    override public function tick():void
    {
      if(song_time_ms == -1)
      {
        MusicHandler.play(song_sound);
        song_time_ms = 0;
        MusicHandler.current_music.channel.whenComplete(function():void
          {
            Main.replaceTopState(new Menu());
          })
      }
      
      song_time_ms += ms_per_frame;
      
      var reported_position_ms:Number =
        MusicHandler.current_music.channel.getPosition();
      if(reported_position_ms != last_reported_position_ms && 
         Math.abs(reported_position_ms - song_time_ms) > 50.0)
      {
        trace(song_time_ms, reported_position_ms);
        song_time_ms = reported_position_ms;
      }
      last_reported_position_ms = reported_position_ms;
      
      song_time_beats = song_time_ms*song_tempo/(1000*60);
      
      super.tick();
      
      for each(var key:int in input.keys_down) keyDown(key);
      for each(    key     in input.keys_up  ) keyUp  (key);
      
      for(var i:int=0; i<4; i++)
        if(hang_times[i]>0) hang_times[i] = hang_times[i]*0.95 + 1*0.05;
    }
    
    private function strikeAt(pos:Vect2):void
    {
      for(var i:int=0; i<Assets.shards.frame_count; i++)
        addEntity(new Particle(
          {
            position: pos,
            velocity: Misc.vectFromAngle(Input.randBetween(0, Math.PI*2)).multiply(Input.randBetween(1, 4)),
            gravity: new Vect2(0, 0),
            fade: -0.04,
            offset: new Vect2(-24, -24),
            scale: 0.75,
            alpha: 1,
            drawable: Assets.shards.frame(i)
          }
        ));
    }
    
    static public function directionFromKey(key:int):int
    {
      if(key < 4) return key;
      
      if(key == Keyboard.LEFT  || key==65)             return 0;
      if(key == Keyboard.DOWN  || key==83 || key==79)  return 1;
      if(key == Keyboard.UP    || key==87 || key==188) return 2;
      if(key == Keyboard.RIGHT || key==68 || key==69)  return 3;
      
      return -1;
    }
    
    private function keyUp(key:int):void
    {
      var direction:int = directionFromKey(key);
      if(direction==-1) return;
      
      hang_times[direction] = 0.01;
    }
		
    private var old_states:Array = [ false, false, false, false ];
    
    private function keyDown(key:int):void
    {
      var direction:int = directionFromKey(key);
      if(direction==-1) return;
      
      for(var p:String in song_notes)
      {
        if(Math.abs(Number(p)-song_time_beats) > hit_leeway) continue;
        for(var i:int=0; i<song_notes[p].length; i++)
        {
          trace(song_notes[p][i], direction);
          if(song_notes[p][i] == direction)
          {
            song_notes[p][i] = -1;
            scores[direction] += base_note_score +
              hang_time_score_bonus*hang_times[direction];
            strikeAt(direction_vectors[direction].multiply(note_distance_px)
              .add(Display.screen_center));
          }
        }
      }
      
      hang_times[direction] = 0;      
    }
  }
}