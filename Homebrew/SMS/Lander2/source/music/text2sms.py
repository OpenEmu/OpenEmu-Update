#! /usr/bin/python

#Copyright 2013-2014 jmimu (jmimu@free.fr)
#Converts string representing music into asm declaration for sega master system (to use with jmimu's code)
#music representation: note-octave-alteration-duration-volume
#examples "g3_1F", "f5#h8"
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

#~ durations={"q":3,"t":4,"h":6,"1":12,"p":18,"2":24,"3":36,"4":48}

fps=60

#interpret_melody() automatically creates volume enveloppe (only attack) for each note, using this parameter:

vibrato_period=12/3
vibrato_amplitude=1 #freq variation

#TODO: make the ADSR frames longer to compensate frames_step
frames_step=1 #to minimize memory used

#ADSR envelop (frames, frames, ratio of volume, frames)
ADSR_envelop=(fps/10,fps/60,0.8,fps/25)
print "ADSR_envelop: ",ADSR_envelop
attack_frames=ADSR_envelop[0]
decay_frames=ADSR_envelop[1]
sustain_ratio=ADSR_envelop[2]
release_frames=ADSR_envelop[3]

#TODO: for drums there is no sustain?

#todo: add attack and end (remove their duration), declare instrument [0.2, 0.7, 1] [0.5] ?
#link: >+duration (make as many intermediate notes as there are frames in duration. interpolation of freq and volume) Able to link many notes
#enable fast notation : abcd (same octave, same len), only allowed to remove ending data !

#todo: make all adsr envelope (r only if pause after the note)

tempo=120


frames_for_1_beat=fps/(tempo/60.0)
frame_beat_factor=frames_for_1_beat/12.0 #multiply duration with beat_factor to get a number of frames
print frames_for_1_beat
print frame_beat_factor

drums={
"Ppp":"%00001111","End":"%11111111","c3_":"%0111","d3_":"%0110","e3_":"%0101","f3_":"%0100"
}

SMS_NTSC={
"Ppp":"$00,$00","End":"$ff,$ff","a1_":"$03,$f9","a1#":"$03,$c0","b1_":"$03,$8a","c2_":"$03,$57","c2#":"$03,$27","d2_":"$02,$fa","d2#":"$02,$cf","e2_":"$02,$a7","f2_":"$02,$81","f2#":"$02,$5d","g2_":"$02,$3b","g2#":"$02,$1b","a2_":"$01,$fc","a2#":"$01,$e0","b2_":"$01,$c5","c3_":"$01,$ac","c3#":"$01,$94","d3_":"$01,$7d","d3#":"$01,$68","e3_":"$01,$53","f3_":"$01,$40","f3#":"$01,$2e","g3_":"$01,$1d","g3#":"$01,$0d","a3_":"$00,$fe","a3#":"$00,$f0","b3_":"$00,$e2","c4_":"$00,$d6","c4#":"$00,$ca","d4_":"$00,$be","d4#":"$00,$b4","e4_":"$00,$aa","f4_":"$00,$a0","f4#":"$00,$97","g4_":"$00,$8f","g4#":"$00,$87","a4_":"$00,$7f","a4#":"$00,$78","b4_":"$00,$71","c5_":"$00,$6b","c5#":"$00,$65","d5_":"$00,$5f","d5#":"$00,$5a","e5_":"$00,$55","f5_":"$00,$50","f5#":"$00,$4c","g5_":"$00,$47","g5#":"$00,$43","a5_":"$00,$40","a5#":"$00,$3c","b5_":"$00,$39","c6_":"$00,$35","c6#":"$00,$32","d6_":"$00,$30","d6#":"$00,$2d","e6_":"$00,$2a","f6_":"$00,$28","f6#":"$00,$26","g6_":"$00,$24","g6#":"$00,$22","a6_":"$00,$20","a6#":"$00,$1e","b6_":"$00,$1c","c7_":"$00,$1b","c7#":"$00,$19","d7_":"$00,$18","d7#":"$00,$16","e7_":"$00,$15","f7_":"$00,$14","f7#":"$00,$13","g7_":"$00,$12","g7#":"$00,$11"}


