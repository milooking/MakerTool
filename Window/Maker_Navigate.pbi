;*****************************************
;******** 单片机仿真模拟器窗体界面 ********
;********    迷路仟 2020.02.24    ********
;*****************************************
;【Maker_Navigate.pbi】 导航条源代码


;-[Enumeration]
Enumeration Screen
   #winNavigate
EndEnumeration


;-[IncludeFile]
XIncludeFile ".\Maker_Define.pbi"      ;定义类源代码

;-[Structure]
;对话框结构
Structure __Navigate_MainInfo Extends __AreaInfo
   *pColors.__ColorInfo
   *pWindow.__WindowInfo
   *pEvents.__EventInfo
   ;=========
   hWindow.l
   hWindowHook.l
   OffsetX.l
   OffsetY.l
   OffsetR.l
   OffsetB.l
   ScrollX.l
   ScrollY.l
   IsMoving.b
   IsRefresh.b
   IsLockedR.b
   IsLockedB.b
   ;=========
   btnMovingBar.__GadgetInfo    
   btnScrollUp.__GadgetInfo  
   btnScrollDown.__GadgetInfo  
   btnScrollLeft.__GadgetInfo  
   btnScrollRight.__GadgetInfo  
   btnScrollHome.__GadgetInfo  
   btnScaleUp.__GadgetInfo  
   btnScaleDown.__GadgetInfo 
EndStructure

;-[Global]
Global _Navigate.__Navigate_MainInfo


