;*****************************************
;******** 单片机仿真模拟器窗体界面 ********
;********    迷路仟 2020.02.24    ********
;*****************************************
;【Maker_Caption.pbi】 标题栏源代码


;-[Enumeration]
Enumeration Screen
   #winCaption
EndEnumeration

;-[IncludeFile]
XIncludeFile ".\Maker_Define.pbi"      ;定义类源代码
XIncludeFile ".\Maker_Balloon.pbi"     ;控件提示文源代码

;-[Structure]
;分页项的设计文档结构
Structure __Caption_DesignInfo Extends __GadgetInfo
   DesignID.l
   LayerZoom.f
   ScrollX.l
   ScrollY.l
   CanvasW.l
   CanvasH.l
   ;=======
   Title$
   FileName$
   ;=======
   IsModify.l
EndStructure

;分页项的设计文档结构
Structure __Caption_BaseInfo Extends __GadgetInfo
   List ListToolItem.__GadgetInfo()
EndStructure

;对话框结构
Structure __Caption_MainInfo Extends __AreaInfo
   *pColors.__ColorInfo
   *pWindow.__WindowInfo
   *pEvents.__EventInfo
   ;=========
   btnSoftware.__GadgetInfo
   btnCreateDesign.__GadgetInfo
   btnOpenDesign.__GadgetInfo
   btnSaveDesign.__GadgetInfo
   btnCloseDesign.__GadgetInfo
   btnScrollLeft.__GadgetInfo
   btnScrollRight.__GadgetInfo
   List ListDesign.__Caption_DesignInfo()
   *pCurrDesign.__Caption_DesignInfo
   ;=========
   *pCallCreateDesign
   *pCallOpenDesign
   *pCallLoadDesign
   *pCallSaveDesign
   *pCallCloseDesign
   *pCallSelectDesign
   *pCallExportImage
   ;=========
   hWindow.l
   hWindowHook.l
   ScrollIndex.l
   DesignIndex.l
EndStructure

;-[Global]
Global _Caption.__Caption_MainInfo

