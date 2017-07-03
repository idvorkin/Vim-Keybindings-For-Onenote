; This script requires gvim installed on the computer. It effectively diffs the results of sending the keys below to a new onenote page vs to a new gvim document.
; Up and down are specifically lightly tested, as they will definitely do different things under vim.
; This may also be true of e, w and b, due to the way onenote handles words (treating punctuation as a word)


#NoEnv  ; Recommended for performance and compatibility with future AutoHotkey releases.
; #Warn  ; Enable warnings to assist with detecting common errors.
SendMode Input  ; Recommended for new scripts due to its superior speed and reliability.
SetWorkingDir %A_ScriptDir%  ; Ensures a consistent starting directory.
#SingleInstance Force
sendlevel, 1 ; So these commands get triggered by autohotkey.
; Ignore these first lines, it is just to set up vim correctly.
send :imap jj <esc>
SendTestCommands(){
        send iThis is the first line of the test script.{return}New line one above this one. In onenote, newlines may be handled strangely. We will just have to ignore that and keep all lines within the wrap.{esc}{b 14}i{return}{esc}A{return}We have now tested i, A, b. We will now test dd, o.{return}This line should not be here if dd works.{esc}ddoNow testing I, 0, d3w (see line 9 for results):{return}two three{esc}Ione {esc}0d3wiNow we will test positioning for i and a, {return}entering normal with double js.jj{left}i(This should be between the j and s)jjla. {return}The js test line should have a period at the endjjOIf this line is before the d3w test, O has worked.{return}{esc}pa. Paste works with d3w, I and 0 work if BOL=words "123".{Return}Now test j{esc}ji(te-j works-st){esc}2wdbjjjoJust tested 2wdb. Should have only one "st" on{return}the previous test, two "te"s. This is the 13th line.{return}{esc}0eeea[b-e works with normal words-.]{esc}$a EOL ($) is good.{return}Now for some crap{esc}cccc replaces whole lines, and (redacted) functions as expected.{return} y4b{esc}y5b5wa {esc}pbbb*wi, as does *{esc}o

}


; All 4 modifier keys + b initiates test.
^!+#b::SendTestCommands()