;-
;- ******** [Redraw] ********
;绘制事件
Procedure Navigate_RedrawScreen()
   ;16x12
   DrawingMode(#PB_2DDrawing_Transparent) 
   With _Navigate  
      LimitB = \pWindow\WindowH-145
      LimitR = \pWindow\WindowW-062
      If \IsLockedB = #True 
         \Y = LimitB-\OffsetB
      Else 
         \Y = \ScrollY
         If \Y < 45 
            \Y = 45 
         ElseIf \Y > LimitB
            \Y = LimitB
         EndIf 
      EndIf 
      
      If \IsLockedR = #True 
         \X = LimitR-\OffsetR
      Else 
         \X = \ScrollX
         If \X < 5 And \Y > 300
            \X = 5
         ElseIf \X < 55 And \Y < 300
            \X = 55
         ElseIf \X > LimitR
            \X = LimitR
         EndIf  
      EndIf  
      \R = \X+\W
      \B = \Y+\H
      \pWindow\NaviOffsetX   = \X
      \pWindow\NaviOffsetY   = \Y
      \pWindow\NaviOffsetR   = \OffsetR
      \pWindow\NaviOffsetB   = \OffsetB      
      \pWindow\IsNaviLockedR = \IsLockedR
      \pWindow\IsNaviLockedB = \IsLockedB

      DrawingMode(#PB_2DDrawing_Transparent|#PB_2DDrawing_AlphaBlend)
      If \pEvents\pMouseTop = \btnMovingBar Or \pEvents\pHoldDown = \btnMovingBar 
         FontColor = _Navigate\pColors\HighColor
         FontColor = (((Alpha(FontColor)-25) << 24) & $FF000000) |(FontColor & $FFFFFF)
         LockColor = ((Alpha(FontColor) << 23) & $FF000000) |(FontColor & $FFFFFF)
         If \IsLockedR : Box(\pWindow\WindowW-17, 0, 10, \pWindow\WindowH, LockColor) : EndIf 
         If \IsLockedB : Box(0, \pWindow\WindowH-18, \pWindow\WindowW, 10, LockColor) : EndIf 
      Else 
         FontColor = \pColors\BackColor
      EndIf 
      
      Define_RedrawGadget(\pEvents, \btnMovingBar,  \X+00, \Y+000)
      Define_RedrawGadget(\pEvents, \btnScrollUp,   \X+15, \Y+000)
      Define_RedrawGadget(\pEvents, \btnScrollDown, \X+15, \Y+034)
      Define_RedrawGadget(\pEvents, \btnScrollLeft, \X+00, \Y+015)
      Define_RedrawGadget(\pEvents, \btnScrollRight,\X+34, \Y+015) 
      Define_RedrawGadget(\pEvents, \btnScrollHome, \X+14, \Y+055)
      Define_RedrawGadget(\pEvents, \btnScaleUp,    \X+14, \Y+080)
      Define_RedrawGadget(\pEvents, \btnScaleDown,  \X+14, \Y+105)
      
      DrawingFont(FontID(\pWindow\Font09ID))
      Text$ = Str(\pWindow\LayerZoom*100)
      TextX = (\W-TextWidth (Text$))/2
      TextY = (\W-TextHeight(Text$))/2
      DrawText(\X+TextX, \Y+TextY, Text$, FontColor)
   EndWith
EndProcedure

;-
;- ******** [Hook] ********
;光标在上事件[Screen_HookWindow()]
Procedure Navigate_Hook_MOUSEMOVE(*pMouse.POINTS)
   With _Navigate
      If \IsMoving = #True
         \ScrollX = *pMouse\X-\OffsetX
         \ScrollY = *pMouse\Y-\OffsetY
         \IsRefresh = #True
         \IsLockedB = #False
         LimitB = \pWindow\WindowH-145
         LimitR = \pWindow\WindowW-062
         If \ScrollY < 45 
            \ScrollY = 45 
         ElseIf Abs(\ScrollY - LimitB) < 50
            \IsLockedB = #True      ;锁定底部
            If \ScrollY < LimitB
               \OffsetB = LimitB-\ScrollY 
            Else 
               \ScrollY = LimitB
               \OffsetB = 0
            EndIf 
         Else 
            *pEventGadget = \btnMovingBar
         EndIf 
         
         \IsLockedR = #False
         If \ScrollX < 5 And \ScrollY > 300
            \ScrollX = 5
         ElseIf \ScrollX < 55 And \ScrollY < 300
            \ScrollX = 55
         ElseIf Abs(\ScrollX - LimitR) < 50
            \IsLockedR = #True      ;锁定右侧
            If \ScrollX < LimitR
               \OffsetR   = LimitR-\ScrollX
            Else 
               \ScrollX   = LimitR
               \OffsetR   = LimitR-\ScrollX
            EndIf 
         EndIf  
         *pEventGadget = \btnMovingBar
      ElseIf Macro_Gadget_InRect2(\btnScrollUp)    : *pEventGadget = \btnScrollUp
      ElseIf Macro_Gadget_InRect2(\btnScrollDown)  : *pEventGadget = \btnScrollDown
      ElseIf Macro_Gadget_InRect2(\btnScrollLeft)  : *pEventGadget = \btnScrollLeft
      ElseIf Macro_Gadget_InRect2(\btnScrollRight) : *pEventGadget = \btnScrollRight 
      ElseIf Macro_Gadget_InRect2(\btnScrollHome)  : *pEventGadget = \btnScrollHome
      ElseIf Macro_Gadget_InRect2(\btnMovingBar)   : *pEventGadget = \btnMovingBar
      ElseIf Macro_Gadget_InRect2(\btnScaleUp)     : *pEventGadget = \btnScaleUp
      ElseIf Macro_Gadget_InRect2(\btnScaleDown)   : *pEventGadget = \btnScaleDown
      EndIf 
   EndWith
   ProcedureReturn *pEventGadget
EndProcedure

;左键按下事件[Screen_HookWindow()]
Procedure Navigate_Hook_LBUTTONDOWN(*pMouse.POINTS)
   With _Navigate
      \IsMoving = #False
      If *pMouse = 0 
      ElseIf Macro_Gadget_InRect2(\btnScrollUp)    : *pEventGadget = \btnScrollUp
      ElseIf Macro_Gadget_InRect2(\btnScrollDown)  : *pEventGadget = \btnScrollDown
      ElseIf Macro_Gadget_InRect2(\btnScrollLeft)  : *pEventGadget = \btnScrollLeft
      ElseIf Macro_Gadget_InRect2(\btnScrollRight) : *pEventGadget = \btnScrollRight
      ElseIf Macro_Gadget_InRect2(\btnMovingBar)   
         *pEventGadget = \btnMovingBar 
         \ScrollX = \btnMovingBar\X
         \ScrollY = \btnMovingBar\Y
         \OffsetX = *pMouse\X-\ScrollX 
         \OffsetY = *pMouse\Y-\ScrollY
         \pEvents\pMoving = \btnMovingBar 
         \IsMoving = #True
         \IsRefresh = #True
      ElseIf Macro_Gadget_InRect2(\btnScrollHome)  : *pEventGadget = \btnScrollHome
      ElseIf Macro_Gadget_InRect2(\btnScaleUp)     : *pEventGadget = \btnScaleUp
      ElseIf Macro_Gadget_InRect2(\btnScaleDown)   : *pEventGadget = \btnScaleDown
      EndIf 
   EndWith
   ProcedureReturn *pEventGadget
EndProcedure

;左键释放事件[Screen_HookWindow()]
Procedure Navigate_Hook_LBUTTONUP(*pMouse.POINTS)
   With _Navigate
      
      *pEventGadget.__GadgetInfo
      If *pMouse = 0 
      ElseIf Macro_Gadget_InRect2(\btnScrollUp)    : *pEventGadget = \btnScrollUp
      ElseIf Macro_Gadget_InRect2(\btnScrollDown)  : *pEventGadget = \btnScrollDown
      ElseIf Macro_Gadget_InRect2(\btnScrollLeft)  : *pEventGadget = \btnScrollLeft
      ElseIf Macro_Gadget_InRect2(\btnScrollRight) : *pEventGadget = \btnScrollRight
      ElseIf Macro_Gadget_InRect2(\btnMovingBar)   : *pEventGadget = \btnMovingBar         
      ElseIf Macro_Gadget_InRect2(\btnScrollHome)  : *pEventGadget = \btnScrollHome
      ElseIf Macro_Gadget_InRect2(\btnScaleUp)     : *pEventGadget = \btnScaleUp
      ElseIf Macro_Gadget_InRect2(\btnScaleDown)   : *pEventGadget = \btnScaleDown
      EndIf 
      If *pEventGadget
         PostEvent(#PB_Event_Gadget, \pWindow\WindowID, *pEventGadget\GadgetID)
      EndIf 
      If \IsMoving = #True 
         \pEvents\pMoving = #Null
         \IsRefresh = #True
         \IsMoving = #False 
         If \pEvents\pMouseTop = \btnMovingBar : \pEvents\pMouseTop = #Null : EndIf 
         If \pEvents\pHoldDown = \btnMovingBar : \pEvents\pHoldDown = #Null : EndIf 
      EndIf 
   EndWith
   ProcedureReturn *pEventGadget
EndProcedure

;-
;- ******** [Create] ********
;创建移动导航条的按键
Procedure Define_CreatebtnMovingBar(W, H)
   BackColor = _Navigate\pColors\BackColor
   BackColor = (Alpha(BackColor) << 23 & $FF000000) |(BackColor & $FFFFFF)
   With _Navigate\btnMovingBar
      \IsCreate = #True
      \GadgetID = #btnMovingBar
      \W = W : \H= H
      If IsImage(\NormalcyID) : FreeImage(\NormalcyID) : EndIf 
      If IsImage(\MouseTopID) : FreeImage(\MouseTopID) : EndIf 
      If IsImage(\HoldDownID) : FreeImage(\HoldDownID) : EndIf 
      \NormalcyID = CreateImage(#PB_Any, \W, 130, 32, #PB_Image_Transparent)
      If StartVectorDrawing(ImageVectorOutput(\NormalcyID))
         VectorSourceColor(BackColor)
         AddPathCircle (26, 26, 26)
         AddPathBox(14, 055, 24, 24)          
         AddPathBox(14, 080, 24, 24)          
         AddPathBox(14, 105, 24, 24)          
         FillPath()
         StopVectorDrawing()
      EndIf
      
      \MouseTopID = CreateImage(#PB_Any, \W, 130, 32, #PB_Image_Transparent)
      If StartVectorDrawing(ImageVectorOutput(\MouseTopID))
         VectorSourceColor(BackColor)
         AddPathCircle (26, 26, 26)
         AddPathBox(14, 055, 24, 24)          
         AddPathBox(14, 080, 24, 24)          
         AddPathBox(14, 105, 24, 24)          
         FillPath()
         StopVectorDrawing()
      EndIf
      
      \HoldDownID = CreateImage(#PB_Any, \W, 130, 32, #PB_Image_Transparent)
      If StartVectorDrawing(ImageVectorOutput(\HoldDownID))
         VectorSourceColor(BackColor)
         AddPathCircle (26, 26, 26)
         AddPathBox(14, 055, 24, 24)          
         AddPathBox(14, 080, 24, 24)          
         AddPathBox(14, 105, 24, 24)          
         FillPath()
         StopVectorDrawing()
      EndIf
      
   EndWith 
   
EndProcedure

;创建[上移]方向键
Procedure Define_CreatebtnScrollUp(W, H)
   BackColor1 = _Navigate\pColors\BackColor
   BackColor2 = _Navigate\pColors\HighColor
   BackColor3 = (((Alpha(BackColor2)-25) << 24) & $FF000000) |(BackColor2 & $FFFFFF)
   With _Navigate\btnScrollUp
      \IsCreate = #True
      \GadgetID = #btnScrollUp
      \W = W : \H= H
      If IsImage(\NormalcyID) : FreeImage(\NormalcyID) : EndIf 
      If IsImage(\MouseTopID) : FreeImage(\MouseTopID) : EndIf 
      If IsImage(\HoldDownID) : FreeImage(\HoldDownID) : EndIf 
      
      \NormalcyID = CreateImage(#PB_Any, \W, \H, 32, #PB_Image_Transparent)
      If StartVectorDrawing(ImageVectorOutput(\NormalcyID))
         VectorSourceColor(BackColor1)
         MovePathCursor(05, 11) : AddPathLine(11, 06) : AddPathLine(17, 11)  ;上箭头
         StrokePath(2) 
         StopVectorDrawing()
      EndIf      
      
      \MouseTopID = CreateImage(#PB_Any, \W, \H, 32, #PB_Image_Transparent)
      If StartVectorDrawing(ImageVectorOutput(\MouseTopID))
         VectorSourceColor(BackColor3)
         MovePathCursor(05, 11) : AddPathLine(11, 06) : AddPathLine(17, 11)  ;上箭头
         StrokePath(2) 
         StopVectorDrawing()
      EndIf
      \HoldDownID = CreateImage(#PB_Any, \W, \H, 32, #PB_Image_Transparent)
      If StartVectorDrawing(ImageVectorOutput(\HoldDownID))
         VectorSourceColor(BackColor2)
         MovePathCursor(05, 11) : AddPathLine(11, 06) : AddPathLine(17, 11)  ;上箭头
         StrokePath(2) 
         StopVectorDrawing()
      EndIf  
   EndWith 
   
EndProcedure

;创建[下移]方向键
Procedure Define_CreatebtnScrollDown(W, H)
   BackColor1 = _Navigate\pColors\BackColor
   BackColor2 = _Navigate\pColors\HighColor
   BackColor3 = (((Alpha(BackColor2)-25) << 24) & $FF000000) |(BackColor2 & $FFFFFF)
   With _Navigate\btnScrollDown
      \IsCreate = #True
      \GadgetID = #btnScrollDown
      \W = W : \H= H
      If IsImage(\NormalcyID) : FreeImage(\NormalcyID) : EndIf 
      If IsImage(\MouseTopID) : FreeImage(\MouseTopID) : EndIf 
      If IsImage(\HoldDownID) : FreeImage(\HoldDownID) : EndIf 
      
      \NormalcyID = CreateImage(#PB_Any, \W, \H, 32, #PB_Image_Transparent)
      If StartVectorDrawing(ImageVectorOutput(\NormalcyID))
         VectorSourceColor(BackColor1)
         MovePathCursor(05, 07) : AddPathLine(11, 12) : AddPathLine(17, 07)  ;下箭头
         StrokePath(2) 
         StopVectorDrawing()
      EndIf      
      
      \MouseTopID = CreateImage(#PB_Any, \W, \H, 32, #PB_Image_Transparent)
      If StartVectorDrawing(ImageVectorOutput(\MouseTopID))
         VectorSourceColor(BackColor3)
         MovePathCursor(05, 05) : AddPathLine(11, 10) : AddPathLine(17, 05)  ;下箭头
         StrokePath(2) 
         StopVectorDrawing()
      EndIf
      \HoldDownID = CreateImage(#PB_Any, \W, \H, 32, #PB_Image_Transparent)
      If StartVectorDrawing(ImageVectorOutput(\HoldDownID))
         VectorSourceColor(BackColor2)
         MovePathCursor(05, 05) : AddPathLine(11, 10) : AddPathLine(17, 05)  ;下箭头
         StrokePath(2) 
         StopVectorDrawing()
      EndIf  
   EndWith 
   
EndProcedure

;创建[左移]方向键
Procedure Define_CreatebtnScrollLeft(W, H)
   BackColor1 = _Navigate\pColors\BackColor
   BackColor2 = _Navigate\pColors\HighColor
   BackColor3 = (((Alpha(BackColor2)-25) << 24) & $FF000000) |(BackColor2 & $FFFFFF)
   With _Navigate\btnScrollLeft
      \IsCreate = #True
      \GadgetID = #btnScrollLeft
      \W = W : \H= H
      If IsImage(\NormalcyID) : FreeImage(\NormalcyID) : EndIf 
      If IsImage(\MouseTopID) : FreeImage(\MouseTopID) : EndIf 
      If IsImage(\HoldDownID) : FreeImage(\HoldDownID) : EndIf 
      
      \NormalcyID = CreateImage(#PB_Any, \W, \H, 32, #PB_Image_Transparent)
      If StartVectorDrawing(ImageVectorOutput(\NormalcyID))
         VectorSourceColor(BackColor1)
         MovePathCursor(11, 05) : AddPathLine(06, 11) : AddPathLine(11, 17)  ;右箭头
         StrokePath(2) 
         StopVectorDrawing()
      EndIf      
      
      \MouseTopID = CreateImage(#PB_Any, \W, \H, 32, #PB_Image_Transparent)
      If StartVectorDrawing(ImageVectorOutput(\MouseTopID))
         VectorSourceColor(BackColor3)
         MovePathCursor(11, 05) : AddPathLine(06, 11) : AddPathLine(11, 17)  ;右箭头
         StrokePath(2) 
         StopVectorDrawing()
      EndIf
      \HoldDownID = CreateImage(#PB_Any, \W, \H, 32, #PB_Image_Transparent)
      If StartVectorDrawing(ImageVectorOutput(\HoldDownID))
         VectorSourceColor(BackColor2)
         MovePathCursor(11, 05) : AddPathLine(06, 11) : AddPathLine(11, 17)  ;右箭头
         StrokePath(2) 
         StopVectorDrawing()
      EndIf  
   EndWith 
   
EndProcedure

;创建[右移]方向键
Procedure Define_CreatebtnScrollRight(W, H)
   BackColor1 = _Navigate\pColors\BackColor
   BackColor2 = _Navigate\pColors\HighColor
   BackColor3 = (((Alpha(BackColor2)-25) << 24) & $FF000000) |(BackColor2 & $FFFFFF)
   With _Navigate\btnScrollRight
      \IsCreate = #True
      \GadgetID = #btnScrollRight
      \W = W : \H= H
      If IsImage(\NormalcyID) : FreeImage(\NormalcyID) : EndIf 
      If IsImage(\MouseTopID) : FreeImage(\MouseTopID) : EndIf 
      If IsImage(\HoldDownID) : FreeImage(\HoldDownID) : EndIf 
      
      \NormalcyID = CreateImage(#PB_Any, \W, \H, 32, #PB_Image_Transparent)
      If StartVectorDrawing(ImageVectorOutput(\NormalcyID))
         VectorSourceColor(BackColor1)
         MovePathCursor(07, 05) : AddPathLine(12, 11) : AddPathLine(07, 17)  ;右箭头
         StrokePath(2) 
         StopVectorDrawing()
      EndIf      
      
      \MouseTopID = CreateImage(#PB_Any, \W, \H, 32, #PB_Image_Transparent)
      If StartVectorDrawing(ImageVectorOutput(\MouseTopID))
         VectorSourceColor(BackColor3)
         MovePathCursor(07, 05) : AddPathLine(12, 11) : AddPathLine(07, 17)  ;右箭头
         StrokePath(2) 
         StopVectorDrawing()
      EndIf
      \HoldDownID = CreateImage(#PB_Any, \W, \H, 32, #PB_Image_Transparent)
      If StartVectorDrawing(ImageVectorOutput(\HoldDownID))
         VectorSourceColor(BackColor2)
         MovePathCursor(07, 05) : AddPathLine(12, 11) : AddPathLine(07, 17)  ;右箭头
         StrokePath(2) 
         StopVectorDrawing()
      EndIf  
   EndWith 
   
EndProcedure

;-
;创建[主页]
Procedure Define_CreatebtnScrollHome(W, H)
   BackColor1 = _Navigate\pColors\BackColor
   BackColor2 = _Navigate\pColors\HighColor
   BackColor3 = (((Alpha(BackColor2)-25) << 24) & $FF000000) |(BackColor2 & $FFFFFF)
   With _Navigate\btnScrollHome
      \IsCreate = #True
      \GadgetID = #btnScrollHome
      \W = W : \H= H
      If IsImage(\NormalcyID) : FreeImage(\NormalcyID) : EndIf 
      If IsImage(\MouseTopID) : FreeImage(\MouseTopID) : EndIf 
      If IsImage(\HoldDownID) : FreeImage(\HoldDownID) : EndIf 
      
      \NormalcyID = CreateImage(#PB_Any, \W, \H, 32, #PB_Image_Transparent)
      If StartVectorDrawing(ImageVectorOutput(\NormalcyID))
         VectorSourceColor(BackColor1)
         AddPathCircle (12, 12, 6)
         MovePathCursor(05, 12) : AddPathLine(02, 12)
         MovePathCursor(19, 12) : AddPathLine(22, 12)
         MovePathCursor(12, 05) : AddPathLine(12, 02)
         MovePathCursor(12, 19) : AddPathLine(12, 22)
         StrokePath(2)   
         AddPathCircle (12, 12, 3)
         FillPath() 
         StopVectorDrawing()
      EndIf      
      
      \MouseTopID = CreateImage(#PB_Any, \W, \H, 32, #PB_Image_Transparent)
      If StartVectorDrawing(ImageVectorOutput(\MouseTopID))
         VectorSourceColor(BackColor3)
         AddPathCircle (12, 12, 6)
         MovePathCursor(05, 12) : AddPathLine(02, 12)
         MovePathCursor(19, 12) : AddPathLine(22, 12)
         MovePathCursor(12, 05) : AddPathLine(12, 02)
         MovePathCursor(12, 19) : AddPathLine(12, 22)
         StrokePath(2)   
         AddPathCircle (12, 12, 3)
         FillPath() 
         StopVectorDrawing()
      EndIf
      \HoldDownID = CreateImage(#PB_Any, \W, \H, 32, #PB_Image_Transparent)
      If StartVectorDrawing(ImageVectorOutput(\HoldDownID))
         VectorSourceColor(BackColor2)
         AddPathCircle (12, 12, 6)
         MovePathCursor(05, 12) : AddPathLine(02, 12)
         MovePathCursor(19, 12) : AddPathLine(22, 12)
         MovePathCursor(12, 05) : AddPathLine(12, 02)
         MovePathCursor(12, 19) : AddPathLine(12, 22)
         StrokePath(2)   
         AddPathCircle (12, 12, 3)
         FillPath() 
         StopVectorDrawing()
      EndIf  
   EndWith 
   
EndProcedure

;创建[扩大比例]
Procedure Define_CreatebtnScaleUp(W, H)
   BackColor1 = _Navigate\pColors\BackColor
   BackColor2 = _Navigate\pColors\HighColor
   BackColor3 = (((Alpha(BackColor2)-25) << 24) & $FF000000) |(BackColor2 & $FFFFFF)
   With _Navigate\btnScaleUp
      \IsCreate = #True
      \GadgetID = #btnScaleUp
      \W = W : \H= H
      If IsImage(\NormalcyID) : FreeImage(\NormalcyID) : EndIf 
      If IsImage(\MouseTopID) : FreeImage(\MouseTopID) : EndIf 
      If IsImage(\HoldDownID) : FreeImage(\HoldDownID) : EndIf 
      
      \NormalcyID = CreateImage(#PB_Any, \W, \H, 32, #PB_Image_Transparent)
      If StartVectorDrawing(ImageVectorOutput(\NormalcyID))
         VectorSourceColor(BackColor1)
         MovePathCursor(05, 12) : AddPathLine(19, 12)
         MovePathCursor(12, 05) : AddPathLine(12, 19)
         StrokePath(2.5)
         StopVectorDrawing()
      EndIf      
      
      \MouseTopID = CreateImage(#PB_Any, \W, \H, 32, #PB_Image_Transparent)
      If StartVectorDrawing(ImageVectorOutput(\MouseTopID))
         VectorSourceColor(BackColor3)
         MovePathCursor(05, 12) : AddPathLine(19, 12)
         MovePathCursor(12, 05) : AddPathLine(12, 19)
         StrokePath(2.5)
         StopVectorDrawing()
      EndIf
      \HoldDownID = CreateImage(#PB_Any, \W, \H, 32, #PB_Image_Transparent)
      If StartVectorDrawing(ImageVectorOutput(\HoldDownID))
         VectorSourceColor(BackColor2)
         MovePathCursor(05, 12) : AddPathLine(19, 12)
         MovePathCursor(12, 05) : AddPathLine(12, 19)
         StrokePath(2.5)
         StopVectorDrawing()
      EndIf  
   EndWith 
   
EndProcedure

;创建[缩小比例]
Procedure Define_CreatebtnScaleDown(W, H)
   BackColor1 = _Navigate\pColors\BackColor
   BackColor2 = _Navigate\pColors\HighColor
   BackColor3 = (((Alpha(BackColor2)-25) << 24) & $FF000000) |(BackColor2 & $FFFFFF)
   With _Navigate\btnScaleDown
      \IsCreate = #True
      \GadgetID = #btnScaleDown
      \W = W : \H= H
      If IsImage(\NormalcyID) : FreeImage(\NormalcyID) : EndIf 
      If IsImage(\MouseTopID) : FreeImage(\MouseTopID) : EndIf 
      If IsImage(\HoldDownID) : FreeImage(\HoldDownID) : EndIf 
      
      \NormalcyID = CreateImage(#PB_Any, \W, \H, 32, #PB_Image_Transparent)
      If StartVectorDrawing(ImageVectorOutput(\NormalcyID))
         VectorSourceColor(BackColor1)
         MovePathCursor(05, 12) : AddPathLine(19, 12)
         StrokePath(3)
         StopVectorDrawing()
      EndIf      
      
      \MouseTopID = CreateImage(#PB_Any, \W, \H, 32, #PB_Image_Transparent)
      If StartVectorDrawing(ImageVectorOutput(\MouseTopID))
         VectorSourceColor(BackColor3)
         MovePathCursor(05, 12) : AddPathLine(19, 12)
         StrokePath(3)
         StopVectorDrawing()
      EndIf
      \HoldDownID = CreateImage(#PB_Any, \W, \H, 32, #PB_Image_Transparent)
      If StartVectorDrawing(ImageVectorOutput(\HoldDownID))
         VectorSourceColor(BackColor2)
         MovePathCursor(05, 12) : AddPathLine(19, 12)
         StrokePath(3)
         StopVectorDrawing()
      EndIf  
   EndWith 
   
EndProcedure
    
;-
;- ======> [External Call] <======
;工具栏导航条
Procedure Navigate_Initial(*pWindow.__WindowInfo, *pColors, *pEvents)
   
   With _Navigate
      \pColors   = *pColors
      \pEvents   = *pEvents
      \pWindow   = *pWindow
      \W         = 52
      \H         = 130
      \ScrollX   = \pWindow\NaviOffsetX
      \ScrollY   = \pWindow\NaviOffsetY
      \OffsetR   = \pWindow\NaviOffsetR
      \OffsetB   = \pWindow\NaviOffsetB
      \IsLockedR = \pWindow\IsNaviLockedR
      \IsLockedB = \pWindow\IsNaviLockedB
      
      Define_CreatebtnMovingBar  (52, 52)
      Define_CreatebtnScrollUp   (22, 18)
      Define_CreatebtnScrollDown (22, 18)
      Define_CreatebtnScrollLeft (22, 18)
      Define_CreatebtnScrollRight(22, 18)   
      Define_CreatebtnScrollHome (24, 24)
      Define_CreatebtnScaleUp    (24, 24)
      Define_CreatebtnScaleDown  (24, 24)
   EndWith
EndProcedure

Procedure Navigate_ChangeStyle(*pColors)
   _Navigate\pColors   = *pColors
   Define_CreatebtnMovingBar  (52, 52)
   Define_CreatebtnScrollUp   (22, 18)
   Define_CreatebtnScrollDown (22, 18)
   Define_CreatebtnScrollLeft (22, 18)
   Define_CreatebtnScrollRight(22, 18)   
   Define_CreatebtnScrollHome (24, 24)
   Define_CreatebtnScaleUp    (24, 24)
   Define_CreatebtnScaleDown  (24, 24)
EndProcedure

;注销导航条
Procedure Navigate_Release()
   With _Navigate
      *pNavigate.__GadgetInfo = \btnMovingBar
      For k = 1 To 8
         Define_FreeGadget(*pNavigate)
         *pNavigate + SizeOf(__GadgetInfo)
      Next
   EndWith
EndProcedure

;获取刷新状态
Procedure Navigate_RefreshState()
   ProcedureReturn _Navigate\IsRefresh
EndProcedure

;设置CallBack函数
Procedure Navigate_CallBack(CallBackType, *pCallFunction)
   With _Navigate
;       Select CallBackType
;          Case #CallBack_SelectMatter : \pCallSelectMatter = *pCallFunction
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
   Window\Font12ID   = LoadFont(#PB_Any, "宋体", 12)  
   Window\Font09ID   = LoadFont(#PB_Any, "宋体", 09)  
   Window\WindowW    = 900
   Window\WindowH    = 600
   Window\LayerZoom  = 1.0
   ;======================
;挂钩事件
Procedure Navigate_HookWindow(hWindow, uMsg, wParam, lParam) 
   With _Navigate
      If \hWindow <> hWindow
         ProcedureReturn DefWindowProc_(hWindow, uMsg, wParam, lParam)
      EndIf
      Select uMsg 
         Case #WM_MOUSEMOVE     
            Result = Navigate_Hook_MOUSEMOVE    (@lParam)
            If \pEvents\pMouseTop <> Result : \pEvents\pMouseTop = Result : EndIf 
            If \IsRefresh = #True : IsRefresh = #False : Refresh = #True  : EndIf 

         Case #WM_LBUTTONDOWN  
            Result = Navigate_Hook_LBUTTONDOWN  (@lParam)
            If \pEvents\pHoldDown <> Result : \pEvents\pHoldDown = Result : Refresh = #True : EndIf            
            
         Case #WM_LBUTTONUP
            Result = Navigate_Hook_LBUTTONUP    (@lParam)
            If \pEvents\pHoldDown Or \pEvents\pMouseTop : \pEvents\pHoldDown = #Null : \pEvents\pMouseTop = #Null : Refresh = #True : EndIf    
            If \IsRefresh = #True : IsRefresh = #False : Refresh = #True  : EndIf 
      EndSelect 
      If Result = 0 
         Result = CallWindowProc_(\hWindowHook, hWindow, uMsg, wParam, lParam) 
      EndIf 
      
      If Refresh = #True
         If StartDrawing(CanvasOutput(#cvsScreen))
            Box(0, 0, \pWindow\WindowW, \pWindow\WindowH, #Define_BackColor&$FFFFFF)
            Navigate_RedrawScreen()
            StopDrawing()
         EndIf 
      EndIf
   EndWith
   ProcedureReturn Result
EndProcedure

   ;======================
   WindowFlags = #PB_Window_SystemMenu|#PB_Window_MaximizeGadget|#PB_Window_MinimizeGadget|#PB_Window_SizeGadget|#PB_Window_ScreenCentered
   hWindow = OpenWindow(#winScreen, 0, 0, Window\WindowW, Window\WindowH, "Navigate 测试" , WindowFlags)
   Navigate_Initial(@Window, @Color, @Event)   
   CanvasGadget(#cvsScreen, 0, 0, Window\WindowW, Window\WindowH)
   If StartDrawing(CanvasOutput(#cvsScreen))
      Box(0, 0, Window\WindowW, Window\WindowH, #Define_BackColor&$FFFFFF)
      Navigate_RedrawScreen()
      StopDrawing()
   EndIf
   _Navigate\hWindow     = GadgetID(#cvsScreen)
   _Navigate\hWindowHook = SetWindowLongPtr_(_Navigate\hWindow, #GWL_WNDPROC, @Navigate_HookWindow())
   ;======================
   Repeat
      WindowEvent = WindowEvent()
      Select WindowEvent
         Case #PB_Event_CloseWindow : IsExitWindow = #True
         Case #PB_Event_SizeWindow
            Window\WindowW = WindowWidth(#winScreen)
            Window\WindowH = WindowHeight(#winScreen)
            ResizeGadget(#cvsScreen, 0, 0, Window\WindowW, Window\WindowH)
            If StartDrawing(CanvasOutput(#cvsScreen))
               Box(0, 0, Window\WindowW, Window\WindowH, #Define_BackColor&$FFFFFF)
               Navigate_RedrawScreen()
               StopDrawing()
            EndIf
      EndSelect
   Until IsExitWindow = #True 
   Navigate_Release()
   FreeFont(Window\Font12ID)
   FreeFont(Window\Font09ID)
   End
CompilerEndIf 




; IDE Options = PureBasic 5.62 (Windows - x86)
; CursorPosition = 611
; FirstLine = 317
; Folding = -BM0
; EnableXP
; Executable = DEMO.exe