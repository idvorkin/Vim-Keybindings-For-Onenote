; This script requires vim installed on the computer. It effectively diffs the results of sending the keys below to a new onenote page vs to a new vim document.
; Up and down are specifically lightly tested, as they will definitely do different things under vim.
; This may also be true of e, w and b, due to the way onenote handles words (treating punctuation as a word)

; Results are outputed as the current time and date in %A_ScriptDir%\testlogs

#NoEnv  ; Recommended for performance and compatibility with future AutoHotkey releases.
; #Warn  ; Enable warnings to assist with detecting common errors.
SendMode Input  ; Recommended for new scripts due to its superior speed and reliability.
SetWorkingDir %A_ScriptDir%  ; Ensures a consistent starting directory.
#SingleInstance Force
sendlevel, 1 ; So these commands get triggered by autohotkey.
SetTitleMatchMode 2 ; window title functions will match by containing the match text. 

SaveClipboard(){
    ; push clipboard to variable
    global ClipSaved := ClipboardAll
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
    ;restore original clipboard
    global ClipSaved
    Clipboard := ClipSaved
    ;ClipWait
    ClipSaved := ; free memory
}

GetSelectedText(){
    Copy()
    Output := Clipboard
    RestoreClipboard()
    return Output
}

; Initialise the programs
run, cmd.exe /r vim
winwait,  - VIM ; Wait for vim to start
send :imap jj <esc> ; Prepare vim    
;TODO: Check if onenote already open. Or just ignore? multiple windows may cause problems.
;       May be fixed by making the switch specific to the test page.
run, onenote
winwait, - Microsoft OneNote ; Wait for onenote to start
send ^nVim Onenote Test{down} ; Create a new page in onenote, name it, move to text section

run, %A_ScriptDir%/vim_onenote.ahk

SwitchToVim(){
    WinActivate,  - VIM
    WinWaitActive,  - VIM
}


SwitchToOnenote(){
    WinActivate, VIM Onenote Test - Microsoft Onenote
    WinWaitActive, VIM Onenote Test - Microsoft Onenote
}

SendTestToOnenoteAndReturnResult(test){
    SwitchToOnenote()
    send {esc} ; Make sure we are in normal mode to start with
    send %test%
    send ^a^a^a ; Ensure we select all of the inserted text.
    output := GetSelectedText()
    ; Delete text ready for next test
    send {backspace}
}

SendTestToVimAndReturnResult(test){
    SwitchToVim()
    send {esc} ; Make sure we are in normal mode to start with
    send %test%
    SaveClipboard()
    send :`%Y+ ; select all text, copy to system clipboard
    output := Clipboard
    RestoreClipboard()
    return output
}

LoggedResults := ""
TestAndCompareOutput(test){
    global Log
    OnenoteOutput := SendTestToOnenoteAndReturnResult(test)
    VimOutput := SendTestToVimAndReturnResult(test)
    LoggedResults += "" CompareStrings(OnenoteOutput, VimOutput)
}

CompareStrings(string1, string2){
    file1 := FileOpen("string1", w)
    file2 := FileOpen("string2", w)
    file1.write(string1)
    file2.write(string2)
    file1.close()
    file2.close()

    ; This line runs the DOS fc (file compare) program and returns the stdout output.
    MsgBox % ComObjCreate("WScript.Shell").Exec("cmd.exe /q /c fc.exe string1 string2").StdOut.ReadAll()

   FileDelete, string1
   FileDelete, string2
}

; Tidy up, close programs, write log to file.
EndTesting(){
    Global LoggedResults
    ; Delete the new page in onenote
    SwitchToOnenote()
    send ^+A
    send {delete}
    SwitchToVim()
    send :q!{return} ; Exit vim.
    LogFile := FileOpen("%A_Scriptdir%\testlogs\A_Now", w)
    LogFile.Write(LoggedResults) 
    LogFile.Close()
}


; All 4 modifier keys + b initiates test.
;^!+#b::SendTestCommands()