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
#Warn ; Provides code warnings when running

SetTitleMatchMode 2 ;- Mode 2 is window title substring.
;#IfWinActive, OneNote ; Only apply this script to onenote. Doesn't seem to work
; Only works in (seemingly) the Onenote text interface. WORKS
#IfWinActive ahk_class Framework::CFrame 
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


;--------------------------------------------------------------------------------
; Return to InsertMode
InsertMode:
    ToolTip
    Suspend, On
    InNormalMode := False
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

; jj has to be implemented differently because of how insert mode works.
; This also fires the function for moving down.
; '$' used to prevent recursive sending of this key.
j::
    suspend, permit
    if InNormalMode
        j()
    else if IsLastKey("j")
    {
        ; Erase j previously typed
        send {BackSpace}
        gosub NormalMode
    }
    else
        send j
return

NormalMode:
    Suspend, Off
    global InNormalMode := True
    ToolTip, OneNote Vim Command Mode Active, 0, 0
return

;--------------------------------------------------------------------------------
IsLastKey(key)
{
    return (A_PriorHotkey == key and A_TimeSincePriorHotkey < 400)
}

SaveClipboard(){
    ; push clipboard to variable
    global ClipSaved := ClipboardAll
    ; Clear clipboard to avoid errors
    Clipboard :=
}

Copy(){
    SaveClipboard()
    send ^c
    ClipWait, 0.5
}

Paste(){
    Send %Clipboard%
    RestoreClipboard()
}

RestoreClipboard(){
    ;restore original clipboard
    global ClipSaved
    Clipboard := ClipSaved
    ;ClipWait
    ClipSaved := ; free memory
}

GetCursorColumn(){
    StartC := A_CaretX
    send +{home}
    ; Saves clipwait having to time out on empty selection if start of line.
    ; Not working. Caret variable seems to perform unexpectedly.
    ;if (StartC = %A_CaretX%){
        ;return 0
    ;}
    Copy()
    position := strLen(Clipboard)
    RestoreClipboard()
    if position != 0
    {
        ; Deselect selection
        send {right}{left}
    }
    return position
}

ConvertMotionToFunctionName(letter){
    ;StringLower, test, letter
    if letter is upper
    {
        ; Return "s" + letter, to map to shift+key function name, eg shiftG().
        letter = shift%letter%
        return letter
    }
    else if letter = 0
        return zero
    else
        return letter
}

; Params are optional, with default values.
InputMotionAndSelect(Repeat:=1, RepeatDigitDepth:=0, VisualMode:= False){
    ; If in visual mode, keep doing this.
    ; Breaks after one round if not in visual mode.
    loop{
        gosub, InsertMode
        ; Get next typed character, then continue
        Input, motion, L1
        gosub, NormalMode
        ; User entered a number. Initiate a repeat.
        if motion is Integer
        {
            ; If this is first number, reduce by one to prepare for addition.
            if RepeatDigitDepth = 1
                Repeat--
            ; Update repeat with next digit.
            Repeat :=(Repeat*10**RepeatDigitDepth + Motion)
            ; The params account for if another number is entered
            ; (I.e., more than 1 digit count)
            InputMotionAndSelect(Repeat, ++RepeatDigitDepth)
        }
        else if motion in i,a,g,v
        {
            ; User has entered a second v. End visual mode.
            if ( motion = "v" )
            {
                VisualMode = False
                return
            }else if motion = "g"
            {
                ; Will check if second g within this function. 
                g()
            }
        }
        ;     if motion = "i"
        ;     {
        ;         ; TODO inner()
        ;         InputMotionAndSelect()
        ;         ; Pass the motion in, have a default param in this function? Adds motions to list?
        ;     }else if motion = "a"
        ;     {
        ;         ; TODO outer/a (word)
        ;         InputMotionAndSelect()
        ;     }else if motion = "g"
        ;     {
        ;         ; expect user is about to type another g (to go to start of doc)
        ;     }
        ; }

        ; Handles cc, dd, etc.
        ; dd has additional logic within own function, still relies on this though.
        else if IsLastKey(motion){
            send {end}
            send +{home}
            return
        }else{
            loop %Repeat%{
            MoveFunction := ConvertMotionToFunctionName(motion)
            send {shift down}
            ; Autohotkey allows dynamic functions (called by var name)
            %MoveFunction%()
            send {shift up}
            }

            DoNotContinue := not VisualMode
            if DoNotContinue
            {
                VisualMode := not VisualMode
                msgbox, exiting visual...
                break
            }
        }
    }
}

;--------------------------------------------------------------------------------
+i::
    send {Home}
    Gosub InsertMode
return 

i::Gosub InsertMode
 
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
;--------------------------------------------------------------------------------

