@ECHO OFF
REM Programme SEARCH version 6.0 par Baptiste Th�mine
SETLOCAL DISABLEDELAYEDEXPANSION

:: -------------------- PreProcess --------------------

REM Variable definitions
CALL :DEFINE_ESCAPE DIR "%CD%"
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
SET 0x21=!
SET ATTR=
SET CMDLINE=echo !FATTR! !FTIME! !FSIZE!	!FPATH!!FNAME!!FEXT!
SET COMPLINE=echo @fattr @fdate @ftime @fsize@tab@frelp
SET DATE1=01/01/1900
SET DATE2=%DATE%
SET DMY=
SET FILE1=
SET FILE2=
SET FIND=FINDSTR
SET FPARAM= 
SET FSPEC=[/C:,/C:]
SET HM=
SET NAME=*
SET NBCHAR=160
SET REPORT_DETAILS=true
SET SEARCH=%0
SET TEXT=
SET TIME1=00:00
SET TIME2=23:59
SET TMPFILE1="%TEMP%\searchtmpfile1.txt"
SET TMPFILE2="%TEMP%\searchtmpfile2.txt"
GOTO START

:: -------------------- Functions --------------------

:DEFINE_ESCAPE
REM Defines variable %1 with escaped sequence %2
SET "STR=%~2"
SET "STR=%STR:&=^&%"
SET "STR=%STR:|=^|%"
SET "STR=%STR:<=^<%"
SET "STR=%STR:>=^>%"
SET "%1=%STR%"
GOTO :EOF

:DEFINE_PARAM
REM Defines variable %1 with prefix %3 according to character filter %2
ECHO "%ARGS:~3%"| FINDSTR /I ".[^%2]." > nul
IF ERRORLEVEL 1 (
	SET "%1=%3%ARGS:~3%"
	EXIT /B 0
) ELSE EXIT /B 1

:DEFINE_COALESCE
REM Defines variable %1 with value %2 if not empty else %3
IF "%~2"=="" (
	SET "%1=%~3"
	EXIT /B 0
)
ECHO "%~2" | FINDSTR /B "./" > nul
IF NOT ERRORLEVEL 1 (
	SET "%1=%~3"
	EXIT /B 0
)
SET "%1=%~2"
EXIT /B 1

:SET_PATH
REM Sets variables DIR and NAME
IF "%~2"=="" GOTO PARAM
ECHO "%~2" | FINDSTR /B "./" > nul && GOTO PARAM
ECHO "%~2" | FINDSTR /R "\\ / : \<\.\> \<\.\.\>" > nul
IF ERRORLEVEL 1 GOTO SET_NAME
IF EXIST "%~2\*" GOTO SET_DIR
SHIFT
SET "DIR=%~dp1"
ECHO "%DIR%" | FINDSTR "| < >" > nul && GOTO ERROR
CALL :DEFINE_ESCAPE DIR "%DIR:"=%"
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
GOTO PARAM

:SET_DIR
IF "%~2"=="" GOTO PARAM
ECHO "%~2" | FINDSTR /B "./" > nul && GOTO PARAM
SHIFT
SET "DIR=%~f1"
ECHO "%DIR%" | FINDSTR "| < >" > nul && GOTO ERROR
CALL :DEFINE_ESCAPE DIR "%DIR:"=%"
GOTO PARAM

:SET_NAME
IF "%~2"=="" GOTO PARAM
ECHO "%~2" | FINDSTR /B "./" > nul && GOTO PARAM
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
ECHO "%NAME:"=%" | FIND "*" > nul && GOTO PARAM
SET "NAME= %NAME:"=% "
IF "%NAME:~1,1%"=="." SET "NAME=%NAME: .= *.%"
SET "NAME=%NAME: = *%"
SET "NAME=%NAME: =* %"
SET "NAME=%NAME:~1,-1%"
ECHO "%NAME%" | FIND "*" > nul || SET NAME="*%NAME: =*%*"
SET NAME=%NAME:="%
GOTO PARAM

:SET_DATE
CALL :DEFINE_COALESCE DMY "%~2" %DATE% || SHIFT
ECHO "%DMY%" | FINDSTR "\/? & | < > = ^" > nul && GOTO ERROR
ECHO %DMY:~0,10%| FINDSTR "[0-9][0-9][-./\\][0-9][0-9][-./\\][0-9][0-9][0-9][0-9]" > nul || GOTO ERROR
ECHO %DMY:~-10%| FINDSTR "[0-9][0-9][-./\\][0-9][0-9][-./\\][0-9][0-9][0-9][0-9]" > nul || GOTO ERROR
ECHO %DMY:~10,-10%| FINDSTR /R /C:"[-.,; ]" > nul || GOTO ERROR
SET DATE1=%DMY:~0,2%/%DMY:~3,2%/%DMY:~6,4%
SET DATE2=%DMY:~-10,2%/%DMY:~-7,2%/%DMY:~-4%
GOTO PARAM

