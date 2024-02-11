<Cabbage>

form caption("Sequencer Experiment") size(630, 360), guiMode("queue"), pluginId("seqx") colour(30, 10, 250)

rslider    bounds(0, 10, 80, 80), valueTextBox(1), textBox(1), channel("bpm"), range(1,  240, 120, 1), text("BPM") 
rslider    bounds(80, 10, 80, 80), valueTextBox(1), textBox(1), channel("amp"),  range(0, 2, 0.75), text("Global Amp")
rslider    bounds(160, 10, 80, 80) valueTextBox(1), textBox(1), channel("state"),  range(0, 1, 0), text("State Fader")
label      bounds(225, 80, 120, 20), text("State Fader Mode T/R"), fontSize(10)
checkbox   bounds(260, 30, 40, 40), valueTextBox(1), channel("stateMode"), value(0), text("State Fader Mode T/R")

rslider    bounds(0, 170, 80, 80), valueTextBox(1), textBox(1), channel("melodyAmp"),  range(0, 1, 0.45), text("Melody Amp")
rslider    bounds(80, 170, 80, 80), valueTextBox(1), textBox(1), channel("bassAmp"),  range(0, 1, 0.25), text("Bass Amp")
rslider    bounds(160, 170, 80, 80), valueTextBox(1), textBox(1), channel("drumsAmp"),  range(0, 1, .94), text("Drums Amp")
rslider    bounds(240, 170, 80, 80), valueTextBox(1), textBox(1), channel("chordsAmp"),  range(0, 1, 0.125), text("Chords Amp")

// LEAD
vslider    bounds(330, 10, 60, 150), valueTextBox(1), textBox(1), channel("leadNote"),  range(24, 84, 60), text("Lead Note")
vslider    bounds(390, 10, 60, 150), valueTextBox(1), textBox(1), channel("leadWave"),  range(0.01, 1, 0.25), text("Lead Wave")
vslider    bounds(450, 10, 60, 150), valueTextBox(1), textBox(1), channel("leadFiltLFOFreq"),  range(0.0, 8, 0), text("FiltLFOFreq")

label      bounds(515, 10, 90, 20), text("Lead Filter LFO ON/OFF"), fontSize(10)
checkbox   bounds(540, 30, 40, 40), valueTextBox(1), channel("leadFiltLFOToggle"), value(1), text("Filter LFO ON/OFF")

rslider    bounds(320, 170, 80, 80), valueTextBox(1), textBox(1), channel("leadAmp"),  range(0, 1, 0.35), text("Lead Amp")
rslider    bounds(320, 260, 80, 80), valueTextBox(1), textBox(1), channel("leadGlide"),  range(0, 1, 0.015), text("Lead Glide")

rslider    bounds(400, 170, 80, 80), valueTextBox(1), textBox(1), channel("leadFiltFreq"),  range(0, 3000, 1200), text("Filter Freq")
rslider    bounds(400, 260, 80, 80), valueTextBox(1), textBox(1), channel("leadFiltRes"),  range(0, 0.35, 0.1), text("Filter Res")

</Cabbage>
<CsoundSynthesizer>
<CsOptions>
-n -d -m 2          ; -n: bypass writing of sound to disk, -d: suppress all displays, -m 2: message level: 2 - samples out of range
</CsOptions>
<CsInstruments>


////////////////////////////
//
// USER DEFINED OPCODES
//
////////////////////////////


/** Checks to see if item exists within array. Returns 1 if
  true and 0 if false. 
  from csound-live-code by Steven Yi
  */
opcode contains, i, ik[]
  ival, karr[] xin
  indx = 0
  iret = 0
  while (indx < lenarray:i(karr)) do
    if (i(karr,indx) == ival) then
      iret = 1
      igoto end
    endif
    indx += 1
  od
end:
  xout iret
endop 


/** Checks to see if item exists within array. Returns 1 if
  true and 0 if false. 
  from csound-live-code by Steven Yi
  */
opcode contains, i, ii[]
  ival, iarr[] xin
  indx = 0
  iret = 0
  while (indx < lenarray:i(iarr)) do
    if (iarr[indx] == ival) then
      iret = 1
      igoto end
    endif
    indx += 1
  od
end:
  xout iret
endop


// Various musical scales
gi_scale_major[] fillarray 0, 2, 4, 5, 7, 9, 11
gi_scale_minor[] fillarray 0, 2, 3, 5, 7, 8, 10
gi_scale_harmonic_minor[] fillarray 0, 2, 3, 5, 7, 8, 11
gi_scale_melodic_minor_asc[] fillarray 0, 2, 3, 5, 7, 9, 11
gi_scale_blues[] fillarray 0, 3, 5, 6, 7, 10
gi_scale_pentatonic_major[] fillarray 0, 2, 4, 7, 9
gi_scale_pentatonic_minor[] fillarray 0, 3, 5, 7, 10
gi_scale_dorian[] fillarray 0, 2, 3, 5, 7, 9, 10
gi_scale_phrygian[] fillarray 0, 1, 3, 5, 7, 8, 10
gi_scale_lydian[] fillarray 0, 2, 4, 6, 7, 9, 11
gi_scale_mixolydian[] fillarray 0, 2, 4, 5, 7, 9, 10
gi_scale_locrian[] fillarray 0, 1, 3, 5, 6, 8, 10

gi_cur_scale[] = gi_scale_minor


/** Set the global scale. */
opcode set_scale, 0,S
  Scale xin
  if(strcmp("maj", Scale) == 0) then
    gi_cur_scale = gi_scale_major
  elseif(strcmp("min", Scale) == 0) then
    gi_cur_scale = gi_scale_minor
  elseif(strcmp("minh", Scale) == 0) then
    gi_cur_scale = gi_scale_harmonic_minor
  elseif(strcmp("mina", Scale) == 0) then
    gi_cur_scale = gi_scale_melodic_minor_asc
  elseif(strcmp("blues", Scale) == 0) then
    gi_cur_scale = gi_scale_blues
  elseif(strcmp("pentmaj", Scale) == 0) then
    gi_cur_scale = gi_scale_pentatonic_major
  elseif(strcmp("pentmin", Scale) == 0) then
    gi_cur_scale = gi_scale_pentatonic_minor
  elseif(strcmp("dor", Scale) == 0) then
    gi_cur_scale = gi_scale_dorian
  elseif(strcmp("phry", Scale) == 0) then
    gi_cur_scale = gi_scale_phrygian
  elseif(strcmp("lyd", Scale) == 0) then
    gi_cur_scale = gi_scale_lydian
  elseif(strcmp("mix", Scale) == 0) then
    gi_cur_scale = gi_scale_mixolydian
  elseif(strcmp("loc", Scale) == 0) then
    gi_cur_scale = gi_scale_locrian
  else
    gi_cur_scale = gi_scale_minor
  endif
  
  prints "Updated scale to: %s", Scale
  printarray gi_cur_scale, "%f", "\nCurrent Scale:"
endop


/** Quantizes given MIDI note number to the given scale 
    (Base on pc:quantize from Extempore)
    from csound-live-code by Steven Yi
      */
opcode pc_quantize, i, ii[]
  ipitch_in, iscale[] xin
  inotenum = round:i(ipitch_in)
  ipc = inotenum % 12
  iout = inotenum
  
  indx = 0
  while (indx < 7) do
    if(contains(ipc + indx, iscale) == 1) then
      iout = inotenum + indx
      goto end
    elseif (contains(ipc - indx, iscale) == 1) then
      iout = inotenum - indx
      goto end
    endif
    indx += 1
  od
  end:
  xout iout
endop


/*
StrayGetEl - Gets one element from a string-array

DESCRIPTION
Returns (at i-rate) the element for ielindex in String, or an empty string, if the element has not been found. By default, the seperators between the elements are spaces and tabs. Others seperators can be defined by their ASCII code number.
Requires Csound 5.15 or higher

SYNTAX
Sel StrayGetEl Stray, ielindx [, isep1 [, isep2]]

INITIALIZATION
Input:
Stray - a string as array
ielindx - the index of the element (starting with 0)
isep1 - the first seperator (default=32: space)
isep2 - the second seperator (default=9: tab)
If the defaults are not used and just isep1 is given, it's the only seperator. If you want two seperators (as in the dafault), you must give isep1 and isep2
Output:
Sel - the element at position ielindx, as a string. if the element has not been found, an empty string is returned

CREDITS
joachim heintz april 2010 / january 2012
*/
  opcode StrayGetEl, S, Sijj
;returns the element at position ielindx in Stray, or an empty string if the element has not been found
Stray, ielindx, isepA, isepB xin
;;DEFINE THE SEPERATORS
isep1     =         (isepA == -1 ? 32 : isepA)
isep2     =         (isepA == -1 && isepB == -1 ? 9 : (isepB == -1 ? isep1 : isepB))
Sep1      sprintf   "%c", isep1
Sep2      sprintf   "%c", isep2
;;INITIALIZE SOME PARAMETERS
ilen      strlen    Stray
istartsel =         -1; startindex for searched element
iendsel   =         -1; endindex for searched element
iel       =         0; actual number of element while searching
iwarleer  =         1
indx      =         0
 if ilen == 0 igoto end ;don't go into the loop if Stray is empty
loop:
Snext     strsub    Stray, indx, indx+1; next sign
isep1p    strcmp    Snext, Sep1; returns 0 if Snext is sep1
isep2p    strcmp    Snext, Sep2; 0 if Snext is sep2
;;NEXT SIGN IS NOT SEP1 NOR SEP2
if isep1p != 0 && isep2p != 0 then
 if iwarleer == 1 then; first character after a seperator 
  if iel == ielindx then; if searched element index
istartsel =         indx; set it
iwarleer  =         0
  else 			;if not searched element index
iel       =         iel+1; increase it
iwarleer  =         0; log that it's not a seperator 
  endif 
 endif 
;;NEXT SIGN IS SEP1 OR SEP2
else 
 if istartsel > -1 then; if this is first selector after searched element
iendsel   =         indx; set iendsel
          igoto     end ;break
 else	
iwarleer  =         1
 endif 
endif
          loop_lt   indx, 1, ilen, loop 
end:
Sout      strsub    Stray, istartsel, iendsel
          xout      Sout
  endop 


