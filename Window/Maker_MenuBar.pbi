;*****************************************
;******** 单片机仿真模拟器窗体界面 ********
;********    迷路仟 2020.02.24    ********
;*****************************************
;【Maker_MenuBar.pbi】 弹出菜单[文件]源代码


;-[Constant]
#MenuBarID_File = 1
#MenuBarID_View = 2
#MenuType_Item = 1
#MenuType_Line = 0

;-[Enumeration]
Enumeration Screen
   #winMenuBar
EndEnumeration

;       DisplayGrid    ;显示网格
;       DisplayCoor    ;显示坐标
;       StyleBlack     ;黑板风格
;       StyleGreen     ;绿板风格
;       StyleBlue      ;蓝板风格
;       StyleRed       ;红板风格

;-[IncludeFile]
XIncludeFile ".\Maker_Define.pbi"      ;定义类源代码

;-[Structure]
;控件基本结构
Structure __MenuItemInfo Extends __AreaInfo
   MenuType.w
   HotKeyW.w
   ItemIconID.l
   MenuItemID.l
   IsChecked.l
   ItemText$
   HotKey$
   
EndStructure

;菜单栏结构
Structure __MenuBar_BaseInfo 
   List ListMenuItem.__MenuItemInfo()
EndStructure
  
;对话框结构
Structure __MenuBar_MainInfo Extends __WindowInfo
   *pColors.__ColorInfo
   *pWindow.__WindowInfo
   ;=========  
   wmiFileMenu.__MenuBar_BaseInfo 
   wmiViewMenu.__MenuBar_BaseInfo 
   ;=========
   Events.__EventInfo
   CheckIcoID.l
   ;=========
   *pMenuBar.__MenuBar_BaseInfo 
   *pMenuItem.__MenuItemInfo 
   ;=========
   IsExitWindow.l
EndStructure

;-[Global]
Global _MenuBar.__MenuBar_MainInfo