:SET_TIME
CALL :DEFINE_COALESCE HM "%~2" %TIME:~0,5% || SHIFT
ECHO "%HM%" | FINDSTR "\/? & | < > = ^" > nul && GOTO ERROR
ECHO %HM:~0,5%| FINDSTR "[0-9][0-9][-.:][0-9][0-9]" > nul || GOTO ERROR
ECHO %HM:~-5%| FINDSTR "[0-9][0-9][-.:][0-9][0-9]" > nul || GOTO ERROR
ECHO %HM:~5,-5%| FINDSTR /R /C:"[-.,; ]" > nul || GOTO ERROR
SET TIME1=%HM:~0,2%:%HM:~3,2%
SET TIME2=%HM:~-5,2%:%HM:~-2%
GOTO PARAM

:SET_TEXT
SET "TEXT=%~1"
ECHO "%TEXT%" | FINDSTR /B "./" > nul && SET "TEXT=\%TEXT%"
GOTO SET_PATH

:SET_FILES
ECHO "%~1" | FINDSTR "* ?" > nul
IF ERRORLEVEL 1 ( SET "FILE1=%~f1"
) ELSE SET "FILE1=%~1"
ECHO "%FILE1%" | FINDSTR "| < >" > nul && GOTO ERROR
IF "%~2"=="" GOTO PARAM
SHIFT
ECHO "%~1" | FINDSTR "* ?" > nul
IF ERRORLEVEL 1 ( SET "FILE2=%~f1"
) ELSE SET "FILE2=%~1"
ECHO "%FILE2%" | FINDSTR "| < >" > nul && GOTO ERROR
GOTO PARAM

:SET_CMDLINE
IF /I "%ARGS:~4%"=="ONLY" ( SET REPORT_DETAILS=false
) ELSE IF NOT "%ARGS:~4%"=="" GOTO ERROR
IF "%~2"=="" GOTO PARAM
ECHO "%~2" | FINDSTR /B "./" > nul && GOTO PARAM
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
SET "CMDLINE=%CMDLINE:@fn8.3=!FN83!%"
SET "CMDLINE=%CMDLINE:@fattr=!FATTR!%"
SET "CMDLINE=%CMDLINE:@fdate=!FTIME:~0,10!%"
SET "CMDLINE=%CMDLINE:@ftime=!FTIME:~11,5!%"
SET "CMDLINE=%CMDLINE:@fsize=!FSIZE!%"
SET "CMDLINE=%CMDLINE:@fbyte=!FBYTE!%"
SET "CMDLINE=%CMDLINE:@count=!N!%"
SET "CMDLINE=%CMDLINE:@tab=	%"
CALL :DEFINE_ESCAPE CMDLINE "%CMDLINE%"
SET CMDLINE=%CMDLINE:@qot="%
GOTO PARAM

:DISPLAY_FILE
REM Displays file search result
SET FTIME=%~1
IF NOT "%FTIME:~2,1%"=="/" GOTO :EOF
SET "FSHORT=%~sf3"
SET "FNAME=%~n3"
SET "FEXT=%~x3"
SET "FN83=%~snx3"
SET "FATTR=%~a3"
SET "FBYTE=%~2"
REM Gets rounded file size else DIR/JUN/SYM
IF "%FBYTE:~0,1%"=="<" SET "FBYTE=%FBYTE:~1,3%"
IF "%FBYTE:~3,1%"=="" ( SET FSIZE=%FBYTE%
) ELSE IF "%FBYTE:~6,1%"=="" ( SET FSIZE=%FBYTE:~0,-3%k
) ELSE IF "%FBYTE:~9,1%"=="" ( SET FSIZE=%FBYTE:~0,-6%M
) ELSE SET FSIZE=%FBYTE:~0,-9%G
REM Filters files by date and time
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
REM Executes command line
SET /A N+=1
SETLOCAL ENABLEDELAYEDEXPANSION
SET "FRELPATH=!FPATH:%DIR%=!!!FNAME!!!!FEXT!!"
%CMDLINE%
ENDLOCAL
GOTO :EOF

