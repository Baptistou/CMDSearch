@ECHO OFF
REM Programme SEARCH version 6.0 par Baptiste Th‚mine
SETLOCAL DISABLEDELAYEDEXPANSION
SET FIND=FINDSTR
SET FPAR= 
SET FSTR=[/C:,/C:]
SET NBCHAR=160
SET -A= 
SET -B= 
SET -C= 
SET -E= 
SET -I= 
SET -L=/L
SET -M= 
SET -O= 
SET -P= 
SET -Q= 
SET -R= 
SET -S= 
SET -T= 
SET -V= 
SET -X= 
CALL :SECURE DIR "%CD%"
SET NAME=*
SET ATTR=
SET DMY=
SET DATE1=01/01/1900
SET DATE2=%DATE%
SET HM=
SET TIME1=00:00
SET TIME2=23:59
SET TEXT=
SET FILE1=
SET FILE2=
SET CMDECHO=true
SET CMDLINE=echo !FATTR! !FTIME! !FSIZE!	!FPATH!!FNAME!!FEXT!
SET COMPLINE=echo @fattr @fdate @ftime @fsize@tab@frelp
SET 0x21=!
SET SEARCH=%0
SET TMPFILE1="%TEMP%\searchtmpfile1.txt"
SET TMPFILE2="%TEMP%\searchtmpfile2.txt"

:START
IF /I "%~1"=="FILE" (
	SET EXE=FILE
	GOTO SETPATH
) ELSE IF /I "%~1"=="TEXT" ( SET EXE=TEXT
) ELSE IF /I "%~1"=="COMP" ( SET EXE=COMP
) ELSE IF /I "%~1"=="HELP" ( GOTO HELP
) ELSE GOTO FASTHELP

:PARAMETERS
SHIFT
IF "%~1%~2%~3"=="" GOTO SEARCH%EXE%
IF "%~1"=="" GOTO ERROR
SET "ARGS=%~1"
IF /I "%ARGS:~0,4%"=="/CMD" GOTO SETCMDLINE
GOTO par%EXE%
:parfile
IF /I "%ARGS%"=="/DIR" ( GOTO SETDIR
) ELSE IF /I "%ARGS%"=="/NAME" ( GOTO SETNAME
) ELSE IF /I "%ARGS%"=="/DATE" ( GOTO SETDATE
) ELSE IF /I "%ARGS%"=="/TIME" ( GOTO SETTIME
) ELSE IF /I "%ARGS:~0,3%"=="/A:" ( CALL :GETARGS ADHILRS- ATTR || GOTO ERROR
) ELSE IF /I "%ARGS%"=="/A" ( SET ATTR=
) ELSE IF /I "%ARGS:~0,3%"=="/O:" ( CALL :GETARGS DEGNS- -O /O: || GOTO ERROR
) ELSE IF /I "%ARGS%"=="/O" ( SET -O= 
) ELSE IF /I "%ARGS%"=="/S" ( SET -S=/S
) ELSE IF /I "%ARGS:~0,3%"=="/T:" ( CALL :GETARGS ACW -T /T: || GOTO ERROR
) ELSE IF /I "%ARGS%"=="/T" ( SET -T= 
) ELSE GOTO ERROR
GOTO PARAMETERS
:partext
IF NOT DEFINED TEXT ( GOTO SETTEXT
) ELSE IF /I "%ARGS%"=="/DIR" ( GOTO SETDIR
) ELSE IF /I "%ARGS%"=="/NAME" ( GOTO SETNAME
) ELSE IF /I "%ARGS%"=="/FIND" (
	SET FIND=FIND
	SET FPAR=/FIND
	SET FSTR=[/C:,   ]
	SET -L= 
) ELSE IF /I "%ARGS%"=="/FINDSTR" (
	SET FIND=FINDSTR
	SET FPAR=/FINDSTR
	SET FSTR=[   ,   ]
	SET -L= 
) ELSE IF /I "%ARGS%"=="/B" ( SET -B=/B
) ELSE IF /I "%ARGS%"=="/C" ( SET -C=/C
) ELSE IF /I "%ARGS%"=="/E" ( SET -E=/E
) ELSE IF /I "%ARGS%"=="/I" ( SET -I=/I
) ELSE IF /I "%ARGS%"=="/L" (
	SET -L=/L
	SET -R= 
) ELSE IF /I "%ARGS%"=="/M" ( SET -M=/M
) ELSE IF /I "%ARGS:~0,3%"=="/N:" ( CALL :GETARGS 0-9 NBCHAR || GOTO ERROR
) ELSE IF /I "%ARGS%"=="/N" ( SET NBCHAR=160
) ELSE IF /I "%ARGS%"=="/P" ( SET -P=/P
) ELSE IF /I "%ARGS%"=="/Q" ( SET -Q=/P
) ELSE IF /I "%ARGS%"=="/R" (
	SET -L= 
	SET -R=/R
) ELSE IF /I "%ARGS%"=="/S" ( SET -S=/S
) ELSE IF /I "%ARGS%"=="/X" ( SET -X=/X
) ELSE GOTO ERROR
IF %FIND%==FIND ECHO "%-B%%-E%%-L%%-Q%%-R%%-X%" | FINDSTR "[A-Z]" > nul && GOTO ERROR
GOTO PARAMETERS
:parcomp
IF NOT DEFINED FILE1 ( GOTO SETFILES
) ELSE IF /I "%ARGS%"=="/NAME" (
	ECHO "%-A%%-B%%-I%%-R%" | FINDSTR "[A-Z]" > nul && GOTO ERROR
	GOTO SETNAME
) ELSE IF /I "%ARGS%"=="/DATE" (
	ECHO "%-A%%-B%%-I%%-R%" | FINDSTR "[A-Z]" > nul && GOTO ERROR
	GOTO SETDATE
) ELSE IF /I "%ARGS%"=="/TIME" (
	ECHO "%-A%%-B%%-I%%-R%" | FINDSTR "[A-Z]" > nul && GOTO ERROR
	GOTO SETTIME
) ELSE IF /I "%ARGS:~0,3%"=="/A:" ( CALL :GETARGS ADHILRS- ATTR /A: || GOTO ERROR
) ELSE IF /I "%ARGS%"=="/A" ( SET -A=/A
) ELSE IF /I "%ARGS%"=="/B" (
	SET -B=/B
	SET -R= 
) ELSE IF /I "%ARGS%"=="/I" ( SET -I=/C
) ELSE IF /I "%ARGS%"=="/R" (
	SET -B= 
	SET -R=/R
) ELSE IF /I "%ARGS%"=="/S" ( SET -S=/S
) ELSE IF /I "%ARGS:~0,3%"=="/T:" ( CALL :GETARGS ACW -T /T: || GOTO ERROR
) ELSE IF /I "%ARGS%"=="/T" ( SET -T= 
) ELSE IF /I "%ARGS%"=="/V" ( SET -V=/V
) ELSE GOTO ERROR
ECHO "%-A%%-B%%-I%%-R%" | FINDSTR "[A-Z]" > nul && ECHO "%ATTR%%-S%%-T%%-V%" | FINDSTR "[A-Z]" > nul && GOTO ERROR
GOTO PARAMETERS

