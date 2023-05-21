AddSubFoldersToTree(Folder, ParentItemID = 0)
{
; This function adds to the TreeView all subfolders in the specified folder.
; It also calls itself recursively to gather nested folders to any depth.
	Loop %Folder%\*.*, 2  ; Retrieve all of Folder's sub-folders.
		AddSubFoldersToTree(A_LoopFileFullPath, TV_Add(A_LoopFileName, ParentItemID, "Icon4"))
}

MyTreeView:  ; This subroutine handles user actions (such as clicking).

; Otherwise, populate the ListView with the contents of the selected folder.
; First determine the full path of the selected folder:
TV_GetText(SelectedItemText, A_EventInfo)
ParentID := A_EventInfo
Loop  ; Build the full path to the selected folder.
{
	ParentID := TV_GetParent(ParentID)
	if not ParentID  ; No more ancestors.
		break
	TV_GetText(ParentText, ParentID)
	SelectedItemText := ParentText "\" SelectedItemText
}
SelectedFullPath := TreeRoot "\" SelectedItemText

; Put the files into the ListView:
LV_Delete()  ; Clear all rows.
GuiControl, -Redraw, MyListView  ; Improve performance by disabling redrawing during load.
FileCount := 0  ; Init prior to loop below.
TotalSize := 0
Loop %SelectedFullPath%\*.*  ; For simplicity, this omits folders so that only files are shown in the ListView.
{
	LV_Add("", A_LoopFileName, A_LoopFileTimeModified)
	FileCount += 1
	TotalSize += A_LoopFileSize
}
GuiControl, +Redraw, MyListView

; Update the three parts of the status bar to show info about the currently selected folder:
SB_SetText(FileCount . " files", 1)
SB_SetText(Round(TotalSize / 1024, 1) . " KB", 2)
SB_SetText(SelectedFullPath, 3)
return

MyListView:
LV_GetText(RowText, A_EventInfo)  ; Get the text from the row's first field.	
SoundFile := SelectedFullPath "\" RowText

if (A_GuiControlEvent == "R") {
; The user has finished editing an item (use == for case sensitive comparison).
	SoundPlay, %SoundFile%
	Inactive := 1
}

if (A_GuiControlEvent == "DoubleClick") {
; The user has finished editing an item (use == for case sensitive comparison).
	SoundFile := SelectedFullPath "\" RowText
	tooltip, sound selected
	sleep, 1000
	tooltip
	Inactive := 1
} 

return


MakeTree:

; The following folder will be the root folder for the TreeView. Note that loading might take a long
; time if an entire drive such as C:\ is specified:
TreeViewWidth := 280
ListViewWidth := A_ScreenWidth - TreeViewWidth - 30

; Allow the user to maximize or drag-resize the window:
Gui 1: +Resize

; Create an ImageList and put some standard system icons into it:
ImageListID := IL_Create(5)
Loop 5 
	IL_Add(ImageListID, "shell32.dll", A_Index)
; Create a TreeView and a ListView side-by-side to behave like Windows Explorer:
gui, 1: Add, TreeView, vMyTreeView r12 w%TreeViewWidth% gMyTreeView ImageList%ImageListID%
gui, 1: Add, ListView, vMyListView r12 w%ListViewWidth% gMyListView x+10, Name
Gui, 1: Add,Button, x10 y230 gCurrentSound ,Use Current Sound


Gui, 1: Add,Button, x10 y259 w84 gStopSound ,Stop Sounds
Gui, 1: Add,Button, x102 y259 gReplaceSound ,Replace BGM


Gui, 1: Add,Button, x14 y300 gTestSound ,Test Sound
Gui, 1: Add,Button, x87 y300 gKeepSound ,Keep Sound
Gui, 1: Add,Button, x164 y300 gRemoveSound ,Discard Sound
Gui, 1: Add,Edit, x190 y260 w60 +Center vSkipAmt,0.5
Gui, 1: Add,Edit, x120 y231 w60 +Center vSoundOffset,%ms%
Gui, 1: Add,Edit, x190 y231 w60 +Center vSoundFilter,anull

gui, 1: +LastFound -E0x00010000 ;The ExStyle allows the parent to take focus if it's clicked.

; Set the ListView's column widths (this is optional):
Col2Width := 70  ; Narrow to reveal only the YYYYMMDD part.
LV_ModifyCol(1, ListViewWidth - Col2Width - 30)  ; Allows room for vertical scrollbar.
LV_ModifyCol(2, Col2Width)

; Create a Status Bar to give info about the number of files and their total size:
;gui, 2: Add, StatusBar
;SB_SetParts(60, 85)  ; Create three parts in the bar (the third part fills all the remaining width).

; Add folders and their subfolders to the tree. Display the status in case loading takes a long time:
SplashTextOn, 200, 25, TreeView and StatusBar Example, Loading the tree... `n 
AddSubFoldersToTree(TreeRoot)
SplashTextOff


; Display the window and return. The OS will notify the script whenever the user performs an eligible action:
gui, 1: Show,, %TreeRoot%  ; Display the source directory (TreeRoot) in the title bar.
WinMove,%TreeRoot%,,,,600,200
;WinMinimize,%TreeRoot%
WinSet,Redraw,,%Title%
WinSet, Style, -0x30000,%TreeRoot%
DisableCloseButton(MyListView)
DisableCloseButton(MyTreeView)

return

GuiDropFiles:
TreeRoot := A_GuiEvent
Gui, 1:Destroy
GoSub,RemakeTree
return

DisableCloseButton(hWnd="") {
	If hWnd=
		hWnd:=WinExist("A")
	hSysMenu:=DllCall("GetSystemMenu","Int",hWnd,"Int",FALSE)
	nCnt:=DllCall("GetMenuItemCount","Int",hSysMenu)
	DllCall("RemoveMenu","Int",hSysMenu,"UInt",nCnt-1,"Uint","0x400")
	DllCall("RemoveMenu","Int",hSysMenu,"UInt",nCnt-2,"Uint","0x400")
	DllCall("DrawMenuBar","Int",hWnd)
	Return ""
}