:DISPLAY_TEXT
REM Displays text search result
REM Gets rounded file size else SYM
IF "%FATTR:~-1%"=="l" SET FBYTE=SYM
IF "%FBYTE:~3,1%"=="" ( SET FSIZE=%FBYTE%
) ELSE IF "%FBYTE:~6,1%"=="" ( SET FSIZE=%FBYTE:~0,-3%k
) ELSE IF "%FBYTE:~9,1%"=="" ( SET FSIZE=%FBYTE:~0,-6%M
) ELSE SET FSIZE=%FBYTE:~0,-9%G
REM Executes command line
SET /A N+=1
SETLOCAL ENABLEDELAYEDEXPANSION
SET "FRELPATH=!FPATH:%DIR%=!!!FNAME!!!!FEXT!!"
%CMDLINE%
ENDLOCAL
IF "%-C%"=="/C" GOTO count
IF "%-M%"=="/M" GOTO :EOF
:lines
REM Displays matching file lines without special chars
FOR /F "eol=- tokens=1-5 delims=" %%I IN ('%FIND% %-B% %-E% %-I% %-L% /N %-Q% %-R% %-X% %FSPEC:~5,3%"%TEXT%" "%FSHORT%"') DO (
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
REM Counts matching file lines
FOR /F %%I IN ('%FIND% %-B% %-E% %-I% %-L% /N %-Q% %-R% %-X% %FSPEC:~5,3%"%TEXT%" "%FSHORT%" ^| FIND /C /V ""') DO ECHO LINES = %%I
ECHO.
GOTO :EOF

:DELCR
REM Removes carriage return
SET "STR=%STR:"=%"
GOTO :EOF

:GET_DIFFLINES
REM Gets line numbers if there is a difference
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

:: -------------------- Main Process --------------------

:START
REM Reads first parameter
IF /I "%~1"=="FILE" (
	SET EXE=FILE
	GOTO SET_PATH
) ELSE IF /I "%~1"=="TEXT" (
	SET EXE=TEXT
	GOTO PARAM
) ELSE IF /I "%~1"=="COMP" (
	SET EXE=COMP
	GOTO PARAM
) ELSE IF /I "%~1"=="HELP" ( GOTO HELP
) ELSE GOTO FASTHELP

:PARAM
SHIFT
IF "%~1%~2%~3"=="" GOTO SEARCH_%EXE%
IF "%~1"=="" GOTO ERROR
SET "ARGS=%~1"
IF /I "%ARGS:~0,4%"=="/CMD" GOTO SET_CMDLINE
GOTO param_%EXE%
:param_file
REM Reads file search parameters
IF /I "%ARGS%"=="/DIR" ( GOTO SET_DIR
) ELSE IF /I "%ARGS%"=="/NAME" ( GOTO SET_NAME
) ELSE IF /I "%ARGS%"=="/DATE" ( GOTO SET_DATE
) ELSE IF /I "%ARGS%"=="/TIME" ( GOTO SET_TIME
) ELSE IF /I "%ARGS:~0,3%"=="/A:" ( CALL :DEFINE_PARAM ATTR ADHILRS- || GOTO ERROR
) ELSE IF /I "%ARGS%"=="/A" ( SET ATTR=
) ELSE IF /I "%ARGS:~0,3%"=="/O:" ( CALL :DEFINE_PARAM -O DEGNS- /O: || GOTO ERROR
) ELSE IF /I "%ARGS%"=="/O" ( SET -O= 
) ELSE IF /I "%ARGS%"=="/S" ( SET -S=/S
) ELSE IF /I "%ARGS:~0,3%"=="/T:" ( CALL :DEFINE_PARAM -T ACW /T: || GOTO ERROR
) ELSE IF /I "%ARGS%"=="/T" ( SET -T= 
) ELSE GOTO ERROR
GOTO PARAM
:param_text
REM Reads text search parameters
IF NOT DEFINED TEXT ( GOTO SET_TEXT
) ELSE IF /I "%ARGS%"=="/DIR" ( GOTO SET_DIR
) ELSE IF /I "%ARGS%"=="/NAME" ( GOTO SET_NAME
) ELSE IF /I "%ARGS%"=="/FIND" (
	SET FIND=FIND
	SET FPARAM=/FIND
	SET FSPEC=[/C:,   ]
	SET -L= 
) ELSE IF /I "%ARGS%"=="/FINDSTR" (
	SET FIND=FINDSTR
	SET FPARAM=/FINDSTR
	SET FSPEC=[   ,   ]
	SET -L= 
) ELSE IF /I "%ARGS%"=="/B" ( SET -B=/B
) ELSE IF /I "%ARGS%"=="/C" ( SET -C=/C
) ELSE IF /I "%ARGS%"=="/E" ( SET -E=/E
) ELSE IF /I "%ARGS%"=="/I" ( SET -I=/I
) ELSE IF /I "%ARGS%"=="/L" (
	SET -L=/L
	SET -R= 
) ELSE IF /I "%ARGS%"=="/M" ( SET -M=/M
) ELSE IF /I "%ARGS:~0,3%"=="/N:" ( CALL :DEFINE_PARAM NBCHAR 0-9 || GOTO ERROR
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
GOTO PARAM
:param_comp
REM Reads comp search parameters
IF NOT DEFINED FILE1 ( GOTO SET_FILES
) ELSE IF /I "%ARGS%"=="/NAME" (
	ECHO "%-A%%-B%%-I%%-R%" | FINDSTR "[A-Z]" > nul && GOTO ERROR
	GOTO SET_NAME
) ELSE IF /I "%ARGS%"=="/DATE" (
	ECHO "%-A%%-B%%-I%%-R%" | FINDSTR "[A-Z]" > nul && GOTO ERROR
	GOTO SET_DATE
) ELSE IF /I "%ARGS%"=="/TIME" (
	ECHO "%-A%%-B%%-I%%-R%" | FINDSTR "[A-Z]" > nul && GOTO ERROR
	GOTO SET_TIME
) ELSE IF /I "%ARGS:~0,3%"=="/A:" ( CALL :DEFINE_PARAM ATTR ADHILRS- /A: || GOTO ERROR
) ELSE IF /I "%ARGS%"=="/A" ( SET -A=/A
) ELSE IF /I "%ARGS%"=="/B" (
	SET -B=/B
	SET -R= 
) ELSE IF /I "%ARGS%"=="/I" ( SET -I=/C
) ELSE IF /I "%ARGS%"=="/R" (
	SET -B= 
	SET -R=/R
) ELSE IF /I "%ARGS%"=="/S" ( SET -S=/S
) ELSE IF /I "%ARGS:~0,3%"=="/T:" ( CALL :DEFINE_PARAM -T ACW /T: || GOTO ERROR
) ELSE IF /I "%ARGS%"=="/T" ( SET -T= 
) ELSE IF /I "%ARGS%"=="/V" ( SET -V=/V
) ELSE GOTO ERROR
ECHO "%-A%%-B%%-I%%-R%" | FINDSTR "[A-Z]" > nul && ECHO "%ATTR%%-S%%-T%%-V%" | FINDSTR "[A-Z]" > nul && GOTO ERROR
GOTO PARAM

:SEARCH_FILE
REM Searches directories/files according to the specified filters
IF %REPORT_DETAILS%==false GOTO next1
ECHO.
ECHO ----------------------------- RAPPORT DE RECHERCHE -----------------------------
ECHO.
ECHO G�n�r� le : %DATE% %TIME:~0,5%
ECHO R�pertoire de recherche : %DIR%
ECHO Masque de recherche : %NAME%
ECHO Attributs : %ATTR%
ECHO Plage de dates : %DATE1% - %DATE2%
ECHO Plage horaire : %TIME1% - %TIME2%
ECHO Param�tres : %-O% %-S% %-T%
ECHO.
ECHO R�sultat de la recherche :
:next1
SET /A N=0
IF NOT "%DIR:~-1%"=="\" SET "DIR=%DIR%\"
PUSHD %DIR%
REM Gets file list from DIR command
IF NOT ERRORLEVEL 1 FOR /F "tokens=1-3*" %%I IN ('DIR /A:%ATTR% /-C %-O% %-S% %-T% %NAME%') DO (
	REM Removes junction/symlink paths from output
	FOR /F "tokens=1,2,3 delims=:" %%M IN ("%%L") DO (
		SET FNAME=%%M
		IF NOT "%%N"=="" CALL SET FNAME=%%FNAME:~0,-3%%
	)
	REM Concats parent directory name to file path
	IF "%%I"=="R�pertoire" (
		IF "%%K"=="%%~dK\" ( SET FPATH=%%K
		) ELSE IF "%%L"=="" ( SET FPATH=%%K\
		) ELSE SET FPATH=%%K %%L\
	) ELSE IF NOT "%%L"=="." IF NOT "%%L"==".." CALL :DISPLAY_FILE "%%I %%J" "%%K" "%%FPATH:'=?%%%%FNAME:'=?%%"
)
POPD
IF %REPORT_DETAILS%==false GOTO EXIT
ECHO.
ECHO %N% fichier(s)/r�pertoire(s) trouv�(s)
GOTO EXIT

:SEARCH_TEXT
REM Searches files matching the specified text and filters
IF NOT DEFINED TEXT GOTO ERROR
IF %REPORT_DETAILS%==false GOTO next2
ECHO.
ECHO ----------------------------- RAPPORT DE RECHERCHE -----------------------------
ECHO.
ECHO G�n�r� le : %DATE% %TIME:~0,5%
ECHO R�pertoire de recherche : %DIR%
ECHO Masque de recherche : %NAME%
ECHO Texte recherch� : "%TEXT%"
ECHO Param�tres : %FPARAM% %-B% %-C% %-E% %-I% %-L% %-M% /N:%NBCHAR% %-P% %-Q:/P=/Q% %-R% %-S% %-X%
ECHO.
ECHO R�sultat de la recherche :
:next2
SET /A N=0
IF NOT "%DIR:~-1%"=="\" SET "DIR=%DIR%\"
PUSHD %DIR%
REM Gets file list from FINDSTR command
IF NOT ERRORLEVEL 1 FOR /F "delims=" %%I IN ('FINDSTR %-B% %-E% %-I% %-L% /M %-P% %-R% %-S% %-X% %FSPEC:~1,3%"%TEXT%" %NAME%') DO (
	SET FPATH=%%~dpI
	SET FSHORT=%%~sfI
	SET FNAME=%%~nI
	SET FEXT=%%~xI
	SET FN83=%%~snxI
	SET FATTR=%%~aI
	SET FTIME=%%~tI
	SET FBYTE=%%~zI
	CALL :DISPLAY_TEXT
)
POPD
IF %REPORT_DETAILS%==false GOTO EXIT
IF "%-M%"=="/M" ( IF NOT "%-C%"=="/C" ECHO.
) ELSE IF %N% EQU 0 ECHO.
ECHO %N% fichier(s) trouv�(s)
GOTO EXIT

:SEARCH_COMP
REM Compares two directories/files according to the specified filters
IF NOT DEFINED FILE1 GOTO ERROR
IF NOT DEFINED FILE2 GOTO ERROR
CALL :DEFINE_ESCAPE SFILE1 "%FILE1%"
CALL :DEFINE_ESCAPE SFILE2 "%FILE2%"
SET COMP_TYPE=FILE
IF EXIST "%FILE1%\*" IF EXIST "%FILE2%\*" SET COMP_TYPE=DIR
IF %REPORT_DETAILS%==false GOTO next3
ECHO.
ECHO ----------------------------- RAPPORT DE RECHERCHE -----------------------------
ECHO.
ECHO G�n�r� le : %DATE% %TIME:~0,5%
ECHO Fichier 1 : %SFILE1%
ECHO Fichier 2 : %SFILE2%
IF %COMP_TYPE%==FILE ECHO Param�tres : %-A% %-B% %-I:/C=/I% %-R%
IF %COMP_TYPE%==DIR ECHO Param�tres : /NAME %NAME% /DATE %DATE1%-%DATE2% /TIME %TIME1%-%TIME2% %ATTR% %-S% %-T% %-V%
ECHO.
ECHO R�sultat de la recherche :
:next3
GOTO COMPARE_%COMP_TYPE%%-B:~1%%-R:~1%

:COMPARE_DIR
REM Searches differences between two directories
ECHO Comparaison des r�pertoires %SFILE1% et %SFILE2%
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
IF %REPORT_DETAILS%==false GOTO EXIT
ECHO.
ECHO %N% fichier(s)/r�pertoire(s) trouv�(s)
GOTO EXIT

:COMPARE_DIRV
REM Searches similarities between two directories
ECHO Comparaison des r�pertoires %SFILE1% et %SFILE2%
CALL %SEARCH% FILE /DIR "%%FILE1%%" /NAME %%NAME%% /DATE %DATE1%-%DATE2% /TIME %TIME1%-%TIME2% %ATTR% /O:N %-S% %-T% /CMDONLY "%COMPLINE%" /SLASH > %TMPFILE1%
CALL %SEARCH% FILE /DIR "%%FILE2%%" /NAME %%NAME%% /DATE %DATE1%-%DATE2% /TIME %TIME1%-%TIME2% %ATTR% /O:N %-S% %-T% /CMDONLY "%COMPLINE%" /SLASH > %TMPFILE2%
SET /A N=0
FOR /F "delims=" %%I IN ('FINDSTR /L /X /G:%TMPFILE1% %TMPFILE2%') DO (
	ECHO %%I
	SET /A N+=1
)
DEL %TMPFILE1% %TMPFILE2%
IF %REPORT_DETAILS%==false GOTO EXIT
ECHO.
ECHO %N% fichier(s)/r�pertoire(s) trouv�(s)
GOTO EXIT

:COMPARE_FILE
REM Searches differences between two files
SET /A N=0
FOR /F "tokens=1-5 delims=" %%I IN ('FC %-A% %-I% /L /N "%FILE1%" "%FILE2%" 2^>^&1') DO (
	ECHO %%I%%J%%K%%L%%M
	IF "%%~I"=="*****" (
		ECHO --------------------------------------------------------------------------------
		SET /A N+=1
	)
)
IF %REPORT_DETAILS%==false GOTO EXIT
ECHO.
ECHO %N% diff�rence(s) trouv�(s)
GOTO EXIT

:COMPARE_FILEB
REM Performs a binary comparison between two files
SET /A N=0
FOR /F "tokens=1*" %%I IN ('FC /B "%FILE1%" "%FILE2%" 2^>^&1') DO (
	ECHO %%I %%J
	IF NOT "%%~I"=="Comparaison" IF NOT "%%~I"=="FC�:" SET /A N+=1
)
IF %REPORT_DETAILS%==false GOTO EXIT
ECHO.
ECHO %N% diff�rence(s) trouv�(s)
GOTO EXIT

:COMPARE_FILER
REM Searches ranges of set of differences between two files
SET STR=
SET /A N=0, MIN=0, MAX=0
FOR /F "tokens=1*" %%I IN ('FC /A %-I% /L /N "%FILE1%" "%FILE2%" 2^>^&1') DO (
	IF "%%~I"=="Comparaison" ( ECHO %%I %%J
	) ELSE IF "%%~I"=="FC�:" ( ECHO %%I %%J
	) ELSE IF "%%~I"=="�chec" ECHO %%I %%J
	CALL :GET_DIFFLINES "%%~I"
	IF "%%~I%%~J"=="*****" SET /A N+=1
)
IF %REPORT_DETAILS%==false GOTO EXIT
ECHO.
ECHO %N% diff�rence(s) trouv�(s)
GOTO EXIT

:: -------------------- Help --------------------

:FASTHELP
ECHO La syntaxe de cette commande est :
ECHO.
ECHO SEARCH HELP					Afficher l'aide
ECHO SEARCH FILE [fichiers...] [options]		Recherche de fichier
ECHO SEARCH TEXT "cha�ne" [fichiers...] [options]	Recherche de texte
ECHO SEARCH COMP fichier1 fichier2 [options]		Comparaison de fichiers
ECHO SEARCH ... [/CMD[ONLY] "cmdline"]		Option ligne de commande
EXIT /B 2

:HELP
SHIFT
IF NOT "%~2"=="" SHIFT & GOTO ERROR
IF NOT "%~1"=="" ECHO "%~1" | FINDSTR /I "FILE TEXT COMP CMD" > nul || GOTO ERROR
ECHO Programme SEARCH version 6.0 par Baptiste Th�mine
ECHO.
IF /I "%~1"=="" GOTO HELP_FILE
IF /I "%~1"=="FILE" GOTO HELP_FILE
IF /I "%~1"=="TEXT" GOTO HELP_TEXT
IF /I "%~1"=="COMP" GOTO HELP_COMP
IF /I "%~1"=="CMD" GOTO HELP_CMD
GOTO ERROR

:HELP_FILE
ECHO SEARCH FILE [r�pertoire ^| fichiers...] [options]
ECHO.
ECHO  Options : [/DIR r�pertoire] [/NAME fichiers...] [/DATE [date]] [/TIME [heure]]
ECHO            [/A[:attribut]] [/O[:tri]] [/S] [/T[:tf]]
ECHO.
ECHO  La recherche de fichier permet de filtrer les fichiers d'un r�pertoire selon :
ECHO  - un masque de recherche c�d un ou plusieurs titres et/ou extensions de
ECHO    fichier (caract�res g�n�riques "*" et "?" autoris�s). Par exemple,
ECHO    /NAME un titre		recherche les fichiers contenant "*un*titre*"
ECHO    /NAME "titre1" "titre2"	recherche les fichiers "*titre1*" ou "*titre2*"
ECHO    /NAME .txt .bat		recherche les fichiers textes et batch
ECHO  - un attribut	D  R�pertoire		R  Lecture seule
ECHO 		H  Cach�		A  Archive
ECHO 		S  Syst�me		I  Fichiers index�s sans contenu
ECHO 		L  Points d'analyse	-  Pr�fixe de n�gation
ECHO  - une date [jj/mm/aaaa] ou une plage de dates [jj/mm/aaaa - jj/mm/aaaa].
ECHO  - une heure [hh:mm] ou une plage horaire [hh:mm - hh:mm].
ECHO  Remarque : /DATE et /TIME sp�cifi�s seuls valent la date et l'heure actuelle.
ECHO.
IF "%~1"=="" GOTO HELP_TEXT
ECHO  /O:tri	Affiche les fichiers selon un tri sp�cifi�.
ECHO 	N  Nom (alphab�tique)		S  Taille (ordre croissant)
ECHO 	E  Extension (alphab�tique)	D  Date et heure (chronologique)
ECHO 	G  R�pertoires en t�te		-  Pr�fixe en ordre indirect
ECHO  /S	Recherche les fichiers correspondants dans le r�pertoire et dans tous
ECHO 	ses sous-r�pertoires.
ECHO  /T:tf	Contr�le le champ d'heure affich� et utilis� dans le tri.
ECHO 	C  Cr�ation		A  Dernier acc�s	W  Derni�re �criture
ECHO.
ECHO  Exemples :
ECHO.
ECHO  SEARCH FILE /S
ECHO  Affiche tous les fichiers pr�sents dans le r�pertoire en cours et tous ses
ECHO  sous-r�pertoires.
ECHO.
ECHO  SEARCH FILE %%TEMP%%
ECHO  Affiche tous les �l�ments pr�sents dans le dossier temporaire de Windows.
ECHO.
ECHO  SEARCH FILE "test" "un fichier" .txt
ECHO  Recherche les fichiers textes et les fichers dont le titre contient les
ECHO  cha�nes "test" ou "un fichier".
ECHO.
ECHO  SEARCH FILE /A:HS
ECHO  Affiche tous les fichiers cach�s syst�mes du r�pertoire en cours.
ECHO.
ECHO  SEARCH FILE /DIR C:\Windows\system32 /NAME %%PATHEXT%% /O:-N
ECHO  Affiche toutes les commandes de CMD.exe dans l'ordre alphab�tique d�croissant.
ECHO.
ECHO  SEARCH FILE /DATE /TIME 8:00-18:00
ECHO  Recherche tous les �l�ments modifi�s aujourd'hui entre 8 et 18 heures.
ECHO.
ECHO  SEARCH FILE /DATE 12/12/2012-%%DATE%% /T:C
ECHO  Recherche tous les �l�ments cr��s depuis le 12 d�cembre 2012 � aujourd'hui.
EXIT /B 0

:HELP_TEXT
ECHO SEARCH TEXT "cha�ne" [r�pertoire ^| fichiers...] [options]
ECHO.
ECHO  Options : [/DIR r�pertoire] [/NAME fichiers...] [/FIND[STR]] [/B] [/C] [/E]
ECHO            [/I] [/L ^| /R] [/M] [/N[:nnn]] [/P] [/Q] [/S] [/X]
ECHO.
ECHO  La recherche de texte permet de rechercher une cha�ne dans les fichiers d'un
ECHO  r�pertoire et d'afficher les lignes correspondantes dans le rapport.
ECHO.
IF "%~1"=="" GOTO HELP_COMP
ECHO  /FIND	Sp�cifie que la recherche s'effectue avec la commande FIND. Ne peut pas
ECHO 	�tre utilis�e avec les commutateurs B, E, L, Q, R ou X.
ECHO  /FINDSTR	Sp�cifie que la recherche s'effectue avec la commande FINDSTR.
ECHO  	Cette derni�re a un comportement diff�rent : si plusieurs mots s�par�s
ECHO 	par un espace sont sp�cifi�s, la recherche s'effectue mot par mot.
ECHO  /B	Recherche l'�l�ment s'il est en d�but de ligne.
ECHO  /C	Compte le nombre de lignes contenant la cha�ne.
ECHO  /E	Recherche l'�l�ment s'il est en fin de ligne.
ECHO  /I	Sp�cifie que la recherche ne doit pas tenir compte de la casse.
ECHO  /L	Recherche la cha�ne sp�cifi�e litt�ralement (par d�faut).
ECHO  /M	Ne pas afficher les lignes correspondantes.
ECHO  /N:nnn	Sp�cifie le nombre maximal de caract�res � afficher pour chaque ligne
ECHO 	correspondante. Sans nombre sp�cifi�, N = 160 caract�res.
ECHO  /P	Ignore les fichiers contenant des caract�res non affichables.
ECHO  /Q	Ignore les lignes correspondantes avec caract�res non affichables.
ECHO  /R	Recherche la cha�ne sp�cifi�e en tant qu'expression r�guli�re. Pour
ECHO 	plus de d�tails, consultez l'aide de la commande FINDSTR.
ECHO  /S	Recherche les fichiers correspondants dans le r�pertoire et dans tous
ECHO 	ses sous-r�pertoires.
ECHO  /X	Recherche les lignes correspondant parfaitement.
ECHO.
ECHO  Exemples :
ECHO.
ECHO  SEARCH TEXT "Hello world"
ECHO  Recherche tous les fichiers contenant la cha�ne "Hello world" et affiche les
ECHO  lignes correspondantes.
ECHO.
ECHO  SEARCH TEXT "Hello world" /DIR "test" /NAME .txt /M /X
ECHO  Recherche les fichiers textes dans le r�pertoire "test" qui contiennent au
ECHO  moins une ligne "Hello world" mais ne les affiche pas.
ECHO.
ECHO  SEARCH TEXT "Hello world" .txt .bat /FINDSTR /B /I /L
ECHO  Recherche les fichiers textes et batch contenant les cha�nes "Hello" ou
ECHO  "world" en d�but de ligne et sans tenir compte de la casse.
ECHO.
ECHO  SEARCH TEXT "^[0-9][0-9]*$" /C /P /R
ECHO  Recherche dans les fichiers lisibles les lignes qui ne contiennent que des
ECHO  chiffres et affiche le r�sultat avec le nombre de lignes correspondantes.
ECHO.
ECHO  SEARCH TEXT .* /C /M /R
ECHO  Affiche le nombre total de lignes contenus dans chaque fichier.
ECHO.
ECHO  SEARCH TEXT . /C /M /R
ECHO  Affiche le nombre total de lignes non vides contenus dans chaque fichier.
EXIT /B 0

:HELP_COMP
ECHO SEARCH COMP fichier1 fichier2 [options]
ECHO             r�pertoire1 r�pertoire2 [options]
ECHO.
ECHO  Options : fichiers     [/A] [/B ^| /R] [/I]
ECHO            r�pertoires  [/NAME fichiers...] [/DATE [date]] [/TIME [heure]]
ECHO                         [/A[:attribut]] [/S] [/T[:tf]] [/V]
ECHO.
ECHO  La comparaison de fichiers permet de rechercher les diff�rences entre deux
ECHO  fichiers sp�cifi�s et de les afficher dans le rapport. La comparaison peut
ECHO  �galement s'effectuer sur deux r�pertoires auquel cas la commande va comparer
ECHO  le contenu des r�pertoires et afficher les diff�rences selon le nom, la taille
ECHO  et la date/heure de derni�re modification de chaque fichier (ces crit�res
ECHO  peuvent �tre modifi�s avec /CMD).
ECHO.
IF "%~1"=="" GOTO HELP_CMD
ECHO  /A	Affiche la 1�re et derni�re ligne de chaque ensemble de diff�rences.
ECHO  /B	Effectue une comparaison binaire.
ECHO  /I	Sp�cifie que la recherche ne doit pas tenir compte de la casse.
ECHO  /R	Affiche uniquement l'intervalle de chaque ensemble de diff�rences.
ECHO.
ECHO  /A:att	Compare les fichiers dot�s des attributs sp�cifi�s.
ECHO  /S	Compare le contenu des deux r�pertoires sp�cifi�s et de tous leurs
ECHO 	sous-r�pertoires.
ECHO  /T:tf	Contr�le le champ d'heure affich� et utilis� dans la comparaison.
ECHO 	C  Cr�ation		A  Dernier acc�s	W  Derni�re �criture
ECHO  /V	Recherche les ressemblances au lieu des diff�rences pour la comparaison
ECHO 	de deux r�pertoires.
ECHO.
ECHO  Exemples :
ECHO.
ECHO  SEARCH COMP test1.txt test2.txt /I
ECHO  Compare le contenu ASCII des fichiers "test1.txt" et "test2.txt" sans tenir
ECHO  compte de la casse.
ECHO.
ECHO  SEARCH COMP *.bat test.bat /A
ECHO  Compare le fichier test.bat avec tous les fichiers batch du r�pertoire courant
ECHO  en affichant le r�sultat abr�g�.
ECHO.
ECHO  SEARCH COMP test1\*.txt test2\*txt
ECHO  Compare le contenu ASCII des fichiers textes deux � deux dans les r�pertoires
ECHO  "test1" et "test2". Les fichiers compar�s doivent porter le m�me nom dans les
ECHO  deux r�pertoires.
ECHO.
ECHO  SEARCH COMP test1 test2 /A:-D /S
ECHO  Recherche toutes les diff�rences de fichiers entre les r�pertoires "test1" et
ECHO  "test2" et tous leurs sous-r�pertoires.
ECHO.
ECHO  SEARCH COMP test1 test2 /V /CMD "echo @fname"
ECHO  Recherche tous les fichiers homonymes des r�pertoires "test1" et "test2".
ECHO.
ECHO  SEARCH COMP test1 test2 /NAME .bat /T:C /CMD "echo @fdate @ftime @frelp"
ECHO  Recherche les fichiers batch pr�sents dans les r�pertoires "test1" et "test2"
ECHO  dont les dates/heures de cr�ation sont diff�rentes.
EXIT /B 0

:HELP_CMD
ECHO Guide de l'option ligne de commande
ECHO.
ECHO  Utilisation : SEARCH [FILE ^| TEXT ^| COMP] [/CMD[ONLY] "cmdline"]
ECHO.
ECHO  /CMD permet de rediriger le r�sultat de la recherche vers une commande
ECHO  sp�cifi�e. "cmdline" indique la ligne de commande � ex�cuter pour chaque
ECHO  fichier trouv� par la recherche de fichier ou de texte et permet �galement de
ECHO  d�finir les crit�res de comparaison de deux r�pertoires. Si /CMDONLY est
ECHO  sp�cifi�, l'affichage d�taill� du rapport de recherche est d�sactiv�. La ligne
ECHO  de commande par d�faut est "echo @fattr @fdate @ftime @fsize@tab@fpath".
ECHO.
IF "%~1"=="" GOTO HELP_EXIT
ECHO  Les variables suivantes peuvent �tre utilis�es dans la cha�ne de commandes :
ECHO  @fpath   - chemin d'acc�s complet du fichier
ECHO  @fshort  - chemin d'acc�s complet du fichier avec nom court 8.3
ECHO  @frelp   - chemin d'acc�s relatif du fichier
ECHO  @fname   - nom du fichier
ECHO  @fext    - extension du fichier
ECHO  @fn8.3   - nom court 8.3 du fichier
ECHO  @fattr   - attributs du fichier
ECHO  @fdate   - date de derni�re modification du fichier
ECHO  @ftime   - derni�re heure de modification du fichier
ECHO  @fsize   - taille du fichier
ECHO  @fbyte   - taille du fichier en octets
ECHO  @count   - compteur de fichier
ECHO  @tab     - tabulation
ECHO  @qot     - guillemet
ECHO.
ECHO  Exemples :
ECHO.
ECHO  SEARCH FILE /CMD "echo @fdate @ftime @fsize@tab@fname@fext"
ECHO  Affiche la liste de fichiers de mani�re semblable � la commande DIR.
ECHO.
ECHO  SEARCH FILE /S /CMDONLY "echo @fpath"
ECHO  Equivalent � DIR /A /B /S.
ECHO.
ECHO  SEARCH FILE /CMDONLY "echo @fattr;@fdate;@ftime;@fsize;@fpath" ^> test.csv
ECHO  Exporte le contenu du r�pertoire dans un document CSV lisible par Excel.
ECHO.
ECHO  SEARCH FILE /CMD "echo @fpath & ren @qot@fpath@qot test@count@fext"
ECHO  Renomme tous les �l�ments du r�pertoire courant avec le nom "testN".
ECHO.
ECHO  SEARCH FILE /DATE 12/12/2012 /CMD "echo @fpath & copy @qot@fpath@qot test"
ECHO  Copie les �l�ments modifi�s le 12 d�cembre 2012 vers le r�pertoire "test".
ECHO.
ECHO  SEARCH TEXT "Hello world" /M /CMD "echo @fpath & del @qot@fpath@qot"
ECHO  Supprime tous les fichiers contenant la cha�ne "Hello world".
ECHO.
ECHO  SEARCH COMP test1 test2 /V /CMD "echo @fname"
ECHO  Recherche tous les fichiers homonymes des r�pertoires "test1" et "test2".
ECHO.
ECHO  SEARCH COMP test1 test2 /NAME .bat /T:C /CMD "echo @fdate @ftime @frelp"
ECHO  Recherche les fichiers batch pr�sents dans les r�pertoires "test1" et "test2"
ECHO  dont les dates/heures de cr�ation sont diff�rentes.
EXIT /B 0

:HELP_EXIT
ECHO Saisissez SEARCH HELP [FILE ^| TEXT ^| COMP ^| CMD] pour obtenir plus de d�tails.
EXIT /B 0

:: -------------------- PostProcess --------------------

:ERROR
IF "%~1%~2%~3"=="" ( ECHO Ligne de commande erron�e : argument manquant. 1>&2
) ELSE ECHO Ligne de commande erron�e : "%~1". 1>&2
EXIT /B 2

:EXIT
IF %N% EQU 0 ( EXIT /B 1
) ELSE EXIT /B 0
