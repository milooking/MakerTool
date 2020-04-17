;*****************************************
;******** 单片机仿真模拟器窗体界面 ********
;********    迷路仟 2020.03.01    ********
;*****************************************
;【Maker_PopupBar.pbi】 右键弹出工具栏源代码

#PopupBar_SingleLine = 50
#PopupBar_DoubleLine = 90

;各种控件标志
Enumeration
   #Object_None      ;空
   #Object_Canvas    ;[画布]
   #Object_Active    ;临时[激活组]
   #Object_Matter    ;[电子元件]
   #Object_String    ;[字符串]
   #Object_Groups    ;[电子元件组]
   #Object_Dupont    ;[杜邦线]
EndEnumeration


XIncludeFile "Maker_ToolBar.pbi"  ;左侧工具栏源代码


Structure __PopupItemInfo Extends __GadgetInfo
   *pToolItem.__ThirdBarInfo
EndStructure
   

Structure __PopupBarInfo Extends __GadgetInfo
   List ListPopupItem.__PopupItemInfo()
   CountItem.l
EndStructure

;-[Structure]
Structure __PopupBar_MainInfo Extends __AreaInfo
   *pColors.__ColorInfo
   *pWindow.__WindowInfo
   *pEvents.__EventInfo
   ;===============
   wtbMatterBar.__PopupBarInfo 
   wtbStringBar.__PopupBarInfo  
   wtbGroupsBar.__PopupBarInfo  
   wtbActiveBar.__PopupBarInfo  
   ;===============
   *pPopupBar.__PopupBarInfo  ;电子元件    
   
EndStructure

;-[Global]
Global _PopupBar.__PopupBar_MainInfo




;绘制控件
Procedure PopupBar_RedrawGadget(*pEvent.__EventInfo, *pPopupItem.__PopupItemInfo)
   With *pPopupItem\pToolItem
      If *pEvent\pHoldDown = *pPopupItem\pToolItem And IsImage(\HoldDownID)
         DrawAlphaImage(ImageID(\HoldDownID), *pPopupItem\X, *pPopupItem\Y)
      ElseIf *pEvent\pMouseTop = *pPopupItem\pToolItem And IsImage(\MouseTopID)
         DrawAlphaImage(ImageID(\MouseTopID), *pPopupItem\X, *pPopupItem\Y)
      ElseIf IsImage(\NormalcyID)
         DrawAlphaImage(ImageID(\NormalcyID), *pPopupItem\X, *pPopupItem\Y)
      EndIf 
   EndWith
EndProcedure


