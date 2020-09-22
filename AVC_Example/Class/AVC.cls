VERSION 1.0 CLASS
BEGIN
  MultiUse = -1  'True
  Persistable = 0  'NotPersistable
  DataBindingBehavior = 0  'vbNone
  DataSourceBehavior  = 0  'vbNone
  MTSTransactionMode  = 0  'NotAnMTSObject
END
Attribute VB_Name = "AVC"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = True
Attribute VB_PredeclaredId = False
Attribute VB_Exposed = False
Option Explicit
' You Must have avformat.dll to use this example download it here http://rapidshare.com/files/116942540/avformat.zip
' or get a ffmpeg.exe and rename it to avformat.dll
Private Type SECURITY_ATTRIBUTES
 nLength As Long
 lpSecurityDescriptor As Long
 bInheritHandle As Long
End Type

Private Type STARTUPINFO
 cb As Long
 lpReserved As Long
 lpDesktop As Long
 lpTitle As Long
 dwX As Long
 dwY As Long
 dwXSize As Long
 dwYSize As Long
 dwXCountChars As Long
 dwYCountChars As Long
 dwFillAttribute As Long
 dwFlags As Long
 wShowWindow As Integer
 cbReserved2 As Integer
 lpReserved2 As Long
 hStdInput As Long
 hStdOutput As Long
 hStdError As Long
End Type

Private Type PROCESS_INFORMATION
 hProcess As Long
 hThread As Long
 dwProcessID As Long
 dwThreadID As Long
End Type

Private Type PROCESSENTRY32
 dwSize As Long
 cntUsage As Long
 th32ProcessID As Long
 th32DefaultHeapID As Long
 th32ModuleID As Long
 cntThreads As Long
 th32ParentProcessID As Long
 pcPriClassBase As Long
 dwFlags As Long
 szExeFile As String * 260
End Type

Private Const AVCLIB = "avformat.dll"  '"ffmpeg.exe"

'Public Event DataOutput(strData As String)
Public Event Converting()
Public Event Complete()
Public Event ErrorEvent(ErrorMessage As String)
Private WithEvents Timer1 As Timer
Attribute Timer1.VB_VarHelpID = -1

Private Declare Function OpenProcess Lib "kernel32.dll" (ByVal dwDesiredAccessas As Long, ByVal bInheritHandle As Long, ByVal dwProcId As Long) As Long
Private Declare Function TerminateProcess Lib "kernel32.dll" (ByVal hProcess As Long, ByVal uExitCode As Long) As Long
Private Declare Function CreateToolhelpSnapshot Lib "kernel32.dll" Alias "CreateToolhelp32Snapshot" (ByVal lFlags As Long, lProcessID As Long) As Long
Private Declare Function ProcessFirst Lib "kernel32.dll" Alias "Process32First" (ByVal hSnapshot As Long, uProcess As PROCESSENTRY32) As Long
Private Declare Function ProcessNext Lib "kernel32.dll" Alias "Process32Next" (ByVal hSnapshot As Long, uProcess As PROCESSENTRY32) As Long
Private Declare Function CreatePipe Lib "kernel32" (phReadPipe As Long, phWritePipe As Long, lpPipeAttributes As Any, ByVal nSize As Long) As Long
Private Declare Function ReadFile Lib "kernel32" (ByVal hFile As Long, ByVal lpBuffer As String, ByVal nNumberOfBytesToRead As Long, lpNumberOfBytesRead As Long, ByVal lpOverlapped As Any) As Long
Private Declare Function GetShortPathName Lib "kernel32" Alias "GetShortPathNameA" (ByVal lpszLongPath As String, ByVal lpszShortPath As String, ByVal cchBuffer As Long) As Long
Private Declare Function CreateProcessA Lib "kernel32" (ByVal lpApplicationName As Long, ByVal lpCommandLine As String, lpProcessAttributes As SECURITY_ATTRIBUTES, lpThreadAttributes As SECURITY_ATTRIBUTES, ByVal bInheritHandles As Long, ByVal dwCreationFlags As Long, ByVal lpEnvironment As Long, ByVal lpCurrentDirectory As Long, lpStartupInfo As STARTUPINFO, lpProcessInformation As PROCESS_INFORMATION) As Long
Private Declare Function CloseHandle Lib "kernel32" (ByVal hHandle As Long) As Long
Private ProcessInfo As PROCESS_INFORMATION
Private StartInfo As STARTUPINFO
Private SecurityAtt As SECURITY_ATTRIBUTES
Private ReadHandle As Long, WriteHandle As Long
Private cVideoSize As String, cVideoBitrate As String, cVideoFrameRate As String, cVideoCodec As String, cVideoFourCCTag As String, cVideoBitrateTolerance As String
Private cAudioBitrate As String, cAudioCodec As String, cAudioFourCCTag As String, cAudioSamples As String, cAudioChannels As String, cTargetFormat As String
Private cDeInterlace As Boolean, cSameQuality As Boolean, cVideoAspectRatio As String, cForceFormat As String, cSourceFile As String, cDestFile As String
Private cRateControlBuffer As String, cGroupOfPictureSize As String, cVideoQuantiserScale As String, cMaxVideoBitrate As String

