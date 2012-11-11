import struct
import sys

def byte2int(byte):
  return struct.unpack('B', byte)[0]

def bytes2ints(bytes):
  return [byte2int(b) for b in bytes]

def twoBytes2Int(bb):
  return 256*byte2int(bb[0]) + byte2int(bb[1])

def fourBytes2Int(bb):
  assert( len(bb) == 4 )
  return struct.unpack('>I', bb)[0]

class Chunk:
  def __init__(_, data):
    _.data = data
    _.pos = 0
  
  def done(_):
    return _.pos >= len(_.data)
  
  def readVariableLength(_):
    val = 0
    while True:
      byte = _.unpack("B", 1)[0]
      val = (val << 7) + (byte & 0x7F)
      if byte & 0x80 == 0: return val
  
  def unpack(_, fmt, size):
    s = _.data[_.pos:_.pos+size]
    assert len(s) == size
    _.pos += size
    return struct.unpack(fmt, s)
  
  def skip(_, size):
    _.pos += size
    assert _.pos <= len(_.data)

def readHeader(fi):
  header = fi.read(4)
  print header
  assert header == "MThd"
  remainSize = bytes2ints(fi.read(4))
  print remainSize
  assert remainSize == [0,0,0,6]

  print 'midi fmt', twoBytes2Int(fi.read(2))
  ntracks = twoBytes2Int(fi.read(2))
  print '# tracks', ntracks
  nticks = twoBytes2Int(fi.read(2))
  if nticks & 0x8000:
    frames_per_sec = (nticks & 0x7fff)
    
  print 'ticks per quarter', nticks

  return (ntracks, nticks)
  
def readTrack(fi):
  header = fi.read(4)
  assert header == "MTrk"

  # read 4 bytes of length
  length = fourBytes2Int(fi.read(4))
  print "length ", length
  chunk = Chunk(fi.read(length))

  time = 0.0
  time_signature = (4, 4, 24, 8)
  clocks_per_beat = 24
  tempo = 120
  
  output = ""
  last_time = 0
  n = 0
  
  while not chunk.done():  
    delta = chunk.readVariableLength()
    time += delta

    event = chunk.unpack("B", 1)[0]

    if event & 0xf0 == 0xd0:
      pass #aftertouch
    elif event == 0xff:
      subevent = chunk.unpack("B", 1)[0]
      length = chunk.readVariableLength()
      if subevent == 0x58:
        time_signature = chunk.unpack("4B", length)
        clocks_per_beat = time_signature[3]
        print "time signature ", time_signature
      if subevent == 0x51:
        tempo = chunk.unpack(">BH", 3)
        tempo = 60*1000000.0 / ((tempo[0]<<16) + tempo[1])
        print "tempo ", tempo
      else: chunk.skip(length)
      #print "skipped meta event ", subevent, " length ", length
    elif event & 0xf0 == 0x90:
      channel = event & 0x0f
      note, velocity = chunk.unpack("BB", 2)
      if time != last_time:
        if last_time != 0:
          output += "], "  
          n += 1
          if n > 4:
            n = 0
            output += "\n"
        output += "%g, [" % (float(time-last_time)/clocks_per_beat/4)
      else:
        output += ", "
      output += "%d" % (note-72)
      last_time = time
      #print output, " -- ", time/clocks_per_beat, " note on: ", channel, note, velocity
      #output = ""
    elif event & 0xf0 == 0x80:
      channel = event & 0x0f
      note, velocity = chunk.unpack("BB", 2)
      #print time/clocks_per_beat, "note off: ", channel, note, velocity
    elif event & 0xf0 == 0xb0:
      channel = event & 0x0f
      cc, value = chunk.unpack("BB", 2)
      #print "cc: ", channel, cc, value
    elif event & 0xf0 == 0xe0:
      channel = event & 0x0f
      pitch = chunk.unpack("<H", 2)[0]
      #print "pitch wheel: ", channel, pitch
    else: print "unknown event ", hex(event)
  if output != "": print output+"]"

def main():
  fi = open(sys.argv[1], "rb")

  tracks, time_division = readHeader(fi)
  for track in xrange(tracks):
    print "reading track", track
    readTrack(fi)
    
  fi.close()
  
if __name__ == "__main__": main()

"""
while True:
  s = fi.read(16)
  if len(s) == 0: break
  op = ""
  v = struct.unpack("%dB"%len(s), s)
  for c in v:
    h = hex(c)[-2:]
    if h[0] == "x": h = "0"+h[1]
    op += h + " "
  op += "   "*(16-len(s))
  for c in v:
    if c < 32 or c > 127: op += "."
    else: op += chr(c)
  print op
fi.close()
"""