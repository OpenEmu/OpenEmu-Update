#! /usr/bin/python
# -*- coding: utf-8 -*-

import midi
import copy

MIDI_JM={
24:"c0_",25:"c0#",26:"d0_",27:"d0#",28:"e0_",29:"f0_",30:"f0#",31:"g0_",32:"g0#",
33:"a0_",34:"a0#",35:"b0_",36:"c1_",37:"c1#",38:"d1_",39:"d1#",40:"e1_",41:"f1_",
42:"f1#",43:"g1_",44:"g1#",45:"a1_",46:"a1#",47:"b1_",48:"c2_",49:"c2#",50:"d2_",
51:"d2#",52:"e2_",53:"f2_",54:"f2#",55:"g2_",56:"g2#",57:"a2_",58:"a2#",59:"b2_",
60:"c3_",61:"c3#",62:"d3_",63:"d3#",64:"e3_",65:"f3_",66:"f3#",67:"g3_",68:"g3#",
69:"a3_",70:"a3#",71:"b3_",72:"c4_",73:"c4#",74:"d4_",75:"d4#",76:"e4_",77:"f4_",
78:"f4#",79:"g4_",80:"g4#",81:"a4_",82:"a4#",83:"b4_",84:"c5_",85:"c5#",86:"d5_",
87:"d5#",88:"e5_",89:"f5_",90:"f5#",91:"g5_",92:"g5#",93:"a5_",94:"a5#",95:"b5_",
96:"c6_",97:"c6#",98:"d6_",99:"d6#",100:"e6_",101:"f6_",102:"f6#",103:"g6_",
104:"g6#",105:"a6_",106:"a6#",107:"b6_",108:"c7_",109:"c7#",110:"d7_",111:"d7#",
112:"e7_",113:"f7_",114:"f7#",115:"g7_",116:"g7#",117:"a7_",118:"a7#",119:"b7_"}

#TODO: support long pauses, read tempo, support multiple notes at the same time
#TODO: support pauses at the beginning of track

#new durations : record 4 chars of 12th of beat, in decimal
#~ durations={"q":3,"t":4,"h":6,"1":12,"p":18,"2":24,"3":36,"4":48}
#~ invertDurations={}
#~ for k in durations.keys():
    #~ invertDurations[durations[k]]=k
#~ 
#~ FPS=60

#let's say 1 tick = 1ms
def ticksToDuration(ticks,tempo):
    blackDuration=1000.0*60/tempo#in ticks
    #print "ticks: ",ticks," => ",blackDuration
    #~ durationJM=durations["1"]*ticks/blackDuration
    durationJM=12*ticks/blackDuration #duration is givent in 12th of a beat
    return "{:#04d}".format(int(round(durationJM)))
    
    #~ bestDiff=100000
    #~ bestDuration="?"
    #~ for k in durations.keys():#dict is not ordered!
        #~ v=durations[k]
        #~ #print "for",k,", ",v," diff",abs(v-durationJM)
        #~ if (abs(v-durationJM)<bestDiff):
            #~ bestDiff=abs(v-durationJM)
            #~ bestDuration=k
    #~ #print "bestDuration",bestDuration," bestDiff",bestDiff
    #~ print "New duration: {:#04d}".format(int(durationJM))
    #~ return bestDuration



#represents at the same time midi events (key pressed or released),
#and notes played at a certain time
class Note(object):
    def __init__(self,_number,_velocity=0):#can try =None, if is None...
        self.number=_number
        self.velocity=_velocity#positive velocity means the note is started
        self.newNote=(self.velocity>0)#null velocity means the note is continued
        self.killNote=(self.velocity<0)#negative velocity means the note is ended
    def toString(self):
        string="Note "+str(self.number)+"; "+str(self.velocity)
        return string

class ConcurrentNotes(object):
    def __init__(self,tick):
        self.allNotes=[]
        self.tick=tick
    def copy(self,other):
        self.allNotes=copy.deepcopy(other.allNotes)
        for note in self.allNotes:
            note.velocity=0#by default these are continued notes
    def addNote(self,note):
        self.allNotes.append(note)
    def delNote(self,note):
        for _note in self.allNotes:
            if (_note.number==note.number):
                self.allNotes.remove(_note)
    def toString(self):
        string="Notes at "+str(self.tick)+":\n"
        for note in self.allNotes:
            string+=note.toString()+"\n"
        return string