w(){
    send ^{right}
}
w::w()
b(){
    send ^{left}
}
b::b()
e(){
    send ^{right}{left}
}
e::e()

; vi left and right
h(){ 
    send {Left}
}
h::h()

l(){
    send {Right}
}
l::l()

; vi up and down.
;  Onenote does some magic that blocks up/down processing. See more @ 
; (Onenote 2013) http://www.autohotkey.com/board/topic/74113-down-in-onenote/
; (Onenote 2007) http://www.autohotkey.com/board/topic/15307-up-and-down-hotkeys-not-working-for-onenote-2007/
;j(){
;    send {end}
;    send {right}
;    send {end}
;    }
;j::j()

;k(){
    ;send {home}
    ;send {left}
    ;}
;k::k()

; Alternate, more accurate up and down. Much more complicated though, may be
; slow on slow computers.
; TODO: Fix column selection to check if at start of line. 
j(){
    column := GetCursorColumn()
    send {end}{right}{end}
    if GetCursorColumn() > column{
        send {home}
        ; Send right %column% times.
        send {right %column%}
    }
}

k(){
    column := GetCursorColumn()
    send {home}{Left}    
    if GetCursorColumn() > column{
        send {home}
        ; Send right %column% times.
        send {right %column%}
    }
}
k::k()


+x::send {BackSpace}

x::send {Delete}



; undo
u::Send, ^z
; redo.
^r::Send, ^y

; G goto to end of document
shiftG(){
    Send, ^{End}
    }
+G::shiftG()

g(){
    if IsLastKey("g")
    {
        ;gg - Go to start of document
        msgbox gg
        Send, ^{Home}
    }
}
g::g()

shift4(){
    Send, {End} ;$
    }
+4::shift4()

z(){
    Send, {Home} 
    }
0::z()

shift6(){
    Send, {Home} ;^
    }
+6::shift6()

shift5(){
    Send, ^b ;%
    }
+5::shift5()

ctrlF(){
    Send, {PgDn}
    }
^F::ctrlF()

ctrlB(){
    Send, {PgUp}
    }
^B::ctrlB()



y::
    InputMotionAndSelect()
    send ^c
    ; Deselect
    send {left}
return 

; Emulates cc
+C::send {c 2}
c::
    InputMotionAndSelect()
    send ^x
    gosub InsertMode
return

; Cut to end of line
+D::
Send, {ShiftDown}{End}
Send, ^x
Send, {ShiftUp}
return

; Delete current line
; dd handled specially, to delete newline.
d::
    InputMotionAndSelect()
    send ^x
    if IsLastKey("d")
    Send, {Del}
return

s::
    send +{right}
    gosub, InsertMode
    ; Wait for single key to be pressed, sends that key
    input, inp, V E L1
    send {left}
return 

+S::
    Send, {Home}{ShiftDown}{End}
    Send, ^x ; Cut instead of yank and delete
    Send, {ShiftUp}
    Gosub, InsertMode   
return 

; TODO handle regular paste , vs paste something picked up with yy.
; That is, handle linewise vs in-place copy/paste. FLags maybe? ugh.
; current behavior assumes in-place pasting/copying.
p::Send {right}^v
+P::Send ^v

; Visual mode parameter causes function to loop, selecting until v is pressed
v::InputMotionAndSelect(,,True)


; Search actions
/::
    Send ^f
    GoSub, InsertMode
    ; V option means input is passed through. Unfortunately, this includes return.
    ; E may or may not do anything. There for reliability.
    input, inp, E V, {escape}{return}
    ; Send shift return to move back one search
    ; (the return key sent through to exit moves you forward once too many times. )
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
    ; V option means input is passed through. Unfortunately, this includes return.
    ; E may or may not do anything. There for reliability.
    input, inp, E V, {escape}{return}
    ; Send shift return to move back one search
    ; (the return key sent through to exit moves you forward once too many times. )
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

; Search for word under cursor. '#' command.
+3::
    ; Ensure we have selected whole word, from anywhere within cursor.
    send {right}^{left}+^{right}
    copy()
    send ^f
    Paste()
    send {return}
    send {esc}
    send {left}
return
; Opposite ('*'), find in reverse.
+8::
    ; Ensure we have selected whole word, from anywhere within cursor.
    send {right}^{left}+^{right}
    copy()
    send ^f
    Paste()
    send +{return}
    send {esc}
    send {left}
return


; Numbers will be used to repeat motions.
1::
2::
3::
4::
5::
6::
7::
8::
9::
    InputMotionAndSelect(A_ThisHotkey, 1)
    ;Deselect
    send {right}{left}
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
    Copy()

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
f::
m::
t::
+E::
+B::
+H::
+J::
+K::
+L::
+M::
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