Public Property Let VideoBitrateTolerance(ByVal StrValue As String)
cVideoBitrateTolerance = StrValue
End Property

Public Property Let TargetFormat(ByVal StrValue As String)
cTargetFormat = StrValue
End Property

Public Property Let GroupOfPictureSize(ByVal StrValue As String)
cGroupOfPictureSize = StrValue
End Property

Public Property Let VideoQuantiserScale(ByVal StrValue As String)
cVideoQuantiserScale = StrValue
End Property

Public Property Let MaxVideoBitrate(ByVal StrValue As String)
cMaxVideoBitrate = StrValue
End Property

Public Property Let SourceFile(ByVal StrValue As String)
cSourceFile = StrValue
End Property

Public Property Let DestFile(ByVal StrValue As String)
cDestFile = StrValue
End Property

Public Property Let DeInterlace(ByVal StrValue As Boolean)
cDeInterlace = StrValue
End Property

Public Property Let SameQuality(ByVal StrValue As Boolean)
cSameQuality = StrValue
End Property

Public Property Let VideoSize(ByVal StrValue As String)
cVideoSize = StrValue
End Property

Public Property Let VideoBitrate(ByVal StrValue As String)
cVideoBitrate = StrValue
End Property

Public Property Let VideoFrameRate(ByVal StrValue As String)
cVideoFrameRate = StrValue
End Property

Public Property Let VideoCodec(ByVal StrValue As String)
cVideoCodec = StrValue
End Property

Public Property Let VideoFourCCTag(ByVal StrValue As String)
cVideoFourCCTag = StrValue
End Property

Public Property Let VideoAspectRatio(ByVal StrValue As String)
cVideoAspectRatio = StrValue
End Property

Public Property Let ForceFormat(ByVal StrValue As String)
cForceFormat = StrValue
End Property

Public Property Let AudioBitrate(ByVal StrValue As String)
cAudioBitrate = StrValue
End Property

Public Property Let AudioCodec(ByVal StrValue As String)
cAudioCodec = StrValue
End Property

Public Property Let AudioFourCCTag(ByVal StrValue As String)
cAudioFourCCTag = StrValue
End Property

Public Property Let AudioSamples(ByVal StrValue As String)
cAudioSamples = StrValue
End Property

Public Property Let AudioChannels(ByVal StrValue As String)
cAudioChannels = StrValue
End Property

Private Function CloseAVCLib(myName As String)
On Local Error GoTo Finish
Dim uProcess As PROCESSENTRY32
Dim CloseReturn As Boolean, sExeName As String, sPid As String, sParentPid As String, lSnapShot As Long, r As Long
Dim rProcessFound As Long, hSnapshot As Long, szExename As String, exitCode As Long
Dim myProcess As Long, AppKill As Boolean, appCount As Integer, I As Integer
appCount = 0
uProcess.dwSize = Len(uProcess)
hSnapshot = CreateToolhelpSnapshot(2&, 0&)
rProcessFound = ProcessFirst(hSnapshot, uProcess)
Do While rProcessFound
I = InStr(1, uProcess.szExeFile, Chr$(0))
szExename = LCase$(Left$(uProcess.szExeFile, I - 1))
If Right$(szExename, Len(myName)) = LCase$(myName) Then
CloseReturn = True
appCount = appCount + 1
myProcess = OpenProcess(1&, -1&, uProcess.th32ProcessID)
AppKill = TerminateProcess(myProcess, 0&)
Call CloseHandle(myProcess)
End If
rProcessFound = ProcessNext(hSnapshot, uProcess)
Loop
Call CloseHandle(hSnapshot)
Finish:
CloseReturn = False
End Function

Private Function GetShortName(ByVal sLongFileName As String) As String
On Error Resume Next
Dim lRetVal As Long, sShortPathName As String, iLen As Integer
sShortPathName = Space(255)
iLen = Len(sShortPathName)
lRetVal = GetShortPathName(sLongFileName, sShortPathName, iLen)
GetShortName = Left(sShortPathName, lRetVal)
End Function

Private Sub ConvertAV(mCommand As String)
On Error Resume Next
Dim Rv As Long
SecurityAtt.nLength = Len(SecurityAtt)
SecurityAtt.bInheritHandle = 1&
SecurityAtt.lpSecurityDescriptor = 0&
Rv = CreatePipe(ReadHandle, WriteHandle, SecurityAtt, 0)
If Rv = 0 Then Exit Sub
StartInfo.cb = Len(StartInfo)
StartInfo.dwFlags = &H100& Or &H1
StartInfo.hStdOutput = WriteHandle
StartInfo.hStdError = WriteHandle
Rv = CreateProcessA(0&, mCommand, SecurityAtt, SecurityAtt, 1&, &H20&, 0&, 0&, StartInfo, ProcessInfo)
If Rv <> 1 Then Exit Sub
Call CloseHandle(WriteHandle)
Timer1.Interval = 300
Timer1.Enabled = True
End Sub

