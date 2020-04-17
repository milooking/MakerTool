;*****************************************
;******** 单片机仿真模拟器窗体界面 ********
;********    迷路仟 2020.02.29    ********
;*****************************************
;【Maker_Progress.pbi】 信息对话框源代码

#Progress_OpenFile = 0
#Progress_SaveFile = 1


;-[Enumeration]
Enumeration Screen
   #winProgress            ;对话框编号
EndEnumeration

;-[IncludeFile]
XIncludeFile ".\Maker_Define.pbi"      ;定义类源代码

;-[Structure]
;信息对话框结构
Structure __Progress_MainInfo Extends __WindowInfo
   hProgressIcon.i
   TitleH.l
   NoticeH.l
   Flags.l
   Title$
   hParent.i
   Progress.l
   Progress$
   ;=========
   *pColors.__ColorInfo
   *pWindow.__WindowInfo
   ;=========
   Events.__EventInfo
   ;=========
   *pCallProgressBar
   ;=========
   IsExitWindow.b
   IsRefresh.b
   IsEnable.b
EndStructure

;-[Global]
Global _Progress.__Progress_MainInfo

;-
;- ******** [Redraw] ********
;绘制边框
Procedure Progress_RedrawBorder()
   With _Progress
      BackColor = \pColors\BackColor
      HighColor = \pColors\HighColor
      ForeColor = \pColors\ForeColor
      ;绘制背景
      DrawingMode(#PB_2DDrawing_AllChannels)
      Box(0, 0, \WindowW, \WindowH, ForeColor)
      Box(4, \TitleH, \WindowW-4-4, \WindowH-\TitleH-8, BackColor)
      
      ;高亮色
      Box(1, \TitleH-3, \WindowW-2, 2, HighColor)              ;标题
      Box(1, \TitleH-1, 2, \WindowH-\TitleH, HighColor)        ;左际
      Box(\WindowW-3,\TitleH-1,2,\WindowH-\TitleH, HighColor)  ;右际
      For k = 1 To 6
         Line(1, \TitleH-9+k, 100+k, 1, HighColor)             ;标题左侧
         Line(3, \WindowH-8+k, 90-k, 1, HighColor)             ;底部左侧  
         Line(\WindowW-3, \WindowH-8+k, -90+k, 1, HighColor)   ;底部右侧  
      Next 
      
      ;条纹色
      For k = 1 To 8
         Line(20+k*7, \TitleH-7, 5, 5, ForeColor)              ;标题左侧
         Line(21+k*7, \TitleH-7, 5, 5, ForeColor)              ;标题左侧 
         Line(22+k*7, \TitleH-7, 5, 5, ForeColor)              ;标题左侧 
         Line(14+k*7, \WindowH-6, -4, 4, ForeColor)            ;底部左侧
         Line(13+k*7, \WindowH-6, -4, 4, ForeColor)            ;底部左侧 
         Line(12+k*7, \WindowH-6, -4, 4, ForeColor)            ;底部左侧 
         Line(\WindowW-12-k*7, \WindowH-6, 4, 4, ForeColor)    ;底部左侧
         Line(\WindowW-13-k*7, \WindowH-6, 4, 4, ForeColor)    ;底部右侧             
         Line(\WindowW-14-k*7, \WindowH-6, 4, 4, ForeColor)    ;底部右侧             
      Next
   EndWith
EndProcedure

;绘制事件
Procedure Progress_RedrawScreen()
   With _Progress
      ;绘制与当前窗体与鼠标事件相关的界面
      If StartDrawing(ImageOutput(\LayerImageID))
         BackColor = \pColors\BackColor
         HighColor = \pColors\HighColor
         ForeColor = \pColors\ForeColor
         Progress_RedrawBorder()
         
         DrawingMode(#PB_2DDrawing_AlphaBlend|#PB_2DDrawing_Outlined)
         Box(020, 055, 400, 18, ForeColor)         
         
         DrawingMode(#PB_2DDrawing_AlphaBlend|#PB_2DDrawing_Gradient)
         BackColor (HighColor)
         FrontColor(ForeColor)
         Index = \Progress*4/10
         LinearGradient(021, 056, Index+021, 016+056)
         Box(021, 056, Index, 16, ForeColor)  

         ;绘制文本
         DrawingMode(#PB_2DDrawing_AlphaBlend|#PB_2DDrawing_Transparent)
         DrawingFont(FontID(\pWindow\Font12ID))
         DrawText(20, (\TitleH-TextHeight(\Title$)-8)/2, \Title$, BackColor)
         X = 40 : Y = \TitleH+20
         DrawText(020, 080, \Progress$, ForeColor)  
         StopDrawing()
      EndIf 

      ;将对话框图像渲染到窗体
      If \hLayerImage : DeleteObject_(\hLayerImage) : \hLayerImage = 0 : EndIf  ;释放窗体背景句柄
      \hLayerImage= CreatePatternBrush_(ImageID(\LayerImageID))
      If \hLayerImage
         SetClassLongPtr_(\hWindow, #GCL_HBRBACKGROUND, \hLayerImage)
         RedrawWindow_(\hWindow, #Null, #Null, #RDW_UPDATENOW|#RDW_ERASE|#RDW_INVALIDATE)
      EndIf 
   EndWith
EndProcedure

;-
;- ======> [External Call] <======
;信息对话框初始化
Procedure Progress_Initial(*pWindow.__WindowInfo, *pColors)
   With _Progress
      \pWindow      = *pWindow
      \pColors      = *pColors
      \LayerImageID = CreateImage(#PB_Any, 440, 120)
   EndWith
EndProcedure

;信息对话框初始化
Procedure Progress_Requester(hParent, Title$, IsEnable=#True)
   With _Progress
      \Flags    = Flags
      \Title$   = Title$
      \IsExitWindow = #False      
      \TitleH   = 38
      \WindowW  = 440
      \WindowH  = 120
      \hParent  = hParent
      \IsEnable = IsEnable
      If hParent = #Null
         WindowFlags = #PB_Window_BorderLess|#PB_Window_ScreenCentered
         \hWindow = OpenWindow(#winProgress, 0, 0, \WindowW, \WindowH, "", WindowFlags)
      ElseIf IsZoomed_(hParent) Or IsIconic_(hParent) ;判断父窗体是否最大化和最小化
         WindowFlags = #PB_Window_BorderLess|#PB_Window_ScreenCentered
         \hWindow = OpenWindow(#winProgress, 0, 0, \WindowW, \WindowH, "", WindowFlags, hParent)
      Else 
         WindowFlags = #PB_Window_BorderLess|#PB_Window_WindowCentered
         \hWindow = OpenWindow(#winProgress, 0, 0, \WindowW, \WindowH, "", WindowFlags, hParent)
      EndIf
      Progress_RedrawScreen()
      If IsEnable=#True And hParent
         EnableWindow_(hParent, #False)   ;禁用父窗体的响应动作
      EndIf 
   EndWith
EndProcedure

Procedure Progress_ChangeStyle(*pColors)
   _Progress\pColors = *pColors
EndProcedure

Procedure Progress_SetInfo(Progress$, Progress, IsExitWindow)
   With _Progress
      WindowEvent()
      _Progress\Progress$    = Progress$
      _Progress\Progress     = Progress
      Progress_RedrawScreen()
      If IsExitWindow = #True
          Delay(200)
         If \hLayerImage  ;释放窗体背景句柄
            DeleteObject_(\hLayerImage) 
            \hLayerImage = 0
         EndIf 
         CloseWindow(#winProgress)
         If \IsEnable=#True And \hParent
            EnableWindow_(\hParent, #True)   ;恢复父窗体的响应动作
         EndIf 
         Delay(100)
      EndIf 
   EndWith
EndProcedure

;注销信息对话框
Procedure Progress_Release()
   With _Progress
      If IsImage(\LayerImageID) 
         FreeImage(\LayerImageID)
      EndIf 
   EndWith
EndProcedure

;-
;- ######## [Test] ######## 
CompilerIf  #PB_Compiler_IsMainFile = #True
   Global Index
   Procedure Call_ProgressBar()
      For Index = 0 To 1000
         Delay(5)
         If Index % 10 = 0
            Progress = Index/10
            Progress$ = "解压进度值: " + Str(Progress)+"%"
            Progress_SetInfo(Progress$, Index, #False)   ;最大值1000
         EndIf 
      Next 
      Progress  = 100
      Progress$ = "解压进度值: " + Str(Progress)+"%"
      Progress_SetInfo(Progress$, 1000, #True)
   EndProcedure   
   
   #winScreen = 1000
   Color.__ColorInfo
   Color\BackColor = #Define_BackColor   
   Color\ForeColor = #Define_ForeColor
   Color\HighColor = #Define_HighColor
   Window.__WindowInfo
   Window\Font12ID = LoadFont(#PB_Any, "宋体", 12)  
   UsePNGImageDecoder()
   Window\ResourIconID  = CatchImage(#PB_Any, ?_ICON_Resources)
   ;======================
   WindowFlags = #PB_Window_SystemMenu|#PB_Window_MinimizeGadget|#PB_Window_ScreenCentered
   hWindow = OpenWindow(#winScreen, 0, 0, 500, 250, "Progress-测试" , WindowFlags)
   Progress_Initial(@Window, @Color)
   ;======================
   Repeat
      WindowEvent = WindowEvent()
      Select WindowEvent
         Case #PB_Event_CloseWindow : IsExitWindow = #True
         Case #WM_LBUTTONUP 
            Progress_Requester(hWindow, "解压", #True)
            Call_ProgressBar()
      EndSelect
   Until IsExitWindow = #True 
   FreeFont(Window\Font12ID)   
   Progress_Release()
   End
   
DataSection
_ICON_Resources:
   IncludeBinary ".\ICON.png" 
EndDataSection

CompilerEndIf 














; IDE Options = PureBasic 5.62 (Windows - x86)
; CursorPosition = 2
; Folding = r6
; EnableXP
; Executable = DEMO.exe