SMS_PAL ={
"Ppp":"$00,$00","End":"$ff,$ff","a1_":"$03,$f0","a1#":"$03,$b7","b1_":"$03,$82","c2_":"$03,$4f","c2#":"$03,$20","d2_":"$02,$f3","d2#":"$02,$c9","e2_":"$02,$a1","f2_":"$02,$7b","f2#":"$02,$57","g2_":"$02,$36","g2#":"$02,$16","a2_":"$01,$f8","a2#":"$01,$dc","b2_":"$01,$c1","c3_":"$01,$a8","c3#":"$01,$90","d3_":"$01,$79","d3#":"$01,$64","e3_":"$01,$50","f3_":"$01,$3d","f3#":"$01,$2c","g3_":"$01,$1b","g3#":"$01,$0b","a3_":"$00,$fc","a3#":"$00,$ee","b3_":"$00,$e0","c4_":"$00,$d4","c4#":"$00,$c8","d4_":"$00,$bd","d4#":"$00,$b2","e4_":"$00,$a8","f4_":"$00,$9f","f4#":"$00,$96","g4_":"$00,$8d","g4#":"$00,$85","a4_":"$00,$7e","a4#":"$00,$77","b4_":"$00,$70","c5_":"$00,$6a","c5#":"$00,$64","d5_":"$00,$5e","d5#":"$00,$59","e5_":"$00,$54","f5_":"$00,$4f","f5#":"$00,$4b","g5_":"$00,$47","g5#":"$00,$43","a5_":"$00,$3f","a5#":"$00,$3b","b5_":"$00,$38","c6_":"$00,$35","c6#":"$00,$32","d6_":"$00,$2f","d6#":"$00,$2d","e6_":"$00,$2a","f6_":"$00,$28","f6#":"$00,$25","g6_":"$00,$23","g6#":"$00,$21","a6_":"$00,$1f","a6#":"$00,$1e","b6_":"$00,$1c","c7_":"$00,$1a","c7#":"$00,$19","d7_":"$00,$18","d7#":"$00,$16","e7_":"$00,$15","f7_":"$00,$14","f7#":"$00,$13","g7_":"$00,$12","g7#":"$00,$11"}

first_harmonic={
"a1_":"a2_","a1#":"a2#","b1_":"b2_","c2_":"c3_","c2#":"c3#","d2_":"d3_","d2#":"d3#","e2_":"e3_","f2_":"f3_","f2#":"f3#","g2_":"g3_","g2#":"g3#","a2_":"a3_","a2#":"a3#","b2_":"b3_","c3_":"c4_","c3#":"c4#","d3_":"d4_","d3#":"d4#","e3_":"e4_","f3_":"f4_","f3#":"f4#","g3_":"g4_","g3#":"g4#","a3_":"a4_","a3#":"a4#","b3_":"b4_","c4_":"c5_","c4#":"c5#","d4_":"d5_","d4#":"d5#","e4_":"e5_","f4_":"f5_","f4#":"f5#","g4_":"g5_","g4#":"g5#","a4_":"a5_","a4#":"a5#","b4_":"b5_","c5_":"c6_","c5#":"c6#","d5_":"d6_","d5#":"d6#","e5_":"e6_","f5_":"f6_","f5#":"f6#","g5_":"g6_","g5#":"g6#","a5_":"a6_","a5#":"a6#","b5_":"b6_","c6_":"c7_","c6#":"c7#","d6_":"d7_","d6#":"d7#","e6_":"e7_","f6_":"f7_","f6#":"f7#","g6_":"g7_","g6#":"g7#","a6_":"a7_","a6#":"a7#","b6_":"b7_"}