:GETARGS
ECHO "%ARGS:~3%"| FINDSTR /I ".[^%1]." > nul
IF ERRORLEVEL 1 (
	SET "%2=%3%ARGS:~3%"
	EXIT /B 0
) ELSE EXIT /B 1

:SEARCHFILE
IF %CMDECHO%==false GOTO next1
ECHO.
ECHO ----------------------------- RAPPORT DE RECHERCHE -----------------------------
ECHO.
ECHO G‚n‚r‚ le : %DATE% %TIME:~0,5%
ECHO R‚pertoire de recherche : %DIR%
ECHO Masque de recherche : %NAME%
ECHO Attributs : %ATTR%
ECHO Plage de dates : %DATE1% - %DATE2%
ECHO Plage horaire : %TIME1% - %TIME2%
ECHO ParamŠtres : %-O% %-S% %-T%
ECHO.
ECHO R‚sultat de la recherche :
:next1
SET /A N=0
PUSHD %DIR%
IF NOT "%DIR:~-1%"=="\" SET "DIR=%DIR%\"
IF NOT ERRORLEVEL 1 FOR /F "tokens=1-3*" %%I IN ('DIR /A:%ATTR% /-C %-O% %-S% %-T% %NAME%') DO (
	FOR /F "tokens=1,2,3 delims=:" %%M IN ("%%L") DO (
		SET FNAME=%%M
		IF NOT "%%N"=="" CALL SET FNAME=%%FNAME:~0,-3%%
	)
	IF "%%I"=="R‚pertoire" (
		IF "%%K"=="%%~dK\" ( SET FPATH=%%K
		) ELSE IF "%%L"=="" ( SET FPATH=%%K\
		) ELSE SET FPATH=%%K %%L\
	) ELSE IF NOT "%%L"=="." IF NOT "%%L"==".." CALL :GETFILE1 "%%I %%J" "%%K" "%%FPATH:'=?%%%%FNAME:'=?%%"
)
POPD
IF %CMDECHO%==false GOTO EXIT
ECHO.
ECHO %N% fichier(s)/r‚pertoire(s) trouv‚(s)
GOTO EXIT

:GETFILE1
SET FTIME=%~1
IF NOT "%FTIME:~2,1%"=="/" GOTO :EOF
SET "FSHORT=%~s3"
SET "FNAME=%~n3"
SET "FEXT=%~x3"
SET "FATTR=%~a3"
SET "FBYTE=%~2"
IF "%FBYTE:~0,1%"=="<" SET "FBYTE=%FBYTE:~1,3%"
IF "%FBYTE:~3,1%"=="" ( SET FSIZE=%FBYTE%
) ELSE IF "%FBYTE:~6,1%"=="" ( SET FSIZE=%FBYTE:~0,-3%k
) ELSE IF "%FBYTE:~9,1%"=="" ( SET FSIZE=%FBYTE:~0,-6%M
) ELSE SET FSIZE=%FBYTE:~0,-9%G

:FILTER
IF NOT "%DMY%"=="*" (
	IF %FTIME:~6,4%%FTIME:~3,2%%FTIME:~0,2% LSS %DATE1:~6,4%%DATE1:~3,2%%DATE1:~0,2% GOTO :EOF
	IF %FTIME:~6,4%%FTIME:~3,2%%FTIME:~0,2% GTR %DATE2:~6,4%%DATE2:~3,2%%DATE2:~0,2% GOTO :EOF
)
IF NOT "%HM%"=="*" (
	IF %TIME1:~0,2%%TIME1:~3,2% LEQ %TIME2:~0,2%%TIME2:~3,2% (
		IF %FTIME:~11,2%%FTIME:~14,2% LSS %TIME1:~0,2%%TIME1:~3,2% GOTO :EOF
		IF %FTIME:~11,2%%FTIME:~14,2% GTR %TIME2:~0,2%%TIME2:~3,2% GOTO :EOF
	) ELSE IF %FTIME:~11,2%%FTIME:~14,2% LSS %TIME1:~0,2%%TIME1:~3,2% IF %FTIME:~11,2%%FTIME:~14,2% GTR %TIME2:~0,2%%TIME2:~3,2% GOTO :EOF
)
SET /A N+=1
SETLOCAL ENABLEDELAYEDEXPANSION
SET "FRELPATH=!FPATH:%DIR%=!!!FNAME!!!!FEXT!!"
%CMDLINE%
ENDLOCAL
GOTO :EOF

