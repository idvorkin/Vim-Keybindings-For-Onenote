; VIM Keybinds for onenote.
;---------------------------------------
;---------------------------------------

;---------------------------------------
; Usage - Run vim_onenote.ahk, or autohotkey vim_onenote.ahk
;---------------------------------------

; Acknolwedgements:
; This is based on a vim autohotkey script which I can no longer find. If you find it, please tell me and I'll add it to the acknolwedgements
;---------------------------------------

; Settings
;---------------------------------------
;#NoTrayIcon ; NoTrayIcon hides the tray icon.
#SingleInstance Force ; SingleInstance makes the script automatically reload.

; The code itself.
;---------------------------------------
;---------------------------------------

; The VIM input model has two modes, normal mode, where you enter commands, and insert mode, where keys are inserted into the text.
;
; In insert mode, this script is suspended, and only the ESC hotkey is active, all other keystrokes are propogated to onenote. When ESC is pressed, the script enters normal mode.

; In normal mode, this script is active and all HotKeys are active. Hotkeys that need to return to insert mode, end by calling InsertMode. On script startup, InsertMode is entered.

Gosub InsertMode ; goto InsertMode mode on script startup

SetTitleMatchMode 2 ;- Mode 2 is window title substring.
#IfWinActive, OneNote ; Only apply this script to onenote.

; ESC enters Normal Mode
ESC::
	Suspend, Off
	ToolTip, OneNote Vim Normal Mode Active, 0, 0
return

; Return to InsertMode
InsertMode:
	ToolTip
	Suspend, On
return


+i::
    SendInput, {Home}
    Gosub InsertMode
return 

i::Gosub InsertMode
return 

; vi left and right

h::SendInput, {Left}
return 
l::SendInput, {Right}
return 

; vi up and down.
;  Onenote does some magic that blocks up/down processing. See more @ 
; (Onenote 2013) http://www.autohotkey.com/board/topic/74113-down-in-onenote/
; (Onenote 2007) http://www.autohotkey.com/board/topic/15307-up-and-down-hotkeys-not-working-for-onenote-2007/
j::SendInput,^{down}
return 
k::SendInput,^{up}
return 

x::SendInput, {Delete}
return 

+a::
SendInput, {End}
Gosub InsertMode
return 

a::
SendInput, {Right}
Gosub InsertMode
return 

+o::
Send, {home}^{up}{End}{Enter}
Gosub InsertMode
return

o::
Send, {End}{Enter}
Gosub InsertMode
return

; undo
u::Send, ^z
return 
; redo.
^r::Send, ^y
return 

+G:: Send, ^{End}
; G goto to end of document
return

g::
; TBD - Design a more generic way to implement the <command> <motion> pattern. For now hardcode dw. 
if (A_PriorHotkey == "g" and A_TimeSincePriorHotkey < 400)
{
    ;gg - Go to start of document
    Send, ^{Home}
    return
}

w::
; TBD - Design a more generic way to implement the <command> <motion> pattern. For now hardcode dw. 
if (A_PriorHotkey == "d" and A_TimeSincePriorHotkey < 400)
{
    ;dw
    Send, {ShiftDown}
    ^{Right}
    Send, {Del}
    Send, {Shift}
    return
}
if (A_PriorHotkey == "c" and A_TimeSincePriorHotkey < 400)
{
    ;cw
    Send, {ShiftDown}
    ^{Right}
    Send, {Del}
    Send, {Shift}
    Gosub InsertMode
    return
}
; just w
Send, ^{Right}
return 
b::Send, ^{Left}
return 
+4::Send, {End}
return 
0::Send, {Home}
return 
+6::Send, {Home}
return 
+5::Send, ^b
return 
^f::Send, {PgDn}
return 
^b::Send, {PgUp}


;; TBD Design a more generic <command> <motion> pattern, for now implement yy and dd the most commonly used commands.
y::
if (A_PriorHotkey <> "y" or A_TimeSincePriorHotkey > 400)
{
    return
}
Send, {Home}{ShiftDown}{End}
Send, ^c
Send, {Shift}
return 

+d::
Send, {ShiftDown}{End}
Send, ^c ; Do a yank before erasing.
Send {Del}
Send, {ShiftUp}
return

d::
if (A_PriorHotkey <> "d" or A_TimeSincePriorHotkey > 400)
{
    return
}
Send, {Home}{ShiftDown}{End}
Send, ^c ; Do a yank before erasing.
Send, {Del}
Send, {Shift}
return 

; TODO handle regular paste , vs paste something picked up with yy
; current behavior assumes yanked with yy.
p::
Send, {End}{Enter}^v
return

/::
; Search 
Send, ^f

return

; swap case of current letter - doesn't work need to debug.
~::
    ; push clipboard to local variable
    ClipSaved := ClipboardAll

        ; copy 1 charector
        Send, {ShiftDown}{Right}
        Send, ^c
        Send, {Shift}

        ; invert char
        char_to_invert:= Substr(Clipboard, 1, 1)
        if char_to_invert is upper
           inverted_char := Chr(Asc(char_to_invert) + 32)
        else if char_to_invert is lower
           inverted_char := Chr(Asc(char_to_invert) - 32)
        else
           inverted_char := char_to_invert

        ;paste char.
        ClipBoard := inverted_char
        Send ^v{left}{right} 

        ;restore original clipboard
        Clipboard := ClipSaved
        ClipWait
    ClipSaved := ; free memory

return

; z  is the fold fold command.

z::
; multi threading is confusing in autohotkey and is getting triggered when you press the second key in the sequence.
; so turn off the hotkeys while running the input command, and turn them back on. 
; Note, you can only disable hotkeys that are implemented (in this case o)

hotkey o, off
hotkey +o, off
hotkey c, off
    Input, SingleKey, L1
hotkey o, on
hotkey +o, on
hotkey c, on

if SingleKey = c
{
    SendInput, !+-
}
else if SingleKey = o
{
    SendInput, !+{+}
}
return

; Eat all other keys if in command mode.
c::
e::
f::
m::
n::
r::
s::
t::
+C::
+E::
+H::
+J::
+K::
+L::
+M::
+N::
+P::
+Q::
+R::
+S::
+T::
+U::
+V::
+W::
+X::
+Y::
+Z::
.::
'::
;::
return::