second_harmonic={
"a1_":"e3_","a1#":"f3_","b1_":"f3#","c2_":"g3_","c2#":"g3#","d2_":"a3_","d2#":"a3#","e2_":"b3_","f2_":"c4_","f2#":"c4#","g2_":"d4_","g2#":"d4#","a2_":"e4_","a2#":"f4_","b2_":"f4#","c3_":"g4_","c3#":"g4#","d3_":"a4_","d3#":"a4#","e3_":"b4_","f3_":"c5_","f3#":"c5#","g3_":"d5_","g3#":"d5#","a3_":"e5_","a3#":"f5_","b3_":"f5#","c4_":"g5_","c4#":"g5#","d4_":"a5_","d4#":"a5#","e4_":"b5_","f4_":"c6_","f4#":"c6#","g4_":"d6_","g4#":"d6#","a4_":"e6_","a4#":"f6_","b4_":"f6#","c5_":"g6_","c5#":"g6#","d5_":"a6_","d5#":"a6#","e5_":"b6_","f5_":"c7_","f5#":"c7#","g5_":"d7_","g5#":"d7#","a5_":"e7_","a5#":"f7_","b5_":"f7#"}

#old version, with octave changing at a.
#SMS_NTSC={
#"ppp":"$00,$00","end":"$ff,$ff","a3_":"$03,$f9","a3#":"$03,$c0","b3_":"$03,$8a","c3_":"$03,$57","c3#":"$03,$27","d3_":"$02,$fa","d3#":"$02,$cf","e3_":"$02,$a7","f3_":"$02,$81","f3#":"$02,$5d","g3_":"$02,$3b","g3#":"$02,$1b","a4_":"$01,$fc","a4#":"$01,$e0","b4_":"$01,$c5","c4_":"$01,$ac","c4#":"$01,$94","d4_":"$01,$7d","d4#":"$01,$68","e4_":"$01,$53","f4_":"$01,$40","f4#":"$01,$2e","g4_":"$01,$1d","g4#":"$01,$0d","a5_":"$00,$fe","a5#":"$00,$f0","b5_":"$00,$e2","c5_":"$00,$d6","c5#":"$00,$ca","d5_":"$00,$be","d5#":"$00,$b4","e5_":"$00,$aa","f5_":"$00,$a0","f5#":"$00,$97","g5_":"$00,$8f","g5#":"$00,$87","a6_":"$00,$7f","a6#":"$00,$78","b6_":"$00,$71","c6_":"$00,$6b","c6#":"$00,$65","d6_":"$00,$5f","d6#":"$00,$5a","e6_":"$00,$55","f6_":"$00,$50","f6#":"$00,$4c","g6_":"$00,$47","g6#":"$00,$43","a7_":"$00,$40","a7#":"$00,$3c","b7_":"$00,$39","c7_":"$00,$35","c7#":"$00,$32","d7_":"$00,$30","d7#":"$00,$2d","e7_":"$00,$2a","f7_":"$00,$28","f7#":"$00,$26","g7_":"$00,$24","g7#":"$00,$22","a8_":"$00,$20","a8#":"$00,$1e","b8_":"$00,$1c","c8_":"$00,$1b","c8#":"$00,$19","d8_":"$00,$18","d8#":"$00,$16","e8_":"$00,$15","f8_":"$00,$14","f8#":"$00,$13","g8_":"$00,$12","g8#":"$00,$11"}
#SMS_PAL ={
#"ppp":"$00,$00","end":"$ff,$ff","a3_":"$03,$f0","a3#":"$03,$b7","b3_":"$03,$82","c3_":"$03,$4f","c3#":"$03,$20","d3_":"$02,$f3","d3#":"$02,$c9","e3_":"$02,$a1","f3_":"$02,$7b","f3#":"$02,$57","g3_":"$02,$36","g3#":"$02,$16","a4_":"$01,$f8","a4#":"$01,$dc","b4_":"$01,$c1","c4_":"$01,$a8","c4#":"$01,$90","d4_":"$01,$79","d4#":"$01,$64","e4_":"$01,$50","f4_":"$01,$3d","f4#":"$01,$2c","g4_":"$01,$1b","g4#":"$01,$0b","a5_":"$00,$fc","a5#":"$00,$ee","b5_":"$00,$e0","c5_":"$00,$d4","c5#":"$00,$c8","d5_":"$00,$bd","d5#":"$00,$b2","e5_":"$00,$a8","f5_":"$00,$9f","f5#":"$00,$96","g5_":"$00,$8d","g5#":"$00,$85","a6_":"$00,$7e","a6#":"$00,$77","b6_":"$00,$70","c6_":"$00,$6a","c6#":"$00,$64","d6_":"$00,$5e","d6#":"$00,$59","e6_":"$00,$54","f6_":"$00,$4f","f6#":"$00,$4b","g6_":"$00,$47","g6#":"$00,$43","a7_":"$00,$3f","a7#":"$00,$3b","b7_":"$00,$38","c7_":"$00,$35","c7#":"$00,$32","d7_":"$00,$2f","d7#":"$00,$2d","e7_":"$00,$2a","f7_":"$00,$28","f7#":"$00,$25","g7_":"$00,$23","g7#":"$00,$21","a8_":"$00,$1f","a8#":"$00,$1e","b8_":"$00,$1c","c8_":"$00,$1a","c8#":"$00,$19","d8_":"$00,$18","d8#":"$00,$16","e8_":"$00,$15","f8_":"$00,$14","f8#":"$00,$13","g8_":"$00,$12","g8#":"$00,$11"}



