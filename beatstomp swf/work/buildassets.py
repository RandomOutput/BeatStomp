import os
import sys

dest_path = "../src/assets"
sprite_path = "art"
sound_path = "sounds"

movieclips = \
{
#  "frog_attack": "clip_FrogAttack",
}

images = \
[
  "arrow"
]

spritesets = \
{
  "shards": 64
}

sounds = \
[
  "wif", "electro", "jump_around", "wwry"
]

soundsets = \
[
]

def mung(s):
  return s.replace("-", "").replace(" ", "").replace(".Jpg", "").replace(".jpg", "")

def header():
  return """
/* Generated code! */
package
{
  import flash.display.*;
  import flash.media.*;
  
  public class Assets
  { """

def footer():
  return """
  }
} """

def clipList(clips):
  s = ""
  for name in clips.keys():
    clip = clips[name]
    s += """
    public static const %s:MovieClip = new %s();""" % (name, clip)
  return s

def addExtension(fn):
  if "." in fn: return fn
  return fn + ".png"

def imageList(images):
  s = ""
  path_prefix = sprite_path
  for image in images:
    s += """
    [Embed (source="assets/%s")] private static const %s:Class;
    public static const %s:Image = new Image(new %s().bitmapData);""" % \
    (addExtension(image.lower()), mung(image.title()), mung(image.lower()), mung(image.title()))
    os.system("cp \"%s/%s\" %s" % (path_prefix, addExtension(image), dest_path))
  return s
  
def spritesetList(sets):
  s = ""
  for name in sets.keys():
    width = sets[name]
    s += """
    [Embed(source = "assets/%s")] public static const %s:Class;
    public static const %s:Spriteset = new Spriteset(new %s(), %d);
      """ % (addExtension(name), mung(name.title()), mung(name), mung(name.title()), width)
    os.system("cp \"%s/%s\" %s" % (sprite_path, addExtension(name), dest_path))
  return s 

def soundsetList(sets):
  s = ""
  for path in sets:
    n = 0
    classes = []
    for file in os.listdir("%s/%s" % (sound_path, path)):
      if not file.lower().endswith(".wav"): continue
      mp3 = file[:-4]+".mp3"
      s += "    [Embed(source = \"assets/%s_%s\")] public static const %s%d:Class;\n" % \
           (mung(path), mp3, mung(path.title()), n)
      classes.append("%s%d" % (mung(path.title()), n))
      n += 1
      os.system("bladeenc -64 -quiet \"%s/%s/%s\" \"%s/%s_%s\"" % (sound_path, path, file, dest_path, mung(path), mp3))
    s += "    public static const %s:Soundset = new Soundset([%s]);\n" % \
        (mung(path), ", ".join(["new %s()"%c for c in classes]))
  return s

def soundList(sounds):
  s = ""
  for sound in sounds:
    s += """
    [Embed(source = \"assets/%s.mp3\")] public static const %s:Class;
    public static const %s:Sound = new %s();""" % \
    (sound, mung(sound.title()), mung(sound), mung(sound.title()))
    os.system("cp \"%s/%s.mp3\" \"%s/%s.mp3\"" % (sound_path, sound, dest_path, sound))
  return s
  
if __name__ == "__main__":
  os.system("rm %s/*" % dest_path)
  print header()
  print clipList(movieclips)
  print imageList(images)
  print spritesetList(spritesets)
  print soundList(sounds)
  print soundsetList(soundsets)
  print footer()
