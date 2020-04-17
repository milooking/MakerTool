;*******************************************************************
;********      此代码由[迷路PUB自绘UI生成工具]自动生成       ********
;********        源代码生成时间: 2020-02-17 23:23:08        ********
;********      工具为绿色免费开源,发现BUG,欢迎及时反馈       ********
;********        开发者: 迷路仟/Miloo [QQ:714095563]        ********
;*******************************************************************
;【源代码功能】:自动生成自绘窗体界面的源代码,节省开发时间.


;*****************************************
;******** 单片机仿真模拟器窗体界面 ********
;********    迷路仟 2020.02.24    ********
;*****************************************
;【Maker_Screen.pbi】 窗体界面布局源代码



;- [Include]
XIncludeFile ".\Maker_Define.pbi"      ;定义类源代码
XIncludeFile ".\Maker_Balloon.pbi"     ;控件提示文源代码
XIncludeFile ".\Maker_Message.pbi"     ;信息对话框源代码
XIncludeFile ".\Maker_MenuBar.pbi"     ;弹出菜单源代码
XIncludeFile ".\Maker_Caption.pbi"     ;标题栏源代码
XIncludeFile ".\Maker_ToolBar.pbi"     ;左侧工具栏源代码
XIncludeFile ".\Maker_Navigate.pbi"    ;导航条源代码
XIncludeFile ".\Maker_Discolor.pbi"    ;颜色修改对话框源代码
XIncludeFile ".\Maker_Editor.pbi"      ;对象修改对话框源代码
XIncludeFile ".\Maker_Dialog.pbi"      ;对象修改对话框源代码
XIncludeFile ".\Maker_Progress.pbi"    ;事件进度对话框源代码
XIncludeFile ".\Maker_PopupBar.pbi"    ;右键弹出工具栏源代码

;-[Enumeration]
Enumeration Screen
   #winScreen
EndEnumeration

#Screen_MinimumW = 650
#Screen_MinimumH = 500



;-[Structure]
;主界面结构
Structure __Screen_MainInfo Extends __WindowInfo
   WindowTitle$
   ;======   
   DesktopW.w
   DesktopH.w
   CanvasH.w
   CanvasW.w
   OffsetX.w
   OffsetY.w
   ScrollX.w
   ScrollY.w
   ;======
   hSizing.i         ;系统光标[左上-右下]
   hLeftRight.i      ;系统光标[左-右]
   hUpDown.i         ;系统光标[上-下]
   hEditing.i        ;系统光标[工字符]
   ;======
   btnCloseBox.__GadgetInfo   ;关闭窗体小按键
   btnMinimize.__GadgetInfo   ;最小化窗体小按键
   btnNormalcy.__GadgetInfo   ;正常化窗体小按键
   btnMaximize.__GadgetInfo   ;最大化窗体小按键
   btnSettings.__GadgetInfo   ;窗体设置小按键
   ;======
   DimColor.__ColorInfo[4]
   *pColor.__ColorInfo  
   
   Event.__EventInfo
   EventData.__EventDataInfo
   hCanvasImage.l
   NormalW.w
   NormalH.w
   ColorStyle.b
   DisplayGrid.b
   DisplayCoor.b
   Keep2.b
   ;======
   *pCallRedrawCanvas
   ;======
   
   IsKeyDownALT.b
   IsShowEditor.b
   IsExitWindow.b             ;关闭窗体条件
   IsSizeWindow.b             ;计时器用,窗体调整大小事件
EndStructure

;-[Global]
Global _Screen.__Screen_MainInfo

