:: THIS IS AN ENGINE FILE AND SHOULD NOT BE RUN DIRECTLY

@If [%1]==[] Goto :eof
@Echo Off

Rem --- Detect available binaries
If Not Exist vivaldi_%1\Application\vivaldi.exe (
  Echo ERROR: Vivaldi "%1" directory not found
  Echo Press any key to exit
  Pause>nul
  Goto :eof
)

Rem --- Count profiles

Set /A NProf=0
Rem  No profiles directory - creating new with default profile
If Not Exist profiles Mkdir profiles\default
Pushd profiles
Rem  Count profile directories, assign current profile
For /F "tokens=*" %%k In ('Dir /b /ad') Do (
  Set ProfName=%%k
  Set /A NProf+=1
)
Rem  No profiles in profiles directory - creating default
If Not Defined ProfName (
  Mkdir default
  Set ProfName=default
  Set /A NProf=1
)
Popd

Rem --- Single profile - start it

Set UseProfile=%ProfName%
If %NProf% EQU 1 Goto start_profile

Rem --- Multiple profiles - prompt to select

Echo * Available profiles:
Dir /b /ad /w profiles
Echo.

:multi_profile
Set UseProfile=
Set LastProfile=%ProfName%
If Not Exist last_profile Goto select_profile

Rem --- Found last_profile marker. Reading first line

REM For /F "tokens=*" %%k In (last_profile) Do (
REM   Set LastProfile=%%k
REM   Goto select_profile
REM )
REM :select_profile

Set /P "LastProfile=" < last_profile
Rem  Using pushd for TAB to work in prompt
Pushd profiles
Set /P "UseProfile=* Which profile? TAB=select, ENTER=[%LastProfile%]: "
Rem  Pressed Enter (empty value) = use default
If Not Defined UseProfile Set UseProfile=%LastProfile%
Popd
Rem  Bad profile name specified? Retry
If Not Exist "profiles\%UseProfile%\" Goto multi_profile

:start_profile
Echo %UseProfile%>last_profile
Prompt $$$S
Echo On
Start "" vivaldi_%1\Application\vivaldi.exe --user-data-dir="profiles\%UseProfile%"
@Timeout /t 10