def interpret_melody(melody,SMS_norm,name):
  output=name+"_start:\n  .db "
  total_duration=0
  total_duration_float=0
  for item in melody.split():
    item=item.strip()
    tone=item[0:3]
    duration=int(item[3:7],10)
    volume=int(item[7],16)
    nb_frames=int(round(frame_beat_factor*duration))
    nb_frames_float=frame_beat_factor*duration
    #print "item : ",item,tone,SMS_norm[tone],duration,nb_frames_float
    total_duration+=nb_frames
    total_duration_float+=nb_frames_float
    
    #print "note: ",tone,SMS_norm[tone]
    #attack
    if tone !="Ppp":
      for i in range(0,attack_frames,frames_step):
        volume_tmp=int(volume*float(i)/attack_frames)
        #print "volume_tmp",volume_tmp
        volume_str="$"+("{:#04x}".format(15-volume_tmp))[2:]
        output+="{},$01,{}, ".format(SMS_norm[tone],volume_str)
      for i in range(0,decay_frames,frames_step):
        volume_tmp=volume-int(volume*(1-sustain_ratio)*float(i)/decay_frames)
        #print "volume_tmp",volume_tmp
        volume_str="$"+("{:#04x}".format(15-volume_tmp))[2:]
        output+="{},$01,{}, ".format(SMS_norm[tone],volume_str)
        
      #vibrato
      if (len(item)>8) and (item[8]=="~"):
        j=0
        for i in range(0,nb_frames,vibrato_period):
          j+=1
          frames_str="$"+("{:#04x}".format(vibrato_period))[2:]
          volume_str="$"+("{:#04x}".format(15-volume))[2:]
          tone_tmp=int(SMS_norm[tone][1:3],16)*256+int(SMS_norm[tone][5:7],16)
          if (j%4==1):
            tone_tmp+=vibrato_amplitude
          if (j%4==3):
            tone_tmp-=vibrato_amplitude
          tone_str="$"+("{:#04x}".format(tone_tmp/256))[2:]+",$"+("{:#04x}".format(tone_tmp%256))[2:]
          #print tone_str,tone_tmp/256,tone_tmp%256
          output+="{},{},{}, ".format(tone_str,frames_str,volume_str)
        #finish tone length
        #print "remaining frames:",nb_frames%vibrato_period,"$"+("{:#04x}".format(nb_frames%vibrato_period))[2:]
        if (nb_frames%vibrato_period>0):
          frames_str="$"+("{:#04x}".format(nb_frames%vibrato_period))[2:]
          volume_str="$"+("{:#04x}".format(15-volume))[2:]
          output+="{},{},{}, ".format(SMS_norm[tone],frames_str,volume_str)
        
      else:#no vibrato
        if (nb_frames-attack_frames-decay_frames-release_frames<0):
          print "Warning: ",item,": ",duration," => ",nb_frames,"frames when minimal is ",attack_frames+decay_frames+release_frames,"\n"
        final_volume=int(volume*sustain_ratio)
        volume_str="$"+("{:#04x}".format(15-final_volume))[2:]
        if (nb_frames-attack_frames-decay_frames-release_frames>0):
          #print "nb_frames-attack_frames: ",nb_frames-attack_frames
          if (nb_frames-attack_frames-decay_frames-release_frames>0xff):
            print "TODO Error ! number of frames too big: ",nb_frames-attack_frames-decay_frames-release_frames
        
          frames_str="$"+("{:#04x}".format(nb_frames-attack_frames-decay_frames-release_frames))[2:]
          output+="{},{},{}, ".format(SMS_norm[tone],frames_str,volume_str)
          #print "frames_str: ",frames_str
      
      for i in range(0,release_frames,frames_step):
        volume_tmp=int(volume*sustain_ratio*float(release_frames-i)/release_frames)
        #print "volume_tmp",volume_tmp
        volume_str="$"+("{:#04x}".format(15-volume_tmp))[2:]
        output+="{},$01,{}, ".format(SMS_norm[tone],volume_str)
    else:#this is a pause
      if (nb_frames>0xff):
        print "TODO Error ! number of frames too big: ",nb_frames
      while (nb_frames>0xff):
        nb_frames-=0xff
        output+="{},$ff,$00, ".format(SMS_norm[tone])

      frames_str="$"+("{:#04x}".format(nb_frames))[2:]
      output+="{},{},$00, ".format(SMS_norm[tone],frames_str)
  output+=SMS_norm["End"]+"\n  ;total {} ({}) frames\n{}_end:\n".format(total_duration,total_duration_float,name)
  return output