;-
;- ******** [Redraw] ********
;绘制事件
Procedure Caption_RedrawScreen()
   DrawingMode(#PB_2DDrawing_Transparent) 
   With _Caption
      \W = \pWindow\WindowW-\X-171
      \R = \X+\W
      
      Define_RedrawGadget(\pEvents, \btnSoftware)
      Define_RedrawGadget(\pEvents, \btnCreateDesign)
      Define_RedrawGadget(\pEvents, \btnOpenDesign)
      Define_RedrawGadget(\pEvents, \btnSaveDesign)
      Define_RedrawGadget(\pEvents, \btnCloseDesign)
      
      ClipOutput(\X, \Y, \W, \H)
      ItemX = \X
      
      If \ScrollIndex > 0 
         \btnScrollLeft\IsHide = #False
         Define_RedrawGadget(\pEvents, \btnScrollLeft, ItemX, \Y)
         ItemX + \btnScrollLeft\W
      Else 
         \btnScrollLeft\IsHide = #True
      EndIf 
      
      ForEach \ListDesign()
         If ItemIdex < \ScrollIndex : ItemIdex+1 
            \ListDesign()\IsHide = #True
            Continue 
         EndIf 
         \ListDesign()\IsHide = #False
         If ItemX +\btnScrollRight\W + \ListDesign()\W > \R : IsShow = #True : Break : EndIf 
         If \pCurrDesign = \ListDesign()
            \pCurrDesign\X = ItemX : \pCurrDesign\R = \pCurrDesign\X+\pCurrDesign\W 
            \pCurrDesign\Y = \Y    : \pCurrDesign\B = \pCurrDesign\Y+\pCurrDesign\H 
            DrawAlphaImage(ImageID(\pCurrDesign\HoldDownID), ItemX, \Y)
         Else 
            Define_RedrawGadget(\pEvents, \ListDesign(), ItemX, \Y)
         EndIf 
         ItemX + \ListDesign()\W
         ItemIdex+1
      Next 
      If IsShow = #True
         \btnScrollRight\IsHide = #False
         Define_RedrawGadget(\pEvents, \btnScrollRight, ItemX, \Y)
      Else 
         \btnScrollRight\IsHide = #True
      EndIf 
      UnclipOutput()
   EndWith
EndProcedure

;-
;- ******** [Hook] ********
;光标在上事件[Screen_HookWindow()]
Procedure Caption_Hook_MOUSEMOVE(*pMouse.POINTS)
   With _Caption
      If Macro_Gadget_InRect1(\btnSoftware)
         *pEventGadget = \btnSoftware
      ElseIf Macro_Gadget_InRect1(\btnCreateDesign)
         *pEventGadget = \btnCreateDesign
      ElseIf Macro_Gadget_InRect1(\btnOpenDesign)
         *pEventGadget = \btnOpenDesign
      ElseIf Macro_Gadget_InRect1(\btnSaveDesign)
         *pEventGadget = \btnSaveDesign
      ElseIf Macro_Gadget_InRect1(\btnCloseDesign)
         *pEventGadget = \btnCloseDesign
      ;判断光标是否落在主工具栏上
      ElseIf Macro_Gadget_InRect1(_Caption)
         If Macro_Gadget_InRect2(\btnScrollLeft)
            *pEventGadget = \btnScrollLeft
         ElseIf Macro_Gadget_InRect2(\btnScrollRight)
            *pEventGadget = \btnScrollRight
         Else 
            ForEach \ListDesign()
               If Macro_Gadget_InRect2(\ListDesign())
                  *pEventGadget = \ListDesign()
                  Break 
               EndIf 
            Next
         EndIf 
      EndIf 
   EndWith
   ProcedureReturn *pEventGadget
EndProcedure

;左键按下事件[Screen_HookWindow()]
Procedure Caption_Hook_LBUTTONDOWN(*pMouse.POINTS)
   With _Caption
      If Macro_Gadget_InRect1(\btnSoftware)
         *pEventGadget = \btnSoftware
      ElseIf Macro_Gadget_InRect1(\btnCreateDesign)
         *pEventGadget = \btnCreateDesign
      ElseIf Macro_Gadget_InRect1(\btnOpenDesign)
         *pEventGadget = \btnOpenDesign
      ElseIf Macro_Gadget_InRect1(\btnSaveDesign)
         *pEventGadget = \btnSaveDesign
      ElseIf Macro_Gadget_InRect1(\btnCloseDesign)
         *pEventGadget = \btnCloseDesign
      ;判断光标是否落在主工具栏上
      ElseIf Macro_Gadget_InRect1(_Caption)
         If Macro_Gadget_InRect2(\btnScrollLeft)
            *pEventGadget = \btnScrollLeft
         ElseIf Macro_Gadget_InRect2(\btnScrollRight)
            *pEventGadget = \btnScrollRight
         Else 
            ForEach \ListDesign()
               If Macro_Gadget_InRect2(\ListDesign())
                  *pEventGadget = \ListDesign()
                  Break 
               EndIf 
            Next
         EndIf 
      EndIf 
   EndWith
   ProcedureReturn *pEventGadget
EndProcedure

;左键释放事件[Screen_HookWindow()]
Procedure Caption_Hook_LBUTTONUP(*pMouse.POINTS)
   With _Caption
      If Macro_Gadget_InRect1(\btnSoftware)
         *pEventGadget = \btnSoftware
         PostEvent(#PB_Event_Gadget, \pWindow\WindowID, #wmiSoftware)
      ElseIf Macro_Gadget_InRect1(\btnCreateDesign)
         *pEventGadget = \btnCreateDesign
         PostEvent(#PB_Event_Gadget, \pWindow\WindowID, #wmiCreateDesign)
      ElseIf Macro_Gadget_InRect1(\btnOpenDesign)
         *pEventGadget = \btnOpenDesign  
         PostEvent(#PB_Event_Gadget, \pWindow\WindowID, #wmiOpenDesign)
      ElseIf Macro_Gadget_InRect1(\btnSaveDesign)
         *pEventGadget = \btnSaveDesign 
         PostEvent(#PB_Event_Gadget, \pWindow\WindowID, #wmiSaveDesign)
      ElseIf Macro_Gadget_InRect1(\btnCloseDesign)
         *pEventGadget = \btnCloseDesign
         PostEvent(#PB_Event_Gadget, \pWindow\WindowID, #wmiCloseDesign)
      ;判断光标是否落在主工具栏上
      ElseIf Macro_Gadget_InRect1(_Caption)
         If Macro_Gadget_InRect2(\btnScrollLeft)
            *pEventGadget = \btnScrollLeft
            \ScrollIndex -1
            If \ScrollIndex < 0 : \ScrollIndex = 0 : EndIf 
            PostEvent(#PB_Event_Gadget, \pWindow\WindowID, #wmiScrollLeft)
         ElseIf Macro_Gadget_InRect2(\btnScrollRight)
            *pEventGadget = \btnScrollRight
            \ScrollIndex + 1
            If \ScrollIndex > ListSize(\ListDesign())-1 : \ScrollIndex = ListSize(\ListDesign())-1 : EndIf 
            PostEvent(#PB_Event_Gadget, \pWindow\WindowID, #wmiScrollRight)
         Else 
            ForEach \ListDesign()
               If Macro_Gadget_InRect2(\ListDesign())
                  *pEventGadget        = \ListDesign()
                  \pWindow\LayerZoom   = \ListDesign()\LayerZoom
                  \pWindow\pCurrDesign = \ListDesign()
                  \pCurrDesign         = *pEventGadget
                  ;回调[主源码文件]的函数
                  If \pCallSelectDesign And \pCurrDesign
                     CallFunctionFast(\pCallSelectDesign, \pCurrDesign)
                  EndIf  
                  PostEvent(#PB_Event_Gadget, \pWindow\WindowID, \pCurrDesign\GadgetID)
                  Break 
               EndIf 
               Index+1
            Next
         EndIf 
      EndIf 
   EndWith
   ProcedureReturn *pEventGadget
EndProcedure

;双击事件[Screen_HookWindow()]
Procedure Caption_Hook_LBUTTONDBLCLK(*pMouse.POINTS)
   With _Caption
      ;判断光标是否落在主工具栏上
      If Macro_Gadget_InRect1(\btnSoftware)
         ProcedureReturn #True
      ElseIf Macro_Gadget_InRect1(\btnCreateDesign)
         ProcedureReturn #True
      ElseIf Macro_Gadget_InRect1(\btnOpenDesign)
         ProcedureReturn #True
      ElseIf Macro_Gadget_InRect1(\btnSaveDesign)
         ProcedureReturn #True
      ElseIf Macro_Gadget_InRect1(\btnCloseDesign)
         ProcedureReturn #True
      ElseIf Macro_Gadget_InRect1(_Caption)
         ProcedureReturn #True
      EndIf 
   EndWith
   
EndProcedure


;-
;- ******** [Create] ********
;创建分页按键
Procedure Caption_CreateButton(*pGadget.__GadgetInfo, X, Y, W, H, IconX, IconY, IconW=32, IconH=32)
   With *pGadget
      \IsCreate = #True
      IconID    = _Caption\pWindow\ResourIconID  
      FontColor = _Caption\pColors\BackColor  
      SideColor = _Caption\pColors\ForeColor
      BackColor = (Alpha(SideColor) << 23 & $FF000000) |(SideColor & $FFFFFF)
      
      HighColor = _Caption\pColors\HighColor
      HighColor1 = (Alpha(HighColor) << 22 & $FF000000) |(HighColor & $FFFFFF)
      HighColor2 = (Alpha(HighColor) << 23 & $FF000000) |(HighColor & $FFFFFF)
      
      \X = X : \Y = Y : \W = W : \H = H : \R = X+W : \B = Y+H
      If IsImage(\NormalcyID) : FreeImage(\NormalcyID) : EndIf 
      If IsImage(\MouseTopID) : FreeImage(\MouseTopID) : EndIf 
      If IsImage(\HoldDownID) : FreeImage(\HoldDownID) : EndIf 
      
      TempImageID = GrabImage(IconID, #PB_Any, IconX, IconY, IconW, IconH)
      \NormalcyID = CreateImage(#PB_Any, W, H, 32, #PB_Image_Transparent)
      If StartDrawing(ImageOutput(\NormalcyID))
         DrawingMode(#PB_2DDrawing_Transparent)
         DrawAlphaImage(ImageID(TempImageID), (W-IconW)/2, (H-IconH)/2)
         StopDrawing()
      EndIf
      FreeImage(TempImageID)
      
      \MouseTopID = CreateImage(#PB_Any, W, H, 32, #PB_Image_Transparent)
      If StartDrawing(ImageOutput(\MouseTopID))
         DrawingMode(#PB_2DDrawing_AlphaBlend)
         RoundBox(0, 0, W, H, 5, 5, HighColor1)         
         DrawAlphaImage(ImageID(\NormalcyID), 0, 0)
         StopDrawing()
      EndIf
      
      \HoldDownID = CreateImage(#PB_Any, W, H, 32, #PB_Image_Transparent)
      If StartDrawing(ImageOutput(\HoldDownID))
         DrawingMode(#PB_2DDrawing_AlphaBlend)
         RoundBox(0, 0, W, H, 5, 5, HighColor2)  
         DrawAlphaImage(ImageID(\NormalcyID), 0, 0)
         StopDrawing()
      EndIf      
   EndWith
EndProcedure

;创建软件标志
Procedure Caption_CreateSoftware(X, Y, W, H, IconX, IconY, IconW, IconH)
   With _Caption\btnSoftware
      \IsCreate = #True
      IconID    = _Caption\pWindow\ResourIconID  
      FontColor = _Caption\pColors\BackColor  
      SideColor = _Caption\pColors\ForeColor
      BackColor = (Alpha(SideColor) << 23 & $FF000000) |(SideColor & $FFFFFF)
      
      HighColor = _Caption\pColors\HighColor
      HighColor1 = (Alpha(HighColor) << 22 & $FF000000) |(HighColor & $FFFFFF)
      HighColor2 = (Alpha(HighColor) << 23 & $FF000000) |(HighColor & $FFFFFF)
      
      \X = X : \Y = Y : \W = W : \H = H : \R = X+W : \B = Y+H
      If IsImage(\NormalcyID) : FreeImage(\NormalcyID) : EndIf 
      If IsImage(\MouseTopID) : FreeImage(\MouseTopID) : EndIf 
      If IsImage(\HoldDownID) : FreeImage(\HoldDownID) : EndIf 
      
      \NormalcyID = GrabImage(IconID, #PB_Any, IconX+000, IconY, IconW, IconH)
      \MouseTopID = GrabImage(IconID, #PB_Any, IconX+110, IconY, IconW, IconH)
      \HoldDownID = GrabImage(IconID, #PB_Any, IconX+000, IconY, IconW, IconH)   
   EndWith
EndProcedure

;创建分页栏左移按键
Procedure Caption_btnScrollLeft()
   BackColor  = _Caption\pColors\HighColor
   ForeColor  = _Caption\pColors\HighColor & $FFFFFF | $1F000000
   FontColor1 = _Caption\pColors\BackColor
   FontColor2 = ((Alpha(BackColor) << 23) & $FF000000) |(BackColor & $FFFFFF)
   HighColor  = ((Alpha(BackColor) << 22) & $FF000000) |(BackColor & $FFFFFF)
   With _Caption\btnScrollLeft
      \IsCreate = #True
      \IsHide   = #True
      \GadgetID = #wmiScrollLeft
      \W = 25 : \H = 30
      If IsImage(\NormalcyID) : FreeImage(\NormalcyID) : EndIf 
      If IsImage(\MouseTopID) : FreeImage(\MouseTopID) : EndIf 
      If IsImage(\HoldDownID) : FreeImage(\HoldDownID) : EndIf 
      \NormalcyID = CreateImage(#PB_Any, \W, \H, 32, #PB_Image_Transparent)
      If StartDrawing(ImageOutput(\NormalcyID))
         Box(0, 0, \W, \H, $FFFFFF)
         DrawingMode(#PB_2DDrawing_Gradient|#PB_2DDrawing_AllChannels)
         BackColor(BackColor)
         GradientColor(0.5, ForeColor)
         GradientColor(1.0, BackColor)
         LinearGradient(0, 01, \W-2, 0)   
         Box(003, 0003, \W-11, 2)
         Box(008, \H-5, \W-11, 2)
         LinearGradient(0, 3, 0, \H-3)            
         Box(0001, 03, 2, \H-13)
         Box(\W-3, 10, 2, \H-13)
         Line(003, \H-10, 005, 005)
         Line(002, \H-10, 006, 006)
         Line(001, \H-10, 007, 007)
         Line(\W-8, 003, 007, 007)
         Line(\W-8, 004, 006, 006)
         Line(\W-8, 005, 005, 005)
         DrawingMode(#PB_2DDrawing_AllChannels)
         Line(11, \H/2-1, 5, -5)
         Line(10, \H/2-1, 5, -5)
         Line(09, \H/2-1, 5, -5)
         Line(08, \H/2-0, 6, 6)
         Line(09, \H/2-0, 6, 6)
         Line(10, \H/2-0, 6, 6)
         StopDrawing()
      EndIf      
      
      \MouseTopID = CopyImage(\NormalcyID, #PB_Any)
      If StartDrawing(ImageOutput(\MouseTopID))
         DrawingMode(#PB_2DDrawing_AlphaBlend)
         FrontColor(FontColor2)
         Line(11, \H/2-1, 5, -5)
         Line(10, \H/2-1, 5, -5)
         Line(09, \H/2-1, 5, -5)
         Line(08, \H/2-0, 6, 6)
         Line(09, \H/2-0, 6, 6)
         Line(10, \H/2-0, 6, 6)
         StopDrawing()
      EndIf    
      
      \HoldDownID = CopyImage(\NormalcyID, #PB_Any)
      If StartDrawing(ImageOutput(\HoldDownID))
         DrawingMode(#PB_2DDrawing_AllChannels)
         FillArea(5, 5, -1, HighColor)
         DrawingMode(#PB_2DDrawing_AlphaBlend)
         FrontColor(FontColor1)
         Line(11, \H/2-1, 5, -5)
         Line(10, \H/2-1, 5, -5)
         Line(09, \H/2-1, 5, -5)
         Line(08, \H/2-0, 6, 6)
         Line(09, \H/2-0, 6, 6)
         Line(10, \H/2-0, 6, 6)
         StopDrawing()
      EndIf
   EndWith 
EndProcedure

;创建分页栏右移按键
Procedure Caption_btnScrollRight()
   BackColor  = _Caption\pColors\HighColor
   ForeColor  = _Caption\pColors\HighColor & $FFFFFF | $1F000000
   FontColor1 = _Caption\pColors\BackColor
   FontColor2 = ((Alpha(BackColor) << 23) & $FF000000) |(BackColor & $FFFFFF)
   HighColor  = ((Alpha(BackColor) << 22) & $FF000000) |(BackColor & $FFFFFF)
   With _Caption\btnScrollRight
      \IsCreate = #True
      \IsHide   = #True      
      \GadgetID = #wmiScrollRight
      \W = 25 : \H = 30
      If IsImage(\NormalcyID) : FreeImage(\NormalcyID) : EndIf 
      If IsImage(\MouseTopID) : FreeImage(\MouseTopID) : EndIf 
      If IsImage(\HoldDownID) : FreeImage(\HoldDownID) : EndIf 
      \NormalcyID = CreateImage(#PB_Any, \W, \H, 32, #PB_Image_Transparent)
      If StartDrawing(ImageOutput(\NormalcyID))
         Box(0, 0, \W, \H, $FFFFFF)
         DrawingMode(#PB_2DDrawing_Gradient|#PB_2DDrawing_AllChannels)
         BackColor(BackColor)
         GradientColor(0.5, ForeColor)
         GradientColor(1.0, BackColor)
         LinearGradient(0, 01, \W-2, 0)   
         Box(003, 0003, \W-11, 2)
         Box(008, \H-5, \W-11, 2)
         LinearGradient(0, 3, 0, \H-3)            
         Box(0001, 03, 2, \H-13)
         Box(\W-3, 10, 2, \H-13)
         Line(003, \H-10, 005, 005)
         Line(002, \H-10, 006, 006)
         Line(001, \H-10, 007, 007)
         Line(\W-8, 003, 007, 007)
         Line(\W-8, 004, 006, 006)
         Line(\W-8, 005, 005, 005)
         DrawingMode(#PB_2DDrawing_AllChannels)
         Line(15, \H/2-1, -5, -5)
         Line(14, \H/2-1, -5, -5)
         Line(13, \H/2-1, -5, -5)
         Line(14, \H/2-0, -6, 06)
         Line(15, \H/2-0, -6, 06)
         Line(16, \H/2-0, -6, 06)
         StopDrawing()
      EndIf      
      
      \MouseTopID = CopyImage(\NormalcyID, #PB_Any)
      If StartDrawing(ImageOutput(\MouseTopID))
         DrawingMode(#PB_2DDrawing_AlphaBlend)
         FrontColor(FontColor2)
         Line(15, \H/2-1, -5, -5)
         Line(14, \H/2-1, -5, -5)
         Line(13, \H/2-1, -5, -5)
         Line(14, \H/2-0, -6, 06)
         Line(15, \H/2-0, -6, 06)
         Line(16, \H/2-0, -6, 06)
         StopDrawing()
      EndIf    
      
      \HoldDownID = CopyImage(\NormalcyID, #PB_Any)
      If StartDrawing(ImageOutput(\HoldDownID))
         DrawingMode(#PB_2DDrawing_AllChannels)
         FillArea(5, 5, -1, HighColor)
         DrawingMode(#PB_2DDrawing_AlphaBlend)
         FrontColor(FontColor1)
         Line(15, \H/2-1, -5, -5)
         Line(14, \H/2-1, -5, -5)
         Line(13, \H/2-1, -5, -5)
         Line(14, \H/2-0, -6, 06)
         Line(15, \H/2-0, -6, 06)
         Line(16, \H/2-0, -6, 06)
         StopDrawing()
      EndIf
   EndWith 
   
EndProcedure

;创建分页栏
Procedure Caption_CreatebtnPanel(*pGadget.__GadgetInfo, W, H, Text$)
   
   BackColor  = _Caption\pColors\HighColor
   ForeColor  = _Caption\pColors\HighColor & $FFFFFF | $1F000000
   FontColor1 = _Caption\pColors\BackColor
   FontColor2 = ((Alpha(BackColor) << 23) & $FF000000) |(BackColor & $FFFFFF)
   HighColor  = ((Alpha(BackColor) << 22) & $FF000000) |(BackColor & $FFFFFF)

   FontID    = _Caption\pWindow\Font12ID
   With *pGadget
      \IsCreate = #True
      \GadgetID = *pGadget
      \Text$    = Text$
      \W = W : \H= H
      If IsImage(\NormalcyID) : FreeImage(\NormalcyID) : EndIf 
      If IsImage(\MouseTopID) : FreeImage(\MouseTopID) : EndIf 
      If IsImage(\HoldDownID) : FreeImage(\HoldDownID) : EndIf 
      TempImageID = CreateImage(#PB_Any, \W, \H, 32, #PB_Image_Transparent)
      If StartDrawing(ImageOutput(TempImageID))
         DrawingFont(FontID(FontID))
         \W = TextWidth(Text$)+20
         If \W > W : \W = W : EndIf 
         Box(0, 0, \W, \H, $FFFFFF)
         DrawingMode(#PB_2DDrawing_Gradient|#PB_2DDrawing_AllChannels)
         BackColor(BackColor)
         GradientColor(0.5, ForeColor)
         GradientColor(1.0, BackColor)
         LinearGradient(0, 01, \W-2, 0)   
         Box(003, 0003, \W-11, 2)
         Box(008, \H-5, \W-11, 2)
         LinearGradient(0, 3, 0, \H-3)            
         Box(0001, 03, 2, \H-13)
         Box(\W-3, 10, 2, \H-13)
         
         Line(003, \H-10, 005, 005)
         Line(002, \H-10, 006, 006)
         Line(001, \H-10, 007, 007)
         Line(\W-8, 003, 007, 007)
         Line(\W-8, 004, 006, 006)
         Line(\W-8, 005, 005, 005)
         DrawingMode(#PB_2DDrawing_AllChannels)
         BackColor($00000000)
         FrontColor(FontColor1)
         DrawText(010, 007, Text$)

         StopDrawing()
      EndIf      
      \NormalcyID = GrabImage(TempImageID, #PB_Any, 0, 0, \W, \H)
      FreeImage(TempImageID)
      
      \MouseTopID = CopyImage(\NormalcyID, #PB_Any)
      If StartDrawing(ImageOutput(\MouseTopID))
         DrawingFont(FontID(FontID))
         DrawingMode(#PB_2DDrawing_AlphaBlend)
         BackColor($00000000)
         FrontColor(FontColor2)
         DrawText(010, 007, Text$)
         StopDrawing()
      EndIf    
      
      \HoldDownID = CreateImage(#PB_Any, \W, \H, 32, #PB_Image_Transparent)
      If StartDrawing(ImageOutput(\HoldDownID))
         DrawingFont(FontID(FontID))
         DrawingMode(#PB_2DDrawing_Gradient|#PB_2DDrawing_AlphaBlend)
         BackColor(BackColor)
         GradientColor(0.5, ForeColor)
         GradientColor(1.0, BackColor)
         LinearGradient(0, 03, \W-6, 0)   
         Box(001, 0001, \W-09, 2)
         Box(007, \H-2, \W-10, 2)
         LinearGradient(0, 3, 0, \H-6)            
         Box(0001, 03, 2, \H-10)
         Box(\W-3, 08, 2, \H-08)
         LinearGradient(0, 0, 0, \H-0)  
         Line(003, \H-7, 005, 005)
         Line(002, \H-7, 006, 006)
         Line(001, \H-7, 007, 007)
         Line(\W-8, 001, 007, 007)
         Line(\W-8, 002, 006, 006)
         Line(\W-8, 003, 005, 005)
         DrawingMode(#PB_2DDrawing_AllChannels)
         FillArea(10, 10, -1, HighColor)
         BackColor(HighColor)
         FrontColor(FontColor1)
         DrawText(010, 008, Text$)
         StopDrawing()
      EndIf
   EndWith 
   
EndProcedure

;-
;分页栏自动调整大小
Procedure Caption_AutoResize()
   With _Caption
      ItemR = \R-\btnScrollRight\W-\btnScrollLeft\W - 5
      LimitR = ItemR
      ForEach \ListDesign()
         If \ListDesign()\IsHide = #True : Continue : EndIf 
         If \ListDesign() = \pCurrDesign : ProcedureReturn : EndIf 
         LimitR - \ListDesign()\W  
         If LimitR < \X : Break : EndIf 
      Next 

      Index = ListSize(\ListDesign()) -1 
      \ScrollIndex = 0
      *pGadget.__GadgetInfo = LastElement(\ListDesign()) 
      While *pGadget 
         If *pGadget = \pCurrDesign : IsAuto = #True : EndIf 
         If IsAuto = #True 
            ItemR - *pGadget\W    
            If ItemR < \X
               \ScrollIndex = Index+1
               Break
            EndIf             
         EndIf 
         Index-1
         *pGadget = PreviousElement(\ListDesign()) 
      Wend          
   EndWith
EndProcedure


;-
;- ======> [External Call] <======
;创建分页按键
Procedure Caption_CreateDesign(Text$=#Null$)
   With _Caption
      If Text$ = #Null$ 
         \DesignIndex+1
         Text$ = "新建文档" + Str(\DesignIndex)
      EndIf 
      LastElement(\ListDesign())
      *pListDesign.__Caption_DesignInfo = AddElement(\ListDesign())
      Caption_CreatebtnPanel(*pListDesign, 999, 30, Text$)
      \ListDesign()\LayerZoom = 1.0
      \ListDesign()\Title$    = Text$
      \pCurrDesign            = *pListDesign
      \pWindow\LayerZoom      = 1.0             ;回调到Screen中,供Navigate调用
      \pWindow\pCurrDesign    = *pListDesign    ;回调到Screen中,供Navigate调用
      Caption_AutoResize()
      ;回调[主源码文件]的函数
      If \pCallCreateDesign
         \pCurrDesign\DesignID  = CallFunctionFast(\pCallCreateDesign, *pListDesign)
      EndIf 
   EndWith
   
   ProcedureReturn *pGadget
EndProcedure

;打开设计文档
Procedure Caption_OpenDesign(FileName$ = #Null$)
   With _Caption
      ;回调[主源码文件]的函数
      Design.__Caption_DesignInfo
      If \pCallOpenDesign And FileName$ = #Null$
         Result = CallFunctionFast(\pCallOpenDesign, @Design)
      ElseIf \pCallLoadDesign And FileName$
         Design\FileName$ = FileName$
         Result = CallFunctionFast(\pCallLoadDesign, @Design)  
      EndIf         
      If Result 
         LastElement(\ListDesign())
         *pListDesign.__Caption_DesignInfo = AddElement(\ListDesign())
         Caption_CreatebtnPanel(*pListDesign, 999, 30, Design\Title$)
         \ListDesign()\LayerZoom = Design\LayerZoom  ;这里要X2进行换算
         \ListDesign()\CanvasW   = Design\CanvasW
         \ListDesign()\CanvasH   = Design\CanvasH
         \ListDesign()\Title$    = Design\Title$
         \ListDesign()\FileName$ = Design\FileName$
         \ListDesign()\DesignID  = Design\DesignID
         \pCurrDesign            = *pListDesign
         \pWindow\LayerZoom      = Design\LayerZoom   ;回调到Screen中,供Navigate调用
         \pWindow\pCurrDesign    = *pListDesign       ;回调到Screen中,供Navigate调用
         Caption_AutoResize()
      EndIf 

      ProcedureReturn *pListDesign
   EndWith
EndProcedure



;保存设计文档
Procedure Caption_SaveDesign(IsSaveAs=#False)
   With _Caption
      ;回调[主源码文件]的函数
      If \pCallSaveDesign And \pCurrDesign
         Result = CallFunctionFast(\pCallSaveDesign, \pCurrDesign, IsSaveAs)
         If Result
            Caption_CreatebtnPanel(\pCurrDesign, 999, 30, \pCurrDesign\Title$)
         EndIf 
      EndIf 
   EndWith
EndProcedure

Procedure Caption_SaveAllDesign() 
   With _Caption
      If \pCallSaveDesign = #Null : ProcedureReturn : EndIf 
      ForEach \ListDesign()
         CallFunctionFast(\pCallSaveDesign, \pCurrDesign)
      Next 
   EndWith 
EndProcedure
   
;关闭分页按键
Procedure Caption_CloseDesign()
   With _Caption
      If ListSize(\ListDesign()) <= 1 
         ;回调[主源码文件]的函数
         If \pCallCloseDesign And \pCurrDesign
            CallFunctionFast(\pCallCloseDesign, \pCurrDesign)
         EndIf
         Define_FreeGadget(\pCurrDesign)
         ClearList(\ListDesign())
         Caption_CreateDesign("新建文档")
         \ScrollIndex = 0
         \DesignIndex = 1
      Else 
         ForEach \ListDesign()
            If \pCurrDesign = \ListDesign()
               ;回调[主源码文件]的函数
               If \pCallCloseDesign
                  CallFunctionFast(\pCallCloseDesign, \ListDesign())
               EndIf
               Define_FreeGadget(\ListDesign())
               DeleteElement(\ListDesign())
               \pCurrDesign = 0
               Break
            EndIf
            Index+1
         Next
         If Index < ListSize(\ListDesign())
            \pCurrDesign = SelectElement(\ListDesign(), Index)
         Else 
            \pCurrDesign = LastElement(\ListDesign())
            Index = ListSize(\ListDesign())-1
         EndIf
         ;回调[主源码文件]的函数
         If \pCallSelectDesign
            CallFunctionFast(\pCallSelectDesign, \pCurrDesign)
         EndIf
         Caption_AutoResize()
      EndIf 
   EndWith
   ProcedureReturn *pGadget
EndProcedure

;关闭所有分页按键
Procedure Caption_CloseAllDesign()
   With _Caption
      ForEach \ListDesign()
         ;回调[主源码文件]的函数
         If \pCallCloseDesign
            CallFunctionFast(\pCallCloseDesign, \ListDesign())
         EndIf
         Define_FreeGadget(\ListDesign())
      Next
      \ScrollIndex = 0
      \DesignIndex = 1
      ClearList(\ListDesign())
      Caption_CreateDesign("新建文档")
   EndWith
   ProcedureReturn *pGadget
EndProcedure

;保存设计文档
Procedure Caption_ExportImage()
   With _Caption
      ;回调[主源码文件]的函数
      If \pCallSaveDesign And \pCurrDesign
         Debug "\pCurrDesign\FileName$ = " + \pCurrDesign\FileName$
         Result = CallFunctionFast(\pCallExportImage, \pCurrDesign)
      EndIf 
   EndWith
EndProcedure


;-
;初始化信息标题栏
Procedure Caption_Initial(*pWindow.__WindowInfo, *pColors, *pEvents)
   With _Caption
      \pColors = *pColors
      \pEvents = *pEvents
      \pWindow = *pWindow
      \X = 275
      \Y = 014
      \W = \pWindow\WindowW-\X-171
      \R = \X+\W
      \H = 030
      \B = 044
      \DesignIndex = 1
      \ScrollIndex = 0
      ItemX = 150    
      Caption_CreateButton(\btnCreateDesign,ItemX, 07, 28, 28, 24*0, 00, 24, 24) : ItemX+30
      Caption_CreateButton(\btnOpenDesign,  ItemX, 07, 28, 28, 24*1, 00, 24, 24) : ItemX+30
      Caption_CreateButton(\btnSaveDesign,  ItemX, 07, 28, 28, 24*2, 00, 24, 24) : ItemX+30
      Caption_CreateButton(\btnCloseDesign, ItemX, 07, 28, 28, 24*3, 00, 24, 24) : ItemX+30
      Caption_CreateSoftware(010, 005, 110, 30, 000, 32, 110, 30) 
      Caption_btnScrollLeft()
      Caption_btnScrollRight()
      Caption_CreateDesign("新建文档")
   EndWith
EndProcedure

Procedure Caption_ChangeStyle(*pColors)
   _Caption\pColors = *pColors
   Caption_btnScrollLeft()
   Caption_btnScrollRight()
   ForEach _Caption\ListDesign()
      Caption_CreatebtnPanel(_Caption\ListDesign(), 999, 30, _Caption\ListDesign()\Title$)
   Next 
   
EndProcedure

;注销信息标题栏
Procedure Caption_Release()
   With _Caption
      ForEach \ListDesign()
         ;回调[主源码文件]的函数
         If \pCallCloseDesign
            CallFunctionFast(\pCallCloseDesign, \ListDesign())
         EndIf
         Define_FreeGadget(\ListDesign())
      Next
      FreeList(\ListDesign()) 
      ;=====================
      *pGadget.__GadgetInfo = \btnSoftware
      For k = 1 To 7
         Define_FreeGadget(*pGadget)
         *pGadget + SizeOf(__GadgetInfo)
      Next 

   EndWith
EndProcedure

   
;设置CallBack函数
Procedure Caption_CallBack(CallBackType, *pCallFunction)
   With _Caption
      Select CallBackType
         Case #CallBack_CreateDesign : \pCallCreateDesign = *pCallFunction
         Case #CallBack_OpenDesign   : \pCallOpenDesign   = *pCallFunction
         Case #CallBack_LoadDesign   : \pCallLoadDesign   = *pCallFunction
         Case #CallBack_SaveDesign   : \pCallSaveDesign   = *pCallFunction
         Case #CallBack_CloseDesign  : \pCallCloseDesign  = *pCallFunction
         Case #CallBack_ExportImage  : \pCallExportImage  = *pCallFunction
         Case #CallBack_SelectDesign : \pCallSelectDesign = *pCallFunction
      EndSelect
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
   Window\WindowH = 250
   Window\WindowW = 1000
   UsePNGImageDecoder()
   Window\ResourIconID  = CatchImage(#PB_Any, ?_ICON_Resources)
   ;======================
;挂钩事件
Procedure Caption_HookWindow(hWindow, uMsg, wParam, lParam) 
   With _Caption
      If \hWindow <> hWindow
         ProcedureReturn DefWindowProc_(hWindow, uMsg, wParam, lParam)
      EndIf
      Select uMsg 
         Case #WM_MOUSEMOVE     
            Result = Caption_Hook_MOUSEMOVE    (@lParam)
            If \pEvents\pMouseTop <> Result : \pEvents\pMouseTop = Result : Refresh = #True : EndIf
         Case #WM_LBUTTONDOWN  
            Result = Caption_Hook_LBUTTONDOWN  (@lParam)
            If \pEvents\pHoldDown <> Result : \pEvents\pHoldDown = Result : Refresh = #True : EndIf            
            
         Case #WM_LBUTTONUP
            Result = Caption_Hook_LBUTTONUP    (@lParam)
            If \pEvents\pHoldDown Or \pEvents\pMouseTop : \pEvents\pHoldDown = #Null : \pEvents\pMouseTop = #Null : Refresh = #True : EndIf    
               
         Case #WM_LBUTTONDBLCLK 
            Result = Caption_Hook_LBUTTONDBLCLK(@lParam)
            
      EndSelect 
      If Result = 0 
         Result = CallWindowProc_(\hWindowHook, hWindow, uMsg, wParam, lParam) 
      ElseIf Refresh = #True
         If StartDrawing(CanvasOutput(#cvsScreen))
            Box(0, 0, 900, 250, #Define_ForeColor&$FFFFFF)
            Caption_RedrawScreen()
            StopDrawing()
         EndIf 
      EndIf
   EndWith
   ProcedureReturn Result
EndProcedure

   ;======================
   WindowFlags = #PB_Window_SystemMenu|#PB_Window_MaximizeGadget|#PB_Window_MinimizeGadget|#PB_Window_SizeGadget|#PB_Window_ScreenCentered
   hWindow = OpenWindow(#winScreen, 0, 0, 900, 250, "Caption-测试" , WindowFlags)
   Caption_Initial(@Window, @Color, @Event)  
   CanvasGadget(#cvsScreen, 0, 0, 900, 250)
   If StartDrawing(CanvasOutput(#cvsScreen))
      Box(0, 0, 900, 250, #Define_ForeColor&$FFFFFF)
      Caption_RedrawScreen()
      StopDrawing()
   EndIf
   _Caption\hWindow     = GadgetID(#cvsScreen)
   _Caption\hWindowHook = SetWindowLongPtr_(_Caption\hWindow, #GWL_WNDPROC, @Caption_HookWindow())
   ;======================
   Repeat
      WindowEvent = WindowEvent()
      Select WindowEvent
         Case #PB_Event_CloseWindow : IsExitWindow = #True
         Case #PB_Event_Gadget
            GadgetID = EventGadget()
            Select GadgetID
               Case #wmiSoftware       : Debug "#wmiSoftware"
               Case #wmiCreateDesign   : Debug "#wmiCreateDesign"   : Caption_CreateDesign()  : Refresh = #True
               Case #wmiOpenDesign     : Debug "#wmiOpenDesign"
               Case #wmiSaveDesign     : Debug "#wmiSaveDesign"
               Case #wmiCloseDesign    : Debug "#wmiCloseDesign"    : Caption_CloseDesign()   : Refresh = #True
               Case #wmiCloseAllDesign : Debug "#wmiCloseAllDesign" : Caption_CloseAllDesign(): Refresh = #True
               Case #wmiScrollLeft     : Debug "#wmiScrollLeft"   
               Case #wmiScrollRight    : Debug "#wmiScrollRight"   
            EndSelect 
            If Refresh = #True
               If StartDrawing(CanvasOutput(#cvsScreen))
                  Box(0, 0, 900, 250, #Define_ForeColor&$FFFFFF)
                  Caption_RedrawScreen()
                  StopDrawing()
               EndIf
            EndIf 
      EndSelect
   Until IsExitWindow = #True 
   Caption_Release()
   FreeFont(Window\Font12ID)
   End
   ;======================
DataSection
_ICON_Resources:
   IncludeBinary ".\ICON.png" 
EndDataSection

   
CompilerEndIf 




; IDE Options = PureBasic 5.62 (Windows - x86)
; CursorPosition = 820
; FirstLine = 501
; Folding = 8D75-
; EnableXP
; Executable = DEMO.exe