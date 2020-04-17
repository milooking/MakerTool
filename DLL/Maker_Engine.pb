;*****************************************
;******** 单片机仿真模拟器内核引擎 ********
;********    迷路仟 2020.02.04    ********
;*****************************************
;【Engine_Module.pbi】 ;模块设置流文件相关的源代码文件
;【Engine_Design.pbi】 ;设计文档流文件相关的源代码文件
;【Engine_Object.pbi】 ;电子元件相关及画布辅助的源代码
;【Engine_Dupont.pbi】 ;杜邦线相关的及画布辅助的源代码
;【Engine_Canvas.pbi】 ;画布绘制及事件相关的源代码文件
;【Maker_Engine.pb】   ;主文件

;- [Constant]
#EngineFlags$ = "Flags_EngineID"
#Engine_Error_1000$ = "Engine没有注册"
#Engine_Error_1001$ = "EngineID无效."
#Engine_Error_1002$ = "ModuleID无效."
#Engine_Error_1003$ = "DesignID无效."
#Engine_Error_1004$ = "CanvasID无效."
#Engine_Error_1005$ = "回调函数不能为空."

#Object_Selected = 0
;- [Enumeration]
Enumeration
   #Engine_Error_1000 = 1000
   #Engine_Error_1001
   #Engine_Error_1002
   #Engine_Error_1003
   #Engine_Error_1004
   #Engine_Error_1005
EndEnumeration

;- [Structure]
;外接变量[模块类型]结构
Structure __Engine_ModuleType
   *pModuleGroup      ;模块编组
   *pModuleTypes      ;模块类型
   *pModuleModel      ;模块型号
   *pModuleName       ;模块名称
   *pModuleNote       ;模块说明
   hModuleIcon.l      ;模块图标ID
   ModuleID.l
EndStructure

; 引擎主结构,作为接口输出为:EngineID
Structure __Engine_MainInfo
   EngineFlags$
   *pMainModule.__Module_MainInfo
   DimReserve.l[16]
EndStructure


;- [Include]
XIncludeFile "Engine_Module.pbi"  ;模块设置流文件相关的源代码文件
XIncludeFile "Engine_Design.pbi"  ;设计文档流文件相关的源代码文件
XIncludeFile "Engine_Canvas.pbi"  ;画布绘制及事件相关的源代码文件

;-
;- ******** [Macro] ********
Macro Macro_Check_EngineID()
   If *pMainEngine = #Null Or *pMainEngine\EngineFlags$ <> #EngineFlags$
      _EngineErrorCode = #Engine_Error_1001
      ProcedureReturn #Null
   EndIf 
EndMacro

Macro Macro_Check_Register()
   If *pMainEngine\pMainModule = #Null
      _EngineErrorCode = #Engine_Error_1000
      ProcedureReturn #Null
   EndIf 
EndMacro

Macro Macro_Check_ModuleID()
   If *pMainModule = #Null Or *pMainModule\ModuleFlags$ <> #ModuleFlags$
      _EngineErrorCode = #Engine_Error_1002
      ProcedureReturn #Null
   EndIf 
EndMacro

Macro Macro_Check_DesignID()
   If *pMainDesign = #Null Or *pMainDesign\DesignFlags$ <> #DesignFlags$
      _EngineErrorCode = #Engine_Error_1003
      ProcedureReturn #Null
   EndIf 
EndMacro

Macro Macro_Check_CanvasID()
   If *pMainCanvas = #Null Or *pMainCanvas\CanvasFlags$ <> #CanvasFlags$
      _EngineErrorCode = #Engine_Error_1004
      ProcedureReturn #Null
   EndIf 
EndMacro

;-
;- ******** [Engine] ********
;初始化引擎
ProcedureDLL Engine_Initial(*pRegister.long)
   UseMD5Fingerprint() 
   UsePNGImageDecoder() 
   UsePNGImageEncoder()
   *pMainModule.__Module_MainInfo = Module_LoadBinary() 
   If *pMainModule = #Null : ProcedureReturn #Null : EndIf 
   If *pRegister
      *pRegister\l = *pMainModule\IsModuleInitial
   EndIf 
   
   ;申请EngineID内存空间
   *pMainEngine.__Engine_MainInfo = AllocateStructure(__Engine_MainInfo)
   *pMainEngine\EngineFlags$ = #EngineFlags$
   *pMainEngine\pMainModule  = *pMainModule
   ProcedureReturn *pMainEngine
EndProcedure