#put drum high (%xxxx) and volume (0 to 15, 15=max) in one 8-bit value
def mixNoiseVolume(noise,volume):
  if (noise=="Ppp")or(noise=="End") :
    return drums[noise]
  return drums[noise]+"{:04b}".format(15-volume)

#for drums only attack and decay
def interpret_drums(melody,name):
  output=name+"_start:\n  .db "
  total_duration=0
  total_duration_float=0
  for item in melody.split():
    item=item.strip()
    tone=item[0:3]
    duration=int(item[3:7],10)
    volume=int(item[7],16)
    nb_frames=int(round(frame_beat_factor*duration))
    nb_frames_float=frame_beat_factor*duration
    #print "item : ",item,tone,SMS_norm[tone],duration,nb_frames_float
    total_duration+=nb_frames
    total_duration_float+=nb_frames_float
    
    #print "note: ",tone,drums[tone]
    #attack
    if tone !="Ppp":
      for i in range(0,attack_frames,frames_step):
        volume_tmp=int(volume*float(i)/attack_frames)
        #print "volume_tmp",volume_tmp
        output+=mixNoiseVolume(tone,volume_tmp)+",$01, "
      for i in range(0,decay_frames,frames_step):
        volume_tmp=volume-int(volume*float(i)/decay_frames)
        #print "volume_tmp",volume_tmp
        output+=mixNoiseVolume(tone,volume_tmp)+",$01, "
      
      if (nb_frames-attack_frames-decay_frames<0):
        print "Warning: ",item,": ",duration," => ",nb_frames,"frames when minimal is ",attack_frames+decay_frames,"\n"
      final_volume=0
      #print "nb_frames-attack_frames: ",nb_frames-attack_frames
      
      if (nb_frames-attack_frames-decay_frames>0xff):
        print "TODO Error ! number of frames too big: ",nb_frames-attack_frames-decay_frames
      
      frames_str="$"+("{:#04x}".format(nb_frames-attack_frames-decay_frames))[2:]
      output+=mixNoiseVolume("Ppp",final_volume)+","+frames_str+", "
      #print "frames_str: ",frames_str
    else:
      if (nb_frames>0xff):
        print "TODO Error ! number of frames too big: ",nb_frames
      
      frames_str="$"+("{:#04x}".format(nb_frames))[2:]
      output+=mixNoiseVolume(tone,volume)+","+frames_str+", "
  output+=drums["End"]+"\n  ;total {} ({}) frames\n{}_end:\n".format(total_duration,total_duration_float,name)
  return output

