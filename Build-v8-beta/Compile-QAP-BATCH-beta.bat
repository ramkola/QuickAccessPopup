@ECHO OFF
rem Set environment variables for Inno Setup and this batch
SET QAPVERSIONPREV=9_3_2_9_4
SET QAPVERSION=9_3_2_9_5
SET QAPVERSIONNUMBER=9.3.2.9.5
SET QAPVERSIONTEXT=v%QAPVERSIONNUMBER% BETA
SET QAPBETAPROD=-beta
rem Call Compile batch
CALL "E:\Dropbox\AutoHotkey\QuickAccessPopup\Setup Script files\Compile-QAP-v8.bat"