;注销引擎
ProcedureDLL Engine_Release(EngineID)
   *pMainEngine.__Engine_MainInfo = EngineID
   Macro_Check_EngineID()
   
   *pMainModule.__Module_MainInfo = *pMainEngine\pMainModule
   Macro_Check_ModuleID()
   
   Module_Release(*pMainEngine\pMainModule)     ;注释ModuleID结构
   *pMainEngine\EngineFlags$ = #Null$
   Result = FreeStructure(*pMainEngine)         ;注释EngineID结构
   ProcedureReturn Result
EndProcedure

;注册引擎
ProcedureDLL Engine_SetCallBack(EngineID, CallBackType, *pCallFunction)
   *pMainEngine.__Engine_MainInfo = EngineID
   Macro_Check_EngineID()
   
   *pMainModule.__Module_MainInfo = *pMainEngine\pMainModule
   Macro_Check_ModuleID()
   
   Select CallBackType
      Case #CallBack_Register
         If *pMainModule\IsModuleInitial = #True
            ProcedureReturn -1
         EndIf 
         *pMainModule\pCallRegister = *pCallFunction
         Module_Register(*pMainModule)
         ProcedureReturn #True
         
      Case #CallBack_AddString
         *pMainModule\pCallAddString = *pCallFunction
         ProcedureReturn #True   
         
      Case #CallBack_RightClick
         *pMainModule\pCallRightClick = *pCallFunction
         ProcedureReturn #True            
         
   EndSelect
EndProcedure  

   
;出错捕获
ProcedureDLL Engine_ErrorCode()
   ProcedureReturn _EngineErrorCode
EndProcedure

