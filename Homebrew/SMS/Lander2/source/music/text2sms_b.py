#! /usr/bin/python3

#Copyright 2013-2014 jmimu (jmimu@free.fr)
#Converts string representing music into asm declaration for sega master system (to use with jmimu's code)
#music representation: note-octave-alteration-duration-volume
#examples "g3_0017F", "f5#00058"
#  note: a to f
#  octave: 1 to 7, octave changes after b!
#  alteration: "_" or "#"
#  previous durations : q,t,h,1,p,2,3,4 (quarter,third, half, 1 time, pointed (1.5), 2 times, 3 times, 4 times)
#  durations are written in 4  decimal digits representing 12th of beat
#  volume: one hex (uppercase) value, 0 = nosound, F = max
#  vibrato: ~ at the end (freq and amplitude fixed, make 3 notes with variation of frequence in asm)
#every note is 5-char long. => todo: enable fast notation!
#For pause : "Ppp"+duration+volume (volume is unused)
#For end : "End"+duration+volume (duration and volume is unused)

#TODO : make echo, add output volume parameter

fps=60

#interpret_melody() automatically creates volume enveloppe  for each note, using this parameter:

pseudo_frame_size=2 #to minimize memory used


tempo=120
time_unit=60*fps/tempo/12 #number of frames for one 12th of a time


#ADSR envelop (duration is in frames = time*time_unit*12)
attack_duration=(12*time_unit)/4
decay_duration=(12*time_unit)/10
sustain_ratio=0.8
release_duration=(12*time_unit)/4
#(release is only if pause after the note)


print("ADSR: ",attack_duration," ",decay_duration," ",sustain_ratio," ",release_duration)

SMS_NTSC_str={
"Ppp":"$00,$00","End":"$ff,$ff","a1_":"$03,$f9","a1#":"$03,$c0","b1_":"$03,$8a","c2_":"$03,$57","c2#":"$03,$27","d2_":"$02,$fa","d2#":"$02,$cf","e2_":"$02,$a7","f2_":"$02,$81","f2#":"$02,$5d","g2_":"$02,$3b","g2#":"$02,$1b","a2_":"$01,$fc","a2#":"$01,$e0","b2_":"$01,$c5","c3_":"$01,$ac","c3#":"$01,$94","d3_":"$01,$7d","d3#":"$01,$68","e3_":"$01,$53","f3_":"$01,$40","f3#":"$01,$2e","g3_":"$01,$1d","g3#":"$01,$0d","a3_":"$00,$fe","a3#":"$00,$f0","b3_":"$00,$e2","c4_":"$00,$d6","c4#":"$00,$ca","d4_":"$00,$be","d4#":"$00,$b4","e4_":"$00,$aa","f4_":"$00,$a0","f4#":"$00,$97","g4_":"$00,$8f","g4#":"$00,$87","a4_":"$00,$7f","a4#":"$00,$78","b4_":"$00,$71","c5_":"$00,$6b","c5#":"$00,$65","d5_":"$00,$5f","d5#":"$00,$5a","e5_":"$00,$55","f5_":"$00,$50","f5#":"$00,$4c","g5_":"$00,$47","g5#":"$00,$43","a5_":"$00,$40","a5#":"$00,$3c","b5_":"$00,$39","c6_":"$00,$35","c6#":"$00,$32","d6_":"$00,$30","d6#":"$00,$2d","e6_":"$00,$2a","f6_":"$00,$28","f6#":"$00,$26","g6_":"$00,$24","g6#":"$00,$22","a6_":"$00,$20","a6#":"$00,$1e","b6_":"$00,$1c","c7_":"$00,$1b","c7#":"$00,$19","d7_":"$00,$18","d7#":"$00,$16","e7_":"$00,$15","f7_":"$00,$14","f7#":"$00,$13","g7_":"$00,$12","g7#":"$00,$11"}


