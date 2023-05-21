;Half-Life Meme Maker
;Pandela 2023
#SingleInstance force
#Persistent
SetTitleMatchMode,2
wao := ""
ms := ""
AlreadyRunning := 0
SeekInterval := "0.1"
AudioArray := []
DelayArray := []
FilterArray := []
;global MyTreeView
px := 0
py := 0
Inactive := 0
counter2 := 0
#Include ./AutoXYWH.ahk ;https://www.autohotkey.com/boards/viewtopic.php?f=6&t=1079



FixVideo := 0 ;Convert all frames in video to keyframes
KeyframeInterval := 1 ;Set to 1 to make ALL frames keyframe, this should probably be 1 if you're using the flag above
Process,Close,ffplay.exe ;close background ffplay process if its running

;gui,Color,Gray
;gui 2:, +LastFound +E0x00010000 ;The ExStyle allows the parent to take focus if it's clicked.

gui 2: color,gray
gui 2: Add, Button, x134 y574 w176 h81 hWndhBtnOk gSkipBackward, <<<===
gui 2: Add, Button, x310 y574 w176 h81 hWndhBtnOk2 gSkipForward, ===>>>
gui 2: Add, Button, x134 y492 w352 h81 hWndhBtnOk3 gStopPlay, Stop/Play
gui 2: Add, Button, x134 y655 w352 h45 hWndhBtnOk4 gNudgeVideo, Nudge
gui 2:  Show, w1280 h720, H.L.M.M
gui 2:  +Resize

TreeRoot := "C:\Users\Pandela\Downloads\Half-Life 1"
File := "C:\Users\Pandela\Documents\balls.txt"
Input := "C:\Users\Pandela\Documents\AHK-Studio-master\Projects\mkvmswsxlbw.webm" ;"C:\Users\Pandela\Downloads\7e17d52906dae7760cfb35d671ea2412_1.mp4" ;"C:\Users\Pandela\Documents\CHEEZCOFI.mp4" ;"C:\msys64\home\Pandela\cofi1.mkv"


FileDelete,%File%
;MakeTree()
gosub,MakeTree
;run % A_ScriptDir . "\SoundBrowser.ahk",,,NewPID
 ; wait until active
WinWait,%TreeRoot%
  ; get window id
id := WinExist()
  ; now ie is active but the page isn't loaded
;Sleep 5000
  ; better be loaded now
  ; then get title from saved window id
WinGetTitle,Title,ahk_id %id%
;MsgBox,%ErrorLevel%: %NEWPID% %Title%
TreeWindow := WinExist(Title)
TIDSWindow := WinExist("H.L.M.M")
WinGetPos,winX,winY,winW,winH,H.L.M.M
;msgbox % winX " " winY " " winW " " winH
test1 := winW / 2 + 150
test2 := winH / 2 + 30
test3 := winW / 2 - 180
test4 := winH / 2 - 80
test8 := winH + 1

    	;Embed FFplay inside our gui
DllCall("SetParent", "uint", TreeWindow, "uint", TIDSWindow)
id_2 := WinExist("ahk_id " TreeWindow)
WinSet,Redraw,,%Title%


	; Move and resize FFPlay window. Note that if SWP_NOSENDCHANGING
	; is omitted, it incorrectly readjusts the size of its client area.
DllCall("SetWindowPos", "uint", TreeWindow, "uint", 0
    , "int", test1, "int",test2, "int", test3, "int", test4
    , "uint", SWP_SHOWWINDOW)

sleep, 500
WinSet,Redraw,,A
WinActivate,H.L.M.M
WinMove,H.L.M.M,,,,,%test8%
FirstRun := 1
WinMaximize,H.L.M.M
DisplayTimestamp()
return


WM_LBUTTONDOWN() {
   If (A_Gui)
      PostMessage, 0xA1, 2
}


F2::
ControlSend,,{Space},H.L.M.M
return


F3::
OpenVideo:
SplitPath,Input,,sourceFolder,,filename2

Process,Close,ffplay.exe
gosub, checkFix
ffplay := ComSpec " /c ffplay -seek_interval " SeekInterval " -i " Input " -hide_banner 2>> " File
run, % ffplay,,Hide,ffplayPID

WinWaitActive,ahk_class SDL_app,,3
ControlSend,,{Space},ahk_class SDL_app ;pause video initially
sleep, 500

sleep, 50

if (AlreadyRunning != 1) {
lt := new CLogTailer(File, Func("NewLine"))
AlreadyRunning := 1
}




TIDSWindow := WinExist("H.L.M.M")
FFPlayWindow := WinExist("ahk_class SDL_app")

