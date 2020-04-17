;*****************************************
;******** 单片机仿真模拟器窗体界面 ********
;********    迷路仟 2020.02.24    ********
;*****************************************
;【Maker_ToolBar.pbi】 左侧工具栏源代码

;-[Constant]
#ToolBar_SingleLine = 50
#ToolBar_DoubleLine = 90

;-[IncludeFile]
XIncludeFile ".\Maker_Define.pbi"      ;定义类源代码
XIncludeFile ".\Maker_Balloon.pbi"     ;控件提示文源代码

;-[Structure]
Structure __ThirdBarInfo Extends __GadgetInfo
   *pModuleType.__Maker_ModuleType
EndStructure

Structure __ChildBarInfo Extends __GadgetInfo
   *pModuleType.__Maker_ModuleType
   List ListThirdBar.__ThirdBarInfo()
   CountItem.l
EndStructure
   
Structure __FirstBarInfo Extends __GadgetInfo
   *pModuleType.__Maker_ModuleType
   List ListChildBar.__ChildBarInfo()
   CountItem.l
EndStructure

;-[Structure]
;对话框结构
Structure __ToolBar_MainInfo Extends __AreaInfo
   *pColors.__ColorInfo
   *pWindow.__WindowInfo
   *pEvents.__EventInfo
   ;=========
   wtbComponents.__FirstBarInfo  ;电子元件  
   wtbCircuitMod.__FirstBarInfo  ;电子模块
   wtbSensorsMod.__FirstBarInfo  ;传感器模块
   wtbPowSwitchs.__FirstBarInfo  ;电源和开关
   wtbAccessorys.__FirstBarInfo  ;辅助部件
   wtbMainBoards.__FirstBarInfo  ;单片机开发板
   wtbOperations.__FirstBarInfo  ;基本编辑
   wtbMiscellane.__FirstBarInfo  ;基本编辑
   
   ;=========
   wtbTest.__ChildBarInfo
   ;=========
   ChildBar.__AreaInfo   ;次级工具栏
   ThirdBar.__AreaInfo   ;弹出菜单,即第三级
   hWindow.l
   hWindowHook.l
   Map *pMapToolItem.__ThirdBarInfo()
   ;=========
   *pCallSelectMatter
   ;=========
   *pCurrFirstBar.__FirstBarInfo
   *pCurrChildBar.__ChildBarInfo
   *pCurrThirdBar.__ThirdBarInfo
   *pModuleType.__Maker_ModuleType
EndStructure

;-[Global]
Global _ToolBar.__ToolBar_MainInfo


;-
;- ******** [Redraw] ********
;绘制一级工具栏
Procedure ToolBar_RedrawFirstBar()
   With _ToolBar
      BackColor = \pColors\BackColor
      HighColor = \pColors\HighColor
      ForeColor = \pColors\ForeColor 
      ForeColor = (Alpha(ForeColor) << 22 & $FF000000) |(ForeColor & $FFFFFF)
      
      ;主工具栏 
      LimitH = \pWindow\WindowH-45-150-9  
      If LimitH >= 290
         \H = 290  
         \W = #ToolBar_SingleLine
      Else
         \H = LimitH
         \W = #ToolBar_DoubleLine
      EndIf 
      \R = \X+\W+3
      \B = \Y+\H

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
      
      ItemX = \X-2
      ItemY = \Y+10      
      *pFirstBar.__FirstBarInfo = \wtbComponents
      For k = 1 To 7
         If ItemY+40 <= \B
            Define_RedrawGadget(\pEvents, *pFirstBar, ItemX, ItemY) : ItemY+40     ;模块元件
         Else 
            ItemX = \X+40
            ItemY = \Y+10 
            Define_RedrawGadget(\pEvents, *pFirstBar, ItemX, ItemY) : ItemY+40     ;模块元件
         EndIf 
         *pFirstBar + SizeOf(__FirstBarInfo)
      Next
   EndWith 
EndProcedure

;绘制二级工具栏
Procedure ToolBar_RedrawChildBar()

   BackColor = _ToolBar\pColors\BackColor
   HighColor = _ToolBar\pColors\HighColor
   ForeColor = _ToolBar\pColors\ForeColor 
   ForeColor = (Alpha(ForeColor) << 22 & $FF000000) |(ForeColor & $FFFFFF)
   ;次级工具栏 
   With _ToolBar\ChildBar
      \X = _ToolBar\R-2
      \Y = _ToolBar\pCurrFirstBar\Y-10
      LimitH = _ToolBar\pWindow\WindowH-\Y -25 -10
      LimitH = LimitH/40*40+10
      FrameH = 10 + _ToolBar\pCurrFirstBar\CountItem * 40 
      
      If FrameH > LimitH
         \H = LimitH
         \W = #ToolBar_DoubleLine
      Else 
         \H = FrameH
         \W = #ToolBar_SingleLine
      EndIf 
      \R = \X+\W+3
      \B = \Y+\H
      
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

      ItemX = \X-2
      ItemY = \Y+10 
   
      ForEach _ToolBar\pCurrFirstBar\ListChildBar()
         *pChildBar.__ChildBarInfo = _ToolBar\pCurrFirstBar\ListChildBar()
         If ItemY+40 <= \B
            Define_RedrawGadget(_ToolBar\pEvents, *pChildBar, ItemX, ItemY) : ItemY+40     ;模块元件
         Else 
            ItemX = \X+40-1
            ItemY = \Y+10 
            Define_RedrawGadget(_ToolBar\pEvents, *pChildBar, ItemX, ItemY) : ItemY+40     ;模块元件
         EndIf 
      Next 
   EndWith
EndProcedure

