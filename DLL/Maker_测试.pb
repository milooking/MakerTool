
;-[Compiler]
;  #DLLTest = #True  ;采用DLL
#DLLTest = #False

CompilerIf #DLLTest = #True
   IncludeFile "Maker_Import.pb"
CompilerElse 
   IncludeFile "Maker_Engine.pb"
CompilerEndIf 



;-[Enumeration]
;控件ID
Enumeration
   #winScreen
   #cvsScreen
   #wmbScreen
   #wtbScreen
   #wsbScreen
   #cvsModule
   #scbVerScroll
   #scbHorScroll
   
   ;=================
   #imgAlignTop  
   #imgAlignMiddle   
   #imgAlignBottom   
   #imgAlignLeft
   #imgAlignCenter   
   #imgAlignRight
   #imgVertical   
   #imgTraverse

   #imgFloorTop
   #imgFloorPrev
   #imgFloorNext
   #imgFloorBottom
   
   #imgFileCreate
   #imgFileOpen
   #imgFileSave
   #imgFileSaveAs
   #imgFileClose
   
   #imgLayerZoom100
   #imgLayerZoom075
   #imgLayerZoom050
   #imgLayerZoom025
   
   #imgRightTurn090   
   #imgLeftTurn090
   #imgHorizFlip180
   
   #imgMatterCopy
   #imgMatterPaste
   #imgObjectFree
   
   #imgDupontMod
   #imgDupontDel
   #imgScreenshot
   #imgCreateGroups
   #imgCancelGroups
   #imgCount
   
   #imgLayerZoom200
   #imgLayerZoom150
   ;=================
   #imgAddString
   #fntModule
EndEnumeration
   

;-[Structure]
Structure __Maker_ModuleInfo
   ModuleGroup$      ;模块编组
   ModuleTypes$      ;模块类型
   ModuleModel$      ;模块型号
   ModuleName$       ;模块名称
   ModuleNote$       ;模块说明
   hModuleIcon.l     ;模块图标ID
   ModuleID.l
   X.w
   Y.w
   W.w
   H.w
   R.w
   B.w 
EndStructure

Structure __Maker_ModuleGroup
   GroupName$
   List ListModule.__Maker_ModuleInfo()
   X.w
   Y.w
   W.w
   H.w
   R.w
   B.w 
   IsVisible.l
EndStructure

   
Structure __Maker_MainInfo
   EngineID.l
   DesignID.l
   ModuleID.l
   WindowW.l
   WindowH.l
   OffsetX.l
   OffsetY.l
   CanvasW.l
   CanvasH.l
   LayerZoom.f       ;缩放比例值
   *pCurrModule.__Maker_ModuleInfo 
   FileName$
   MenuItemZoom.l
   IsRegister.l
   IsExitWindow.b  
   Value.l
EndStructure


;-[Global]
Global _Maker.__Maker_MainInfo
Global NewList _ListGroups.__Maker_ModuleGroup()
;-[Include]
XIncludeFile "Maker_Function.pb"
;-
;- ******** [Redraw] ******** 