; Get size of FFPlay window, excluding caption and borders:
WinGetActiveStats,%FFPlayWindow%,FFPlayW,FFPlayH,x,y
newX := FFPlayW / 2
NewY := FFPlayH / 2
WinMove,ahk_class SDL_app,,%x%,%y%,%NewX%,%NewY%
;msgbox % FFPlayWindow

;Embed FFplay inside our gui
DllCall("SetParent", "uint", FFplayWindow, "uint", TIDSWindow)
id_1 := WinExist("ahk_id " FFplayWindow)

;msgbox % px " " py " " pw " " ph


; Move and resize FFPlay window. Note that if SWP_NOSENDCHANGING
; is omitted, it incorrectly readjusts the size of its client area.
DllCall("SetWindowPos", "uint", FFPlayWindow, "uint", 0
, "int", 0, "int",0, "int", newX, "int", NewY
, "uint",SWP_SHOWWINDOW|SWP_NOSENDCHANGING)

if (px != 0) && (FirstRun = 0) {
	newX := pW
	newY := pH
	py := (py - 20)
}

; Move and resize FFPlay window. Note that if SWP_NOSENDCHANGING
; is omitted, it incorrectly readjusts the size of its client area.
DllCall("SetWindowPos", "uint", FFPlayWindow, "uint", 0
, "int", px, "int",py, "int", newX, "int", NewY
, "uint",SWP_SHOWWINDOW|SWP_NOSENDCHANGING)

FirstRun := 0 ;;;;asd
return


NewLine(text){
	match := RegExMatch(text,"\d+\.\d+",timestamp)
	global ms := ceil((timestamp * 1000))
	
	if (wao = 1) {
		ToolTip % "Timestamp: " timestamp "`n ms: " ms "`n"
		GuiControl,,SoundOffset,%ms%
	}
	
	if (wao = 0) {
		ToolTip
	}
}



;https://www.autohotkey.com/boards/viewtopic.php?t=47894#p215692
class CLogTailer {
	__New(logfile, callback){
		this.file := FileOpen(logfile, "r-d")
		this.callback := callback
		; Move seek to end of file
		this.file.Seek(0, 2)
		fn := this.WatchLog.Bind(this)
		SetTimer, % fn, 100
	}
	
	WatchLog(){
		Loop {
			p := this.file.Tell()
			l := this.file.Length
			line := this.file.ReadLine(), "`r`n"
			len := StrLen(line)
			if (len){
				RegExMatch(line, "[\r\n]+", matches)
				if (line == matches)
					continue
				this.callback.Call(Trim(line, "`r`n"))
			}
		} until (p == l)
	}
}


2GuiClose:
Process,Close,ffplay.exe
ExitApp



DisplayTimestamp()
{
gosub, displayTS
}


DisplayTS:
loop {
	sleep, 200
	if WinActive("H.L.M.M") else WinActive("ahk_class SDL_app") {
		global wao := 1
	}
	
	if !WinActive("H.L.M.M") && !WinActive("ahk_class SDL_app") {
		global  wao := 0
	}
}
return

CheckFix:
SplitPath,Input,,Dir,,Filename
NewFile := Dir "\" Filename . ".mkv"

FixIt := ComSpec " /c ffmpeg -i " Input " -g 10 -bf 0 -crf 20 -y -ac 2 -c:a pcm_u32le -f nut -fflags +genpts " NewFile

if !FileExist(NewFile) && (FixVideo = 1) {
	runwait, % FixIt
	
	sleep, 100
	global Input := NewFile
}

Return

SkipForward:
if (Inactive = 1) {
	WinGet, hWnd2, ID, ahk_id %id_1%
	WinActivate,ahk_id %hWnd2%
	Inactive := 0
}
Forward(ms)
Return


SkipBackward:
if (Inactive = 1) {
	WinGet, hWnd2, ID, ahk_id %id_1%
	WinActivate,ahk_id %hWnd2%
	Inactive := 0
}
Backward(ms)
Return

F8::
WinGet, hWnd2, ID, ahk_id %id_1%
;msgbox % hWnd2
WinActivate,ahk_id %hWnd2%
WinGetPos, pX,pY,pW,pH,ahk_id %id_1%
WinGet, hWnd, ID, H.L.M.M
msgbox % px " " py " " pw " " ph
return


StopPlay:
if (Inactive = 1) {
	WinGet, hWnd2, ID, ahk_id %id_1%
	WinActivate,ahk_id %hWnd2%
	Inactive := 0
}
StopAndPlay()
Return

NudgeVideo:
if (Inactive = 1) {
	WinGet, hWnd2, ID, ahk_id %id_1%
	WinActivate,ahk_id %hWnd2%
	Inactive := 0
}
Nudge()
Return