:SEARCHTEXT
IF NOT DEFINED TEXT GOTO ERROR
IF %CMDECHO%==false GOTO next2
ECHO.
ECHO ----------------------------- RAPPORT DE RECHERCHE -----------------------------
ECHO.
ECHO G‚n‚r‚ le : %DATE% %TIME:~0,5%
ECHO R‚pertoire de recherche : %DIR%
ECHO Masque de recherche : %NAME%
ECHO Texte recherch‚ : "%TEXT%"
ECHO ParamŠtres : %FPAR% %-B% %-C% %-E% %-I% %-L% %-M% /N:%NBCHAR% %-P% %-Q:/P=/Q% %-R% %-S% %-X%
ECHO.
ECHO R‚sultat de la recherche :
:next2
SET /A N=0
PUSHD %DIR%
IF NOT "%DIR:~-1%"=="\" SET "DIR=%DIR%\"
IF NOT ERRORLEVEL 1 FOR /F "delims=" %%I IN ('FINDSTR %-B% %-E% %-I% %-L% /M %-P% %-R% %-S% %-X% %FSTR:~1,3%"%TEXT%" %NAME%') DO (
	SET FPATH=%%~dpI
	SET FSHORT=%%~sI
	SET FNAME=%%~nI
	SET FEXT=%%~xI
	SET FATTR=%%~aI
	SET FTIME=%%~tI
	SET FBYTE=%%~zI
	CALL :GETFILE2
)
POPD
IF %CMDECHO%==false GOTO EXIT
IF "%-M%"=="/M" ( IF NOT "%-C%"=="/C" ECHO.
) ELSE IF %N% EQU 0 ECHO.
ECHO %N% fichier(s) trouv‚(s)
GOTO EXIT

:GETFILE2
IF "%FATTR:~-1%"=="l" SET FBYTE=SYM
IF "%FBYTE:~3,1%"=="" ( SET FSIZE=%FBYTE%
) ELSE IF "%FBYTE:~6,1%"=="" ( SET FSIZE=%FBYTE:~0,-3%k
) ELSE IF "%FBYTE:~9,1%"=="" ( SET FSIZE=%FBYTE:~0,-6%M
) ELSE SET FSIZE=%FBYTE:~0,-9%G

:RESULT
SET /A N+=1
SETLOCAL ENABLEDELAYEDEXPANSION
SET "FRELPATH=!FPATH:%DIR%=!!!FNAME!!!!FEXT!!"
%CMDLINE%
ENDLOCAL
IF NOT "%-M%"=="/M" GOTO lines
IF "%-C%"=="/C" GOTO count
GOTO :EOF
:lines
FOR /F "eol=- tokens=1-5 delims=" %%I IN ('%FIND% %-B% %-E% %-I% %-L% /N %-Q% %-R% %-X% %FSTR:~5,3%"%TEXT%" "%FSHORT%"') DO (
	SET STR=%%I%%J%%K%%L%%M
	CALL :DELCR
	SETLOCAL ENABLEDELAYEDEXPANSION
	SET STR=!STR:="!
	ECHO !STR:~0,%NBCHAR%!
	ENDLOCAL
)
IF "%-C%"=="/C" GOTO count
ECHO.
GOTO :EOF
:count
FOR /F %%I IN ('%FIND% %-B% %-E% %-I% %-L% /N %-Q% %-R% %-X% %FSTR:~5,3%"%TEXT%" "%FSHORT%" ^| FIND /C /V ""') DO ECHO LINES = %%I
ECHO.
GOTO :EOF

:DELCR
SET "STR=%STR:"=%"
GOTO :EOF

:SEARCHCOMP
IF NOT DEFINED FILE1 GOTO ERROR
IF NOT DEFINED FILE2 GOTO ERROR
CALL :SECURE SFILE1 "%FILE1%"
CALL :SECURE SFILE2 "%FILE2%"
SET COMP=COMPFILE
IF EXIST "%FILE1%\*" IF EXIST "%FILE2%\*" SET COMP=COMPDIR
IF %CMDECHO%==false GOTO next3
ECHO.
ECHO ----------------------------- RAPPORT DE RECHERCHE -----------------------------
ECHO.
ECHO G‚n‚r‚ le : %DATE% %TIME:~0,5%
ECHO Fichier 1 : %SFILE1%
ECHO Fichier 2 : %SFILE2%
IF %COMP%==COMPFILE ECHO ParamŠtres : %-A% %-B% %-I:/C=/I% %-R%
IF %COMP%==COMPDIR ECHO ParamŠtres : /NAME %NAME% /DATE %DATE1%-%DATE2% /TIME %TIME1%-%TIME2% %ATTR% %-S% %-T% %-V%
ECHO.
ECHO R‚sultat de la recherche :
:next3
GOTO %COMP%%-B:~1%%-R:~1%

:COMPDIR
ECHO Comparaison des r‚pertoires %SFILE1% et %SFILE2%
CALL %SEARCH% FILE /DIR "%%FILE1%%" /NAME %%NAME%% /DATE %DATE1%-%DATE2% /TIME %TIME1%-%TIME2% %ATTR% /O:N %-S% %-T% /CMDONLY "%COMPLINE%" /SLASH > %TMPFILE1%
ECHO -------------------------------------------------------------------------------->> %TMPFILE1%
CALL %SEARCH% FILE /DIR "%%FILE2%%" /NAME %%NAME%% /DATE %DATE1%-%DATE2% /TIME %TIME1%-%TIME2% %ATTR% /O:N %-S% %-T% /CMDONLY "%COMPLINE%" /SLASH > %TMPFILE2%
ECHO -------------------------------------------------------------------------------->> %TMPFILE2%
SET /A N=0
ECHO ***** %SFILE1%
FOR /F "delims=" %%I IN ('FINDSTR /L /V /X /G:%TMPFILE2% %TMPFILE1%') DO (
	ECHO %%I
	SET /A N+=1
)
ECHO ***** %SFILE2%
FOR /F "delims=" %%I IN ('FINDSTR /L /V /X /G:%TMPFILE1% %TMPFILE2%') DO (
	ECHO %%I
	SET /A N+=1
)
ECHO *****
DEL %TMPFILE1% %TMPFILE2%
IF %CMDECHO%==false GOTO EXIT
ECHO.
ECHO %N% fichier(s)/r‚pertoire(s) trouv‚(s)
GOTO EXIT