SMS_PAL_str ={
"Ppp":"$00,$00","End":"$ff,$ff","a1_":"$03,$f0","a1#":"$03,$b7","b1_":"$03,$82","c2_":"$03,$4f","c2#":"$03,$20","d2_":"$02,$f3","d2#":"$02,$c9","e2_":"$02,$a1","f2_":"$02,$7b","f2#":"$02,$57","g2_":"$02,$36","g2#":"$02,$16","a2_":"$01,$f8","a2#":"$01,$dc","b2_":"$01,$c1","c3_":"$01,$a8","c3#":"$01,$90","d3_":"$01,$79","d3#":"$01,$64","e3_":"$01,$50","f3_":"$01,$3d","f3#":"$01,$2c","g3_":"$01,$1b","g3#":"$01,$0b","a3_":"$00,$fc","a3#":"$00,$ee","b3_":"$00,$e0","c4_":"$00,$d4","c4#":"$00,$c8","d4_":"$00,$bd","d4#":"$00,$b2","e4_":"$00,$a8","f4_":"$00,$9f","f4#":"$00,$96","g4_":"$00,$8d","g4#":"$00,$85","a4_":"$00,$7e","a4#":"$00,$77","b4_":"$00,$70","c5_":"$00,$6a","c5#":"$00,$64","d5_":"$00,$5e","d5#":"$00,$59","e5_":"$00,$54","f5_":"$00,$4f","f5#":"$00,$4b","g5_":"$00,$47","g5#":"$00,$43","a5_":"$00,$3f","a5#":"$00,$3b","b5_":"$00,$38","c6_":"$00,$35","c6#":"$00,$32","d6_":"$00,$2f","d6#":"$00,$2d","e6_":"$00,$2a","f6_":"$00,$28","f6#":"$00,$25","g6_":"$00,$23","g6#":"$00,$21","a6_":"$00,$1f","a6#":"$00,$1e","b6_":"$00,$1c","c7_":"$00,$1a","c7#":"$00,$19","d7_":"$00,$18","d7#":"$00,$16","e7_":"$00,$15","f7_":"$00,$14","f7#":"$00,$13","g7_":"$00,$12","g7#":"$00,$11"}

SMS_NTSC={
"Ppp":"0000","End":"ffff","a1_":"03f9","a1#":"03c0","b1_":"038a","c2_":"0357","c2#":"0327","d2_":"02fa","d2#":"02cf","e2_":"02a7","f2_":"0281","f2#":"025d","g2_":"023b","g2#":"021b","a2_":"01fc","a2#":"01e0","b2_":"01c5","c3_":"01ac","c3#":"0194","d3_":"017d","d3#":"0168","e3_":"0153","f3_":"0140","f3#":"012e","g3_":"011d","g3#":"010d","a3_":"00fe","a3#":"00f0","b3_":"00e2","c4_":"00d6","c4#":"00ca","d4_":"00be","d4#":"00b4","e4_":"00aa","f4_":"00a0","f4#":"0097","g4_":"008f","g4#":"0087","a4_":"007f","a4#":"0078","b4_":"0071","c5_":"006b","c5#":"0065","d5_":"005f","d5#":"005a","e5_":"0055","f5_":"0050","f5#":"004c","g5_":"0047","g5#":"0043","a5_":"0040","a5#":"003c","b5_":"0039","c6_":"0035","c6#":"0032","d6_":"0030","d6#":"002d","e6_":"002a","f6_":"0028","f6#":"0026","g6_":"0024","g6#":"0022","a6_":"0020","a6#":"001e","b6_":"001c","c7_":"001b","c7#":"0019","d7_":"0018","d7#":"0016","e7_":"0015","f7_":"0014","f7#":"0013","g7_":"0012","g7#":"0011"}


SMS_PAL ={
"Ppp":"0000","End":"ffff","a1_":"03f0","a1#":"03b7","b1_":"0382","c2_":"034f","c2#":"0320","d2_":"02f3","d2#":"02c9","e2_":"02a1","f2_":"027b","f2#":"0257","g2_":"0236","g2#":"0216","a2_":"01f8","a2#":"01dc","b2_":"01c1","c3_":"01a8","c3#":"0190","d3_":"0179","d3#":"0164","e3_":"0150","f3_":"013d","f3#":"012c","g3_":"011b","g3#":"010b","a3_":"00fc","a3#":"00ee","b3_":"00e0","c4_":"00d4","c4#":"00c8","d4_":"00bd","d4#":"00b2","e4_":"00a8","f4_":"009f","f4#":"0096","g4_":"008d","g4#":"0085","a4_":"007e","a4#":"0077","b4_":"0070","c5_":"006a","c5#":"0064","d5_":"005e","d5#":"0059","e5_":"0054","f5_":"004f","f5#":"004b","g5_":"0047","g5#":"0043","a5_":"003f","a5#":"003b","b5_":"0038","c6_":"0035","c6#":"0032","d6_":"002f","d6#":"002d","e6_":"002a","f6_":"0028","f6#":"0025","g6_":"0023","g6#":"0021","a6_":"001f","a6#":"001e","b6_":"001c","c7_":"001a","c7#":"0019","d7_":"0018","d7#":"0016","e7_":"0015","f7_":"0014","f7#":"0013","g7_":"0012","g7#":"0011"}