/*
StrayLen - Returns the length of an array-string

DESCRIPTION
Returns the number of elements in Stray. Elements are defined by two seperators as ASCII coded characters: isep1 defaults to 32 (= space), isep2 defaults to 9 (= tab). If just one seperator is used, isep2 equals isep1.


SYNTAX
ilen StrayLen Stray [, isep1 [, isep2]]

INITIALIZATION
Stray - a string as array
isep1 - the first seperator (default=32: space)
isep2 - the second seperator (default=9: tab) 

CREDITS
joachim heintz april 2010
*/
  opcode StrayLen, i, Sjj
;returns the number of elements in Stray. elements are defined by two seperators as ASCII coded characters: isep1 defaults to 32 (= space), isep2 defaults to 9 (= tab). if just one seperator is used, isep2 equals isep1
Stray, isepA, isepB xin
;;DEFINE THE SEPERATORS
isep1     =         (isepA == -1 ? 32 : isepA)
isep2     =         (isepA == -1 && isepB == -1 ? 9 : (isepB == -1 ? isep1 : isepB))
Sep1      sprintf   "%c", isep1
Sep2      sprintf   "%c", isep2
;;INITIALIZE SOME PARAMETERS
ilen      strlen    Stray
icount    =         0; number of elements
iwarsep   =         1
indx      =         0
 if ilen == 0 igoto end ;don't go into the loop if String is empty
loop:
Snext     strsub    Stray, indx, indx+1; next sign
isep1p    strcmp    Snext, Sep1; returns 0 if Snext is sep1
isep2p    strcmp    Snext, Sep2; 0 if Snext is sep2
 if isep1p == 0 || isep2p == 0 then; if sep1 or sep2
iwarsep   =         1; tell the log so
 else 				; if not 
  if iwarsep == 1 then	; and has been sep1 or sep2 before
icount    =         icount + 1; increase counter
iwarsep   =         0; and tell you are ot sep1 nor sep2 
  endif 
 endif	
          loop_lt   indx, 1, ilen, loop 
end:      xout      icount
  endop


/*
    Parse a 2D Note Array using ASCII separators from a string generated by an external software
    A note is a struct with a note number, a volume and a duration
*/
opcode Parse2DNoteArray, i[][], Sii
    String, iSepA, iSepB xin

    //prints "\nParse2DNoteArray: %s", String
    iLen = StrayLen(String, iSepA)
    iCounter = 0
    
    iArr[][] init iLen, 3
    
    while iCounter < iLen do
        SNote = StrayGetEl(String, iCounter, iSepA)
        ;prints SNote 
        
        iNoteNum = strtod(StrayGetEl(SNote, 0, iSepB))
        iVol = strtod(StrayGetEl(SNote, 1, iSepB))
        iDur = strtod(StrayGetEl(SNote, 2, iSepB))
        iRow[] = fillarray(iNoteNum, iVol, iDur)
        iArr = setrow(iRow, iCounter)
        ; "\n %d: %d, %d, %d", iCounter, iNoteNum, iVol, iDur
        iCounter += 1
    od

    ;printarray iArr, "%d", "\n2D Array: "
    
    xout iArr
endop


/*
    Parse a 3D Note Array using ASCII separators from a string generated by an external software
    The array contains a list of Steps, each step can contain one or more notes.
    A note is a struct with a note number, a volume and a duration
*/
opcode Parse3DNoteArray, i[][][], Siii

    String, iSepA, iSepB, iSepC xin
    iCounter = 0
    iLen = StrayLen(String, iSepA)
    ;prints "\n\n3D Array Length: %d\n", iLen   
    
    ; we have to overcome the possible difference in length of the 2D arrays: they could have a different element count
    ; but this is not supported in Csound, where subarrays of multidimensional arrays must have the same length
    ; so first parse 2D arrays and keep track of the biggest size
    iMaxSize init 0
    while iCounter < iLen do
    
        Step = StrayGetEl(String, iCounter, iSepA)
        ;prints "\nStep[%d]: %s\n", iCounter, Step
        iSize = StrayLen(Step, iSepB)
        ;prints "\nStep[%d] size: %d", iSize
        
        if iSize > iMaxSize then
            iMaxSize = iSize
        endif
        
        iCounter += 1
    od
    
    ; init the 3D array with the found max size on the 2nd dimension
    iArr[][][] init iLen, iMaxSize, 3
    
    ; now it's time to copy 2D arrays in the 3D array
    iCount1 = 0
    while iCount1 < iLen do
        
        Step = StrayGetEl(String, iCount1, iSepA)
        ;prints "\n\nStep[%d]: %s\n", iCount1, Step
        iStep[][] Parse2DNoteArray Step, iSepB, iSepC
        
        iCount2 = 0
        while iCount2 < iMaxSize do
            iCount3 = 0
            
            ; we still need to skip in case the step array has not enough elements
            ; the skipped elements will remain unset
            iSize lenarray iStep, 1
            ;prints "\ncurrent step [%d][%d] size: %d", iCount1, iCount2, iSize
            if iCount2 < iSize then
                while iCount3 < 3 do
                    iVal = iStep[iCount2][iCount3]
                    ;prints "\n\tsetting value [%d][%d][%d]: : %f", iCount1, iCount2, iCount3, iVal
                    iArr[iCount1][iCount2][iCount3] = iVal
                    iCount3 += 1
                od
            else
                ;prints "\n\tnothing to set"
            endif
            iCount2 += 1
        od
        iCount1 += 1
    od
    xout iArr
endop


/////////////////////////////
//
// VARIABLES DECLARATIONS
//
////////////////////////////

sr = 48000
kr = 48000
ksmps = 1
nchnls = 2
0dbfs = 1


instr INIT ; fake empty instrument just to have a quick hook to this section ;)
endin

// MELODY
;gSMelody                init "0,0,0:_60,1,1:_65,1,1:_67,1,1:_0,0,0:_0,0,0:_0,0,0:_0,0,0:_0,0,0:_0,0,0:_0,0,0:_0,0,0:_0,0,0:_0,0,0:_67,1,1:_72,1,1:_"    ; init "60,1,1.5:-1,1,0.5:-1,1,0.5:62,1,0.5:64,1,0.5:67,1,0.5:70,1,0.5:67,1,0.5:68,1,1.5:-1,1,0.5:-1,1,0.5:67,1,0.5:66,1,2:-1,1,0.5:-1,1,0.5:62,1,0.5:" ;TEST
;gSTenseMelody           init "36,1,1:_43,1,1:_48,1,1:_51,1,1:_55,1,1:_60,1,1:_63,1,1:_67,1,1:_68,1,1:_63,1,1:_60,1,1:_56,1,1:_58,1,1:_62,1,1:_65,1,1:_70,1,1:_73,1,1:68,1,1:";init "48,1,1:_55,1,1:_60,1,1:_63,1,1:_67,1,1:_72,1,1:_75,1,1:_79,1,1:_80,1,1:_75,1,1:_72,1,1:_68,1,1:_70,1,1:_74,1,1:_77,1,1:_82,1,1:_"; init "60,1,1:0,1,0.5:60,1,1:0,1,0.5:62,1,1:0,1,0.5:60,1,1:0,1,0.5:63,1,1:0,1,0.5:60,1,1:0,1,1:65,1,1:0,1,0.5:63,1,1:0,1,0.5:"                         ;TEST
gSMelody                chnexport "melody", 1          ; will receive the string from an external software
gSTenseMelody           chnexport "tenseMelody", 1

giMelodyLen             init 0 


// BASS
;gSBass                 init "0,0,0:_0,0,0:_0,0,0:_0,0,0:_36,1,4:_0,0,0:_0,0,0:_0,0,0:_0,0,0:_0,0,0:_0,0,0:_0,0,0:_0,0,0:_0,0,0:_0,0,0:_0,0,0:_0,0,0:_0,0,0:_0,0,0:_0,0,0:_41,1,4:_0,0,0:_0,0,0:_0,0,0:_0,0,0:_0,0,0:_0,0,0:_0,0,0::_39,1,4_0,0,0:_0,0,0:_0,0,0:_" ; init "36,1,4:0,1,4:0,1,4:0,1,4:36,1,4:0,1,4:0,1,4:0,1,4:36,1,4:0,1,4:0,1,4:0,1,4:36,1,4:0,1,4:0,1,4:0,1,4:32,1,4:0,1,4:0,1,4:0,1,4:32,1,4:0,1,4:0,1,4:0,1,4:29,1,4:0,1,4:0,1,4:0,1,4:29,1,4:0,1,4:0,1,4:0,1,4:"
;gSTenseBass            init "36,1,4:_0,0,0:_0,0,0:_0,0,0:_36,1,4:_0,0,0:_0,0,0:_0,0,0:_36,1,4:_0,0,0:_0,0,0:_0,0,0:_36,1,4:_0,0,0:_0,0,0:_0,0,0:_32,1,4:_0,0,0:_0,0,0:_0,0,0:_32,1,4:_0,0,0:_0,0,0:_0,0,0:_29,1,4:_0,0,0:_0,0,0:_0,0,0:_29,1,4:_0,0,0:_0,0,0:_0,0,0:_"; init "36,1,4:0,1,4:0,1,4:0,1,4:36,1,4:0,1,4:0,1,4:0,1,4:36,1,4:0,1,4:0,1,4:0,1,4:36,1,4:0,1,4:0,1,4:0,1,4:32,1,4:0,1,4:0,1,4:0,1,4:32,1,4:0,1,4:0,1,4:0,1,4:29,1,4:0,1,4:0,1,4:0,1,4:29,1,4:0,1,4:0,1,4:0,1,4:"
gSBass                  chnexport "bass", 1
gSTenseBass             chnexport "tenseBass", 1

giBassLen               init 0


// DRUMS
;gSRhythm               init "1,1,1:_0,0,0:_0,0,0:_0,0,0:_3,1,1:_0,0,0:_0,0,0:_0,0,0:_0,0,0:_0,0,0:_0,0,0:_0,0,0:_3,1,1:_0,0,0:_0,0,0:_0,0,0:_1,1,1:_0,0,0:_1,1,1:_0,0,0:_3,1,1:_0,0,0:_0,0,0:_0,0,0:_0,0,0:_0,0,0:_0,0,0:_0,0,0:_3,1,1:_0,0,0:_0,0,0:_0,0,0:_" ;init "1,1,1:8,1,1:_2,1,1:_3,1,1:_2,1,1:_1,1,1:_2,1,1:_3,1,1:_2,1,1:_"                   ;TEST
;gSTenseRhythm          init "1,1,1:_0,0,0:_0,0,0:_0,0,0:_3,1,1:_0,0,0:_0,0,0:_0,0,0:_2,1,1:_0,0,0:_0,0,0:_0,0,0:_3,1,1:_0,0,0:_0,0,0:_0,0,0:_1,1,1:_0,0,0:_0,0,0:_0,0,0:_3,1,1:_0,0,0:_0,0,0:_0,0,0:_2,1,1:_0,0,0:_0,0,0:_0,0,0:_4,1,1:_0,0,0:_0,0,0:_0,0,0:_"; init "1,1,1:8,1,1:_1,1,1:2,1,1:_3,1,1:_1,1,1:2,1,1:_1,1,1:_2,1,1:_3,1,1:_2,1,1:_"       ;TEST
gSRhythm                chnexport "rhythm", 1
gSTenseRhythm           chnexport "tenseRhythm", 1