Procedure Maker_RedrawModule()
   If StartDrawing(CanvasOutput(#cvsModule))
      Box(000, 000, 200, 700, RGB(255, 255, 255))
      DrawingFont(FontID(#fntModule))
      DrawingMode(#PB_2DDrawing_Transparent)
      ;=================================
      PosX = 005
      PosY = 001
      ForEach _ListGroups()
         Box(000, PosY, 200, 024, $E0E0E0)
         DrawText(010, PosY+002, _ListGroups()\GroupName$, $404040)
         _ListGroups()\X = 000
         _ListGroups()\Y = PosY
         _ListGroups()\W = 200
         _ListGroups()\H = 026-2
         _ListGroups()\R = _ListGroups()\X+_ListGroups()\W
         _ListGroups()\B = _ListGroups()\Y+_ListGroups()\H
         PosY + 026
         If _ListGroups()\IsVisible = #True
            ForEach _ListGroups()\ListModule()
               With _ListGroups()\ListModule()
                  If _Maker\pCurrModule = _ListGroups()\ListModule()
                     Box(001, PosY, 200-2, 48, $E0E0E0)
                     DrawingMode(#PB_2DDrawing_Outlined)
                     Box(001, PosY, 200-2, 48, $0000E0)
                     DrawingMode(#PB_2DDrawing_Transparent)
                  Else 
                     Box(000, PosY, 200, 48, $F0F0F0)
                  EndIf   
                  If \hModuleIcon
                     DrawAlphaImage(\hModuleIcon, PosX, PosY+3)
                  EndIf 
                  DrawText(PosX+50, PosY+04, \ModuleModel$, $404040)
                  DrawText(PosX+50, PosY+24, \ModuleName$,  $404040)  
                  \X = 000
                  \Y = PosY
                  \W = 200
                  \H = 50-2
                  \R = \X+\W
                  \B = \Y+\H
                  PosY + 50
               EndWith
            Next 
         EndIf 
      Next 
      ;=================================
      GadgetW = GadgetWidth(#cvsModule)
      GadgetH = GadgetHeight(#cvsModule)
      Line(0, 0, GadgetW, 1, $808080)
      Line(0, 0, 001, GadgetH, $808080)
      Line(GadgetW-1, 0, 1, GadgetH, $FFFFFF)
      Line(000, GadgetH-1, GadgetW, 1, $FFFFFF)
      StopDrawing()
   EndIf
EndProcedure

Procedure Maker_RedrawScreen()
   GadgetW = GadgetWidth(#cvsScreen)
   GadgetH = GadgetHeight(#cvsScreen)     
   hImage = Engine_RedrawCanvas(_Maker\DesignID, GadgetW, GadgetH)
   If StartDrawing(CanvasOutput(#cvsScreen))
      Box(0, 0, GadgetW, GadgetH, $F0F0F0)
      
      If hImage 
         CanvasW = _Maker\CanvasW * _Maker\LayerZoom
         CanvasH = _Maker\CanvasH * _Maker\LayerZoom
         If CanvasW < GadgetW : ImageX = (GadgetW-CanvasW)/2 : EndIf 
         If CanvasH < GadgetH : ImageY = (GadgetH-CanvasH)/2 : EndIf 
         
         _Maker\OffsetX = ImageX
         _Maker\OffsetY = ImageY
         
         DrawImage(hImage, ImageX, ImageY) 
      Else 
         Debug "出错 Engine_RedrawCanvas()"
      EndIf 

      Line(0, 0, GadgetW, 1, $808080)
      Line(0, 0, 001, GadgetH, $808080)
      Line(GadgetW-1, 0, 1, GadgetH, $FFFFFF)
      Line(000, GadgetH-1, GadgetW, 1, $FFFFFF)
      StopDrawing()
   EndIf
EndProcedure

;-
;- ******** [Event] ******** 

Procedure Maker_CreateDesign()
   If _Maker\DesignID
      Engine_FreeDesign(_Maker\DesignID)
   EndIf 
;    _Maker\DesignID = Engine_CreateDesign(_Maker\EngineID, _Maker\CanvasW, _Maker\CanvasH) 
   _Maker\DesignID = Engine_CreateDesign(_Maker\EngineID) 
   ProcedureReturn Bool(_Maker\DesignID)
EndProcedure

Procedure Maker_OpenDesign() 
   Pattern$ = "电路图 (*.mct)|*.mct"
   Pattern = 0    ; 默认选择第一个
   FileName$ = OpenFileRequester("请选择要打开的文件", _Maker\FileName$, Pattern$, Pattern)
   If FileName$
      _Maker\FileName$ = FileName$
      _Maker\DesignID = Engine_LoadDesign(_Maker\EngineID, FileName$)
      If _Maker\DesignID 
         _Maker\CanvasW = Engine_GetAttribute(_Maker\DesignID, #Attribute_CanvasWidth) 
         _Maker\CanvasH = Engine_GetAttribute(_Maker\DesignID, #Attribute_CanvasHeight) 
      EndIf 
      ProcedureReturn Bool(_Maker\DesignID)
   EndIf
   
EndProcedure

Procedure Maker_SaveDesign(IsSaveAs = #False) 
   If _Maker\FileName$ = #Null$ Or IsSaveAs = #True
      If _Maker\FileName$ = #Null$
         FileName$ = "新建电路图.mct" 
      Else 
         FileName$ = _Maker\FileName$
      EndIf 
      
      Pattern$ = "电路图 (*.mct)|*.mct"
      FileName$ = SaveFileRequester("请选择要保存的文件", FileName$, Pattern$, 0)
      If FileName$
         If LCase(GetExtensionPart(FileName$)) <> "mct" ;判断后辍是不是mct
            FileName$+".mct"
         EndIf 
         _Maker\FileName$ = FileName$
      Else 
         ProcedureReturn 
      EndIf 
   EndIf 
   Result = Engine_SaveDesign(_Maker\DesignID, _Maker\FileName$)
   If Result
      MessageRequester("迷路提示", "保存成功!")
   Else
      MessageRequester("迷路提示", "保存失败!")
   EndIf 
EndProcedure

Procedure Maker_Screenshot() 
   Pattern$ = "电路图 (*.png)|*.png"
   FileName$ = SaveFileRequester("请选择要保存的文件", "电路图.png", Pattern$, 0)
   If FileName$
      If LCase(GetExtensionPart(FileName$)) <> "png" ;判断后辍是不是mct
         FileName$+".png"
      EndIf 
   Else 
      ProcedureReturn 
   EndIf 
   Result = Engine_Screenshot(_Maker\DesignID, FileName$) 
   If Result
      MessageRequester("迷路提示", "截屏成功!")
   Else
      MessageRequester("迷路提示", "截屏失败!")
   EndIf 
EndProcedure


Procedure Maker_EventWindow_EventMenu()
   MenuID = EventMenu()
   Select MenuID
      ;========[文件]=======
      Case #imgFileCreate     : Refresh = Maker_CreateDesign()
      Case #imgFileOpen       : Refresh = Maker_OpenDesign() 
      Case #imgFileSave       : Refresh = Maker_SaveDesign() 
      Case #imgFileSaveAs     : Refresh = Maker_SaveDesign(#True) 
      Case #imgFileClose      : Refresh = Maker_CreateDesign()
      ;========[图层]=======
      Case #imgObjectFree     : Refresh = Engine_SetAttribute(_Maker\DesignID, #Attribute_ObjectDelete,  #Null) 
      Case #imgDupontDel
      Case #imgDupontMod
      Case #imgCreateGroups   : Refresh = Engine_SetAttribute(_Maker\DesignID, #Attribute_ActiveGroups,  #Object_Group_Merger) 
      Case #imgCancelGroups   : Refresh = Engine_SetAttribute(_Maker\DesignID, #Attribute_ActiveGroups,  #Object_Group_Divide) 
      ;========[图层]=======
      Case #imgFloorTop       : Refresh = Engine_SetAttribute(_Maker\DesignID, #Attribute_ObjectLayer,  #Object_Layer_Top) 
      Case #imgFloorPrev      : Refresh = Engine_SetAttribute(_Maker\DesignID, #Attribute_ObjectLayer,  #Object_Layer_Prev) 
      Case #imgFloorNext      : Refresh = Engine_SetAttribute(_Maker\DesignID, #Attribute_ObjectLayer,  #Object_Layer_Next) 
      Case #imgFloorBottom    : Refresh = Engine_SetAttribute(_Maker\DesignID, #Attribute_ObjectLayer,  #Object_Layer_Bottom)  
      Case #imgLeftTurn090    : Refresh = Engine_SetAttribute(_Maker\DesignID, #Attribute_MatterRotate, #Object_Rotate_TurnL90) 
      Case #imgRightTurn090   : Refresh = Engine_SetAttribute(_Maker\DesignID, #Attribute_MatterRotate, #Object_Rotate_TurnR90) 
      Case #imgHorizFlip180   : Refresh = Engine_SetAttribute(_Maker\DesignID, #Attribute_MatterRotate, #Object_Rotate_Flip180)   
      ;========[对齐]=======
      Case #imgAlignTop       : Refresh = Engine_SetAttribute(_Maker\DesignID, #Attribute_Alignment,  #Canvas_Align_Top)   
      Case #imgAlignMiddle    : Refresh = Engine_SetAttribute(_Maker\DesignID, #Attribute_Alignment,  #Canvas_Align_Middle)   
      Case #imgAlignBottom    : Refresh = Engine_SetAttribute(_Maker\DesignID, #Attribute_Alignment,  #Canvas_Align_Bottom)   
      Case #imgAlignLeft      : Refresh = Engine_SetAttribute(_Maker\DesignID, #Attribute_Alignment,  #Canvas_Align_Left)   
      Case #imgAlignCenter    : Refresh = Engine_SetAttribute(_Maker\DesignID, #Attribute_Alignment,  #Canvas_Align_Center)   
      Case #imgAlignRight     : Refresh = Engine_SetAttribute(_Maker\DesignID, #Attribute_Alignment,  #Canvas_Align_Right)  
      Case #imgTraverse       : Refresh = Engine_SetAttribute(_Maker\DesignID, #Attribute_Distribute, #Canvas_Evenly_Space)   
      Case #imgVertical       : Refresh = Engine_SetAttribute(_Maker\DesignID, #Attribute_Distribute, #Canvas_Evenly_Border)  
      ;========[工具]=======
      Case #imgScreenshot     : Maker_Screenshot() 
      ;========[视图]=======
      Case #imgLayerZoom200 : Refresh = Engine_SetAttribute(_Maker\DesignID, #Attribute_CanvasZoom, 2000) : _Maker\LayerZoom = 2.00  
      Case #imgLayerZoom150 : Refresh = Engine_SetAttribute(_Maker\DesignID, #Attribute_CanvasZoom, 1500) : _Maker\LayerZoom = 1.50     
      Case #imgLayerZoom100 : Refresh = Engine_SetAttribute(_Maker\DesignID, #Attribute_CanvasZoom, 1000) : _Maker\LayerZoom = 1.00     
      Case #imgLayerZoom075 : Refresh = Engine_SetAttribute(_Maker\DesignID, #Attribute_CanvasZoom, 0750) : _Maker\LayerZoom = 0.75        
      Case #imgLayerZoom050 : Refresh = Engine_SetAttribute(_Maker\DesignID, #Attribute_CanvasZoom, 0500) : _Maker\LayerZoom = 0.50     
      Case #imgLayerZoom025 : Refresh = Engine_SetAttribute(_Maker\DesignID, #Attribute_CanvasZoom, 0250) : _Maker\LayerZoom = 0.25    
   EndSelect
   
   Select MenuID
      Case #imgLayerZoom200,#imgLayerZoom150,#imgLayerZoom100,#imgLayerZoom075,#imgLayerZoom050,#imgLayerZoom025    
         SetMenuItemState(#wmbScreen, _Maker\MenuItemZoom, #False)
         _Maker\MenuItemZoom = MenuID 
         SetMenuItemState(#wmbScreen, _Maker\MenuItemZoom, #True)
   EndSelect
   
   If Refresh : Maker_RedrawScreen() : EndIf 
   
EndProcedure

Procedure Maker_EventGadget_cvsModule()
   Select EventType()
      Case #PB_EventType_LeftDoubleClick
         X = GetGadgetAttribute(#cvsModule, #PB_Canvas_MouseX)
         Y = GetGadgetAttribute(#cvsModule, #PB_Canvas_MouseY)
         ForEach _ListGroups()
            With _ListGroups()
               If \X <= X And X <= \R And \Y <= Y And Y <= \B
                  If \IsVisible = #False 
                     \IsVisible = #True
                     NeedRefresh = #True
                  EndIf 
               Else 
                  If \IsVisible = #True 
                     \IsVisible = #False
                     NeedRefresh = #True
                  EndIf   
               EndIf             
            EndWith
         Next 
      Case #PB_EventType_LeftButtonDown
         X = GetGadgetAttribute(#cvsModule, #PB_Canvas_MouseX)
         Y = GetGadgetAttribute(#cvsModule, #PB_Canvas_MouseY)
         ForEach _ListGroups()
            ForEach _ListGroups()\ListModule()
               With _ListGroups()\ListModule()
                  If \X <= X And X <= \R And \Y <= Y And Y <= \B
                     *pCurrModule = _ListGroups()\ListModule()
                  EndIf 
               EndWith
            Next 
         Next 
         If _Maker\pCurrModule <> *pCurrModule
            _Maker\pCurrModule = *pCurrModule
            If *pCurrModule
               Engine_SetAttribute(_Maker\DesignID, #Attribute_ActiveModule, #Object_Selected, _Maker\pCurrModule\ModuleID)
            EndIf 
            NeedRefresh = #True
         EndIf
      Case #PB_EventType_LeftButtonUp
      Case #PB_EventType_MouseMove 
   EndSelect
   If NeedRefresh : Maker_RedrawModule() : EndIf 
EndProcedure

Procedure Maker_EventGadget_cvsScreen()
   X = GetGadgetAttribute(#cvsScreen, #PB_Canvas_MouseX)-_Maker\OffsetX
   Y = GetGadgetAttribute(#cvsScreen, #PB_Canvas_MouseY)-_Maker\OffsetY 
   Modifiers = GetGadgetAttribute(#cvsScreen, #PB_Canvas_Modifiers) 
   
   Select EventType() 
      Case #PB_EventType_LeftButtonDown  : Refresh = Engine_EventCanvas(_Maker\DesignID, X, Y, #PB_EventType_LeftButtonDown,  Modifiers)
      Case #PB_EventType_LeftButtonUp    : Refresh = Engine_EventCanvas(_Maker\DesignID, X, Y, #PB_EventType_LeftButtonUp,    Modifiers)
                                           _Maker\pCurrModule = #Null : Maker_RedrawModule()
      Case #PB_EventType_LeftDoubleClick : Refresh = Engine_EventCanvas(_Maker\DesignID, X, Y, #PB_EventType_LeftDoubleClick)  
      Case #PB_EventType_MouseMove
         ButtonState = GetGadgetAttribute(#cvsScreen, #PB_Canvas_Buttons) 
         Refresh = Engine_EventCanvas(_Maker\DesignID, X, Y, #PB_EventType_MouseMove, ButtonState) 
         If Refresh
            ObjectID = Engine_GetAttribute(_Maker\DesignID, #Attribute_ActiveObject)
            If ObjectID
               X = Engine_GetAttribute(_Maker\DesignID, #Attribute_ObjectX, ObjectID)
               Y = Engine_GetAttribute(_Maker\DesignID, #Attribute_ObjectY, ObjectID)
               *pName = Engine_GetAttribute(_Maker\DesignID, #Attribute_ObjectName, ObjectID)
               If *pName
                  Name$ = PeekS(*pName)
                  StatusBarText(#wsbScreen, 1, "["+Name$+"] 坐标: "+Str(X) +","+ Str(Y)) 
               Else 
                  StatusBarText(#wsbScreen, 1, "坐标: "+Str(X) +","+ Str(Y)) 
               EndIf 
            EndIf 
         EndIf 
         
      Case #PB_EventType_RightButtonDown : Refresh = Engine_EventCanvas(_Maker\DesignID, X, Y, #PB_EventType_RightButtonDown, Modifiers)

         
      Case #PB_EventType_RightButtonUp   : Refresh = Engine_EventCanvas(_Maker\DesignID, X, Y, #PB_EventType_RightButtonUp,   Modifiers)
                                           _Maker\pCurrModule = #Null : Maker_RedrawModule()
      Case #PB_EventType_RightDoubleClick: Refresh = Engine_EventCanvas(_Maker\DesignID, X, Y, #PB_EventType_RightDoubleClick) 

      Case #PB_EventType_KeyDown : 
         Button = GetGadgetAttribute(#cvsScreen, #PB_Canvas_Key)
         Refresh = Engine_EventCanvas(_Maker\DesignID, #Null, #Null, #PB_EventType_KeyDown,   Button)                            
      Case #PB_EventType_KeyUp                                  
   EndSelect
;    Debug  
;    Debug GetGadgetAttribute(#cvsScreen, #PB_Canvas_Input)   
   If Refresh : Maker_RedrawScreen() : EndIf 
   
EndProcedure

;-
Procedure Maker_EventGadget_scbHorScroll()
   ScrollX = GetGadgetState(#scbHorScroll)
   Engine_SetAttribute(_Maker\DesignID, #Attribute_CanvasScrollX, ScrollX)
   Maker_RedrawScreen()
EndProcedure

Procedure Maker_EventGadget_scbVerScroll()
   ScrollY = GetGadgetState(#scbVerScroll)
   Engine_SetAttribute(_Maker\DesignID, #Attribute_CanvasScrollY, ScrollY)
   Maker_RedrawScreen()
EndProcedure

Procedure Maker_EventWindow_ReSizeWindow()
   _Maker\WindowW = WindowWidth(#winScreen)
   _Maker\WindowH = WindowHeight(#winScreen)
   GadgetX = _Maker\WindowW-018-05
   GadgetW = _Maker\WindowW-210-18-05
   GadgetY = _Maker\WindowH-MenuHeight()-StatusBarHeight(#wsbScreen)-18-05    
   GadgetH = _Maker\WindowH-MenuHeight()-StatusBarHeight(#wsbScreen)-35-18-05
   ResizeGadget(#scbHorScroll, 210, GadgetY, GadgetW, 18)
   ResizeGadget(#scbVerScroll, GadgetX, 035, 18, GadgetH)
   ResizeGadget(#cvsModule, 005, 035, 200, GadgetH+18)
   ResizeGadget(#cvsScreen, 210, 035, GadgetW, GadgetH)
   SetGadgetAttribute(#scbHorScroll, #PB_ScrollBar_Maximum, _Maker\CanvasW-GadgetW)
   SetGadgetAttribute(#scbVerScroll, #PB_ScrollBar_Maximum, _Maker\CanvasH-GadgetH)
   Maker_RedrawModule()
   Maker_RedrawScreen() 
EndProcedure
;-
;- [Initial]
Procedure Maker_Initial()
   LoadFont(#fntModule, "微软雅黑", 11)
   UsePNGImageDecoder()    
   ImageID = CatchImage(#PB_Any, ?_ICON_Resources)                       
   If ImageID
      For k = 0 To 12-1
         GrabImage(ImageID, #imgAlignTop+k, 24*k, 00, 24, 24)
      Next 
      For k = 0 To 12-1
         GrabImage(ImageID, #imgFileCreate+k, 24*k, 24, 24, 24)
      Next       
      For k = 0 To 8-1
         GrabImage(ImageID, #imgMatterCopy+k, 24*k, 48, 24, 24)
      Next       
      FreeImage(ImageID)
   EndIf 
EndProcedure



Procedure Maker_CreateMenuBar(hWindow)
   If CreateMenu(#wmbScreen, hWindow)
      MenuTitle("文件(&F)") 
         MenuItem(#imgFileCreate, "新建设计文档")  
         MenuItem(#imgFileOpen,   "打开设计文档")  
         MenuBar()
         MenuItem(#imgFileSave,   "保存设计文档")  
         MenuItem(#imgFileSaveAs, "设计文档另存为")
         MenuBar()
         MenuItem(#imgFileClose,  "关闭设计文档")
         MenuTitle("编辑(&E)")
         MenuItem(#imgAddString, "插入文本签标")   
         MenuBar()         
         MenuItem(#imgObjectFree, "删除对象")  
         MenuItem(#imgDupontDel,  "删除杜邦线") 
         MenuBar()
         MenuItem(#imgDupontMod, "修改杜邦线") 
         MenuBar()
         MenuItem(#imgCreateGroups, "合并组") 
         MenuItem(#imgCancelGroups, "拆散组") 
  
      MenuTitle("图层(&L)")         
         MenuItem(#imgFloorTop,     "对象置顶") 
         MenuItem(#imgFloorBottom,  "对象置底") 
         MenuItem(#imgFloorPrev,    "上移一层") 
         MenuItem(#imgFloorNext,    "下移一层")   
         MenuBar()
         MenuItem(#imgLeftTurn090,  "向左旋转90度") 
         MenuItem(#imgRightTurn090, "向右旋转90度")   
         MenuBar()
         MenuItem(#imgHorizFlip180, "翻转对像") 

      MenuTitle("对齐(&A)")   
         MenuItem(#imgAlignTop,     "上对齐") 
         MenuItem(#imgAlignMiddle,  "居中对齐") 
         MenuItem(#imgAlignBottom,  "下对齐") 
         MenuBar()
         MenuItem(#imgAlignLeft,    "左对齐") 
         MenuItem(#imgAlignCenter,  "中心对齐") 
         MenuItem(#imgAlignRight,   "右对齐") 
         MenuBar()
         MenuItem(#imgTraverse,     "水平间隔分布") 
         MenuItem(#imgVertical,     "垂直间隔分布") 

      MenuTitle("工具(&T)")
         MenuItem(#imgScreenshot,   "截图") 
      
         MenuTitle("视图(&V)")
         
         MenuItem(#imgLayerZoom200, "视图:200%")    
         MenuItem(#imgLayerZoom150, "视图:150%")    
         MenuItem(#imgLayerZoom100, "视图:100%")    
         MenuItem(#imgLayerZoom075, "视图: 75%") 
         MenuItem(#imgLayerZoom050, "视图: 50%")          
;          MenuItem(#imgLayerZoom025, "视图: 25%")            
   EndIf    
   _Maker\MenuItemZoom = #imgLayerZoom100
   SetMenuItemState(#wmbScreen, #imgLayerZoom100, #True)
EndProcedure

Procedure Maker_CreateToolBar(hWindow)
   hToolBar = CreateToolBar(#wtbScreen, hWindow)
   If hToolBar
      ImageList = SendMessage_(hToolBar, #TB_GETIMAGELIST, 0, 0)
      ImageList_SetIconSize_(ImageList, 24, 24)
      ToolBarImageButton(#imgFileCreate,    ImageID(#imgFileCreate)) 
      ToolBarImageButton(#imgFileOpen,      ImageID(#imgFileOpen))
      ToolBarImageButton(#imgFileSave,      ImageID(#imgFileSave))
      ToolBarImageButton(#imgFileClose,     ImageID(#imgFileClose))
      ToolBarSeparator()    
      ToolBarImageButton(#imgObjectFree,    ImageID(#imgObjectFree))
      ToolBarSeparator()   
      ToolBarImageButton(#imgCreateGroups,  ImageID(#imgCreateGroups))
      ToolBarImageButton(#imgCancelGroups,  ImageID(#imgCancelGroups))       
      ToolBarSeparator()      
      ToolBarImageButton(#imgScreenshot,    ImageID(#imgScreenshot))      
      ToolBarSeparator()      
      ToolBarImageButton(#imgFloorTop,      ImageID(#imgFloorTop))
      ToolBarImageButton(#imgFloorPrev,     ImageID(#imgFloorPrev))    
      ToolBarImageButton(#imgFloorNext,     ImageID(#imgFloorNext))    
      ToolBarImageButton(#imgFloorBottom,   ImageID(#imgFloorBottom))    
      ToolBarSeparator()      
      ToolBarImageButton(#imgAlignTop,      ImageID(#imgAlignTop))
      ToolBarImageButton(#imgAlignMiddle,   ImageID(#imgAlignMiddle))
      ToolBarImageButton(#imgAlignBottom,   ImageID(#imgAlignBottom))
      ToolBarSeparator()
      ToolBarImageButton(#imgAlignLeft,     ImageID(#imgAlignLeft))
      ToolBarImageButton(#imgAlignCenter,   ImageID(#imgAlignCenter))
      ToolBarImageButton(#imgAlignRight,    ImageID(#imgAlignRight))
      ToolBarSeparator()
      ToolBarImageButton(#imgTraverse,      ImageID(#imgTraverse))
      ToolBarImageButton(#imgVertical,      ImageID(#imgVertical))       

      ToolBarSeparator()
      ToolBarImageButton(#imgLeftTurn090,   ImageID(#imgLeftTurn090))
      ToolBarImageButton(#imgRightTurn090,  ImageID(#imgRightTurn090)) 
      ToolBarSeparator()
      ToolBarImageButton(#imgHorizFlip180,  ImageID(#imgHorizFlip180))       
       
      ToolBarToolTip(#wtbScreen, #imgFileCreate,   "新建设计文档") 
      ToolBarToolTip(#wtbScreen, #imgFileOpen,     "打开设计文档") 
      ToolBarToolTip(#wtbScreen, #imgFileSave,     "保存设计文档") 
      ToolBarToolTip(#wtbScreen, #imgFileClose,    "关闭设计文档") 
      ToolBarToolTip(#wtbScreen, #imgObjectFree,   "删除对象") 
      
      ToolBarToolTip(#wtbScreen, #imgFloorTop,     "对象置顶") 
      ToolBarToolTip(#wtbScreen, #imgFloorBottom,  "对象置底") 
      ToolBarToolTip(#wtbScreen, #imgFloorPrev,    "上移一层") 
      ToolBarToolTip(#wtbScreen, #imgFloorNext,    "下移一层")       
      ToolBarToolTip(#wtbScreen, #imgScreenshot,   "截图")       
      
      ToolBarToolTip(#wtbScreen, #imgAlignTop,     "上对齐") 
      ToolBarToolTip(#wtbScreen, #imgAlignMiddle,  "居中对齐") 
      ToolBarToolTip(#wtbScreen, #imgAlignBottom,  "下对齐") 
      
      ToolBarToolTip(#wtbScreen, #imgAlignTop,     "左对齐") 
      ToolBarToolTip(#wtbScreen, #imgAlignMiddle,  "中心对齐") 
      ToolBarToolTip(#wtbScreen, #imgAlignBottom,  "右对齐") 
      
      ToolBarToolTip(#wtbScreen, #imgLeftTurn090,  "向左旋转90度") 
      ToolBarToolTip(#wtbScreen, #imgRightTurn090, "向右旋转90度") 
      ToolBarToolTip(#wtbScreen, #imgHorizFlip180, "翻转对像") 
      
      ToolBarToolTip(#wtbScreen, #imgTraverse,     "水平间隔分布") 
      ToolBarToolTip(#wtbScreen, #imgVertical,     "垂直间隔分布") 
      
      ToolBarToolTip(#wtbScreen, #imgCreateGroups, "合并组") 
      ToolBarToolTip(#wtbScreen, #imgCancelGroups, "拆散组")       

   EndIf 
EndProcedure

Procedure Maker_CreateStatusBar(hWindow)
   If CreateStatusBar(#wsbScreen, hWindow)
      AddStatusBarField(100)
      AddStatusBarField(150)
      AddStatusBarField(130)
      StatusBarText(#wsbScreen,  0, "- 有思鹿 -", #PB_StatusBar_Center)
      StatusBarText(#wsbScreen,  1, "")
      StatusBarText(#wsbScreen,  2, "提示功能")
   EndIf
EndProcedure

Procedure Maker_CreateGadget(hWindow)
   GadgetX = _Maker\WindowW-18-5
   GadgetW = _Maker\WindowW-210-18-5
   GadgetY = _Maker\WindowH-MenuHeight()-StatusBarHeight(#wsbScreen)-18-5    
   GadgetH = _Maker\WindowH-MenuHeight()-StatusBarHeight(#wsbScreen)-35-18-5
   ScrollBarGadget(#scbHorScroll, 210, GadgetY, GadgetW, 18, 0, _Maker\CanvasW-GadgetW, 10)
   ScrollBarGadget(#scbVerScroll, GadgetX, 035, 18, GadgetH, 0, _Maker\CanvasH-GadgetH, 10, #PB_ScrollBar_Vertical)
   CanvasGadget(#cvsModule, 005, 035, 200,     GadgetH+18,  #PB_Canvas_Keyboard)
   CanvasGadget(#cvsScreen, 210, 035, GadgetW, GadgetH,  #PB_Canvas_Keyboard)
EndProcedure


;-
;- ######## [Main] ######## 
With _Maker
   Maker_Initial()
   If Maker_InitialEngine() : End : EndIf 

   \CanvasW = 1280
   \CanvasH = 960
   \WindowW = 1100
   \WindowH = 750
   \LayerZoom = 1.00
   WindowFlags = #PB_Window_SystemMenu|#PB_Window_MaximizeGadget|#PB_Window_MinimizeGadget|#PB_Window_SizeGadget
   hWindow = OpenWindow(#winScreen, 0, 0, \WindowW, \WindowH, "单片机仿真模拟器", WindowFlags|#PB_Window_ScreenCentered)
   Maker_CreateMenuBar(hWindow)
   Maker_CreateToolBar(hWindow)
   Maker_CreateStatusBar(hWindow)
   Maker_CreateGadget(hWindow)
   Maker_RedrawModule()

   Maker_RegisterEngine()
;    \DesignID = Engine_CreateDesign(\EngineID, \CanvasW, \CanvasH)
   \DesignID = Engine_CreateDesign(\EngineID)
   Maker_RedrawScreen()
   BindGadgetEvent(#cvsScreen,      @Maker_EventGadget_cvsScreen())
   BindGadgetEvent(#cvsModule,      @Maker_EventGadget_cvsModule())
   BindGadgetEvent(#scbHorScroll,   @Maker_EventGadget_scbHorScroll())
   BindGadgetEvent(#scbVerScroll,   @Maker_EventGadget_scbVerScroll())
   BindEvent(#PB_Event_SizeWindow,  @Maker_EventWindow_ReSizeWindow())
   Repeat
      WinEvent = WindowEvent()
      Select WinEvent 
         Case #PB_Event_CloseWindow : \IsExitWindow = #True
         Case #PB_Event_Menu  : Maker_EventWindow_EventMenu()
      EndSelect
   Until \IsExitWindow = #True
   Maker_ReleaseEngine()
EndWith
End

;-
;- ******** [Data] ******** 
DataSection
_ICON_Resources:
   IncludeBinary ".\Resources\ICON.png" 
EndDataSection


; IDE Options = PureBasic 5.62 (Windows - x86)
; CursorPosition = 664
; FirstLine = 502
; Folding = p--0
; EnableXP
; Executable = DEMO.exe