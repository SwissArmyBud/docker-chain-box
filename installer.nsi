!include "LogicLib.nsh"
!include "Sections.nsh"

# set the name of the installer
Outfile "Install.exe"

!define Rnd "!insertmacro _Rnd"
!macro _Rnd _RetVal_ _Min_ _Max_
   Push "${_Max_}"
   Push "${_Min_}"
   Call Rnd
   Pop ${_RetVal_}
!macroend
Function Rnd
   Exch $0  ;; Min / return value
   Exch
   Exch $1  ;; Max / random value
   Push "$3"  ;; Max - Min range
   Push "$4"  ;; random value buffer

   IntOp $3 $1 - $0 ;; calculate range
   IntOp $3 $3 + 1
   System::Call '*(l) i .r4'
   System::Call 'advapi32::SystemFunction036(i r4, i 4)'  ;; RtlGenRandom
   System::Call '*$4(l .r1)'
   System::Free $4
   ;; fit value within range
   System::Int64Op $1 * $3
   Pop $3
   System::Int64Op $3 / 0xFFFFFFFF
   Pop $3
   IntOp $0 $3 + $0  ;; index with minimum value

   Pop $4
   Pop $3
   Pop $1
   Exch $0
FunctionEnd

# create a default section.
Section

    InitPluginsDir
    Var /GLOBAL ONE_TIME_PATH

    # get a random 4-digit number for post-fix and check it's free
    ${Do}
        ${Rnd} $0 1000 9999
        StrCpy $ONE_TIME_PATH "BR-Tournamnent-$0"
    ${LoopWhile} ${FileExists} "$DESKTOP\BR-Tournamnent-$0"

    # send file to temp
    SetCompress off
    SetOutPath "$PLUGINSDIR"
    File "Tournament.zip"

    DetailPrint "$ONE_TIME_PATH"
    CreateDirectory "$DESKTOP\$ONE_TIME_PATH"

    # Call plug-in. Push filename to ZIP first, and the dest. folder last.
    nsisunz::UnzipToLog "$PLUGINSDIR\Tournament.zip" "$DESKTOP\$ONE_TIME_PATH"
    # Always check result on stack
    Pop $0
    StrCmp $0 "success" ok
        DetailPrint "$0" ;print error message to log
    ok:

SectionEnd