giRhythmLen             init 0


// CHORDS
gSChords                chnexport "chords", 1
gSTenseChords           chnexport "tenseChords", 1

giChordsLen             init 0

; The total number of steps in the sequencer
;giTickSteps             init 64                         ; TEST
giTickSteps             chnexport "tickSteps", 1       ; get the steps subdivision from external software
;giBars                  init 8
giBars                  chnexport "bars", 1            ; get the number of bars from external software

giMelodyTicks           chnexport "melodyTicks", 1
giRhythmTicks           chnexport "rhythmTicks", 1
giBassTicks             chnexport "bassTicks", 1
giChordsTicks           chnexport "chordsTicks", 1

; only one ratio for variants of Melody, Bass, Rhythm and Chords
; this is to avoid desyncing in the pointer when switching between them
; this also means that arrays of the same instrument should have the same length
giMelodyRatio           init 1
giBassRatio             init 1
giRhythmRatio           init 1
giChordsRatio           init 1

// Arrays holding notes
; melody
giMelody[][][]              init 1, 1, 1
giTenseMelody[][][]         init 1, 1, 1

; bass
giBass[][][]                init 1, 1, 1
giTenseBass[][][]           init 1, 1, 1

; rhythm
giRhythm[][][]              init 1, 1, 1
giTenseRhythm[][][]         init 1, 1, 1

; chords
giChords[][][]              init 1, 1, 1
giTenseChords[][][]         init 1, 1, 1

// MELODY global Audio Outputs (Bus)
gaMelodyL, gaMelodyR    init 0

// DRUMS global Audio Outputs (Bus)
gaDrumsL, gaDrumsR      init 0

// Reverb FX global Audio Outputs (Bus)
gaRevL, gaRevR          init 0

// Lead Delay FX global Audio Outputs (Bus)
gaDelayL, gaDelayR      init 0

// Stutter FX global Audio Outputs (Bus)
gaStutSendL             init 0
gaStutSendR             init 0

// Drums Delay FX Audio Outputs (Bus)
gaGlobalDelayL          init 0
gaGlobalDelayR          init 0

// Global Audio Output (Bus)
gaGlobalOutputL         init 0
gaGlobalOutputR         init 0

;giGlobalOutputTableL     ftgen   0, 0, 2^16, 7, 0, 2^16, 0 ; a table to hold 1 second of output samples, for further processing on the global output
;giGlobalOutputTableR     ftgen   0, 0, 2^16, 7, 0, 2^16, 0 ; a table to hold 1 second of output samples, for further processing on the global output

// DRUMS FUNCTIONS
giSine		            ftgen	0,0,65536,10,1		; A SINE WAVE
giCos		            ftgen	0,0,65536,9,1,1,90	; A COSINE WAVE

// LEAD WAVE PARTIALS FUNCTION
giPartials = ftgen(0, 0, 2048, 10, 1, .3, .5, .2, .4)


// Musical scale used by Lead instr
set_scale("blues")


// PERFORMANCE VARIABLES

// General
gkAmp init 0.1
gkBPM init 120
gkState init 0
gkStateMode init 0

// Amplitudes
gkMelodyAmp init 0.5
gkBassAmp   init 0.3
gkDrumsAmp  init 0.9
gkChordsAmp init 0.3

// Lead Sound
gkLeadAmp   init 0.6
gkLeadGlide init 0.05
gkLeadNote  init 60
gkLeadWave  init 0.5
gkLeadFiltFreq init 1200
gkLeadFiltRes init 0.2
gkLeadFiltLFOToggle init 0
gkLeadFiltLFOFreq init 0

gkLeadRevSend init 0.2
gkLeadDelaySend init 0.3
gkLeadDelayLvl init 0.2
gkLeadDelayL init 0.35
gkLeadDelayR init 0.4

// Reverb
gkRevLev init 0.6
gkRoom  init 0.7
gkHF    init 0.8

// hardcoded values for now for:
// Delay
;...
// Stutter
;...


////////////////////////////
//
// INITIALIZATION INSTRUMENT
//
// Parses the strings received from an external software to create the note arrays used for playback
// 
////////////////////////////
instr INITIALIZATION

iError init 0

// Melody
iMelody[][][] Parse3DNoteArray gSMelody, 95, 58, 44  ; ASCII Codes Separators in string: 95 --> underscore '_', 58 --> colon ':', 44 --> comma ','
iTenseMelody[][][] Parse3DNoteArray gSTenseMelody, 95, 58, 44

iMelodyLen lenarray iMelody
iAltMelodyLen lenarray iTenseMelody 

if iMelodyLen != iAltMelodyLen then
    prints "ERROR! Melody arrays length differ! This is not permitted to avoid desync issues\n"
    iError = -1
endif

// Bass
iBass[][][] Parse3DNoteArray gSBass, 95, 58, 44
iTenseBass[][][] Parse3DNoteArray gSTenseBass, 95, 58, 44

iBassLen lenarray iBass
iTenseBassLen lenarray iTenseBass

if iBassLen != iTenseBassLen then
   prints "ERROR! Bass arrays length differ! This is not permitted to avoid desync issues\n"
   iError = -1
endif

;prints "\n\nBASIC RHYTHM: %s", gSRhythm
;prints "\n\nTENSE RHYTHM: %s", gSTenseRhythm

// Rhythm
iRhythm[][][] Parse3DNoteArray gSRhythm, 95, 58, 44
iTenseRhythm[][][] Parse3DNoteArray gSTenseRhythm, 95, 58, 44

iRhythmLen lenarray iRhythm
iTenseRhythmLen lenarray iTenseRhythm

if iRhythmLen != iTenseRhythmLen then
    prints "ERROR! Rhythm arrays length differ! This is not permitted to avoid desync issues\n"
    iError = -1
endif

// Chords
iChords[][][] Parse3DNoteArray gSChords, 95, 58, 44
iTenseChords[][][] Parse3DNoteArray gSTenseChords, 95, 58, 44

iChordsLen lenarray iChords
iTenseChordsLen lenarray iTenseChords

if iChordsLen != iTenseChordsLen then
    prints "ERROR! Chords arrays length differ! This is not permitted to avoid desync issues\n"
    iError = -1
endif

; exit early if any of the errors above occurred
if iError == -1 then
    turnoff
endif

giMelody = iMelody
giTenseMelody = iTenseMelody
giMelodyLen = iMelodyLen
giBass = iBass
giTenseBass = iTenseBass
giBassLen = iBassLen
giRhythm = iRhythm
giTenseRhythm = iTenseRhythm
giRhythmLen = iRhythmLen
giChords = iChords
giTenseChords = iTenseChords
giChordsLen = iChordsLen

;prints "giRhythmLen: %d, giRhythmTicks: %d", giRhythmLen, giRhythmTicks

; calculates the ratio of the various sequences compared to the tick subdivision
giMelodyRatio = giTickSteps / giMelodyTicks ;giTickSteps / (giMelodyLen / giMelodyTicks) 
giBassRatio = giTickSteps / giBassTicks ;giTickSteps / (giBassLen / giBassTicks) 
giRhythmRatio = giTickSteps / giRhythmTicks ;giTickSteps / (giRhythmLen / giRhythmTicks)  
giChordsRatio = giTickSteps / giChordsTicks

prints "giMelodyRatio: %f, giBassRatio: %f, giRhythmRatio: %f, giChordsRatio: %f\n\n", giMelodyRatio, giBassRatio, giRhythmRatio, giChordsRatio

endin


////////////////////////////
//
// LEAD INSTRUMENT
//
// A punchy lead sound meant to be controlled with the hand position, using X, Y and Z to alter its parameters
// 
// X : FILTER FREQ
// Y : NOTE PITCH
// Z : DISTORTION
// 
// ROTATION Z : FILTER RES
// 
// For the instrument name we're using a number (and a string for clarity purposes) so that we can start (i1 0 -1) / stop (i-1 0 -1) the instrument from an external software
// It is not possible to start stop an instrument using its string name
//
////////////////////////////
instr 1

  start:
  ipan = 0.5
  iNote = i(gkLeadNote)
  kFrqInScale = pc_quantize(iNote, gi_cur_scale)
  rireturn
  
  kNoteChanged = changed(gkLeadNote)
  if kNoteChanged == 1 then
    reinit start
  endif
  
  kAmp portk gkLeadAmp, 0.1
  kFreq = portk(mtof:k(kFrqInScale), gkLeadGlide)
  kLeadDist portk gkLeadWave, 0.1
  kLeadFiltFreq portk gkLeadFiltFreq, 0.1
  kLeadFiltRes portk gkLeadFiltRes, 0.1
  kLeadWave = portk(gkLeadWave, 0.05)
  kState = portk(gkState, 0.05)
  
  ;kLmt = rspline(1.2, 24, gkBPM / 60, gkBPM / 60)
  ;kLeadWave *= kLmt
  kLeadWave *= 18
  aPhs  = phasor:a(kFreq) ^ kLeadWave
  aSig = tablei:a(aPhs, giPartials, 1, 0, 1)
  kLeadWave2 = kLeadWave * 14
  aPhs2 = phasor:a(kFreq/2) ^ kLeadWave2
  aSig2 = tablei:a(aPhs2, giPartials, 1, 0, 1)
  ;aSig2 gendy 1, 4, 1, 1, 1, kFreq / 2, kFreq / 2, 0.5, 0.5
  kSig2Mix = kState > 0.5 ? kState - 0.5 : 0
  aMix = (aSig + aSig2 * kSig2Mix) /// 2 // always keep aSig in, and only use half of aSig2 amp
  
  if gkLeadFiltLFOToggle == 1 then
  
      kLFO lfo kLeadFiltFreq, gkBPM * 4 / (60 * gkLeadFiltLFOFreq), 1
      kLFO += kLeadFiltFreq / 2
      //kLFO *= 0.95
      kLeadFiltFreq += kLFO
  
  endif
  
  aFilt moogvcf2 aMix, kLeadFiltFreq, kLeadFiltRes
  aEnv madsr 0.1, 0.001, 1, 0.1
  aSig = aFilt * aEnv
  ;outs aSig, aSig ;TEST
  aL, aR pan2 aSig, ipan

  aOutL = aL * kAmp
  aOutR = aR * kAmp
  
  gaDelayL += aOutL * gkLeadDelaySend 
  gaDelayR += aOutR * gkLeadDelaySend
  
  gaRevL += aOutL * gkLeadRevSend
  gaRevR += aOutR * gkLeadRevSend
  
  ;outs(aOutL, aOutR)
  gaGlobalOutputL += aOutL
  gaGlobalOutputR += aOutR
  