Public Sub ConvertMedia(OverWrite As Boolean)
On Error Resume Next
Dim Cmd As String, FormatType As String
FormatType = ""
If cSourceFile = "" Then RaiseEvent ErrorEvent("No source filename defined"): Exit Sub
If cDestFile = "" Then RaiseEvent ErrorEvent("No destination filename defined"):  Exit Sub
If OverWrite = True Then FormatType = FormatType & "-y" & Chr(32)
If Not cVideoBitrate = "" Then FormatType = FormatType & "-b " & cVideoBitrate & Chr(32)
If Not cVideoFrameRate = "" Then FormatType = FormatType & "-r " & cVideoFrameRate & Chr(32)
If Not cVideoSize = "" Then FormatType = FormatType & "-s " & cVideoSize & Chr(32)
If Not cVideoCodec = "" Then FormatType = FormatType & "-vcodec " & cVideoCodec & Chr(32)
If Not cVideoFourCCTag = "" Then FormatType = FormatType & "-vtag " & cVideoFourCCTag & Chr(32)
If Not cVideoAspectRatio = "" Then FormatType = FormatType & "-aspect " & cVideoAspectRatio & Chr(32)
If Not cVideoBitrateTolerance = "" Then FormatType = FormatType & "-bt " & cVideoBitrateTolerance & Chr(32)
If Not cForceFormat = "" Then FormatType = FormatType & "-f " & cForceFormat & Chr(32)
If Not cTargetFormat = "" Then FormatType = FormatType & "-target " & cTargetFormat & Chr(32)
If Not cRateControlBuffer = "" Then FormatType = FormatType & "-bufsize " & cRateControlBuffer & Chr(32)
If Not cGroupOfPictureSize = "" Then FormatType = FormatType & "-g " & cGroupOfPictureSize & Chr(32)
If Not cVideoQuantiserScale = "" Then FormatType = FormatType & "-qscale " & cVideoQuantiserScale & Chr(32)
If Not cMaxVideoBitrate = "" Then FormatType = FormatType & "-maxrate " & cMaxVideoBitrate & Chr(32)
If cDeInterlace = True Then FormatType = FormatType & "-deinterlace" & Chr(32)
If cSameQuality = True Then FormatType = FormatType & "-sameq" & Chr(32)
If Not cAudioCodec = "" Then FormatType = FormatType & "-acodec " & cAudioCodec & Chr(32)
If Not cAudioFourCCTag = "" Then FormatType = FormatType & "-atag " & cAudioFourCCTag & Chr(32)
If Not cAudioBitrate = "" Then FormatType = FormatType & "-ab " & cAudioBitrate & Chr(32)
If Not cAudioSamples = "" Then FormatType = FormatType & "-ar " & cAudioSamples & Chr(32)
If Not cAudioChannels = "" Then FormatType = FormatType & "-ac " & cAudioChannels & Chr(32)
Cmd = GetShortName(App.Path & Chr(92) & AVCLIB) & Chr(32) & Chr(45) & Chr(105) & Chr(32) & Chr(34) & cSourceFile & Chr(34) & Chr(32) & FormatType & Chr(34) & cDestFile & Chr(34)
If Dir(App.Path & Chr(92) & AVCLIB, vbNormal) = "" Then
RaiseEvent ErrorEvent("Unable to locate " & AVCLIB)
Else
ConvertAV Cmd
End If
End Sub

Private Sub Class_Initialize()
On Error Resume Next
Set Timer1 = Form1.Timer1
End Sub

Private Sub Class_Terminate()
On Error Resume Next
Set Timer1 = Nothing
End Sub

Private Sub Timer1_Timer()
On Error Resume Next
Dim Data As String * 256
Dim Rv As Long, DataLength As Long
Rv = ReadFile(ReadHandle, Data, 256, DataLength, 0&)
'RaiseEvent DataOutput(Replace(Left(Data, DataLength), Chr(0), ""))
RaiseEvent Converting
If Rv <> 0 Then Exit Sub
Call CloseHandle(ProcessInfo.hProcess)
Call CloseHandle(ProcessInfo.hThread)
Call CloseHandle(ReadHandle)
Timer1.Enabled = False
cSourceFile = ""
cDestFile = ""
cVideoBitrate = ""
cVideoFrameRate = ""
cVideoSize = ""
cVideoCodec = ""
cVideoFourCCTag = ""
cVideoAspectRatio = ""
cForceFormat = ""
cRateControlBuffer = ""
cGroupOfPictureSize = ""
cVideoQuantiserScale = ""
cVideoBitrateTolerance = ""
cMaxVideoBitrate = ""
cAudioCodec = ""
cAudioFourCCTag = ""
cAudioBitrate = ""
cAudioSamples = ""
cAudioChannels = ""
cDeInterlace = False
cSameQuality = False
RaiseEvent Complete
End Sub

Public Sub CancelConvert()
On Error Resume Next
CloseAVCLib AVCLIB
End Sub
