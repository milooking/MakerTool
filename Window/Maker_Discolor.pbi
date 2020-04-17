;*****************************************
;******** 单片机仿真模拟器窗体界面 ********
;********    迷路仟 2020.02.27    ********
;*****************************************
;【Maker_Discolor.pbi】 颜色修改对话框源代码



;-[Enumeration]
Enumeration Screen
   #winDiscolor
   #btnColorExit
   #btnColorSure
   #btnColorCancel
   #txtColorRed
   #txtColorGreen
   #txtColorBlue
   #txtColorValue
EndEnumeration


;-[IncludeFile]
XIncludeFile ".\Maker_Define.pbi"      ;定义类源代码

;-[Structure]
;对话框结构
Structure __Discolor_MainInfo Extends __WindowInfo
   hMessageIcon.i
   TitleH.l
   Flags.l
   Title$
   OldColor.l
   NewColor.l
   ImageLinerID.l
   ImageBlockID.l
   DimColorLiner.l[270]
   ;=========
   *pColors.__ColorInfo
   *pWindow.__WindowInfo
   ;=========
   btnCloseBox.__GadgetInfo
   btnColorSure.__GadgetInfo
   btnColorCancel.__GadgetInfo
   btnColorLiner.__GadgetInfo
   btnColorBlock.__GadgetInfo
   btnColorLine.__GadgetInfo
   btnColorArea.__GadgetInfo
   btnColorTable.__GadgetInfo
   ;=========
   Events.__EventInfo
   ;=========
   IsExitWindow.b
   IsMovingLiner.b
   IsMovingBlock.b
   IsRefreshLiner.b
   IsPickColor.b
EndStructure

;-[Global]
Global _Discolor.__Discolor_MainInfo

;-
;- ******** [Redraw] ********
;绘制边框
Procedure Discolor_RedrawBorder()
   With _Discolor
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