endin


////////////////////////////
//
// TICK GENERATOR INSTRUMENT
//
// Generates instances of the TICK INSTRUMENT depending on BPM and Tick division
// 
////////////////////////////
instr GENERATOR

iTick init 0
iBPS init 1
iBarLen init 4     ; 4/4

reset:
iBPS = i(gkBPM) / 60
iBarDur = iBarLen * (1 / iBPS)
iTime = iBarDur / giTickSteps

timout 0, iTime, cont
reinit reset

cont:
schedule "TICK", 0, iTime, iTick

iTick += 1

if iTick == (giTickSteps * giBars) then
    iTick = 0
endif

endin


////////////////////////////
//
// TICK INSTRUMENT
//
// Performs a step in the sequencer, starting instances of audio instruments
// 
////////////////////////////
instr TICK

;prints "\nTick! [%d] duration: %f\n", p4, p3
    
schedule "MELODY", 0, p3, p4 ; p3 is the duration of the Tick, 
schedule "BASS", 0, p3, p4   ; it will be used to determine the length of a note, 
schedule "DRUMS", 0, p3, p4  ; that is a multiple of that
schedule "CHORDS", 0, p3, p4 ; p4 is the index of the tick

endin


////////////////////////////
//
// MELODY INSTRUMENT
//
// Performs a step for melody instrument, choosing which melody to play
// 
////////////////////////////
instr MELODY

iTickDur = p3
iTick = p4
iMod = iTick % giMelodyRatio
iMode = i(gkStateMode)
;prints "Melody Tick! [%d] duration: %f, iMod: %d\n", iTick, iTickDur, iMod

if iMod != 0 then
    ;prints "\t\tNot playing for iTick %d, turning off MELODY", iTick
    ; exit the instrument if we don't have notes at this tick resolution
    turnoff
else
    iState = iMode == 1 ? rnd(i(gkState)) : i(gkState)
    iStep = int(iTick / giMelodyRatio) % giMelodyLen

    if iState < 0.5 then
        iBlockLen lenarray giMelody, 2
    else
        iBlockLen lenarray giTenseMelody, 2
    endif
    
    iCounter = 0
    
    while iCounter < iBlockLen do
        
        if (iState < 0.5) then
            iNote = giMelody[iStep][iCounter][0]
            iVol = giMelody[iStep][iCounter][1] * i(gkMelodyAmp)
            iDur = giMelody[iStep][iCounter][2] * giMelodyRatio * iTickDur
        else
            iNote = giTenseMelody[iStep][iCounter][0]
            iVol = giTenseMelody[iStep][iCounter][1] * i(gkMelodyAmp)
            iDur = giTenseMelody[iStep][iCounter][2] * giMelodyRatio * iTickDur
        endif
        
        iCounter += 1
        ;prints "\nMELODY iNote: %d, iVol: %f, iDur: %f\n", iNote, iVol, iDur
        
        if iNote >= 0 && iDur > 0 && iVol > 0 then
            schedule "MELODY_1", 0, iDur, iVol, mtof:i(iNote)
        endif
    od

endif

endin


////////////////////////////
//
// BASS INSTRUMENT
//
// Performs a step for bass instrument
// 
////////////////////////////
instr BASS
iTickDur = p3
iTick = p4
iMod = iTick % giBassRatio
iMode = i(gkStateMode)
;prints "Bass Tick! [%d] duration: %f, iMod: %d\n", iTick, iTickDur, iMod

if iMod != 0 then
    ;prints "\t\tNot playing for iTick %d, turning off BASS", iTick
    ; exit the instrument if we don't have notes at this tick resolution
    turnoff
else
    ;prints "\n----->BASS iMod: %d", iMod
    iState = iMode == 1 ? rnd(i(gkState)) : i(gkState)
    iStep = int(iTick / giBassRatio) % giBassLen

    if iState < 0.5 then
        iBlockLen lenarray giBass, 2
    else
        iBlockLen lenarray giTenseBass, 2
    endif
    
    iCounter = 0
    
    while iCounter < iBlockLen do
        
        iRnd = iState   ;= rnd(iState)
        
        if (iRnd < 0.5) then
            iNote = giBass[iStep][iCounter][0]
            iVol = giBass[iStep][iCounter][1]
            iDur = giBass[iStep][iCounter][2] * giBassRatio * iTickDur
        else
            iNote = giTenseBass[iStep][iCounter][0]
            iVol = giTenseBass[iStep][iCounter][1]
            iDur = giTenseBass[iStep][iCounter][2] * giBassRatio * iTickDur
        endif
        
        iCounter += 1
        
        if iNote >= 0 && iDur > 0 && iVol > 0 then
            ;prints "\n[%d][%d] BASS iNote: %d, iVol: %f, iDur: %f, iTickDur: %f, giBassRatio: %f\n", iTick, iStep, iNote, iVol, iDur, iTickDur, giBassRatio
            schedule "BASS_3", 0, iDur, iVol, mtof:i(iNote)
        endif
    od
    
endif

endin


////////////////////////////
//
// DRUMS INSTRUMENT
//
// Performs a step for drum instruments, starting subinstances of drums instruments, currently 8 tracks from 101 to 109 
// 
////////////////////////////
instr DRUMS

iTickDur = p3
iTick = p4
iMod = iTick % giRhythmRatio
iMode = i(gkStateMode)
;prints "Rhythm Tick! [%d] duration: %f, iMod: %d\n", iTick, iTickDur, iMod

if iMod != 0 then
    ;prints "\t\tNot playing for iTick %d, turning off RHYTHM", iTick
    ; exit the instrument if we don't have notes at this tick resolution
    turnoff
else

    iState = iMode == 1 ? rnd(i(gkState)) : i(gkState)
    iStep = int(iTick / giRhythmRatio) % giRhythmLen
    
    ;prints "DRUMS iStep: %d", iStep
    
    if iState < 0.5 then
        iBlockLen lenarray giRhythm, 2
    else
        iBlockLen lenarray giTenseRhythm, 2
    endif
    
    ;prints "\n-------------------------> iBlockLen: %d\n", iBlockLen
    
    iCounter = 0
    
    while iCounter < iBlockLen do
        
        iRnd = iState;= rnd(iState)
        
        if (iRnd < 0.5) then
            iInstr = giRhythm[iStep][iCounter][0]
            iVol = giRhythm[iStep][iCounter][1] * i(gkDrumsAmp)
            iDur = giRhythm[iStep][iCounter][2] * giRhythmRatio * iTickDur
            iAmp = i(gkAmp) * iVol
        else
            iInstr = giTenseRhythm[iStep][iCounter][0]
            iVol = giTenseRhythm[iStep][iCounter][1] * i(gkDrumsAmp)
            iDur = giTenseRhythm[iStep][iCounter][2] * giRhythmRatio * iTickDur
            iAmp = i(gkAmp) * iVol
        endif
        
        iCounter += 1
        ;prints "\niInstr: %d, iVol: %f, iDur: %f, iAmp: %f\n", iInstr, iVol, iDur, iAmp
        
        if iInstr >= 0 && iDur > 0 && iVol > 0 then
            ;prints "----> scheduling instr: %d, iVol: %f, iDur: %f, iAmp: %f\n", 100 +iInstr, iVol, iDur, iAmp
            schedule 100 + iInstr, 0, iDur, iAmp
        endif
    od
    
endif

endin


////////////////////////////
//
// CHORDS INSTRUMENT 
// 
////////////////////////////
instr CHORDS

iTickDur = p3
iTick = p4
iMod = iTick % giChordsRatio
iMode = i(gkStateMode)
;prints "Chords Tick! [%d] duration: %f, iMod: %d\n", iTick, iTickDur, iMod

if iMod != 0 then
    ;prints "\t\tNot playing for iTick %d, turning off CHORDS", iTick
    ; exit the instrument if we don't have notes at this tick resolution
    turnoff
else

    iState = iMode == 1 ? rnd(i(gkState)) : i(gkState)
    iStep = int(iTick / giChordsRatio) % giChordsLen
    
    ;prints "CHORDS iStep: %d", iStep

    if iState < 0.5 then
        iBlockLen lenarray giChords, 2
    else
        iBlockLen lenarray giTenseChords, 2
    endif
    ;prints "\n-------------------------> iBlockLen: %d\n", iBlockLen
    
    iCounter = 0
    
    
    while iCounter < iBlockLen do
        
        iRnd = iState;= rnd(iState)
        
        if (iRnd < 0.5) then
            iNote = giChords[iStep][iCounter][0]
            iVol = giChords[iStep][iCounter][1] ;* i(gkChordsAmp)
            iDur = giChords[iStep][iCounter][2] * giChordsRatio * iTickDur
            ;iAmp = i(gkAmp) * iVol
        else
            iNote = giTenseChords[iStep][iCounter][0]
            iVol = giTenseChords[iStep][iCounter][1]; * i(gkChordsAmp)
            iDur = giTenseChords[iStep][iCounter][2] * giChordsRatio * iTickDur
            ;iAmp = i(gkAmp) * iVol
        endif
        
        iCounter += 1
        
        if iNote >= 0 && iDur > 0 && iVol > 0 then
            schedule "CHORDS_2", 0, iDur, mtof:i(iNote), iVol
        endif
    od
    
endif

endin


////////////////////////////
//
// MELODY INSTRUMENT
//
// Basic VCO2 + Dynamic stochastic approach to waveform synthesis conceived by Iannis Xenakis.
// https://csound.com/manual/gendy.html
// 
////////////////////////////
instr MELODY_1

aEnv      linseg 0.1, 0.1, p4