2GuiSize:
sleep, 50
WinGetPos,winX,winY,winW,winH,H.L.M.M
test1 := winW / 2 + 150
test2 := winH / 2 + 30
test3 := winW / 2 - 180
test4 := winH / 2 - 80
;If (A_EventInfo == 1) {
;        Return
;}
balls := !balls
;msgbox % balls

if (balls = 1) {
	thisX := "x0.0"
	thisY := "*y+1.0"
}

if (balls = 0) {
	thisX := "x0.0"
	thisY := "y0.0"
}

AutoXYWH( thisX " " thisY, hBtnOk)
AutoXYWH( thisX " " thisY, hBtnOk2)
AutoXYWH( thisX " " thisY, hBtnOk3)
AutoXYWH( thisX " " thisY, hBtnOk4)
	; Move and resize FFPlay window. Note that if SWP_NOSENDCHANGING
	; is omitted, it incorrectly readjusts the size of its client area.
DllCall("SetWindowPos", "uint", TreeWindow, "uint", 0
    , "int", test1, "int",test2, "int", test3, "int",test4
    , "uint", SWP_NOACTIVATE|SWP_SHOWWINDOW|SWP_NOSENDCHANGING)
sleep, 20
WinSet,Redraw,,A
;WinActivate,H.L.M.M
return
Return











Forward(ms)
{
	ControlSend,,{Right},H.L.M.M
	sleep, 50
	ControlSend,,S,H.L.M.M
	if (ms = 0){
		ControlSend,,S,H.L.M.M
	}
	if (ms = 0){
		ControlSend,,S,H.L.M.M
	}
	if (ms = 0){
		ControlSend,,S,H.L.M.M
	}
	if (ms = 0){
		ControlSend,,S,H.L.M.M
	}
	if (ms = 0){
		ControlSend,,S,H.L.M.M
	}
	if (ms = 0){
		ControlSend,,S,H.L.M.M
	}
	if (ms = 0){
		ControlSend,,S,H.L.M.M
	}
	if (ms = 0){
		ControlSend,,S,H.L.M.M
	}
}



Backward(ms)
{
	ControlSend,,{Left},H.L.M.M
	sleep, 50
	ControlSend,,S,H.L.M.M
	if (ms = 0){
		ControlSend,,S,H.L.M.M
	}
	if (ms = 0){
		ControlSend,,S,H.L.M.M
	}
	if (ms = 0){
		ControlSend,,S,H.L.M.M
	}
	if (ms = 0){
		ControlSend,,S,H.L.M.M
	}
	if (ms = 0){
		ControlSend,,S,H.L.M.M
	}
	if (ms = 0){
		ControlSend,,S,H.L.M.M
	}
	if (ms = 0){
		ControlSend,,S,H.L.M.M
	}
	if (ms = 0){
		ControlSend,,S,H.L.M.M
	}
}


StopAndPlay()
{
	ControlSend,,{Space},H.L.M.M
}

Nudge()
{
	ControlSend,,S,H.L.M.M
}


;PostLeftClick(x, y, hwnd) {
;	PostMessage, 0x201, 0x0001, ((y<<16)^x), , ahk_id%hwnd%         ;WM_LBUTTONDOWN
;	PostMessage, 0x202 , 0, ((y<<16)^x), , ahk_id%hwnd%               ;WM_LBUTTONUP	
;}


	
#Include ./SoundBrowser.ahk


testSound:
if (ReplaceBGM = 1) {
	input := newVideo
}

if (KeepSound = 1) {
	input := KeepSoundFile
}

AddSounds := ComSpec " /c ffmpeg -i " chr(0x22) input chr(0x22)  " "
AddFilters := " -filter_complex " chr(0x22) 
Amt := AudioArray.Length() 
loop %Amt%
{
	AddSounds .= " -i " chr(0x22) AudioArray[A_Index] chr(0x22) 
}

loop %Amt%
{
	if (FilterArray[A_Index] = "") {
		ApplyFilter := ""
	}
	
	if (FilterArray[A_Index] != "") {
		ApplyFilter := "," FilterArray[A_Index]
		msgbox % ApplyFilter
	}
	
	
	
	AddFilters .= "[" A_Index "]adelay=" DelayArray[A_Index] "|" DelayArray[A_Index] ApplyFilter "[HL" A_Index "];"
	MixStack .= "[HL" A_Index "]"
}
KeepSoundFile := sourceFolder "\output_" counter2 ".mkv"
KeepSoundFileNext := sourceFolder "\output_" counter2+1 ".mkv"


