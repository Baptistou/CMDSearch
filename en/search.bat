@ECHO OFF
REM Program SEARCH version 6.0 by Baptiste Th‚mine
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
ECHO -------------------------------- SEARCH REPORT --------------------------------
ECHO.
ECHO Generated on : %DATE% %TIME:~0,5%
ECHO Search path : %DIR%
ECHO Search mask : %NAME%
ECHO Attributes : %ATTR%
ECHO Date range : %DATE1% - %DATE2%
ECHO Time range : %TIME1% - %TIME2%
ECHO Parameters : %-O% %-S% %-T%
ECHO.
ECHO Search result :
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
	IF "%%I"=="Directory" (
		IF "%%K"=="%%~dK\" ( SET FPATH=%%K
		) ELSE IF "%%L"=="" ( SET FPATH=%%K\
		) ELSE SET FPATH=%%K %%L\
	) ELSE IF NOT "%%L"=="." IF NOT "%%L"==".." CALL :DISPLAY_FILE "%%I %%J" "%%K" "%%FPATH:'=?%%%%FNAME:'=?%%"
)
POPD
IF %REPORT_DETAILS%==false GOTO EXIT
ECHO.
ECHO %N% files(s)/directories(s) found
GOTO EXIT

:SEARCH_TEXT
REM Searches files matching the specified text and filters
IF NOT DEFINED TEXT GOTO ERROR
IF %REPORT_DETAILS%==false GOTO next2
ECHO.
ECHO -------------------------------- SEARCH REPORT --------------------------------
ECHO.
ECHO Generated on : %DATE% %TIME:~0,5%
ECHO Search path : %DIR%
ECHO Search mask : %NAME%
ECHO Text to find : "%TEXT%"
ECHO Parameters : %FPARAM% %-B% %-C% %-E% %-I% %-L% %-M% /N:%NBCHAR% %-P% %-Q:/P=/Q% %-R% %-S% %-X%
ECHO.
ECHO Search result :
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
ECHO %N% files(s)/directories(s) found
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
ECHO -------------------------------- SEARCH REPORT --------------------------------
ECHO.
ECHO Generated on : %DATE% %TIME:~0,5%
ECHO File 1 : %SFILE1%
ECHO File 2 : %SFILE2%
IF %COMP_TYPE%==FILE ECHO Parameters : %-A% %-B% %-I:/C=/I% %-R%
IF %COMP_TYPE%==DIR ECHO Parameters : /NAME %NAME% /DATE %DATE1%-%DATE2% /TIME %TIME1%-%TIME2% %ATTR% %-S% %-T% %-V%
ECHO.
ECHO Search result :
:next3
GOTO COMPARE_%COMP_TYPE%%-B:~1%%-R:~1%

:COMPARE_DIR
REM Searches differences between two directories
ECHO Comparing directories %SFILE1% and %SFILE2%
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
ECHO %N% files(s)/directories(s) found
GOTO EXIT

:COMPARE_DIRV
REM Searches similarities between two directories
ECHO Comparing directories %SFILE1% and %SFILE2%
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
ECHO %N% files(s)/directories(s) found
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
ECHO %N% difference(s) found
GOTO EXIT

:COMPARE_FILEB
REM Performs a binary comparison between two files
SET /A N=0
FOR /F "tokens=1*" %%I IN ('FC /B "%FILE1%" "%FILE2%" 2^>^&1') DO (
	ECHO %%I %%J
	IF NOT "%%~I"=="Comparing" IF NOT "%%~I"=="FC:" SET /A N+=1
)
IF %REPORT_DETAILS%==false GOTO EXIT
ECHO.
ECHO %N% difference(s) found
GOTO EXIT

:COMPARE_FILER
REM Searches ranges of set of differences between two files
SET STR=
SET /A N=0, MIN=0, MAX=0
FOR /F "tokens=1*" %%I IN ('FC /A %-I% /L /N "%FILE1%" "%FILE2%" 2^>^&1') DO (
	IF "%%~I"=="Comparing" ( ECHO %%I %%J
	) ELSE IF "%%~I"=="FC:" ( ECHO %%I %%J
	) ELSE IF "%%~I"=="Resync" ECHO %%I %%J
	CALL :GET_DIFFLINES "%%~I"
	IF "%%~I%%~J"=="*****" SET /A N+=1
)
IF %REPORT_DETAILS%==false GOTO EXIT
ECHO.
ECHO %N% difference(s) found
GOTO EXIT