;-
;- ******** [Redraw] ********
;绘制窗体布局,即标题栏等四际.
Procedure Screen_RedrawBorder()
   DrawingMode(#PB_2DDrawing_AllChannels)
   ImageW = _Screen\WindowW
   ImageH = _Screen\WindowH
   ForeColor = _Screen\pColor\ForeColor
   HighColor = _Screen\pColor\HighColor
   PartH = (ImageH-90)/2
   
   ;前景色
   Box(000, 000, ImageW, 045, ForeColor)                   ;标题
   Box(000, 000, 004, ImageH, ForeColor)                   ;左侧
   Box(ImageW-4, 000, 004, ImageH, ForeColor)              ;右侧
   Box(000, ImageH-8, ImageW, 008, ForeColor)              ;底部         
   For k = 3 To 6
      Line(k, ImageH-100-5+k, 1, 150+3-k, ForeColor)       ;左侧
      Line(ImageW-k-1, 44, 1, 81-k, ForeColor)             ;右侧顶            
      Line(ImageW-k-1, PartH+k+38, 1, ImageH-PartH-k-38, ForeColor)   ;右侧底 
   Next   
      
   ;高亮色
   Box(000, 42, ImageW, 2, HighColor)                      ;标题
   Box(001, 44, 2, ImageH-100-44, HighColor)               ;左侧
   Box(004, ImageH-68, 2, 68, HighColor)                   ;左侧
   Box(ImageW-3, 44, 2, PartH, HighColor)                  ;右侧  
   Box(ImageW-6, PartH+75, 2, ImageH-PartH-75, HighColor)  ;右侧  
   Box(5, ImageH-7, ImageW-5, 2, HighColor)                ;底部  
   For k = 1 To 5
      Line(0, 36+k, 274+k, 1, HighColor)                   ;标题左侧
      Line(ImageW, 36+k, -166-k, 1, HighColor)             ;标题右侧
      Line(0, ImageH-109+k*7, 6, 6, HighColor)             ;左侧条纹 
      Line(0, ImageH-108+k*7, 6, 6, HighColor)             ;左侧条纹 
      Line(0, ImageH-107+k*7, 6, 6, HighColor)             ;左侧条纹 
      Line(ImageW-k-1, 44, 1, 80-k, HighColor)             ;右侧顶
      Line(ImageW-1, PartH+k*7+34, -6, 6, HighColor)       ;右侧条纹   
      Line(ImageW-1, PartH+k*7+35, -6, 6, HighColor)       ;右侧条纹 
      Line(ImageW-1, PartH+k*7+36, -6, 6, HighColor)       ;右侧条纹 
      Line(ImageW-6+k, ImageH-122+k, 1, 122-k, HighColor)  ;右侧底
      Line(5, ImageH-6+k, 200-k, 1, HighColor)             ;底部左侧  
      Line(ImageW-5, ImageH-6+k, -200+k, 1, HighColor)     ;底部右侧  
   Next 
   
   ;条纹色
   For k = 1 To 16
      Line(60+k*7, 38, 5, 5, ForeColor)                    ;标题左侧
      Line(61+k*7, 38, 5, 5, ForeColor)                    ;标题左侧 
      Line(62+k*7, 38, 5, 5, ForeColor)                    ;标题左侧 
      Line(40+k*7, ImageH-6, -4, 4, ForeColor)             ;底部左侧
      Line(41+k*7, ImageH-6, -4, 4, ForeColor)             ;底部左侧 
      Line(42+k*7, ImageH-6, -4, 4, ForeColor)             ;底部左侧 
      Line(ImageW-42-k*7, ImageH-6, 4, 4, ForeColor)       ;底部左侧
      Line(ImageW-41-k*7, ImageH-6, 4, 4, ForeColor)       ;底部右侧             
      Line(ImageW-40-k*7, ImageH-6, 4, 4, ForeColor)       ;底部右侧             
   Next
   ;四围
   DrawingMode(#PB_2DDrawing_Outlined)
   Box(000, 000, ImageW, ImageH, ForeColor)  
EndProcedure

;主界面自绘函数
Procedure Screen_RedrawScreen(IsCallEngine)
   With _Screen
      If \pCallRedrawCanvas And IsCallEngine = #True
         hIamge = CallFunctionFast(\pCallRedrawCanvas, _Screen)
         If hIamge
            \hCanvasImage = hIamge
         EndIf 
      EndIf 

      If StartDrawing(ImageOutput(\LayerImageID))
         ;背景色
         Box(000, 000, \DesktopW, \DesktopH, \pColor\BackColor & $FFFFFF) 
         If \hCanvasImage
            DrawAlphaImage(\hCanvasImage, \OffsetX+\ScrollX, \OffsetY+\ScrollY)
         EndIf  
         Navigate_RedrawScreen()
         ToolBar_RedrawScreen()
         PopupBar_RedrawScreen()
         DrawingMode(#PB_2DDrawing_Transparent) 
         ;绘制系统小按键
         Screen_RedrawBorder()
         ButtonX = \WindowW-1-\btnCloseBox\W
         Define_RedrawGadget(\Event, \btnCloseBox, ButtonX, 1)
         ButtonX = ButtonX-1-\btnNormalcy\W
         Define_RedrawGadget(\Event, \btnNormalcy, ButtonX, 1)
         Define_RedrawGadget(\Event, \btnMaximize, ButtonX, 1)
         ButtonX = ButtonX-1-\btnMinimize\W
         Define_RedrawGadget(\Event, \btnMinimize, ButtonX, 1)
         ButtonX = ButtonX-1-\btnSettings\W
         Define_RedrawGadget(\Event, \btnSettings, ButtonX, 1)
         Caption_RedrawScreen()
         StopDrawing()
      EndIf         
      If \hLayerImage : DeleteObject_(\hLayerImage) : \hLayerImage = 0 : EndIf  ;释放窗体背景句柄
      ;将背景图像渲染到窗体
      \hLayerImage= CreatePatternBrush_(ImageID(\LayerImageID))
      If \hLayerImage
         SetClassLongPtr_(\hWindow, #GCL_HBRBACKGROUND, \hLayerImage)
         RedrawWindow_(\hWindow, #Null, #Null, #RDW_UPDATENOW|#RDW_ERASE|#RDW_INVALIDATE)
      EndIf 
   EndWith
EndProcedure  

;-
;- ******** [Hook] ********
;光标在上事件[Main Hook]
Procedure Screen_Hook_MOUSEMOVE(*pMouse.POINTS, Button)
   With _Screen
      ;判断是否存在[工具栏]事件
      If \Event\pMoving = #False
;          *pEventGadget = ToolBar_Hook_MOUSEMOVE(*pMouse, Button) 
         *pEventGadget = PopupBar_Hook_MOUSEMOVE(*pMouse, Button) 
      EndIf 
      ;判断是否存在[标题栏]事件
      If *pEventGadget = #Null And \Event\pMoving = #False
         *pEventGadget = Caption_Hook_MOUSEMOVE(*pMouse)
      EndIf          
      
      ;判断是否存在[导航条]事件
      If *pEventGadget = #Null : 
         *pEventGadget = Navigate_Hook_MOUSEMOVE(*pMouse)
         IsRefresh = Navigate_RefreshState()
      EndIf 
      
      If *pEventGadget = #Null And \Event\pMoving = #False
         If     Macro_Gadget_InRect1(\btnCloseBox)  : *pEventGadget = \btnCloseBox
         ElseIf Macro_Gadget_InRect1(\btnMinimize)  : *pEventGadget = \btnMinimize
         ElseIf Macro_Gadget_InRect2(\btnNormalcy)  : *pEventGadget = \btnNormalcy
         ElseIf Macro_Gadget_InRect2(\btnMaximize)  : *pEventGadget = \btnMaximize
         ElseIf Macro_Gadget_InRect1(\btnSettings)  : *pEventGadget = \btnSettings
         ElseIf *pMouse\X >= \WindowW-25 And *pMouse\Y >= \WindowH-25 : SetCursor_(\hSizing)
         ElseIf *pMouse\X <= #WinSideL Or *pMouse\X >= \WindowW-#WinSideR : SetCursor_(\hLeftRight)
         ElseIf *pMouse\Y <= #WinSideT Or *pMouse\Y >= \WindowH-#WinSideB : SetCursor_(\hUpDown)
         EndIf 
      EndIf 
      If \Event\pMoving = #False
         Balloon_Hook_MOUSEMOVE(*pEventGadget)
      EndIf

      ;整理响应事件
      If \Event\pMouseTop <> *pEventGadget 
         \Event\pMouseTop = *pEventGadget
         Screen_RedrawScreen(#False) 
      Else 
         If IsRefresh : Screen_RedrawScreen(#False) : EndIf 
         \EventData\MouseX = *pMouse\X
         \EventData\MouseY = *pMouse\Y
         \EventData\Button = Button
         PostEvent(#PB_Event_Gadget, #winScreen, #winScreen, #PB_EventType_MouseMove, \EventData)
      EndIf
   EndWith
   ProcedureReturn
EndProcedure

;计时器事件[Main Hook]
Procedure Screen_Hook_TIMER(wParam)
   With _Screen
      Select wParam
         Case #TIMER_SizeWindow
            \WindowW = WindowWidth (\WindowID)
            \WindowH = WindowHeight(\WindowID)
            \IsSizeWindow = #True
            Screen_RedrawScreen(#True)
            PostEvent(#PB_Event_SizeWindow)
         Case #TIMER_ShowBalloon
            Balloon_Active()     
      EndSelect
   EndWith
   ProcedureReturn Result
EndProcedure

;-
;左键按下事件[Main Hook]
Procedure Screen_Hook_LBUTTONDOWN(*pMouse.POINTS, Button)
   With _Screen
      If _Balloon\pBalloon
         _Balloon\pBalloon = #Null
         KillTimer_(\hWindow, #TIMER_ShowBalloon)
         SetTimer_(\hWindow, #TIMER_ShowBalloon, 0010, #Null)
      EndIf
      
      ;判断是否存在[工具栏]事件
      If \Event\pMoving = #False
;          *pEventGadget = ToolBar_Hook_LBUTTONDOWN(*pMouse)
         *pEventGadget = PopupBar_Hook_LBUTTONDOWN(*pMouse)
      EndIf 
      
      ;判断是否存在[标题栏]事件
      If *pEventGadget = #Null And \Event\pMoving = #False
         PopupBar_Display()
         MenuBar_Display()
         *pEventGadget = Caption_Hook_LBUTTONDOWN(*pMouse)
      EndIf   
      
      ;判断是否存在[导航条]事件
      If *pEventGadget = #Null
         *pEventGadget = Navigate_Hook_LBUTTONDOWN(*pMouse)
         IsRefresh = Navigate_RefreshState()
      EndIf 
    
      If *pEventGadget = #Null And \Event\pMoving = #False
         PopupBar_Display()
         MenuBar_Display()
         If     Macro_Gadget_InRect1(\btnCloseBox)   : *pEventGadget = \btnCloseBox
         ElseIf Macro_Gadget_InRect1(\btnMinimize)  : *pEventGadget = \btnMinimize
         ElseIf Macro_Gadget_InRect2(\btnNormalcy)  : *pEventGadget = \btnNormalcy
         ElseIf Macro_Gadget_InRect2(\btnMaximize)  : *pEventGadget = \btnMaximize
         ElseIf Macro_Gadget_InRect1(\btnSettings)  : *pEventGadget = \btnSettings
         ElseIf *pMouse\X >= \WindowW-25 And *pMouse\Y >= \WindowH-25
            SetCursor_(\hSizing)       
            KillTimer_(\hWindow, #TIMER_SizeWindow)
            SetTimer_ (\hWindow, #TIMER_SizeWindow, 10, #Null) 
            SendMessage_(\hWindow, #WM_NCLBUTTONDOWN, #HTBOTTOMRIGHT, #True)
            ProcedureReturn #True
   
         ElseIf *pMouse\X <= #WinSideL 
            SetCursor_(\hLeftRight)
            KillTimer_(\hWindow, #TIMER_SizeWindow)
            SetTimer_ (\hWindow, #TIMER_SizeWindow, 10, #Null) 
            SendMessage_(\hWindow, #WM_NCLBUTTONDOWN, #HTLEFT, #True)
            ProcedureReturn #True
   
         ElseIf *pMouse\X >= \WindowW-#WinSideR 
            SetCursor_(\hLeftRight)
            KillTimer_(\hWindow, #TIMER_SizeWindow)
            SetTimer_ (\hWindow, #TIMER_SizeWindow, 10, #Null) 
            SendMessage_(\hWindow, #WM_NCLBUTTONDOWN, #HTRIGHT, #True)
            ProcedureReturn #True
   
         ElseIf *pMouse\Y <= #WinSideT
            SetCursor_(\hUpDown)
            KillTimer_(\hWindow, #TIMER_SizeWindow)
            SetTimer_ (\hWindow, #TIMER_SizeWindow, 10, #Null) 
            SendMessage_(\hWindow, #WM_NCLBUTTONDOWN, #HTTOP, #True)
            ProcedureReturn #True
   
         ElseIf *pMouse\Y >= \WindowH-#WinSideB
            SetCursor_(\hUpDown)
            KillTimer_(\hWindow, #TIMER_SizeWindow)
            SetTimer_ (\hWindow, #TIMER_SizeWindow, 10, #Null) 
            SendMessage_(\hWindow, #WM_NCLBUTTONDOWN, #HTBOTTOM, #True)
            ProcedureReturn #True
         ElseIf *pMouse\Y  <= 45 Or *pMouse\X < 55
            SendMessage_(\hWindow, #WM_NCLBUTTONDOWN, #HTCAPTION, 0)
         EndIf
         
      EndIf 
      
      ;整理响应事件
      If \Event\pHoldDown <> *pEventGadget 
         \Event\pHoldDown = *pEventGadget
         Screen_RedrawScreen(#False)
      Else 

         If IsRefresh = #True : Screen_RedrawScreen(#False) : EndIf 
         \EventData\MouseX = *pMouse\X
         \EventData\MouseY = *pMouse\Y
         If \IsKeyDownALT = #True
            \EventData\Button = #PB_Canvas_Alt
         ElseIf Button = 9 
            \EventData\Button = #PB_Canvas_Control
         EndIf 
         PostEvent(#PB_Event_Gadget, #winScreen, #winScreen, #PB_EventType_LeftButtonDown, \EventData)
      EndIf
      
   EndWith
   ProcedureReturn
EndProcedure

;左键释放事件[Main Hook]
Procedure Screen_Hook_LBUTTONUP(*pMouse.POINTS, Button)
   With _Screen
      If _Balloon\pBalloon
         _Balloon\pBalloon = #Null
         KillTimer_(hWindow, #TIMER_ShowBalloon)
         SetTimer_(\hWindow, #TIMER_ShowBalloon, 0010, #Null)
      EndIf
      \Event\pMoving = #False
      
      ;判断是否存在[工具栏]事件
;       *pEventGadget = ToolBar_Hook_LBUTTONUP(*pMouse)
      *pEventGadget = PopupBar_Hook_LBUTTONUP(*pMouse)
     
      ;判断是否存在[标题栏]事件
      If *pEventGadget = #Null : 
         *pEventGadget = Caption_Hook_LBUTTONUP(*pMouse)
      EndIf     
      
      ;判断是否存在[导航条]事件
      If *pEventGadget = #Null : 
         *pEventGadget = Navigate_Hook_LBUTTONUP(*pMouse)
         IsRefresh = Navigate_RefreshState()
      EndIf 
   
      If *pEventGadget = #Null 
         If Macro_Gadget_InRect1(\btnCloseBox) 
            *pEventGadget = \btnCloseBox 
            If \Event\pHoldDown = \btnCloseBox : PostEvent(#PB_Event_CloseWindow) : EndIf
         ElseIf Macro_Gadget_InRect1(\btnMinimize)
            *pEventGadget = \btnMinimize
            \NormalW = WindowWidth (#winScreen)
            \NormalH = WindowHeight(#winScreen)
            If \Event\pHoldDown = \btnMinimize : ShowWindow_(\hWindow, 2) : EndIf    ;最小化窗体
         ElseIf Macro_Gadget_InRect2(\btnMaximize)
            If \Event\pHoldDown = \btnMaximize
               \btnNormalcy\IsHide = #False
               \btnMaximize\IsHide = #True
               \NormalW = WindowWidth (#winScreen)
               \NormalH = WindowHeight(#winScreen)
               SystemParametersInfo_(#SPI_GETWORKAREA, 0, RECT.RECT, 0)    ;获取桌面屏幕大小
               \WindowW = RECT\right-RECT\left+2
               \WindowH = RECT\bottom-RECT\top
               Screen_RedrawScreen(#True)
               ShowWindow_(\hWindow, 3)       ;最大化窗体
               MoveWindow_(\hWindow, 0, 0, \WindowW, \WindowH, #True)
               \Event\pHoldDown = 0 : \Event\pMouseTop = 0 : Screen_RedrawScreen(#True)
               ProcedureReturn
            EndIf 
         ElseIf Macro_Gadget_InRect2(\btnNormalcy)
            If \Event\pHoldDown = \btnNormalcy
               \btnNormalcy\IsHide = #True
               \btnMaximize\IsHide = #False
               ShowWindow_(\hWindow,1)       ;正常化窗体
               \Event\pHoldDown = 0
               \WindowW = WindowWidth(\WindowID)
               \WindowH = WindowHeight(\WindowID)
               \Event\pHoldDown = 0 : \Event\pMouseTop = 0 : Screen_RedrawScreen(#True)
               ProcedureReturn
            EndIf 
         ElseIf Macro_Gadget_InRect1(\btnSettings)
            *pEventGadget = \btnSettings
            If \Event\pHoldDown = \btnSettings : PostEvent(#PB_Event_Gadget, \WindowID, #wmiSettings) : EndIf
         EndIf 
      EndIf 
      ;整理响应事件
      If \Event\pHoldDown Or \Event\pMouseTop
         \Event\pHoldDown = 0 
         \Event\pMouseTop = 0 
         Screen_RedrawScreen(#False) 
      Else 
         If IsRefresh = #True : Screen_RedrawScreen(#False) : EndIf 
         \EventData\MouseX = *pMouse\X
         \EventData\MouseY = *pMouse\Y
         \EventData\Button = Button
         PostEvent(#PB_Event_Gadget, #winScreen, #winScreen, #PB_EventType_LeftButtonUp, \EventData)
      EndIf
   EndWith
   ProcedureReturn
EndProcedure

;左键双击事件[Main Hook]
Procedure Screen_Hook_LBUTTONDBLCLK(*pMouse.POINTS, Button)
   With _Screen
      Result = Caption_Hook_LBUTTONDBLCLK(*pMouse)
      If Result : ProcedureReturn Result : EndIf 
      If *pMouse\Y < #CaptionH
         If \btnNormalcy\IsHide = #True
            \btnNormalcy\IsHide = #False
            \btnMaximize\IsHide = #True
            SystemParametersInfo_(#SPI_GETWORKAREA, 0, RECT.RECT, 0)    ;获取桌面屏幕大小
            \WindowW = RECT\right-RECT\left+2
            \WindowH = RECT\bottom-RECT\top
            Screen_RedrawScreen(#True)
            ShowWindow_(\hWindow, 3)       ;最大化窗体
            MoveWindow_(\hWindow, 0, 0, \WindowW, \WindowH, #True)
            \Event\pHoldDown = 0 : \Event\pMouseTop = 0 : Screen_RedrawScreen(#True)
         Else 
            \btnNormalcy\IsHide = #True
            \btnMaximize\IsHide = #False
            ShowWindow_(\hWindow,1)       ;正常化窗体
            \Event\pHoldDown = 0
            \WindowW = WindowWidth (_Screen\WindowID)
            \WindowH = WindowHeight(_Screen\WindowID)
            \Event\pHoldDown = 0 : \Event\pMouseTop = 0 : Screen_RedrawScreen(#True)
         EndIf 
      Else 
         \EventData\MouseX = *pMouse\X
         \EventData\MouseY = *pMouse\Y
         \EventData\Button = Button
         PostEvent(#PB_Event_Gadget, #winScreen, #winScreen, #PB_EventType_LeftDoubleClick, \EventData)
      EndIf
   EndWith
   ProcedureReturn Result
EndProcedure

;-
;右键按下事件[Main Hook]
Procedure Screen_Hook_RBUTTONDOWN(*pMouse.POINTS, Button)
   With _Screen
      If MenuBar_Display()
         ProcedureReturn #True 
      EndIf 
      \EventData\MouseX = *pMouse\X
      \EventData\MouseY = *pMouse\Y
      \EventData\Button = Button
      PostEvent(#PB_Event_Gadget, #winScreen, #winScreen, #PB_EventType_RightButtonDown, \EventData)  
   EndWith 
EndProcedure

;右键释放事件[Main Hook]
Procedure Screen_Hook_RBUTTONUP(*pMouse.POINTS, Button)
   With _Screen
      \EventData\MouseX = *pMouse\X
      \EventData\MouseY = *pMouse\Y
      \EventData\Button = Button
      PopupBar_Display()
      PostEvent(#PB_Event_Gadget, #winScreen, #winScreen, #PB_EventType_RightButtonUp, \EventData)  
   EndWith 
EndProcedure

;右键双击事件[Main Hook]
Procedure Screen_Hook_RBUTTONDBLCLK(*pMouse.POINTS, Button)
   With _Screen
      \EventData\MouseX = *pMouse\X
      \EventData\MouseY = *pMouse\Y
      \EventData\Button = Button
      PostEvent(#PB_Event_Gadget, #winScreen, #winScreen, #PB_EventType_RightDoubleClick, \EventData)  
   EndWith 
EndProcedure

Procedure Screen_Hook_KEYDOWN(lParam, wParam)
   If lParam & $FFFFFF = $1D0001 : ProcedureReturn : EndIf 
   _Screen\EventData\Button = wParam
   PostEvent(#PB_Event_Gadget, #winScreen, #winScreen, #PB_EventType_KeyDown, _Screen\EventData)  
   ProcedureReturn #True
EndProcedure

;-
;挂钩事件
Procedure Screen_HookWindow(hWindow, uMsg, wParam, lParam) 
   With _Screen
      If \hWindow <> hWindow
         ProcedureReturn DefWindowProc_(hWindow, uMsg, wParam, lParam)
      EndIf
            
      Select uMsg 
         Case #WM_LBUTTONDOWN   : Result = Screen_Hook_LBUTTONDOWN  (@lParam, wParam)
         Case #WM_LBUTTONUP     : Result = Screen_Hook_LBUTTONUP    (@lParam, wParam)
         Case #WM_LBUTTONDBLCLK : Result = Screen_Hook_LBUTTONDBLCLK(@lParam, wParam)
         Case #WM_RBUTTONDOWN   : Result = Screen_Hook_RBUTTONDOWN  (@lParam, wParam)
         Case #WM_RBUTTONUP     : Result = Screen_Hook_RBUTTONUP    (@lParam, wParam)
         Case #WM_RBUTTONDBLCLK : Result = Screen_Hook_RBUTTONDBLCLK(@lParam, wParam)   
         Case #WM_MOUSEMOVE     : Result = Screen_Hook_MOUSEMOVE    (@lParam, wParam)
         Case #WM_KEYDOWN       : Result = Screen_Hook_KEYDOWN      (lParam, wParam) 
         Case #WM_SYSKEYDOWN    : \IsKeyDownALT = #True
         Case #WM_SYSKEYUP      : \IsKeyDownALT = #False      
         Case #WM_TIMER         : Result = Screen_Hook_TIMER        (wParam)
         Case #WM_SIZE
            If wParam = 0 And \btnMaximize\IsHide = #True
               \btnNormalcy\IsHide = #True
               \btnMaximize\IsHide = #False
            EndIf
            SetTimer_ (\hWindow, #TIMER_SizeWindow, 10, #Null)
      EndSelect 
      If Result = 0 
         Result = CallWindowProc_(\hWindowHook, hWindow, uMsg, wParam, lParam) 
      EndIf
   EndWith
   ProcedureReturn Result
EndProcedure

;-
;- ======> [Create] <======

;创建主界面窗体
Procedure Screen_CreateWindow()
   With _Screen 
      Define_CreateCloseBox(\pColor, \btnCloseBox)    ;创建关闭窗体小按键
      Define_CreateMinimize(\pColor, \btnMinimize)    ;最小化窗体小按键
      Define_CreateNormalcy(\pColor, \btnNormalcy)    ;正常化窗体小按键
      Define_CreateMaximize(\pColor, \btnMaximize)    ;最大化窗体小按键
      Define_CreateSettings(\pColor, \btnSettings)    ;窗体设置小按键
      Balloon_Gadget(\btnCloseBox, "关闭窗体")
      Balloon_Gadget(\btnMinimize, "最小化窗体")
      Balloon_Gadget(\btnNormalcy, "窗体正常化")
      Balloon_Gadget(\btnMaximize, "最大化窗体")
      Balloon_Gadget(\btnSettings, "软件设置")
      \hWindowHook = SetWindowLongPtr_(\hWindow, #GWL_WNDPROC, @Screen_HookWindow())
      Screen_RedrawScreen(#True)   
   EndWith  
EndProcedure

;加载设置
Procedure Screen_LoadPrefer(PreferName$)
   With _Screen
      OpenPreferences(PreferName$)
      PreferenceGroup("窗体设置")
         \WindowX = ReadPreferenceLong("WindowX", 0)
         \WindowY = ReadPreferenceLong("WindowY", 0)
         \WindowW = ReadPreferenceLong("WindowW", 1024)
         \WindowH = ReadPreferenceLong("WindowH", 768)
         \ColorStyle = ReadPreferenceLong("窗体风格", 0)

      PreferenceGroup("导航条设置")
         \NaviOffsetX   = ReadPreferenceLong("OffsetX",   005)
         \NaviOffsetY   = ReadPreferenceLong("OffsetY",   050)
         \NaviOffsetR   = ReadPreferenceLong("OffsetR",   000)
         \NaviOffsetB   = ReadPreferenceLong("OffsetB",   010)
         \IsNaviLockedR = ReadPreferenceLong("IsLockedR", 0)
         \IsNaviLockedB = ReadPreferenceLong("IsLockedB", 1)
         
      PreferenceGroup("颜色设置")
         For k = 1 To 32
            _DimColorTable(k+7)\Color = ReadPreferenceLong("颜色-"+Str(k), -1)
         Next 
      ClosePreferences()
   EndWith
EndProcedure

;保存设置
Procedure Screen_SavePrefer(PreferName$)
   With _Screen
      If CreatePreferences(PreferName$)
         PreferenceComment("***************************************")
         PreferenceComment("****　　有思鹿单片机仿真模拟器　　*****")
         PreferenceComment("***************************************")
         PreferenceComment("")
         PreferenceGroup("窗体设置")
            If IsWindow(#winScreen) And GetWindowState(#winScreen) <> #PB_Window_Normal
               WritePreferenceLong("WindowX", \WindowX)
               WritePreferenceLong("WindowY", \WindowY)
               WritePreferenceLong("WindowW", \NormalW)
               WritePreferenceLong("WindowH", \NormalH)
            Else 
               WritePreferenceLong("WindowX", WindowX(#winScreen))
               WritePreferenceLong("WindowY", WindowY(#winScreen))
               WritePreferenceLong("WindowW", WindowWidth(#winScreen))
               WritePreferenceLong("WindowH", WindowHeight(#winScreen))
            EndIf 
            WritePreferenceLong("窗体风格", \ColorStyle)
            
         PreferenceComment("")
         PreferenceGroup("导航条设置")  
            WritePreferenceLong("OffsetX",   \NaviOffsetX)
            WritePreferenceLong("OffsetY",   \NaviOffsetY)
            WritePreferenceLong("OffsetR",   \NaviOffsetR)
            WritePreferenceLong("OffsetB",   \NaviOffsetB)
            WritePreferenceLong("IsLockedR", \IsNaviLockedR)
            WritePreferenceLong("IsLockedB", \IsNaviLockedB)
            
         PreferenceComment("")
         PreferenceGroup("颜色设置")
         For k = 1 To 32
            WritePreferenceLong("颜色-"+Str(k),   _DimColorTable(k+7)\Color)
         Next 
         ClosePreferences()
      EndIf
   EndWith
EndProcedure


;-
;- ======> [External Call] <======

; 空事件处理[主程必须]
Procedure Screen_EventWindow_Null()
   If _Screen\Event\pMouseTop Or _Screen\Event\pHoldDown
      GetCursorPos_(@Mouse.q) ;光标移境时,取消相应事件. 
      If WindowFromPoint_(Mouse) <> _Screen\hWindow
         _Screen\Event\pMouseTop = 0
         _Screen\Event\pHoldDown = 0 
         Screen_RedrawScreen(#False)
      EndIf 
   EndIf  
EndProcedure

;延时事件[主程必须]
Procedure Screen_EventWindow_Delay()
   If _Screen\IsSizeWindow = #True 
      KillTimer_(_Screen\hWindow, #TIMER_SizeWindow) 
      _Screen\IsSizeWindow = #False
   EndIf 
   Delay(1)   
EndProcedure

;主界面初始化
Procedure Screen_Initail()
   With _Screen 
      ExamineDesktops()
      UsePNGImageDecoder()
      Screen_LoadPrefer(".\设置.ini")
      \DesktopW        = DesktopWidth(0)
      \DesktopH        = DesktopHeight(0)
      
      \DimColor[#ViewStlye_Black]\BackColor = #Black_BackColor   
      \DimColor[#ViewStlye_Black]\ForeColor = #Black_ForeColor
      \DimColor[#ViewStlye_Black]\HighColor = #Black_HighColor
      
      \DimColor[#ViewStlye_Green]\BackColor = #Green_BackColor   
      \DimColor[#ViewStlye_Green]\ForeColor = #Green_ForeColor
      \DimColor[#ViewStlye_Green]\HighColor = #Green_HighColor

      \DimColor[#ViewStlye_Blue]\BackColor = #Blue_BackColor   
      \DimColor[#ViewStlye_Blue]\ForeColor = #Blue_ForeColor
      \DimColor[#ViewStlye_Blue]\HighColor = #Blue_HighColor
      
      \DimColor[#ViewStlye_Red]\BackColor = #Red_BackColor   
      \DimColor[#ViewStlye_Red]\ForeColor = #Red_ForeColor
      \DimColor[#ViewStlye_Red]\HighColor = #Red_HighColor      
      
      \pColor = \DimColor[\ColorStyle]  

      
      \hSizing       = LoadCursor_(0,#IDC_SIZENWSE) ;获取系统光标[左上-右下]
      \hLeftRight    = LoadCursor_(0,#IDC_SIZEWE)   ;获取系统光标[左-右]
      \hUpDown       = LoadCursor_(0,#IDC_SIZENS)   ;获取系统光标[上-下]
      \hEditing      = LoadCursor_(0,#IDC_IBEAM)    ;获取系统光标[工字符]
      \ResourIconID  = CatchImage(#PB_Any, ?_ICON_Resources)
      \LayerImageID  = CreateImage(#PB_Any, \DesktopW, \DesktopH)
      \Font12ID      = LoadFont(#PB_Any, "宋体", 12)
      \Font09ID      = LoadFont(#PB_Any, "宋体", 09)
      ;=====================
      _DimColorTable(0)\Color = $0080F0
      _DimColorTable(1)\Color = $0000C0
      _DimColorTable(2)\Color = $00C000
      _DimColorTable(3)\Color = $C00000
      ;=====================
      If \WindowW < #Screen_MinimumW :  \WindowW = 1024 : EndIf 
      If \WindowH < #Screen_MinimumH :  \WindowH = 0768 : EndIf 
      \WindowTitle$ = "有思鹿单片机仿真模拟器" 
      \WindowID     = #winScreen
      If \WindowX <= 0 Or \WindowY <= 0 
         \hWindow = OpenWindow(#winScreen, 0, 0, \WindowW, \WindowH, \WindowTitle$, #PB_Window_BorderLess|#PB_Window_ScreenCentered)
         \WindowX = WindowX(#winScreen)
         \WindowY = WindowY(#winScreen)
      Else 
         \hWindow = OpenWindow(#winScreen, \WindowX, \WindowY, \WindowW, \WindowH, \WindowTitle$, #PB_Window_BorderLess)
      EndIf 
      WindowBounds(#winScreen, #Screen_MinimumW, #Screen_MinimumH, #PB_Ignore, #PB_Ignore) 
      Balloon_Initial (_Screen, \pColor)
      Message_Initial (_Screen, \pColor)
      Discolor_Initial(_Screen, \pColor)
      Navigate_Initial(_Screen, \pColor, \Event)  
      ToolBar_Initial (_Screen, \pColor, \Event)
      Caption_Initial (_Screen, \pColor, \Event)
      MenuBar_Initial (_Screen, \pColor)
      Editor_Initial  (_Screen, \pColor)
      Dialog_Initial  (_Screen, \pColor)
      Progress_Initial(_Screen, \pColor)
      PopupBar_Initial(_Screen, \pColor, \Event)
      Screen_CreateWindow()
      MenuBar_SetItemState(#MenuBarID_View, #wmiStyleBlack+\ColorStyle, #True)
      DragAcceptFiles_(\hWindow, #True)   ;设置窗体界面是否支持系统拖放.
      ProcedureReturn _Screen
   EndWith
EndProcedure


;更换风格
Procedure Screen_ChangeStyle(ViewStlye)
   With _Screen   
      \ColorStyle = ViewStlye % 4
      \pColor = \DimColor[\ColorStyle] 
      
      For k = 0 To 4
         If \ColorStyle = k
            MenuBar_SetItemState(#MenuBarID_View, #wmiStyleBlack+k, #True)
         Else
            MenuBar_SetItemState(#MenuBarID_View, #wmiStyleBlack+k, #False)
         EndIf 
      Next 
      Define_CreateCloseBox(\pColor, \btnCloseBox)    ;创建关闭窗体小按键
      Define_CreateMinimize(\pColor, \btnMinimize)    ;最小化窗体小按键
      Define_CreateNormalcy(\pColor, \btnNormalcy)    ;正常化窗体小按键
      Define_CreateMaximize(\pColor, \btnMaximize)    ;最大化窗体小按键
      Define_CreateSettings(\pColor, \btnSettings)    ;窗体设置小按键
      Balloon_ChangeStyle (\pColor)
      Message_ChangeStyle (\pColor)
      Discolor_ChangeStyle(\pColor)
      Navigate_ChangeStyle(\pColor)  
      ToolBar_ChangeStyle (\pColor)
      Caption_ChangeStyle (\pColor)
      MenuBar_ChangeStyle (\pColor)
      Editor_ChangeStyle  (\pColor)
      Dialog_ChangeStyle  (\pColor)
      Progress_ChangeStyle(\pColor)
      PopupBar_ChangeStyle(\pColor)
      
      Screen_RedrawScreen(#False) 
   EndWith
EndProcedure

;注销主界面窗体
Procedure Screen_Release()
   Screen_SavePrefer(".\设置.ini")
   With _Screen
      FreeFont(\Font12ID)                 ;注销字体
      FreeFont(\Font09ID)                 ;注销字体
      DestroyCursor_(\hSizing)            ;注销系统光标[左上-右下]
      DestroyCursor_(\hLeftRight)         ;注销系统光标[左-右]
      DestroyCursor_(\hUpDown)            ;注销系统光标[上-下]
      DestroyCursor_(\hEditing)           ;注销系统光标[上-下]
      Define_FreeGadget(\btnCloseBox)     ;注销关闭窗体小按键
      Define_FreeGadget(\btnMinimize)     ;注销最小化窗体小按键
      Define_FreeGadget(\btnNormalcy)     ;注销正常化窗体小按键
      Define_FreeGadget(\btnMaximize)     ;注销最大化窗体小按键
      Define_FreeGadget(\btnSettings)     ;注销窗体设置小按键
      DragFinish_(\hWindow)               ;注销系统拖放文件
      FreeImage(\ResourIconID)
      FreeImage(\LayerImageID)
   EndWith
   Balloon_Release ()
   Navigate_Release()
   Discolor_Release()   
   Message_Release ()
   ToolBar_Release ()
   Caption_Release ()
   MenuBar_Release ()
   Editor_Release  ()
   Dialog_Release  ()
   Progress_Release()
   PopupBar_Release()
   
EndProcedure

;设置CallBack函数
Procedure Screen_CallBack(CallBackType, *pCallFunction)
   With _Screen
      Select CallBackType
         Case #CallBack_RedrawCanvas : \pCallRedrawCanvas = *pCallFunction
      EndSelect
   EndWith
EndProcedure


;-
;- ######## [Test] ######## 
CompilerIf  #PB_Compiler_IsMainFile = #True

*pScreen.__Screen_MainInfo = Screen_Initail()
hWindow = *pScreen\hWindow
If hWindow = #Null : End : EndIf 
Repeat
   WindowEvent = WindowEvent()
   Select WindowEvent
      Case #PB_Event_CloseWindow : 
         Result = Message_Requester(hWindow, "迷路提示", "确定要关闭窗体吗? ", #PB_MessageRequester_YesNo, #True)
         If Result = #PB_MessageRequester_Yes : IsExitWindow = #True : EndIf 
      Case #PB_Event_Gadget
         GadgetID = EventGadget()
         Select GadgetID
            ;菜单栏
            Case #winScreen
            Case #wmiSoftware       : MenuBar_Active(hWindow,  #MenuBarID_File)  : Debug "#wmiSoftware"
            Case #wmiSettings       : MenuBar_Active(hWindow,  #MenuBarID_View)  : Debug "#wmiSettings"
            Case #wmiCreateDesign   : Caption_CreateDesign()   : Screen_RedrawScreen(#False) : Debug "#wmiCreateDesign"
            Case #wmiOpenDesign     : Debug "#wmiOpenDesign"
            Case #wmiSaveDesign     : Debug "#wmiSaveDesign"
            Case #wmiSaveAsDesign   : Debug "#wmiSaveAsDesign"
            Case #wmiSaveAllDesign  : Debug "#wmiSaveAllDesign"
            Case #wmiCloseDesign    : Caption_CloseDesign()    : Screen_RedrawScreen(#False) : Debug "#wmiCloseDesign"
            Case #wmiCloseAllDesign : Caption_CloseAllDesign() : Screen_RedrawScreen(#False) : Debug "#wmiCloseAllDesign"
            Case #wmiExportImage    : Debug "#wmiExportImage"
            Case #wmiResizeCanvas   : Debug "#wmiResizeCanvas"
            Case #wmiExitSoftware   : Debug "#wmiExitSoftware"  
               Result = Message_Requester(hWindow, "迷路提示", "确定要关闭窗体吗? ", #PB_MessageRequester_YesNo, #True)
               If Result = #PB_MessageRequester_Yes : IsExitWindow = #True : EndIf 
            Case #wmiScrollLeft     : Debug "#wmiScrollLeft"   
            Case #wmiScrollRight    : Debug "#wmiScrollRight"   
            ;弹出菜单部分[视图]
            Case #wmiDisplayGrid    ;显示网格
            Case #wmiDisplayCoor    ;显示坐标
            Case #wmiStyleBlack     : Screen_ChangeStyle(#ViewStlye_Black) ;黑板风格
            Case #wmiStyleGreen     : Screen_ChangeStyle(#ViewStlye_Green) ;绿板风格
            Case #wmiStyleBlue      : Screen_ChangeStyle(#ViewStlye_Blue)  ;蓝板风格
            Case #wmiStyleRed       : Screen_ChangeStyle(#ViewStlye_Red)   ;红板风格
                     
            ;工具栏
            Case #wtbComponents     : Debug "#wtbComponents"    ;电子元件
            Case #wtbCircuitMod     : Debug "#wtbCircuitMod"    ;模块元件
            Case #wtbSensorsMod     : Debug "#wtbSensorsMod"    ;IC芯片
            Case #wtbPowSwitchs     : Debug "#wtbPowSwitchs"    ;电机部件
            Case #wtbAccessorys     : Debug "#wtbAccessorys"    ;电源部件
            Case #wtbMainBoards     : Debug "#wtbMainBoards"    ;单片机
            Case #wtbOperations     : Debug "#wtbOperations"     ;基本编辑
            ;导航条
            Case #btnScrollUp       : Debug "#btnScrollUp"
            Case #btnScrollDown     : Debug "#btnScrollDown"
            Case #btnScrollLeft     : Debug "#btnScrollLeft" 
            Case #btnScrollRight    : Debug "#btnScrollRight"  
            Case #btnScrollHome     : Debug "#btnScrollHome"  
            Case #btnScaleUp        : Debug "#btnScaleUp"
               LayerZoom = _Screen\pCurrDesign\LayerZoom * 100
               Select LayerZoom
                  Case 175 : LayerZoom = 200
                  Case 150 : LayerZoom = 175
                  Case 125 : LayerZoom = 150
                  Case 100 : LayerZoom = 125
                  Case 075 : LayerZoom = 100
                  Case 050 : LayerZoom = 075
                  Case 025 : LayerZoom = 050
                  Case 012 : LayerZoom = 025   
               EndSelect
               _Screen\pCurrDesign\LayerZoom = LayerZoom/100
               _Screen\LayerZoom = LayerZoom/100
               Screen_RedrawScreen(#False)
               
            Case #btnScaleDown     
               LayerZoom = _Screen\pCurrDesign\LayerZoom * 100
               Select LayerZoom
                  Case 200 : LayerZoom = 175
                  Case 175 : LayerZoom = 150
                  Case 150 : LayerZoom = 125
                  Case 125 : LayerZoom = 100
                  Case 100 : LayerZoom = 075
                  Case 075 : LayerZoom = 050
                  Case 050 : LayerZoom = 025   
                  Case 025 : LayerZoom = 012   
               EndSelect
               _Screen\pCurrDesign\LayerZoom = LayerZoom/100
               _Screen\LayerZoom = LayerZoom/100
               Screen_RedrawScreen(#False)
            Default : Debug "GadgetID = " + Str(GadgetID)
         EndSelect       

      Case #WM_RBUTTONUP         : 
      Case #Null                 : Screen_EventWindow_Null()
   EndSelect
   Screen_EventWindow_Delay()  
Until IsExitWindow = #True 
Screen_Release()

End

DataSection
_ICON_Resources:
   IncludeBinary ".\ICON.png" 
EndDataSection
CompilerEndIf 



; IDE Options = PureBasic 5.62 (Windows - x86)
; CursorPosition = 294
; FirstLine = 221
; Folding = 9----
; EnableXP
; Executable = DEMO.exe