FinalCommand := AddSounds " " AddFilters "[0]" MixStack "amix=" (Amt + 1) ":normalize=false" chr(0x22) " -c:v copy -f nut -c:a pcm_u32le -ac 2 " KeepSoundFileNext " -y && ffplay " KeepSoundFileNext
clipboard := FinalCommand
;msgbox % FinalCommand
runwait % FinalCommand
MixStack := ""
Inactive = 1
return


CurrentSound:
Gui 1:Submit,NoHide
msgbox % SoundFilter
Counter += 1
AudioArray.push(SoundFile)
DelayArray.push(SoundOffset)
FilterArray.push(SoundFilter)
tooltip % AudioArray[Counter] "`n" DelayArray[Counter] " " ms
Inactive = 1
return

StopSound:
SoundPlay,nothing.avi
Inactive = 1
return

ReplaceSound:
WinGet, hWnd2, ID, ahk_id %id_1%
WinGetPos, pX,pY,pW,pH,ahk_id %id_1%
sleep, 100
Gui 1:Submit,NoHide
SkipAmount := 0.5
SoundPlay,nothing.avi
ReplaceBGM := 1

if (SoundFilter != "") {
	ApplyFilter := " -af " SoundFilter
}

if (SoundFilter = "") {
	ApplyFilter := ""
}


SplitPath,Input,,sourceFolder,,filename2
newVideo := sourceFolder "\" filename2 "_" sound ".mkv"
replaceAudio := ComSpec " /c ffmpeg -i " chr(0x22) Input chr(0x22) " -ss " SkipAmt " -i " chr(0x22) SoundFile chr(0x22) " " ApplyFilter " -c:v copy -map 0:v -map 1:a -f nut -c:a pcm_u32le -ac 2  -y " newVideo
msgbox % replaceAudio
runwait, % replaceAudio,,Hide
oldInput := input
input := newVideo
gosub, OpenVideo
input := oldInput
Inactive = 1
AudioArray := []
DelayArray := []
FilterArray := []
Return

KeepSound:
WinGet, hWnd2, ID, ahk_id %id_1%
WinGetPos, pX,pY,pW,pH,ahk_id %id_1%
counter2 += 1
KeepSoundFile := sourceFolder "\output_" counter2 ".mkv"
KeepSoundFileNext := sourceFolder "\output_" counter2+1 ".mkv"

input := KeepSoundFile
KeepSound := 1
AudioArray := []
DelayArray := []
FilterArray := []
Inactive = 1
gosub,OpenVideo
Return

RemoveSound:
AudioArray := []
DelayArray := []
FilterArray := []
Inactive = 1
return


2GuiDropFiles:
WinGet, hWnd2, ID, ahk_id %id_1%
WinGetPos, pX,pY,pW,pH,ahk_id %id_1%
Input := A_GuiEvent
gosub,OpenVideo
Return





RemakeTree:
gosub,MakeTree
;run % A_ScriptDir . "\SoundBrowser.ahk",,,NewPID
 ; wait until active
WinWait,%TreeRoot%
  ; get window id
id := WinExist()
  ; now ie is active but the page isn't loaded
;Sleep 5000
  ; better be loaded now
  ; then get title from saved window id
WinGetTitle,Title,ahk_id %id%
;MsgBox,%ErrorLevel%: %NEWPID% %Title%
TreeWindow := WinExist(Title)
TIDSWindow := WinExist("H.L.M.M")
WinGetPos,winX,winY,winW,winH,H.L.M.M
;msgbox % winX " " winY " " winW " " winH
test1 := winW / 2 + 150
test2 := winH / 2 + 30
test3 := winW / 2 - 180
test4 := winH / 2 - 80
test8 := winH + 1

    	;Embed FFplay inside our gui
DllCall("SetParent", "uint", TreeWindow, "uint", TIDSWindow)
id_2 := WinExist("ahk_id " TreeWindow)
WinSet,Redraw,,%Title%


	; Move and resize FFPlay window. Note that if SWP_NOSENDCHANGING
	; is omitted, it incorrectly readjusts the size of its client area.
DllCall("SetWindowPos", "uint", TreeWindow, "uint", 0
    , "int", test1, "int",test2, "int", test3, "int", test4
    , "uint", SWP_SHOWWINDOW)

sleep, 500
WinSet,Redraw,,A
return


#IfWinActive,H.L.M.M
S::ControlSend,,S,H.L.M.M ;Allow to send S key to nudge video one frame
Q:: ;do nothing, prevents closing ffplay window
#IfWinActive

#IfWinActive, ahk_class SDL_app
Q:: ;do nothing, prevents closing ffplay window
Esc:: ;do nothing, prevents closing ffplay window