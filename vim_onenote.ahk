;---------------------------------------
; Basic VIM Keybinds for onenote.
;---------------------------------------

;---------------------------------------
; Usage - Run vim_onenote.ahk, or autohotkey vim_onenote.ahk
;---------------------------------------

;--------------------------------------------------------------------------------
; https://github.com/idvorkin/Vim-Keybindings-For-Onenote
;
; Acknowledgments:
; This is based on a vim autohotkey script which I can no longer find. If you find it, 
; please tell me and I'll add it to the acknowledgments
;---------------------------------------

;---------------------------------------
; Settings
;---------------------------------------
;#NoTrayIcon ; NoTrayIcon hides the tray icon.
#SingleInstance Force ; SingleInstance makes the script automatically reload.
#NoEnv  ; Recommended for performance and compatibility with future AutoHotkey releases.
SendMode Input  ; Recommended for new scripts due to its superior speed and reliability.
;SetWorkingDir %A_ScriptDir%  ; Ensures a consistent starting directory.
#KeyHistory 0 ; Disables logging of keystrokes in key history

;---------------------------------------
; The code itself.
;---------------------------------------

; The VIM input model has two modes, normal mode, where you enter commands, 
; and insert mode, where keys are inserted into the text.
;
; In insert mode, this script is suspended, and only the ESC hotkey is active, all other 
; keystrokes are propagated to onenote. When ESC is pressed, the script enters normal mode.

; In normal mode, this script is active and all HotKeys are active. Hotkeys that need to
; return to insert mode, end by calling InsertMode. On script startup, InsertMode is entered.

;--------------------------------------------------------------------------------
Gosub InsertMode ; goto InsertMode mode on script startup

SetTitleMatchMode 2 ;- Mode 2 is window title substring.
#IfWinActive, OneNote ; Only apply this script to onenote.

;--------------------------------------------------------------------------------
IsLastKey(key)
{
    return (A_PriorHotkey == key and A_TimeSincePriorHotkey < 400)
}

SelectMotion(){
    gosub, InsertMode
    Input, motion, L1
    gosub, NormalMode
    msgbox, entered normal
    ;if motion = i, a or digit, need to wait. If digit, loop motion that many times. If i, g or w, wait for anotther motion.
    send {shift down}
    send %motion%
    send {shift up}
    msgbox, %motion%
}

;--------------------------------------------------------------------------------
; Return to InsertMode
InsertMode:
    ToolTip
    Suspend, On
    hotkey, ESC, on
return

;--------------------------------------------------------------------------------