;绘制三级工具栏
Procedure ToolBar_RedrawThirdBar()
   BackColor = _ToolBar\pColors\BackColor
   HighColor = _ToolBar\pColors\HighColor
   ForeColor = _ToolBar\pColors\ForeColor 
   ForeColor = (Alpha(ForeColor) << 22 & $FF000000) |(ForeColor & $FFFFFF)

   ;次级工具栏 
   With _ToolBar\ThirdBar
      \X = _ToolBar\ChildBar\R-2
      \Y = _ToolBar\pCurrChildBar\Y-10
      LimitW = _ToolBar\pWindow\WindowW-\X -25 -10
      LimitW = LimitW/40*40+10
      FrameW = 10 + _ToolBar\pCurrChildBar\CountItem * 40 
      
      If FrameW > LimitW
         \W = LimitW
         \H = #ToolBar_DoubleLine-4
      Else 
         \W = FrameW
         \H = #ToolBar_SingleLine-4
      EndIf 
      \R = \X+\W
      \B = \Y+\H
      
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

      ItemX = \X+4
      ItemY = \Y+3 
   
      ForEach _ToolBar\pCurrChildBar\ListThirdBar()
         *pThirdBar.__ThirdBarInfo = _ToolBar\pCurrChildBar\ListThirdBar()
         If ItemX+40 <= \R
            Define_RedrawGadget(_ToolBar\pEvents, *pThirdBar, ItemX, ItemY) : ItemX+40     ;模块元件
         Else 
            ItemX = \X+4
            ItemY = \Y+3+40 
            Define_RedrawGadget(_ToolBar\pEvents, *pThirdBar, ItemX, ItemY) : ItemX+40     ;模块元件
         EndIf 
      Next 
   EndWith 
EndProcedure

;绘制事件
Procedure ToolBar_RedrawScreen()
   ToolBar_RedrawFirstBar()
   If _ToolBar\pCurrFirstBar And _ToolBar\pCurrFirstBar\CountItem
      ToolBar_RedrawChildBar()
      If _ToolBar\pCurrChildBar And _ToolBar\pCurrChildBar\CountItem
         ToolBar_RedrawThirdBar()      
      EndIf 
   EndIf 
EndProcedure

;-
;- ******** [Hook] ********
;光标在上事件[Screen_HookWindow()]
Procedure ToolBar_Hook_MOUSEMOVE(*pMouse.POINTS, Button)
   With _ToolBar
      ;判断光标是否落在次级工具栏上
      If \pCurrFirstBar
         If Macro_Gadget_InRect1(\pCurrFirstBar)
            InRect1 = #True
         EndIf
         If Macro_Gadget_InRect1(\ChildBar)
            InRect2 = #True
         EndIf 
         If \pCurrChildBar
            If Macro_Gadget_InRect1(\ThirdBar)
               InRect3 = #True
            EndIf          
         EndIf    
         
         If InRect1 Or InRect2 Or InRect3
            If \pCurrChildBar
               ForEach \pCurrChildBar\ListThirdBar()
                  If Macro_Gadget_InRect2(\pCurrChildBar\ListThirdBar())
                     \pCurrThirdBar = \pCurrChildBar\ListThirdBar()
                     ProcedureReturn \pCurrThirdBar 
                  EndIf 
               Next 
            EndIf 
            \pCurrThirdBar = #Null
            If Button = #False
               ForEach \pCurrFirstBar\ListChildBar()
                  If Macro_Gadget_InRect2(\pCurrFirstBar\ListChildBar())
                     \pCurrChildBar = \pCurrFirstBar\ListChildBar()
                     ProcedureReturn \pCurrChildBar
                     Break 
                  EndIf 
               Next 
            EndIf 
            ProcedureReturn \pCurrFirstBar
         EndIf 
      EndIf 

      ;判断光标是否落在主工具栏上
      If Macro_Gadget_InRect1(_ToolBar)
         *pFirstBar.__FirstBarInfo = \wtbComponents
         For k = 1 To 7
            If Macro_Gadget_InRect2(*pFirstBar)
               *pEventGadget = *pFirstBar
               Break 
            EndIf 
            *pFirstBar + SizeOf(__FirstBarInfo)
         Next
      EndIf 
      If \pCurrFirstBar <> *pEventGadget
         \pCurrChildBar = #Null
      EndIf 
      \pCurrFirstBar = *pEventGadget
   EndWith
   ProcedureReturn *pEventGadget
EndProcedure

;左键按下事件[Screen_HookWindow()]
Procedure ToolBar_Hook_LBUTTONDOWN(*pMouse.POINTS)
   With _ToolBar
      If \pCurrFirstBar 
         If \pCurrChildBar
            If Macro_Gadget_InRect1(\ThirdBar)
               ForEach \pCurrChildBar\ListThirdBar()
                  If Macro_Gadget_InRect2(\pCurrChildBar\ListThirdBar())
                     *pEventGadget = \pCurrChildBar\ListThirdBar()
                     Break 
                  EndIf 
               Next   
               ProcedureReturn *pEventGadget
            EndIf 
         EndIf 

         If Macro_Gadget_InRect1(\ChildBar)
            ForEach \pCurrFirstBar\ListChildBar()
               If Macro_Gadget_InRect2(\pCurrFirstBar\ListChildBar())
                  *pEventGadget = \pCurrFirstBar\ListChildBar()
                  Break 
               EndIf 
            Next 
            ProcedureReturn *pEventGadget
         EndIf 
      EndIf 
      ;判断光标是否落在主工具栏上
      If Macro_Gadget_InRect1(_ToolBar)
         *pFirstBar.__FirstBarInfo = \wtbComponents
         For k = 1 To 7
            If Macro_Gadget_InRect2(*pFirstBar)
               *pEventGadget = *pFirstBar
               Break 
            EndIf 
            *pFirstBar + SizeOf(__FirstBarInfo)
         Next
      EndIf 
   EndWith
   ProcedureReturn *pEventGadget
EndProcedure