#from one melody creates 2 melodies of harmonics
def create_harmonics(melody,ampl_h1,ampl_h2):
  melody_h1=""
  melody_h2=""
  for item in melody.split():
    item=item.strip()
    tone=item[0:3]
    duration=int(item[3:7],10)
    volume=int(item[7],16)
    
    
    if (tone in first_harmonic):
      tone_h1=first_harmonic[tone]
    else:
      tone_h1="Ppp"
    if (tone in second_harmonic):
      tone_h2=second_harmonic[tone]
    else:
      tone_h2="Ppp"
    
    volume_h1=int(volume*ampl_h1)
    volume_h2=int(volume*ampl_h2)
    volume_h1_str=("{:#03x}".format(volume_h1))[2:]
    volume_h2_str=("{:#03x}".format(volume_h2))[2:]
    melody_h1+=tone_h1+"{:#04d}".format(duration)+volume_h1_str+" "
    melody_h2+=tone_h2+"{:#04d}".format(duration)+volume_h2_str+" "
  return (melody_h1,melody_h2)

def interpret_melody_harmonics(melody,SMS_norm,ampl_h1,ampl_h2,name,name_h1,name_h2):
  (melody_h1,melody_h2)=create_harmonics(melody,ampl_h1,ampl_h2)
  code1=interpret_melody(melody,SMS_norm,name)
  code2=interpret_melody(melody_h1,SMS_norm,name_h1)
  code3=interpret_melody(melody_h2,SMS_norm,name_h2)
  print code1
  print code2
  print code3
  #return (code1,code2,code3)