;  ctrl + [, ESC enter Normal Mode.
; Not using ctrl + c, as people may still want to use for copying.
;^c::
^[::
ESC::
    ; Is not affected by insertmode's suspend
    suspend, permit
    gosub NormalMode
return

; imap workings (eg jj) currently can't be implemented because of how 
; insert mode works.


NormalMode:
    Suspend, Off
    ToolTip, OneNote Vim Command Mode Active, 0, 0
return


;--------------------------------------------------------------------------------
+i::
    send {Home}
    Gosub InsertMode
return 

i::Gosub InsertMode
return 

;--------------------------------------------------------------------------------
PrepareClipboard(){
    ; push clipboard to local variable
    ClipSaved := ClipboardAll
    ; Clear clipboard to avoid errors
    Clipboard :=
}

Copy(){
    PrepareClipboard()
    send ^c
    ClipWait
}

Paste(){
    Send %Clipboard%
    RestoreClipboard()
}

RestoreClipboard(){
    ;restore original clipboard
    Clipboard := ClipSaved
    ;ClipWait
    ClipSaved := ; free memory
}

GetCursorColumn(){
    send +{home}
    Copy()
    position := strLen(Clipboard)
    RestoreClipboard()
    return position
}


; vi left and right

h:: send {Left}
return 
l:: send {Right}
return 

;--------------------------------------------------------------------------------
; vi up and down.
;  Onenote does some magic that blocks up/down processing. See more @ 
; (Onenote 2013) http://www.autohotkey.com/board/topic/74113-down-in-onenote/
; (Onenote 2007) http://www.autohotkey.com/board/topic/15307-up-and-down-hotkeys-not-working-for-onenote-2007/
j:: send ^{down}
k:: send ^{up}

Return:: send ^{down}


+x:: send {BackSpace}

x:: send {Delete}

+a::
 send {End}
Gosub InsertMode
return 

a::
 send {Right}
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

r::
    send +{right}
    gosub, InsertMode
    ; Wait for single key to be pressed, sends that key and returns to normal
    input, inp, V E L1
    send {left}
    gosub, NormalMode
return

; undo
u::Send, ^z
; redo.
^r::Send, ^y

; G goto to end of document
+G:: Send, ^{End}

g::
; TBD - Design a more generic way to implement the <command> <motion> pattern. For now hardcode dw. 
if IsLastKey("g")
{
    ;gg - Go to start of document
    Send, ^{Home}
    return
}
return

w::
; TBD - Design a more generic way to implement the <command> <motion> pattern. For now hardcode dw. 
if IsLastKey("d")
{
    ;dw
    Send, {ShiftDown}
    ^{Right}
    Send, {Del}
    Send, {Shift}
    return
}
if IsLastKey("c")
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

b::Send, ^{Left}
+4::Send, {End} ;$
0::Send, {Home} 
+6::Send, {Home} ;^
+5::Send, ^b ;%
^F::Send, {PgDn}
+B::Send, {PgUp}


;; TBD Design a more generic <command> <motion> pattern, for now implement yy and dd the most commonly used commands.
y::
if IsLastKey("y")
{
    Send, {Home}{ShiftDown}{End}
    Send, ^c
    Send, {Shift}
}
return 

; Cut to end of line
+d::
Send, {ShiftDown}{End}
Send, ^x ; Cut instead of yank and delete
Send, {ShiftUp}
return

; Delete current line
d::
    if IsLastKey("d")
{
    Send, {Home}{Shift down}{End}
    Send, {Shift up}
    Send, ^x ; Yank before delete
    Send, {Del}
}
else
    SelectMotion()
    send ^x
return

+S::
Send, {Home}{ShiftDown}{End}
Send, ^x ; Cut instead of yank and delete
Send, {ShiftUp}
Gosub, InsertMode   
return 

; TODO handle regular paste , vs paste something picked up with yy
; current behavior assumes yanked with yy.
p::Send, {End}{Enter}^v



; Search actions
/::
    Send ^f
    GoSub, InsertMode
    input, inp, E V, {escape}{return}
    ; Send shift return to move back one search
    ; (the return endkey gets send through, unfortunately. )
    send +{return}
    send {esc}
    send {left}
    gosub, NormalMode
return

; Simulate reverse find. Doesn't highlight the previous one,
;  but does drop cursor there.
?::
    Send, ^f
    GoSub, InsertMode
    input, inp, E V, {escape}{return}
    ; Send shift return to move back one search
    ; (the return endkey gets send through, unfortunately. )
    send +{return}
    send +{return}
    send {esc}
    send {left}
    gosub, NormalMode
return

; Next/prev search repeat
n::
    send ^f
    send {return}
    send {esc}
    send {left}
return
+N::
    Send, ^f
    send +{return}
    send {esc}
    send {left}
return


; C-P => Search all notebooks.
^p::
Send, ^e
; a bit weird - we're in insert mode after the search.
GoSub InsertMode
return 


; swap case of current letter. Uses shift + ` (ie ~), but uses virtual code
; because doesn't work otherwise. AHK uses ~ as special key, 
; escaping doesn't seem to work.
+VKC0::
    ; copy 1 charecter
    Send, +{Right}
    COpy()

    ; invert char
    if clipboard is upper
        StringLower, Clipboard, Clipboard
    else
        StringUpper, Clipboard, Clipboard

    Paste()
    ; Return to original position
    Send {left}
    
return

;; << Outdent

<::
if IsLastKey("<")
{
    Send, {Home}
    Send, +{Tab}
}
return

;; << Outdent

>::
if IsLastKey(">")
{
    Send, {Home}
    Send, {Tab}
}
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
     send !+-
}
else if SingleKey = o
{
     send !+{+}
}
return

; See https://autohotkey.com/docs/commands/Input.htm at the last example. 
; Could be a way of implementing some commands at some point.
;--------------------------------------------------------------------------------
; Eat all other keys if in command mode.
;--------------------------------------------------------------------------------
c::
e::
f::
m::
s::
t::
+C::
+E::
+H::
+J::
+K::
+L::
+M::
+P::
+Q::
+R::
+T::
+U::
+V::
+W::
+Y::
+Z::
.::
'::
`;::
