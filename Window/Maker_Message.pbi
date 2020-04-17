;*****************************************
;******** 单片机仿真模拟器窗体界面 ********
;********    迷路仟 2020.02.24    ********
;*****************************************
;【Maker_Message.pbi】 信息对话框源代码

;-[Enumeration]
Enumeration Screen
   #winMessage          ;对话框编号
   #btnCloseBox         ;对话框关闭按键编号
   #btnMessageYes       ;对话框YES按键编号
   #btnMessageSure      ;对话框Sure按键编号
   #btnMessageOK        ;对话框OK按键编号
   #btnMessageNo        ;对话框NO按键编号
   #btnMessageCancel    ;对话框取消按键编号
EndEnumeration

;-[IncludeFile]
XIncludeFile ".\Maker_Define.pbi"      ;定义类源代码

;-[Structure]
;信息对话框结构
Structure __Message_MainInfo Extends __WindowInfo
   hMessageIcon.i
   TitleH.l
   NoticeH.l
   Flags.l
   Title$
   SystemPath$
   List ListText$()
   ;=========
   *pColors.__ColorInfo
   *pWindow.__WindowInfo
   ;=========
   btnCloseBox.__GadgetInfo
   btnMessageYes.__GadgetInfo
   btnMessageSure.__GadgetInfo
   btnMessageOK.__GadgetInfo
   btnMessageNo.__GadgetInfo
   btnMessageCancel.__GadgetInfo
   ;=========
   Events.__EventInfo
   ;=========
   IsExitWindow.b
   MessageResult.b
EndStructure

;-[Global]
Global _Message.__Message_MainInfo