;左键释放事件[Screen_HookWindow()]
Procedure ToolBar_Hook_LBUTTONUP(*pMouse.POINTS)
   With _ToolBar
      If \pCurrFirstBar 
         If \pCurrChildBar
            If Macro_Gadget_InRect1(\ThirdBar)
               ForEach \pCurrChildBar\ListThirdBar()
                  If Macro_Gadget_InRect2(\pCurrChildBar\ListThirdBar())
                     *pEventGadget = \pCurrChildBar\ListThirdBar()
                     If \pCallSelectMatter And \pCurrChildBar\ListThirdBar()\pModuleType
                        CallFunctionFast(\pCallSelectMatter, \pCurrChildBar\ListThirdBar()\pModuleType) 
                     EndIf 
                     PostEvent(#PB_Event_Gadget, \pWindow\WindowID, \pCurrChildBar\ListThirdBar()\GadgetID)
                     Break 
                  EndIf 
               Next     
               \pCurrFirstBar = #Null
               \pCurrChildBar = #Null
               \pCurrThirdBar = #Null
               ProcedureReturn *pEventGadget
            EndIf 
         EndIf 
         If Macro_Gadget_InRect1(\ChildBar)
            ForEach \pCurrFirstBar\ListChildBar()
               If Macro_Gadget_InRect2(\pCurrFirstBar\ListChildBar())
                  PostEvent(#PB_Event_Gadget, \pWindow\WindowID, \pCurrFirstBar\ListChildBar()\GadgetID)
                  
                  If \pCallSelectMatter And \pCurrFirstBar\ListChildBar()\pModuleType
                     CallFunctionFast(\pCallSelectMatter, \pCurrFirstBar\ListChildBar()\pModuleType) 
                  EndIf 
                  Break 
               EndIf 
            Next 
            If \pCurrChildBar = #Null Or \pCurrChildBar\CountItem = #Null
               \pCurrFirstBar = #Null
               \pCurrChildBar = #Null
               \pCurrThirdBar = #Null
            EndIf 
            ProcedureReturn *pEventGadget
         EndIf 
      EndIf 
      ;判断光标是否落在主工具栏上
      If Macro_Gadget_InRect1(_ToolBar)
         *pFirstBar.__FirstBarInfo = \wtbComponents
         For k = 1 To 7
            If Macro_Gadget_InRect2(*pFirstBar)
               *pEventGadget = *pFirstBar
               PostEvent(#PB_Event_Gadget, \pWindow\WindowID, *pFirstBar\GadgetID)
               Break 
            EndIf 
            *pFirstBar + SizeOf(__FirstBarInfo)
         Next
      EndIf 
   EndWith
   ProcedureReturn *pEventGadget
EndProcedure

;-
;- ******** [Create] ********
;创建一级菜单项
Procedure ToolBar_CreateFirstBar(*pGadget.__GadgetInfo, ToolItemID, W, H, IconX, IconY, IconW=32, IconH=32)
   With *pGadget
      \IsCreate = #True
      \GadgetID = ToolItemID
      IconID = _ToolBar\pWindow\ResourIconID
      FontColor = _ToolBar\pColors\BackColor  
      SideColor = _ToolBar\pColors\ForeColor
      BackColor = (Alpha(SideColor) << 23 & $FF000000) |(SideColor & $FFFFFF)
      
      HighColor = _ToolBar\pColors\HighColor
      HighColor1 = ((Alpha(HighColor)-120) << 24 & $FF000000) |(HighColor & $FFFFFF)
      HighColor2 = ((Alpha(HighColor)-060) << 24 & $FF000000) |(HighColor & $FFFFFF)
      
      
      \W = W : \H = H : \IconX = IconX : \IconY = IconY
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
      
      \MouseTopID = CreateImage(#PB_Any, W, H, 32, #PB_Image_Transparent)
      If StartDrawing(ImageOutput(\MouseTopID))
         DrawingMode(#PB_2DDrawing_AlphaBlend)
         Box(7, 0, W-14, H, HighColor1)         
         DrawAlphaImage(ImageID(\NormalcyID), 0, 0)
         StopDrawing()
      EndIf
      
      \HoldDownID = CreateImage(#PB_Any, W, H, 32, #PB_Image_Transparent)
      If StartDrawing(ImageOutput(\HoldDownID))
         DrawingMode(#PB_2DDrawing_AlphaBlend)
         Box(7, 0, W-14, H, HighColor2)         
         DrawAlphaImage(ImageID(\NormalcyID), 0, 0)
         StopDrawing()
      EndIf      
   EndWith
EndProcedure

;创建二级菜单项
Procedure ToolBar_CreateChildBar(*pFirstBar.__FirstBarInfo, ToolItemID, ItemW, ItemH, IconX, IconY, ModuleTypes$)
   *pChildBar.__ChildBarInfo = AddElement(*pFirstBar\ListChildBar())
   If ToolItemID = #PB_Any : ToolItemID = *pChildBar : EndIf 
   ToolBar_CreateFirstBar(*pChildBar, ToolItemID, ItemW, ItemH, IconX, IconY) 
   Balloon_Gadget(*pChildBar, "<"+ModuleTypes$+">")  
   *pFirstBar\CountItem = ListSize(*pFirstBar\ListChildBar())
   _ToolBar\pMapToolItem(ModuleTypes$)
   _ToolBar\pMapToolItem() = *pChildBar
   ProcedureReturn *pChildBar
EndProcedure

;创建三级菜单项
Procedure ToolBar_CreatePopupBar(*pGadget.__GadgetInfo, ToolItemID, W, H, IconX, IconY, IconW=32, IconH=32)
   With *pGadget
      \IsCreate = #True
      \GadgetID = ToolItemID
      IconID = _ToolBar\pWindow\ResourIconID
      FontColor = _ToolBar\pColors\BackColor  
      SideColor = _ToolBar\pColors\ForeColor
      BackColor = (Alpha(SideColor) << 23 & $FF000000) |(SideColor & $FFFFFF)
      
      HighColor = _ToolBar\pColors\HighColor
      HighColor1 = ((Alpha(HighColor)-120) << 24 & $FF000000) |(HighColor & $FFFFFF)
      HighColor2 = ((Alpha(HighColor)-060) << 24 & $FF000000) |(HighColor & $FFFFFF)
      
      \W = W : \H = H : \IconX = IconX : \IconY = IconY
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
      
      \MouseTopID = CreateImage(#PB_Any, W, H, 32, #PB_Image_Transparent)
      If StartDrawing(ImageOutput(\MouseTopID))
         DrawingMode(#PB_2DDrawing_AlphaBlend)
         Box(0, 5, W, H-10, HighColor1)         
         DrawAlphaImage(ImageID(\NormalcyID), 0, 0)
         StopDrawing()
      EndIf
      
      \HoldDownID = CreateImage(#PB_Any, W, H, 32, #PB_Image_Transparent)
      If StartDrawing(ImageOutput(\HoldDownID))
         DrawingMode(#PB_2DDrawing_AlphaBlend)
         Box(0, 5, W, H-10, HighColor2)         
         DrawAlphaImage(ImageID(\NormalcyID), 0, 0)
         StopDrawing()
      EndIf      
   EndWith
EndProcedure

;创建三级菜单项
Procedure ToolBar_CreateThirdBar(*pChildBar.__ChildBarInfo, ToolItemID, ItemW, ItemH, IconX, IconY, ModuleTypes$, ModuleType=#True)
   *pThirdBar.__ThirdBarInfo = AddElement(*pChildBar\ListThirdBar())
   If ToolItemID = #PB_Any : ToolItemID = *pThirdBar : EndIf 
   ToolBar_CreatePopupBar(*pThirdBar, ToolItemID, ItemW, ItemH, IconX, IconY) 
   Balloon_Gadget(*pThirdBar, ModuleTypes$) 
   If ModuleType And FindMapElement(_MapModule(), ModuleTypes$)
      _MapModule(ModuleTypes$)
      *pThirdBar\pModuleType = _MapModule()
   ElseIf ModuleType = #False 
      _ToolBar\pMapToolItem(ModuleTypes$)
      _ToolBar\pMapToolItem() = *pThirdBar
   EndIf  
   *pChildBar\CountItem = ListSize(*pChildBar\ListThirdBar()) 
   ProcedureReturn *pThirdBar
EndProcedure

;-
;一级工具栏子项: [电子元件]
Procedure ToolBar_Create_wtbComponents()
   With _ToolBar
      ItemW = #ToolBar_SingleLine + 4
      ToolBar_CreateFirstBar(\wtbComponents, #wtbComponents,  ItemW, 040, 032*0, 064) 
      Balloon_Gadget(\wtbComponents, "[电子元件]")

      *pChildBar = ToolBar_CreateChildBar(\wtbComponents, #PB_Any, ItemW, 040, 032*0, 224, "单色发光二极管")
         ToolBar_CreateThirdBar(*pChildBar, #PB_Any, 040, 050, 032*1, 224, "红色发光二极管[LED5MM]")
         ToolBar_CreateThirdBar(*pChildBar, #PB_Any, 040, 050, 032*2, 224, "黄色发光二极管[LED5MM]")
         ToolBar_CreateThirdBar(*pChildBar, #PB_Any, 040, 050, 032*3, 224, "绿色发光二极管[LED5MM]") 
         ToolBar_CreateThirdBar(*pChildBar, #PB_Any, 040, 050, 032*4, 224, "蓝色发光二极管[LED5MM]") 

      *pChildBar = ToolBar_CreateChildBar(\wtbComponents, #PB_Any, ItemW, 040, 032*0, 256, "双色发光二极管")
         ToolBar_CreateThirdBar(*pChildBar, #PB_Any, 040, 050, 032*1, 256, "红绿共阴[--]")
         ToolBar_CreateThirdBar(*pChildBar, #PB_Any, 040, 050, 032*2, 256, "红绿共阳[--]")
         ToolBar_CreateThirdBar(*pChildBar, #PB_Any, 040, 050, 032*3, 256, "红绿共脚[--]") 

      *pChildBar = ToolBar_CreateChildBar(\wtbComponents, #PB_Any, ItemW, 040, 032*0, 288, "变色发光二极管")
         ToolBar_CreateThirdBar(*pChildBar, #PB_Any, 040, 050, 032*1, 288, "七色LED[--]")

      *pChildBar = ToolBar_CreateChildBar(\wtbComponents, #PB_Any, ItemW, 040, 032*0, 320, "红外二极管")
         ToolBar_CreateThirdBar(*pChildBar, #PB_Any, 040, 050, 032*1, 320, "红外接收[--]")
         ToolBar_CreateThirdBar(*pChildBar, #PB_Any, 040, 050, 032*2, 320, "红外发射管[--]")
         
      *pChildBar = ToolBar_CreateChildBar(\wtbComponents, #PB_Any, ItemW, 040, 032*0, 352, "碳膜电阻")
         ToolBar_CreateThirdBar(*pChildBar, #PB_Any, 040, 050, 032*1, 352, "碳膜电阻[R220Ω]")
         ToolBar_CreateThirdBar(*pChildBar, #PB_Any, 040, 050, 032*2, 352, "碳膜电阻[R1KΩ]")
         ToolBar_CreateThirdBar(*pChildBar, #PB_Any, 040, 050, 032*3, 352, "碳膜电阻[R10KΩ]")

      *pChildBar = ToolBar_CreateChildBar(\wtbComponents, #PB_Any, ItemW, 040, 032*0, 384, "电容")
         ToolBar_CreateThirdBar(*pChildBar, #PB_Any, 040, 050, 032*1, 384, "陶瓷电容1μF[--]")
         ToolBar_CreateThirdBar(*pChildBar, #PB_Any, 040, 050, 032*2, 384, "电解电容10μF[--]")
         
      *pChildBar = ToolBar_CreateChildBar(\wtbComponents, #PB_Any, ItemW, 040, 032*0, 416, "其它元件")
         ToolBar_CreateThirdBar(*pChildBar, #PB_Any, 040, 050, 032*1, 416, "光敏电阻[--]")
         ToolBar_CreateThirdBar(*pChildBar, #PB_Any, 040, 050, 032*2, 416, "热敏电阻[--]")
         ToolBar_CreateThirdBar(*pChildBar, #PB_Any, 040, 050, 032*3, 416, "二极管[--]")
         ToolBar_CreateThirdBar(*pChildBar, #PB_Any, 040, 050, 032*4, 416, "三极管[--]")
   EndWith
EndProcedure

;一级工具栏子项: [电子模块]
Procedure ToolBar_Create_wtbCircuitMod()
   With _ToolBar
      ItemW = #ToolBar_SingleLine + 4
      ToolBar_CreateFirstBar(\wtbCircuitMod, #wtbPowSwitchs,  ItemW, 040, 032*1, 064) ;电机部件
      Balloon_Gadget(\wtbCircuitMod, "[电机部件]")
      
      *pChildBar = ToolBar_CreateChildBar(\wtbCircuitMod, #PB_Any, ItemW, 040, 032*0, 448, "继电器模块[--]")
         ToolBar_CreateThirdBar(*pChildBar, #PB_Any, 040, 050, 032*1, 448, "1位继电器模块[--]")
         ToolBar_CreateThirdBar(*pChildBar, #PB_Any, 040, 050, 032*2, 448, "2位继电器模块[--]")
         ToolBar_CreateThirdBar(*pChildBar, #PB_Any, 040, 050, 032*3, 448, "4位继电器模块[--]")

      *pChildBar = ToolBar_CreateChildBar(\wtbCircuitMod, #PB_Any, ItemW, 040, 032*0, 480, "数码管[--]")
         ToolBar_CreateThirdBar(*pChildBar, #PB_Any, 040, 050, 032*1, 480, "1位数码管[--]")
         ToolBar_CreateThirdBar(*pChildBar, #PB_Any, 040, 050, 032*2, 480, "2位数码管[--]")
         ToolBar_CreateThirdBar(*pChildBar, #PB_Any, 040, 050, 032*3, 480, "3位数码管[--]")
         ToolBar_CreateThirdBar(*pChildBar, #PB_Any, 040, 050, 032*4, 480, "4位数码管[--]")

      *pChildBar = ToolBar_CreateChildBar(\wtbCircuitMod, #PB_Any, ItemW, 040, 032*0, 512, "蜂鸣器[--]")
         ToolBar_CreateThirdBar(*pChildBar, #PB_Any, 040, 050, 032*1, 512, "有源蜂鸣器[--]")
         ToolBar_CreateThirdBar(*pChildBar, #PB_Any, 040, 050, 032*2, 512, "无源蜂鸣器[--]")

      *pChildBar = ToolBar_CreateChildBar(\wtbCircuitMod, #PB_Any, ItemW, 040, 032*0, 544, "其它模块[--]")
         ToolBar_CreateThirdBar(*pChildBar, #PB_Any, 040, 050, 032*1, 544, "晶体管制冷片[--]")
   EndWith
EndProcedure

;一级工具栏子项: [传感器模块]
Procedure ToolBar_Create_wtbSensorsMod()
   With _ToolBar
      ItemW = #ToolBar_SingleLine + 4
      ToolBar_CreateFirstBar(\wtbSensorsMod, #wtbSensorsMod,  ItemW, 040, 032*2, 064) 
      Balloon_Gadget(\wtbSensorsMod, "[传感器模块]")
      
      *pChildBar = ToolBar_CreateChildBar(\wtbSensorsMod, #PB_Any, ItemW, 040, 032*0, 576, "光电传感器[--]")
         ToolBar_CreateThirdBar(*pChildBar, #PB_Any, 040, 050, 032*1, 576, "循迹模块[--]")
         ToolBar_CreateThirdBar(*pChildBar, #PB_Any, 040, 050, 032*2, 576, "寻线模块[--]")
         ToolBar_CreateThirdBar(*pChildBar, #PB_Any, 040, 050, 032*3, 576, "光敏模块[--]") 

      *pChildBar = ToolBar_CreateChildBar(\wtbSensorsMod, #PB_Any, ItemW, 040, 032*0, 608, "温湿传感器[--]")
         ToolBar_CreateThirdBar(*pChildBar, #PB_Any, 040, 050, 032*1, 608, "温湿度传感器[--]")
         ToolBar_CreateThirdBar(*pChildBar, #PB_Any, 040, 050, 032*2, 608, "土壤湿度传感器[--]")
         ToolBar_CreateThirdBar(*pChildBar, #PB_Any, 040, 050, 032*3, 608, "雨滴传感器[--]")
      
      *pChildBar = ToolBar_CreateChildBar(\wtbSensorsMod, #PB_Any, ItemW, 040, 032*0, 640, "声波传感器[--]")
         ToolBar_CreateThirdBar(*pChildBar, #PB_Any, 040, 050, 032*1, 640, "超声波测距模块[--]")
         ToolBar_CreateThirdBar(*pChildBar, #PB_Any, 040, 050, 032*2, 640, "声音传感器[--]")  

      *pChildBar = ToolBar_CreateChildBar(\wtbSensorsMod, #PB_Any, ItemW, 040, 032*0, 672, "体感传感器[--]")
         ToolBar_CreateThirdBar(*pChildBar, #PB_Any, 040, 050, 032*1, 672, "人体红外传感器[--]")
         ToolBar_CreateThirdBar(*pChildBar, #PB_Any, 040, 050, 032*2, 672, "触摸传感器[--]")   

      *pChildBar = ToolBar_CreateChildBar(\wtbSensorsMod, #PB_Any, ItemW, 040, 032*0, 704, "其它传感器[--]")
         ToolBar_CreateThirdBar(*pChildBar, #PB_Any, 040, 050, 032*1, 704, "烟雾传感器[--]")
         ToolBar_CreateThirdBar(*pChildBar, #PB_Any, 040, 050, 032*2, 704, "热敏模块[--]")
   EndWith
EndProcedure

;一级工具栏子项: [电源和开关]
Procedure ToolBar_Create_wtbPowSwitchs()
   With _ToolBar
      ItemW = #ToolBar_SingleLine + 4
      ToolBar_CreateFirstBar(\wtbPowSwitchs, #wtbPowSwitchs,  ItemW, 040, 032*3, 064) 
      Balloon_Gadget(\wtbPowSwitchs, "[电源和开关]")
      IconX = 160
      *pChildBar = ToolBar_CreateChildBar(\wtbPowSwitchs, #PB_Any, ItemW, 040, IconX+032*0, 224, "干电池[--]")
         ToolBar_CreateThirdBar(*pChildBar, #PB_Any, 040, 050, IconX+032*1, 224, "干电池盒[BC5x3]")
         ToolBar_CreateThirdBar(*pChildBar, #PB_Any, 040, 050, IconX+032*2, 224, "干电池盒[BC5x4]")
         ToolBar_CreateThirdBar(*pChildBar, #PB_Any, 040, 050, IconX+032*3, 224, "干电池盒[BC5x5]")
         ToolBar_CreateThirdBar(*pChildBar, #PB_Any, 040, 050, IconX+032*4, 224, "9V电池")
      
      *pChildBar = ToolBar_CreateChildBar(\wtbPowSwitchs, #PB_Any, ItemW, 040, IconX+032*0, 256, "锂电池组[--]")
         ToolBar_CreateThirdBar(*pChildBar, #PB_Any, 040, 050, IconX+032*1, 256, "18650x2[---]")
         ToolBar_CreateThirdBar(*pChildBar, #PB_Any, 040, 050, IconX+032*2, 256, "18650x3[---]")
         ToolBar_CreateThirdBar(*pChildBar, #PB_Any, 040, 050, IconX+032*3, 256, "14500x2[---]")
         ToolBar_CreateThirdBar(*pChildBar, #PB_Any, 040, 050, IconX+032*4, 256, "14500x3[---]") 
 
      *pChildBar = ToolBar_CreateChildBar(\wtbPowSwitchs, #PB_Any, ItemW, 040, IconX+032*0, 288, "聚合物电池[--]")

      *pChildBar = ToolBar_CreateChildBar(\wtbPowSwitchs, #PB_Any, ItemW, 040, IconX+032*0, 320, "适配器电源[--]")
         ToolBar_CreateThirdBar(*pChildBar, #PB_Any, 040, 050, IconX+032*1, 320, "5V电源适配器[---]")
         ToolBar_CreateThirdBar(*pChildBar, #PB_Any, 040, 050, IconX+032*2, 320, "9V电源适配器[---]")
         ToolBar_CreateThirdBar(*pChildBar, #PB_Any, 040, 050, IconX+032*3, 320, "12电源适配器[---]")
      
      *pChildBar = ToolBar_CreateChildBar(\wtbPowSwitchs, #PB_Any, ItemW, 040, IconX+032*0, 352, "波动开关[--]")
         ToolBar_CreateThirdBar(*pChildBar, #PB_Any, 040, 050, IconX+032*1, 352, "船型波动开关[KCD11]")
         ToolBar_CreateThirdBar(*pChildBar, #PB_Any, 040, 050, IconX+032*2, 352, "船型波动开关[KCD12]")  

      *pChildBar = ToolBar_CreateChildBar(\wtbPowSwitchs, #PB_Any, ItemW, 040, IconX+032*0, 384, "其它开关[--]")
         ToolBar_CreateThirdBar(*pChildBar, #PB_Any, 040, 050, IconX+032*1, 384, "电位器[---]")
         ToolBar_CreateThirdBar(*pChildBar, #PB_Any, 040, 050, IconX+032*2, 384, "按钮[---]")
         ToolBar_CreateThirdBar(*pChildBar, #PB_Any, 040, 050, IconX+032*3, 384, "接触开关[---]")
   EndWith
   
EndProcedure

;一级工具栏子项: [辅助部件]
Procedure ToolBar_Create_wtbAccessorys()
   With _ToolBar
      ItemW = #ToolBar_SingleLine + 4
      ToolBar_CreateFirstBar(\wtbAccessorys, #wtbAccessorys,  ItemW, 040, 032*4, 064)
      Balloon_Gadget(\wtbAccessorys, "[辅助部件]")

      IconX=160
      *pChildBar = ToolBar_CreateChildBar(\wtbAccessorys, #PB_Any, ItemW, 040, IconX+032*0, 416, "面包板[--]")
         ToolBar_CreateThirdBar(*pChildBar, #PB_Any, 040, 050, IconX+032*1, 416, "小面包板[SYB-170]")
         ToolBar_CreateThirdBar(*pChildBar, #PB_Any, 040, 050, IconX+032*2, 416, "小面包板[SYB-46]") 

      *pChildBar = ToolBar_CreateChildBar(\wtbAccessorys, #PB_Any, ItemW, 040, IconX+032*0, 448, "直流电机[--]")
         ToolBar_CreateThirdBar(*pChildBar, #PB_Any, 040, 050, IconX+032*1, 448, "直流马达[---]")
         ToolBar_CreateThirdBar(*pChildBar, #PB_Any, 040, 050, IconX+032*2, 448, "TT减速马达1:48[---]")
         ToolBar_CreateThirdBar(*pChildBar, #PB_Any, 040, 050, IconX+032*3, 448, "TT减速马达1:120[---]")
          
      *pChildBar = ToolBar_CreateChildBar(\wtbAccessorys, #PB_Any, ItemW, 040, IconX+032*0, 480, "步进电机[--]")
         ToolBar_CreateThirdBar(*pChildBar, #PB_Any, 040, 050, IconX+032*1, 480, "舵机[---]")
         ToolBar_CreateThirdBar(*pChildBar, #PB_Any, 040, 050, IconX+032*2, 480, "步进电机[---]")

      *pChildBar = ToolBar_CreateChildBar(\wtbAccessorys, #PB_Any, ItemW, 040, IconX+032*0, 512, "驱动板[--]")
         ToolBar_CreateThirdBar(*pChildBar, #PB_Any, 040, 050, IconX+032*1, 512, "a4988步进电机驱动[---]")
         ToolBar_CreateThirdBar(*pChildBar, #PB_Any, 040, 050, IconX+032*2, 512, "9110电机驱动[---]")
         
      *pChildBar = ToolBar_CreateChildBar(\wtbAccessorys, #PB_Any, ItemW, 040, IconX+032*0, 544, "逻辑芯片[--]")
         ToolBar_CreateThirdBar(*pChildBar, #PB_Any, 040, 050, IconX+032*1, 544, "4069逻辑芯片[---]")
         ToolBar_CreateThirdBar(*pChildBar, #PB_Any, 040, 050, IconX+032*2, 544, "4081逻辑芯片[---]")
   EndWith
EndProcedure

;一级工具栏子项: [单片机开发板]
Procedure ToolBar_Create_wtbMainBoards()
   With _ToolBar
      ItemW = #ToolBar_SingleLine + 4
      ToolBar_CreateFirstBar(\wtbMainBoards, #wtbMainBoards,  ItemW, 040, 032*5, 064)
      Balloon_Gadget(\wtbMainBoards, "[单片机开发板]")
      IconX = 160
      *pChildBar = ToolBar_CreateChildBar(\wtbMainBoards, #PB_Any, ItemW, 040, IconX+032*0, 576, "51开发板[--]")
         ToolBar_CreateThirdBar(*pChildBar, #PB_Any, 040, 050, IconX+032*1, 576, "51开发板[---]")
      
      *pChildBar = ToolBar_CreateChildBar(\wtbMainBoards, #PB_Any, ItemW, 040, IconX+032*0, 608, "ESP32开发板[--]")
         ToolBar_CreateThirdBar(*pChildBar, #PB_Any, 040, 050, IconX+032*1, 608, "ESP32开发板[---]")
      
      *pChildBar = ToolBar_CreateChildBar(\wtbMainBoards, #PB_Any, ItemW, 040, IconX+032*0, 640, "Arduino开发板[--]")
         ToolBar_CreateThirdBar(*pChildBar, #PB_Any, 040, 050, IconX+032*1, 640, "Arduino开发板[---]")
         
      *pChildBar = ToolBar_CreateChildBar(\wtbMainBoards, #PB_Any, ItemW, 040, IconX+032*0, 672, "Micro:bit开发板[--]")
         ToolBar_CreateThirdBar(*pChildBar, #PB_Any, 040, 050, IconX+032*1, 672, "Micro:bit开发板[---]")
   EndWith
EndProcedure

;一级工具栏子项: [基本编辑]
Procedure ToolBar_Create_wtbOperations()
   With _ToolBar
      ItemW = #ToolBar_SingleLine + 4
      ToolBar_CreateFirstBar(\wtbOperations, #wtbOperations,  ItemW, 040, 032*6, 064) ;基本编辑
      Balloon_Gadget(\wtbOperations, "[基本编辑]")
      *pChildBar.__ChildBarInfo
      
      *pChildBar = ToolBar_CreateChildBar(\wtbOperations, #wmiCreateString, ItemW, 040, 032*0, 096, "添加标签")
      ModuleTypes$ = "标签控件[Label]"
      If FindMapElement(_MapModule(), ModuleTypes$)
         _MapModule(ModuleTypes$)
         *pChildBar\pModuleType = _MapModule()
      EndIf  

      *pChildBar = ToolBar_CreateChildBar(\wtbOperations, #wmiDeleteObject, ItemW, 040, 032*1, 096, "删除对象")
      
      *pChildBar = ToolBar_CreateChildBar(\wtbOperations, #PB_Any, ItemW, 040, 032*2, 096, "叠放次序")
         ToolBar_CreateThirdBar(*pChildBar, #wmiLayerTop,     040, 050, 032*0, 192, "置于顶层", #False)
         ToolBar_CreateThirdBar(*pChildBar, #wmiLayerBottom,  040, 050, 032*1, 192, "置于底层", #False)
         ToolBar_CreateThirdBar(*pChildBar, #wmiLayerPrev,    040, 050, 032*2, 192, "上移一层", #False)
         ToolBar_CreateThirdBar(*pChildBar, #wmiLayerNext,    040, 050, 032*3, 192, "下移一层", #False)
         
      *pChildBar = ToolBar_CreateChildBar(\wtbOperations, #PB_Any, ItemW, 040, 032*3, 096, "旋转或翻转")
         ToolBar_CreateThirdBar(*pChildBar, #wmiRotateTurnL90,040, 050, 032*4, 192, "左转90度", #False)
         ToolBar_CreateThirdBar(*pChildBar, #wmiRotateTurnR90,040, 050, 032*5, 192, "右转90度", #False)
         ToolBar_CreateThirdBar(*pChildBar, #wmiRotateFlip180,040, 050, 032*6, 192, "翻转对象", #False)

      *pChildBar = ToolBar_CreateChildBar(\wtbOperations, #PB_Any, ItemW, 040, 032*4, 096, "对象对齐")
         ToolBar_CreateThirdBar(*pChildBar, #wmiAlignLeft,    040, 050, 032*0, 128, "左对齐",       #False)
         ToolBar_CreateThirdBar(*pChildBar, #wmiAlignCenter,  040, 050, 032*1, 128, "水平中心对齐", #False)
         ToolBar_CreateThirdBar(*pChildBar, #wmiAlignRight,   040, 050, 032*2, 128, "右对齐",       #False)
         ToolBar_CreateThirdBar(*pChildBar, #wmiAlignTop,     040, 050, 032*3, 128, "上对齐",       #False)
         ToolBar_CreateThirdBar(*pChildBar, #wmiAlignMiddle,  040, 050, 032*4, 128, "垂直中心对齐", #False)

      *pChildBar = ToolBar_CreateChildBar(\wtbOperations, #PB_Any, ItemW, 040, 032*5, 096, "对象分布")
         ToolBar_CreateThirdBar(*pChildBar, #wmiEvenlyLeft,   040, 050, 032*0, 160, "左侧分布",     #False)
         ToolBar_CreateThirdBar(*pChildBar, #wmiEvenlyCenter, 040, 050, 032*1, 160, "水平中心分布", #False)
         ToolBar_CreateThirdBar(*pChildBar, #wmiEvenlySpace,  040, 050, 032*2, 160, "水平间距分布", #False)
         ToolBar_CreateThirdBar(*pChildBar, #wmiEvenlyRight,  040, 050, 032*3, 160, "右侧分布",     #False)
         ToolBar_CreateThirdBar(*pChildBar, #wmiEvenlyTop,    040, 050, 032*0, 160, "上侧分布",     #False)
         ToolBar_CreateThirdBar(*pChildBar, #wmiEvenlyMiddle, 040, 050, 032*1, 160, "垂直中心分布", #False)
         ToolBar_CreateThirdBar(*pChildBar, #wmiEvenlyBorder, 040, 050, 032*2, 160, "垂直间距分布", #False)
         ToolBar_CreateThirdBar(*pChildBar, #wmiEvenlyBottom, 040, 050, 032*3, 160, "下侧分布",     #False)

      *pChildBar = ToolBar_CreateChildBar(\wtbOperations, #wmiMergerGroups, ItemW, 040, 032*6, 096, "对象组合")
      *pChildBar = ToolBar_CreateChildBar(\wtbOperations, #wmiDivideGroups, ItemW, 040, 032*7, 096, "拆散组合")
      *pChildBar = ToolBar_CreateChildBar(\wtbOperations, #wmiDupontsColor, ItemW, 040, 032*8, 096, "颜色")
   EndWith
EndProcedure

Procedure ToolBar_Create_wtbMiscellane()
   With _ToolBar
      ItemW = #ToolBar_SingleLine + 4
      ToolBar_CreateFirstBar(\wtbMiscellane, #wtbMiscellane,  ItemW, 040, 288, 064) ;杂类
      *pChildBar.__ChildBarInfo
      *pChildBar = ToolBar_CreateChildBar(\wtbMiscellane, #PB_Any, ItemW, 040, 032*2, 096, "杂类")
         ToolBar_CreateThirdBar(*pChildBar, #wmiAlignGrids, 040, 050, 192, 128, "对齐网格", #False)
   EndWith
EndProcedure


;-
;- ======> [External Call] <======
;工具栏初始化
Procedure ToolBar_Initial(*pWindow.__WindowInfo, *pColors, *pEvents)
   With _ToolBar
      \pColors       = *pColors
      \pEvents       = *pEvents
      \pWindow       = *pWindow
      \X             = 5
      \Y             = 46
      \W             = #ToolBar_SingleLine
      ToolBar_Create_wtbComponents()   ;电子元件
      ToolBar_Create_wtbCircuitMod()   ;电子模块 
      ToolBar_Create_wtbSensorsMod()   ;传感器模块      
      ToolBar_Create_wtbPowSwitchs()   ;电源和开关      
      ToolBar_Create_wtbAccessorys()   ;电源和开关
      ToolBar_Create_wtbMainBoards()   ;单片机开发板
      ToolBar_Create_wtbOperations()   ;基本编辑
      ToolBar_Create_wtbMiscellane()   ;基本编辑
   EndWith
EndProcedure

Procedure ToolBar_ChangeStyle(*pColors)
   With _ToolBar
      \pColors = *pColors
      ItemW = #ToolBar_SingleLine + 4
      *pFirstBar.__FirstBarInfo = \wtbComponents
      For k = 1 To 8
         ToolBar_CreateFirstBar(*pFirstBar, *pFirstBar\GadgetID,  ItemW, 040, *pFirstBar\IconX, *pFirstBar\IconY)
         ForEach *pFirstBar\ListChildBar()
            *pChildBar.__ChildBarInfo = *pFirstBar\ListChildBar()
            ToolBar_CreateFirstBar(*pChildBar, *pChildBar\GadgetID,  ItemW, 040, *pChildBar\IconX, *pChildBar\IconY)
            ForEach *pChildBar\ListThirdBar()
               *pThirdBar.__ThirdBarInfo = *pChildBar\ListThirdBar()
               ToolBar_CreatePopupBar(*pThirdBar, *pThirdBar\GadgetID,  040, 050, *pThirdBar\IconX, *pThirdBar\IconY)
            Next 
         Next 
         *pFirstBar + SizeOf(__FirstBarInfo)
      Next
   EndWith
EndProcedure
   
;注销工具栏
Procedure ToolBar_Release()
   With _ToolBar
      *pFirstBar.__FirstBarInfo = \wtbComponents
      For k = 1 To 8
         ForEach *pFirstBar\ListChildBar()
            *pChildBar.__ChildBarInfo = *pFirstBar\ListChildBar()
            ForEach *pChildBar\ListThirdBar()
               Define_FreeGadget(*pChildBar\ListThirdBar())
            Next 
            FreeList(*pChildBar\ListThirdBar())
            Define_FreeGadget(*pFirstBar\ListChildBar())
         Next 
         Define_FreeGadget(*pFirstBar)
         FreeList(*pFirstBar\ListChildBar())
         *pFirstBar + SizeOf(__FirstBarInfo)
      Next
      FreeMap(\pMapToolItem())
   EndWith
EndProcedure

Procedure ToolBar_SelectItem(ToolItemName$)
   With _ToolBar
      If FindMapElement(\pMapToolItem(), ToolItemName$)
         \pMapToolItem(ToolItemName$)
         ProcedureReturn \pMapToolItem()
      Else 
         ProcedureReturn #Null
      EndIf 
   EndWith
EndProcedure

;设置CallBack函数
Procedure ToolBar_CallBack(CallBackType, *pCallFunction)
   With _ToolBar
      Select CallBackType
         Case #CallBack_SelectMatter : \pCallSelectMatter = *pCallFunction
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
   Window\WindowH = 650
   Window\WindowW = 1000
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
            Result = ToolBar_Hook_MOUSEMOVE    (@lParam, wParam)
            If \pEvents\pMouseTop <> Result : \pEvents\pMouseTop = Result : Refresh = #True : EndIf
         Case #WM_LBUTTONDOWN  
            Result = ToolBar_Hook_LBUTTONDOWN  (@lParam)
            If \pEvents\pHoldDown <> Result : \pEvents\pHoldDown = Result : Refresh = #True : EndIf            
            
         Case #WM_LBUTTONUP
            Result = ToolBar_Hook_LBUTTONUP    (@lParam)
            If \pEvents\pHoldDown Or \pEvents\pMouseTop : \pEvents\pHoldDown = #Null : \pEvents\pMouseTop = #Null : Refresh = #True : EndIf    

      EndSelect 
      If Result = 0 
         Result = CallWindowProc_(\hWindowHook, hWindow, uMsg, wParam, lParam) 
      ElseIf Refresh = #True
         If StartDrawing(CanvasOutput(#cvsScreen))
            Box(0, 0, 900, 650, #Define_BackColor&$FFFFFF)
            ToolBar_RedrawScreen()
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
         Case #PB_Event_Gadget
            GadgetID = EventGadget()
            If Refresh = #True
               If StartDrawing(CanvasOutput(#cvsScreen))
                  Box(0, 0, 900, 650, #Define_BackColor&$FFFFFF)
                  ToolBar_RedrawScreen()
                  StopDrawing()
               EndIf
            EndIf 
      EndSelect
   Until IsExitWindow = #True 
   ToolBar_Release()
   FreeFont(Window\Font12ID)
   End
   ;======================
DataSection
_ICON_Resources:
   IncludeBinary ".\ICON.png" 
EndDataSection

   
CompilerEndIf 





















; IDE Options = PureBasic 5.62 (Windows - x86)
; CursorPosition = 757
; FirstLine = 732
; Folding = ------
; EnableXP
; Executable = DEMO.exe