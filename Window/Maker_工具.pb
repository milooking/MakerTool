;*****************************************
;******** 单片机仿真模拟器窗体界面 ********
;********    迷路仟 2020.02.24    ********
;*****************************************
;【Maker_Import.pbi】     ;引擎接口源代码
;【Maker_Define.pbi】     ;定义类源代码
;【Maker_Balloon.pbi】    ;控件提示文源代码
;【Maker_Message.pbi】    ;信息对话框源代码
;【Maker_MenuBar.pbi】    ;弹出菜单源代码
;【Maker_Caption.pbi】    ;标题栏源代码
;【Maker_ToolBar.pbi】    ;左侧工具栏源代码
;【Maker_Navigate.pbi】   ;导航条源代码
;【Maker_Discolor.pbi】   ;颜色修改对话框源代码
;【Maker_Editor.pbi】     ;对象修改对话框源代码
;【Maker_Dialog.pbi】     ;文件保存打开对话框源代码
;【Maker_Progress.pbi】   ;事件进度对话框源代码
;【Maker_PopupBar.pbi】   ;右键弹出工具栏源代码
;【Maker_Screen.pbi】     ;窗体界面布局源代码

;-[Compiler]
; #DLLTest = #True  ;采用DLL
#DLLTest = #False

CompilerIf #DLLTest = #True
   IncludeFile "Maker_Import.pb"
CompilerElse 
   IncludeFile "..\Maker_Engine.pb"
CompilerEndIf 

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
XIncludeFile ".\Maker_Screen.pbi"      ;窗体界面布局源代码

   
Structure __Maker_MainInfo
   hWindow.l
   ;========
   EngineID.l
   DesignID.l
   ModuleID.l
   ;========
   *pColors.__ColorInfo
   *pWindow.__WindowInfo
   *pEvents.__EventInfo
   ;=========
   CanvasH.w
   CanvasW.w
   ;========
   FileName$
   ;========
   *pCurrModule.__Maker_ModuleInfo 
   *pCurrDesign.__Caption_DesignInfo
   ;========
   IsRefresh.b
   IsRegister.b
   IsExitWindow.b
EndStructure



Global _Maker.__Maker_MainInfo


Declare Maker_Event_CloseWindow()


