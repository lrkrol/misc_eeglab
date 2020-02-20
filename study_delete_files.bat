
@echo off


::  Script to delete all files related to EEGLAB studies.
::
::  This script PERMANENTLY DELETES all files in a given directory,
::  and in ALL SUBDIRECTORIES, starting with a given study design name,
::  and ending with known study-related extensions:
::
::      .daterp      .icaerp
::      .daterpimg   .icaerpim
::      .datersp     .icaersp
::      .datitc      .icaitc
::      .datspec     .icaspec
::      .dattimef    .icatimef
::   
::  Copyright (c) 2019 Laurens R Krol. All rights reserved.
::
::  This work is licensed under the terms of the MIT license.  
::  For a copy, see <https://opensource.org/licenses/MIT>.


set design=design1
set directory=.
set /p design="Design name ( default: design1 ) : "
set /p directory="Directory   ( default: . )       : "

dir /b %directory%\%design%*.daterp %directory%\%design%*.daterpimg %directory%\%design%*.datersp %directory%\%design%*.datitc %directory%\%design%*.datspec %directory%\%design%*.dattimef %directory%\%design%*.icaerp %directory%\%design%*.icaerpim %directory%\%design%*.icaersp %directory%\%design%*.icaitc %directory%\%design%*.icaspec %directory%\%design%*.icatimef /s 2> nul | find "" /v /c > tmp && set /p count=<tmp && del tmp

if "%count%"=="" (
    echo Found no files related to %design%.
    exit /b
)

set /p confirm="About to PERMANENTLY DELETE %count% files related to %design%. Continue? (y/n) "
if "%confirm%"=="y" (
    echo Ok.
    del /s %directory%\%design%*.daterp %directory%\%design%*.daterpimg %directory%\%design%*.datersp %directory%\%design%*.datitc %directory%\%design%*.datspec %directory%\%design%*.dattimef %directory%\%design%*.icaerp %directory%\%design%*.icaerpim %directory%\%design%*.icaersp %directory%\%design%*.icaitc %directory%\%design%*.icaspec %directory%\%design%*.icatimef
) else (
    echo Ok. Nothing changed.
)