aSig      vco2  p4, p5 ; VCO-style oscillator
aSig2     gendy p4, 4, 1, 1, 1, p5 - k(5), p5 + k(5), 0.5, 0.5
kSig2Mix = gkState > 0.5 ? gkState - 0.5 : 0
aMix = (aSig + aSig2 * kSig2Mix) / 2

iRandPan = rnd(1)

gaMelodyL += aMix * aEnv * iRandPan
gaMelodyR += aMix * aEnv * (1 - iRandPan)

endin


////////////////////////////
//
//  MELODY_OUTPUT
//  
//  Heavily inspired by EXAMPLE 05A10_lpshold_loopseg.csd by Iain McCurdy
//
//  https://flossmanual.csound.com/sound-modification/envelopes
//
//  Generated melody is feeded into this instrument using global audio channels 
//  so that we can apply long filter envelopes
//
////////////////////////////
instr MELODY_OUTPUT
    kAmp portk gkAmp, 0.01
    kBtFreq   =            (gkBPM)/15  ; frequency of each 1/16th note
    kDecay    randomi      -10,10,0.2  ; decay shape of the filter.
    kCfBase   init 9       ;randomi      7,10, 0.2    ; base filter frequency (oct format)
    kCfEnv    randomi      0,4,0.2     ; filter envelope depth
    kRes      randomi      0.1,0.7, kBtFreq ; filter resonance
    kDist     randomi      0,1,0.1     ; amount of distortion
    
    ; filter envelope
    kCfOct    looptseg      kBtFreq, 0,0, (kCfBase + kCfEnv), kDecay, 1, (kCfBase)
    aFiltL    lpf18 gaMelodyL, cpsoct(kCfOct), kRes, (kDist^2)*10 ; filter audioL
    aFiltR    lpf18 gaMelodyR, cpsoct(kCfOct), kRes, (kDist^2)*10 ; filter audioR
    gaMelodyL      balance       aFiltL,gaMelodyL             ; balance levels
    gaMelodyR      balance       aFiltR,gaMelodyR             ; balance levels
    ;outs gaMelodyL * 0.99, gaMelodyR * 0.99
    
    gaGlobalOutputL += gaMelodyL * kAmp
    gaGlobalOutputR += gaMelodyR * kAmp
    
    clear gaMelodyL, gaMelodyR
endin


////////////////////////////
//
// BASS 1 INSTRUMENT
//
// 4 oscillators and lots of filters
//
// by René Nyffenegger
//
// http://www.adp-gmbh.ch/csound/instruments/bass01.html
//  
////////////////////////////
instr BASS_1

  ;prints "\nBASS_1 triggered"
  
  kAmp   port gkBassAmp, 0.1
  ifrq   init        p5
  ilen   init        p3
  iamp   init        p4

  k2    expseg 3000, 0.08, 9000, ilen, 1

  ksweep = k2 - 3000
  
  a1    oscil    iamp * 0.40, ifrq * 0.998 - .12, 1
  a2    oscil    iamp * 0.40, ifrq * 1.002 - .12, 2
  a3    oscil    iamp * 0.40, ifrq * 1.002 - .12, 1
  a4    oscil    iamp * 0.70, ifrq - .24        , 2
  
  a5  = a1 + a2 + a3 + a4
  a6    butterlp  a5, ksweep
  a7    butterlp  a6, ksweep
  a8    butterhp  a7, 65  
  a9    butterhp  a8, 65  
  a10   butterlp  a9, 1000
  asig  linen     a10, 0.01, ilen - 0.02, 0.01
  ;out   asig * kAmp;, asig * kAmp
  
  gaGlobalOutputL += asig * kAmp
  gaGlobalOutputR += asig * kAmp
  
endin


////////////////////////////
//
// BASS 2 INSTRUMENT
//
// Physical Model - A little out of tune :/
//
// by Hans Mikelson
// 
// https://www.csounds.com/mikelson/#waveguide
// 
//////////////////////////// 
instr BASS_2

  kAmp   port gkBassAmp, 0.1
; Initializations
  ifqc  = p5
  ipluck  =    1/ifqc * .25
  kcount  init 0
  adline  init 0
  ablock2 init 0
  ablock3 init 0
  afiltr  init 0
  afeedbk init 0

  koutenv linseg 0,.01,1,p3-.11,1,.1,0 ;Output envelope
  kfltenv linseg 0, 1.5, 1, 1.5, 0 

; This envelope loads the string with a triangle wave.
  kenvstr linseg 0,ipluck/4,-p4/2,ipluck/2,p4/2,ipluck/4,0,p3-ipluck,0

  aenvstr =     kenvstr
  ainput  tone  aenvstr,200

; DC Blocker
  ablock2 =     afeedbk-ablock3+.99*ablock2
  ablock3 =     afeedbk
  ablock  =     ablock2

; Delay line with filtered feedback
  adline  delay ablock+ainput,1/ifqc-15/sr
  afiltr  tone  adline,400

; Resonance of the body 
  abody1 reson afiltr, 110, 40
  abody1 =     abody1/5000
  abody2 reson afiltr, 70, 20
  abody2 =     abody2/50000

  afeedbk =     afiltr

  aout    =     afeedbk
  
  ares = 10*koutenv*(aout + kfltenv*(abody1 + abody2))
  
  ;outs ares * kAmp, ares * kAmp
  
  gaGlobalOutputL += ares * kAmp
  gaGlobalOutputR += ares * kAmp
  
endin


////////////////////////////
//
// BASS 3
//
// coded by Oeyvind Brandtsegg 2000, revised 2002
// 
// FM bass synth with warm distortion, variation of "FMBass1.csd"
// The 2-oscillator FM setup gives some overtones and "edge" to the sine wave,
// and the distortion is used more for "presence" and "edge" than actual dist.
// 
// midi controller 2 is used to control modulation index,
// giving more overtones and presence
// midi controller 1 is used to control distortion shaping,
// giving a more pronounced bass, with more enveloping, more attack
//
// http://oeyvind.teks.no/frames/Csound.htm
//
////////////////////////////
instr	BASS_3

    kAmp   port gkBassAmp, 0.1
    kState port gkState, 0.1
    ilen   init        p3
    ;inum	notnum
    icps	init p5  ;cpsmidi
    ;icps	= icps/4
    iamp	init p4 / 20  ;ampmidi	1500
    kctrl1	init 0.2      ;ctrl7	1, 1, 0, 1			;ch1, midi ctrl1, min, max
    kctrl2	init 0.3      ;ctrl7	1, 2, 0, 1			;ch1, midi ctrl1, min, max

        klfo2	oscil	0.5, 0.14 , giSine	
        klfo3	oscil	0.5, 0.26 , giSine
        klfo5	oscil	0.5, 0.87 , giSine

        klfo2	= klfo2 + 0.5
        klfo3	= klfo3 + 0.5
        klfo5	= klfo5 + 0.5

    kpregain	= klfo2*5 + 2
    kpostgain	init 1
    kpostgain	= 1-(klfo2*0.5) - (kctrl1*0.5)
    kshape1		= klfo5*0.2 + (kctrl1*5)
    kshape2		= kctrl1*10

        a_amp	linen	iamp, 0.001, ilen, 0.1
        k_env2	linseg	0, 0.01, 1, ilen, 0

        kfmndx	= (klfo3 * 40) + (600*kctrl2) 	;fm index, amplitude of modulator

        a1	oscili	kfmndx, icps*1.0,   giSine
        afmcps	= a1+icps
        a2	oscili	a_amp,  afmcps, giSine
        a2	distort1	a2, kpregain, kpostgain, kshape1, kshape2 *k_env2
        aL = a2 * kAmp
        aR = aL
        
        ;outs	aL, aR  ; direct output to speakers without using buses
        
        gaGlobalOutputL += aL
        gaGlobalOutputR += aR
        
        ; send a filtered version to delay and reverb buses
        aFilt butterhp aL, 100
        gaGlobalDelayL += aFilt * rnd(kState) * 0.1
        gaGlobalDelayR += aFilt * rnd(kState) * 0.1
        gaRevL += aFilt * 0.14
        gaRevR += aFilt * 0.14

endin


////////////////////////////
//
// DRUMS INSTRUMENTS
//
// by Iain McCurdy
//
// http://iainmccurdy.org/CsoundRealtimeExamples/Cabbage/Instruments/DrumMachines/TR-808.csd
//
////////////////////////////

////////////////////////////
//
// BASS DRUM
//
////////////////////////////
instr	101
	p3	=	2								;NOTE DURATION. SCALED USING GUI 'Decay' KNOB
	;SUSTAIN AND BODY OF THE SOUND
	kmul	transeg	0.2,p3*0.5,-15,0.01, p3*0.5,0,0					;PARTIAL STRENGTHS MULTIPLIER USED BY GBUZZ. DECAYS FROM A SOUND WITH OVERTONES TO A SINE TONE.
	kbend	transeg	0.5,1.2,-4, 0,1,0,0						;SLIGHT PITCH BEND AT THE START OF THE NOTE 
	asig	gbuzz	0.5,50*semitone(kbend),20,1,kmul,giCos				;GBUZZ TONE
	aenv	transeg	1,p3-0.004,-6,0							;AMPLITUDE ENVELOPE FOR SUSTAIN OF THE SOUND
	aatt	linseg	0,0.004,1							;SOFT ATTACK
	asig	=	asig*aenv*aatt

	;HARD, SHORT ATTACK OF THE SOUND
	aenv	linseg	1,0.07,0							;AMPLITUDE ENVELOPE (FAST DECAY)						
	acps	expsega	400,0.07,0.001,1,0.001						;FREQUENCY OF THE ATTACK SOUND. QUICKLY GLISSES FROM 400 Hz TO SUB-AUDIO
	aimp	oscili	aenv,acps,giSine						;CREATE ATTACK SOUND
	
	amix	=	((asig*0.5)+(aimp*0.35))*p4*0.95			;MIX SUSTAIN AND ATTACK SOUND ELEMENTS AND SCALE USING p4 (and again to 95%)
	
	aL,aR	pan2	amix,0.5							;PAN THE MONOPHONIC SOUND
    
    aFiltL buthp aL, 100
	aFiltR buthp aR, 100
	
    
    ; FX SEND
	kStut = 0.1 * rnd(gkState) ; randomise stutter send based on gkState
	gaStutSendL += aFiltL * kStut
	gaStutSendR += aFiltR * kStut
	
	kDel = 0.15 * rnd(gkState) ; randomise delay send
	
	gaGlobalDelayL += aFiltL * kDel
	gaGlobalDelayR += aFiltR * kDel
    