;-
;- ******** [Redraw] ********
;绘制事件
Procedure MenuBar_RedrawScreen()
   With _MenuBar
      If \pMenuBar = #Null : ProcedureReturn : EndIf 
      BackColor = \pColors\BackColor
      ForeColor = \pColors\ForeColor
      HighColor = \pColors\HighColor
      MenuColor = (Alpha(ForeColor) << 22 & $FF000000) |(ForeColor & $FFFFFF)
      If StartDrawing(ImageOutput(\LayerImageID))
         DrawingFont(FontID(\pWindow\Font12ID))
         DrawingMode(#PB_2DDrawing_AllChannels)
         Box(0, 0, \WindowW, \WindowH, BackColor)
         ItemX = 10
         ItemY = 5
         ItemW = \WindowW
         BackColor(HighColor & $FFFFFF)
         GradientColor(0.5, HighColor)
         GradientColor(1.0, HighColor & $FFFFFF)
         LinearGradient(0, 0, ItemW, 0)   
         ForEach \pMenuBar\ListMenuItem()
            *pMenuItem.__MenuItemInfo = \pMenuBar\ListMenuItem()
            If *pMenuItem\MenuType = #MenuType_Line
               DrawingMode(#PB_2DDrawing_Gradient|#PB_2DDrawing_AlphaBlend)
               Box(000, ItemY+2, ItemW, 2)                : 
            Else
               DrawingMode(#PB_2DDrawing_Gradient|#PB_2DDrawing_AlphaBlend)
               If \Events\pMouseTop = *pMenuItem
                  Box(000, ItemY, ItemW, *pMenuItem\H)
               EndIf 
               DrawingMode(#PB_2DDrawing_Transparent)
               
               If *pMenuItem\IsChecked = #True
                  DrawAlphaImage(ImageID(\CheckIcoID), ItemX, ItemY+1)
               ElseIf *pMenuItem\ItemIconID And IsImage(*pMenuItem\ItemIconID)
                  DrawAlphaImage(ImageID(*pMenuItem\ItemIconID), ItemX, ItemY+1)
               EndIf 
               DrawText(ItemX+25, ItemY+3, *pMenuItem\ItemText$, ForeColor) 
               DrawText(ItemW-*pMenuItem\HotKeyW, ItemY+3, *pMenuItem\HotKey$, ForeColor) 
            EndIf 
            *pMenuItem\X = 0
            *pMenuItem\W = ItemW
            *pMenuItem\R = ItemW
            ItemY + *pMenuItem\H
         Next 
         DrawingMode(#PB_2DDrawing_Outlined|#PB_2DDrawing_AllChannels)
         Box(0, 0, \WindowW, \WindowH, ForeColor)
         Box(1, 1, \WindowW-2, \WindowH-2, HighColor)
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
;光标在上事件[独立HOOK]
Procedure MenuBar_Hook_MOUSEMOVE(*pMouse.POINTS)
   With _MenuBar
      If \pMenuBar = #Null : ProcedureReturn : EndIf 
      ForEach \pMenuBar\ListMenuItem()
         If Macro_Gadget_InRect1(\pMenuBar\ListMenuItem())
            *pEventGadget = \pMenuBar\ListMenuItem()
         EndIf 
      Next 

      ;整理响应事件
      If \Events\pMouseTop <> *pEventGadget 
         \Events\pMouseTop = *pEventGadget
         MenuBar_RedrawScreen() 
      EndIf
   EndWith
EndProcedure

;左键按下事件[独立HOOK]
Procedure MenuBar_Hook_LBUTTONDOWN(*pMouse.POINTS)
   With _MenuBar
      ForEach \pMenuBar\ListMenuItem()
         If Macro_Gadget_InRect1(\pMenuBar\ListMenuItem())
            *pEventGadget = \pMenuBar\ListMenuItem()
         EndIf 
      Next 
      ;整理响应事件
      If \Events\pHoldDown <> *pEventGadget
         \Events\pHoldDown = *pEventGadget
         MenuBar_RedrawScreen()
      EndIf   
   EndWith
EndProcedure

;左键释放事件[独立HOOK]
Procedure MenuBar_Hook_LBUTTONUP(*pMouse.POINTS)
   With _MenuBar
      ForEach \pMenuBar\ListMenuItem()
         If Macro_Gadget_InRect1(\pMenuBar\ListMenuItem())
            *pEventGadget = \pMenuBar\ListMenuItem()
            PostEvent(#PB_Event_Gadget, \pWindow\WindowID, \pMenuBar\ListMenuItem()\MenuItemID)
            \IsExitWindow = #True
         EndIf 
      Next 
      ;整理响应事件
      If \Events\pHoldDown Or \Events\pHoldDown
         \Events\pHoldDown = 0
         \Events\pMouseTop = 0
         MenuBar_RedrawScreen()
      EndIf   
   EndWith
EndProcedure

;挂钩事件[独立HOOK]
Procedure MenuBar_Hook(hWindow, uMsg, wParam, lParam) 
   With _MenuBar
      If \hWindow <> hWindow
         \IsExitWindow = #True
         ProcedureReturn DefWindowProc_(hWindow, uMsg, wParam, lParam)
      EndIf
      Select uMsg
         Case #WM_MOUSEMOVE     : MenuBar_Hook_MOUSEMOVE  (@lParam)
         Case #WM_LBUTTONDOWN   : MenuBar_Hook_LBUTTONDOWN(@lParam)
         Case #WM_LBUTTONUP     : MenuBar_Hook_LBUTTONUP  (@lParam)
      EndSelect 
      Result = CallWindowProc_(\hWindowHook, hWindow, uMsg, wParam, lParam)
   EndWith
   ProcedureReturn Result
EndProcedure

;-
;- ******** [Create] ********
;创建菜单项
Procedure MenuBar_MenuItem(*pMenuBar.__MenuBar_BaseInfo, MenuItemID, ItemText$, X=#PB_Ignore, Y=#PB_Ignore, HotKey$=#Null$, IsCheck=#False)
   *pMenuItem.__MenuItemInfo = AddElement(*pMenuBar\ListMenuItem())
   *pMenuItem\MenuType   = #MenuType_Item
   *pMenuItem\ItemText$  = ItemText$
   *pMenuItem\MenuItemID = MenuItemID   
   *pMenuItem\HotKey$    = HotKey$
   If X<>#PB_Ignore And Y<>#PB_Ignore
      *pMenuItem\ItemIconID = GrabImage(_MenuBar\pWindow\ResourIconID, #PB_Any, X, Y, 20, 20)
   Else 
      *pMenuItem\ItemIconID = 0
   EndIf 
EndProcedure 

;创建菜单项分隔线
Procedure MenuBar_MenuLine(*pMenuBar.__MenuBar_BaseInfo)
   *pMenuItem.__MenuItemInfo = AddElement(*pMenuBar\ListMenuItem())
   *pMenuItem\MenuType  = #MenuType_Line
EndProcedure 

;-
;- ******** [Function] ********
;创建菜单栏
Procedure MenuBar_Calculate()
   With _MenuBar
      ;计算文本占用的最大宽度和最大高度
      ItemY  = 5
      LimitW = 100
      LimitK = 0
      If StartDrawing(ImageOutput(\LayerImageID))
         DrawingFont(FontID(\pWindow\Font12ID))
         ForEach \pMenuBar\ListMenuItem()
            *pMenuItem.__MenuItemInfo = \pMenuBar\ListMenuItem()
            *pMenuItem\Y = ItemY
            If *pMenuItem\MenuType = #MenuType_Line
               ItemY + 6
            Else 
               TextW = TextWidth (*pMenuItem\ItemText$)+25+20
               TextH = TextHeight(*pMenuItem\ItemText$)
               HotKeyW = TextWidth (*pMenuItem\HotKey$)  
               
               If LimitW < TextW : LimitW = TextW : EndIf 
               If LimitK < HotKeyW : LimitK = HotKeyW : EndIf 
               ItemY + TextH + 6
            EndIf 
            *pMenuItem\HotKeyW = HotKeyW+10
            *pMenuItem\B = ItemY
            *pMenuItem\H = ItemY-*pMenuItem\Y
         Next 
         StopDrawing()
      EndIf
      \WindowW = LimitW + LimitK + 30
      \WindowH = ItemY + 5 
   EndWith
EndProcedure

;-
;- ======> [External Call] <======
;初始化菜单栏
Procedure MenuBar_Initial(*pWindow.__WindowInfo, *pColors)
   With _MenuBar
      ExamineDesktops()
      DesktopH      = DesktopHeight(0)
      \pColors      = *pColors
      \pWindow      = *pWindow
      \LayerImageID = CreateImage(#PB_Any, 500, DesktopH)
      \CheckIcoID   = GrabImage(\pWindow\ResourIconID, #PB_Any, 376, 0, 20, 20)
      IconX = 096 : IconY = 000
      MenuBar_MenuItem(\wmiFileMenu, #wmiCreateDesign,    "新建文档",     IconX, IconY, "Ctr+N") : IconX+20
      MenuBar_MenuItem(\wmiFileMenu, #wmiOpenDesign,      "打开文档",     IconX, IconY, "Ctr+O") : IconX+20
      MenuBar_MenuLine(\wmiFileMenu)
      MenuBar_MenuItem(\wmiFileMenu, #wmiSaveDesign,      "保存文档",     IconX, IconY, "Ctr+S") : IconX+20
      MenuBar_MenuItem(\wmiFileMenu, #wmiSaveAsDesign,    "文档另存为..", IconX, IconY)          : IconX+20
      MenuBar_MenuItem(\wmiFileMenu, #wmiSaveAllDesign,   "保存全部文档", IconX, IconY)          : IconX+20
      MenuBar_MenuLine(\wmiFileMenu)
      MenuBar_MenuItem(\wmiFileMenu, #wmiCloseDesign,     "关闭文档",     IconX, IconY, "Ctr+C") : IconX+20
      MenuBar_MenuItem(\wmiFileMenu, #wmiCloseAllDesign,  "关闭全部文档")
      MenuBar_MenuLine(\wmiFileMenu)
      MenuBar_MenuItem(\wmiFileMenu, #wmiExportImage,     "导出图像...",  IconX, IconY, "Ctr+E") : IconX+20      
      MenuBar_MenuLine(\wmiFileMenu)
      MenuBar_MenuItem(\wmiFileMenu, #wmiResizeCanvas,    "软件设置...",  IconX, IconY, "Ctr+P") : IconX+20
      MenuBar_MenuLine(\wmiFileMenu)
      MenuBar_MenuItem(\wmiFileMenu, #wmiExitSoftware,    "退出工具")
      
      IconX = 256 : IconY = 000
      MenuBar_MenuItem(\wmiViewMenu, #wmiDisplayGrid,    "显示网格",  IconX, IconY) : IconX+20 
;       MenuBar_MenuItem(\wmiViewMenu, #wmiDisplayCoor,    "显示坐标") 
      MenuBar_MenuLine(\wmiViewMenu)
      MenuBar_MenuItem(\wmiViewMenu, #wmiStyleBlack,     "黑板风格",  IconX, IconY) : IconX+20
      MenuBar_MenuItem(\wmiViewMenu, #wmiStyleGreen,     "绿板风格",  IconX, IconY) : IconX+20
      MenuBar_MenuItem(\wmiViewMenu, #wmiStyleBlue,      "蓝板风格",  IconX, IconY) : IconX+20
      MenuBar_MenuItem(\wmiViewMenu, #wmiStyleRed,       "红板风格",  IconX, IconY) : IconX+20
   EndWith  
EndProcedure

Procedure MenuBar_ChangeStyle(*pColors)
   _MenuBar\pColors = *pColors
EndProcedure

;注销菜单栏
Procedure MenuBar_Release()
   With _MenuBar
      *pMenuBar.__MenuBar_BaseInfo = \wmiFileMenu
      ForEach *pMenuBar\ListMenuItem()
         Define_FreeGadget(*pMenuBar\ListMenuItem())
      Next 
      ClearList(*pMenuBar\ListMenuItem())
      
      *pMenuBar.__MenuBar_BaseInfo = \wmiViewMenu
      ForEach *pMenuBar\ListMenuItem()
         Define_FreeGadget(*pMenuBar\ListMenuItem())
      Next 
      ClearList(*pMenuBar\ListMenuItem())      
      
      Define_FreeGadget(*pMenuBar)
      If \hLayerImage  ;释放窗体背景句柄
         DeleteObject_(\hLayerImage) 
         \hLayerImage = 0
      EndIf 
      FreeImage(\LayerImageID)
      FreeImage(\CheckIcoID)
   EndWith
EndProcedure

;激活菜单栏
Procedure MenuBar_Active(hParent, MenuBarID)
   With _MenuBar
      Select MenuBarID
         Case #MenuBarID_File : \pMenuBar = \wmiFileMenu
         Case #MenuBarID_View : \pMenuBar = \wmiViewMenu
      EndSelect
      If \pMenuBar = #Null : ProcedureReturn : EndIf 
      MenuBar_Calculate()
      ;计算要显示的坐标位置
      GetCursorPos_(Mouse.POINT)
      Mouse\Y + 20
      \IsExitWindow = #False   
      If hParent = #Null
         \hWindow = OpenWindow(#winMenuBar, Mouse\X, Mouse\Y, \WindowW, \WindowH, "", #PB_Window_BorderLess)
      Else 
         \hWindow = OpenWindow(#winMenuBar, Mouse\X, Mouse\Y, \WindowW, \WindowH, "", #PB_Window_BorderLess, hParent)
      EndIf
      MenuBar_RedrawScreen()
      \hWindowHook = SetWindowLongPtr_(\hWindow, #GWL_WNDPROC, @MenuBar_Hook()) 
      
      Repeat
         Select WindowEvent()
            Case #PB_Event_CloseWindow   : \IsExitWindow = #True
            Case #PB_Event_Gadget
            Default 
         EndSelect
      Until \IsExitWindow = #True 
      If \hLayerImage  ;释放窗体背景句柄
         DeleteObject_(\hLayerImage) 
         \hLayerImage = 0
      EndIf 
      CloseWindow(#winMenuBar)
      Delay(100)
   EndWith
EndProcedure

;隐藏菜单栏
Procedure MenuBar_Display()
   If _MenuBar\IsExitWindow = #False
      _MenuBar\IsExitWindow = #True
      ProcedureReturn #True
   EndIf 
EndProcedure


Procedure MenuBar_SetItemState(MenuBarID, MenuItemID, State)
   Select MenuBarID
      Case #MenuBarID_File 
         ForEach _MenuBar\wmiFileMenu\ListMenuItem()
            With _MenuBar\wmiFileMenu\ListMenuItem()
               If \MenuItemID = MenuItemID
                  \IsChecked = State
                  Break
               EndIf 
            EndWith
         Next 
         
      Case #MenuBarID_View
         ForEach _MenuBar\wmiViewMenu\ListMenuItem()
            With _MenuBar\wmiViewMenu\ListMenuItem()
               If \MenuItemID = MenuItemID
                  \IsChecked = State
                  Break
               EndIf 
            EndWith
         Next 
   EndSelect
EndProcedure
   
   
;设置CallBack函数
Procedure MenuBar_CallBack(CallBackType, *pCallFunction)
   With _MenuBar
;       Select CallBackType
;          Case #CallBack_CreateDesign : \pCallCreateDesign = *pCallFunction
;          Case #CallBack_CloseDesign  : \pCallCloseDesign  = *pCallFunction
;          Case #CallBack_SelectDesign : \pCallSelectDesign = *pCallFunction
;       EndSelect
   EndWith
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
   Window\WindowH = 500
   Window\WindowW = 800
   UsePNGImageDecoder()
   Window\ResourIconID  = CatchImage(#PB_Any, ?_ICON_Resources)
   ;======================
   WindowFlags = #PB_Window_SystemMenu|#PB_Window_MaximizeGadget|#PB_Window_MinimizeGadget|#PB_Window_SizeGadget|#PB_Window_ScreenCentered
   hWindow = OpenWindow(#winScreen, 0, 0, 800, 550, "MenuBar 测试" , WindowFlags)
   Window\hWindow = hWindow
   MenuBar_Initial(@Window, @Color)  
   ;======================
   Repeat
      WindowEvent = WindowEvent()
      Select WindowEvent
         Case #PB_Event_CloseWindow : IsExitWindow = #True
         Case #PB_Event_Gadget 
            Select EventGadget()
               Case #wmiCreateDesign   : Debug "#wmiCreateDesign"
               Case #wmiOpenDesign     : Debug "#wmiOpenDesign"
               Case #wmiSaveDesign     : Debug "#wmiSaveDesign"
               Case #wmiSaveAsDesign   : Debug "#wmiSaveAsDesign"
               Case #wmiSaveAllDesign  : Debug "#wmiSaveAllDesign"
               Case #wmiCloseDesign    : Debug "#wmiCloseDesign"
               Case #wmiCloseAllDesign : Debug "#wmiCloseAllDesign"
               Case #wmiExportImage    : Debug "#wmiExportImage"
               Case #wmiResizeCanvas   : Debug "#wmiResizeCanvas"
               Case #wmiExitSoftware   : Debug "#wmiExitSoftware"   
            EndSelect  
         Case #WM_LBUTTONUP   : MenuBar_Active(hWindow,  #MenuBarID_File)  
         Case #WM_RBUTTONUP   : MenuBar_Active(hWindow,  #MenuBarID_View)  
      EndSelect
   Until IsExitWindow = #True 
   FreeFont(Window\Font12ID)
   MenuBar_Release()
   End
   ;======================
DataSection
_ICON_Resources:
   IncludeBinary ".\ICON.png" 
EndDataSection

CompilerEndIf 




; IDE Options = PureBasic 5.62 (Windows - x86)
; CursorPosition = 274
; FirstLine = 171
; Folding = fCB-
; EnableXP
; Executable = DEMO.exe