:: -------------------- Help --------------------

:FASTHELP
ECHO The syntax of this command is :
ECHO.
ECHO SEARCH HELP					Display help
ECHO SEARCH FILE [files...] [options]		File search
ECHO SEARCH TEXT "string" [files...] [options]	Text search
ECHO SEARCH COMP file1 file2 [options]		File comparison
ECHO SEARCH ... [/CMD[ONLY] "cmdline"]		Command line option
EXIT /B 2

:HELP
SHIFT
IF NOT "%~2"=="" SHIFT & GOTO ERROR
IF NOT "%~1"=="" ECHO "%~1" | FINDSTR /I "FILE TEXT COMP CMD" > nul || GOTO ERROR
ECHO Program SEARCH version 6.0 by Baptiste Th‚mine
ECHO.
IF /I "%~1"=="" GOTO HELP_FILE
IF /I "%~1"=="FILE" GOTO HELP_FILE
IF /I "%~1"=="TEXT" GOTO HELP_TEXT
IF /I "%~1"=="COMP" GOTO HELP_COMP
IF /I "%~1"=="CMD" GOTO HELP_CMD
GOTO ERROR

:HELP_FILE
ECHO SEARCH FILE [directory ^| files...] [options]
ECHO.
ECHO  Options : [/DIR directory] [/NAME files...] [/DATE [date]] [/TIME [time]]
ECHO            [/A[:attribute]] [/O[:ord]] [/S] [/T[:tf]]
ECHO.
ECHO  File search filters and displays a list of files in a directory according to :
ECHO  - a search mask i.e. one or multiple file titles and/or file extensions
ECHO    (wildcards "*" and "?" can be used). For example,
ECHO    /NAME a title		search files matching "*a*title*"
ECHO    /NAME "title1" "title2"	search files matching "*title1*" or "*title2*"
ECHO    /NAME .txt .bat		search text files and batch files
ECHO  - an attribute	D  Directories		R  Read-only files
ECHO 		H  Hidden files		A  Files ready for archiving
ECHO 		S  System files		I  Not content indexed files
ECHO 		L  Reparse Points	-  Prefix meaning not
ECHO  - a date [dd/mm/yyyy] or a date range [dd/mm/yyyy - dd/mm/yyyy].
ECHO  - a time [hh:mm] or a time range [hh:mm - hh:mm].
ECHO  Note : /DATE and /TIME specified alone match for current date and time.
ECHO.
IF "%~1"=="" GOTO HELP_TEXT
ECHO  /O:ord	List by files in sorted order.
ECHO 	N  By name (alphabetic)		S  By size (smallest first)
ECHO 	E  By extension (alphabetic)	D  By date/time (oldest first)
ECHO 	G  Group directories first	-  Prefix to reverse order
ECHO  /S	Searches for matching files in the current directory and all
ECHO 	subdirectories.
ECHO  /T:tf	Controls which time field displayed or used for sorting
ECHO 	C  Creation		A  Last Access		W  Last Written
ECHO.
ECHO  Examples :
ECHO.
ECHO  SEARCH FILE /S
ECHO  Displays all files inside the current directory and all subdirectories.
ECHO.
ECHO  SEARCH FILE %%TEMP%%
ECHO  Displays all elements inside the Window temporary directory.
ECHO.
ECHO  SEARCH FILE "test" "a file name" .txt
ECHO  Searches for text files and files with a name containing the strings "test" or
ECHO  "a file name".
ECHO.
ECHO  SEARCH FILE /A:HS
ECHO  Displays the hidden system files inside the current directory.
ECHO.
ECHO  SEARCH FILE /DIR C:\Windows\system32 /NAME .exe /O:S
ECHO  Displays the list of CMD.exe commands in sorted order by size.
ECHO.
ECHO  SEARCH FILE /DATE /TIME 8:00-18:00
ECHO  Searches for all elements modified today between 8:00 am and 6:00 pm.
ECHO.
ECHO  SEARCH FILE /DATE 12/12/2012-%%DATE%% /T:C
ECHO  Searches for all elements created between the 12th of december 2012 and today.
EXIT /B 0

