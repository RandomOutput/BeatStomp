 package  
{
  import flash.events.Event;
  import flash.media.Sound;
  import flash.utils.getTimer;
  import flash.utils.Timer;
  
  public class MusicHandler 
  {
    static public var current_music:MusicHandler;
    
    public var music:Sound, intro:Sound;
    private var loop:Boolean, time:Number;
    public var volume:Number = 1.0;
    public var channel:SoundChannelWrapper;
    
    static public function play(music:Sound, intro:Sound=null, time:Number=0,
      loop:Boolean = true):void
    {
      if(current_music && current_music.music == music &&
         current_music.volume == 1.0) return;
      if(current_music) current_music.stop();
      current_music = new MusicHandler(music, intro, time, loop);
    }
    
    public function MusicHandler(music_:Sound, intro_:Sound = null,
      time_:Number=0, loop_:Boolean = true)
    {
      music = music_;
      intro = intro_;
      loop  = loop_;
      time  = time_;
      if(!intro) playBody();
      else
      {
        channel = new SoundChannelWrapper(intro.play(time), intro);
        channel.whenComplete(playBody);
        time = 0;
      }
      channel.setVolume(1);
    }
    
    public function playBody(e:Event = null):void
    {
      channel = new SoundChannelWrapper(music.play(time, loop?int.MAX_VALUE:0), music);
    }
    
    public function position():Number
    {
      return channel.getPosition();
    }
    
    public function duck(time:Number = 0.3, to:Number = 0.3):void
    {
      var start_time:Number = Input.time();
      Main.fuses.add(new Fuse(1, "duck",
        function():void
        {
          if(handleFade(channel, volume, to, start_time, time)) Fuse.retrigger(1);
          else volume = to;
        }));
    }
    
    public function stop(time:Number=1):void
    {
      current_music = null;
      if(time==0) channel.stop();
      fade(time, volume, 0);
    }
    
    public function fade(time:Number=1, from:Number=0, to:Number=1):void
    {
      volume = from;
      channel.setVolume(volume);
      var start_time:Number = Input.time();
      Main.fuses.add(new Fuse(1, "fade",
        function():void
        {
          if(handleFade(channel, from, to, start_time, time)) Fuse.retrigger(1);
        }));
    }
    
    public function handleFade(ch:SoundChannelWrapper, from:Number, to:Number, start_time:Number,
      length:Number):Boolean
    {
      var time:Number = Input.time();
      var retrigger:Boolean = true;
      var new_volume:Number = 0;
      
      if(time-start_time > length)
      {
        retrigger = false;
        new_volume = to;
      }
      else
      {
        var position:Number = (time-start_time) / length;
        new_volume = from*(1-position)+to*position;
      }
      
      //trace(position, from, to, new_volume);
      
      if(new_volume <= 0) 
      {
        ch.cancelWhenComplete();
        ch.stop();
      }
      else ch.setVolume(new_volume);
      volume = new_volume;
      
      return retrigger;
    }
  }
}