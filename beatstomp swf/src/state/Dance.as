package state
{
  import flash.display.*;
  import flash.events.KeyboardEvent;
  import flash.filters.BlurFilter;
  import flash.geom.*;
  import flash.ui.*;
  
  import entity.*;
  
  public class Dance extends State 
  {
    private var song:Object = {};
    private var song_time:Number = 0;
    private var song_position:Number = 0;
    private var scale:int = 35;
    private var tempo:int = 151;
    private var hit_state:Number = 0.3;
    private var last_direction:int = -1;
    private var last_direction_time:int = 0;
    private var combo:int = 0;    
    private var entities:Array = [];
    private var latency:Number;
    private var dance_meter:Number = 0.75;
    private var dance_meter_decay_min:Number = 0.01;
    private var dance_meter_decay:Number = dance_meter_decay_min;
    
    private var sound_channel:SoundChannelWrapper;
    
    private var last_position:Number = 0, last_delta:Number = 0;
    
    private var arrow_bloom:Array = [0, 0, 0, 0];
    
    private var miss   :Bitmap = Text.render("Miss!");
    private var good   :Bitmap = Text.render("Good!");
    private var great  :Bitmap = Text.render("Great!");
    private var perfect:Bitmap = Text.render("Perfect!");
    
    private const MAXIMUM_FRAMES_BETWEEN_SIMULTANEOUS_KEYS:int = 10;
    private const BLOOM_FRAMES:int = 6;
    
    private var last_input:Object = Input.emptyState();
    
    private var light_overlay:Image = Image.blank(640, 480);
    private var lights:Array = [[0, 0], [0, 0], [0, 0]];
    private var dance_frame:int = 7;
    
    private var done:Boolean = false, playing:Boolean = false;

    private var arrow_sprites:Array;

    private var song_data:Array = 
    [
12, [1], 1.5, [0], 0.5, [3], 1, [0, 3], 1, [0], 
1, [1], 0.5, [3], 1, [1], 0.5, [0], 0.5, [1], 
0.5, [3], 0.5, [1], 1, [2], 1, [1], 0.5, [0], 
0.5, [1], 0.5, [0, 1], 1, [3, 2], 1, [0], 0.5, [2], 
0.5, [3], 0.5, [2], 0.5, [0], 0.5, [1], 0.5, [3], 
0.5, [2], 1, [3], 0.5, [1], 0.5, [0], 0.5, [0], 
1, [3], 0.5, [2], 1, [0], 0.5, [1], 0.5, [3], 
0.5, [2], 0.5, [1], 0.5, [2], 0.5, [0], 1, [0], 
0.5, [1], 1, [3], 1, [1], 0.5, [3], 0.5, [2], 
0.5, [3], 0.5, [0], 0.5, [1], 0.5, [3], 1, [2], 
0.5, [1], 1, [3], 0.5, [0], 0.5, [2], 1, [3, 0], 
1, [2, 3], 2.5, [2, 0], 1.5, [3, 1], 1, [0, 3], 2, [2, 0], 
1.5, [3, 1], 1.5, [1, 0], 0.5, [2, 3], 1.5, [0, 1], 1.5, [3, 1], 
1.5, [0, 2], 1, [1, 3], 1.5, [0], 0.5, [3, 2], 1, [0, 3], 
1, [3, 0], 1, [1, 0], 1, [3], 0.5, [2, 0], 1.5, [3, 1], 
1, [0, 2], 2, [2, 3], 1, [2], 0.5, [2, 0], 1.5, [0, 3], 
1, [3, 1], 1, [1, 3], 1, [3], 1, [1, 0], 1, [2, 0], 
1, [2, 0], 1, [3], 1, [3, 2], 1, [3, 1], 1, [3, 1], 
1, [1], 1, [3, 0], 1, [0, 2], 1, [0, 2], 1, [0], 
1, [2, 3], 0.5, [0], 0.5, [3], 0.5, [0], 0.5, [2], 
0.5, [1], 0.5, [2], 0.5, [2, 0], 1, [1], 0.5, [3], 
0.5, [1], 0.5, [0], 0.5, [2], 0.5, [0], 0.5, [3, 1], 
1, [3], 0.5, [2], 0.5, [3], 0.5, [0], 0.5, [1], 
0.5, [0], 0.5, [0, 1], 1, [1], 0.5, [2], 0.5, [1], 
0.5, [3], 0.5, [0], 0.75, [2], 0.75, [0], 0.5, [0], 
1, [1], 0.5, [3], 1, [1], 0.5, [0], 0.5, [1], 
0.5, [3], 0.5, [1], 1, [2], 1, [1], 0.5, [0], 
0.5, [1], 0.5, [0, 1], 1, [3, 2], 1, [0], 0.5, [2], 
0.5, [3], 0.5, [2], 0.5, [0], 0.5, [1], 0.5, [3], 
0.5, [2], 1, [3], 0.5, [1], 0.5, [0], 0.5, [0], 
1, [3], 0.5, [2], 1, [0], 0.5, [1], 0.5, [3], 
0.5, [2], 0.5, [1], 0.5, [2], 0.5, [0], 1, [0], 
0.5, [1], 1, [3], 1, [1], 0.5, [3], 0.5, [2], 
0.5, [3], 0.5, [0], 0.5, [1], 0.5, [3], 1, [2], 
0.5, [1], 1, [3], 0.5, [0], 0.5, [2], 0.5, [0], 
1, [1], 0.5, [3], 1, [1], 0.5, [0], 0.5, [1], 
0.5, [3], 0.5, [1], 1, [2], 1, [1], 0.5, [0], 
0.5, [1], 0.5, [0, 1], 1, [3, 2], 1, [0], 0.5, [2], 
0.5, [3], 0.5, [2], 0.5, [0], 0.5, [1], 0.5, [3], 
0.5, [2], 1, [3], 0.5, [1], 0.5, [0], 0.5, [0], 
1, [3], 0.5, [2], 1, [0], 0.5, [1], 0.5, [3], 
0.5, [2], 0.5, [1], 0.5, [2], 0.5, [0], 1, [0], 
0.5, [1], 1, [0], 0.5, [0], 0.5, [0], 0.5, [1], 
0.5, [3], 0.5, [1], 0.5, [0], 0.5, [1], 0.5, [2], 
0.5, [2], 0.5, [2], 0.5, [3], 0.5, [1], 0.5, [0], 
0.5, [1], 0.5, [3], 0.5, [0, 3]
    ];
    
    private var result_template:Object =
    {
      position: new Vect2(320, 50),
      velocity: new Vect2(0, -3),
      gravity:  new Vect2(0, 0),
      fade:     -0.04,
      alpha:    1,
      drag:     new Vect2(0.9, 0.9)
    };
    
    public function Dance(latency_:Number)
    {
      buildArrowSprites();
    
      latency = latency_;
      var time:Number = 0;
      for(var i:int=0; i<song_data.length; i+=2)
      {
        time+=song_data[i];
        song[time] = [song_data[i+1], false, false];
      }
      
      if(MusicHandler.current_music) MusicHandler.current_music.stop(2);
      light_overlay.filters = [new BlurFilter(16, 16)];
    }
    
    public override function tick():void
    {
      //trace(song_time, Tip.time_since_tip, MusicHandler.current_music);
      if(!playing)
      {
        playing = true;
        MusicHandler.play(Assets.wif, null, 0, false);
        sound_channel = MusicHandler.current_music.channel;
      }
      if(!sound_channel) return;
      
      if(song_time > 72000 && !done)
      {
        done = true;
      }  
      
      for(var i:int=0; i<3; i++)
        lights[i][0] = (lights[i][0]*0.9+lights[i][1]*0.1);
      if(int(song_position) != int((last_position-4800)*151/(1000*60)) && !done)
        for(i=0; i<3; i++)
          lights[i][1] = Input.randBetween(-Math.PI/2, Math.PI/2);

      for each(var k:int in input.keys_down)
        keyDown(k);
      last_input = input;
      
      song_time += 1000/30.0;
      var position:Number = sound_channel.getPosition();
      if(position != last_position && 
         Math.abs(song_time - position) > 50.0)
      {
        trace(song_time, position, last_position);
        song_time = position;
      }
      song_position = (song_time-4800)*151/(1000*60); //+= tempo/scale/60.0;
      last_position = position;
      
      if(song_position > 0) dance_frame++;// = (song_position-(int(song_position)/4*4)) * 6;
      
      if(++last_direction_time > MAXIMUM_FRAMES_BETWEEN_SIMULTANEOUS_KEYS)
        last_direction = -1;
      
      for(var p:String in song)
      {
        if(song[p][2]) continue;
        
        position = Number(p);
        if(position < song_position-hit_state) 
        {
          song[p][2] = true;
          result_template.drawable = miss;
          entities.push(new Particle(result_template));
          combo = 0;
          dance_meter -= 0.1;
          dance_meter_decay *= 1.5;
          if(dance_meter < 0) dance_meter = 0;
          if(dance_meter < 0.25) Tip.addTip("If all else fails, try button-mashing!");
        }
      }
      
      for each(var e:Entity in entities) e.tick();
      for(i=0; i<entities.length; i++)
        if(entities[i].remove) entities.splice(i--, 1);
    }
    
    private function buildArrowSprites():void
    {
      arrow_sprites = [];
      for each(var color:ColorTransform in [new ColorTransform(1, 0, 0), new ColorTransform(1, 1, 0)])
      {
        var color_set:Array = [];
        for each(var rotation:int in [0, 270, 90, 180])
        {
          var rotation_set:Array = [];
          for(var slide:int = 0; slide<16; slide++)
          {
            var image:Image = Image.blank(64, 64);
            var m:Matrix = new Matrix();
            if(rotation == 0)
            {
              m.scale(2, 2);
              m.translate(-slide*4, 0);
            }
            if(rotation == 90)
            {
              m.rotate(rotation*Math.PI/180);
              m.scale(2, 2);
              m.translate(64, -slide*4);
            }
            if(rotation == 180)
            {
              m.scale(-2, 2);
              m.translate(64+slide*4, 0);
            }
            if(rotation == 270)
            {
              m.rotate(rotation*Math.PI/180);
              m.scale(-2, 2);
              m.translate(64, slide*4+64);
            }
            image.bitmapData.draw(Assets.arrowgradient, m, color);
            m = new Matrix();
            m.scale(2, 2);
            m.translate(-32, -32);
            m.rotate(rotation*Math.PI/180);
            m.translate(32, 32);
            image.bitmapData.draw(Assets.arrows.frame(1), m, null, BlendMode.ERASE);
            Assets.arrows.blit(image, 32, 32, 0, false, false, rotation/90, 2);
            rotation_set.push(image);
          }
          color_set.push(rotation_set);
        }
        arrow_sprites.push(color_set);
      }
    }
    
    public override function draw():void
    {
      Display.screen.bitmapData.copyPixels(Assets.debateroom.bitmapData,
        new Rectangle(0, 0, Display.screen_size.x, Display.screen_size.y),
        new Point(0, 0));
      
      var facing_left:Boolean = dance_frame % 24 > 12;
      var frame:int = dance_frame % 12;
      /*Assets.frog_attack.gotoAndStop(frame);
      var matrix:Matrix = new Matrix(1, 0, 0, 1, 10, -70);
      matrix.scale(facing_left?-1:1, 1);
      matrix.translate(320, 420);
      Misc.screen.bitmapData.draw(Assets.frog_attack, matrix);*/
      
      if(!sound_channel)
      {
        //drawArrows();
        return;
      }
      
      light_overlay.bitmapData.fillRect(light_overlay.bitmapData.rect, 0x7f000000);
      var shape:Shape = new Shape();
      var colors:Array = [[1, 0, 0], [0, 1, 0], [0, 0, 1]];
	    for(var i:int=0; i<3; i++)
        for(var j:int=0; j<3; j++)
          if(colors[i][j]==0) colors[i][j] = 0.5 - (song_position - int(song_position))*0.5;
      for(i=0; i<3; i++)
	    {
        shape.graphics.beginFill(Misc.colorFromTriplet(colors[i]), 0.3);
        shape.graphics.moveTo(300, -20);
        shape.graphics.lineTo(340, -20);
        var v:Vect2 = Misc.vectFromAngle(lights[i][0]+Math.PI/2-Math.PI/12).multiply(800).add(new Vect2(320, 0));
        shape.graphics.lineTo(v.x, v.y);
        v = Misc.vectFromAngle(lights[i][0]+Math.PI/2+Math.PI/12).multiply(800).add(new Vect2(320, 0));
        shape.graphics.lineTo(v.x, v.y);
        shape.graphics.endFill();
      }
      light_overlay.bitmapData.draw(shape);
      Display.screen.bitmapData.draw(light_overlay);
      
      /*var beat:int = (song_position-int(song_position))%4;
      var beat_color:Array = [0x808080, 0x202020, 0x404040, 0x202020];
      for(var i:Number=32/scale-song_position; i<Misc.screen_size.y/scale; i++)
      {
        shape.graphics.beginFill(beat_color[beat], 0.8);
        shape.graphics.drawRect(10, i*scale-scale/2, 140, scale);
        beat++;
        beat %= 4;
      }*/
      shape = new Shape();
      shape.graphics.lineStyle(2, 0xffffff, 1);
      shape.graphics.drawRect(318, 3, 284, 24);
      shape.graphics.lineStyle();
      shape.graphics.beginFill(0x00ff00, 1);
      shape.graphics.drawRect(320, 5, 280*dance_meter, 20);
      shape.graphics.endFill();
      Display.screen.bitmapData.draw(shape);

      for(var p:String in song)
      {
        var position:Number = Number(p);
        // if arrow not onscreen, skip
        if(position < song_position-64/scale ||
           position > song_position+(Display.screen_size.y)/scale)
          continue;
        
        var note:Array = song[p];
        // if arrow already hit, skip
        if(note[1]) continue;
        
        for each(var arrow:int in note[0])
        {
/*          var arrow_ss:Spriteset = Assets.arrowsred;
          if(position != int(position)) arrow_ss = Assets.arrowsyellow;
          arrow_ss.draw(Misc.screen, arrow*64+64,
                        (position-song_position)*scale*2+48, arrow, 2, 2);*/
          arrow_sprites[position != int(position)?1:0][arrow][int(song_time)%16].blit(
            Display.screen, new Vect2(arrow*64+32, (position-song_position)*scale*2+16));
            
        }
      }

      drawArrows();

      for each(var e:Entity in entities) e.draw();
      
      if(combo > 5)
        Text.renderTo(Display.screen, combo.toString()+" combo", 300, 50);
    }
    
    private function drawArrows():void
    {  
      var blink_amount:Number = 1.0 - (song_position - int(song_position))/2;
      var blink:ColorTransform = new ColorTransform(blink_amount, blink_amount, blink_amount);
      for(var i:int=0; i<4; i++)
      {
        var bloom_offset:int = 0;
        var reward_blink:ColorTransform = null;
        if(arrow_bloom[i] > 0)
        {
          var amount:Number = arrow_bloom[i]*1.0/BLOOM_FRAMES;
          reward_blink = new ColorTransform(1, 1, 1, amount);
          arrow_bloom[i]--;
          trace(amount);
        }
        Assets.arrowshollow.draw(Display.screen, i*64+64, 48, i,   2, 2, 0, blink);        
        if(reward_blink) Assets.arrowshollow.draw(Display.screen, i*64+64, 48, i+4, 2, 2, 0, reward_blink);        
      } 
    }
    
    protected function keyDown(key:int):void
    {
      var direction:int = -1;
      if(key == Keyboard.LEFT  || key==65)             direction = 0;
      if(key == Keyboard.DOWN  || key==83 || key==79)  direction = 1;
      if(key == Keyboard.UP    || key==87 || key==188) direction = 2;
      if(key == Keyboard.RIGHT || key==68 || key==69)  direction = 3;
      if(direction == -1) return;

      var hit_note:Boolean = false;
      
      for(var p:String in song)
      {
        if(Math.abs(Number(p)-song_position) > hit_state) continue; 
        var note:Array = song[p];
        if(note[0].length == 1 && note[0][0] == direction)
        {
          note[1] = true;
          note[2] = true;
          arrow_bloom[direction] = BLOOM_FRAMES;
        }
        if(note[0].length == 2 &&
           ((note[0][0] == direction && note[0][1] == last_direction) ||
            (note[0][1] == direction && note[0][0] == last_direction)))
        {
          note[1] = true;
          note[2] = true;
          arrow_bloom[direction     ] = BLOOM_FRAMES;
          arrow_bloom[last_direction] = BLOOM_FRAMES;
        }
        
        if(note[1])
        {
          if(Math.abs(int(p)-song_position) < hit_state/3)
            result_template.drawable = perfect;
          else if(Math.abs(int(p)-song_position) < hit_state*2/3)
            result_template.drawable = great;
          else result_template.drawable = good;
          entities.push(new Particle(result_template));
          var offset:Number = (1-dance_meter)/10;
          dance_meter += offset;
          if(dance_meter > 1) dance_meter = 1;
          dance_meter_decay = dance_meter_decay_min;
          combo+=note[0].length;
          
          hit_note = true;
        }
      }
      
      if(hit_note) last_direction = -1;
      else
      {
        last_direction = direction;
        last_direction_time = 0;
      }
    }
  }
}