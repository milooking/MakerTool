;*****************************************
;******** 单片机仿真模拟器窗体界面 ********
;********    迷路仟 2020.02.24    ********
;*****************************************
;【Maker_Editor.pbi】 对象修改对话框源代码



;-[Enumeration]
Enumeration Screen
   #winEditor
   #btnEditExit
   #btnEditSure
   #btnEditCancel
   #txtEditPosX
   #txtEditPosY
   #txtEditText
   #txtEditSize
   #txtEditColor
   #btnEditColor
EndEnumeration

;-[IncludeFile]
XIncludeFile ".\Maker_Define.pbi"      ;定义类源代码
XIncludeFile ".\Maker_Discolor.pbi"    ;颜色修改对话框源代码

;-[Structure]
;对话框结构
Structure __Editor_MainInfo Extends __WindowInfo
   hMessageIcon.i
   TitleH.l
   Flags.l
   Title$
   FontColor.l
   ;=========
   *pColors.__ColorInfo
   *pWindow.__WindowInfo
   ;=========
   btnCloseBox.__GadgetInfo
   btnEditSure.__GadgetInfo
   btnEditCancel.__GadgetInfo
   btnEditColor.__GadgetInfo
   ;=========
   Events.__EventInfo
   ;=========
   IsExitWindow.b
EndStructure

;-[Global]
Global _Editor.__Editor_MainInfo