if __name__ == '__main__':
  #~ melody1=\
      #~ "b5_pF g4_hF g4_hF b5_hF  b5_pF g4_hF g4_hF b5_hF  c5_hF d5_qF c5_qF b5_1F a5_1F  b5_pF g4_hF g4_hF d5_hF "\
      #~ +"e5_pF b5_hF b5_hF d5_hF  e5_pF b5_hF b5_hF d5_hF  f5#hF e5_hF d5_1F c5#1F       d5_pF f4#hF f4#hF b5_hF  "
      #~ #+"b5_pF g4_hF g4_hF b5_hF  b5_pF g4_hF g4_hF b5_hF  c5_hF d5_qF c5_qF b5_1F a5_1F   "\
  #~ melody2=\
      #~ "g3_1F d4_1F d4_1F       g3_1F d4_1F d4_1F       g3_1F d4_1F d4_1F            g3_1F d4_1F d4_1F "\
      #~ +"e3_1F b4_1F b4_1F       e3_1F b4_1F b4_1F       d3_1F b4_1F c4#1F            b3_1F b4_1F b4_1F      "
      #~ #+" g3_1F d4_1F d4_1F  g3_1F d4_1F d4_1F       g3_1F d4_1F d4_1F   "\

  melody1=\
      " b3_0018A g3_0006A g3_0006A b3_0006A             b3_0018A g3_0006A g3_0006A b3_0006A "\
      +"c4_0006A d4_0003A c4_0003A b3_0012A a3_0012A    b3_0018A g3_0006A g3_0006A d4_0006A "\
      +"e4_0018A b3_0006A b3_0006A d4_0006A             e4_0018A b3_0006A b3_0006A d4_0006A "\
      +"f4#0006A e4_0006A d4_0012A c4#0012A             d4_0018A f3#0006A f3#0006A b3_0006A "
      #~ +"b4_0018A g4_0006A g4_0006A b4_0006A             b4_0018A g4_0006A g4_0006A b4_0006A "\
      #~ +"c5_0006A d5_0003A c5_0003A b4_0012A a4_0012A    b4_0018A g4_0006A g4_0006A d5_0006A "\
      #~ +"e5_0018A b4_0006A b4_0006A d5_0006A             e5_0018A b4_0006A b4_0006A d5_0006A "\
      #~ +"f5#0006A e5_0006A d5_0012A c5#0012A "
  melody2=\
      " g2_00126 d3_00126 d3_00126       g2_00126 d3_00126 d3_00126 "\
      +"g2_00126 d3_00126 d3_00126       g2_00126 d3_00126 d3_00126 "\
      +"e2_00126 b2_00126 b2_00126       e2_00126 b2_00126 b2_00126 "\
      +"d2_00126 b2_00126 c3#00126       b2_00126 b3_00126 b3_00126 "
      #~ +"g3_00126 d4_00126 d4_00126       g3_00126 d4_00126 d4_00126 "\
      #~ +"g3_00126 d4_00126 d4_00126       g3_00126 d4_00126 d4_00126 "\
      #~ +"e3_00126 b3_00126 b3_00126       e3_00126 b3_00126 b3_00126 "\
      #~ +"d3_00126 b3_00126 c4#00126 "

  #~ print interpret_melody(melody1,SMS_NTSC,"brahms1")
  interpret_melody_harmonics(melody1,SMS_NTSC,0.2,0,"brahms1","brahms2","poubelle")
  print interpret_melody(melody2,SMS_NTSC,"brahms3")

  #test="a3_1F a3_1F a3_1F a3_4F~ c3_1F d3_1F e3_1F f3_1F g3_1F a3_1F b3_1F c4_1F Ppp1F End1F"
  #test1="e3_pA b3_pA c4_pA b3_pA g3_pA d3_pA e3_3A g3_pA a3_pA b3_pA a3_pA a3_3A~ b3_pA a3_pA f3_pA d3_pA e3_pA a3_pA b3_pA e4_pA d4_pA c4_pA a3_pA c4_pA a3_3A~  PpppA End1F"
  #test2="Pppp6  e3_p6 b3_p6 c4_p6 b3_p6 g3_p6 d3_p6 e3_36 g3_p6 a3_p6 b3_p6 a3_p6 a3_36~ b3_p6 a3_p6 f3_p6 d3_p6 e3_p6 a3_p6 b3_p6 e4_p6 d4_p6 c4_p6 a3_p6 c4_p6 a3_36~  End1F"
  #print interpret_melody(test1,SMS_NTSC,"test1")
  #print interpret_melody(test2,SMS_NTSC,"test2")
  
  #test1="d4_hA b3_hA b3_hA d4_hA a3_hA g3_hA f3_hA a3_hA a3_hA b3_hA d4_hA a3_hA f3_hA a3_hA d4_hA a3_hA b3_hA a3_hA c4_hA g3_hA g3_hA a3_hA e4_hA b3_hA c4_hA a3_hA c4_hA g3_hA c4_hA g3_hA b3_hA f3_hA"
  #test2="b1_pA b1_hA PpphF b1_pA d2_hA PpphF b1_pA b1_hA PpphF b1_pA d2_hA PpphF b1_pA b1_hA PpphF b1_pA d2_hA PpphF b1_pA b1_hA PpphF b1_pA d2_hA"
  
  #~ test1="a3_1F b3_1F c4_1F Ppp1F"
  #~ test1="a3_1F Ppp3F"
  #~ test2="Ppp4F"
  #~ #test3="Ppp4F"
  #~ 
  #~ 
  #~ 
  #~ print interpret_melody(test1,SMS_NTSC,"test1")
  #~ print interpret_melody(test2,SMS_NTSC,"test2")
  #~ #print interpret_melody(test3,SMS_NTSC,"test3")
#~ 
  #~ #drums1="c3_1F e3_1F c3_hF c3_hF e3_1F"
  #~ drums1="c3_1F Ppp3F"
  #~ drums1="Ppp3F"
  #~ print interpret_drums(drums1,"drums1")
#~ 
  #~ #harmonics test:
  #~ harmo1="a2_4F a2_4F Ppp4F"
  #~ harmo2="a2_49 a3_49 Ppp4F"
  #~ harmo3="a2_44 e4_44 Ppp4F"
  #~ print interpret_melody(harmo1,SMS_NTSC,"test1")
  #~ print interpret_melody(harmo2,SMS_NTSC,"test2")
  #~ print interpret_melody(harmo3,SMS_NTSC,"test3")
