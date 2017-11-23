IsLastHotkey(key)
{
    return (A_PriorHotkey == key and A_TimeSincePriorHotkey < 800)
}

IsLastkey(key)
{
    return (A_Priorkey == key and A_TimeSincePriorkey < 800)
}

SaveClipboard(){
    ; push clipboard to variable
    global ClipSaved := ClipboardAll
    ; Sleep to give time for saving
    sleep, 20
    ; Clear clipboard to avoid errors
    Clipboard :=
}

Copy(){
    SaveClipboard()
    send ^c
    ClipWait, 0.1
}

Paste(){
    Send %Clipboard%
    RestoreClipboard()
}

RestoreClipboard(){
    ; empty clip so clipwait works
    Clipboard :=
    ;restore original clipboard
    global ClipSaved
    Clipboard := ClipSaved
    ClipWait
    ClipSaved := ; free memory
}

GetSelectedText(){
    Copy()
    Output := Clipboard
    RestoreClipboard()
    return Output
}

DebugLog(text){
    LogFileName := "DebugLog.txt"
    LogFile := FileOpen(LogFileName, "a")
    FormatTime, Timestamp ; Method gives current time by default
    LogEntry = %Timestamp%:   %text%`n
    LogFile.Write(LogEntry) 
    LogFile.Close()
}

; Alternate to WinWaitActive, designed to work with CI better.
; It doesn't.
;  regex f&r: s/WinWaitActive,([\w -]+)/WaitForWindowToActivate("$1")/g
WaitForWindowToActivate(WindowTitle){
    while not WinActive(WindowTitle){
       sleep, 20
    }
    ToolTip, winwait worked, 100, 100, 3
    sleep, 100
    return True
}

HackWinActivate(WindowTitle){
    while not WinActive(WindowTitle){
        sleep, 10
        send {alt down}{shift down}
        sleep, 10
        send {tab}
        sleep, 10
        send {shift up}{alt up}
        sleep, 20
    }
    ToolTip, Winactivate worked, 10, 10, 2
    sleep, 100
    return True
}