;出错捕获
ProcedureDLL$ Engine_ErrorMessage(ErrorCode=#PB_Ignore)
   If ErrorCode=#PB_Ignore : ErrorCode=_EngineErrorCode : EndIf 
   ErrorMessage$ = Module_ErrorMessage(ErrorCode)
   If ErrorMessage$ : ProcedureReturn ErrorMessage$ : EndIf 
   ErrorMessage$ = Design_ErrorMessage(ErrorCode)
   If ErrorMessage$ : ProcedureReturn ErrorMessage$ : EndIf 
   ErrorMessage$ = Canvas_ErrorMessage(ErrorCode)
   If ErrorMessage$ : ProcedureReturn ErrorMessage$ : EndIf 
   
   Select ErrorCode
      Case #Engine_Error_1000 : ErrorMessage$ = #Engine_Error_1000$
      Case #Engine_Error_1001 : ErrorMessage$ = #Engine_Error_1001$
      Case #Engine_Error_1002 : ErrorMessage$ = #Engine_Error_1002$
      Case #Engine_Error_1003 : ErrorMessage$ = #Engine_Error_1003$
      Case #Engine_Error_1004 : ErrorMessage$ = #Engine_Error_1004$
      Case #Engine_Error_1005 : ErrorMessage$ = #Engine_Error_1005$
   EndSelect
   ProcedureReturn ErrorMessage$    
EndProcedure

;-
;- ******** [Module] ********
;获取[模块类型]数量
ProcedureDLL Engine_CountModule(EngineID)
   *pMainEngine.__Engine_MainInfo = EngineID
   Macro_Check_EngineID()
   
   *pMainModule.__Module_MainInfo = *pMainEngine\pMainModule
   Macro_Check_ModuleID()
   
   CountModule = ListSize(*pMainModule\ListModule())
   ProcedureReturn CountModule
EndProcedure

;获取[模块类型]基本信息
ProcedureDLL Engine_GetModule(EngineID, Index, *pModule.__Engine_ModuleType)
   *pMainEngine.__Engine_MainInfo = EngineID
   Macro_Check_EngineID()

   *pMainModule.__Module_MainInfo = *pMainEngine\pMainModule
   Macro_Check_ModuleID()

   If SelectElement(*pMainModule\ListModule(), Index) And *pModule
      *pListModule.__Module_BaseInfo = *pMainModule\ListModule()
      With *pListModule
         *pModule\pModuleGroup = @\ModuleGroup$           ;模块编组
         *pModule\pModuleTypes = @\ModuleTypes$           ;模块类型
         *pModule\pModuleModel = @\ModuleModel$           ;模块型号
         *pModule\pModuleName  = @\ModuleName$            ;模块名称
         *pModule\pModuleNote  = @\ModuleNote$            ;模块说明
         *pModule\hModuleIcon  = ImageID(\ModuleIconID)  ;模块图标ID
         *pModule\ModuleID     = *pListModule
      EndWith
   EndIf 
   ProcedureReturn *pListModule
EndProcedure

;-
;- ******** [Design] ********
;创建一个[设计文档]
ProcedureDLL Engine_CreateDesign(EngineID)
   *pMainEngine.__Engine_MainInfo = EngineID
   Macro_Check_EngineID()
   Macro_Check_Register()
   
   *pMainDesign.__Design_MainInfo = Design_Create(*pMainEngine\pMainModule)
   If *pMainDesign = #Null
      _EngineErrorCode = #Engine_Error_1003
      ProcedureReturn #Null
   EndIf 
   *pMainDesign\pMainEngine = *pMainEngine

   *pMainCanvas.__Canvas_MainInfo = Canvas_Create(*pMainDesign)   
   If *pMainCanvas = #Null
      Design_Release(*pMainDesign)
      _EngineErrorCode = #Design_Error_3001
      ProcedureReturn #Null
   EndIf 
   ;特别注意,这里返回值是: *pMainDesign, 
   ;*pMainCanvas由*pMainDesign内部关联,减少外接使用的麻烦
   ProcedureReturn *pMainDesign
EndProcedure

;释放一个[设计文档]
ProcedureDLL Engine_FreeDesign(DesignID)
   *pMainDesign.__Design_MainInfo = DesignID
   Macro_Check_DesignID()
   *pMainEngine.__Engine_MainInfo = *pMainDesign\pMainModule

   Macro_Check_EngineID()
   Macro_Check_Register()
   *pMainCanvas.__Canvas_MainInfo = *pMainDesign\pMainCanvas
   Macro_Check_CanvasID()
   Result = Canvas_Release(*pMainCanvas)
   Result | Design_Release(*pMainDesign)
   ProcedureReturn Result
EndProcedure

ProcedureDLL Engine_Thumbnail(EngineID, FileName$)
   *pMainEngine.__Engine_MainInfo = EngineID
   Macro_Check_EngineID()
   Macro_Check_Register()
   *pMainModule.__Module_MainInfo = *pMainEngine\pMainModule
   Macro_Check_ModuleID()
   *hThumbnail = Design_Thumbnail(*pMainModule, FileName$)
   ProcedureReturn *hThumbnail
EndProcedure


;加载[设计文档]
ProcedureDLL Engine_LoadDesign(EngineID, FileName$)
   *pMainEngine.__Engine_MainInfo = EngineID
   Macro_Check_EngineID()
   Macro_Check_Register()
   *pMainModule.__Module_MainInfo = *pMainEngine\pMainModule
   Macro_Check_ModuleID()
   *pMainDesign.__Design_MainInfo = Design_LoadFile(*pMainModule, FileName$, @Canvas_Create())
   *pMainDesign\pMainEngine = *pMainEngine
   *pMainDesign\pMainModule = *pMainModule
   *pMainCanvas.__Canvas_MainInfo = *pMainDesign\pMainCanvas
   ProcedureReturn *pMainDesign
EndProcedure

;保存[设计文档]
ProcedureDLL Engine_SaveDesign(DesignID, SaveName$)
   *pMainDesign.__Design_MainInfo = DesignID
   Macro_Check_DesignID()
   *pMainEngine.__Engine_MainInfo = *pMainDesign\pMainEngine 
   Macro_Check_Register()
   Result = Design_SaveFile(*pMainDesign, SaveName$)
   ProcedureReturn Result 
EndProcedure



;-
;- ******** [Object] ********
;添加一个[电子元件]
ProcedureDLL Engine_NewMatter(DesignID, ModuleID, X.f, Y.f, RotateIdx)
   *pMainDesign.__Design_MainInfo = DesignID
   Macro_Check_DesignID()
   
   *pMainEngine.__Engine_MainInfo = *pMainDesign\pMainEngine 
   Macro_Check_Register()
   
   *pMatter = Object_AddMatter(*pMainDesign, ModuleID, X, Y, RotateIdx)
   ProcedureReturn *pMatter
EndProcedure

;删除一个[电子元件]
ProcedureDLL Engine_FreeMatter(DesignID, MatterID)
   *pMainDesign.__Design_MainInfo = DesignID
   Macro_Check_DesignID()
   
   *pMainEngine.__Engine_MainInfo = *pMainDesign\pMainEngine 
   Macro_Check_Register()
   
   Result = Object_FreeMatter(*pMainDesign, MatterID)
   ProcedureReturn Result
EndProcedure

;添加一个[文本标签]
ProcedureDLL Engine_NewString(DesignID, X.f, Y.f, Text$)
   *pMainDesign.__Design_MainInfo = DesignID
   Macro_Check_DesignID()
   
   *pMainEngine.__Engine_MainInfo = *pMainDesign\pMainEngine 
   Macro_Check_Register()
   
   *pString = Object_AddString(*pMainDesign, X, Y, Text$)
   ProcedureReturn *pString
EndProcedure

;删除一个[文本标签]
ProcedureDLL Engine_FreeString(DesignID, StringID)
   *pMainDesign.__Design_MainInfo = DesignID
   Macro_Check_DesignID()
   
   *pMainEngine.__Engine_MainInfo = *pMainDesign\pMainEngine 
   Macro_Check_Register()
   
   Result = Object_FreeString(*pMainDesign, StringID)
   ProcedureReturn Result
EndProcedure

;-
;- ******** [Canvas] ********
;重绘画布
ProcedureDLL Engine_RedrawCanvas(DesignID, CanvasW, CanvasH)
   *pMainDesign.__Design_MainInfo = DesignID
   Macro_Check_DesignID()
   *pMainEngine.__Engine_MainInfo = *pMainDesign\pMainEngine 
   
   Macro_Check_Register()
   *pMainCanvas.__Canvas_MainInfo = *pMainDesign\pMainCanvas
   Macro_Check_CanvasID()

   hCanvasImage = Canvas_RedrawScreen(*pMainCanvas, CanvasW, CanvasH)
   ProcedureReturn hCanvasImage
EndProcedure

;画布截屏
ProcedureDLL Engine_Screenshot(DesignID, FileName$)
   *pMainDesign.__Design_MainInfo = DesignID
   Macro_Check_DesignID()
   
   *pMainEngine.__Engine_MainInfo = *pMainDesign\pMainEngine 
   Macro_Check_Register()
   
   *pMainCanvas.__Canvas_MainInfo = *pMainDesign\pMainCanvas
   Macro_Check_CanvasID()
   
   Result = Canvas_Screenshot(*pMainCanvas, FileName$)
   ProcedureReturn Result
EndProcedure

;画布响应事件
ProcedureDLL Engine_EventCanvas(DesignID, X, Y, EventType, Button=#Null)
   *pMainDesign.__Design_MainInfo = DesignID
   Macro_Check_DesignID()
   *pMainCanvas.__Canvas_MainInfo = *pMainDesign\pMainCanvas
   Macro_Check_CanvasID()
   Select EventType
      Case  #PB_EventType_LeftButtonDown  : Result = Canvas_Event_LeftButtonDown  (*pMainCanvas, X, Y, Button) ;左键按下事件
      Case  #PB_EventType_LeftButtonUp    : Result = Canvas_Event_LeftButtonUp    (*pMainCanvas, X, Y, Button) ;左键释放事件
      Case  #PB_EventType_LeftDoubleClick : Result = Canvas_Event_LeftDoubleClick (*pMainCanvas, X, Y)         ;左键双击事件
      Case  #PB_EventType_RightButtonDown : Result = Canvas_Event_RightButtonDown (*pMainCanvas, X, Y, Button) ;右键按下事件
      Case  #PB_EventType_RightButtonUp   : Result = Canvas_Event_RightButtonUp   (*pMainCanvas, X, Y, Button) ;右键释放事件
      Case  #PB_EventType_RightDoubleClick: Result = Canvas_Event_RightDoubleClick(*pMainCanvas, X, Y)         ;右键双击事件
      Case  #PB_EventType_MouseMove       : Result = Canvas_Event_MouseMove       (*pMainCanvas, X, Y, Button) ;光标移动事件       
      Case  #PB_EventType_KeyDown         : Result = Canvas_Event_KeyDown         (*pMainCanvas, Button)       ;
      Case  #PB_EventType_KeyUp           : Result = Canvas_Event_KeyUp           (*pMainCanvas, Button)       ;
   EndSelect
   ProcedureReturn Result
EndProcedure


;-
;- ******** [Attribute] ********

;设置属性
ProcedureDLL Engine_GetAttribute(DesignID, Attribute, ObjectID=#Null)
   *pMainDesign.__Design_MainInfo = DesignID
   Macro_Check_DesignID()
   
   *pMainCanvas.__Canvas_MainInfo = *pMainDesign\pMainCanvas
   Macro_Check_CanvasID()
   
   Value = Object_GetAttribute(*pMainDesign, Attribute, ObjectID)
   ProcedureReturn Value
EndProcedure

;获取属性
ProcedureDLL Engine_SetAttribute(DesignID, Attribute, Value, ObjectID=#Null)
   *pMainDesign.__Design_MainInfo = DesignID
   Macro_Check_DesignID()
   
   *pMainCanvas.__Canvas_MainInfo = *pMainDesign\pMainCanvas
   Macro_Check_CanvasID()
   Result = Object_SetAttribute(*pMainDesign, Attribute, Value, ObjectID)
   ProcedureReturn Result
EndProcedure







; IDE Options = PureBasic 5.62 (Windows - x86)
; ExecutableFormat = Shared dll
; CursorPosition = 149
; FirstLine = 84
; Folding = Oc9-5
; EnableXP
; Executable = MakerTool\Engine.dll