;	gaRevL = gaRevL + aL * .1 ; send to reverb too?
;	gaRevR = gaRevR + aR * .12
;		outs	aL,aR								;SEND AUDIO TO OUTPUTS
	gaDrumsL += aL              ; SEND TO DRUMS BUS
	gaDrumsR += aR
endin


////////////////////////////
//
// SNARE DRUM
//
////////////////////////////
instr	102
	;SOUND CONSISTS OF TWO SINE TONES, AN OCTAVE APART AND A NOISE SIGNAL
	ifrq  	=	342		;FREQUENCY OF THE TONES
	iNseDur	=	0.3		;DURATION OF THE NOISE COMPONENT
	iPchDur	=	0.1		;DURATION OF THE SINE TONES COMPONENT
	p3	=	iNseDur 	;p3 DURATION TAKEN FROM NOISE COMPONENT DURATION (ALWATS THE LONGEST COMPONENT)
	
	;SINE TONES COMPONENT
	aenv1	expseg	1,iPchDur,0.0001,p3-iPchDur,0.0001		;AMPLITUDE ENVELOPE
	apitch1	oscili	1,ifrq,giSine			;SINE TONE 1
	apitch2	oscili	0.25,ifrq*0.5,giSine		;SINE TONE 2 (AN OCTAVE LOWER)
	apitch	=	(apitch1+apitch2)*0.75				;MIX THE TWO SINE TONES

	;NOISE COMPONENT
	aenv2	expon	1,p3,0.0005					;AMPLITUDE ENVELOPE
	anoise	noise	0.75,0						;CREATE SOME NOISE
	anoise	butbp	anoise,10000,10000		;BANDPASS FILTER THE NOISE SIGNAL
	anoise	buthp	anoise,1000					;HIGHPASS FILTER THE NOISE SIGNAL
	kcf	expseg	5000,0.1,3000,p3-0.2,3000			;CUTOFF FREQUENCY FOR A LOWPASS FILTER
	anoise	butlp	anoise,kcf					;LOWPASS FILTER THE NOISE SIGNAL
	amix	=	((apitch*aenv1)+(anoise*aenv2))*p4		;MIX AUDIO SIGNALS AND SCALE ACCORDING TO GUI 'Level' CONTROL
	aL,aR	pan2	amix,0.55						;PAN THE MONOPHONIC AUDIO SIGNAL
	;	outs	aL,aR						;SEND AUDIO TO OUTPUTS
    gaDrumsL += aL              ; SEND TO DRUMS BUS
	gaDrumsR += aR
	
    ; FX SEND
	kStut = 0.9 * rnd(gkState) ; randomise stutter
	gaStutSendL += aL * kStut
	gaStutSendR += aR * kStut
	
	kDel = 0.9 * rnd(gkState) ; randomise delay send
	gaGlobalDelayL = gaGlobalDelayL + aL * kDel
	gaGlobalDelayR = gaGlobalDelayR + aR * kDel
	
	gaRevL += aL * .3
	gaRevR += aR * .4
endin


////////////////////////////
//
// CLOSED HIGH HAT
//
////////////////////////////
instr	103
	kFrq1	=	296		 	;FREQUENCIES OF THE 6 OSCILLATORS
	kFrq2	=	285 	
	kFrq3	=	365 	
	kFrq4	=	348 	
	kFrq5	=	420 	
	kFrq6	=	835 	
	idur	=	0.088			;DURATION OF THE NOTE
	p3	=	idur

	iactive	active	p1-1			;SENSE ACTIVITY OF PREVIOUS INSTRUMENT (OPEN HIGH HAT) 
	if iactive>0 then			;IF 'OPEN HIGH HAT' IS ACTIVE...
	 turnoff2	p1-1,0,0		;TURN IT OFF (CLOSED HIGH HAT TAKES PRESIDENCE)
	endif

	;PITCHED ELEMENT
	aenv	expsega	1,idur,0.001,1,0.001		;AMPLITUDE ENVELOPE FOR THE PULSE OSCILLATORS
	ipw	=	0.25				;PULSE WIDTH
	a1	vco2	0.5,kFrq1,2,ipw			;PULSE OSCILLATORS...			
	a2	vco2	0.5,kFrq2,2,ipw
	a3	vco2	0.5,kFrq3,2,ipw
	a4	vco2	0.5,kFrq4,2,ipw
	a5	vco2	0.5,kFrq5,2,ipw
	a6	vco2	0.5,kFrq6,2,ipw
	amix	sum	a1,a2,a3,a4,a5,a6		;MIX THE PULSE OSCILLATORS
	amix	reson	amix,5000,5000,1		;BANDPASS FILTER THE MIXTURE
	amix	buthp	amix,5000			;HIGHPASS FILTER THE SOUND...
	amix	buthp	amix,5000			;...AND AGAIN
	amix	=	amix*aenv			;APPLY THE AMPLITUDE ENVELOPE
	
	;NOISE ELEMENT
	anoise	noise	0.8,0				;GENERATE SOME WHITE NOISE
	aenv	expsega	1,idur,0.001,1,0.001		;CREATE AN AMPLITUDE ENVELOPE
	kcf	expseg	20000,0.7,9000,idur-0.1,9000	;CREATE A CUTOFF FREQ. ENVELOPE
	anoise	butlp	anoise,kcf			;LOWPASS FILTER THE NOISE SIGNAL
	anoise	buthp	anoise,8000			;HIGHPASS FILTER THE NOISE SIGNAL
	anoise	=	anoise*aenv			;APPLY THE AMPLITUDE ENVELOPE
	
	;MIX PULSE OSCILLATOR AND NOISE COMPONENTS
	amix	=	(amix+anoise)*p4*0.65
	aL,aR	pan2	amix,0.65			;PAN MONOPHONIC SIGNAL
	;	outs	aL,aR				;SEND TO OUTPUTS
	gaDrumsL += aL              ; SEND TO DRUMS BUS
	gaDrumsR += aR
	
    ; FX SEND
	kStut = 0.85 * rnd(gkState) ; randomise stutter
	gaStutSendL += aL * kStut
	gaStutSendR += aR * kStut
	
	kDel = 0.85 * rnd(gkState) ; randomise delay send
	gaGlobalDelayL = gaGlobalDelayL + aL * kDel
	gaGlobalDelayR = gaGlobalDelayR + aR * kDel
	
	gaRevL += aL * .15
	gaRevR += aR * .18
endin


////////////////////////////
//
// OPEN HIGH HAT
//
////////////////////////////
instr	104
	kFrq1	=	296 	;FREQUENCIES OF THE 6 OSCILLATORS
	kFrq2	=	285 	
	kFrq3	=	365 	
	kFrq4	=	348 	
	kFrq5	=	420 	
	kFrq6	=	835 	
	p3	=	0.5			;DURATION OF THE NOTE
	
	;SOUND CONSISTS OF 6 PULSE OSCILLATORS MIXED WITH A NOISE COMPONENT
	;PITCHED ELEMENT
	aenv	linseg	1,p3-0.05,0.1,0.05,0		;AMPLITUDE ENVELOPE FOR THE PULSE OSCILLATORS
	ipw	=	0.25				;PULSE WIDTH
	a1	vco2	0.5,kFrq1,2,ipw			;PULSE OSCILLATORS...
	a2	vco2	0.5,kFrq2,2,ipw
	a3	vco2	0.5,kFrq3,2,ipw
	a4	vco2	0.5,kFrq4,2,ipw
	a5	vco2	0.5,kFrq5,2,ipw
	a6	vco2	0.5,kFrq6,2,ipw
	amix	sum	a1,a2,a3,a4,a5,a6		;MIX THE PULSE OSCILLATORS
	amix	reson	amix,5000,5000,1		;BANDPASS FILTER THE MIXTURE
	amix	buthp	amix,5000			;HIGHPASS FILTER THE SOUND...
	amix	buthp	amix,5000			;...AND AGAIN
	amix	=	amix*aenv			;APPLY THE AMPLITUDE ENVELOPE
	
	;NOISE ELEMENT
	anoise	noise	0.8,0				;GENERATE SOME WHITE NOISE
	aenv	linseg	1,p3-0.05,0.1,0.05,0		;CREATE AN AMPLITUDE ENVELOPE
	kcf	expseg	20000,0.7,9000,p3-0.1,9000	;CREATE A CUTOFF FREQ. ENVELOPE
	anoise	butlp	anoise,kcf			;LOWPASS FILTER THE NOISE SIGNAL
	anoise	buthp	anoise,8000			;HIGHPASS FILTER THE NOISE SIGNAL
	anoise	=	anoise*aenv			;APPLY THE AMPLITUDE ENVELOPE
	
	;MIX PULSE OSCILLATOR AND NOISE COMPONENTS
	amix	=	(amix+anoise)*p4*0.25
	aL,aR	pan2	amix,0.65				;PAN MONOPHONIC SIGNAL
	gaDrumsL += aL              ; SEND TO DRUMS BUS
	gaDrumsR += aR
	;outs	aL,aR				;SEND TO OUTPUTS
	
    ; FX SEND
	kStut = 0.55 * rnd(gkState) ; randomise stutter
	gaStutSendL += aL * kStut
	gaStutSendR += aR * kStut
;	
	gaRevL += aL * .15
	gaRevR += aR * .14
	
	kactive	active	p1+1				;CHECK NUMBER OF ACTIVE INSTANCES OF CLOSED HIGH HAT INSTRUMENT
	if kactive>0 then			        ;IF HIGH-HAT CLOSED IS ACTIVE...
	 turnoff				            ;TURN OFF THIS INSTRUMENT
	endif
endin


