package  
{
  import flash.media.*;
  
  public class Soundset 
  { 
    private var m_sounds:Array;
    
    public function Soundset(sounds:Array) 
    {
      m_sounds = sounds;
    }
    
    public function play(n:int, volume:Number=1):SoundChannel
    {
      var sound_channel:SoundChannel = m_sounds[n].play();
      if(volume!=1) sound_channel.soundTransform = new SoundTransform(volume);
      return sound_channel;
    }
    
    public function playRandom(volume:Number=1):SoundChannel
    {
      return play(int(Input.rand()*m_sounds.length), volume);
    }
  }
}