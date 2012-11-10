 package  
{
  import flash.events.Event;
  import flash.media.Sound;
  import flash.media.SoundChannel;
  import flash.media.SoundTransform;
  
  public class MusicHandler 
  {
    static public var current_music:MusicHandler = null;
    
    public var music:Sound, intro:Sound;
    private var loop:Boolean, time:Number;
    private var volume:Number = 1.0;
    public var channel:SoundChannel;
    private var fade_amount:Number = 0;
    
    static public function play(music:Sound, intro:Sound=null, time:Number=0,
      loop:Boolean = true):void
    {
      if(current_music && current_music.music == music) return;
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
        channel = intro.play(time);
        time = 0;
        if(channel) channel.addEventListener(Event.SOUND_COMPLETE, playBody);
      }
      if(channel) channel.soundTransform = new SoundTransform(1, 0);
    }
    
    public function playBody(e:Event = null):void
    {
      channel = music.play(time, loop?int.MAX_VALUE:0);
    }
    
    public function position():Number
    {
      return channel.position;
    }
    
    public function stop(time:Number=1):void
    {
      current_music = null;
      if(time==0) channel.stop();
      else
      {
        fade_amount = -1.0/(time*30);
        Main.fuses.add(new Fuse(1, "fade",
          function():void { if(fade(fade_amount)) Fuse.retrigger(1); }));
      }
    }
    
    public function fadeIn(time:Number=1):void
    {
      channel.soundTransform = new SoundTransform(0);
      fade_amount = 1.0/(time*30);
      Main.fuses.add(new Fuse(1, "fade",
        function():void { if(fade(fade_amount)) Fuse.retrigger(1); }));
    }
    
    public function setVolume(volume_:Number):void
    {
      volume = volume_;
      channel.soundTransform =  new SoundTransform(volume);
    }
    
    public function fade(amount:Number):Boolean
    {
      setVolume(volume+amount);
      if(volume <= 0 || volume >= 1)
      {
        if(amount < 0) channel.stop();
        return false;
      }
      return true;
    }
  }
}