class MidiMusic(object):
    def __init__(self,_filename,_track_number,_volume):
        self.filename=_filename
        self.pattern = midi.read_midifile(self.filename)
        self.allEvents=[]#list of tuple (tick,[notes])
        self.notesAtEachTime=[]#list of concurrent notes
        self.tick=0
        self.track_number=_track_number
        self.volume=_volume
        self.indexInTrack=[0]*len(self.pattern)
        self.tempo=120#bpm (TODO: read it in midi.SetTempoEvent(tick=0, data=[7, 161, 32]))
    def convertToEvents(self):#convert pythonmidi events to Note
        self.allEvents=[]
        self.tick=0
        self.indexInTrack=[0]*len(self.pattern)
        (tick,nextEvents)=music.getNextEvents()
        while len(nextEvents)>0:
            print"At ",tick,": "
            self.allEvents.append((tick,nextEvents))
            for event in nextEvents:
                print event.toString()
            music.printStatus()
            (tick,nextEvents)=music.getNextEvents()
    def convertToNotes(self):#computes the list of notes played for each event
        self.notesAtEachTime=[]
        for (tick,events) in self.allEvents:
            concurrentNotes=ConcurrentNotes(tick)
            if (len(self.notesAtEachTime)>0):
                concurrentNotes.copy(self.notesAtEachTime[-1])
            for event in events:
                if (event.newNote):
                    concurrentNotes.addNote(event)
                if (event.killNote):
                    concurrentNotes.delNote(event)
            self.notesAtEachTime.append(concurrentNotes)
            print concurrentNotes.toString()
    def convertToJMMusic(self):#computes sequence of notes with durations
        #TODO: add a limit to number of current notes, and try not to change channel for the same note!
        self.convertToEvents()
        print len(self.allEvents)
        self.convertToNotes()
        string=""
        timeIndex=0
        for concurrentNotes in self.notesAtEachTime:
            if len(concurrentNotes.allNotes)>0:
                currentNote=concurrentNotes.allNotes[0]#TODO: work with more than one note at the same time!
                noteEndTick=-1
                #search when the note finishes to get its duration
                for nextNotes in self.notesAtEachTime[timeIndex+1:]:
                    noteFound=False
                    for nextNote in nextNotes.allNotes:
                        if (nextNote.number==currentNote.number) and (not nextNote.newNote):
                            noteFound=True
                            break
                    if (not noteFound):
                        noteEndTick=nextNotes.tick
                        break
                string+=MIDI_JM[currentNote.number]
                string+=ticksToDuration(noteEndTick-concurrentNotes.tick,self.tempo)
                #string+=("{:#03X}".format(currentNote.velocity/8))[2:]#max velocity is 127
                string+=self.volume#max velocity is 127
                string+=" "
                print MIDI_JM[currentNote.number]," duration: ",noteEndTick-concurrentNotes.tick," ticks = ",ticksToDuration(noteEndTick-concurrentNotes.tick,self.tempo)
            else:
                #no note=>pause
                if (len(self.notesAtEachTime)>timeIndex+1):
                    noteEndTick=self.notesAtEachTime[timeIndex+1].tick
                    string+="Ppp"
                    string+=ticksToDuration(noteEndTick-concurrentNotes.tick,self.tempo)
                    string+="F "
            timeIndex+=1
        return string
    def getNextEvents(self):
        track_num=self.track_number
        nextEvents=[]
        #previousTick=self.tick#first part of the event is its date
        track=self.pattern[track_num]
        for event in track[self.indexInTrack[track_num]:]:
            print "Event num ",self.indexInTrack[track_num],": ",event
            if (type(event)!=midi.events.NoteOnEvent)and(type(event)!=midi.events.NoteOffEvent):
                self.indexInTrack[track_num]+=1
                print "Not interesting..."
            else:
                if (event.tick<=1)or(len(nextEvents)==0):#say that 1 tick is simultaneous, and allow tick big only if this is the first event at this moment
                    self.tick+=event.tick
                    self.indexInTrack[track_num]+=1
                    #print "New event",event
                    if (type(event)==midi.events.NoteOnEvent):
                        if (event.data[1]>0):
                            nextEvents.append(Note(event.data[0],event.data[1]))
                        else:
                            nextEvents.append(Note(event.data[0],-1))
                    elif (type(event)==midi.events.NoteOffEvent):#must be an off event
                        nextEvents.append(Note(event.data[0],-1))
                else:
                    print "This is in the future"
                    break
        return (self.tick,nextEvents)
    
    def printStatus(self):
        print "Status: ",self.tick,self.indexInTrack
    
if __name__ == '__main__':
    #~ music=MidiMusic("musescore/test_c.mid",0)
    #~ #print music.pattern
    #~ text_track0=music.convertToJMMusic()
#~ 
    #~ music=MidiMusic("musescore/test_c.mid",1)
    #~ #print music.pattern
    #~ text_track1=music.convertToJMMusic()
    #~ 
    #~ print text_track0
    #~ print text_track1
    #~ 
    
    
    music=MidiMusic("lander2_fin8.mid",0,"A")
    #print music.pattern
    text_track0=music.convertToJMMusic()

    music=MidiMusic("lander2_fin8.mid",1,"7")
    #print music.pattern
    text_track1=music.convertToJMMusic()

    music=MidiMusic("lander2_fin8.mid",2,"7")
    #print music.pattern
    text_track2=music.convertToJMMusic()
    

    


    #music=MidiMusic("lander2_intro4.mid",0,"a")
    ##print music.pattern
    #text_track0=music.convertToJMMusic()
    #
    #music=MidiMusic("lander2_intro4.mid",1,"a")
    ##print music.pattern
    #text_track1=music.convertToJMMusic()


    print text_track0
    print text_track1
    print text_track2