Procedure Discolor_RedrawBlock(LineColor, Color = -1)
   If StartDrawing(ImageOutput(_Discolor\ImageBlockID))
      DrawingMode(#PB_2DDrawing_Default)  
      Box(0, 0, 258, 258, $FFFFFF)
      DrawingMode(#PB_2DDrawing_Outlined)
      Box(0, 0, 258, 258, $000000)
      ;左右红色渐变
      DrawingMode(#PB_2DDrawing_Gradient)      
      BackColor($FFFFFF)
      FrontColor(LineColor)
      LinearGradient(1, 1, 256, 1)    
      Box(1, 1, 256, 256)
      ;上下透明度渐变
      DrawingMode(#PB_2DDrawing_Gradient|#PB_2DDrawing_AlphaBlend)      
      BackColor ($00000000)
      FrontColor($FF000000)
      LinearGradient(1, 1, 1, 256)    
      Box(1, 1, 256, 256)
      If Color > -1
         R = Red(Color)
         G = Green(Color)
         B = Blue(Color)
         MinDiffer = 255 * 3
         For y = 257 To 01 Step -1
            For x = 257 To 01 Step -1
               PointColor = Point(x, y)
               CurDiffer = Abs(Red(PointColor)-R)
               CurDiffer + Abs(Green(PointColor)-G)
               CurDiffer + Abs(Blue(PointColor)-B)
               If CurDiffer < MinDiffer 
                  MinDiffer = CurDiffer
                  
                  _Discolor\btnColorBlock\X = X+60
                  _Discolor\btnColorBlock\Y = Y+43
                  _Discolor\btnColorBlock\R = _Discolor\btnColorBlock\X+_Discolor\btnColorBlock\W
                  _Discolor\btnColorBlock\B = _Discolor\btnColorBlock\Y+_Discolor\btnColorBlock\H
               EndIf 
            Next 
         Next
         Debug "CurDiffer = " + MinDiffer
      EndIf 
      StopDrawing()
   EndIf  
EndProcedure


;绘制事件
Procedure Discolor_RedrawScreen()
   With _Discolor
      If \IsRefreshLiner = #True
         LineColor = \DimColorLiner[\btnColorLiner\Y-46]
         Discolor_RedrawBlock(LineColor)
         \IsRefreshLiner = #False
      EndIf 
      ;绘制与当前窗体与鼠标事件相关的界面
      If StartDrawing(ImageOutput(\LayerImageID))
         BackColor = \pColors\BackColor
         HighColor = \pColors\HighColor
         ForeColor = \pColors\ForeColor
         Discolor_RedrawBorder()
         
         ;绘制颜色渐变条
         X = 20 :Y = 15+\TitleH
         DrawImage(ImageID(\ImageLinerID), X, Y)
;          LinerColor = Point(33, \btnColorLiner\Y+7)  ;<----获取颜色条的颜色

         X+50
         Box(X-1, Y-1, 256+2, 256+2, $FFFFFF)
         DrawingMode(#PB_2DDrawing_Outlined)
         Box(X-1, Y-1, 256+2, 256+2, ForeColor)
         
         Box(X+275+40, 190+00, 80, 025, ForeColor)
         Box(X+275+40, 190+24, 80, 025, ForeColor)
         
         For k = 0 To 8-1
            Box(_DimColorTable(k)\X, _DimColorTable(k)\Y, 22, 22, $FF0000C0)
         Next 
         For k = 8 To 40-1
            Box(_DimColorTable(k)\X, _DimColorTable(k)\Y, 22, 22, ForeColor)
         Next 

         DrawImage(ImageID(\ImageBlockID), X-1, Y-1)

         If \IsPickColor = #True
            BlockColor = Point(\btnColorBlock\X+10, \btnColorBlock\Y+10)  ;<----获取颜色域的颜色
            \IsPickColor = #False
         Else 
            BlockColor = \NewColor
         EndIf 
         
         DrawingMode(#PB_2DDrawing_Default)
         Box(X+275+41, 190+01, 80-2, 025-2, BlockColor)
         Box(X+275+41, 190+25, 80-2, 025-2, \OldColor)
         
         For k = 0 To 40-1
            If _DimColorTable(k)\Color = -1 : Continue : EndIf 
            Box(_DimColorTable(k)\X+1, _DimColorTable(k)\Y+1, 20, 20, _DimColorTable(k)\Color)
         Next 
         
         
         ;绘制文本
         DrawingMode(#PB_2DDrawing_AlphaBlend|#PB_2DDrawing_Transparent)
         
         
         DrawingFont(FontID(\pWindow\Font12ID))
         DrawText(20, (\TitleH-TextHeight(\Title$)-8)/2, \Title$, BackColor)
         
         X + 310 : Y = 196
         DrawText(X-TextWidth("新的"), Y-03, "新的", ForeColor)
         DrawText(X-TextWidth("当前"), Y+22, "当前", ForeColor)
         DrawText(X-TextWidth("0x:"),  Y+50, "0x:",  ForeColor) 
         
         X + 120 : Y = 196
         DrawText(X-TextWidth("R:"),   Y+00, "R:",   ForeColor)
         DrawText(X-TextWidth("G:"),   Y+25, "G:",   ForeColor)
         DrawText(X-TextWidth("B:"),   Y+50, "B:",   ForeColor)

         
         ;绘制按键
         DrawingMode(#PB_2DDrawing_AlphaBlend) 
         ButtonX = \WindowW-1 - \btnCloseBox\W : ButtonY = 1  
         Define_RedrawGadget(\Events, \btnCloseBox, ButtonX, ButtonY)
         
         Define_RedrawGadget(\Events, \btnColorSure,   450, \WindowH-50)
         Define_RedrawGadget(\Events, \btnColorCancel, 340, \WindowH-50)
         Define_RedrawGadget(\Events, \btnColorLiner)
         Define_RedrawGadget(\Events, \btnColorBlock)
         StopDrawing()
      EndIf 

      ;将对话框图像渲染到窗体
      If \hLayerImage : DeleteObject_(\hLayerImage) : \hLayerImage = 0 : EndIf  ;释放窗体背景句柄
      \hLayerImage= CreatePatternBrush_(ImageID(\LayerImageID))
      If \hLayerImage
         SetClassLongPtr_(\hWindow, #GCL_HBRBACKGROUND, \hLayerImage)
         ;设置刷新域,去掉窗体界面控件部分 注意:*pRectScreen.RECT, *pRgnCombine是指针,不一样

         *pRgnCombine = CreateRectRgn_(0,0,\WindowW, \WindowH)           ;设置一个大的区域
         For GadgetID = #txtColorRed To  #txtColorValue
            X = GadgetX(GadgetID)
            Y = GadgetY(GadgetID)
            R = X+GadgetWidth(GadgetID)
            B = Y+GadgetHeight(GadgetID)
            *pRgnReserve = CreateRectRgn_(X,Y,R,B)                  ;设置[]的区域
;             GetWindowRect_(GadgetID(GadgetID), Rect.RECT) 
;             *pRgnReserve = CreateRectRgn_(Rect\left-1,Rect\top-1,Rect\right+1,Rect\bottom+1)                  ;设置[]的区域
            CombineRgn_(*pRgnCombine,*pRgnCombine,*pRgnReserve,#RGN_DIFF)   ;在大区域中挖去按键区域  
         Next    
         RedrawWindow_(\hWindow, #Null, *pRgnCombine, #RDW_UPDATENOW|#RDW_ERASE|#RDW_INVALIDATE)
;          RedrawWindow_(\hWindow, *pRectScreen, *pRgnCombine, #RDW_INTERNALPAINT|#RDW_ERASE|#RDW_INVALIDATE)
      EndIf 
      If \NewColor <> BlockColor
         \NewColor = BlockColor
         Color = (\NewColor & $00FF00)|(\NewColor << 16 & $FF0000)|(\NewColor >> 16 & $0000FF)
         SetGadgetText(#txtColorRed,   RSet(Str(Red  (\NewColor)), 3, "0"))
         SetGadgetText(#txtColorGreen, RSet(Str(Green(\NewColor)), 3, "0"))
         SetGadgetText(#txtColorBlue,  RSet(Str(Blue (\NewColor)), 3, "0"))
         SetGadgetText(#txtColorValue, RSet(Hex(Color), 6, "0"))  
      EndIf 
   EndWith
EndProcedure

;-
;- ******** [Function] ********
Procedure Discolor_Calculate(Color)
   R = Red  (Color)
   G = Green(Color)
   B = Blue (Color)
   ;去掉最小值
   If R <= G And R <= B 
      R = 0  
   ElseIf G <= R And G <= B 
      G = 0 
   Else
      B = 0 
   EndIf 
   ;去掉最大值
   If R >= G And R >= B 
      R = 255 
      G = (G+3) /6 * 6
      B = (B+3) /6 * 6
   ElseIf G >= R And G >= B 
      G = 255 
      R = (R+3) /6 * 6 
      B = (B+3) /6 * 6
   Else
      B = 255 
      R = (R+3) /6 * 6 
      G = (G+3) /6 * 6
   EndIf 
   
   LineColor = RGB(R,G,B)
   For i = 0 To 257
      If _Discolor\DimColorLiner[i] = LineColor
         _Discolor\btnColorLiner\Y = i + 46
         _Discolor\btnColorLiner\B = _Discolor\btnColorLiner\Y+_Discolor\btnColorLiner\H
         Break
      EndIf 
   Next 
   Discolor_RedrawBlock(LineColor, Color)
EndProcedure


;-
;- ******** [Hook] ********
;光标在上事件[独立HOOK]
Procedure Discolor_Hook_MOUSEMOVE(*pMouse.POINTS)
   With _Discolor
      If \IsMovingLiner = #True
         \btnColorLiner\Y = *pMouse\Y-\btnColorLiner\OffsetY
         If \btnColorLiner\Y < 46+000 : \btnColorLiner\Y = 46+000 : EndIf 
         If \btnColorLiner\Y > 46+257 : \btnColorLiner\Y = 46+257 : EndIf 
         \btnColorLiner\B = \btnColorLiner\Y+\btnColorLiner\H
         \IsRefreshLiner  = #True
         \IsPickColor     = #True
         *pEventGadget    = \btnColorLiner
         SetTimer_ (\hWindow, #TIMER_ChangeColor, 10, #Null)  ;搞个定时器,是为了让颜色条滚动时,不卡顿

      ElseIf \IsMovingBlock = #True
         \btnColorBlock\X = *pMouse\X-\btnColorBlock\OffsetX
         \btnColorBlock\Y = *pMouse\Y-\btnColorBlock\OffsetY
         If \btnColorBlock\X < 60+000 : \btnColorBlock\X = 60+000 : EndIf 
         If \btnColorBlock\X > 60+255 : \btnColorBlock\X = 60+255 : EndIf 
         If \btnColorBlock\Y < 43+000 : \btnColorBlock\Y = 43+000 : EndIf 
         If \btnColorBlock\Y > 43+255 : \btnColorBlock\Y = 43+255 : EndIf          
         
         \btnColorBlock\R = \btnColorBlock\X+\btnColorBlock\W
         \btnColorBlock\B = \btnColorBlock\Y+\btnColorBlock\H
         \IsPickColor     = #True
         *pEventGadget    = \btnColorBlock
         IsRefresh = #True
         
      ElseIf Macro_Gadget_InRect2(\btnCloseBox)    : *pEventGadget = \btnCloseBox
      ElseIf Macro_Gadget_InRect2(\btnColorSure)   : *pEventGadget = \btnColorSure
      ElseIf Macro_Gadget_InRect2(\btnColorCancel) : *pEventGadget = \btnColorCancel
      ElseIf Macro_Gadget_InRect2(\btnColorLiner)  : *pEventGadget = \btnColorLiner
      ElseIf Macro_Gadget_InRect2(\btnColorBlock)  : *pEventGadget = \btnColorBlock
      ElseIf Macro_Gadget_InRect2(\btnColorLine)   : *pEventGadget = \btnColorLine
      ElseIf Macro_Gadget_InRect2(\btnColorArea)   : *pEventGadget = \btnColorArea
      ElseIf Macro_Gadget_InRect2(\btnColorTable)  : *pEventGadget = \btnColorTable
      EndIf 
      ;整理响应事件
      If \Events\pMouseTop <> *pEventGadget 
         \Events\pMouseTop = *pEventGadget 
         Discolor_RedrawScreen() 
      ElseIf IsRefresh = #True
         Discolor_RedrawScreen() 
      EndIf
   EndWith
EndProcedure

;左键按下事件[独立HOOK]
Procedure Discolor_Hook_LBUTTONDOWN(*pMouse.POINTS)
   With _Discolor
      If *pMouse = 0   
      ElseIf Macro_Gadget_InRect3(\btnCloseBox)    : *pEventGadget = \btnCloseBox
      ElseIf Macro_Gadget_InRect3(\btnColorSure)   : *pEventGadget = \btnColorSure
      ElseIf Macro_Gadget_InRect3(\btnColorCancel) : *pEventGadget = \btnColorCancel
      ElseIf Macro_Gadget_InRect2(\btnColorLiner)
         *pEventGadget = \btnColorLiner
         \IsMovingLiner = #True
         \btnColorLiner\OffsetY = *pMouse\Y-\btnColorLiner\Y
      ElseIf Macro_Gadget_InRect2(\btnColorBlock) 
         *pEventGadget = \btnColorBlock
         \IsMovingBlock = #True
         \btnColorBlock\OffsetX = *pMouse\X-\btnColorBlock\X 
         \btnColorBlock\OffsetY = *pMouse\Y-\btnColorBlock\Y
      ElseIf Macro_Gadget_InRect2(\btnColorLine)   : *pEventGadget = \btnColorLine  ;这两行一定要放在这里
      ElseIf Macro_Gadget_InRect2(\btnColorArea)   : *pEventGadget = \btnColorArea  
      ElseIf Macro_Gadget_InRect2(\btnColorTable)  : *pEventGadget = \btnColorTable  
      Else
         \IsMovingLiner = #False
         \IsMovingBlock = #False
         SendMessage_(\hWindow, #WM_NCLBUTTONDOWN, #HTCAPTION, 0)      
      EndIf 
      
      ;整理响应事件
      If \Events\pHoldDown <> *pEventGadget : \Events\pHoldDown = *pEventGadget : Discolor_RedrawScreen() : EndIf   
   EndWith
EndProcedure

;左键释放事件[独立HOOK]
Procedure Discolor_Hook_LBUTTONUP(*pMouse.POINTS)
   With _Discolor

      If *pMouse = 0   
      ElseIf Macro_Gadget_InRect3(\btnCloseBox) 
         If \Events\pHoldDown = \btnCloseBox
            *pEventGadget = \btnCloseBox
            PostEvent(#PB_Event_Gadget, #winDiscolor, #btnColorExit)
         EndIf 
      ElseIf Macro_Gadget_InRect3(\btnColorSure)
         If \Events\pHoldDown = \btnColorSure
            *pEventGadget = \btnColorSure
            PostEvent(#PB_Event_Gadget, #winDiscolor, #btnColorSure)
         EndIf
      ElseIf Macro_Gadget_InRect3(\btnColorCancel)
         If \Events\pHoldDown = \btnColorCancel
            *pEventGadget = \btnColorCancel
            PostEvent(#PB_Event_Gadget, #winDiscolor, #btnColorCancel)
         EndIf  
         
      ElseIf Macro_Gadget_InRect2(\btnColorLine)    ;这两行一定要放在这里
         If \IsMovingLiner = #False
            \btnColorLiner\Y = *pMouse\Y
            If \btnColorLiner\Y < 46+000 : \btnColorLiner\Y = 46+000 : EndIf 
            If \btnColorLiner\Y > 46+257 : \btnColorLiner\Y = 46+257 : EndIf 
            \btnColorLiner\B = \btnColorLiner\Y+\btnColorLiner\H
            IsRefresh        = #True
            \IsRefreshLiner  = #True
            \IsPickColor     = #True
            *pEventGadget    = \btnColorLine
         EndIf 
      
      ElseIf Macro_Gadget_InRect2(\btnColorArea)  
         If \IsMovingBlock = #False
            \btnColorBlock\X = *pMouse\X - 11
            \btnColorBlock\Y = *pMouse\Y - 11
            If \btnColorBlock\X < 60+000 : \btnColorBlock\X = 60+000 : EndIf 
            If \btnColorBlock\X > 60+255 : \btnColorBlock\X = 60+255 : EndIf 
            If \btnColorBlock\Y < 43+000 : \btnColorBlock\Y = 43+000 : EndIf 
            If \btnColorBlock\Y > 43+255 : \btnColorBlock\Y = 43+255 : EndIf          
            
            \btnColorBlock\R = \btnColorBlock\X+\btnColorBlock\W
            \btnColorBlock\B = \btnColorBlock\Y+\btnColorBlock\H
            \IsPickColor     = #True
            *pEventGadget    = \btnColorArea
            IsRefresh = #True
         EndIf 
         
      ElseIf Macro_Gadget_InRect2(\btnColorTable) 
         For k = 0 To 40-1
            If *pMouse\X >= _DimColorTable(k)\X And *pMouse\X <= _DimColorTable(k)\X+22 And 
               *pMouse\Y >= _DimColorTable(k)\Y And *pMouse\Y <= _DimColorTable(k)\Y+22
               Color = _DimColorTable(k)\Color
               If Color > -1
                  _Discolor\NewColor = Color
                  Discolor_Calculate(_Discolor\NewColor)
                  IsRefresh = #True
               EndIf                
            EndIf  
         Next 
         *pEventGadget = \btnColorTable  
      EndIf 
      
      ;整理响应事件
      If \Events\pHoldDown Or \Events\pHoldDown
         \Events\pHoldDown = 0 
         \Events\pMouseTop = 0
         Discolor_RedrawScreen()
      ElseIf IsRefresh = #True
         Discolor_RedrawScreen() 
      EndIf  
      \IsMovingLiner = #False
      \IsMovingBlock = #False
      
   EndWith
EndProcedure

;计时器事件[Main Hook]
Procedure Discolor_Hook_TIMER(wParam)
   With _Discolor
      Select wParam
         Case #TIMER_ChangeColor
            KillTimer_(\hWindow, #TIMER_ChangeColor)
            Discolor_RedrawScreen()
      EndSelect
   EndWith
   ProcedureReturn Result
EndProcedure

;挂钩事件[独立HOOK]
Procedure Discolor_Hook(hWindow, uMsg, wParam, lParam) 
   With _Discolor
      If \hWindow <> hWindow
         ProcedureReturn DefWindowProc_(hWindow, uMsg, wParam, lParam)
      EndIf
      Select uMsg
         Case #WM_MOUSEMOVE     : Discolor_Hook_MOUSEMOVE  (@lParam)
         Case #WM_LBUTTONDOWN   : Discolor_Hook_LBUTTONDOWN(@lParam)
         Case #WM_LBUTTONUP     : Discolor_Hook_LBUTTONUP  (@lParam)
         Case #WM_TIMER         : Discolor_Hook_TIMER      (wParam)
      EndSelect 
      Result = CallWindowProc_(\hWindowHook, hWindow, uMsg, wParam, lParam)
   EndWith
   ProcedureReturn Result
EndProcedure


;-
;- ******** [Event] ********

Procedure Discolor_Event_txtColorValue()
   If EventType() = #PB_EventType_Change
      Value = Val("$"+GetGadgetText(#txtColorValue))
      Color = (Value & $00FF00)|(Value << 16 & $FF0000)|(Value >> 16 & $0000FF)
      _Discolor\IsPickColor    = #False
      _Discolor\IsRefreshLiner = #True
      _Discolor\NewColor       = Color
      SetGadgetText(#txtColorRed,   RSet(Str(Red  (_Discolor\NewColor)), 3, "0"))
      SetGadgetText(#txtColorGreen, RSet(Str(Green(_Discolor\NewColor)), 3, "0"))
      SetGadgetText(#txtColorBlue,  RSet(Str(Blue (_Discolor\NewColor)), 3, "0"))
      Discolor_Calculate(Color)
      Discolor_RedrawScreen() 
   EndIf 
EndProcedure

Procedure Discolor_Event_txtColorRed()
   If EventType() = #PB_EventType_Change
      R = Val(GetGadgetText(#txtColorRed))
      G = Val(GetGadgetText(#txtColorGreen))
      B = Val(GetGadgetText(#txtColorBlue))      
      If R > 255 : R = 255 : SetGadgetText(#txtColorRed, "255") : EndIf 
      If R < 000 : R = 000 : SetGadgetText(#txtColorRed, "000") : EndIf 

      _Discolor\IsPickColor    = #False
      _Discolor\IsRefreshLiner = #True
      _Discolor\NewColor       = RGB(R,G,B)
      Color = (_Discolor\NewColor & $00FF00)|(_Discolor\NewColor << 16 & $FF0000)|(_Discolor\NewColor >> 16 & $0000FF)
      SetGadgetText(#txtColorValue, RSet(Hex(Color), 6, "0"))  
      Discolor_Calculate(_Discolor\NewColor)
      Discolor_RedrawScreen()
   EndIf  
EndProcedure 

Procedure Discolor_Event_txtColorGreen()
   If EventType() = #PB_EventType_Change
      R = Val(GetGadgetText(#txtColorRed))
      G = Val(GetGadgetText(#txtColorGreen))
      B = Val(GetGadgetText(#txtColorBlue))
      
      If G > 255 : G = 255 : SetGadgetText(#txtColorGreen, "255") : EndIf 
      If G < 000 : G = 000 : SetGadgetText(#txtColorGreen, "000") : EndIf      
      _Discolor\IsPickColor    = #False
      _Discolor\IsRefreshLiner = #True
      _Discolor\NewColor       = RGB(R,G,B)
      Color = (_Discolor\NewColor & $00FF00)|(_Discolor\NewColor << 16 & $FF0000)|(_Discolor\NewColor >> 16 & $0000FF)
      SetGadgetText(#txtColorValue, RSet(Hex(Color), 6, "0"))  
      Discolor_Calculate(_Discolor\NewColor)
      Discolor_RedrawScreen()
   EndIf  
EndProcedure 


Procedure Discolor_Event_txtColorBlue()
   If EventType() = #PB_EventType_Change
      R = Val(GetGadgetText(#txtColorRed))
      G = Val(GetGadgetText(#txtColorGreen))
      B = Val(GetGadgetText(#txtColorBlue))
      
      If B > 255 : B = 255 : SetGadgetText(#txtColorBlue, "255") : EndIf 
      If B < 000 : B = 000 : SetGadgetText(#txtColorBlue, "000") : EndIf       
      _Discolor\IsPickColor    = #False
      _Discolor\IsRefreshLiner = #True
      _Discolor\NewColor       = RGB(R,G,B)
      Color = (_Discolor\NewColor & $00FF00)|(_Discolor\NewColor << 16 & $FF0000)|(_Discolor\NewColor >> 16 & $0000FF)
      SetGadgetText(#txtColorValue, RSet(Hex(Color), 6, "0"))  
      Discolor_Calculate(_Discolor\NewColor)
      Discolor_RedrawScreen()
   EndIf  
EndProcedure 


;-
;- ******** [Create] ********

Procedure Discolor_CreateColorLiner(X, Y, W, H)
   With _Discolor\btnColorLiner
      \IsCreate = #True
      ForeColor = $FF000000
      HighColor = _Discolor\pColors\HighColor
      HighColor = (Alpha(HighColor) << 23 & $FF000000) |(HighColor & $FFFFFF)
      \X = X : \Y = Y : \W = W : \H = H : \R = X+W : \B = Y+H
      If IsImage(\NormalcyID) : FreeImage(\NormalcyID) : EndIf 
      If IsImage(\MouseTopID) : FreeImage(\MouseTopID) : EndIf 
      If IsImage(\HoldDownID) : FreeImage(\HoldDownID) : EndIf 
      \NormalcyID = CreateImage(#PB_Any, W, H, 32, #PB_Image_Transparent)
      If StartDrawing(ImageOutput(\NormalcyID))
         DrawingMode(#PB_2DDrawing_AllChannels)
         Box(03, 3, 04, 9, ForeColor)
         Box(07, 4, 01, 7, ForeColor)
         Box(08, 5, 01, 5, ForeColor)
         Box(09, 6, 01, 3, ForeColor)
         Box(10, 7, 29, 1, ForeColor)
         Box(39, 6, 01, 3, ForeColor)
         Box(40, 5, 01, 5, ForeColor)
         Box(41, 4, 01, 7, ForeColor)
         Box(42, 3, 04, 9, ForeColor)
         StopDrawing()
      EndIf
      
      \MouseTopID = CopyImage(\NormalcyID, #PB_Any)
      If StartDrawing(ImageOutput(\MouseTopID))
         DrawingMode(#PB_2DDrawing_AlphaClip)
         Box(0, 0, \W, \H, HighColor)
         StopDrawing()
      EndIf
      
      \HoldDownID = CopyImage(\NormalcyID, #PB_Any)
      If StartDrawing(ImageOutput(\HoldDownID))
         DrawingMode(#PB_2DDrawing_AlphaClip)
         Box(0, 0, \W, \H, HighColor)
         StopDrawing()
      EndIf      
   EndWith
EndProcedure


Procedure Discolor_CreateColorBlock(X, Y, W, H)
   With _Discolor\btnColorBlock
      \IsCreate = #True
      ForeColor = _Discolor\pColors\ForeColor
      BackColor = _Discolor\pColors\BackColor
      HighColor = _Discolor\pColors\HighColor
      HighColor = (Alpha(HighColor) << 23 & $FF000000) |(HighColor & $FFFFFF)
      \X = X : \Y = Y : \W = W : \H = H : \R = X+W : \B = Y+H
      If IsImage(\NormalcyID) : FreeImage(\NormalcyID) : EndIf 
      If IsImage(\MouseTopID) : FreeImage(\MouseTopID) : EndIf 
      If IsImage(\HoldDownID) : FreeImage(\HoldDownID) : EndIf 
      \NormalcyID = CreateImage(#PB_Any, W, H, 32, #PB_Image_Transparent)
      If StartDrawing(ImageOutput(\NormalcyID))
         DrawingMode(#PB_2DDrawing_AllChannels|#PB_2DDrawing_Outlined)
         Circle(11, 11, 08, $FFFFFFFF)         
         Circle(11, 11, 09, $FF000000)
         StopDrawing()
      EndIf
      
      \MouseTopID = CopyImage(\NormalcyID, #PB_Any)
      If StartDrawing(ImageOutput(\MouseTopID))
         DrawingMode(#PB_2DDrawing_AlphaClip)
         Box(0, 0, \W, \H, HighColor)
         StopDrawing()
      EndIf
      
      \HoldDownID = CopyImage(\NormalcyID, #PB_Any)
      If StartDrawing(ImageOutput(\HoldDownID))
         DrawingMode(#PB_2DDrawing_AlphaClip)
         Box(0, 0, \W, \H, HighColor)
         StopDrawing()
      EndIf  
   EndWith
EndProcedure

   
;-
;- ======> [External Call] <======
;信息对话框初始化
Procedure Discolor_Initial(*pWindow.__WindowInfo, *pColors)
   With _Discolor
      \pWindow      = *pWindow
      \pColors      = *pColors
      \LayerImageID = CreateImage(#PB_Any, 560, 330)
      \ImageLinerID = CreateImage(#PB_Any, 25, 258)
      \ImageBlockID = CreateImage(#PB_Any, 258, 258)
      If StartDrawing(ImageOutput(\ImageLinerID))
         DrawingMode(#PB_2DDrawing_Default)  
         Box(0, 0, 025, 258, $FFFFFF)
         X = 0 : Y = 0
         For B = 000 To 252 Step 06 : \DimColorLiner[Y] = RGB(255, 000, B) : Line(X, Y, 025, 1, \DimColorLiner[Y]) : Y+1 : Next 
         For R = 252 To 000 Step -6 : \DimColorLiner[Y] = RGB(R, 000, 255) : Line(X, Y, 025, 1, \DimColorLiner[Y]) : Y+1 : Next 
         For G = 000 To 252 Step 06 : \DimColorLiner[Y] = RGB(000, G, 255) : Line(X, Y, 025, 1, \DimColorLiner[Y]) : Y+1 : Next 
         For B = 252 To 000 Step -6 : \DimColorLiner[Y] = RGB(000, 255, B) : Line(X, Y, 025, 1, \DimColorLiner[Y]) : Y+1 : Next 
         For R = 000 To 252 Step 06 : \DimColorLiner[Y] = RGB(R, 255, 000) : Line(X, Y, 025, 1, \DimColorLiner[Y]) : Y+1 : Next 
         For G = 252 To 000 Step -6 : \DimColorLiner[Y] = RGB(255, G, 000) : Line(X, Y, 025, 1, \DimColorLiner[Y]) : Y+1 : Next 
         StopDrawing()
      EndIf  
      Define_CreateCloseBox(*pColors, \btnCloseBox)    ;创建关闭窗体小按键
      Define_CreateButton  (*pColors, \btnColorSure,   000, 000, 090, 30, "确定",   *pWindow\Font12ID)
      Define_CreateButton  (*pColors, \btnColorCancel, 000, 000, 090, 30, "取消",   *pWindow\Font12ID)
      Discolor_CreateColorLiner (08, 46, 50, 15)
      Discolor_CreateColorBlock(60, 43, 21, 21)
   EndWith
   With _Discolor\btnColorLine
      \X = 008 : \Y = 047 : \W = 052 : \H=256+16 : \R = \X + \W : \B = \Y + \H 
   EndWith
   With _Discolor\btnColorArea
      \X = 060 : \Y = 043 : \W = 256+20 : \H=256+20 : \R = \X + \W : \B = \Y + \H 
   EndWith
   
   With _Discolor\btnColorTable
      \X = 345 : \Y = 050 : \W = 200 : \H=125 : \R = \X + \W : \B = \Y + \H 
   EndWith  
   
   Index = 0
   For j = 0 To 4
      For i = 0 To 7
         _DimColorTable(Index)\X = 346+i*25
         _DimColorTable(Index)\Y = 053+j*25
         Index+1
      Next 
   Next 
   
EndProcedure


;信息对话框初始化
Procedure Discolor_ChangeStyle(*pColors)
   With _Discolor
      \pColors      = *pColors
      Define_CreateCloseBox(*pColors, \btnCloseBox)    ;创建关闭窗体小按键
      Define_CreateButton  (*pColors, \btnColorSure,   000, 000, 090, 30, "确定",   \pWindow\Font12ID)
      Define_CreateButton  (*pColors, \btnColorCancel, 000, 000, 090, 30, "取消",   \pWindow\Font12ID)
      Discolor_CreateColorLiner (08, 46, 50, 15)
      Discolor_CreateColorBlock (60, 43, 21, 21)
   EndWith
   
EndProcedure


;注销信息对话框
Procedure Discolor_Release()
   With _Discolor
      Define_FreeGadget(\btnCloseBox)
      Define_FreeGadget(\btnColorSure)
      Define_FreeGadget(\btnColorCancel)
      Define_FreeGadget(\btnColorLiner)
      Define_FreeGadget(\btnColorBlock)
      FreeImage(\LayerImageID)
      FreeImage(\ImageLinerID)      
      FreeImage(\ImageBlockID)      
   EndWith
EndProcedure

;信息对话框初始化
Procedure Discolor_Requester(hParent, Color, Title$)
   With _Discolor
      Discolor_Calculate(Color)
      \WindowW = 560
      \WindowH = 330
      \NewColor= Color
      \OldColor= Color
      \Flags   = Flags
      \TitleH  = 38
      \Title$  = "修改["+Title$+"]颜色"
      \IsExitWindow = #False      
      If hParent = #Null
         WindowFlags = #PB_Window_BorderLess|#PB_Window_ScreenCentered
         \hWindow = OpenWindow(#winDiscolor, 0, 0, \WindowW, \WindowH, "", WindowFlags)
      Else 
         WindowFlags = #PB_Window_BorderLess|#PB_Window_WindowCentered
         \hWindow = OpenWindow(#winDiscolor, 0, 0, \WindowW, \WindowH, "", WindowFlags, hParent)
      EndIf
      
      X = 385 : Y = 195
      Color = (\NewColor & $00FF00)|(\NewColor << 16 & $FF0000)|(\NewColor >> 16 & $0000FF)
      StringGadget(#txtColorValue, X, Y+50, 080, 020, RSet(Hex(Color), 6, "0"))  
      X + 115 : Y = 195
      StringGadget(#txtColorRed,   X, Y+00, 040, 020, RSet(Str(Red(\NewColor)),   3, "0"), #PB_String_Numeric)
      StringGadget(#txtColorGreen, X, Y+25, 040, 020, RSet(Str(Green(\NewColor)), 3, "0"), #PB_String_Numeric)
      StringGadget(#txtColorBlue,  X, Y+50, 040, 020, RSet(Str(Blue(\NewColor)),  3, "0"), #PB_String_Numeric)

      SetGadgetFont(#txtColorRed,   FontID(\pWindow\Font12ID))
      SetGadgetFont(#txtColorGreen, FontID(\pWindow\Font12ID))
      SetGadgetFont(#txtColorBlue,  FontID(\pWindow\Font12ID))
      SetGadgetFont(#txtColorValue, FontID(\pWindow\Font12ID))

      Discolor_RedrawScreen()
      \hWindowHook = SetWindowLongPtr_(\hWindow, #GWL_WNDPROC, @Discolor_Hook()) 
      If hParent
         EnableWindow_(hParent, #False)   ;禁用父窗体的响应动作
      EndIf 
      Repeat
         Select WindowEvent()
            Case #PB_Event_CloseWindow    : \IsExitWindow = #True
            Case #PB_Event_Gadget
               Select EventGadget()
                  Case #btnColorExit      : \IsExitWindow = #True : Result = -1
                  Case #btnColorSure      : \IsExitWindow = #True : Result = \NewColor
                  Case #btnColorCancel    : \IsExitWindow = #True : Result = -1
                  Case #txtColorValue     : Discolor_Event_txtColorValue()
                  Case #txtColorRed       : Discolor_Event_txtColorRed()
                  Case #txtColorGreen     : Discolor_Event_txtColorGreen()
                  Case #txtColorBlue      : Discolor_Event_txtColorBlue()
               EndSelect
            Default 
         EndSelect
      Until \IsExitWindow = #True 
      If Result <> -1
         If _DimColorTable(8)\Color = Result
            IsFind = #True
         EndIf 
         If IsFind = #False
            For k = 9 To 40-1
               If _DimColorTable(k)\Color = Result
                  For x = k To 9 Step -1
                     _DimColorTable(x)\Color = _DimColorTable(x-1)\Color
                  Next  
                  IsFind = #True
               EndIf 
            Next 
         EndIf 
         
         If IsFind = #False 
            For x = 40-1 To 9 Step -1
               _DimColorTable(x)\Color = _DimColorTable(x-1)\Color
            Next         
         EndIf 
         _DimColorTable(8)\Color = Result
      EndIf 
      If \hLayerImage  ;释放窗体背景句柄
         DeleteObject_(\hLayerImage) 
         \hLayerImage = 0
      EndIf 
      If hParent
         EnableWindow_(hParent, #True)   ;恢复父窗体的响应动作
      EndIf 
      CloseWindow(#winDiscolor)
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
   hWindow = OpenWindow(#winScreen, 0, 0, 500, 250, "Discolor-测试" , WindowFlags)
   Discolor_Initial(@Window, @Color)
   ;======================
   Discolor_Requester(hWindow, $Fe202e, "对象")
   Repeat
      WindowEvent = WindowEvent()
      Select WindowEvent
         Case #PB_Event_CloseWindow : IsExitWindow = #True
         Case #WM_LBUTTONUP : Discolor_Requester(hWindow, Random($FFFFFF), "对象")
         Case #WM_RBUTTONUP : Discolor_Requester(hWindow, Random($FFFFFF), "对象")
      EndSelect
   Until IsExitWindow = #True 
   FreeFont(Window\Font12ID)   
   Discolor_Release()
   End
CompilerEndIf 














; IDE Options = PureBasic 5.62 (Windows - x86)
; CursorPosition = 14
; Folding = -fX-
; EnableXP
; Executable = DEMO.exe