:COMPDIRV
ECHO Comparaison des r‚pertoires %SFILE1% et %SFILE2%
CALL %SEARCH% FILE /DIR "%%FILE1%%" /NAME %%NAME%% /DATE %DATE1%-%DATE2% /TIME %TIME1%-%TIME2% %ATTR% /O:N %-S% %-T% /CMDONLY "%COMPLINE%" /SLASH > %TMPFILE1%
CALL %SEARCH% FILE /DIR "%%FILE2%%" /NAME %%NAME%% /DATE %DATE1%-%DATE2% /TIME %TIME1%-%TIME2% %ATTR% /O:N %-S% %-T% /CMDONLY "%COMPLINE%" /SLASH > %TMPFILE2%
SET /A N=0
FOR /F "delims=" %%I IN ('FINDSTR /L /X /G:%TMPFILE1% %TMPFILE2%') DO (
	ECHO %%I
	SET /A N+=1
)
DEL %TMPFILE1% %TMPFILE2%
IF %CMDECHO%==false GOTO EXIT
ECHO.
ECHO %N% fichier(s)/r‚pertoire(s) trouv‚(s)
GOTO EXIT

:COMPFILE
SET /A N=0
FOR /F "tokens=1-5 delims=" %%I IN ('FC %-A% %-I% /L /N "%FILE1%" "%FILE2%" 2^>^&1') DO (
	ECHO %%I%%J%%K%%L%%M
	IF "%%~I"=="*****" (
		ECHO --------------------------------------------------------------------------------
		SET /A N+=1
	)
)
IF %CMDECHO%==false GOTO EXIT
ECHO.
ECHO %N% diff‚rence(s) trouv‚(s)
GOTO EXIT

:COMPFILEB
SET /A N=0
FOR /F "tokens=1*" %%I IN ('FC /B "%FILE1%" "%FILE2%" 2^>^&1') DO (
	ECHO %%I %%J
	IF NOT "%%~I"=="Comparaison" IF NOT "%%~I"=="FCÿ:" SET /A N+=1
)
IF %CMDECHO%==false GOTO EXIT
ECHO.
ECHO %N% diff‚rence(s) trouv‚(s)
GOTO EXIT

:COMPFILER
SET STR=
SET /A N=0, MIN=0, MAX=0
FOR /F "tokens=1*" %%I IN ('FC /A %-I% /L /N "%FILE1%" "%FILE2%" 2^>^&1') DO (
	IF "%%~I"=="Comparaison" ( ECHO %%I %%J
	) ELSE IF "%%~I"=="FCÿ:" ( ECHO %%I %%J
	) ELSE IF "%%~I"=="chec" ECHO %%I %%J
	CALL :GETLINES "%%~I"
	IF "%%~I%%~J"=="*****" SET /A N+=1
)
IF %CMDECHO%==false GOTO EXIT
ECHO.
ECHO %N% diff‚rence(s) trouv‚(s)
GOTO EXIT

:GETLINES
IF %MIN% EQU 0 (
	SET /A "MIN=%~1" > nul 2>&1
	SET /A MAX=MIN
) ELSE IF NOT "%~1"=="*****" ( SET /A "MAX=%~1" > nul 2>&1
) ELSE (
	IF DEFINED STR (
		ECHO %STR%   		[%MIN%;%MAX%]
		SET STR=
	) ELSE SET STR=[%MIN%;%MAX%]
	SET /A MIN=0, MAX=0
)
GOTO :EOF

:SETPATH
IF "%~2"=="" GOTO PARAMETERS
ECHO "%~2" | FINDSTR /B "./" > nul && GOTO PARAMETERS
ECHO "%~2" | FINDSTR /R "\\ / : \<\.\> \<\.\.\>" > nul
IF ERRORLEVEL 1 GOTO SETNAME
IF EXIST "%~2\*" GOTO SETDIR
SHIFT
SET "DIR=%~dp1"
ECHO "%DIR%" | FINDSTR "| < >" > nul && GOTO ERROR
CALL :SECURE DIR "%DIR:"=%"
SET "NAME=%~1"
SET "NAME=%NAME:/=\%"
:while1
SET "NAME=%NAME:*\=%"
IF NOT "%NAME%"=="%NAME:*\=%" GOTO while1
:then1
ECHO "%NAME%" | FINDSTR "\\ / : | < >" > nul && GOTO ERROR
ECHO "%NAME%" | FIND "*" > nul
IF ERRORLEVEL 1 ( SET NAME="*%NAME: =*%*"
) ELSE SET NAME="%NAME%"
GOTO PARAMETERS

:SETDIR
IF "%~2"=="" GOTO PARAMETERS
ECHO "%~2" | FINDSTR /B "./" > nul && GOTO PARAMETERS
SHIFT
SET "DIR=%~f1"
ECHO "%DIR%" | FINDSTR "| < >" > nul && GOTO ERROR
CALL :SECURE DIR "%DIR:"=%"
GOTO PARAMETERS

