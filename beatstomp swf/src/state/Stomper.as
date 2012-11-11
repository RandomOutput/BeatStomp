package state 
{
  import flash.display.Shape;
  import flash.media.Sound;
  import flash.ui.*;
  
  public class Stomper extends State 
  {
    static public var latency_ms:Number = -16;
    static public var ms_per_frame:Number = 1000.0/60;
    
    private var song_time_ms:Number = -1;
    private var song_time_beats:Number = 0;
    private var last_reported_position_ms:Number = -1;
    private var sound_channel:SoundChannelWrapper = null;
    
    private var song_notes:Object = {};
    private var song_sound:Sound = null;
    private var song_tempo:Number = 0;
    
    private const center_circle_radius:int = 30;
    private const player_circle_radius:int = 15;
    private const note_radius:int = 15;
    private const note_distance_px:int = 350;
    private const note_distance_beats:int = 4;
    private const hit_leeway:Number = 0.3;
	
	private var data_manager:DataManager = null;
    
    public function Stomper(song_data:Array, sound:Sound, tempo:Number)
    {
      song_sound = sound;
      song_tempo = tempo;
      
      var time:Number = 0;
      for(var i:int=0; i<song_data.length; i+=2)
      {
        time+=song_data[i];
        song_notes[time] = song_data[i+1];
      }
	  
	  data_manager = new DataManager(playerStateChanged);
    }
    
    override public function draw():void
    {
      super.draw();
      
      Text.renderTo(Display.screen, song_time_beats.toString(), 5, 5);
      var shape:Shape = new Shape();
      var b:Number = 1-(song_time_beats-Math.floor(song_time_beats))/2.0;
      shape.graphics.lineStyle(3, Misc.colorFromTriplet([b, b, b]));
      shape.graphics.drawCircle(Display.screen_center.x, Display.screen_center.y,
        center_circle_radius);
      shape.graphics.drawCircle(Display.screen_center.x+note_distance_px,
        Display.screen_center.y, player_circle_radius);
      shape.graphics.drawCircle(Display.screen_center.x-note_distance_px,
        Display.screen_center.y, player_circle_radius);
      shape.graphics.drawCircle(Display.screen_center.x,
        Display.screen_center.y+note_distance_px, player_circle_radius);
      shape.graphics.drawCircle(Display.screen_center.x,
        Display.screen_center.y-note_distance_px, player_circle_radius);

      for(var p:String in song_notes)
      {
        var position:Number = Number(p);
        if(position < song_time_beats-note_distance_beats ||
           position > song_time_beats+note_distance_beats)
          continue;
        
        for each(var note:int in song_notes[p])
        {
          var direction:Vect2 = new Vect2(0, 0);
          if(note==-1) continue;
          if(note==0) direction.x = -1;
          if(note==1) direction.y =  1;
          if(note==2) direction.y = -1;
          if(note==3) direction.x =  1;
          
          var beat_position:Number = position - song_time_beats;
          var screen_position:Vect2 =
            Display.screen_center.add(direction.multiply(note_distance_px-
              beat_position*(note_distance_px/note_distance_beats)));
          shape.graphics.drawCircle(screen_position.x, screen_position.y, 
            note_radius);
        }
      }
      
      Display.screen.bitmapData.draw(shape);
    }
    
    override public function tick():void
    {
      if(song_time_ms == -1)
      {
        sound_channel = SoundChannelWrapper.play(song_sound);
        song_time_ms = 0;
      }
      
      song_time_ms += ms_per_frame;
      
      var reported_position_ms:Number = sound_channel.getPosition();
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
    }
		
	public function playerStateChanged(player_states:Array) {
		trace("Player state changed: " + player_states);
	}
    
    private function keyDown(key:int):void
    {
      var direction:int = -1;
      if(key == Keyboard.LEFT  || key==65)             direction = 0;
      if(key == Keyboard.DOWN  || key==83 || key==79)  direction = 1;
      if(key == Keyboard.UP    || key==87 || key==188) direction = 2;
      if(key == Keyboard.RIGHT || key==68 || key==69)  direction = 3;
      if(direction == -1) return;
      
      for(var p:String in song_notes)
      {
        if(Math.abs(Number(p)-song_time_beats) > hit_leeway) continue;
        for(var i:int=0; i<song_notes[p].length; i++)
        {
          trace(song_notes[p][i], direction);
          if(song_notes[p][i] == direction) song_notes[p][i] = -1;
        }
      }
    }
  }
}