class Note(object):
  def __init__(self,_text,_SMS_norm):
    self.text=_text
    item=self.text.strip()
    self.tone_str=item[0:3]
    self.tone=int(_SMS_norm[self.tone_str],16)
    self.duration=int(item[3:7],10)*time_unit
    self.volume=int(item[7],16)

"""
  The melody is interpreted as an analog function, stored as (time,volume,note) 
  The function is linear between the store points
  and its mean value is computed for every pseudo-frame
"""
#TODO: add > and ~
class Melody(object):
  def __init__(self,_name,_SMS_norm):
    self.name=_name
    self.SMS_norm=_SMS_norm
    self.melodytext=""
    self.length=0
    self.all_notes=[]
    self.analog_function=[] #(time,volume,note)
    self.sampled_function=[] #(volume,note)
    self.compressed_function=[] #(duration,volume,note)
  def interpret(self,_melodytext):
    self.melodytext=_melodytext
    self.length=0
    self.all_notes=[]
    self.analog_function=[]
    current_time=0
    for item in self.melodytext.split():
      self.all_notes.append(Note(item,self.SMS_norm))
    i=0
    while (i<len(self.all_notes)):
      note=self.all_notes[i]
      start_current_time=current_time
      print("item : ",note.text,note.tone,self.SMS_norm[note.tone_str],note.duration)
      
      #if pause
      if (self.all_notes[i].tone_str=="Ppp"):
        current_time+=note.duration
        self.analog_function.append( (current_time,0,note.tone) )
      else:
        #check if note is long enougth
        if (note.duration<attack_duration+decay_duration):
          #print("Error! ",note.text," is too short for ADSR!!!")
          #print(note.duration,"<",attack_duration+decay_duration)
          #add first point of the note (volume 0)
          self.analog_function.append( (current_time,0,note.tone) )
          ##add immediatly a second point with 50% volume
          #self.analog_function.append( (current_time,note.volume*0.5,note.tone) )
          #add end of note
          current_time+=note.duration
          self.analog_function.append( (current_time,note.volume,note.tone) )
          #if next is a pause, add release time
          if ((i<len(self.all_notes)-1) and (self.all_notes[i+1].tone_str=="Ppp")):
            if (self.all_notes[i+1].duration>release_duration):
              current_time+=release_duration
              self.analog_function.append( (current_time,0,note.tone) )
              #add the remaining pause time
              current_time+=self.all_notes[i+1].duration-release_duration
            else:
              current_time+=self.all_notes[i+1].duration
              self.analog_function.append( (current_time,0,note.tone) )
            i+=1
        else:
        
          #add first point of the note (volume 0)
          self.analog_function.append( (current_time,0,note.tone) )
          #add end of attack
          current_time+=attack_duration
          self.analog_function.append( (current_time,note.volume,note.tone) )
          #add end of decay
          current_time+=decay_duration
          self.analog_function.append( (current_time,note.volume*sustain_ratio,note.tone) )
          #add end of note
          current_time+=note.duration-attack_duration-decay_duration
          self.analog_function.append( (current_time,note.volume*sustain_ratio,note.tone) )
          #if next is a pause, add release time
          if ((i<len(self.all_notes)-1) and (self.all_notes[i+1].tone_str=="Ppp")):
            if (self.all_notes[i+1].duration>release_duration):
              current_time+=release_duration
              self.analog_function.append( (current_time,0,note.tone) )
              #add the remaining pause time
              current_time+=self.all_notes[i+1].duration-release_duration
            else:
              current_time+=self.all_notes[i+1].duration
              self.analog_function.append( (current_time,0,note.tone) )
            i+=1
      i+=1
    self.length=current_time
    print(self.analog_function)
      
    
  def setLength(self,aim_length):
    #TODO?: if longer than release, add release then pause?
    if (self.length>aim_length):
      print("Error: can't melody sound be smaller than ",self.length)
    else:
      if (aim_length-self.length<release_duration):
        self.length=aim_length
        self.analog_function.append( (self.length,0,self.analog_function[-1][2]) )
      else:
        self.length+=release_duration
        self.analog_function.append( (self.length,0,self.analog_function[-1][2]) )
        self.length=aim_length
        self.analog_function.append( (self.length,0,self.analog_function[-1][2]) )
    
  def sampling(self):
    self.sampled_function=[]
    self.compressed_function=[]
    nbr_samples=int(self.length/pseudo_frame_size)
    analog_ptr=0
    for i in range(nbr_samples):
      sample_middle=(i+0.5)*pseudo_frame_size
      while (self.analog_function[analog_ptr][0]<sample_middle):
        analog_ptr+=1
      #take the value of the fonction at sample_middle (TODO: integration?)
      analog_before=self.analog_function[analog_ptr-1]
      analog_after=self.analog_function[analog_ptr]
      sampled_value=int(((analog_after[1]-analog_before[1])*(sample_middle-analog_before[0])/(analog_after[0]-analog_before[0])+analog_before[1])+0.5)
      sampled_tone=int(((analog_after[2]-analog_before[2])*(sample_middle-analog_before[0])/(analog_after[0]-analog_before[0])+analog_before[2])+0.5)
      self.sampled_function.append((sampled_value,sampled_tone))
    print(self.sampled_function)
    self.compressSampled()
      
  def compressSampled(self):
    if (len(self.sampled_function)==0):
      print("ERROR, execute 'sampling' first")
      return
    self.compressed_function=[]
    #if sampled_function has severel times the same value put in only once
    last_sample=None
    last_sample_duration=0
    for sample in self.sampled_function :
      if (last_sample==None):
        last_sample=sample
        last_sample_duration=1
        continue
      if ((last_sample[0]==sample[0]) and (sample[0]==0 or  (last_sample[1]==sample[1]) )):
        last_sample_duration+=1
        continue
      self.compressed_function.append((last_sample_duration,last_sample[0],last_sample[1]))
      last_sample=sample
      last_sample_duration=1
    self.compressed_function.append((last_sample_duration,last_sample[0],last_sample[1]))
    print(self.compressed_function)
    
    
  def toASM(self):
    if (len(self.compressed_function)==0):
      print("ERROR, execute 'sampling' first")
      return
    output=self.name+"_start:\n  .db "
    for sample in self.compressed_function :
      tone_str="$"+("{:#04x}".format(int(sample[2]/256)))[2:]+",$"+("{:#04x}".format(sample[2]%256))[2:]
      volume_str="$"+("{:#04x}".format(15-sample[1]))[2:]
      duration=sample[0]*pseudo_frame_size
      while (duration>255):
        frames_str="$"+("{:#04x}".format(255))[2:]
        output+="{},{},{}, ".format(tone_str,frames_str,volume_str)
        duration-=255
      if (duration>0):
        frames_str="$"+("{:#04x}".format(duration))[2:]
        output+="{},{},{}, ".format(tone_str,frames_str,volume_str)
    
    output+="$ff,$ff"+"\n  ;total {} frames\n{}_end:\n".format(self.length,self.name)
    return output