:SETNAME
IF "%~2"=="" GOTO PARAMETERS
ECHO "%~2" | FINDSTR /B "./" > nul && GOTO PARAMETERS
SHIFT
CALL SET NAME=%%1
ECHO "%NAME:"=%" | FINDSTR "\\ / : | < >" > nul && GOTO ERROR
GOTO then2
:while2
SHIFT
CALL SET NAME=%%NAME%% %%1
ECHO "%NAME:"=%" | FINDSTR "\\ / : | < >" > nul && GOTO ERROR
:then2
IF NOT "%~2"=="" ECHO "%~2" | FINDSTR /B "./" > nul || GOTO while2
ECHO "%NAME:"=%" | FIND "*" > nul && GOTO PARAMETERS
SET "NAME= %NAME:"=% "
IF "%NAME:~1,1%"=="." SET "NAME=%NAME: .= *.%"
SET "NAME=%NAME: = *%"
SET "NAME=%NAME: =* %"
SET "NAME=%NAME:~1,-1%"
ECHO "%NAME%" | FIND "*" > nul || SET NAME="*%NAME: =*%*"
SET NAME=%NAME:="%
GOTO PARAMETERS

:SETDATE
CALL :DEFAULT DMY %DATE% "%~2" || SHIFT
ECHO "%DMY%" | FINDSTR "\/? & | < > = ^" > nul && GOTO ERROR
ECHO %DMY:~0,10%| FINDSTR "[0-9][0-9][-./\\][0-9][0-9][-./\\][0-9][0-9][0-9][0-9]" > nul || GOTO ERROR
ECHO %DMY:~-10%| FINDSTR "[0-9][0-9][-./\\][0-9][0-9][-./\\][0-9][0-9][0-9][0-9]" > nul || GOTO ERROR
ECHO %DMY:~10,-10%| FINDSTR /R /C:"[-.,; ]" > nul || GOTO ERROR
SET DATE1=%DMY:~0,2%/%DMY:~3,2%/%DMY:~6,4%
SET DATE2=%DMY:~-10,2%/%DMY:~-7,2%/%DMY:~-4%
GOTO PARAMETERS

:SETTIME
CALL :DEFAULT HM %TIME:~0,5% "%~2" || SHIFT
ECHO "%HM%" | FINDSTR "\/? & | < > = ^" > nul && GOTO ERROR
ECHO %HM:~0,5%| FINDSTR "[0-9][0-9][-.:][0-9][0-9]" > nul || GOTO ERROR
ECHO %HM:~-5%| FINDSTR "[0-9][0-9][-.:][0-9][0-9]" > nul || GOTO ERROR
ECHO %HM:~5,-5%| FINDSTR /R /C:"[-.,; ]" > nul || GOTO ERROR
SET TIME1=%HM:~0,2%:%HM:~3,2%
SET TIME2=%HM:~-5,2%:%HM:~-2%
GOTO PARAMETERS

:SETTEXT
SET "TEXT=%~1"
ECHO "%TEXT%" | FINDSTR /B "./" > nul && SET "TEXT=\%TEXT%"
GOTO SETPATH

:SETFILES
ECHO "%~1" | FINDSTR "* ?" > nul
IF ERRORLEVEL 1 ( SET "FILE1=%~f1"
) ELSE SET "FILE1=%~1"
ECHO "%FILE1%" | FINDSTR "| < >" > nul && GOTO ERROR
IF "%~2"=="" GOTO PARAMETERS
SHIFT
ECHO "%~1" | FINDSTR "* ?" > nul
IF ERRORLEVEL 1 ( SET "FILE2=%~f1"
) ELSE SET "FILE2=%~1"
ECHO "%FILE2%" | FINDSTR "| < >" > nul && GOTO ERROR
GOTO PARAMETERS

:DEFAULT
IF %3=="" (
	SET %1=%2
	EXIT /B 0
)
ECHO %3 | FINDSTR /B "./" > nul
IF NOT ERRORLEVEL 1 (
	SET %1=%2
	EXIT /B 0
)
SET "%1=%~3"
EXIT /B 1

:SETCMDLINE
IF /I "%ARGS:~4%"=="ONLY" ( SET CMDECHO=false
) ELSE IF NOT "%ARGS:~4%"=="" GOTO ERROR
IF "%~2"=="" GOTO PARAMETERS
ECHO "%~2" | FINDSTR /B "./" > nul && GOTO PARAMETERS
SHIFT
SET "CMDLINE=%~1"
SET "COMPLINE=%~1"
SET "CMDLINE=%CMDLINE:!=!0x21!%"
IF /I NOT "%~2"=="/SLASH" GOTO backslash
:slash
SHIFT
SET "CMDLINE=%CMDLINE:@fpath=!FPATH:\=/!!FNAME!!FEXT!%"
SET "CMDLINE=%CMDLINE:@frelp=!FRELPATH:\=/!%"
SET "CMDLINE=%CMDLINE:@fshort=!FSHORT:\=/!%"
:backslash
SET "CMDLINE=%CMDLINE:@fpath=!FPATH!!FNAME!!FEXT!%"
SET "CMDLINE=%CMDLINE:@frelp=!FRELPATH!%"
SET "CMDLINE=%CMDLINE:@fshort=!FSHORT!%"
SET "CMDLINE=%CMDLINE:@fname=!FNAME!%"
SET "CMDLINE=%CMDLINE:@fext=!FEXT!%"
SET "CMDLINE=%CMDLINE:@fattr=!FATTR!%"
SET "CMDLINE=%CMDLINE:@fdate=!FTIME:~0,10!%"
SET "CMDLINE=%CMDLINE:@ftime=!FTIME:~11,5!%"
SET "CMDLINE=%CMDLINE:@fsize=!FSIZE!%"
SET "CMDLINE=%CMDLINE:@fbyte=!FBYTE!%"
SET "CMDLINE=%CMDLINE:@count=!N!%"
SET "CMDLINE=%CMDLINE:@tab=	%"
CALL :SECURE CMDLINE "%CMDLINE%"
SET CMDLINE=%CMDLINE:@qot="%
GOTO PARAMETERS

