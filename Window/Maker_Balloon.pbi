;*****************************************
;******** 单片机仿真模拟器窗体界面 ********
;********    迷路仟 2020.02.24    ********
;*****************************************
;【Maker_Balloon.pbi】 控件提示文源代码

;-[Enumeration]
Enumeration Screen
   #winBalloon
   #imgBalloon
EndEnumeration

;-[IncludeFile]
XIncludeFile ".\Maker_Define.pbi"      ;定义类源代码

;-[Structure]
Structure __Balloon_MainInfo Extends __WindowInfo
   *pBalloon.__GadgetInfo
   *pColors.__ColorInfo
   *pWindow.__WindowInfo
   Map *pMapGadget.__GadgetInfo()
   IsShowWindow.l
EndStructure

;-[Global]
Global _Balloon.__Balloon_MainInfo

;-
;- ******** [Redraw] ********
;提示文窗体自绘
Procedure Balloon_RedrawScreen()
   With _Balloon
      BackColor = \pColors\BackColor
      ForeColor = \pColors\ForeColor
      If StartDrawing(ImageOutput(\LayerImageID))
         DrawingFont(FontID(\pWindow\Font12ID))
         DrawingMode(#PB_2DDrawing_AllChannels)
         Box(0, 0, \WindowW, \WindowH, BackColor)
         DrawingMode(#PB_2DDrawing_AlphaBlend)
         Box(0, 0,\WindowW, \WindowH, BackColor)
         DrawingMode(#PB_2DDrawing_AlphaBlend|#PB_2DDrawing_Transparent)
         DrawText(10, 05, \pBalloon\BalloonTip$, ForeColor)
         DrawingMode(#PB_2DDrawing_AlphaBlend|#PB_2DDrawing_Outlined)
         Box(0, 0, \WindowW, \WindowH, ForeColor) 
         StopDrawing()
      EndIf 
         
      If \hLayerImage : DeleteObject_(\hLayerImage) : \hLayerImage = 0 : EndIf  ;释放窗体背景句柄

      ;将背景图像渲染到窗体
      \hLayerImage= CreatePatternBrush_(ImageID(\LayerImageID))
      If \hLayerImage
         SetClassLongPtr_(\hWindow, #GCL_HBRBACKGROUND, \hLayerImage)
         RedrawWindow_(\hWindow, #Null, #Null, #RDW_INTERNALPAINT|#RDW_ERASE|#RDW_INVALIDATE)
      EndIf 
   EndWith
EndProcedure

;-
;- ******** [Hook] ********
;用于[Screen_HookWindow()]
Procedure Balloon_Hook_MOUSEMOVE(*pEventGadget)
   With _Balloon
      If \pBalloon = *pEventGadget : ProcedureReturn *pEventGadget : EndIf 
      If *pEventGadget = #Null
         \pBalloon = #Null
         SetTimer_(\pWindow\hWindow, #TIMER_ShowBalloon, 0010, #Null) 
      Else
         ForEach \pMapGadget()
            If \pMapGadget() = *pEventGadget
               If \IsShowWindow = #True And \pBalloon <> *pEventGadget 
                  \pBalloon = *pEventGadget
                  KillTimer_(\pWindow\hWindow, #TIMER_ShowBalloon)
                  SetTimer_(\pWindow\hWindow, #TIMER_ShowBalloon, 0010, #Null) 
                  ProcedureReturn *pEventGadget
               Else 
                  \pBalloon = *pEventGadget
                  SetTimer_(\pWindow\hWindow, #TIMER_ShowBalloon, 1000, #Null)
                  ProcedureReturn *pEventGadget
               EndIf 
            EndIf 
         Next 
         \pBalloon = #Null
         KillTimer_(\pWindow\hWindow, #TIMER_ShowBalloon)
         SetTimer_(\pWindow\hWindow, #TIMER_ShowBalloon, 0010, #Null) 
      EndIf 
   EndWith
   ProcedureReturn *pEventGadget
EndProcedure

;-
;- ======> [External Call] <======
;提示文初始化
Procedure Balloon_Initial(*pWindow.__WindowInfo, *pColors)
   ExamineDesktops()
   With _Balloon
      DesktopW       = DesktopWidth(0)
      \pWindow       = *pWindow
      \pColors       = *pColors
      \LayerImageID  = CreateImage(#PB_Any, DesktopW, 100)
   EndWith
EndProcedure

Procedure Balloon_ChangeStyle(*pColors)
   _Balloon\pColors = *pColors   
EndProcedure



;注销提示文
Procedure Balloon_Release()
   With _Balloon
      FreeMap(\pMapGadget())
      If IsImage(LayerImageID) 
         FreeImage(\LayerImageID) 
      EndIf 
   EndWith
EndProcedure

;创建提示文
Procedure Balloon_Gadget(GadgetID, BalloonTip$)
   _Balloon\pMapGadget(Str(GadgetID)) = GadgetID
   _Balloon\pMapGadget()\BalloonTip$ = BalloonTip$
EndProcedure

;激活窗体
Procedure Balloon_Active()
   With _Balloon
      KillTimer_(\pWindow\hWindow, #TIMER_ShowBalloon)      
      If \pBalloon = #Null Or \pBalloon\BalloonTip$ = #Null$
         If IsWindow(#winBalloon) 
            HideWindow(#winBalloon, #True)
         EndIf 
         \IsShowWindow = #False
         \pBalloon = #Null
         ProcedureReturn
      EndIf 
      \IsShowWindow = #True
      BackColor = \pColors\BackColor
      ForeColor = \pColors\ForeColor
      HighColor = \pColors\HighColor

      ;计算文本占用的最大宽度和最大高度
      If StartDrawing(ImageOutput(\LayerImageID))
         DrawingFont(FontID(\pWindow\Font12ID))
         TextW = TextWidth (\pBalloon\BalloonTip$) + 20
         TextH = TextHeight(\pBalloon\BalloonTip$) + 10
         StopDrawing()
      EndIf
      
      ;计算要显示的坐标位置
      GetCursorPos_(Mouse.POINT)
      Gadget.POINT
      Mouse\X + 20
      Mouse\Y + 20
      \WindowW = TextW
      \WindowH = TextH
      
      If IsWindow(#winBalloon) = #False
         \hWindow = OpenWindow(#winBalloon, 0, 0, 0, 0, "", #PB_Window_BorderLess, \pWindow\hWindow)
         HideWindow(#winBalloon, #True)
      EndIf       
      Balloon_RedrawScreen()
      ResizeWindow(#winBalloon, Mouse\X, Mouse\Y, \WindowW, \WindowH)
      SetActiveWindow(\pWindow\WindowID)
      HideWindow(#winBalloon, #False)
      SetActiveWindow(\pWindow\WindowID)
   EndWith
EndProcedure


;-
;- ######## [Test] ######## 
CompilerIf  #PB_Compiler_IsMainFile = #True
   #winScreen  = 1000
   #btnButton1 = 1001
   #btnButton2 = 1002
   #btnButton3 = 1003
   Color.__ColorInfo
   Color\BackColor = #Define_BackColor   
   Color\ForeColor = #Define_ForeColor
   Color\HighColor = #Define_HighColor
   Event.__EventInfo
   Window.__WindowInfo
   Window\Font12ID = LoadFont(#PB_Any, "宋体", 12)  
   Window\WindowH = 500
   Window\WindowW = 800
   Window\WindowID= #winScreen
   NewMap MapGadget.__GadgetInfo()
   ;======================
   WindowFlags = #PB_Window_SystemMenu|#PB_Window_MinimizeGadget|#PB_Window_ScreenCentered
   hWindow = OpenWindow(#winScreen, 0, 0, 500, 250, "Balloon-测试" , WindowFlags)
   ButtonGadget(#btnButton1, 200, 050, 100, 030, "提示文1")
   ButtonGadget(#btnButton2, 200, 100, 100, 030, "提示文2")
   ButtonGadget(#btnButton3, 200, 150, 100, 030, "提示文3")
   Window\hWindow = hWindow
   Balloon_Initial(@Window, @Color)
   For k = 0 To 2
      MapGadget(Str(#btnButton1+k)) 
      MapGadget()\GadgetID = #btnButton1+k 
      MapGadget()\X = 500+200 
      MapGadget()\Y = 035+050 * k
      MapGadget()\W = 100
      MapGadget()\H = 030
      MapGadget()\R = MapGadget()\X+MapGadget()\W
      MapGadget()\B = MapGadget()\Y+MapGadget()\H
      Balloon_Gadget(MapGadget(), "测试: 提示文"+Str(1+k))
   Next 
   ;======================
   Repeat
      WindowEvent = WindowEvent()
      Select WindowEvent
         Case #PB_Event_CloseWindow : IsExitWindow = #True
         Case #WM_LBUTTONDOWN : _Balloon\pBalloon = #Null : Balloon_Active()    
         Case #PB_Event_Gadget
            Select EventGadget()
               Case #btnButton1 : MapGadget(Str(#btnButton1)) : _Balloon\pBalloon = MapGadget() : Balloon_Active() 
               Case #btnButton2 : MapGadget(Str(#btnButton2)) : _Balloon\pBalloon = MapGadget() : Balloon_Active() 
               Case #btnButton3 : MapGadget(Str(#btnButton3)) : _Balloon\pBalloon = MapGadget() : Balloon_Active() 
            EndSelect
      EndSelect
   Until IsExitWindow = #True 
   FreeFont(Window\Font12ID)
   Balloon_Release()
   FreeMap(MapGadget())
   End
CompilerEndIf 














; IDE Options = PureBasic 5.62 (Windows - x86)
; CursorPosition = 153
; FirstLine = 91
; Folding = m9
; EnableXP
; Executable = DEMO.exe