////////////////////////////
//
// HIGH TOM
//
////////////////////////////
instr	105
	ifrq     	=	200				;FREQUENCY
	p3	  	=	0.5				;DURATION OF THIS NOTE

	;SINE TONE SIGNAL
	aAmpEnv	transeg	1,p3,-10,0.001				;AMPLITUDE ENVELOPE FOR SINE TONE SIGNAL
	afmod	expsega	5,0.125/ifrq,1,1,1			;FREQUENCY MODULATION ENVELOPE. GIVES THE TONE MORE OF AN ATTACK.
	asig	oscili	-aAmpEnv*0.6,ifrq*afmod,giSine		;SINE TONE SIGNAL

	;NOISE SIGNAL
	aEnvNse	transeg	1,p3,-6,0.001				;AMPLITUDE ENVELOPE FOR NOISE SIGNAL
	anoise	dust2	0.4, 8000				;GENERATE NOISE SIGNAL
	anoise	reson	anoise,400,800,1			;BANDPASS FILTER THE NOISE SIGNAL
	anoise	buthp	anoise,100				;HIGHPASS FILTER THE NOSIE SIGNAL
	anoise	butlp	anoise,1000				;LOWPASS FILTER THE NOISE SIGNAL
	anoise	=	anoise * aEnvNse			;SCALE NOISE SIGNAL WITH AMPLITUDE ENVELOPE
	
	;MIX THE TWO SOUND COMPONENTS
	amix	=	(asig + anoise)*p4
	aL,aR	pan2	amix,0.35					;PAN MONOPHONIC SIGNAL
    
    gaDrumsL += aL                      ; SEND TO DRUMS BUS
	gaDrumsR += aR
	;	outs	aL,aR					;SEND AUDIO TO OUTPUTS
		
    ; FX SEND
	kStut = 0.5 * rnd(gkState) ; randomise stutter
	gaStutSendL += aL * kStut
	gaStutSendR += aR * kStut
;	
;	gaRevL = gaRevL + aL * .1
;	gaRevR = gaRevR + aR * .1
endin


////////////////////////////
//
// MID TOM
//
////////////////////////////
instr	106
	ifrq     	=	133		 		;FREQUENCY
	p3	  	=	0.6				;DURATION OF THIS NOTE

	;SINE TONE SIGNAL
	aAmpEnv	transeg	1,p3,-10,0.001				;AMPLITUDE ENVELOPE FOR SINE TONE SIGNAL
	afmod	expsega	5,0.125/ifrq,1,1,1			;FREQUENCY MODULATION ENVELOPE. GIVES THE TONE MORE OF AN ATTACK.
	asig	oscili	-aAmpEnv*0.6,ifrq*afmod,giSine		;SINE TONE SIGNAL

	;NOISE SIGNAL
	aEnvNse	transeg	1,p3,-6,0.001				;AMPLITUDE ENVELOPE FOR NOISE SIGNAL
	anoise	dust2	0.4, 8000				;GENERATE NOISE SIGNAL
	anoise	reson	anoise, 400,800,1			;BANDPASS FILTER THE NOISE SIGNAL
	anoise	buthp	anoise,100				;HIGHPASS FILTER THE NOSIE SIGNAL
	anoise	butlp	anoise,600				;LOWPASS FILTER THE NOISE SIGNAL
	anoise	=	anoise * aEnvNse			;SCALE NOISE SIGNAL WITH AMPLITUDE ENVELOPE
	
	;MIX THE TWO SOUND COMPONENTS
	amix	=	(asig + anoise)*p4
	aL,aR	pan2	amix,0.25					;PAN MONOPHONIC SIGNAL
	;	outs	aL,aR					;SEND AUDIO TO OUTPUTS
	gaDrumsL += aL              ; SEND TO DRUMS BUS
	gaDrumsR += aR
	
    ; FX SEND
	kStut = 0.5 * rnd(gkState); randomise stutter
	gaStutSendL += aL * kStut
	gaStutSendR += aR * kStut
;	
;	gaRevL = gaRevL + aL * .1
;	gaRevR = gaRevR + aR * .1
endin


////////////////////////////
//
// LOW TOM
//
////////////////////////////
instr	107
	ifrq     	=	90				;FREQUENCY
	p3 	 	=	0.7		 		;DURATION OF THIS NOTE

	;SINE TONE SIGNAL
	aAmpEnv	transeg	1,p3,-10,0.001				;AMPLITUDE ENVELOPE FOR SINE TONE SIGNAL
	afmod	expsega	5,0.125/ifrq,1,1,1			;FREQUENCY MODULATION ENVELOPE. GIVES THE TONE MORE OF AN ATTACK.
	asig	oscili	-aAmpEnv*0.6,ifrq*afmod,giSine		;SINE TONE SIGNAL

	;NOISE SIGNAL
	aEnvNse	transeg	1,p3,-6,0.001				;AMPLITUDE ENVELOPE FOR NOISE SIGNAL
	anoise	dust2	0.4, 8000				;GENERATE NOISE SIGNAL
	anoise	reson	anoise,40,800,1				;BANDPASS FILTER THE NOISE SIGNAL
	anoise	buthp	anoise,100				;HIGHPASS FILTER THE NOSIE SIGNAL
	anoise	butlp	anoise,600				;LOWPASS FILTER THE NOISE SIGNAL
	anoise	=	anoise * aEnvNse			;SCALE NOISE SIGNAL WITH AMPLITUDE ENVELOPE
	
	;MIX THE TWO SOUND COMPONENTS
	amix	=	(asig + anoise)*p4
	aL,aR	pan2	amix,0.15				;PAN MONOPHONIC SIGNAL
	;	outs	aL,aR					    ;SEND AUDIO TO OUTPUTS
	gaDrumsL += aL                          ; SEND TO DRUMS BUS
	gaDrumsR += aR
    
    ; FX SEND
	kStut = 0.2 * rnd(gkState) ; randomise stutter
	gaStutSendL += aL * kStut
	gaStutSendR += aR * kStut
;	
;	gaRevL = gaRevL + aL * .1
;	gaRevR = gaRevR + aR * .1
endin


////////////////////////////
//
// CYMBAL
//
////////////////////////////
instr	108	
	kFrq1	=	296 			;FREQUENCIES OF THE 6 OSCILLATORS
	kFrq2	=	285
	kFrq3	=	365
	kFrq4	=	348     
	kFrq5	=	420
	kFrq6	=	835
	p3	=	2			;DURATION OF THE NOTE

	;SOUND CONSISTS OF 6 PULSE OSCILLATORS MIXED WITH A NOISE COMPONENT
	;PITCHED ELEMENT
	aenv	expon	1,p3,0.0001		;AMPLITUDE ENVELOPE FOR THE PULSE OSCILLATORS 
	ipw	=	0.25			;PULSE WIDTH      
	a1	vco2	0.5,kFrq1,2,ipw		;PULSE OSCILLATORS...  
	a2	vco2	0.5,kFrq2,2,ipw
	a3	vco2	0.5,kFrq3,2,ipw
	a4	vco2	0.5,kFrq4,2,ipw
	a5	vco2	0.5,kFrq5,2,ipw                                                                   
	a6	vco2	0.5,kFrq6,2,ipw
	amix	sum	a1,a2,a3,a4,a5,a6		;MIX THE PULSE OSCILLATORS
	amix	reson	amix,5000,5000,1		;BANDPASS FILTER THE MIXTURE
	amix	buthp	amix,10000			;HIGHPASS FILTER THE SOUND
	amix	butlp	amix,12000			;LOWPASS FILTER THE SOUND...
	amix	butlp	amix,12000			;AND AGAIN...
	amix	=	amix*aenv			;APPLY THE AMPLITUDE ENVELOPE
	
	;NOISE ELEMENT
	anoise	noise	0.8,0				;GENERATE SOME WHITE NOISE
	aenv	expsega	1,0.3,0.07,p3-0.1,0.00001	;CREATE AN AMPLITUDE ENVELOPE
	kcf	expseg	14000,0.7,7000,p3-0.1,5000	;CREATE A CUTOFF FREQ. ENVELOPE
	anoise	butlp	anoise,kcf			;LOWPASS FILTER THE NOISE SIGNAL
	anoise	buthp	anoise,8000			;HIGHPASS FILTER THE NOISE SIGNAL
	anoise	=	anoise*aenv			;APPLY THE AMPLITUDE ENVELOPE            

	;MIX PULSE OSCILLATOR AND NOISE COMPONENTS
	amix	=	(amix+anoise)*p4*0.85
	aL,aR	pan2	amix,0.05			;PAN MONOPHONIC SIGNAL
	
	;	outs	aL,aR				;SEND TO OUTPUTS
	gaDrumsL += aL              ; SEND TO DRUMS BUS
	gaDrumsR += aR
	
	; FX SEND
	kStut = 0.1 * rnd(gkState) ; randomise stutter
	gaStutSendL = gaStutSendL + aL * kStut
	gaStutSendR = gaStutSendR + aR * kStut
	
	;gaRevL = gaRevL + aL * .3
	;gaRevR = gaRevR + aR * .4
endin


////////////////////////////
//
// DRUMS OUTPUT INSTRUMENT
//
////////////////////////////
instr DRUMS_OUTPUT
 
    ;outs gaDrumsL * 0.99, gaDrumsR * 0.99
    gaGlobalOutputL += gaDrumsL
    gaGlobalOutputR += gaDrumsR
    
    clear gaDrumsL, gaDrumsR
    
endin


////////////////////////////
//
// CHORDS 1 INSTRUMENT - NOT WORKING AS INTENDED YET, super heavy!
//
////////////////////////////
instr CHORDS_1

    iattack = 0.37
    idecay = 0.2
    isustain = 0.8
    irelease = 0.4
    aenv madsr iattack, idecay, isustain, irelease
    ifreq = p4
    iamp = p5
	asig poscil iamp, ifreq, giSine
    asig = aenv * asig * gkChordsAmp
	aleft, aright pan2 asig, 0.5
	;outs aleft, aright
	gaGlobalOutputL += aleft
	gaGlobalOutputR += aright
	
endin