:HELP_TEXT
ECHO SEARCH TEXT "string" [directory ^| files...] [options]
ECHO.
ECHO  Options : [/DIR directory] [/NAME files...] [/FIND[STR]] [/B] [/C] [/E] [/I]
ECHO            [/L ^| /R] [/M] [/N[:nnn]] [/P] [/Q] [/S] [/X]
ECHO.
ECHO  Text search searches for a text string in a list of files in a directory and
ECHO  displays matching lines in the report.
ECHO.
IF "%~1"=="" GOTO HELP_COMP
ECHO  /FIND	Specifies that text search will execute FIND command. It can't be used
ECHO 	with B, E, L, Q, R or X specifiers.
ECHO  /FINDSTR	Specifies that text search will execute FINDSTR command.
ECHO  	The behavior of this command is different : if multiple space-separated
ECHO 	words are specified, the search is performed word by word.
ECHO  /B	Matches pattern if at the beginning of a line.
ECHO  /C	Displays the count of lines containing the string.
ECHO  /E	Matches pattern if at the end of a line.
ECHO  /I	Specifies that the search is not to be case-sensitive.
ECHO  /L	Uses search string literally (by default).
ECHO  /M	Don't display matching lines.
ECHO  /N:nnn	Specifies the maximum number of characters to display for each
ECHO 	matching lines. Without specification, N = 160 characters.
ECHO  /P	Skip files with non-printable characters.
ECHO  /Q	Skip lines containing non-printable characters.
ECHO  /R	Uses search string as regular expressions. For more details, please
ECHO 	read the regular expression reference of FINDSTR command.
ECHO  /S	Searches for matching files in the current directory and all
ECHO 	subdirectories.
ECHO  /X	Searches lines that match exactly.
ECHO.
ECHO  Examples :
ECHO.
ECHO  SEARCH TEXT "Hello world"
ECHO  Searches for all files containing the string "Hello world" and displays the
ECHO  matching lines.
ECHO.
ECHO  SEARCH TEXT "Hello world" /DIR "test" /NAME .txt /M /X
ECHO  Searches for text files inside the directory "test" which contains a whole
ECHO  line "Hello world" but doesn't display them.
ECHO.
ECHO  SEARCH TEXT "Hello world" .txt .bat /FINDSTR /B /I /L
ECHO  Searches for text and batch files containing the strings "Hello" or "world" at
ECHO  the beginning of a line and specifies that the search is not case-sensitive.
ECHO.
ECHO  SEARCH TEXT "^[0-9][0-9]*$" /C /P /R
ECHO  Searches for files with printable characters the lines which contains only
ECHO  digits and displays the result with the count of matching lines.
ECHO.
ECHO  SEARCH TEXT .* /C /M /R
ECHO  Displays the count of all lines inside each file.
ECHO.
ECHO  SEARCH TEXT . /C /M /R
ECHO  Displays the count of non empty lines inside each file.
EXIT /B 0

:HELP_COMP
ECHO SEARCH COMP file1 file2 [options]
ECHO             directory1 directory2 [options]
ECHO.
ECHO  Options : files     [/A] [/B ^| /R] [/I]
ECHO            directories  [/NAME files...] [/DATE [date]] [/TIME [time]]
ECHO                         [/A[:attribute]] [/S] [/T[:tf]] [/V]
ECHO.
ECHO  File comparison searches differences between two specified files and displays
ECHO  the result in the report. Comparison can also be used for two directories,
ECHO  in this case the command compares the content of each directory and displays
ECHO  differences according to name, size, and last modified date/time of each file
ECHO  (criteria can be modified with /CMD specifier).
ECHO.
IF "%~1"=="" GOTO HELP_CMD
ECHO  /A	Displays only first and last lines for each set of differences.
ECHO  /B	Performs a binary comparison.
ECHO  /I	Specifies that the search is not to be case-sensitive.
ECHO  /R	Displays only the range of each set of differences.
ECHO.
ECHO  /A:att	Compares files with specified attributes.
ECHO  /S	Compares the content of the two specified directories and all
ECHO 	subdirectories.
ECHO  /T:tf	Controls which time field displayed or used for comparison
ECHO 	C  Creation		A  Last Access		W  Last Written
ECHO  /V	Searches similarities instead of differences for comparing two
ECHO 	directories.
ECHO.
ECHO  Examples :
ECHO.
ECHO  SEARCH COMP test1.txt test2.txt /I
ECHO  Does a non case-sensitive ASCII comparison between the contents of files
ECHO  "test1.txt" and "test2.txt".
ECHO.
ECHO  SEARCH COMP *.bat test.bat /A
ECHO  Compares the file test.bat with all batch files in current directory and
ECHO  displays the result in abbreviated format.
ECHO.
ECHO  SEARCH COMP test1\*.txt test2\*txt
ECHO  Does an ASCII comparison between text files two by two inside the two
ECHO  directories "test1" and "test2". The compared files must have the same name
ECHO  inside the two directories.
ECHO.
ECHO  SEARCH COMP test1 test2 /A:-D /S
ECHO  Searches for all file differencies between the two directories "test1" and
ECHO  "test2" and all subdirectories.
ECHO.
ECHO  SEARCH COMP test1 test2 /V /CMD "echo @fname"
ECHO  Searches for all homonymous files of the directories "test1" and "test2".
ECHO.
ECHO  SEARCH COMP test1 test2 /NAME .bat /T:C /CMD "echo @fdate @ftime @frelp"
ECHO  Searches for batch files which have different creation date/time inside the
ECHO  two directories "test1" and "test2".
EXIT /B 0

