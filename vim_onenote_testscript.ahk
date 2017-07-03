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

#include vim_onenote_library.ahk

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

SampleText =
(
   This is the first line of the test, and contains a comma and a period.
   Second line here
   3rd line. The second line is shorter than both 1st and 3rd line.
   The fourth line contains     some additional whitespace.	< a tab too!
   What should I put on the 5th line?A missing space, perhaps
   This line 6 should be longer than the line before it and after it to test kj
   No line, including 7, can be longer than 80 characters.
   This is because onenote wraps automatically, (line 8)
   and treats a wrapped line as separate lines (line 9)
)

; Put a comma before each test string to add it to the previous line.
; The test will be send from normal mode, with the cursor at the start of the sample text.
ArrayOfTests := [
    ,
]

SwitchToOnenote(){
    WinActivate, VIM Onenote Test - Microsoft Onenote
    WinWaitActive, VIM Onenote Test - Microsoft Onenote
}

SendTestToOnenoteAndReturnResult(test){
    SwitchToOnenote()
    ; Ensure insert mode for the sample text.
    send i{backspace}
    send %SampleText%
    ; Make sure we are in normal mode to start with, at start of text.
    send {esc}^{home} 
    send %test%
    send ^a^a^a ; Ensure we select all of the inserted text.
    output := GetSelectedText()
    ; Delete text ready for next test
    send {backspace}
}

SendTestToVimAndReturnResult(test){
    SwitchToVim()
    ; Ensure insert mode for the sample text.
    send i{backspace}
    send %SampleText%
    ; Make sure we are in normal mode to start with, at start of text.
    send {esc}^{home} 
    send %test%
    SaveClipboard()
    send :`%d+ ; select all text, cut to system clipboard
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
    ; Could also consider using comp.exe /AL instead, to compare individual characters. Possibly more useful.
    DiffResult := ComObjCreate("WScript.Shell").Exec("cmd.exe /q /c fc.exe /LN string1 string2").StdOut.ReadAll()
    msgbox %DiffResult%
   FileDelete, string1
   FileDelete, string2
   return DiffResult
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