#~ 
  #~ test1="a3_1F b3_1F c4_1F Ppp1F"
  #~ interpret_melody_harmonics(test1,SMS_NTSC,0.6,0.5,"test1","test2","test3")


  test1="c3_0045A c3_0046A c3#0069A                                                                        Ppp0023F "\
    +"e3_0011A g3_0005A f3_0017A     e3_0011A a3_0005A g3_0017A    e3_0011A g3_0005A f3_0017A "\
    +"a3_0011A g3_0005A e3_0017A     c3_0017A d3_0028A e3_0011A g3_0005A f3_0017A e3_0011A a3_0005A g3_0017A e3_0011A g3_0005A f3_0017A a3_0011A g3_0005A e3_0017A d3_0017A c3_0028A Ppp0092F c3_0011A"
  test2="e3_0045A e3_0046A f3#0006A f3#0006A f3#0006A f3#0006A f3#0006A f3#0006A f3#0006A f3#0006A f3#0021A Ppp0023F "\
    +"a2_0034A                               g2_0034A                                a2_0034A b2_0034A g2_0046A a2_0034A g2_0034A a2_0034A b2_0034A g2_0046A Ppp0092F e3_0011A"
  test3="g3_0045A a3_0046A a3#0069A Ppp0483F g3_0011A"
  
    
  test1="e3_0034A e3_0035A f3#0006A f3#0006A f3#0006A f3#0006A f3#0006A f3#0006A f3#0006A f3#0006A f3#0023A Ppp0035F e3_0012A g3_0006A f3_0017A e3_0012A a3_0006A g3_0017A e3_0012A g3_0006A f3_0017A a3_0012A g3_0006A e3_0017A c3_0017A d3_0040A Ppp0012F e3_0012A g3_0006A f3_0017A e3_0012A a3_0006A g3_0017A e3_0012A g3_0006A f3_0017A a3_0012A g3_0006A e3_0017A d3_0017A c3_0040A  "
  test2="g2_0035A a2_0035A a2#0069A Ppp0035F a2_0035A g2_0035A a2_0035A b2_0035A g2_0058A Ppp0012F a2_0035A g2_0035A a2_0035A b2_0035A g2_0058A "
  test3="g3_0034A a3_0035A a3#0069A "
 
  
  
  print interpret_melody(test1,SMS_NTSC,"demo_music_ch1")
  print interpret_melody(test2,SMS_NTSC,"demo_music_ch2")
  print interpret_melody(test3,SMS_NTSC,"demo_music_ch3")
  
  #test4="c3#0011A c3#0006A a3#0006A g3#0006A a3#0006A d3#0012A d3#0006A b3_0006A a3#0006A b3_0006A f3_0012A f3_0006A b3_0006A a3#0006A b3_0006A e3_0012A e3_0006A a3#0006A g3#0006A a3#0006A"
  #print interpret_melody(test4,SMS_NTSC,"demo_music_4")
  
  test1="f3_0017A f3_0006A a3_0012A f3_0012A e3_0023A a3_0006A Ppp0017F d3_0017A d3_0006A f3_0012A d3_0012A c3_0023A Ppp0023F a2#0017A a2#0006A c3_0012A a2#0012A a2_0023A f3_0023A e3_0017A e3_0006A f3_0012A g3_0012A f3_0023A Ppp0021F f5_0011A "
  test2="f4_00067 a4_00067 c5_00067 a4_00067 f4_00067 a4_00067 c5_00067 a4_00067 e4_00067 a4_00067 c5_00067 a4_00067 e4_00067 a4_00067 c5_00067 a4_00067 d4_00067 f4_00067 a4_00067 f4_00067 d4_00067 f4_00067 a4_00067 f4_00067 c4_00067 f4_00067 a4_00067 f4_00067 c4_00067 f4_00067 a4_00067 f4_00067 a3#00067 d4_00067 f4_00067 d4_00067 a3#00067 d4_00067 f4_00067 d4_00067 a3_00067 c4_00067 f4_00067 c4_00067 a3_00067 c4_00067 f4_00067 c4_00067 g3_00067 c4_00067 f4_00067 c4_00067 g3_00067 c4_00067 f4_00067 c4_00067 f3_00067 a3_00067 c4_00067 f4_00067 a4_00067 c5_00067 f5_00117 "
  
  print interpret_melody(test1,SMS_NTSC,"end_music_ch1")
  print interpret_melody(test2,SMS_NTSC,"end_music_ch2")
  
  

