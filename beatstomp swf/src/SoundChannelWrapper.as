package  
{
  import flash.events.Event;
  import flash.media.*;
  
  public class SoundChannelWrapper 
  {
    private var sound_channel:SoundChannel;
    private var position:Number = -1;
    private var length:Number = 0;
    private var id:int = 0;
    private var complete_callback:Function = null;
    private var volume:Number = 1, panning:Number = 0;
    private static var next_id:int = 0;
    
    public function SoundChannelWrapper(sc:SoundChannel, sound:Sound)
    {
      sound_channel = sc;
      if(!sound_channel)
      {
        id = next_id++;
        position = 0;
        length = sound.length;
        Main.fuses.add(new Fuse(1, "soundchannel_handler"+id.toString(), function():void
          {
            position += 1000.0/30;
            if(position >= length) 
            {
              stop();
              if(complete_callback!=null) complete_callback(null);
            }
            else Fuse.retrigger(1);
          }));
      }
    }
    
    static public function play(s:Sound, start_time:Number=0, loops:int=0,
      volume:Number=1):SoundChannelWrapper
    {
      return new SoundChannelWrapper(s.play(start_time, loops,
        new SoundTransform(volume)), s);
    }
    
    public function whenComplete(callback:Function):void
    {
      if(sound_channel) sound_channel.addEventListener(Event.SOUND_COMPLETE, callback);
      complete_callback = callback;
    }
    
    public function cancelWhenComplete():void
    {
      if(sound_channel && complete_callback!=null)
        sound_channel.removeEventListener(Event.SOUND_COMPLETE, complete_callback);
      complete_callback = null;
    }
    
    public function setVolume(volume_:Number):void
    {
      volume = volume_;
      if(sound_channel) sound_channel.soundTransform = new SoundTransform(volume, panning);
    }
    
    public function getPosition():Number
    {
      if(sound_channel) return sound_channel.position;
      return position;
    }
    
    public function stop():void
    {
      if(sound_channel) sound_channel.stop();
      Main.fuses.cancel("soundchannel_handler"+id.toString());
      position = -1;
    }
  }
}