;绘制事件
Procedure PopupBar_RedrawScreen()

   If _PopupBar\pPopupBar = #Null : ProcedureReturn : EndIf 
   
   BackColor = _PopupBar\pColors\BackColor
   HighColor = _PopupBar\pColors\HighColor
   ForeColor = _PopupBar\pColors\ForeColor 
   ForeColor = (Alpha(ForeColor) << 22 & $FF000000) |(ForeColor & $FFFFFF)
   With _PopupBar\pPopupBar
      ;前景色
      DrawingMode(#PB_2DDrawing_AllChannels) 
      Box(\X, \Y+5, \W, \H, BackColor)                   ;打底
      DrawingMode(#PB_2DDrawing_AlphaBlend) 
      Box(\X, \Y+5, \W, \H, ForeColor)                   ;打底      
      For k = 1 To 5
         Line(\X, \Y+k-1, \W-5+k, 1, ForeColor)          ;顶部
         Line(\X+k-1, \Y+\H+5+k-1, \W-k+1, 1, ForeColor) ;底部
      Next   
      ;高亮色
      Box(\X+1, \Y+5, 1, \H, HighColor)                  ;左侧
      Box(\X+\W-2, \Y+5, 1, \H, HighColor)               ;左侧
      For k = 1 To 5
         Line(\X+1, \Y+k, \W-7+k, 1, HighColor)          ;顶部
         Line(\X+k, \Y+\H+5+k-2, \W-k-1, 1, HighColor)   ;顶部
      Next 
      ForEach \ListPopupItem()
         PopupBar_RedrawGadget(_PopupBar\pEvents, \ListPopupItem())
      Next 
   EndWith 
EndProcedure

;-
;- ******** [Hook] ********
;-
;光标在上事件[Screen_HookWindow()]
Procedure PopupBar_Hook_MOUSEMOVE(*pMouse.POINTS, Button)
   If _PopupBar\pPopupBar = #Null 
      *pEventGadget = ToolBar_Hook_MOUSEMOVE(*pMouse, Button)
      ProcedureReturn *pEventGadget
   ElseIf Macro_Gadget_InRect1(_PopupBar\pPopupBar)
      With _PopupBar\pPopupBar
         X = *pMouse\X-\X
         Y = *pMouse\Y-\Y
         ForEach \ListPopupItem()
            If Macro_Gadget_InRect1(\ListPopupItem())
               ProcedureReturn \ListPopupItem()\pToolItem
            EndIf 
         Next 
         ProcedureReturn _PopupBar\pPopupBar
      EndWith
   Else 
      *pEventGadget = ToolBar_Hook_MOUSEMOVE(*pMouse, Button)
      If *pEventGadget
         _PopupBar\pPopupBar = #Null 
      EndIf 
      ProcedureReturn *pEventGadget
   EndIf 
EndProcedure


Procedure PopupBar_Hook_LBUTTONDOWN(*pMouse.POINTS)
   If _PopupBar\pPopupBar = #Null 
      *pEventGadget = ToolBar_Hook_LBUTTONDOWN(*pMouse)
      ProcedureReturn *pEventGadget
   ElseIf Macro_Gadget_InRect1(_PopupBar\pPopupBar)
      With _PopupBar\pPopupBar
         X = *pMouse\X-\X
         Y = *pMouse\Y-\Y
         ForEach \ListPopupItem()
            If Macro_Gadget_InRect1(\ListPopupItem())
               ProcedureReturn \ListPopupItem()\pToolItem
            EndIf 
         Next 
         ProcedureReturn _PopupBar\pPopupBar
      EndWith
   Else 
      *pEventGadget = ToolBar_Hook_LBUTTONDOWN(*pMouse)
      If *pEventGadget
         _PopupBar\pPopupBar = #Null 
      EndIf 
      ProcedureReturn *pEventGadget
   EndIf 
EndProcedure


Procedure PopupBar_Hook_LBUTTONUP(*pMouse.POINTS)
   If _PopupBar\pPopupBar = #Null 
      *pEventGadget = ToolBar_Hook_LBUTTONUP(*pMouse)
      ProcedureReturn *pEventGadget
   ElseIf Macro_Gadget_InRect1(_PopupBar\pPopupBar)
      With _PopupBar\pPopupBar
         X = *pMouse\X-\X
         Y = *pMouse\Y-\Y
         ForEach \ListPopupItem()
            If Macro_Gadget_InRect1(\ListPopupItem())
               PostEvent(#PB_Event_Gadget, _PopupBar\pWindow\WindowID, \ListPopupItem()\pToolItem\GadgetID)
               *pEventGadget = \ListPopupItem()\pToolItem
               _PopupBar\pPopupBar = #Null 
               ProcedureReturn *pEventGadget
            EndIf 
         Next 
         ProcedureReturn _PopupBar\pPopupBar
      EndWith
   Else 
      *pEventGadget = ToolBar_Hook_LBUTTONUP(*pMouse)
      If *pEventGadget
         _PopupBar\pPopupBar = #Null 
      EndIf 
      ProcedureReturn *pEventGadget
   EndIf 
EndProcedure





Procedure PopupBar_CreatePopupItem(*pPopupBar.__PopupBarInfo, ItemName$, OffsetX, OffsetY)
   *pToolItem.__GadgetInfo = ToolBar_SelectItem(ItemName$)
   If *pToolItem
      *pPopupItem.__PopupItemInfo = AddElement(*pPopupBar\ListPopupItem())
      With *pPopupItem
         \pToolItem = *pToolItem
         \OffsetX = OffsetX
         \OffsetY = OffsetY
         \W = *pToolItem\W
         \H = *pToolItem\H
         Balloon_Gadget(*pPopupItem, *pPopupBar\ListPopupItem()\BalloonTip$)
      EndWith
      *pPopupBar\W  + 40
   EndIf 
EndProcedure

;-
;一级工具栏子项: [基本编辑]
Procedure PopupBar_Create_wtbMatterBar(*pPopupBar.__PopupBarInfo)
   With *pPopupBar
      \IsHide = #True
      \W = 20
      \H = 46
      ItemX = 10
      PopupBar_CreatePopupItem(*pPopupBar, "对齐网格", ItemX, 003) : ItemX+40
      PopupBar_CreatePopupItem(*pPopupBar, "置于顶层", ItemX, 003) : ItemX+40
      PopupBar_CreatePopupItem(*pPopupBar, "置于底层", ItemX, 003) : ItemX+40
      PopupBar_CreatePopupItem(*pPopupBar, "上移一层", ItemX, 003) : ItemX+40
      PopupBar_CreatePopupItem(*pPopupBar, "下移一层", ItemX, 003) : ItemX+40
      PopupBar_CreatePopupItem(*pPopupBar, "删除对象", ItemX-7, 008) : ItemX+40      
   EndWith
EndProcedure

Procedure PopupBar_Create_wtbStringBar(*pPopupBar.__PopupBarInfo)
   With *pPopupBar
      \IsHide = #True
      \W = 20
      \H = 46
      ItemX = 10
      PopupBar_CreatePopupItem(*pPopupBar, "对齐网格", ItemX+0, 003) : ItemX+40
      PopupBar_CreatePopupItem(*pPopupBar, "置于顶层", ItemX+0, 003) : ItemX+40
      PopupBar_CreatePopupItem(*pPopupBar, "置于底层", ItemX+0, 003) : ItemX+40
      PopupBar_CreatePopupItem(*pPopupBar, "上移一层", ItemX+0, 003) : ItemX+40
      PopupBar_CreatePopupItem(*pPopupBar, "下移一层", ItemX+0, 003) : ItemX+40
      PopupBar_CreatePopupItem(*pPopupBar, "删除对象", ItemX-7, 008) : ItemX+40     
   EndWith
EndProcedure

Procedure PopupBar_Create_wtbGroupsBar(*pPopupBar.__PopupBarInfo)
   With *pPopupBar
      \IsHide = #True
      \W = 20
      \H = 46
      ItemX = 10
      PopupBar_CreatePopupItem(*pPopupBar, "对齐网格", ItemX+0, 003) : ItemX+40
      PopupBar_CreatePopupItem(*pPopupBar, "拆散组合", ItemX-7, 008) : ItemX+40
      PopupBar_CreatePopupItem(*pPopupBar, "置于顶层", ItemX+0, 003) : ItemX+40
      PopupBar_CreatePopupItem(*pPopupBar, "置于底层", ItemX+0, 003) : ItemX+40
      PopupBar_CreatePopupItem(*pPopupBar, "上移一层", ItemX+0, 003) : ItemX+40
      PopupBar_CreatePopupItem(*pPopupBar, "下移一层", ItemX+0, 003) : ItemX+40
      PopupBar_CreatePopupItem(*pPopupBar, "删除对象", ItemX-7, 008) : ItemX+40   
   EndWith
EndProcedure

Procedure PopupBar_Create_wtbActiveBar(*pPopupBar.__PopupBarInfo)
   With *pPopupBar
      \IsHide = #True
      \W = 20
      \H = 46
      ItemX = 10
      PopupBar_CreatePopupItem(*pPopupBar, "对齐网格", ItemX+0, 003) : ItemX+40
      PopupBar_CreatePopupItem(*pPopupBar, "对象组合", ItemX-7, 008) : ItemX+40
      PopupBar_CreatePopupItem(*pPopupBar, "置于顶层", ItemX+0, 003) : ItemX+40
      PopupBar_CreatePopupItem(*pPopupBar, "置于底层", ItemX+0, 003) : ItemX+40
      PopupBar_CreatePopupItem(*pPopupBar, "上移一层", ItemX+0, 003) : ItemX+40
      PopupBar_CreatePopupItem(*pPopupBar, "下移一层", ItemX+0, 003) : ItemX+40
      PopupBar_CreatePopupItem(*pPopupBar, "删除对象", ItemX-7, 008) : ItemX+40         
   EndWith
EndProcedure


;-
Procedure PopupBar_Initial(*pWindow.__WindowInfo, *pColors, *pEvents)
   With _PopupBar
      \pColors       = *pColors
      \pEvents       = *pEvents
      \pWindow       = *pWindow
      PopupBar_Create_wtbMatterBar(\wtbMatterBar)
      PopupBar_Create_wtbStringBar(\wtbStringBar)
      PopupBar_Create_wtbGroupsBar(\wtbGroupsBar)
      PopupBar_Create_wtbActiveBar(\wtbActiveBar)
   EndWith
EndProcedure

Procedure PopupBar_ChangeStyle(*pColors) 
   _PopupBar\pColors       = *pColors
EndProcedure
    
;注销工具栏
Procedure PopupBar_Release()
   With _PopupBar
      *pPopupBar.__PopupBarInfo = \wtbMatterBar
      For k = 1 To 4
         FreeList(*pPopupBar\ListPopupItem())
         *pPopupBar + SizeOf(__PopupBarInfo)
      Next
   EndWith
EndProcedure

Procedure PopupBar_Active(ObjectType)
   Select ObjectType
      Case #Object_Matter : _PopupBar\pPopupBar = _PopupBar\wtbMatterBar
      Case #Object_String : _PopupBar\pPopupBar = _PopupBar\wtbStringBar
      Case #Object_Groups : _PopupBar\pPopupBar = _PopupBar\wtbGroupsBar
      Case #Object_Active : _PopupBar\pPopupBar = _PopupBar\wtbActiveBar
      Default : ProcedureReturn 
   EndSelect

   With _PopupBar\pPopupBar
      GetCursorPos_(Mouse.POINT)
;       ScreenToClient_(_PopupBar\pWindow\hWindow, Mouse) 
      \X = Mouse\X- WindowX(_PopupBar\pWindow\WindowID)+10
      \Y = Mouse\Y- WindowY(_PopupBar\pWindow\WindowID)-60
      \R = \X+\W
      \B = \Y+\H
      ForEach \ListPopupItem()
         \ListPopupItem()\X = \X+\ListPopupItem()\OffsetX
         \ListPopupItem()\Y = \Y+\ListPopupItem()\OffsetY
         \ListPopupItem()\R = \ListPopupItem()\X+\ListPopupItem()\W
         \ListPopupItem()\B = \ListPopupItem()\Y+\ListPopupItem()\H
      Next
   EndWith     
   ProcedureReturn #True
EndProcedure

;隐藏菜单栏
Procedure PopupBar_Display()
   If _PopupBar\pPopupBar
      _PopupBar\pPopupBar = #Null
      ProcedureReturn #True
   EndIf 
EndProcedure

;-
;- ######## [Test] ######## 
CompilerIf  #PB_Compiler_IsMainFile = #True
   #winScreen = 1000
   #cvsScreen = 1001
   Color.__ColorInfo
   Color\BackColor = #Define_BackColor   
   Color\ForeColor = #Define_ForeColor
   Color\HighColor = #Define_HighColor
   Event.__EventInfo
   Window.__WindowInfo
   Window\Font12ID = LoadFont(#PB_Any, "宋体", 12)  
   Window\WindowH = 650
   Window\WindowW = 1000
   Window\WindowID = #winScreen
   UsePNGImageDecoder()
   Window\ResourIconID  = CatchImage(#PB_Any, ?_ICON_Resources)
   ;======================
;挂钩事件
Procedure ToolBar_HookWindow(hWindow, uMsg, wParam, lParam) 
   With _ToolBar
      If \hWindow <> hWindow
         ProcedureReturn DefWindowProc_(hWindow, uMsg, wParam, lParam)
      EndIf
      Select uMsg 
         Case #WM_MOUSEMOVE
            Result = PopupBar_Hook_MOUSEMOVE    (@lParam, wParam)
            If \pEvents\pMouseTop <> Result : \pEvents\pMouseTop = Result : Refresh = #True : EndIf
         Case #WM_LBUTTONDOWN  
            Result = PopupBar_Hook_LBUTTONDOWN  (@lParam)
            If \pEvents\pHoldDown <> Result : \pEvents\pHoldDown = Result : Refresh = #True : EndIf            
            
         Case #WM_LBUTTONUP
            Result = PopupBar_Hook_LBUTTONUP    (@lParam)
            If \pEvents\pHoldDown Or \pEvents\pMouseTop : \pEvents\pHoldDown = #Null : \pEvents\pMouseTop = #Null : Refresh = #True : EndIf    

      EndSelect 
      If Result = 0 
         Result = CallWindowProc_(\hWindowHook, hWindow, uMsg, wParam, lParam) 
      ElseIf Refresh = #True
         If StartDrawing(CanvasOutput(#cvsScreen))
            Box(0, 0, 900, 650, #Define_BackColor&$FFFFFF)
            ToolBar_RedrawScreen()
            PopupBar_RedrawScreen()  
            StopDrawing()
         EndIf 
      EndIf
   EndWith
   ProcedureReturn Result
EndProcedure

   ;======================
   WindowFlags = #PB_Window_SystemMenu|#PB_Window_MaximizeGadget|#PB_Window_MinimizeGadget|#PB_Window_SizeGadget|#PB_Window_ScreenCentered
   hWindow = OpenWindow(#winScreen, 0, 0, 900, 650, "ToolBar-测试" , WindowFlags)
   ToolBar_Initial(@Window, @Color, @Event)  
   PopupBar_Initial(@Window, @Color, @Event) 
   CanvasGadget(#cvsScreen, 0, 0, 900, 650)
   If StartDrawing(CanvasOutput(#cvsScreen))
      Box(0, 0, 900, 650, #Define_BackColor&$FFFFFF)
      ToolBar_RedrawScreen()
      StopDrawing()
   EndIf
   _ToolBar\hWindow     = GadgetID(#cvsScreen)
   _ToolBar\hWindowHook = SetWindowLongPtr_(_ToolBar\hWindow, #GWL_WNDPROC, @ToolBar_HookWindow())
   ;======================
   Repeat
      WindowEvent = WindowEvent()
      Select WindowEvent
         Case #PB_Event_CloseWindow : IsExitWindow = #True
         Case #WM_LBUTTONUP : Refresh = PopupBar_Display()  
         Case #WM_RBUTTONUP : Refresh = PopupBar_Active(Random(3)+2)
         Case #PB_Event_Gadget : Refresh = EventGadget() 
      EndSelect
      If Refresh
         Refresh = #Null
         If StartDrawing(CanvasOutput(#cvsScreen))
            Box(0, 0, 900, 650, #Define_BackColor&$FFFFFF)
            ToolBar_RedrawScreen()
            PopupBar_RedrawScreen()  
            StopDrawing()
         EndIf
      EndIf 
   Until IsExitWindow = #True 
   ToolBar_Release()
   PopupBar_Release()
   FreeFont(Window\Font12ID)
   End
   ;======================
DataSection
_ICON_Resources:
   IncludeBinary ".\ICON.png" 
EndDataSection

   
CompilerEndIf 





















; IDE Options = PureBasic 5.62 (Windows - x86)
; CursorPosition = 265
; FirstLine = 201
; Folding = --n-
; EnableXP
; Executable = DEMO.exe