:HELP_CMD
ECHO Command line option reference :
ECHO.
ECHO  Syntax : SEARCH [FILE ^| TEXT ^| COMP] [/CMD[ONLY] "cmdline"]
ECHO.
ECHO  /CMD allows to redirect search result to a specified command line. "cmdline"
ECHO  is the command line to execute for each found files by file search or text
ECHO  search and defines also criteria for comparing two directories. If /CMDONLY is
ECHO  specified, the search report detailed output is disabled.
ECHO  The default command line is "echo @fattr @fdate @ftime @fsize@tab@fpath".
ECHO.
IF "%~1"=="" GOTO HELP_EXIT
ECHO  The following variables can be used in the command string :
ECHO  @fpath   - full path of the file
ECHO  @fshort  - full path of the file with short name 8.3
ECHO  @frelp   - relative path of the file
ECHO  @fname   - name of the file
ECHO  @fext    - extension of the file
ECHO  @fn8.3   - short name 8.3 of the file
ECHO  @fattr   - attributes of the file
ECHO  @fdate   - last modified date of the file
ECHO  @ftime   - last modified time of the file
ECHO  @fsize   - size of the file
ECHO  @fbyte   - size of the file in bytes
ECHO  @count   - file counter
ECHO  @tab     - tab
ECHO  @qot     - quote
ECHO.
ECHO  Examples :
ECHO.
ECHO  SEARCH FILE /CMD "echo @fdate @ftime @fsize@tab@fname@fext"
ECHO  Displays file list similarly to DIR command.
ECHO.
ECHO  SEARCH FILE /S /CMDONLY "echo @fpath"
ECHO  Equivalent to DIR /A /B /S.
ECHO.
ECHO  SEARCH FILE /CMDONLY "echo @fattr;@fdate;@ftime;@fsize;@fpath" ^> test.csv
ECHO  Exports the directory content into CSV document readable by Excel.
ECHO.
ECHO  SEARCH FILE /CMD "echo @fpath & ren @qot@fpath@qot test@count@fext"
ECHO  Renames all elements in current directory with the name "testN".
ECHO.
ECHO  SEARCH FILE /DATE 12/12/2012 /CMD "echo @fpath & copy @qot@fpath@qot test"
ECHO  Copies elements modified the 12th of december 2012 into directory "test".
ECHO.
ECHO  SEARCH TEXT "Hello world" /M /CMD "echo @fpath & del @qot@fpath@qot"
ECHO  Deletes all files which contain the string "Hello world".
ECHO.
ECHO  SEARCH COMP test1 test2 /V /CMD "echo @fname"
ECHO  Searches for all homonymous files of the directories "test1" and "test2".
ECHO.
ECHO  SEARCH COMP test1 test2 /NAME .bat /T:C /CMD "echo @fdate @ftime @frelp"
ECHO  Searches for batch files which have different creation date/time inside the
ECHO  two directories "test1" and "test2".
EXIT /B 0

:HELP_EXIT
ECHO Enter SEARCH HELP [FILE ^| TEXT ^| COMP ^| CMD] to obtain more details.
EXIT /B 0

:: -------------------- PostProcess --------------------

:ERROR
IF "%~1%~2%~3"=="" ( ECHO Invalid syntax : missing argument. 1>&2
) ELSE ECHO Invalid syntax : "%~1". 1>&2
EXIT /B 2

:EXIT
IF %N% EQU 0 ( EXIT /B 1
) ELSE EXIT /B 0