////////////////////////////
//
// CHORDS INSTRUMENT - CINEMATOGRAPHIC STRINGS (simplified)
//
// by Scott Daughtrey
//
////////////////////////////
instr CHORDS_2

    kPhs  = trandom(1, 0, 1)
    kAmp  = portk(gkChordsAmp, 0.01)
    kState = portk(gkState, 0.5)
    ; saw(ramp)/pulse - positive side of waveform is saw/ramp, negative is square
    ; p4  = pitch (including detune [5-voice "unison"] 
    ; p5  = amp
    ; p6  = phase (0 - 1, randomized per trigger event) 

    aEnv  = madsr(.29, 3.004, .31, .35)
    iNyx  = .25 ; bandlimiting value
    ; pwm
    kPw   = rspline(.5, .66, .3, .5) ; width of pos. part of pulse cycle, based on how wide ramp wave will be   
    aPwm1 = vco2(.7, p4, 2, kPw, p6, iNyx)
    kPw2  = rspline(.6, .7, .4, .6)
    aPwm2 = vco2(.3, p4 * 4, 2, kPw2, kPhs, iNyx)
    ; ramp saw
    aRamp = vco2(.7, p4, 20, .99, kPhs, iNyx)
    aRmp2 = vco2(.3, p4 * 2, 20, .99, kPhs, iNyx)
    
    aMix1 = dcblock2(aRamp * (aPwm1 + .7) + (aPwm1 -.7), 256)
    aMix2 = dcblock2(aRmp2 * (aPwm2 + .3) + (aPwm2 -.3), 256)
    kQ    = adsr(.06, 4.358, .08, .06)/7
    a1 moogvcf2 aMix1 * p5 * aEnv, 3000, .12 - kQ * .68
    a2 moogvcf2 aMix2 * p5 * aEnv, 4000, .12 - kQ * .68
    iAmp  = .17 ; amp. attenuation
    a1L, a1R pan2 a1, rspline(0.35, 0.6, 0.1, .15)
    a2L, a2R pan2 a2, rspline(0.4, 0.75, 0.2, .3)
    ;outs (a1 + a2), (a1 + a2)
    aL = (a1L + a2L) * kAmp * kState
    aR = (a1R + a2R) * kAmp * kState
    ; the output of this instrument is directly in the chorus instrument
    ; that in turn will be feeded into the reverb instrument
    gaChorusL  += aL
    gaChorusR  += aL
    ; send this straight to the reverb too for an exponential boost depending on kState
    gaRevL += aL * kState
    gaRevR += aR * kState
    gaGlobalDelayL += aL * 0.5
    gaGlobalDelayR += aR * 0.5
endin   


instr GLOBAL_OUTPUT

    kAmp portk gkAmp, 0.1
    
    kthreshold = .95
    icomp1 = 1.75
    icomp2 = 1.15
    irtime = 0.15
    iftime = 0.15
    
    aL = gaGlobalOutputL * kAmp
    aR = gaGlobalOutputR * kAmp
    
    aL dam aL, kthreshold, icomp1, icomp2, irtime, iftime
    aR dam aR, kthreshold, icomp1, icomp2, irtime, iftime
    
    ;outs gaGlobalOutputL * kAmp, gaGlobalOutputR * kAmp
    outs aL * 0.525, aR * 0.525
    
    clear gaGlobalOutputL, gaGlobalOutputR
    
endin


////////////////////////////
//
// CHORUS FX
//
// Always active, uses global audio channels that are fed into from chords
//
// Goes straight into Reverb
// 
////////////////////////////
instr   CHORUS

    kMod  = lfo(3, .6) + 3
    kMod2 = lfo(3, .65) + 3
    aDelL = vdelay(gaChorusL, 10 + kMod, 20)
    aDelR = vdelay(gaChorusR, 10 + kMod2, 20)

    ; goes into reverb
    gaRevL  += gaChorusL * 0.95 + aDelL * .6
    gaRevR  += gaChorusR * 0.95 + aDelR * .6

    ;outs gaChorusL * 0.95 + aDelL * .3, gaChorusR * 0.95 + aDelR * .3
    clear gaChorusL, gaChorusR
    
endin

////////////////////////////
//
// REVERB FX INSTRUMENT
//
// Always active, uses global audio channels that are fed into from other instruments
// 
////////////////////////////
instr REVERB

    ainL = gaRevL
    ainR = gaRevR
    
    ; test
    ;aTest pinkish .8
    ;ainL = aTest
    ;ainR = aTest
    
    denorm ainL
    denorm ainR
    ;arevL, arevR 	freeverb  ainL, ainR, gkROOM, gkHF

    kRoom 	    port gkRoom, 0.1 ; port to the UI value in 0.1s
    kHF		    port gkHF, 0.1
    kRevLev 	port gkRevLev, 0.1
    arevL, arevR reverbsc ainL, ainR, kRoom * 0.995, kHF * sr / 2
    
    ;outs arevL * kRevLev, arevR * kRevLev	;  Audio to DAC -  REVERB out 	
    gaGlobalOutputL += arevL * kRevLev
    gaGlobalOutputR += arevR * kRevLev
    
    ;outs aTest * gkRevLev, aTest * gkRevLev
    ;outs aTest, aTest
    gaRevL = 0
    gaRevR = 0
    
endin


////////////////////////////
//
// LEAD DELAY FX INSTRUMENT
//
// Always active, uses global audio channels that are fed into from lead instrument
// 
////////////////////////////
instr LEAD_DELAY

  iFdbackL =        0.6           ; left feedback ratio
  aDelayL  init     0             ; initialize delayed signal
  aDelayL  delay    gaDelayL + (aDelayL * iFdbackL), .35 ;delay in seconds
  
  iFdbackR =        0.65          ; right feedback ratio
  aDelayR  init     0             ; initialize delayed signal
  aDelayR  delay    gaDelayR + (aDelayR * iFdbackR), .3 ;delay in seconds

  aOutL    = gaDelayL + (aDelayL * 0.6)
  aOutR    = gaDelayR + (aDelayR * 0.6)
  
  ; lead delay goes also into reverb
  gaRevL = gaRevL + aOutL
  gaRevR = gaRevR + aOutR
  
  ;outs(aOutL, aOutR)
  gaGlobalOutputL += aOutL
  gaGlobalOutputR += aOutR
  
  gaDelayL = 0
  gaDelayR = 0
  
endin


////////////////////////////
//
// GLOBAL DELAY FX INSTRUMENT 
//
// Always active, uses global audio channels that are fed into from other instruments
// 
////////////////////////////
instr GLOBAL_DELAY

  INITIALIZATION:
  
  iState = i(gkState)
  iRandFdbk = rnd(iState)
  iRandBeat = int(iRandFdbk * giTickSteps)
  iBar = 60 / i(gkBPM) * 4 ; 4/4 at BPM
  iDelay init 0.25
  iDelay = iBar / 16 ; default 1/16 of a bar ;* iRandBeat
  
  if iDelay > 0 then
  
      ;prints "iDelay: %f, iRandFdbk: %f, iRandBeat: %d\n", iDelay, iRandFdbk, iRandBeat
  
      iFdbackL =        0.5 * iRandFdbk          ; left feedback ratio
      aDelayL  init     0                       ; initialize delayed signal
      aDelayL  delay    gaGlobalDelayL + (aDelayL * iFdbackL), iDelay ;delay in seconds
  
      iFdbackR =        0.55  * iRandFdbk          ; right feedback ratio
      aDelayR  init     0                          ; initialize delayed signal
      aDelayR  delay    gaGlobalDelayR + (aDelayR * iFdbackR), iDelay ;delay in seconds

      rireturn
  
      aOutL    = gaGlobalDelayL + (aDelayL * 0.4)
      aOutR    = gaGlobalDelayR + (aDelayR * 0.4)
  
      ;outs(aOutL, aOutR)
      gaGlobalOutputL += aOutL
      gaGlobalOutputR += aOutR
        
      gaGlobalDelayL = 0
      gaGlobalDelayR = 0
  
  endif
  
  kChanged changed2 gkState, gkBPM
  if kChanged == 1 then
    reinit INITIALIZATION
  endif
  
endin


////////////////////////////
//
// STUTTER FX
//
// Always active, uses global audio channels that are fed into from drums instruments
// 
////////////////////////////
instr    STUTTER
        
    ; input parameters for bbcut 
    ;; << 4/4 >>
    initialization:
    
    isubdiv        =    8
    ibarlen        =    2     
    iphrase        =    8     
    irepeats       =    4     
    istutspd       =    4     
    istutchnc      =    1             
    
    kChanged = changed2(gkBPM)
    printk2 kChanged

    if kChanged == 1 then
        reinit initialization
    endif
    
    aL, aR    bbcuts    gaStutSendL, gaStutSendR,   i(gkBPM)/60, isubdiv,  ibarlen,  iphrase, irepeats, istutspd, istutchnc
    
    rireturn
   
    kRandPan rspline 0, 1, 60/gkBPM, 60/gkBPM * 4
    
    ;outs aL * 0.95 * kRandPan, aR * 0.95 * (1 - kRandPan)
    gaGlobalOutputL += aL * 0.95 * kRandPan
    gaGlobalOutputR += aR * 0.95 * (1 - kRandPan)
    
    clear gaStutSendL
    clear gaStutSendR

endin


////////////////////////////
//
// UPDATE SCALE INSTRUMENT
//
// Updates the current scale using the string passed as p4
// 
////////////////////////////
instr UPDATE_SCALE

    Scale = p4
    set_scale(Scale)

    turnoff ; turns itself off

endin


////////////////////////////
//
// UI INSTRUMENT
//
// Continuously (well, every 10ms) updates the variables coming from an external software
// 
////////////////////////////
instr UI

    // check every 10 ms
    kCheck metro 10

    if kCheck == 1 then

        gkAmp   chnget "amp"
        gkBPM   chnget "bpm"
        gkState chnget "state"
        gkStateMode chnget "stateMode"
        gkMelodyAmp chnget "melodyAmp"
        gkBassAmp   chnget "bassAmp"
        gkDrumsAmp  chnget "drumsAmp"
        gkChordsAmp chnget "chordsAmp"

        gkLeadAmp   chnget "leadAmp"
        gkLeadGlide chnget "leadGlide"
        gkLeadNote  chnget "leadNote"
        gkLeadWave  chnget "leadWave"
        
        gkLeadFiltFreq      chnget "leadFiltFreq"
        gkLeadFiltRes       chnget "leadFiltRes"
        gkLeadFiltLFOToggle chnget "leadFiltLFOToggle"
        gkLeadFiltLFOFreq   chnget "leadFiltLFOFreq"
        
        ;printks "gkLeadWave: %f, gkLeadFiltFreq: %f\n", 0.1, gkLeadWave, gkLeadFiltFreq
    endif

endin

</CsInstruments>
<CsScore>
;causes Csound to run for about 7000 years...
f0 z

// ALWAYS ON INSTRUMENTS
i"MELODY_OUTPUT" 0 z
i"DRUMS_OUTPUT" 0 z
i"GLOBAL_OUTPUT" 0 z
i"REVERB" 0 z
i"LEAD_DELAY" 0 z
i"GLOBAL_DELAY" 0 z
i"STUTTER" 0 z
i"CHORUS" 0 z
i"UI" 0 z

; TEST TRIGGERS
;i"INITIALIZATION" 3 z
;i"GENERATOR" 4 z
;i2 0 z
;i1 0 z
;i"UPDATE_SCALE" 3 0.1 "mix"
;i"UPDATE_SCALE" 6 0.1 "phry"

</CsScore>
</CsoundSynthesizer>