:SECURE
SET "STR=%~2"
SET "STR=%STR:&=^&%"
SET "STR=%STR:|=^|%"
SET "STR=%STR:<=^<%"
SET "STR=%STR:>=^>%"
SET "%1=%STR%"
GOTO :EOF

:FASTHELP
ECHO La syntaxe de cette commande estÿ:
ECHO.
ECHO SEARCH HELP					Afficher l'aide
ECHO SEARCH FILE [fichiers...] [options]		Recherche de fichier
ECHO SEARCH TEXT "chaŒne" [fichiers...] [options]	Recherche de texte
ECHO SEARCH COMP fichier1 fichier2 [options]		Comparaison de fichiers
ECHO SEARCH ... [/CMD[ONLY] "cmdline"]		Option ligne de commande
EXIT /B 2

:HELP
SHIFT
IF NOT "%~1"=="" ECHO "%~1" | FINDSTR /I "FILE TEXT COMP CMD" > nul || GOTO ERROR
ECHO Programme SEARCH version 6.0 par Baptiste Th‚mine
ECHO.
IF /I "%~1"=="FILE" GOTO helpfile
IF /I "%~1"=="TEXT" GOTO helptext
IF /I "%~1"=="COMP" GOTO helpcomp
IF /I "%~1"=="CMD" GOTO helpcmd
:helpfile
ECHO SEARCH FILE [r‚pertoire ^| fichiers...] [options]
ECHO.
ECHO  Options : [/DIR r‚pertoire] [/NAME fichiers...] [/DATE [date]] [/TIME [heure]]
ECHO            [/A[:attribut]] [/O[:tri]] [/S] [/T[:tf]]
ECHO.
ECHO  La recherche de fichier permet de filtrer les fichiers d'un r‚pertoire selon :
ECHO  - un masque de recherche c…d un ou plusieurs titres et/ou extensions de
ECHO    fichier (caractŠres g‚n‚riques "*" et "?" autoris‚s). Par exemple,
ECHO    /NAME un titre		recherche les fichiers contenant "*un*titre*"
ECHO    /NAME "titre1" "titre2"	recherche les fichiers "*titre1*" ou "*titre2*"
ECHO    /NAME .txt .bat		recherche les fichiers textes et batch
ECHO  - un attribut	D  R‚pertoire		R  Lecture seule
ECHO 		H  Cach‚		A  Archive
ECHO 		S  SystŠme		I  Fichiers index‚s sans contenu
ECHO 		L  Points d'analyse	-  Pr‚fixe de n‚gation
ECHO  - une date [jj/mm/aaaa] ou une plage de dates [jj/mm/aaaa - jj/mm/aaaa].
ECHO  - une heure [hh:mm] ou une plage horaire [hh:mm - hh:mm].
ECHO  Remarque : /DATE et /TIME sp‚cifi‚s seuls valent la date et l'heure actuelle.
ECHO.
IF "%~1"=="" GOTO helptext
ECHO  /O:tri	Affiche les fichiers selon un tri sp‚cifi‚.
ECHO 	N  Nom (alphab‚tique)		S  Taille (ordre croissant)
ECHO 	E  Extension (alphab‚tique)	D  Date et heure (chronologique)
ECHO 	G  R‚pertoires en tˆte		-  Pr‚fixe en ordre indirect
ECHO  /S	Recherche les fichiers correspondants dans le r‚pertoire et dans tous
ECHO 	ses sous-r‚pertoires.
ECHO  /T:tf	Contr“le le champ d'heure affich‚ et utilis‚ dans le tri.
ECHO 	C  Cr‚ation		A  Dernier accŠs	W  DerniŠre ‚criture
ECHO.
ECHO  Exemples :
ECHO.
ECHO  SEARCH FILE /S
ECHO  Affiche tous les fichiers pr‚sents dans le r‚pertoire en cours et tous ses
ECHO  sous-r‚pertoires.
ECHO.
ECHO  SEARCH FILE %%TEMP%%
ECHO  Affiche tous les ‚l‚ments pr‚sents dans le dossier temporaire de Windows.
ECHO.
ECHO  SEARCH FILE "test" "un fichier" .txt
ECHO  Recherche les fichiers textes et les fichers dont le titre contient les
ECHO  chaŒnes "test" ou "un fichier".
ECHO.
ECHO  SEARCH FILE /A:HS
ECHO  Affiche tous les fichiers cach‚s systŠmes du r‚pertoire en cours.
ECHO.
ECHO  SEARCH FILE /DIR C:\Windows\system32 /NAME %%PATHEXT%% /O:-N
ECHO  Affiche toutes les commandes de CMD.exe dans l'ordre alphab‚tique d‚croissant.
ECHO.
ECHO  SEARCH FILE /DATE /TIME 8:00-18:00
ECHO  Recherche tous les ‚l‚ments modifi‚s aujourd'hui entre 8 et 18 heures.
ECHO.
ECHO  SEARCH FILE /DATE 12/12/2012-%%DATE%% /T:C
ECHO  Recherche tous les ‚l‚ments cr‚‚s depuis le 12 d‚cembre 2012 … aujourd'hui.
EXIT /B 0
:helptext
ECHO SEARCH TEXT "chaŒne" [r‚pertoire ^| fichiers...] [options]
ECHO.
ECHO  Options : [/DIR r‚pertoire] [/NAME fichiers...] [/FIND[STR]] [/B] [/C] [/E]
ECHO            [/I] [/L ^| /R] [/M] [/N[:nnn]] [/P] [/Q] [/S] [/X]
ECHO.
ECHO  La recherche de texte permet de rechercher une chaŒne dans les fichiers d'un
ECHO  r‚pertoire et d'afficher les lignes correspondantes dans le rapport.
ECHO.
IF "%~1"=="" GOTO helpcomp
ECHO  /FIND	Sp‚cifie que la recherche s'effectue avec la commande FIND. Ne peut pas
ECHO 	ˆtre utilis‚e avec les commutateurs B, E, L, Q, R ou X.
ECHO  /FINDSTR	Sp‚cifie que la recherche s'effectue avec la commande FINDSTR.
ECHO  	Cette derniŠre a un comportement diff‚rent : si plusieurs mots s‚par‚s
ECHO 	par un espace sont sp‚cifi‚s, la recherche s'effectue mot par mot.
ECHO  /B	Recherche l'‚l‚ment s'il est en d‚but de ligne.
ECHO  /C	Compte le nombre de lignes contenant la chaŒne.
ECHO  /E	Recherche l'‚l‚ment s'il est en fin de ligne.
ECHO  /I	Sp‚cifie que la recherche ne doit pas tenir compte de la casse.
ECHO  /L	Recherche la chaŒne sp‚cifi‚e litt‚ralement (par d‚faut).
ECHO  /M	Ne pas afficher les lignes correspondantes.
ECHO  /N:nnn	Sp‚cifie le nombre maximal de caractŠres … afficher pour chaque ligne
ECHO 	correspondante. Sans nombre sp‚cifi‚, N = 160 caractŠres.
ECHO  /P	Ignore les fichiers contenant des caractŠres non affichables.
ECHO  /Q	Ignore les lignes correspondantes avec caractŠres non affichables.
ECHO  /R	Recherche la chaŒne sp‚cifi‚e en tant qu'expression r‚guliŠre. Pour
ECHO 	plus de d‚tails, consultez l'aide de la commande FINDSTR.
ECHO  /S	Recherche les fichiers correspondants dans le r‚pertoire et dans tous
ECHO 	ses sous-r‚pertoires.
ECHO  /X	Recherche les lignes correspondant parfaitement.
ECHO.
ECHO  Exemples :
ECHO.
ECHO  SEARCH TEXT "Hello world"
ECHO  Recherche tous les fichiers contenant la chaŒne "Hello world" et affiche les
ECHO  lignes correspondantes.
ECHO.
ECHO  SEARCH TEXT "Hello world" /DIR "test" /NAME .txt /M /X
ECHO  Recherche les fichiers textes dans le r‚pertoire "test" qui contiennent au
ECHO  moins une ligne "Hello world" mais ne les affiche pas.
ECHO.
ECHO  SEARCH TEXT "Hello world" .txt .bat /FINDSTR /B /I /L
ECHO  Recherche les fichiers textes et batch contenant les chaŒnes "Hello" ou
ECHO  "world" en d‚but de ligne et sans tenir compte de la casse.
ECHO.
ECHO  SEARCH TEXT "^[0-9][0-9]*$" /C /P /R
ECHO  Recherche dans les fichiers lisibles les lignes qui ne contiennent que des
ECHO  chiffres et affiche le r‚sultat avec le nombre de lignes correspondantes.
ECHO.
ECHO  SEARCH TEXT .* /C /M /R
ECHO  Affiche le nombre total de lignes contenus dans chaque fichier.
ECHO.
ECHO  SEARCH TEXT . /C /M /R
ECHO  Affiche le nombre total de lignes non vides contenus dans chaque fichier.
EXIT /B 0
:helpcomp
ECHO SEARCH COMP fichier1 fichier2 [options]
ECHO             r‚pertoire1 r‚pertoire2 [options]
ECHO.
ECHO  Options : fichiers     [/A] [/B ^| /R] [/I]
ECHO            r‚pertoires  [/NAME fichiers...] [/DATE [date]] [/TIME [heure]]
ECHO                         [/A[:attribut]] [/S] [/T[:tf]] [/V]
ECHO.
ECHO  La comparaison de fichiers permet de rechercher les diff‚rences entre deux
ECHO  fichiers sp‚cifi‚s et de les afficher dans le rapport. La comparaison peut
ECHO  ‚galement s'effectuer sur deux r‚pertoires auquel cas la commande va comparer
ECHO  le contenu des r‚pertoires et afficher les diff‚rences selon le nom, la taille
ECHO  et la date/heure de derniŠre modification de chaque fichier (ces critŠres
ECHO  peuvent ˆtre modifi‚s avec /CMD).
ECHO.
IF "%~1"=="" GOTO helpcmd
ECHO  /A	Affiche la 1Šre et derniŠre ligne de chaque ensemble de diff‚rences.
ECHO  /B	Effectue une comparaison binaire.
ECHO  /I	Sp‚cifie que la recherche ne doit pas tenir compte de la casse.
ECHO  /R	Affiche uniquement l'intervalle de chaque ensemble de diff‚rences.
ECHO.
ECHO  /A:att	Compare les fichiers dot‚s des attributs sp‚cifi‚s.
ECHO  /S	Compare le contenu des deux r‚pertoires sp‚cifi‚s et de tous leurs
ECHO 	sous-r‚pertoires.
ECHO  /T:tf	Contr“le le champ d'heure affich‚ et utilis‚ dans la comparaison.
ECHO 	C  Cr‚ation		A  Dernier accŠs	W  DerniŠre ‚criture
ECHO  /V	Recherche les ressemblances au lieu des diff‚rences pour la comparaison
ECHO 	de deux r‚pertoires.
ECHO.
ECHO  Exemples :
ECHO.
ECHO  SEARCH COMP test1.txt test2.txt /I
ECHO  Compare le contenu ASCII des fichiers "test1.txt" et "test2.txt" sans tenir
ECHO  compte de la casse.
ECHO.
ECHO  SEARCH COMP *.bat test.bat /A
ECHO  Compare le fichier test.bat avec tous les fichiers batch du r‚pertoire courant
ECHO  en affichant le r‚sultat abr‚g‚.
ECHO.
ECHO  SEARCH COMP test1\*.txt test2\*txt
ECHO  Compare le contenu ASCII des fichiers textes deux … deux dans les r‚pertoires
ECHO  "test1" et "test2". Les fichiers compar‚s doivent porter le mˆme nom dans les
ECHO  deux r‚pertoires.
ECHO.
ECHO  SEARCH COMP test1 test2 /A:-D /S
ECHO  Recherche toutes les diff‚rences de fichiers entre les r‚pertoires "test1" et
ECHO  "test2" et tous leurs sous-r‚pertoires.
ECHO.
ECHO  SEARCH COMP test1 test2 /V /CMD "echo @fname"
ECHO  Recherche tous les noms de fichier pr‚sents … la fois dans le r‚pertoire
ECHO  "test1" et le r‚pertoire "test2".
ECHO.
ECHO  SEARCH COMP test1 test2 /NAME .bat /T:C /CMD "echo @fdate @ftime @frelp"
ECHO  Recherche les fichiers batch pr‚sents dans les r‚pertoires "test1" et "test2"
ECHO  dont les dates/heures de cr‚ation sont diff‚rentes.
EXIT /B 0
:helpcmd
ECHO Guide de l'option ligne de commande
ECHO.
ECHO  Utilisation : SEARCH [FILE ^| TEXT ^| COMP] [/CMD[ONLY] "cmdline"]
ECHO.
ECHO  /CMD permet de rediriger le r‚sultat de la recherche vers une commande
ECHO  sp‚cifi‚e. "cmdline" indique la ligne de commande … ex‚cuter pour chaque
ECHO  fichier trouv‚ par la recherche de fichier ou de texte et permet ‚galement de
ECHO  d‚finir les critŠres de comparaison de deux r‚pertoires. Si /CMDONLY est
ECHO  sp‚cifi‚, alors seule la sortie de la ligne de commande est affich‚e. La ligne
ECHO  de commande par d‚faut est "echo @fattr @fdate @ftime @fsize@tab@fpath".
ECHO.
IF "%~1"=="" GOTO helpend
ECHO  Les variables suivantes peuvent ˆtre utilis‚es dans la chaŒne de commandesÿ:
ECHO  @fpath   - chemin d'accŠs complet du fichier
ECHO  @fshort  - chemin d'accŠs complet du fichier avec nom court 8.3
ECHO  @frelp   - chemin d'accŠs relatif du fichier
ECHO  @fname   - nom du fichier
ECHO  @fext    - extension du fichier
ECHO  @fattr   - attributs du fichier
ECHO  @fdate   - date de derniŠre modification du fichier
ECHO  @ftime   - derniŠre heure de modification du fichier
ECHO  @fsize   - taille du fichier
ECHO  @fbyte   - taille du fichier en octets
ECHO  @count   - compteur de fichier
ECHO  @tab     - tabulation
ECHO  @qot     - guillemet
ECHO.
ECHO  Exemples :
ECHO.
ECHO  SEARCH FILE /CMD "echo @fdate @ftime @fsize@tab@fname@fext"
ECHO  Affiche la liste de fichiers de maniŠre semblable … la commande DIR.
ECHO.
ECHO  SEARCH FILE /S /CMDONLY "echo @fpath"
ECHO  Equivalent … DIR /A /B /S.
ECHO.
ECHO  SEARCH FILE /CMDONLY "echo @fattr;@fdate;@ftime;@fsize;@fpath" ^> test.csv
ECHO  Exporte le contenu du r‚pertoire dans un document CSV lisible par Excel.
ECHO.
ECHO  SEARCH FILE /CMD "echo @fpath & ren @qot@fpath@qot test@count@fext"
ECHO  Renomme tous les ‚l‚ments du r‚pertoire courant avec le nom "testN".
ECHO.
ECHO  SEARCH FILE /DATE 12/12/2012 /CMD "echo @fpath & copy @qot@fpath@qot test"
ECHO  Copie les ‚l‚ments modifi‚s le 12 d‚cembre 2012 vers le r‚pertoire "test".
ECHO.
ECHO  SEARCH TEXT "Hello world" /M /CMD "echo @fpath & del @qot@fpath@qot"
ECHO  Efface tous les fichiers contenant la chaŒne "Hello world".
ECHO.
ECHO  SEARCH COMP test1 test2 /V /CMD "echo @fname"
ECHO  Recherche tous les noms de fichier pr‚sents … la fois dans le r‚pertoire
ECHO  "test1" et le r‚pertoire "test2".
ECHO.
ECHO  SEARCH COMP test1 test2 /NAME .bat /T:C /CMD "echo @fdate @ftime @frelp"
ECHO  Recherche les fichiers batch pr‚sents dans les r‚pertoires "test1" et "test2"
ECHO  dont les dates/heures de cr‚ation sont diff‚rentes.
EXIT /B 0
:helpend
ECHO Saisissez SEARCH HELP [FILE ^| TEXT ^| COMP ^| CMD] pour obtenir plus de d‚tails.
EXIT /B 0

:ERROR
IF "%~1%~2%~3"=="" ( ECHO Ligne de commande erron‚e : argument manquant. 1>&2
) ELSE ECHO Ligne de commande erron‚e : "%~1" 1>&2
EXIT /B 2

:EXIT
IF %N% EQU 0 ( EXIT /B 1
) ELSE EXIT /B 0