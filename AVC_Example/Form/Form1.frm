VERSION 5.00
Object = "{F9043C88-F6F2-101A-A3C9-08002B2F49FB}#1.2#0"; "COMDLG32.ocx"
Begin VB.Form Form1 
   BorderStyle     =   1  'Fixed Single
   Caption         =   "AVC"
   ClientHeight    =   1710
   ClientLeft      =   45
   ClientTop       =   330
   ClientWidth     =   3015
   LinkTopic       =   "Form1"
   MaxButton       =   0   'False
   ScaleHeight     =   1710
   ScaleWidth      =   3015
   StartUpPosition =   3  'Windows Default
   Begin VB.CommandButton Command3 
      Caption         =   "Cancel"
      Height          =   375
      Left            =   1680
      TabIndex        =   5
      Top             =   1200
      Width           =   1215
   End
   Begin MSComDlg.CommonDialog CD1 
      Left            =   3360
      Top             =   0
      _ExtentX        =   847
      _ExtentY        =   847
      _Version        =   393216
   End
   Begin VB.CommandButton Command2 
      Caption         =   "..."
      Height          =   255
      Left            =   2520
      TabIndex        =   4
      Top             =   360
      Width           =   375
   End
   Begin VB.Timer Timer1 
      Enabled         =   0   'False
      Left            =   3360
      Top             =   0
   End
   Begin VB.TextBox Text2 
      Height          =   285
      Left            =   120
      TabIndex        =   3
      Text            =   "OutputVideo.avi"
      Top             =   720
      Width           =   2295
   End
   Begin VB.TextBox Text1 
      Height          =   285
      Left            =   120
      TabIndex        =   2
      Top             =   360
      Width           =   2295
   End
   Begin VB.CommandButton Command1 
      Caption         =   "Convert"
      Height          =   375
      Left            =   120
      TabIndex        =   0
      Top             =   1200
      Width           =   1215
   End
   Begin VB.Label Label1 
      Alignment       =   2  'Center
      Appearance      =   0  'Flat
      BackColor       =   &H80000005&
      BackStyle       =   0  'Transparent
      Caption         =   "Ready"
      ForeColor       =   &H80000008&
      Height          =   255
      Left            =   120
      TabIndex        =   1
      Top             =   0
      Width           =   2775
   End
End
Attribute VB_Name = "Form1"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = False
Attribute VB_PredeclaredId = True
Attribute VB_Exposed = False
Option Explicit
' You Must have avformat.dll to use this example download it here http://rapidshare.com/files/116942540/avformat.zip
' or get a ffmpeg.exe and rename it to avformat.dll
Private WithEvents AVC1 As AVC
Attribute AVC1.VB_VarHelpID = -1
Private IntCaptn As Integer

Private Sub Command1_Click()
On Error Resume Next
If Text1.Text = "" Then Command2_Click: Exit Sub
AVC1.AudioBitrate = "128"
AVC1.AudioChannels = "2"
AVC1.AudioCodec = "mp2"
AVC1.AudioSamples = "22050"
'AVC1.AudioFourCCTag = "0x55"

AVC1.VideoBitrate = "360"
AVC1.VideoFrameRate = "25"
AVC1.VideoSize = "320x240"
AVC1.VideoCodec = "mpeg4"

'AVC1.VideoFourCCTag = "xvid"
'AVC1.GroupOfPictureSize = "250"
'AVC1.VideoQuantiserScale = "25"
'AVC1.MaxVideoBitrate = "1500"
'AVC1.RateControlBuffer = "128"
'AVC1.ForceFormat = "avi"
'AVC1.TargetFormat = "vcd"
'AVC1.VideoBitrateTolerance = "60"
'AVC1.VideoAspectRatio = "4:3"

AVC1.SameQuality = True
AVC1.DeInterlace = True

AVC1.SourceFile = Text1.Text
AVC1.DestFile = App.Path & "\" & Text2.Text
AVC1.ConvertMedia True
End Sub

Private Sub Command2_Click()
On Error Resume Next
CD1.DialogTitle = "Locate Source Media File"
CD1.Filter = "All Media Files|*.mp3;*.avi;*.mpg;*.mpeg;*.vob;*.mov;*.wmv;*.wma;*.wav;*.rm;*.flv;*.3gp;*.3g2;*.m4a;*.dat;*.fla;*.swf;*.m1v;*.m2v;*.ram;*.qt;*.ogm;*.ogg;*.mpv;*.mp2;*.mp1;*.m2p;*.mp4;*.mpa;*.aac;*.divx;*.dv;*.aif;*.aiff;*.asf;*.ac3"
CD1.ShowOpen
If CD1.FileName = "" Then Exit Sub
Text1.Text = CD1.FileName
End Sub

Private Sub Command3_Click()
AVC1.CancelConvert
End Sub

Private Sub Form_Load()
On Error Resume Next
Set AVC1 = New AVC
IntCaptn = 0
End Sub

Private Sub Form_Unload(Cancel As Integer)
On Error Resume Next
Set AVC1 = Nothing
End
End Sub

Private Sub AVC1_Complete()
On Error Resume Next
Label1.Caption = "Complete"
End Sub

Private Sub AVC1_Converting()
On Error Resume Next
On Error Resume Next
Select Case IntCaptn
Case Is = 0
IntCaptn = 1
Label1.Caption = "Please Wait Converting..."
Case Is = 1
IntCaptn = 2
Label1.Caption = "Please Wait Converting>.."
Case Is = 2
IntCaptn = 3
Label1.Caption = "Please Wait Converting.>."
Case Is = 3
IntCaptn = 0
Label1.Caption = "Please Wait Converting..>"
End Select
End Sub

Private Sub AVC1_ErrorEvent(ErrorMessage As String)
On Error Resume Next
Label1.Caption = ErrorMessage
End Sub