;-
;- ******** [Redraw] ********
;绘制边框
Procedure Editor_RedrawBorder()
   With _Editor
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
Procedure Editor_RedrawScreen()
   With _Editor
      ;绘制与当前窗体与鼠标事件相关的界面
      If StartDrawing(ImageOutput(\LayerImageID))
         BackColor = \pColors\BackColor
         HighColor = \pColors\HighColor
         ForeColor = \pColors\ForeColor
         Editor_RedrawBorder()
         
         Box(\btnEditColor\X, \btnEditColor\Y, 20, 20, \FontColor)
         
         ;绘制文本
         DrawingMode(#PB_2DDrawing_AlphaBlend|#PB_2DDrawing_Transparent)
         DrawingFont(FontID(\pWindow\Font12ID))
         DrawText(20, (\TitleH-TextHeight(\Title$)-8)/2, \Title$, BackColor)
         X = 065 : Y = 060
         DrawText(X-TextWidth("X坐标:"), Y+00, "X坐标:",    ForeColor)
         DrawText(X-TextWidth("Y坐标:"), Y+25, "Y坐标:",    ForeColor)
         DrawText(X-TextWidth("内容:"),  Y+50, "内容:", ForeColor) 
         
         X = 235 : Y = 060
         DrawText(X-TextWidth("字体大小:"), Y+00, "字体大小:",  ForeColor)
         DrawText(X-TextWidth("颜色:"),     Y+25, "颜色: 0x",  ForeColor)
         
         ;绘制按键
         DrawingMode(#PB_2DDrawing_AlphaBlend) 
         ButtonX = \WindowW-1 - \btnCloseBox\W : ButtonY = 1  
         Define_RedrawGadget(\Events, \btnCloseBox, ButtonX, ButtonY)
         Define_RedrawGadget(\Events, \btnEditSure,   \WindowW-110, \WindowH-50)
         Define_RedrawGadget(\Events, \btnEditCancel, \WindowW-210, \WindowH-50)
         StopDrawing()
      EndIf 

      ;将对话框图像渲染到窗体
      If \hLayerImage : DeleteObject_(\hLayerImage) : \hLayerImage = 0 : EndIf  ;释放窗体背景句柄
      \hLayerImage= CreatePatternBrush_(ImageID(\LayerImageID))
      If \hLayerImage
         SetClassLongPtr_(\hWindow, #GCL_HBRBACKGROUND, \hLayerImage)
;          RedrawWindow_(\hWindow, #Null, #Null, #RDW_UPDATENOW|#RDW_ERASE|#RDW_INVALIDATE)
;          设置刷新域,去掉窗体界面控件部分 注意:*pRectScreen.RECT, *pRgnCombine是指针,不一样
         *pRgnCombine = CreateRectRgn_(0,0,\WindowW, \WindowH)           ;设置一个大的区域
         For GadgetID = #txtEditPosX To  #txtEditColor
            GetWindowRect_(GadgetID(GadgetID), Rect.RECT) 
            *pRgnReserve = CreateRectRgn_(Rect\left,Rect\top,Rect\right,Rect\bottom)                  ;设置[]的区域
            CombineRgn_(*pRgnCombine,*pRgnCombine,*pRgnReserve,#RGN_DIFF)   ;在大区域中挖去按键区域  
         Next 
         RedrawWindow_(\hWindow, *pRectScreen, *pRgnCombine, #RDW_INTERNALPAINT|#RDW_ERASE|#RDW_INVALIDATE)
      EndIf 
   EndWith
EndProcedure
   

   
;-
;- ******** [Hook] ********
;光标在上事件[独立HOOK]
Procedure Editor_Hook_MOUSEMOVE(*pMouse.POINTS)
   With _Editor
      If *pMouse = 0
      ElseIf Macro_Gadget_InRect2(\btnCloseBox)    : *pEventGadget = \btnCloseBox
      ElseIf Macro_Gadget_InRect2(\btnEditSure)    : *pEventGadget = \btnEditSure
      ElseIf Macro_Gadget_InRect2(\btnEditCancel)  : *pEventGadget = \btnEditCancel
      ElseIf Macro_Gadget_InRect1(\btnEditColor)   : *pEventGadget = \btnEditColor
      EndIf 
      ;整理响应事件
      If \Events\pMouseTop <> *pEventGadget 
         \Events\pMouseTop = *pEventGadget 
         Editor_RedrawScreen() 
      ElseIf IsRefresh = #True
         Editor_RedrawScreen() 
      EndIf
   EndWith
EndProcedure

;左键按下事件[独立HOOK]
Procedure Editor_Hook_LBUTTONDOWN(*pMouse.POINTS)
   With _Editor
      If *pMouse = 0   
      ElseIf Macro_Gadget_InRect2(\btnCloseBox)    : *pEventGadget = \btnCloseBox
      ElseIf Macro_Gadget_InRect2(\btnEditSure)    : *pEventGadget = \btnEditSure
      ElseIf Macro_Gadget_InRect2(\btnEditCancel)  : *pEventGadget = \btnEditCancel
      ElseIf Macro_Gadget_InRect1(\btnEditColor)   : *pEventGadget = \btnEditColor
      Else
         SendMessage_(\hWindow, #WM_NCLBUTTONDOWN, #HTCAPTION, 0)      
      EndIf 
      
      ;整理响应事件
      If \Events\pHoldDown <> *pEventGadget : \Events\pHoldDown = *pEventGadget : Editor_RedrawScreen() : EndIf   
   EndWith
EndProcedure

;左键释放事件[独立HOOK]
Procedure Editor_Hook_LBUTTONUP(*pMouse.POINTS)
   With _Editor

      If *pMouse = 0   
      ElseIf Macro_Gadget_InRect2(\btnCloseBox) 
         If \Events\pHoldDown = \btnCloseBox
            *pEventGadget = \btnCloseBox
            PostEvent(#PB_Event_Gadget, #winEditor, #btnEditExit)
         EndIf 
      ElseIf Macro_Gadget_InRect2(\btnEditSure)
         If \Events\pHoldDown = \btnEditSure
            *pEventGadget = \btnEditSure
            PostEvent(#PB_Event_Gadget, #winEditor, #btnEditSure)
         EndIf
      ElseIf Macro_Gadget_InRect2(\btnEditCancel)
         If \Events\pHoldDown = \btnEditCancel
            *pEventGadget = \btnEditCancel
            PostEvent(#PB_Event_Gadget, #winEditor, #btnEditCancel)
         EndIf  
      ElseIf Macro_Gadget_InRect1(\btnEditColor)   
         If \Events\pHoldDown = \btnEditColor
            *pEventGadget = \btnEditColor
            PostEvent(#PB_Event_Gadget, #winEditor, #btnEditColor)
            Debug "xxxxxxxxx"
         EndIf  
      EndIf 
      
      ;整理响应事件
      If \Events\pHoldDown Or \Events\pHoldDown
         \Events\pHoldDown = 0 
         \Events\pMouseTop = 0
         Editor_RedrawScreen()
      ElseIf IsRefresh = #True
         Editor_RedrawScreen() 
      EndIf  
   EndWith
EndProcedure

;挂钩事件[独立HOOK]
Procedure Editor_Hook(hWindow, uMsg, wParam, lParam) 
   With _Editor
      If \hWindow <> hWindow
         ProcedureReturn DefWindowProc_(hWindow, uMsg, wParam, lParam)
      EndIf
      Select uMsg
         Case #WM_MOUSEMOVE     : Editor_Hook_MOUSEMOVE  (@lParam)
         Case #WM_LBUTTONDOWN   : Editor_Hook_LBUTTONDOWN(@lParam)
         Case #WM_LBUTTONUP     : Editor_Hook_LBUTTONUP  (@lParam)
      EndSelect 
      Result = CallWindowProc_(\hWindowHook, hWindow, uMsg, wParam, lParam)
   EndWith
   ProcedureReturn Result
EndProcedure

;-
;- ======> [External Call] <======
;信息对话框初始化
Procedure Editor_Initial(*pWindow.__WindowInfo, *pColors)
   With _Editor
      \pWindow      = *pWindow
      \pColors      = *pColors
      \LayerImageID = CreateImage(#PB_Any, 340, 250)
      Define_CreateCloseBox(*pColors, \btnCloseBox)    ;创建关闭窗体小按键
      Define_CreateButton  (*pColors, \btnEditSure,   000, 000, 090, 30, "确定", *pWindow\Font12ID)
      Define_CreateButton  (*pColors, \btnEditCancel, 000, 000, 090, 30, "取消", *pWindow\Font12ID)
   EndWith

   With _Editor\btnEditColor
      \X = 165 : \Y = 083 : \W = 020 : \H=020 : \R = \X + \W : \B = \Y + \H 
   EndWith
EndProcedure

Procedure Editor_ChangeStyle(*pColors)
   With _Editor
      \pColors      = *pColors
      Define_CreateCloseBox(*pColors, \btnCloseBox)    ;创建关闭窗体小按键
      Define_CreateButton  (*pColors, \btnEditSure,   000, 000, 090, 30, "确定", \pWindow\Font12ID)
      Define_CreateButton  (*pColors, \btnEditCancel, 000, 000, 090, 30, "取消", \pWindow\Font12ID)
   EndWith
EndProcedure

;注销信息对话框
Procedure Editor_Release()
   With _Editor
      Define_FreeGadget(\btnCloseBox)
      Define_FreeGadget(\btnEditSure)
      Define_FreeGadget(\btnEditCancel)
      FreeImage(\LayerImageID)   
   EndWith
EndProcedure

;信息对话框初始化
Procedure Editor_Requester(hParent, *pObject.__Maker_ObjectInfo, IsModify=#False, X=#PB_Ignore, Y=#PB_Ignore)
   With _Editor
      If *pObject = #Null : ProcedureReturn : EndIf 
      If IsModify = #True : Title$ = "修改文本标签" : Else : Title$ = "添加文本标签" : EndIf 
      \WindowW = 340
      \WindowH = 250
      \Flags   = Flags
      \TitleH  = 38
      \Title$  = Title$
      \IsExitWindow = #False  
      \FontColor = *pObject\FontColor
      If hParent = #Null
         If  X=#PB_Ignore Or Y=#PB_Ignore
            WindowFlags = #PB_Window_BorderLess|#PB_Window_ScreenCentered
            \hWindow = OpenWindow(#winEditor, 0, 0, \WindowW, \WindowH, "", WindowFlags)
         Else 
            WindowFlags = #PB_Window_BorderLess
            \hWindow = OpenWindow(#winEditor, X, Y, \WindowW, \WindowH, "", WindowFlags)            
         EndIf 
      ElseIf X=#PB_Ignore Or Y=#PB_Ignore
         WindowFlags = #PB_Window_BorderLess|#PB_Window_WindowCentered
         \hWindow = OpenWindow(#winEditor, 0, 0, \WindowW, \WindowH, "", WindowFlags, hParent)
      Else 
         WindowFlags = #PB_Window_BorderLess
         \hWindow = OpenWindow(#winEditor, X, Y, \WindowW, \WindowH, "", WindowFlags, hParent)        
      EndIf
      X = 75 : Y = 060
      StringGadget(#txtEditPosX,  X, Y+00, 060, 020, Str(*pObject\X), #PB_String_Numeric)
      StringGadget(#txtEditPosY,  X, Y+25, 060, 020, Str(*pObject\Y), #PB_String_Numeric)
      EditorGadget(#txtEditText,  X, Y+50, 245, 080)
      X = 240 : Y = 060
      FontColor = (\FontColor & $00FF00)|(\FontColor << 16 & $FF0000)|(\FontColor >> 16 & $0000FF)
      SpinGadget  (#txtEditSize,  X+00, Y+00, 080, 020, 010, 200, #PB_Spin_Numeric)
      StringGadget(#txtEditColor, X+20, Y+25, 060, 020, RSet(Hex(FontColor), 6, "0"))
      SetGadgetFont(#txtEditPosX,  FontID(\pWindow\Font12ID))
      SetGadgetFont(#txtEditPosY,  FontID(\pWindow\Font12ID))
      SetGadgetFont(#txtEditSize,  FontID(\pWindow\Font12ID))
      SetGadgetFont(#txtEditColor, FontID(\pWindow\Font12ID))
      SetGadgetFont(#txtEditText,  FontID(\pWindow\Font12ID))
      SetGadgetText(#txtEditSize,  Str(*pObject\FontSize))
      SetGadgetText(#txtEditText,  *pObject\Text$)
      SetActiveGadget(#txtEditText)
      Editor_RedrawScreen()

      \hWindowHook = SetWindowLongPtr_(\hWindow, #GWL_WNDPROC, @Editor_Hook()) 
      If hParent
         EnableWindow_(hParent, #False)   ;禁用父窗体的响应动作
      EndIf 
      Repeat
         Select WindowEvent()
            Case #PB_Event_CloseWindow    : \IsExitWindow = #True
            Case #PB_Event_Gadget
               Select EventGadget()
                  Case #btnEditExit      : \IsExitWindow = #True : 
                  Case #btnEditSure      : \IsExitWindow = #True : Result = #True
                  Case #btnEditCancel    : \IsExitWindow = #True : 
                  Case #btnEditColor     
                     FontColor = Discolor_Requester(\hWindow, \FontColor, "标签字体")
                     \FontColor = FontColor
                     FontColor = (FontColor & $00FF00)|(FontColor << 16 & $FF0000)|(FontColor >> 16 & $0000FF)
                     SetGadgetText(#txtEditColor, RSet(Hex(FontColor), 6, "0"))
                     Editor_RedrawScreen()
               EndSelect
            Default 
         EndSelect
      Until \IsExitWindow = #True 
      
      *pObject\Text$     = GetGadgetText(#txtEditText)
      *pObject\X         = Val(GetGadgetText(#txtEditPosX))
      *pObject\Y         = Val(GetGadgetText(#txtEditPosY))
      *pObject\FontSize  = Val(GetGadgetText(#txtEditSize))
      FontColor          = Val("$"+GetGadgetText(#txtEditColor))
      *pObject\FontColor = (FontColor & $00FF00)|(FontColor << 16 & $FF0000)|(FontColor >> 16 & $0000FF)
      If \hLayerImage  ;释放窗体背景句柄
         DeleteObject_(\hLayerImage) 
         \hLayerImage = 0
      EndIf 
      If hParent
         EnableWindow_(hParent, #True)   ;恢复父窗体的响应动作
      EndIf 
      CloseWindow(#winEditor)
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
   _DimColorTable(0)\Color = $0080F0
   _DimColorTable(1)\Color = $0000C0
   _DimColorTable(2)\Color = $00C000
   _DimColorTable(3)\Color = $C00000
   
   Window.__WindowInfo
   Window\Font12ID = LoadFont(#PB_Any, "宋体", 12)  
   ;======================
   WindowFlags = #PB_Window_SystemMenu|#PB_Window_MinimizeGadget|#PB_Window_ScreenCentered
   hWindow = OpenWindow(#winScreen, 0, 0, 500, 250, "Editor-测试" , WindowFlags)
   Editor_Initial(@Window, @Color)
   Discolor_Initial(@Window, @Color)
   ;======================
   
   Object.__Maker_ObjectInfo
   Object\X = 100
   Object\Y = 200
   Object\FontSize  = 60
   Object\FontColor = 0
   Object\Text$ = "文本标签"
   Editor_Requester(hWindow, @Object)

   Repeat
      WindowEvent = WindowEvent()
      Select WindowEvent
         Case #PB_Event_CloseWindow : IsExitWindow = #True
         Case #WM_LBUTTONUP 
            Editor_Requester(hWindow, @Object)
            Debug Object\X
            Debug Object\Y
            Debug Object\Text$
            Debug ""
      EndSelect
   Until IsExitWindow = #True 
   FreeFont(Window\Font12ID)  
   Discolor_Release()
   Editor_Release()
   End
CompilerEndIf 














; IDE Options = PureBasic 5.62 (Windows - x86)
; CursorPosition = 264
; FirstLine = 236
; Folding = -0-
; EnableXP
; Executable = DEMO.exe