#a corriger : tone interpole si pause !



if __name__ == '__main__':
  

  
  test1="f3_0017A f3_0006A a3_0012A f3_0012A e3_0023A a3_0006A Ppp0017F d3_0017A d3_0006A f3_0012A d3_0012A c3_0023A Ppp0023F a2#0017A a2#0006A c3_0012A a2#0012A a2_0023A f3_0023A e3_0017A e3_0006A f3_0012A g3_0012A f3_0023A "
  #test2="f4_00067 a4_00067 c5_00067 a4_00067 f4_00067 a4_00067 c5_00067 a4_00067 e4_00067 a4_00067 c5_00067 a4_00067 e4_00067 a4_00067 c5_00067 a4_00067 d4_00067 f4_00067 a4_00067 f4_00067 d4_00067 f4_00067 a4_00067 f4_00067 c4_00067 f4_00067 a4_00067 f4_00067 c4_00067 f4_00067 a4_00067 f4_00067 a3#00067 d4_00067 f4_00067 d4_00067 a3#00067 d4_00067 f4_00067 d4_00067 a3_00067 c4_00067 f4_00067 c4_00067 a3_00067 c4_00067 f4_00067 c4_00067 g3_00067 c4_00067 f4_00067 c4_00067 g3_00067 c4_00067 f4_00067 c4_00067 f3_00067 a3_00067 c4_00067 f4_00067 a4_00067 c5_00067 f5_00117 "
  test2="  f3_00067 a3_00067 c4_00067 a3_00067 f3_00067 a3_00067 c4_00067 a3_00067 e3_00067 a3_00067 c4_00067 a3_00067 e3_00067 a3_00067 c4_00067 a3_00067 d3_00067 f3_00067 a3_00067  f3_00067 d3_00067 f3_00067 a3_00067 f3_00067 c3_00067 f3_00067 a3_00067 f3_00067 c3_00067 f3_00067 a3_00067 f3_00067 a2#00067 d3_00067 f3_00067 d3_00067 a2#00067 d3_00067  f3_00067 d3_00067 a2_00067 c3_00067 f3_00067 c3_00067 a2_00067 c3_00067 f3_00067 c3_00067 g2_00067 c3_00067 f3_00067 c3_00067 g2_00067 c3_00067 f3_00067 c3_00067 f2_00067  a2_00067 c3_00067 f3_00067 a3_00067 c4_00067 f4_00117 "
  test3="f3_00177 c5_00037 d5_00037 c5_00037 Ppp0037F c5_00037 d5_00037 c5_00037 Ppp0037F a4_00037 a4#00037 a4_00037 Ppp0037F a4_00037 a4#00037 a4_00037 Ppp0037F a4_00037 a4#00037 a4_00037 Ppp0037F f4_00037 g4_00037 f4_00037 Ppp0037F c5_00037 d5_00037 c5_00037"
  
  melody1=Melody("end_music_ch1",SMS_NTSC)
  melody1.interpret(test1)
  print("melody1.length: ",melody1.length)
  melody1.setLength(1000)
  melody1.sampling()
  
  melody2=Melody("end_music_ch2",SMS_NTSC)
  melody2.interpret(test2)
  print("melody2.length: ",melody2.length)
  melody2.setLength(1000)
  melody2.sampling()
  
  melody3=Melody("end_music_ch3",SMS_NTSC)
  melody3.interpret(test3)
  print("melody3.length: ",melody3.length)
  melody3.setLength(1000)
  melody3.sampling()
  
  
  print(melody1.toASM())
  print(melody2.toASM())
  print(melody3.toASM())
  

  import numpy as np
  import matplotlib.pyplot as plt
  npfunction=np.array(melody1.analog_function)
  t=npfunction[:,0]
  v=npfunction[:,1]
  n=npfunction[:,2]/50
  
  npfunction_compr=np.array(melody3.sampled_function)
  t2=np.arange(len(melody1.sampled_function))*pseudo_frame_size
  v2=npfunction_compr[:,0]
  n2=npfunction_compr[:,1]/50
  plt.plot(t, v, '-')
  #plt.plot(t, n, '-')
  plt.plot(t2, v2, '-')
  #plt.plot(t2, n2, '-')
  #plt.bar(t2, v2,pseudo_frame_size,color='r',edgecolor='r')
  plt.show()
  
  
  melody4=Melody("demo4_music_ch1",SMS_NTSC)
  melody4.interpret("e3_0011a g3_0006a f3_0017a e3_0012a a3_0006a g3_0017a e3_0012a g3_0006a f3_0017a a3_0012a g3_0006a e3_0017a c3_0017a d3_0040a Ppp0012F e3_0012a g3_0006a f3_0017a e3_0012a a3_0006a g3_0017a e3_0012a g3_0006a f3_0017a a3_0012a g3_0006a e3_0017a d3_0017a c3_0040a Ppp0012F c3_0006a d3_0006a e3_0006a f3_0006a g3_0006a a3_0006a b3_0035a c4_0011a Ppp0012F c3_0011a ")
  print("melody4.length: ",melody4.length)
  melody4.setLength(1000)
  melody4.sampling()
  
  melody5=Melody("demo4_music_ch2",SMS_NTSC)
  melody5.interpret("a2_0035a g2_0035a a2_0035a b2_0035a g2_0058a Ppp0012F a2_0035a g2_0035a a2_0035a b2_0035a g2_0058a ")
  print("melody5.length: ",melody5.length)
  melody5.setLength(1000)
  melody5.sampling()

  print(melody4.toASM())
  print(melody5.toASM())