;-
;- ******** [Redraw] ********
;绘制边框
Procedure Message_RedrawBorder()
   With _Message
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
Procedure Message_RedrawScreen()
   With _Message
      ;绘制与当前窗体与鼠标事件相关的界面
      If StartDrawing(ImageOutput(\LayerImageID))
         BackColor = \pColors\BackColor
         HighColor = \pColors\HighColor
         ForeColor = \pColors\ForeColor
         Message_RedrawBorder()

         ;绘制文本
         DrawingMode(#PB_2DDrawing_AlphaBlend|#PB_2DDrawing_Transparent)
         DrawingFont(FontID(\pWindow\Font12ID))
         DrawText(20, (\TitleH-TextHeight(\Title$)-8)/2, \Title$, BackColor)
         X = 40 : Y = \TitleH+20
         If \hMessageIcon
            X + 50 
            If \NoticeH < 50 : Y = \TitleH+10 + (50-\NoticeH)/2 : EndIf 
            DrawImage(\hMessageIcon, 40, \TitleH+(\WindowH-\TitleH-32-50)/2, 32, 32)
         EndIf 

         ForEach \ListText$()
            DrawText(X+0, Y+0, \ListText$(),ForeColor)
            Y + TextHeight(\ListText$()) + 5
         Next 
         
         ;绘制按键
         DrawingMode(#PB_2DDrawing_AlphaBlend) 
         ButtonX = \WindowW-1 - \btnCloseBox\W : ButtonY = 1  
         Define_RedrawGadget(\Events, \btnCloseBox, ButtonX, ButtonY)
         Define_RedrawGadget(\Events, \btnMessageYes)
         Define_RedrawGadget(\Events, \btnMessageSure)
         Define_RedrawGadget(\Events, \btnMessageOK)
         Define_RedrawGadget(\Events, \btnMessageNo)
         Define_RedrawGadget(\Events, \btnMessageCancel)
         DrawingMode(#PB_2DDrawing_AlphaBlend|#PB_2DDrawing_Outlined)
         StopDrawing()
      EndIf 

      ;将对话框图像渲染到窗体
      If \hLayerImage : DeleteObject_(\hLayerImage) : \hLayerImage = 0 : EndIf  ;释放窗体背景句柄
      \hLayerImage= CreatePatternBrush_(ImageID(\LayerImageID))
      If \hLayerImage
         SetClassLongPtr_(\hWindow, #GCL_HBRBACKGROUND, \hLayerImage)
         RedrawWindow_(\hWindow, #Null, #Null, #RDW_INTERNALPAINT|#RDW_ERASE|#RDW_INVALIDATE)
      EndIf 
   EndWith
EndProcedure

;-
;- ******** [Hook] ********
;光标在上事件[独立HOOK]
Procedure Message_Hook_MOUSEMOVE(*pMouse.POINTS)
   With _Message
      If *pMouse = 0   
      ElseIf Macro_Gadget_InRect3(\btnCloseBox)      : *pEventGadget = \btnCloseBox
      ElseIf Macro_Gadget_InRect3(\btnMessageYes)    : *pEventGadget = \btnMessageYes
      ElseIf Macro_Gadget_InRect3(\btnMessageSure)   : *pEventGadget = \btnMessageSure
      ElseIf Macro_Gadget_InRect3(\btnMessageOK)     : *pEventGadget = \btnMessageOK
      ElseIf Macro_Gadget_InRect3(\btnMessageNo)     : *pEventGadget = \btnMessageNo
      ElseIf Macro_Gadget_InRect3(\btnMessageCancel) : *pEventGadget = \btnMessageCancel
      EndIf 
      ;整理响应事件
      If \Events\pMouseTop <> *pEventGadget : \Events\pMouseTop = *pEventGadget : Message_RedrawScreen() : EndIf
   EndWith
EndProcedure

;左键按下事件[独立HOOK]
Procedure Message_Hook_LBUTTONDOWN(*pMouse.POINTS)
   With _Message
      If *pMouse = 0   
      ElseIf Macro_Gadget_InRect3(\btnCloseBox)      : *pEventGadget = \btnCloseBox
      ElseIf Macro_Gadget_InRect3(\btnMessageYes)    : *pEventGadget = \btnMessageYes
      ElseIf Macro_Gadget_InRect3(\btnMessageSure)   : *pEventGadget = \btnMessageSure
      ElseIf Macro_Gadget_InRect3(\btnMessageOK)     : *pEventGadget = \btnMessageOK
      ElseIf Macro_Gadget_InRect3(\btnMessageNo)     : *pEventGadget = \btnMessageNo
      ElseIf Macro_Gadget_InRect3(\btnMessageCancel) : *pEventGadget = \btnMessageCancel
      Else
         SendMessage_(\hWindow, #WM_NCLBUTTONDOWN, #HTCAPTION, 0)      
      EndIf 
      ;整理响应事件
      If \Events\pHoldDown <> *pEventGadget : \Events\pHoldDown = *pEventGadget : Message_RedrawScreen() : EndIf   
   EndWith
EndProcedure

;左键释放事件[独立HOOK]
Procedure Message_Hook_LBUTTONUP(*pMouse.POINTS)
   With _Message
      
      If *pMouse = 0   
      ElseIf Macro_Gadget_InRect3(\btnCloseBox) 
         If \Events\pHoldDown = \btnCloseBox
            *pEventGadget = \btnCloseBox
            PostEvent(#PB_Event_Gadget, #winMessage, #btnCloseBox)
         EndIf 
      ElseIf Macro_Gadget_InRect3(\btnMessageYes)
         If \Events\pHoldDown = \btnMessageYes
            *pEventGadget = \btnMessageYes
            PostEvent(#PB_Event_Gadget, #winMessage, #btnMessageYes)
         EndIf
      ElseIf Macro_Gadget_InRect3(\btnMessageSure)
         If \Events\pHoldDown = \btnMessageSure
            *pEventGadget = \btnMessageSure
            PostEvent(#PB_Event_Gadget, #winMessage, #btnMessageSure)
         EndIf         
         
      ElseIf Macro_Gadget_InRect3(\btnMessageOK)
         If \Events\pHoldDown = \btnMessageOK
            *pEventGadget = \btnMessageOK
            PostEvent(#PB_Event_Gadget, #winMessage, #btnMessageOK)
         EndIf         
      ElseIf Macro_Gadget_InRect3(\btnMessageNo)
         If \Events\pHoldDown = \btnMessageNo
            *pEventGadget = \btnMessageNo
            PostEvent(#PB_Event_Gadget, #winMessage, #btnMessageNo)
         EndIf
      ElseIf Macro_Gadget_InRect3(\btnMessageCancel)
         If \Events\pHoldDown = \btnMessageCancel
            *pEventGadget = \btnMessageCancel
            PostEvent(#PB_Event_Gadget, #winMessage, #btnMessageCancel)
         EndIf
      EndIf 
      ;整理响应事件
      If \Events\pHoldDown Or \Events\pHoldDown
         \Events\pHoldDown = 0 : \Events\pMouseTop = 0 : Message_RedrawScreen()
      EndIf   
   EndWith
EndProcedure

;挂钩事件[独立HOOK]
Procedure Message_Hook(hWindow, uMsg, wParam, lParam) 
   With _Message
      If \hWindow <> hWindow
         ProcedureReturn DefWindowProc_(hWindow, uMsg, wParam, lParam)
      EndIf
      Select uMsg
         Case #WM_MOUSEMOVE     : Message_Hook_MOUSEMOVE  (@lParam)
         Case #WM_LBUTTONDOWN   : Message_Hook_LBUTTONDOWN(@lParam)
         Case #WM_LBUTTONUP     : Message_Hook_LBUTTONUP  (@lParam)
      EndSelect 
      Result = CallWindowProc_(\hWindowHook, hWindow, uMsg, wParam, lParam)
   EndWith
   ProcedureReturn Result
EndProcedure

;-
;- ******** [Function] ********
;计算信息对话框位置
Procedure Message_Position()
   With _Message
      Select \Flags & $0F
         Case #PB_MessageRequester_YesNo
            \btnMessageSure\IsHide   = #False
            \btnMessageSure\X        = \WindowW/2-120
            \btnMessageSure\Y        = \WindowH-060
            \btnMessageSure\R        = \btnMessageSure\X+\btnMessageSure\W
            \btnMessageSure\B        = \btnMessageSure\Y+\btnMessageSure\H
            \btnMessageCancel\IsHide = #False
            \btnMessageCancel\X      = \WindowW/2+020
            \btnMessageCancel\Y      = \WindowH-060
            \btnMessageCancel\R      = \btnMessageCancel\X+\btnMessageCancel\W
            \btnMessageCancel\B      = \btnMessageCancel\Y+\btnMessageCancel\H
            \btnMessageYes\IsHide    = #True
            \btnMessageNo\IsHide     = #True
            \btnMessageOK\IsHide     = #True
         Case  #PB_MessageRequester_YesNoCancel
            \btnMessageYes\IsHide    = #False
            \btnMessageYes\X         = \WindowW/2-170
            \btnMessageYes\Y         = \WindowH-060
            \btnMessageYes\R         = \btnMessageYes\X+\btnMessageYes\W
            \btnMessageYes\B         = \btnMessageYes\Y+\btnMessageYes\H
            \btnMessageNo\IsHide     = #False
            \btnMessageNo\X          = \WindowW/2-050
            \btnMessageNo\Y          = \WindowH-060
            \btnMessageNo\R          = \btnMessageNo\X+\btnMessageNo\W
            \btnMessageNo\B          = \btnMessageNo\Y+\btnMessageNo\H
            \btnMessageCancel\IsHide = #False
            \btnMessageCancel\X      = \WindowW/2+070
            \btnMessageCancel\Y      = \WindowH-060  
            \btnMessageCancel\R      = \btnMessageCancel\X+\btnMessageCancel\W
            \btnMessageCancel\B      = \btnMessageCancel\Y+\btnMessageCancel\H
            \btnMessageSure\IsHide   = #True
            \btnMessageOK\IsHide     = #True
         Default
            \btnMessageOK\IsHide     = #False
            \btnMessageOK\X          = \WindowW/2-050
            \btnMessageOK\Y          = \WindowH-060
            \btnMessageOK\R          = \btnMessageOK\X+\btnMessageOK\W
            \btnMessageOK\B          = \btnMessageOK\Y+\btnMessageOK\H
            \btnMessageYes\IsHide    = #True
            \btnMessageNo\IsHide     = #True
            \btnMessageCancel\IsHide = #True       
            \btnMessageSure\IsHide   = #True
      EndSelect
   EndWith
EndProcedure

;计算信息对话框位置
Procedure Message_Calculate(Notice$, Flags)
   With _Message
      ;分割文本,并计算文本占用的最大宽度和最大高度
      ClearList(\ListText$())
      If StartDrawing(ImageOutput(\LayerImageID))
         DrawingFont(FontID(\pWindow\Font12ID))
         For k = 1 To CountString(Notice$, #LF$)+1
            LineText$ = StringField(Notice$, k, #LF$)
            TextW = TextWidth(LineText$)
            If W < TextW : W = TextW : EndIf 
            H + TextHeight(LineText$) + 5
            AddElement(\ListText$())
            \ListText$() = LineText$
         Next 
         StopDrawing()
      EndIf
      
      ;根据标志,定义按键名称及计算最小宽度
      Select Flags & $0F
         Case #PB_MessageRequester_YesNo        : MinW = 240 : Button1$ = "确认" : Button2$ = "取消"
         Case #PB_MessageRequester_YesNoCancel  : MinW = 340 : Button1$ = "是"   : Button2$ = "否"   : Button3$ = "取消"
         Default : MinW = 100 : Button1$ = "OK"
      EndSelect 
      Select Flags & $F0
         Case #PB_MessageRequester_Error    : W+50 : MinH = 50 : \hMessageIcon = ExtractIcon_(0, \SystemPath$, 3)
         Case $20                           : W+50 : MinH = 50 : \hMessageIcon = ExtractIcon_(0, \SystemPath$, 2)
         Case #PB_MessageRequester_Warning  : W+50 : MinH = 50 : \hMessageIcon = ExtractIcon_(0, \SystemPath$, 1)
         Case #PB_MessageRequester_Info     : W+50 : MinH = 50 : \hMessageIcon = ExtractIcon_(0, \SystemPath$, 4)
         Default : \hMessageIcon = 0  
      EndSelect 
      If W < MinW : W = MinW : EndIf
      If H < MinH : H = MinH : EndIf

      ;计算对话框的宽度和高度
      \TitleH = 38
      W = W + 40 + 40  
      H = H + \TitleH + 20 + 80  
      
      ;创建对话框窗体
      \WindowW = W
      \WindowH = H
   EndWith
EndProcedure
 

;-
;- ======> [External Call] <======
;信息对话框初始化
Procedure Message_Initial(*pWindow.__WindowInfo, *pColors)
   With _Message
      \SystemPath$  = Space(255)
      GetSystemDirectory_(@_Message\SystemPath$,255)
      \SystemPath$  + "\User32.dll"
      ExamineDesktops()
      DesktopW      = DesktopWidth(0)/2
      DesktopH      = DesktopHeight(0)/2
      \pWindow      = *pWindow
      \pColors      = *pColors
      \LayerImageID = CreateImage(#PB_Any, DesktopW, DesktopH)
      Define_CreateCloseBox(*pColors, \btnCloseBox)    ;创建关闭窗体小按键
      Define_CreateButton  (*pColors, \btnMessageYes,   0, 0, 100, 30, "是",   *pWindow\Font12ID)
      Define_CreateButton  (*pColors, \btnMessageNo,    0, 0, 100, 30, "否",   *pWindow\Font12ID)
      Define_CreateButton  (*pColors, \btnMessageCancel,0, 0, 100, 30, "取消", *pWindow\Font12ID)
      Define_CreateButton  (*pColors, \btnMessageSure,  0, 0, 100, 30, "确认", *pWindow\Font12ID)
      Define_CreateButton  (*pColors, \btnMessageOK,    0, 0, 100, 30, "OK",   *pWindow\Font12ID)
   EndWith
EndProcedure


Procedure Message_ChangeStyle(*pColors)
   With _Message
      \pColors      = *pColors
      Define_CreateCloseBox(*pColors, \btnCloseBox)    ;创建关闭窗体小按键
      Define_CreateButton  (*pColors, \btnMessageYes,   0, 0, 100, 30, "是",   \pWindow\Font12ID)
      Define_CreateButton  (*pColors, \btnMessageNo,    0, 0, 100, 30, "否",   \pWindow\Font12ID)
      Define_CreateButton  (*pColors, \btnMessageCancel,0, 0, 100, 30, "取消", \pWindow\Font12ID)
      Define_CreateButton  (*pColors, \btnMessageSure,  0, 0, 100, 30, "确认", \pWindow\Font12ID)
      Define_CreateButton  (*pColors, \btnMessageOK,    0, 0, 100, 30, "OK",   \pWindow\Font12ID)
   EndWith
EndProcedure

;注销信息对话框
Procedure Message_Release()
   With _Message
      FreeList(\ListText$())
      Define_FreeGadget(\btnCloseBox)
      Define_FreeGadget(\btnMessageYes)
      Define_FreeGadget(\btnMessageNo)
      Define_FreeGadget(\btnMessageCancel)
      Define_FreeGadget(\btnMessageSure)
      Define_FreeGadget(\btnMessageOK)
      If IsImage(\LayerImageID) 
         FreeImage(\LayerImageID)
      EndIf 
   EndWith
EndProcedure

;信息对话框初始化
Procedure Message_Requester(hParent, Title$, Notice$, Flags=#PB_MessageRequester_Ok, IsEnable=#True)
   With _Message
      Message_Calculate(Notice$, Flags)
      \Flags   = Flags
      \Title$  = Title$
      \IsExitWindow = #False      
      Message_Position()
      
      If hParent = #Null
         WindowFlags = #PB_Window_BorderLess|#PB_Window_ScreenCentered
         \hWindow = OpenWindow(#winMessage, 0, 0, \WindowW, \WindowH, "", WindowFlags)
      ElseIf IsZoomed_(hParent) Or IsIconic_(hParent) ;判断父窗体是否最大化和最小化
         WindowFlags = #PB_Window_BorderLess|#PB_Window_ScreenCentered
         \hWindow = OpenWindow(#winMessage, 0, 0, \WindowW, \WindowH, "", WindowFlags, hParent)
      Else 
         WindowFlags = #PB_Window_BorderLess|#PB_Window_WindowCentered
         \hWindow = OpenWindow(#winMessage, 0, 0, \WindowW, \WindowH, "", WindowFlags, hParent)
      EndIf
      Message_RedrawScreen()
      \hWindowHook = SetWindowLongPtr_(\hWindow, #GWL_WNDPROC, @Message_Hook()) 
      If IsEnable=#True And hParent
         EnableWindow_(hParent, #False)   ;禁用父窗体的响应动作
      EndIf 
      Repeat
         Select WindowEvent()
            Case #PB_Event_CloseWindow   : \IsExitWindow = #True
            Case #PB_Event_Gadget
               Select EventGadget()
                  Case #btnCloseBox      : \IsExitWindow = #True
                  Case #btnMessageYes    : \IsExitWindow = #True : Result = #PB_MessageRequester_Yes
                  Case #btnMessageSure   : \IsExitWindow = #True : Result = #PB_MessageRequester_Yes
                  Case #btnMessageOK     : \IsExitWindow = #True : Result = #PB_MessageRequester_Yes
                  Case #btnMessageNo     : \IsExitWindow = #True : Result = #PB_MessageRequester_No
                  Case #btnMessageCancel : \IsExitWindow = #True : Result = #PB_MessageRequester_Cancel
               EndSelect
            Default 
         EndSelect
      Until \IsExitWindow = #True 
      If \hLayerImage  ;释放窗体背景句柄
         DeleteObject_(\hLayerImage) 
         \hLayerImage = 0
      EndIf 
      CloseWindow(#winMessage)
      If IsEnable=#True And hParent
         EnableWindow_(hParent, #True)   ;恢复父窗体的响应动作
      EndIf 
      Delay(100)
   EndWith
   ProcedureReturn Result
EndProcedure

;-
;- ######## [Test] ######## 
CompilerIf  #PB_Compiler_IsMainFile = #True
   #winScreen = 1000
   Color.__ColorInfo
   Color\BackColor = #Define_BackColor   
   Color\ForeColor = #Define_ForeColor
   Color\HighColor = #Define_HighColor
   Window.__WindowInfo
   Window\Font12ID = LoadFont(#PB_Any, "宋体", 12)  
   ;======================
   WindowFlags = #PB_Window_SystemMenu|#PB_Window_MinimizeGadget|#PB_Window_ScreenCentered
   hWindow = OpenWindow(#winScreen, 0, 0, 500, 250, "Message-测试" , WindowFlags)
   Message_Initial(@Window, @Color)
   ;======================
   Repeat
      WindowEvent = WindowEvent()
      Select WindowEvent
         Case #PB_Event_CloseWindow : IsExitWindow = #True
         Case #WM_LBUTTONUP : Message_Requester(hWindow, "提示", "是否要退出软件!", #PB_MessageRequester_YesNo)
         Case #WM_RBUTTONUP : Message_Requester(hWindow, "提示", "是否要退出软件!", #PB_MessageRequester_YesNo)
      EndSelect
   Until IsExitWindow = #True 
   FreeFont(Window\Font12ID)   
   Message_Release()
   End
CompilerEndIf 














; IDE Options = PureBasic 5.62 (Windows - x86)
; CursorPosition = 355
; FirstLine = 160
; Folding = Pw+
; EnableXP
; Executable = DEMO.exe