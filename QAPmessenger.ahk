;===============================================
/*

Quick Access Popup Messenger
Written using AutoHotkey_L v1.1.09.03+ (http://ahkscript.org/)
By Jean Lalonde (JnLlnd on AHKScript.org forum)
	
DESCRIPTION

Called from Explorer context menus to send messages to QAP in order to launch various actions like:
- add the selected folder to favorites (message "AddFolder")
- add the selected file to favorites (message "AddFile")
- add the selected folder to favorites in express mode (message "AddFolderXpress")
- add the selected file tofavorites in express mode (message "AddFileXpress")

HISTORY
=======

Version: 0.3 beta (2016-05-24)
- improve version number and branch mangement

Version: 0.2 beta (2016-04-29)
- check for result 0xFFFF flagging an open settings window in QAP

Version: 0.1 beta (2016-04-25)
- initial alpha test release
- implement message "AddFolder", "AddFile", "AddFolderXpress" and "AddFileXpress"
- manage result codes sent by QAP: 1 for success, FAIL or 0 if an error occurred

*/ 
;========================================================================================================================
; --- COMPILER DIRECTIVES ---
;========================================================================================================================

; Doc: http://fincs.ahk4.net/Ahk2ExeDirectives.htm
; Note: prefix comma with `

;@Ahk2Exe-SetName QAP Messenger
;@Ahk2Exe-SetDescription Send messages to Quick Access Popup
;@Ahk2Exe-SetVersion 0.3 BETA
;@Ahk2Exe-SetOrigFilename QAPmessenger.exe


;========================================================================================================================
; INITIALIZATION
;========================================================================================================================

#NoEnv
#SingleInstance force
#KeyHistory 0
ListLines, Off

; Force A_WorkingDir to A_ScriptDir if uncomplied (development environment)
;@Ahk2Exe-IgnoreBegin
; Start of code for development environment only - won't be compiled
; see http://fincs.ahk4.net/Ahk2ExeDirectives.htm
ListLines, On
; / End of code for developement enviuronment only - won't be compiled
;@Ahk2Exe-IgnoreEnd

g_strAppNameText := "Quick Access Popup Messenger"
g_strAppVersion := "0.3"
g_strAppVersionBranch := "beta"
g_strAppVersionLong := "v" . g_strAppVersion . (g_strAppVersionBranch <> "prod" ? " " . g_strAppVersionBranch : "")
g_stTargetAppTitle := "Quick Access Popup ahk_class JeanLalonde.ca"
g_stTargetAppTitleDev := "Quick Access Popup ahk_class AutoHotkeyGUI"
g_stTargetAppName := "Quick Access Popup"

; Use traditional method, not expression
g_strParam0 = %0% ; number of parameters
g_strParam1 = %1% ; fisrt parameter, the command name
g_strParam2 = %2% ; second parameter, the selected path or filename

if (g_strParam0 > 0) and StrLen(g_strParam1)
{
	; try to send message to compiled QAP
	intResult := Send_WM_COPYDATA(g_strParam1 . "|" . g_strParam2, g_stTargetAppTitle)
	; returns FAIL or 0 if an error occurred, 0xFFFF if a QAP window is open or 1 if success
	
	; if error, check if running in dev
	if (intResult <> 1) and (intResult <> 0xFFFF)
		intResult := Send_WM_COPYDATA(g_strParam1 . "|" . g_strParam2, g_stTargetAppTitleDev)
	
	if (intResult = 0xFFFF)
		Oops("A settings window is open in ~1~ with unsaved changes.`n`nPlease, close settings window before using this context menu.", g_stTargetAppName)
	; else if (intResult <> 1)
	;	Oops("An error occurred while sending message to ~1~ (error: ~2~).`n`nCheck if ~1~ is running...", g_stTargetAppName, intResult)
}
else
	Oops("Do not run ~1~ directly. Right-click file or folder icons in Explorer.`n`nSee ""Context menus"" checkbox in ~2~ Options window.", g_strAppNameText, g_stTargetAppName)

return


;-----------------------------------------------------------
Send_WM_COPYDATA(ByRef strStringToSend, ByRef strTargetScriptTitle) ; ByRef saves a little memory in this case.
; Adapted from AHK documentation (https://autohotkey.com/docs/commands/OnMessage.htm)
; This function sends the specified string to the specified window and returns the reply.
; The reply is 1 if the target window processed the message, or 0 if it ignored it.
;-----------------------------------------------------------
{
    VarSetCapacity(varCopyDataStruct, 3 * A_PtrSize, 0) ; Set up the structure's memory area.
	
    ; First set the structure's cbData member to the size of the string, including its zero terminator:
    intSizeInBytes := (StrLen(strStringToSend) + 1) * (A_IsUnicode ? 2 : 1)
    NumPut(intSizeInBytes, varCopyDataStruct, A_PtrSize) ; OS requires that this be done.
    NumPut(&strStringToSend, varCopyDataStruct, 2 * A_PtrSize) ; Set lpData to point to the string itself.

	strPrevDetectHiddenWindows := A_DetectHiddenWindows
    intPrevTitleMatchMode := A_TitleMatchMode
    DetectHiddenWindows On
    SetTitleMatchMode 2
	
    SendMessage, 0x4a, 0, &varCopyDataStruct, , %strTargetScriptTitle% ; 0x4a is WM_COPYDATA. Must use Send not Post.
	
    DetectHiddenWindows %strPrevDetectHiddenWindows% ; Restore original setting for the caller.
    SetTitleMatchMode %intPrevTitleMatchMode% ; Same.
	
    return ErrorLevel ; Return SendMessage's reply back to our caller.
}
;-----------------------------------------------------------


;------------------------------------------------
Oops(strMessage, objVariables*)
;------------------------------------------------
{
	global g_strAppNameText
	global g_strAppVersionLong
	
	MsgBox, 48, % L("~1~ (~2~)", g_strAppNameText, g_strAppVersionLong), % L(strMessage, objVariables*)
}
; ------------------------------------------------


;------------------------------------------------
L(strMessage, objVariables*)
;------------------------------------------------
{
	Loop
	{
		if InStr(strMessage, "~" . A_Index . "~")
			StringReplace, strMessage, strMessage, ~%A_Index%~, % objVariables[A_Index], A
 		else
			break
	}
	
	return strMessage
}
;------------------------------------------------


