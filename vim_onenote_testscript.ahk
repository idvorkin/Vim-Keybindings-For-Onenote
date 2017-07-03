; This script requires vim installed on the computer. It effectively diffs the results of sending the keys below to a new onenote page vs to a new vim document.
; Up and down are specifically lightly tested, as they will definitely do different things under vim.
; This may also be true of e, w and b, due to the way onenote handles words (treating punctuation as a word)

; Results are outputed as the current time and date in %A_ScriptDir%\testlogs

#NoEnv  ; Recommended for performance and compatibility with future AutoHotkey releases.
; #Warn  ; Enable warnings to assist with detecting common errors.
SendMode Input  ; Recommended for new scripts due to its superior speed and reliability.
SetWorkingDir %A_ScriptDir%  ; Ensures a consistent starting directory.
#SingleInstance Force
#warn
sendlevel, 1 ; So these commands get triggered by autohotkey.
SetTitleMatchMode 2 ; window title functions will match by containing the match text. 

; Contains clipboard related functions, among others.
#include vim_onenote_library.ahk

LoggedResults := ""
TestsFailed := False

; Initialise the programs
run, cmd.exe /r vim
winwait,  - VIM ; Wait for vim to start
send :imap jj <esc>{return} ; Prepare vim    
;TODO: Check if onenote already open. Or just ignore? multiple windows may cause problems.
;       May be fixed by making the switch specific to the test page.
run, onenote
winwait, - Microsoft OneNote ; Wait for onenote to start
WinActivate, - Microsoft OneNote
WinWaitActive, - Microsoft OneNote
send ^nVim Onenote Test ; Create a new page in onenote, name it, move to text section

run, %A_ScriptDir%/vim_onenote.ahk



; This is the text that all of the tests are run on, fresh.
SampleText =
(
{down 2}
This is the first line of the test, and contains a comma and a period.
Second line here
3rd line. The second line is shorter than both 1st and 3rd line.
The fourth line contains     some additional whitespace.
What should I put on the 5th line?A missing space, perhaps
This line 6 should be longer than the line before it and after it to test kj
No line, including 7, can be longer than 80 characters.
This is because onenote wraps automatically, (line 8)
and treats a wrapped line as separate lines (line 9)
)

; Put the comma before each test string to add it to the previous line.
; The test will be send from normal mode, with the cursor at the start of the sample text.
ArrayOfTests := ["iat start of first lin.{esc}ie{esc}IWord " ; Tests i,I
    ,"ahe {esc}A Also this." ] ; a, A]

RunTests(){
    Global ArrayOfTests
    msgbox, runtests
    for index, test in ArrayOfTests
    {
        TestAndCompareOutput(test)
        msgbox
    }
    EndTesting()
}

SwitchToVim(){
    WinActivate,  - VIM
    WinWaitActive,  - VIM
}

SwitchToOnenote(){
    WinActivate,Vim Onenote Test - Microsoft OneNote
    WinWaitActive,Vim Onenote Test - Microsoft OneNote
}

SendTestToOnenoteAndReturnResult(test){
    msgbox, switchtoOnenoteandredurnresults
    Global SampleText
    SwitchToOnenote()
    ; Ensure insert mode for the sample text.
    send i{backspace}
    send %SampleText%
    sleep, 1000
    ; Make sure we are in normal mode to start with, at start of text.
    send {esc}^{home} 
    msgbox %test%
    controlsend,, %test%,A
    sleep, 1000
    msgbox, justested
    send ^a^a^a ; Ensure we select all of the inserted text.
    msgbox, select
    output := GetSelectedText()
    ; Delete text ready for next test
    send {backspace}
}

SendTestToVimAndReturnResult(test){
    msgbox, switchtoVimandredurnresults
    Global SampleText
    SwitchToVim()
    ; Ensure insert mode for the sample text.
    send i{backspace}
    send %SampleText%
    sleep, 1000
    ; Make sure we are in normal mode to start with, at start of text.
    send {esc}^{home}
    send %test%
    sleep, 1000
    msgbox, justested
    SaveClipboard()
    send :`%d+ ; select all text, cut to system clipboard
    output := Clipboard
    RestoreClipboard()
    return output
}

TestAndCompareOutput(test){
    msgbox, testandcompareoutput
    Global LoggedResults
    global Log
    OnenoteOutput := SendTestToOnenoteAndReturnResult(test)
    VimOutput := SendTestToVimAndReturnResult(test)
    LoggedResults += "" CompareStrings(OnenoteOutput, VimOutput, test)
}

CompareStrings(string1, string2, CurrentTest){
    msgbox, CompareStrings
    Global LoggedResults
    Global TestsFailed
    file1 := FileOpen("string1", "w")
    file2 := FileOpen("string2", "w")
    file1.write(string1)
    file2.write(string2)
    file1.close()
    file2.close()

    ; This line runs the DOS fc (file compare) program and returns the stdout output.
    ; Could also consider using comp.exe /AL instead, to compare individual characters. Possibly more useful.
    ; Comp sucks. Wow. Using fc, but only shows two lines: the different one and the one after. Hard to see, but it'll do for now.
    DiffResult := ComObjCreate("WScript.Shell").Exec("cmd.exe /q /c fc.exe /LB2 /N string1 string2").StdOut.ReadAll() 
    msgbox %DiffResult%
    IfNotInString, DiffResult, "FC: no differences encountered"
    {
        TestsFailed := True
        LoggedResults += "%CurrentTest%`n"
        LoggedResults += "%DiffResult%`n`n"
    }
    FileDelete, string1
    FileDelete, string2
    return DiffResult
}

; Tidy up, close programs, write log to file.
EndTesting(){
    msgbox, EndTesting
    Global LoggedResults
    Global TestsFailed
    ; Delete the new page in onenote
    SwitchToOnenote()
    send ^+A
    send {delete}
    SwitchToVim()
    send :q!{return} ; Exit vim.
    LogFileName = %A_Scriptdir%\testlogs\%A_Now%
    LogFile := FileOpen(LogFileName, w)
    LogFile.Write(LoggedResults) 
    LogFile.Close()
    if (TestsFailed == True)
    {
        msgbox, At least one test has failed!`nResults are in %LogFileName%
    }else{
        msgbox, All tests pass!
    }
}

RunTests()

ExitApp
; All 4 modifier keys + b initiates test.
;^!+#b::SendTestCommands()