;-
;- ******** [CallBack] ******** 
Procedure Maker_CallBack_Register(Index, Count, Note$)
   If Index >= Count
      Progress_SetInfo("解压完毕", 1000, #True)
   Else
      Progress  = Index * 500 / Count
      Progress$ = Note$ + ":" + Str(Progress/10)+"% "
      Progress_SetInfo(Progress$, Progress, #False)   ;最大值1000
   EndIf
EndProcedure


Procedure Maker_CallBack_AddString(*pObject.__Maker_ObjectInfo, IsModify=#False)
   Result = Editor_Requester(_Maker\hWindow, *pObject, IsModify)
   ProcedureReturn Result
EndProcedure

Procedure Maker_CallBack_RightClick(DesignID, ObjectType, ObjectID)
   Select ObjectType
      Case #Object_Matter : PopupBar_Active(#Object_Matter)
      Case #Object_String : PopupBar_Active(#Object_String)
      Case #Object_Groups : PopupBar_Active(#Object_Groups)
      Case #Object_Active : PopupBar_Active(#Object_Active) 
      Default : ProcedureReturn 
   EndSelect
   _Maker\IsRefresh = #True
   Debug "ObjectType = " + Str(ObjectType) + " : 0x"+Hex(ObjectID, #PB_Long)
   ProcedureReturn Result
EndProcedure



;-
Procedure Maker_Call_CreateDesign(*pListDesign.__Caption_DesignInfo)
   With _Maker
      *pListDesign\DesignID = Engine_CreateDesign(\EngineID)
      Engine_SetAttribute(*pListDesign\DesignID, #Attribute_CanvasScrollX, 60) 
      Engine_SetAttribute(*pListDesign\DesignID, #Attribute_CanvasScrollY, 45) 
      _Maker\pCurrDesign = *pListDesign
   EndWith
   ProcedureReturn *pListDesign\DesignID
EndProcedure

;打开设计文档
Procedure Maker_Call_OpenDesign(*pListDesign.__Caption_DesignInfo)   
   If _Maker\IsRegister  = #Null : ProcedureReturn : EndIf 
   If *pListDesign = #Null : ProcedureReturn : EndIf 
;    Pattern$ = "设计文档(*.mct)|*.mct"
;    Pattern = 0    ; 默认选择第一个
   With *pListDesign
      ;       FileName$ = OpenFileRequester("请选择要打开的文件", \FileName$, Pattern$, Pattern)
      FileName$ = \FileName$
      If FileName$ = #Null$ : FileName$ = GetCurrentDirectory() : EndIf
      FileName$ = Dialog_OpenFile(_Maker\hWindow, FileName$, #True)
      If FileName$
         \FileName$ = FileName$
         \Title$    = GetFilePart(FileName$)
         \DesignID  = Engine_LoadDesign(_Maker\EngineID, FileName$)
         If \DesignID 
            \CanvasW   = Engine_GetAttribute(\DesignID, #Attribute_CanvasWidth) 
            \CanvasH   = Engine_GetAttribute(\DesignID, #Attribute_CanvasHeight) 
            Engine_SetAttribute(\DesignID, #Attribute_CanvasScrollX, 60) 
            Engine_SetAttribute(\DesignID, #Attribute_CanvasScrollY, 45) 
            \LayerZoom = Engine_GetAttribute(\DesignID, #Attribute_CanvasZoom) /1000
         EndIf 
         ProcedureReturn #True
      EndIf
   EndWith
   ProcedureReturn #False
EndProcedure

Procedure Maker_Call_LoadDesign(*pListDesign.__Caption_DesignInfo)   
   If _Maker\IsRegister  = #Null : ProcedureReturn : EndIf 
   If _Maker\pCurrDesign = #Null : ProcedureReturn : EndIf 
   With *pListDesign 
      \Title$    = GetFilePart(\FileName$)
      \DesignID  = Engine_LoadDesign(_Maker\EngineID, \FileName$)
      If \DesignID 
         \CanvasW   = Engine_GetAttribute(\DesignID, #Attribute_CanvasWidth) 
         \CanvasH   = Engine_GetAttribute(\DesignID, #Attribute_CanvasHeight) 
         Engine_SetAttribute(\DesignID, #Attribute_CanvasScrollX, 60) 
         Engine_SetAttribute(\DesignID, #Attribute_CanvasScrollY, 45) 
         \LayerZoom = Engine_GetAttribute(\DesignID, #Attribute_CanvasZoom) /1000
      EndIf 
   EndWith
   ProcedureReturn #True
EndProcedure

;打开设计文档
Procedure Maker_Call_SaveDesign(*pListDesign.__Caption_DesignInfo, IsSaveAs=#False)   
   If _Maker\IsRegister  = #Null : ProcedureReturn : EndIf 
   If _Maker\pCurrDesign = #Null : ProcedureReturn : EndIf 
   With *pListDesign 
      If \FileName$ = #Null$ Or IsSaveAs = #True
         FileName$ = \Title$
;          Pattern$ = "设计文档 (*.mct)|*.mct"
;          FileName$ = SaveFileRequester("请选择要保存的文件", FileName$, Pattern$, 0)
         If GetPathPart(FileName$) = #Null$ : FileName$ = GetCurrentDirectory()+FileName$ : EndIf
         FileName$ = Dialog_SaveFile(_Maker\hWindow, FileName$, #True)
         If FileName$
            If LCase(GetExtensionPart(FileName$)) <> "mct" ;判断后辍是不是mct
               FileName$+".mct"
            EndIf 
            \FileName$ = FileName$
         Else 
            ProcedureReturn 
         EndIf 
      EndIf 
      Result = Engine_SaveDesign(\DesignID, \FileName$)
      If Result
         \Title$ = GetFilePart(\FileName$)
         Message_Requester(_Maker\hWindow, "迷路提示", "["+GetFilePart(\FileName$)+"]保存成功!", #PB_MessageRequester_Ok, #True)
         ProcedureReturn #True
      Else
         Message_Requester(_Maker\hWindow, "迷路提示", "["+GetFilePart(\FileName$)+"]保存失败!", #PB_MessageRequester_Ok, #True)
      EndIf 
   EndWith
   ProcedureReturn #False
EndProcedure

Procedure Maker_Call_CloseDesign(*pListDesign.__Caption_DesignInfo)
   Engine_FreeDesign(*pListDesign\DesignID) 
EndProcedure

;导出画布图像
Procedure Maker_Call_ExportImage(*pListDesign.__Caption_DesignInfo)  
   If *pListDesign = #Null : ProcedureReturn : EndIf
   Pattern$ = "PNG图像(*.png)|*.png"
   Pattern = 0    ; 默认选择第一个
   
   FileName$ = ReplaceString(*pListDesign\FileName$, ".mct", ".png")
   FileName$ = SaveFileRequester("请选择要导出的图像", FileName$, Pattern$, Pattern)
   If FileName$
      If LCase(GetExtensionPart(FileName$)) <> "png"
         FileName$+".png"
      EndIf 
      Result = Engine_Screenshot(*pListDesign\DesignID, FileName$)
      If Result
         Message_Requester(_Maker\hWindow, "迷路提示", "["+GetFilePart(FileName$)+"]导出图像成功!", #PB_MessageRequester_Ok, #True)
         ProcedureReturn #True
      EndIf 
   EndIf
EndProcedure

Procedure Maker_Call_SelectDesign(*pListDesign.__Caption_DesignInfo)
   _Maker\pCurrDesign = *pListDesign
   _Maker\pWindow\LayerZoom   = *pListDesign\LayerZoom
   _Maker\pWindow\pCurrDesign = *pListDesign
   Screen_RedrawScreen(#True)
EndProcedure

Procedure Maker_Call_SelectMatter(*pModuleType.__Maker_ModuleType)
   If *pModuleType And _Maker\pCurrDesign
      Engine_SetAttribute(_Maker\pCurrDesign\DesignID, #Attribute_ActiveModule, #Null, *pModuleType\ModuleID)
   EndIf 
EndProcedure

Procedure Maker_Call_RedrawCanvas(*pMainScreen.__Screen_MainInfo)
   If _Maker\pCurrDesign
      With _Maker\pCurrDesign
         hCanvas  = Engine_RedrawCanvas(\DesignID, *pMainScreen\WindowW, *pMainScreen\WindowH) 
      EndWith
   EndIf 
   ProcedureReturn hCanvas
EndProcedure

Procedure Maker_Call_GetThumbnail(FileName$)
   Debug "FileName$ = " + FileName$
   hThumbnail = Engine_Thumbnail(_Maker\EngineID, FileName$)
   ProcedureReturn hThumbnail
EndProcedure




;-
;- ******** [Engine] ******** 
Procedure Maker_InitialEngine()
   _Maker\EngineID = Engine_Initial(@IsRegister.long)
   If _Maker\EngineID = #Null
      ProcedureReturn #True
   EndIf 
   _Maker\IsRegister = IsRegister\l
   _Maker\CanvasW    = 1080
   _Maker\CanvasH    = 0720
   
   ModuleGroup$ = #Null$
   Count = Engine_CountModule(_Maker\EngineID)
   ListModule.__Maker_ModuleType
   
   For Index = 0 To Count-1
      Engine_GetModule(_Maker\EngineID, Index, @ListModule)
      ModuleTypes$ = PeekS(ListModule\pModuleTypes)  ;模块类型
      _MapModule(ModuleTypes$)
      *pModule.__ModuleInfo = _MapModule()
      *pModule\ModuleGroup$ = PeekS(ListModule\pModuleGroup)  ;模块编组
      *pModule\ModuleTypes$ = PeekS(ListModule\pModuleTypes)  ;模块类型
      *pModule\ModuleModel$ = PeekS(ListModule\pModuleModel)  ;模块型号
      *pModule\ModuleName$  = PeekS(ListModule\pModuleName)   ;模块名称
      *pModule\ModuleNote$  = PeekS(ListModule\pModuleNote)   ;模块说明
      *pModule\hModuleIcon  = ListModule\hModuleIcon   ;模块图标ID
      *pModule\ModuleID     = ListModule\ModuleID      ;模块图标ID
   Next 
   ProcedureReturn #False
EndProcedure


Procedure Maker_RegisterEngine()
   If _Maker\IsRegister = #Null
      Progress_Requester(_Maker\hWindow, "解压资源文件(仅这一次)", #True)
      Engine_SetCallBack(_Maker\EngineID, #CallBack_Register, @Maker_CallBack_Register())
   EndIf 
   Engine_SetCallBack(_Maker\EngineID, #CallBack_AddString,  @Maker_CallBack_AddString())
   Engine_SetCallBack(_Maker\EngineID, #CallBack_RightClick, @Maker_CallBack_RightClick())

EndProcedure

Procedure Maker_CreateDesign(*pCurrDesign.__Caption_DesignInfo)
   With *pCurrDesign
      \LayerZoom = 1.0
      \DesignID  = Engine_CreateDesign(_Maker\EngineID)
   EndWith
EndProcedure

Procedure Maker_ReleaseEngine()
   Engine_Release(_Maker\EngineID)
EndProcedure

;-
;- ******** [EventGadget] ******** 
Procedure Maker_EventGadget_winScreen()
   
   If _Caption\pCurrDesign = #Null : ProcedureReturn : EndIf 
   EventType = EventType()
   *pMouse.__EventDataInfo = EventData()
   X = *pMouse\MouseX - _Screen\OffsetX
   Y = *pMouse\MouseY - _Screen\OffsetY
   Button = *pMouse\Button
   DesignID = _Caption\pCurrDesign\DesignID
   If DesignID = #Null : ProcedureReturn : EndIf 
   Select EventType() 
      Case #PB_EventType_LeftButtonDown  
         Refresh = Engine_EventCanvas(DesignID, X, Y, #PB_EventType_LeftButtonDown,  Button)
         
      Case #PB_EventType_LeftButtonUp    
         Refresh = Engine_EventCanvas(DesignID, X, Y, #PB_EventType_LeftButtonUp,    Button)

      Case #PB_EventType_LeftDoubleClick
         Refresh = Engine_EventCanvas(DesignID, X, Y, #PB_EventType_LeftDoubleClick)
         
      Case #PB_EventType_MouseMove
         Refresh = Engine_EventCanvas(DesignID, X, Y, #PB_EventType_MouseMove, Button) 

      Case #PB_EventType_RightButtonDown 
         Refresh = Engine_EventCanvas(DesignID, X, Y, #PB_EventType_RightButtonDown, Button)
         
      Case #PB_EventType_RightButtonUp 
         Refresh = Engine_EventCanvas(DesignID, X, Y, #PB_EventType_RightButtonUp,   Button)

      Case #PB_EventType_RightDoubleClick
         Refresh = Engine_EventCanvas(DesignID, X, Y, #PB_EventType_RightDoubleClick) 

      Case #PB_EventType_KeyDown 

         Refresh = Engine_EventCanvas(DesignID, #Null, #Null, #PB_EventType_KeyDown, Button) 
         
      Case #PB_EventType_KeyUp  
         
   EndSelect
   If Refresh 
      Screen_RedrawScreen(#True)
   EndIf 
   
EndProcedure

;软件标志和名字
Procedure Maker_EventGadget_wmiSoftware()
   MenuBar_Active(_Maker\hWindow,  #MenuBarID_File)
   Screen_RedrawScreen(#False)
EndProcedure

Procedure Maker_EventGadget_wmiSettings()
   MenuBar_Active(_Maker\hWindow,  #MenuBarID_View)
   Screen_RedrawScreen(#False)
EndProcedure

;创建设计文档
Procedure Maker_EventGadget_wmiCreateDesign()
   Caption_CreateDesign() 
   Screen_RedrawScreen(#True)
EndProcedure

;保存设计文档
Procedure Maker_EventGadget_wmiOpenDesign()
   *pListDesign = Caption_OpenDesign() 
   If *pListDesign
      _Maker\pCurrDesign = *pListDesign
   EndIf 
   Screen_RedrawScreen(#True)
EndProcedure

;保存设计文档
Procedure Maker_EventGadget_wmiSaveDesign()
   Caption_SaveDesign() 
   Screen_RedrawScreen(#True)
EndProcedure

 ;设计文档另存为
Procedure Maker_EventGadget_wmiSaveAsDesign() 
   Caption_SaveDesign(#True) 
   Screen_RedrawScreen(#True)
EndProcedure

 ;设计文档另存为
Procedure Maker_EventGadget_wmiSaveAllDesign() 
   Caption_SaveAllDesign() 
   Screen_RedrawScreen(#True)
EndProcedure

;关闭设计文档
Procedure Maker_EventGadget_wmiCloseDesign()
   Caption_CloseDesign() 
   Screen_RedrawScreen(#True)
EndProcedure

;关闭全部设计文档
Procedure Maker_EventGadget_wmiCloseAllDesign()
   Caption_CloseAllDesign() 
   Screen_RedrawScreen(#True)
EndProcedure

;导出画布图像
Procedure Maker_EventGadget_wmiExportImage()  
   If _Maker\pCurrDesign = #Null : ProcedureReturn : EndIf
   Caption_ExportImage()
EndProcedure

;重新设计画布尺寸
Procedure Maker_EventGadget_wmiResizeCanvas()  
;    If _Maker\pCurrDesign = #Null : ProcedureReturn : EndIf
;    Dialog_OpenFile(_Maker\hWindow, "F:\桌面\新建文档.mct", #True)
;    Screen_RedrawScreen(#True)
EndProcedure


Procedure Maker_EventGadget_wmiDisplayGrid()
   _Maker\pWindow\IsDisplayGrid = 1-_Maker\pWindow\IsDisplayGrid
   MenuBar_SetItemState(#MenuBarID_View, #wmiDisplayGrid, _Maker\pWindow\IsDisplayGrid)
   Engine_SetAttribute(_Maker\pCurrDesign\DesignID, #Attribute_DisplayGrid, _Maker\pWindow\IsDisplayGrid)
   Screen_RedrawScreen(#True)
EndProcedure

;-
;向上滚动画布
Procedure Maker_EventGadget_btnScrollUp()
   If _Maker\pCurrDesign = #Null : ProcedureReturn : EndIf 
   Engine_SetAttribute(_Maker\pCurrDesign\DesignID, #Attribute_CanvasScrollY, #Object_Event_Align, #True) 
   Screen_RedrawScreen(#True)
EndProcedure

;向下滚动画布
Procedure Maker_EventGadget_btnScrollDown()
   If _Maker\pCurrDesign = #Null : ProcedureReturn : EndIf 
   Engine_SetAttribute(_Maker\pCurrDesign\DesignID, #Attribute_CanvasScrollY, -#Object_Event_Align, #True) 
   Screen_RedrawScreen(#True)  
EndProcedure

;向左滚动画布
Procedure Maker_EventGadget_btnScrollLeft()
   If _Maker\pCurrDesign = #Null : ProcedureReturn : EndIf 
   Engine_SetAttribute(_Maker\pCurrDesign\DesignID, #Attribute_CanvasScrollX, #Object_Event_Align, #True) 
   Screen_RedrawScreen(#True)  
EndProcedure

;向右滚动画布
Procedure Maker_EventGadget_btnScrollRight()
   If _Maker\pCurrDesign = #Null : ProcedureReturn : EndIf 
   Engine_SetAttribute(_Maker\pCurrDesign\DesignID, #Attribute_CanvasScrollX, -#Object_Event_Align, #True) 
   Screen_RedrawScreen(#True)  
EndProcedure

;画布滚动至主页
Procedure Maker_EventGadget_btnScrollHome()
   If _Maker\pCurrDesign = #Null : ProcedureReturn : EndIf 
   Engine_SetAttribute(_Maker\pCurrDesign\DesignID, #Attribute_CanvasScrollX, 60) 
   Engine_SetAttribute(_Maker\pCurrDesign\DesignID, #Attribute_CanvasScrollY, 45) 
   Screen_RedrawScreen(#True)  
EndProcedure

;扩大画布比例
Procedure Maker_EventGadget_btnScaleUp()
   If _Maker\pCurrDesign = #Null : ProcedureReturn : EndIf 
   LayerZoom = _Maker\pCurrDesign\LayerZoom * 1000
   Select LayerZoom
      Case 1750 : LayerZoom = 2000
      Case 1500 : LayerZoom = 1750
      Case 1250 : LayerZoom = 1500
      Case 1000 : LayerZoom = 1250
      Case 0800 : LayerZoom = 1000
      Case 0600 : LayerZoom = 0800
      Case 0500 : LayerZoom = 0600
      Case 0400 : LayerZoom = 0500
      Case 0300 : LayerZoom = 0400
      Case 0250 : LayerZoom = 0300
      Case 0200 : LayerZoom = 0250
      Case 0150 : LayerZoom = 0200   
      Case 0100 : LayerZoom = 0200   
   EndSelect
   _Maker\pCurrDesign\LayerZoom = LayerZoom/1000
   _Maker\pWindow\LayerZoom     = LayerZoom/1000
   Engine_SetAttribute(_Maker\pCurrDesign\DesignID, #Attribute_CanvasZoom, LayerZoom)
   Screen_RedrawScreen(#True)
EndProcedure

;缩小画布比例 
Procedure Maker_EventGadget_btnScaleDown()
   If _Maker\pCurrDesign = #Null : ProcedureReturn : EndIf 
   LayerZoom = _Maker\pCurrDesign\LayerZoom * 1000
   Select LayerZoom
      Case 2000 : LayerZoom = 1750
      Case 1750 : LayerZoom = 1500
      Case 1500 : LayerZoom = 1250
      Case 1250 : LayerZoom = 1000
      Case 1000 : LayerZoom = 0800
      Case 0800 : LayerZoom = 0600
      Case 0600 : LayerZoom = 0500
      Case 0500 : LayerZoom = 0400
      Case 0400 : LayerZoom = 0300
      Case 0300 : LayerZoom = 0250
      Case 0250 : LayerZoom = 0200
      Case 0200 : LayerZoom = 0150
      Case 0150 : LayerZoom = 0100  
   EndSelect
   _Maker\pCurrDesign\LayerZoom = LayerZoom/1000
   _Maker\pWindow\LayerZoom     = LayerZoom/1000
   Engine_SetAttribute(_Maker\pCurrDesign\DesignID, #Attribute_CanvasZoom, LayerZoom)
   Screen_RedrawScreen(#True)
EndProcedure
     
;-
;添加标签
Procedure Maker_EventGadget_wmiCreateString()  
;    _Maker\pWindow\IsCreateString = #True
EndProcedure

;删除对象
Procedure Maker_EventGadget_wmiDeleteObject()  
   If _Maker\pCurrDesign = #Null : ProcedureReturn : EndIf 
   Engine_SetAttribute(_Maker\pCurrDesign\DesignID, #Attribute_ObjectDelete, #Null)
   Screen_RedrawScreen(#True)
EndProcedure

;组合[活动组]
Procedure Maker_EventGadget_wmiMergerGroups()  
   If _Maker\pCurrDesign = #Null : ProcedureReturn : EndIf 
   Engine_SetAttribute(_Maker\pCurrDesign\DesignID, #Attribute_ActiveGroups, #Object_Group_Merger)
   Screen_RedrawScreen(#True)
EndProcedure

;拆分[选中组]
Procedure Maker_EventGadget_wmiDivideGroups()  
   If _Maker\pCurrDesign = #Null : ProcedureReturn : EndIf 
   Engine_SetAttribute(_Maker\pCurrDesign\DesignID, #Attribute_ActiveGroups, #Object_Group_Divide)
   Screen_RedrawScreen(#True)
EndProcedure

;[杜邦线]修改颜色
Procedure Maker_EventGadget_wmiDupontsColor()  
   If _Maker\pCurrDesign = #Null : ProcedureReturn : EndIf 
   Color = Engine_GetAttribute(_Maker\pCurrDesign\DesignID, #Attribute_DupontColor)
   If Color = -1 : ProcedureReturn : EndIf 
   Color = Discolor_Requester(_Maker\hWindow, Color, "杜邦线")
   If Color = -1 : ProcedureReturn : EndIf 
   Result = Engine_SetAttribute(_Maker\pCurrDesign\DesignID, #Attribute_DupontColor, Color)
   If Result : Screen_RedrawScreen(#True) : EndIf 
EndProcedure

;-
;置于顶层 
Procedure Maker_EventGadget_wmiLayerTop()
   If _Maker\pCurrDesign = #Null : ProcedureReturn : EndIf 
   Engine_SetAttribute(_Maker\pCurrDesign\DesignID, #Attribute_ObjectLayer, #Object_Layer_Top)
   Screen_RedrawScreen(#True)
EndProcedure

;置于底层
Procedure Maker_EventGadget_wmiLayerBottom()
   If _Maker\pCurrDesign = #Null : ProcedureReturn : EndIf 
   Engine_SetAttribute(_Maker\pCurrDesign\DesignID, #Attribute_ObjectLayer, #Object_Layer_Bottom)
   Screen_RedrawScreen(#True)
EndProcedure

;上移一层 
Procedure Maker_EventGadget_wmiLayerPrev()
   If _Maker\pCurrDesign = #Null : ProcedureReturn : EndIf 
   Engine_SetAttribute(_Maker\pCurrDesign\DesignID, #Attribute_ObjectLayer, #Object_Layer_Prev)
   Screen_RedrawScreen(#True)
EndProcedure

;下移一层
Procedure Maker_EventGadget_wmiLayerNext()
   If _Maker\pCurrDesign = #Null : ProcedureReturn : EndIf 
   Engine_SetAttribute(_Maker\pCurrDesign\DesignID, #Attribute_ObjectLayer, #Object_Layer_Next)
   Screen_RedrawScreen(#True)
EndProcedure

;左转90度
Procedure Maker_EventGadget_wmiRotateTurnL90() 
   If _Maker\pCurrDesign = #Null : ProcedureReturn : EndIf 
   Engine_SetAttribute(_Maker\pCurrDesign\DesignID, #Attribute_MatterRotate, #Object_Rotate_TurnL90)
   Screen_RedrawScreen(#True)
EndProcedure
   
;右转90度
Procedure Maker_EventGadget_wmiRotateTurnR90() 
   If _Maker\pCurrDesign = #Null : ProcedureReturn : EndIf 
   Engine_SetAttribute(_Maker\pCurrDesign\DesignID, #Attribute_MatterRotate, #Object_Rotate_TurnR90)
   Screen_RedrawScreen(#True)
EndProcedure   

;翻转对象
Procedure Maker_EventGadget_wmiRotateFlip180() 
   If _Maker\pCurrDesign = #Null : ProcedureReturn : EndIf 
   Engine_SetAttribute(_Maker\pCurrDesign\DesignID, #Attribute_MatterRotate, #Object_Rotate_Flip180)
   Screen_RedrawScreen(#True)
EndProcedure

;-
;左对齐
Procedure Maker_EventGadget_wmiAlignLeft()     
   If _Maker\pCurrDesign = #Null : ProcedureReturn : EndIf 
   Engine_SetAttribute(_Maker\pCurrDesign\DesignID, #Attribute_Alignment, #Canvas_Align_Left)
   Screen_RedrawScreen(#True)
EndProcedure

;水平中心对齐 
Procedure Maker_EventGadget_wmiAlignCenter()   
   If _Maker\pCurrDesign = #Null : ProcedureReturn : EndIf 
   Engine_SetAttribute(_Maker\pCurrDesign\DesignID, #Attribute_Alignment, #Canvas_Align_Center)
   Screen_RedrawScreen(#True)
EndProcedure

;右对齐 
Procedure Maker_EventGadget_wmiAlignRight()      
   If _Maker\pCurrDesign = #Null : ProcedureReturn : EndIf 
   Engine_SetAttribute(_Maker\pCurrDesign\DesignID, #Attribute_Alignment, #Canvas_Align_Right)
   Screen_RedrawScreen(#True)
EndProcedure

;上对齐
Procedure Maker_EventGadget_wmiAlignTop()      
   If _Maker\pCurrDesign = #Null : ProcedureReturn : EndIf 
   Engine_SetAttribute(_Maker\pCurrDesign\DesignID, #Attribute_Alignment, #Canvas_Align_Top)
   Screen_RedrawScreen(#True)
EndProcedure

;垂直中心对齐
Procedure Maker_EventGadget_wmiAlignMiddle()   
   If _Maker\pCurrDesign = #Null : ProcedureReturn : EndIf 
   Engine_SetAttribute(_Maker\pCurrDesign\DesignID, #Attribute_Alignment, #Canvas_Align_Middle)
   Screen_RedrawScreen(#True)
EndProcedure

;下对齐
Procedure Maker_EventGadget_wmiAlignBottom()   
   If _Maker\pCurrDesign = #Null : ProcedureReturn : EndIf 
   Engine_SetAttribute(_Maker\pCurrDesign\DesignID, #Attribute_Alignment, #Canvas_Align_Bottom)
   Screen_RedrawScreen(#True)
EndProcedure

;-
;左侧分布
Procedure Maker_EventGadget_wmiEvenlyLeft()    
   If _Maker\pCurrDesign = #Null : ProcedureReturn : EndIf 
   Engine_SetAttribute(_Maker\pCurrDesign\DesignID, #Attribute_Distribute, #Canvas_Evenly_Left)
   Screen_RedrawScreen(#True)
EndProcedure

;水平中心分布
Procedure Maker_EventGadget_wmiEvenlyCenter()  
   If _Maker\pCurrDesign = #Null : ProcedureReturn : EndIf 
   Engine_SetAttribute(_Maker\pCurrDesign\DesignID, #Attribute_Distribute, #Canvas_Evenly_Center)
   Screen_RedrawScreen(#True)
EndProcedure

;水平间距分布
Procedure Maker_EventGadget_wmiEvenlySpace()   
   If _Maker\pCurrDesign = #Null : ProcedureReturn : EndIf 
   Engine_SetAttribute(_Maker\pCurrDesign\DesignID, #Attribute_Distribute, #Canvas_Evenly_Space)
   Screen_RedrawScreen(#True)
EndProcedure

;右侧分布
Procedure Maker_EventGadget_wmiEvenlyRight()   
   If _Maker\pCurrDesign = #Null : ProcedureReturn : EndIf 
   Engine_SetAttribute(_Maker\pCurrDesign\DesignID, #Attribute_Distribute, #Canvas_Evenly_Right)
   Screen_RedrawScreen(#True)
EndProcedure

;上侧分布
Procedure Maker_EventGadget_wmiEvenlyTop()     
   If _Maker\pCurrDesign = #Null : ProcedureReturn : EndIf 
   Engine_SetAttribute(_Maker\pCurrDesign\DesignID, #Attribute_Distribute, #Canvas_Evenly_Top)
   Screen_RedrawScreen(#True)
EndProcedure

;垂直中心分布
Procedure Maker_EventGadget_wmiEvenlyMiddle()  
   If _Maker\pCurrDesign = #Null : ProcedureReturn : EndIf 
   Engine_SetAttribute(_Maker\pCurrDesign\DesignID, #Attribute_Distribute, #Canvas_Evenly_Middle)
   Screen_RedrawScreen(#True)
EndProcedure

;垂直间距分布
Procedure Maker_EventGadget_wmiEvenlyBorder()  
   If _Maker\pCurrDesign = #Null : ProcedureReturn : EndIf 
   Engine_SetAttribute(_Maker\pCurrDesign\DesignID, #Attribute_Distribute, #Canvas_Evenly_Border)
   Screen_RedrawScreen(#True)
EndProcedure

;下侧分布
Procedure Maker_EventGadget_wmiEvenlyBottom()  
   If _Maker\pCurrDesign = #Null : ProcedureReturn : EndIf 
   Engine_SetAttribute(_Maker\pCurrDesign\DesignID, #Attribute_Distribute, #Canvas_Evenly_Bottom)
   Screen_RedrawScreen(#True)
EndProcedure

;-
;下侧分布
Procedure Maker_EventGadget_wmiAlignGrids()  
   If _Maker\pCurrDesign = #Null : ProcedureReturn : EndIf 
   Engine_SetAttribute(_Maker\pCurrDesign\DesignID, #Attribute_AlignGrids, #Null)
   Screen_RedrawScreen(#True)
EndProcedure

;-
Procedure Maker_EventGadget()
   
   If _Maker\IsRegister = #Null 
      GadgetID = EventGadget()
      If GadgetID = #wmiExitSoftware
         Maker_Event_CloseWindow()            ;退出软件
      EndIf 
      ProcedureReturn 
   EndIf 
   
   GadgetID = EventGadget()
   Select GadgetID
      Case #winScreen         : Maker_EventGadget_winScreen()        ;软件标志和名字
      ;标题栏部分
      Case #wmiSoftware       : Maker_EventGadget_wmiSoftware() 
      Case #wmiSettings       : Maker_EventGadget_wmiSettings() 
      Case #wmiCreateDesign   : Maker_EventGadget_wmiCreateDesign()  ;创建设计文档
      Case #wmiOpenDesign     : Maker_EventGadget_wmiOpenDesign()    ;打开设计文档
      Case #wmiSaveDesign     : Maker_EventGadget_wmiSaveDesign()    ;保存设计文档
      Case #wmiCloseDesign    : Maker_EventGadget_wmiCloseDesign()   ;关闭设计文档      
      ;弹出菜单部分[文件]
      Case #wmiSaveAsDesign   : Maker_EventGadget_wmiSaveAsDesign()  ;设计文档另存为
      Case #wmiSaveAllDesign  : Maker_EventGadget_wmiSaveAllDesign() ;保存所有设计文档
      Case #wmiCloseAllDesign : Maker_EventGadget_wmiCloseAllDesign();关闭所有设计文档
      Case #wmiExportImage    : Maker_EventGadget_wmiExportImage()   ;导出画布图像
      Case #wmiResizeCanvas   : Maker_EventGadget_wmiResizeCanvas()  ;重新设计画布尺寸
      Case #wmiExitSoftware   : Maker_Event_CloseWindow()            ;退出软件
      ;弹出菜单部分[视图]
      Case #wmiDisplayGrid    : Maker_EventGadget_wmiDisplayGrid()   ;显示网格
      Case #wmiDisplayCoor    ;显示坐标
      Case #wmiStyleBlack     : Screen_ChangeStyle(#ViewStlye_Black) ;黑板风格
      Case #wmiStyleGreen     : Screen_ChangeStyle(#ViewStlye_Green) ;绿板风格
      Case #wmiStyleBlue      : Screen_ChangeStyle(#ViewStlye_Blue)  ;蓝板风格
      Case #wmiStyleRed       : Screen_ChangeStyle(#ViewStlye_Red)   ;红板风格
      ;导航条部分   
      Case #btnScrollUp       : Maker_EventGadget_btnScrollUp()      ;向上滚动画布
      Case #btnScrollDown     : Maker_EventGadget_btnScrollDown()    ;向下滚动画布
      Case #btnScrollLeft     : Maker_EventGadget_btnScrollLeft()    ;向左滚动画布
      Case #btnScrollRight    : Maker_EventGadget_btnScrollRight()   ;向右滚动画布
      Case #btnScrollHome     : Maker_EventGadget_btnScrollHome()    ;画布滚动至主页
      Case #btnScaleUp        : Maker_EventGadget_btnScaleUp()       ;扩大画布比例
      Case #btnScaleDown      : Maker_EventGadget_btnScaleDown()     ;缩小画布比例          
      ;基本操作
      Case #wmiCreateString   : Maker_EventGadget_wmiCreateString()  ;添加标签
      Case #wmiDeleteObject   : Maker_EventGadget_wmiDeleteObject()  ;删除对象
      Case #wmiMergerGroups   : Maker_EventGadget_wmiMergerGroups()  ;组合[活动组]
      Case #wmiDivideGroups   : Maker_EventGadget_wmiDivideGroups()  ;拆分[选中组]
      Case #wmiDupontsColor   : Maker_EventGadget_wmiDupontsColor()  ;[杜邦线]修改颜色
      ;========================
      Case #wmiLayerTop       : Maker_EventGadget_wmiLayerTop()      ;置于顶层 
      Case #wmiLayerBottom    : Maker_EventGadget_wmiLayerBottom()   ;置于底层  
      Case #wmiLayerPrev      : Maker_EventGadget_wmiLayerPrev()     ;下移一层 
      Case #wmiLayerNext      : Maker_EventGadget_wmiLayerNext()     ;上移一层
      Case #wmiRotateTurnL90  : Maker_EventGadget_wmiRotateTurnL90() ;左转90度
      Case #wmiRotateTurnR90  : Maker_EventGadget_wmiRotateTurnR90() ;右转90度
      Case #wmiRotateFlip180  : Maker_EventGadget_wmiRotateFlip180() ;翻转对象
      ;======================== 
      Case #wmiAlignLeft      : Maker_EventGadget_wmiAlignLeft()     ;左对齐
      Case #wmiAlignCenter    : Maker_EventGadget_wmiAlignCenter()   ;水平中心对齐 
      Case #wmiAlignRight     : Maker_EventGadget_wmiAlignRight()    ;右对齐   
      Case #wmiAlignTop       : Maker_EventGadget_wmiAlignTop()      ;上对齐
      Case #wmiAlignMiddle    : Maker_EventGadget_wmiAlignMiddle()   ;垂直中心对齐
      Case #wmiAlignBottom    : Maker_EventGadget_wmiAlignBottom()   ;下对齐
      ;========================
      Case #wmiEvenlyLeft     : Maker_EventGadget_wmiEvenlyLeft()    ;左侧分布
      Case #wmiEvenlyCenter   : Maker_EventGadget_wmiEvenlyCenter()  ;水平中心分布
      Case #wmiEvenlySpace    : Maker_EventGadget_wmiEvenlySpace()   ;水平间距分布
      Case #wmiEvenlyRight    : Maker_EventGadget_wmiEvenlyRight()   ;右侧分布
      Case #wmiEvenlyTop      : Maker_EventGadget_wmiEvenlyTop()     ;上侧分布
      Case #wmiEvenlyMiddle   : Maker_EventGadget_wmiEvenlyMiddle()  ;垂直中心分布
      Case #wmiEvenlyBorder   : Maker_EventGadget_wmiEvenlyBorder()  ;垂直间距分布
      Case #wmiEvenlyBottom   : Maker_EventGadget_wmiEvenlyBottom()  ;下侧分布
      ;========================
      Case #wmiAlignGrids     : Maker_EventGadget_wmiAlignGrids()  
   EndSelect    
EndProcedure

;-
;- ******** [EventWindow] ******** 

;系统拖放文件事件[单文件模式]
Procedure Maker_Event_DragDorpFile()
   DroppedID = EventwParam()
   CountFiles = DragQueryFile_(DroppedID, -1, "", 0)
   If CountFiles
      LenFileName  = DragQueryFile_(DroppedID, 0, 0, 0)
      FileName$ = Space(LenFileName)  
      DragQueryFile_(DroppedID, 0, FileName$, LenFileName+1) 
   EndIf 
   DragFinish_(DroppedID) 
   If FileSize(FileName$) >= 0 
      *pListDesign = Caption_OpenDesign(FileName$) 
      If *pListDesign
         _Maker\pCurrDesign = *pListDesign
      EndIf 
      Screen_RedrawScreen(#True)  
   EndIf
EndProcedure



;关闭窗体事件
Procedure Maker_Event_CloseWindow()
   Result = Message_Requester(_Maker\hWindow, "迷路提示", "确定要关闭窗体吗? ", #PB_MessageRequester_YesNo, #True)
   If Result = #PB_MessageRequester_Yes 
      _Maker\IsExitWindow = #True 
   EndIf 
EndProcedure

;-
;- ######## [Main] ######## 
With _Maker
   If Maker_InitialEngine() : End : EndIf 
   Caption_CallBack (#CallBack_CreateDesign, @Maker_Call_CreateDesign())
   Caption_CallBack (#CallBack_OpenDesign,   @Maker_Call_OpenDesign())
   Caption_CallBack (#CallBack_LoadDesign,   @Maker_Call_LoadDesign())
   Caption_CallBack (#CallBack_SaveDesign,   @Maker_Call_SaveDesign())
   Caption_CallBack (#CallBack_CloseDesign,  @Maker_Call_CloseDesign())
   Caption_CallBack (#CallBack_ExportImage,  @Maker_Call_ExportImage())
   Caption_CallBack (#CallBack_SelectDesign, @Maker_Call_SelectDesign())
   ToolBar_CallBack (#CallBack_SelectMatter, @Maker_Call_SelectMatter())
   Screen_CallBack  (#CallBack_RedrawCanvas, @Maker_Call_RedrawCanvas())
   Dialog_CallBack  (#CallBack_GetThumbnail, @Maker_Call_GetThumbnail())
   \pWindow = Screen_Initail()
   Maker_RegisterEngine()
   \hWindow = \pWindow\hWindow
   If \hWindow = #Null : End : EndIf 
   Repeat
      WindowEvent = WindowEvent()
      Select WindowEvent
         Case #PB_Event_CloseWindow : Maker_Event_CloseWindow()
         Case #WM_DROPFILES         : Maker_Event_DragDorpFile()
         Case #PB_Event_Gadget      : Maker_EventGadget()   
         Case #Null                 : Screen_EventWindow_Null()
      EndSelect
      Screen_EventWindow_Delay() 
      If _Maker\IsRefresh = #True
         Screen_RedrawScreen(#True)
         _Maker\IsRefresh = #False
      EndIf 
         
   Until \IsExitWindow = #True 
   Screen_Release()   
   Maker_ReleaseEngine()

EndWith
End

;-
;- ******** [Data] ******** 
DataSection
_ICON_Resources:
   IncludeBinary ".\ICON.png" 
EndDataSection








; IDE Options = PureBasic 5.62 (Windows - x86)
; CursorPosition = 712
; FirstLine = 585
; Folding = fI7---------
; EnableXP
; Executable = DEMO.exe