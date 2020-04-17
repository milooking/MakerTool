
Procedure Maker_InitialEngine()
   _Maker\EngineID = Engine_Initial(@IsRegister.long)
   If _Maker\EngineID = #Null
      Debug Engine_ErrorMessage()
      ProcedureReturn #True
   EndIf 
   _Maker\IsRegister = IsRegister\l
   
   ModuleGroup$ = #Null$
   Count = Engine_CountModule(_Maker\EngineID)
   ListModule.__Engine_ModuleType
;    ListModule.__Maker_ModuleType
   *pGroups.__Maker_ModuleGroup = AddElement(_ListGroups())
   For Index = 0 To Count-1
      Engine_GetModule(_Maker\EngineID, Index, @ListModule)
      CurrModuleGroup$ = PeekS(ListModule\pModuleGroup)  ;模块编组
      
      If ModuleGroup$ <> CurrModuleGroup$
         ModuleGroup$ = CurrModuleGroup$
         *pGroups.__Maker_ModuleGroup = AddElement(_ListGroups())
         *pGroups\GroupName$ = ModuleGroup$
      EndIf 
      *pModule.__Maker_ModuleInfo = AddElement(_ListGroups()\ListModule())
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

Procedure Maker_CallBack_Register(Index, Count, Note$)
   Debug Str(Index)+"/"+Str(Count) + ":" + Note$
EndProcedure

Procedure Maker_RegisterEngine()
   If _Maker\IsRegister = #Null
      Engine_SetCallBack(_Maker\EngineID, #CallBack_Register, @Maker_CallBack_Register())
   EndIf 
EndProcedure

Procedure Maker_ReleaseEngine()
   Engine_FreeDesign(_Maker\DesignID)   
   Engine_Release(_Maker\EngineID)
EndProcedure
   
   
; IDE Options = PureBasic 5.62 (Windows - x86)
; CursorPosition = 36
; FirstLine = 12
; Folding = -
; EnableXP
; Executable = Engine.dll