;*****************************************
;******** 单片机仿真模拟器内核引擎 ********
;********    迷路仟 2020.02.04    ********
;*****************************************
;【Engine_Module.pbi】 ;模块设置流文件相关的源代码文件

Enumeration
   ;调整这里的顺序,可以测试指定的 Debug
   
   #DebugLevel_Design   

   ;===========================   
   #DebugLevel_Dupont_Modify  ;修改选中[杜邦线]    
   #DebugLevel_Object_Moving  ;[对象]移动 
   #DebugLevel_Dupont_Create  ;新建一条[杜邦线]    
 
   #DebugLevel_Dupont_DuNode  ;节点修改  
   #DebugLevel_Visible     ;<---以上的内容为可视的Debug 
   #DebugLevel_Object_Select  ;[对象]选择 
 
   #DebugLevel_Object_Modify  
     
   #DebugLevel_Module 
   #DebugLevel_Canvas
EndEnumeration

DebugLevel #DebugLevel_Visible ;指定测试类别


;- [Constant]
;{
#ModuleFlags$ = "Flags_BinaryID"
#Object_HorizontalFlip_180 = 4
#Binary_Module_Flags   = $C3D6E8C9E9BFA3C4
#Binary_Module_Module$ = ".\Module.bin"
#Binary_Version   = 0.1
#GroupType_None   = 0       ;常规引脚
#GroupType_Group  = 1      ;编组
#GroupType_Element= 2      ;编组成员
#ModuleType_String$ = "标签控件[Label]" 

#Module_Error_2001$ = "ModuleID无效."
#Module_Error_2002$ = "[Module.bin]文件丢失."
#Module_Error_2003$ = "[Module.bin]文件被占用."
#Module_Error_2004$ = "[Module.bin]文件标志有误."
#Module_Error_2005$ = "[Module.bin]文件版本有误."
#Module_Error_2006$ = "[Module.bin]文件数据受损:MD5校验出错."
#Module_Error_2007$ = "[Module.bin]文件数据受损:加载图标失败."
#Module_Error_2008$ = "[Module.bin]文件被占用."
#Module_Error_2009$ = "[Module.bin]文件数据受损:图像大小为0."
#Module_Error_2010$ = "[Module.bin]文件数据受损:加载图标出错."
#Module_Error_2011$ = "[Module.bin]文件数据受损:加载图像出错."
#Module_Error_2012$ = "[Module.bin]文件初始化失败:回调函数不能为空."
#Module_Error_2013$ = "[Module.bin]文件重载失败."


#CallBack_Register   = 1
#CallBack_AddString  = 2
#CallBack_RightClick = 3

               
               
;}

;- [Enumeration]
; 出错代码
Enumeration
   #Module_Error_None
   #Module_Error_2001 = 2001
   #Module_Error_2002
   #Module_Error_2003
   #Module_Error_2004
   #Module_Error_2005
   #Module_Error_2006
   #Module_Error_2007
   #Module_Error_2008
   #Module_Error_2009
   #Module_Error_2010
   #Module_Error_2011
   #Module_Error_2012
   #Module_Error_2013

EndEnumeration
      
; [实物单元]旋转角度
Enumeration
   #Object_Rotate_000
   #Object_Rotate_090
   #Object_Rotate_180
   #Object_Rotate_270
   #Object_Rotate_Count
EndEnumeration

; [实物单元]缩放比例
Enumeration
   #Layer_Zoom_100
   #Layer_Zoom_075
   #Layer_Zoom_050
   #Layer_Zoom_025
   #Layer_Zoom_Count
EndEnumeration



;- [Structure]
;========= [流文件] =========
;[模块设置]流文件头部结构
Structure __Module_Header
   Flags.q        ; 标志
   HeadSize.w     ; 头部大小
   NoteAddr.w     ; 备注地址
   Version.f      ; 版本号
   IdxCount.l     ; 索引数量
   ExtSize.l      ; 索引大小     
   VirSize.l      ; 索引大小    
   IdxAddr.l      ; 索引地址
   MaxIconSize.l  ; 最在图标大小
   CreateTime.l   ; 创建日期
   InitialTime.l  ; 初始化时间
   MD5.b[32]      ; ＭＤ5
   Reserve.l
EndStructure

;[设计文档]流文件头部结构
Structure __Binary_Design_Header
   Flags.l
   Version.l
   CRC32.l
   IdxCount.l
   DimIdxAddr.l[4]
EndStructure

;========= [模块类型] =========
;[模块类型]-引脚属性
Structure __Module_PinAttri
   PinsLabel$     ;引脚标签
   LinkTypes.w    ;接线类型   
   LinkModes.w    ;接线方式
   Direction.w    ;接线方向
   PinsGroup.w    ;引脚组
   PinsColor.l    ;引脚颜色
   MaxVoltage.f   ;最大电压    ;<<< 新增
   MinVoltage.f   ;最小电压    ;<<< 新增
   Reserve.l
EndStructure

   
;[模块类型]-引脚参数
Structure __Module_PinParam
   OffsetX.f      ;引脚相对位置
   OffsetY.f      ;引脚相对位置   
   OffsetW.f      ;引脚相对位置
   OffsetH.f      ;引脚相对位置
   PinDirection.w
   GroupType.b    ;编组类型                ;<<< 新增 V11
   IsSocket.b     ;是否是插孔              ;<<< 新增 V11
   GroupIndex.w   ;用于保存                ;<<< 新增 V11
   *pGroupParam.__Module_PinParam          ;<<< 新增 V11
   *pListPinAttri.__Module_PinAttri
   *pParentModule.__Module_BaseInfo
EndStructure

;[模块类型]-图像参数
Structure __Module_ImageInfo
   ImageID.l      ;模块图像ID
   ImageW.f       ;模块图像大小
   ImageH.f       ;模块图像大小
   ImageAddr.l
   ImageSize.l
   List ListPinParam.__Module_PinParam()
EndStructure

;[特效类型]-图像参数      ;<<< 新增
Structure __Module_EffectInfo
   ImageID.l      ;特效图像ID
   OffsetX.f
   OffsetY.f   
   ImageW.f       ;特效图像大小
   ImageH.f       ;特效图像大小
   ImageAddr.l
   ImageSize.l
   EffectType.w      
   EffectNote$
EndStructure



;[模块类型]基本信息结构
Structure __Module_BaseInfo
   ModuleGroup$      ;模块编组   
   ModuleTypes$      ;模块类型
   ModuleModel$      ;模块型号
   ModuleName$       ;模块名称
   ModuleNote$       ;模块说明
   ;==================
   ModuleIconID.l    ;模块图标ID
   MaxIconSize.l
   Resistance.f      ;电阻值           ;<<< 新增
   IsSymmetry.b      ;是否对称   
   IsInitial.b       ;是否初始化
   DimReserve.b[2] 
   List ListPinAttri.__Module_PinAttri()
   List ListEffect.__Module_EffectInfo()  ;<<< 新增
;    Array DimImage.__Module_ImageInfo(#Layer_Zoom_Count-1, #Object_Rotate_Count*2-1)  ;<<< 删除 
   DimImage.__Module_ImageInfo[#Object_Rotate_Count*2]    ;<<< 改动
EndStructure

;========= [主体结构] =========
; [模块类型]主结构,作为接口输出为:ModuleID
Structure __Module_MainInfo
   ModuleFlags$
   ModuleFileID.l
   ThreadID.l
   DesktopW.l
   DesktopH.l
   *pCallRegister    ;注册回调函数
   *pCallAddString   ;事件回调函数
   *pCallRightClick
   ThumbnailID.l
   List ListModule.__Module_BaseInfo()
   IsModuleInitial.b
   IsDisplayGrid.b
   DimReserve.b[2] 
EndStructure


;-[Global]
Global _EngineErrorCode.l

;-
;- ******** [模块设置] ******** 
;加载压缩文件
Procedure Module_LoadPack(*pMainModule.__Module_MainInfo, *pHeader.__Module_Header, *MemIndex)
   
   FileID = *pMainModule\ModuleFileID 
   *MemImage = AllocateMemory(*pHeader\MaxIconSize+1024)
   Pos = 0 
   PinsAttriSize = SizeOf(__Module_PinAttri)
   PinsParamSize = 4*2
   
   ModuleGroups$ = #Null$
   Dim DimTempParam.i(10)
   For k = 1 To *pHeader\IdxCount 
      *pModule.__Module_BaseInfo = AddElement(*pMainModule\ListModule())
      With *pModule
         Lenght       = PeekA(*MemIndex+Pos)                   : Pos+1 
         \ModuleTypes$= PeekS(*MemIndex+Pos, -1, #PB_Ascii)    : Pos+Lenght   
         Lenght       = PeekA(*MemIndex+Pos)                   : Pos+1 
         \ModuleGroup$= PeekS(*MemIndex+Pos, -1, #PB_Ascii)    : Pos+Lenght            
         Lenght       = PeekA(*MemIndex+Pos)                   : Pos+1 
         \ModuleName$ = PeekS(*MemIndex+Pos, -1, #PB_Ascii)    : Pos+Lenght   
         Lenght       = PeekA(*MemIndex+Pos)                   : Pos+1 
         \ModuleModel$= PeekS(*MemIndex+Pos, -1, #PB_Ascii)    : Pos+Lenght            
         Lenght       = PeekW(*MemIndex+Pos)                   : Pos+2 
         \ModuleNote$ = PeekS(*MemIndex+Pos, -1, #PB_Ascii)    : Pos+Lenght 
         \Resistance  = PeekF(*MemIndex+Pos)                   : Pos+4    ;<<< 新增 V11  
         \IsSymmetry  = PeekB(*MemIndex+Pos)                   : Pos+1 
         \MaxIconSize = PeekL(*MemIndex+Pos)                   : Pos+4
         Debug "[Module] ModuleTypes$ = " + \ModuleTypes$, #DebugLevel_Module
      EndWith
      
      ;引脚属性
      CountPins = PeekW(*MemIndex+Pos)                         : Pos+2   
      For i = 1 To CountPins
         *pPinsAttri.__Module_PinAttri = AddElement(*pModule\ListPinAttri())
         Lenght                 = PeekA(*MemIndex+Pos)                  : Pos+1 
         *pPinsAttri\PinsLabel$ = PeekS(*MemIndex+Pos, -1, #PB_Ascii)   : Pos+Lenght   
         *pPinsAttri\LinkTypes  = PeekW(*MemIndex+Pos)                  : Pos+2         
         *pPinsAttri\LinkModes  = PeekW(*MemIndex+Pos)                  : Pos+2
         *pPinsAttri\Direction  = PeekW(*MemIndex+Pos)                  : Pos+2
         *pPinsAttri\PinsGroup  = PeekW(*MemIndex+Pos)                  : Pos+2
         *pPinsAttri\PinsColor  = PeekL(*MemIndex+Pos)                  : Pos+4
         *pPinsAttri\MaxVoltage = PeekF(*MemIndex+Pos)                  : Pos+4    ;<<< 新增 V11  
         *pPinsAttri\MinVoltage = PeekF(*MemIndex+Pos)                  : Pos+4    ;<<< 新增 V11  
      Next 
;       Debug "[Module] CountPins = " + Str(CountPins), #DebugLevel_Module
      
      ;模块图标
      IconAddr = PeekL(*MemIndex+Pos) : Pos+4
      IconSize = PeekL(*MemIndex+Pos) : Pos+4
      FileSeek(FileID, IconAddr)
      ReadData(FileID, *MemImage, IconSize)
      *pDecrypt.long = *MemImage : *pDecrypt\l ! IconAddr            ;<--- 解密
      
      *pModule\ModuleIconID = CatchImage(#PB_Any, *MemImage) 

      If IsImage(*pModule\ModuleIconID) = #Null
         FreeMemory(*MemIndex)
         FreeMemory(*MemImage)
         _EngineErrorCode = #Module_Error_2007 ; 文件数据受损
         ProcedureReturn #Null
      EndIf 

      FillMemory(*MemImage, IconSize)

      *pDimImage.__Module_ImageInfo = *pModule\DimImage[0]
      With *pDimImage
         \ImageAddr = PeekL(*MemIndex+Pos) : Pos+4
         \ImageSize = PeekL(*MemIndex+Pos) : Pos+4
         \ImageW    = PeekW(*MemIndex+Pos) : Pos+2
         \ImageH    = PeekW(*MemIndex+Pos) : Pos+2
      EndWith
      
      ;引脚属性
      CountParam = PeekW(*MemIndex+Pos)                         : Pos+2  ;<<<< 新增 V11 
      ReDim DimTempParam.i(CountParam)
      For i = 1 To CountParam
         *pPinParam.__Module_PinParam = AddElement(*pDimImage\ListPinParam())
         DimTempParam(i) = *pPinParam
         With *pPinParam
            \OffsetX    = PeekW(*MemIndex+Pos) : Pos+2      ;引脚相对位置
            \OffsetY    = PeekW(*MemIndex+Pos) : Pos+2      ;引脚相对位置   
            \OffsetW    = PeekW(*MemIndex+Pos) : Pos+2      ;引脚相对位置
            \OffsetH    = PeekW(*MemIndex+Pos) : Pos+2      ;引脚相对位置
            
            ;<<< 新增 V11{
            \IsSocket   = PeekB(*MemIndex+Pos)  : Pos+1      
            \GroupType  = PeekB(*MemIndex+Pos)  : Pos+1     
            \GroupIndex = PeekW(*MemIndex+Pos)  : Pos+2  
            If \GroupType = #GroupType_Element And \GroupIndex
               \pGroupParam = DimTempParam(\GroupIndex)
            EndIf                                                          
            ;<<< 新增 V11}
            
            \pListPinAttri  = SelectElement(*pModule\ListPinAttri(), \GroupIndex-1)
            \PinDirection   = \pListPinAttri\Direction
            \pParentModule  = *pModule
         EndWith
      Next 
      
      CountEffects = PeekW(*MemIndex+Pos) : Pos+2                       ;<<<< 新增 V11 {
;       Debug "[Module] CountEffects = " + Str(CountEffects), #DebugLevel_Module
      For x = 1 To CountEffects
         *pEffect.__Module_EffectInfo = AddElement(*pModule\ListEffect())
         With *pEffect
            \ImageAddr  = PeekL(*MemIndex+Pos) : Pos+4
            \ImageSize  = PeekL(*MemIndex+Pos) : Pos+4
            \OffsetX    = PeekW(*MemIndex+Pos) : Pos+2
            \OffsetY    = PeekW(*MemIndex+Pos) : Pos+2
            \ImageW     = PeekW(*MemIndex+Pos) : Pos+2
            \ImageH     = PeekW(*MemIndex+Pos) : Pos+2
            \EffectType = PeekW(*MemIndex+Pos) : Pos+2
            Lenght      = PeekA(*MemIndex+Pos)                   : Pos+1 
            \EffectNote$= PeekS(*MemIndex+Pos, -1, #PB_Ascii)    : Pos+Lenght  
         EndWith
      Next                                                              ;<<<< 新增 V11 }
   Next 
   FreeMemory(*MemIndex)
   FreeMemory(*MemImage)
   ProcedureReturn #True
EndProcedure

;加载数据文件
Procedure Module_LoadData(*pMainModule.__Module_MainInfo, *pHeader.__Module_Header, *MemIndex)
   
   FileID = *pMainModule\ModuleFileID 
   *MemImage = AllocateMemory(*pHeader\MaxIconSize+1024)
   Pos = 0 
   PinsAttriSize = SizeOf(__Module_PinAttri)
   PinsParamSize = 4*2
   ModuleGroups$ = #Null$
   Dim DimTempParam.i(10)
   For k = 1 To *pHeader\IdxCount
      *pModule.__Module_BaseInfo = AddElement(*pMainModule\ListModule())
      With *pModule
         Lenght       = PeekA(*MemIndex+Pos)                   : Pos+1 
         \ModuleTypes$= PeekS(*MemIndex+Pos, -1, #PB_Ascii)    : Pos+Lenght   
         Lenght       = PeekA(*MemIndex+Pos)                   : Pos+1 
         \ModuleGroup$= PeekS(*MemIndex+Pos, -1, #PB_Ascii)    : Pos+Lenght            
         Lenght       = PeekA(*MemIndex+Pos)                   : Pos+1 
         \ModuleName$ = PeekS(*MemIndex+Pos, -1, #PB_Ascii)    : Pos+Lenght   
         Lenght       = PeekA(*MemIndex+Pos)                   : Pos+1 
         \ModuleModel$= PeekS(*MemIndex+Pos, -1, #PB_Ascii)    : Pos+Lenght            
         Lenght       = PeekW(*MemIndex+Pos)                   : Pos+2 
         \ModuleNote$ = PeekS(*MemIndex+Pos, -1, #PB_Ascii)    : Pos+Lenght 
         \Resistance  = PeekF(*MemIndex+Pos)                   : Pos+4    ;<<< 新增 V11  
         \IsSymmetry  = PeekB(*MemIndex+Pos)                   : Pos+1 
         \MaxIconSize = PeekL(*MemIndex+Pos)                   : Pos+4
         Debug "[Module] ModuleTypes$ = " + \ModuleTypes$, #DebugLevel_Module
         Debug "[Module] ModuleTypes$ = " + \ModuleTypes$
      EndWith

      ;引脚属性

      PinsCount = PeekW(*MemIndex+Pos)                         : Pos+2 
      For i = 1 To PinsCount
         *pPinsAttri.__Module_PinAttri = AddElement(*pModule\ListPinAttri())
         Lenght                 = PeekA(*MemIndex+Pos)                  : Pos+1 
         *pPinsAttri\PinsLabel$ = PeekS(*MemIndex+Pos, -1, #PB_Ascii)   : Pos+Lenght   
         *pPinsAttri\LinkTypes  = PeekW(*MemIndex+Pos)                  : Pos+2         
         *pPinsAttri\LinkModes  = PeekW(*MemIndex+Pos)                  : Pos+2
         *pPinsAttri\Direction  = PeekW(*MemIndex+Pos)                  : Pos+2
         *pPinsAttri\PinsGroup  = PeekW(*MemIndex+Pos)                  : Pos+2
         *pPinsAttri\PinsColor  = PeekL(*MemIndex+Pos)                  : Pos+4
         *pPinsAttri\MaxVoltage = PeekF(*MemIndex+Pos)                  : Pos+4    ;<<< 新增 V11  
         *pPinsAttri\MinVoltage = PeekF(*MemIndex+Pos)                  : Pos+4    ;<<< 新增 V11 
      Next 

      ;模块图标
      IconAddr = PeekL(*MemIndex+Pos) : Pos+4
      IconSize = PeekL(*MemIndex+Pos) : Pos+4
      FileSeek(FileID, IconAddr)
      ReadData(FileID, *MemImage, IconSize)
      *pDecrypt.long = *MemImage : *pDecrypt\l ! IconAddr   ;<--- 解密
      *pModule\ModuleIconID = CatchImage(#PB_Any, *MemImage) 

      If IsImage(*pModule\ModuleIconID) = #Null
         FreeMemory(*MemIndex)
         FreeMemory(*MemImage)
         _EngineErrorCode = #Module_Error_2007 ; 文件数据受损
         ProcedureReturn #Null
      EndIf 

      FillMemory(*MemImage, IconSize)
      
      For RotateIdx = 0 To #Object_Rotate_Count-1
         *pDimImage.__Module_ImageInfo = *pModule\DimImage[RotateIdx]
         With *pDimImage
            \ImageAddr = PeekL(*MemIndex+Pos) : Pos+4
            \ImageSize = PeekL(*MemIndex+Pos) : Pos+4
            \ImageW    = PeekF(*MemIndex+Pos) : Pos+4
            \ImageH    = PeekF(*MemIndex+Pos) : Pos+4
         EndWith
         
         CountParam = PeekW(*MemIndex+Pos)                  : Pos+2  ;<<<< 新增 V11 
         ReDim DimTempParam.i(CountParam)
         For x = 1 To CountParam
            *pPinParam.__Module_PinParam = AddElement(*pDimImage\ListPinParam())
            DimTempParam(x) = *pPinParam
            With *pPinParam
               \OffsetX = PeekF(*MemIndex+Pos)          : Pos+4      ;引脚相对位置
               \OffsetY = PeekF(*MemIndex+Pos)          : Pos+4      ;引脚相对位置   
               \OffsetW = PeekF(*MemIndex+Pos)          : Pos+4      ;引脚相对位置
               \OffsetH = PeekF(*MemIndex+Pos)          : Pos+4      ;引脚相对位置
               \PinDirection = PeekL(*MemIndex+Pos)     : Pos+4      ;
               ;<<< 新增 V11{
               \IsSocket   = PeekB(*MemIndex+Pos) : Pos+1      
               \GroupType  = PeekB(*MemIndex+Pos) : Pos+1     
               \GroupIndex = PeekW(*MemIndex+Pos) : Pos+2  
               If \GroupType = #GroupType_Element ;And \GroupIndex
                  \pGroupParam = DimTempParam(\GroupIndex)
;                   Debug Str(\GroupIndex) + ":" + Str(\pGroupParam)
               EndIf                                                            
               ;<<< 新增 V11}
               
               \pListPinAttri  = SelectElement(*pModule\ListPinAttri(), \GroupIndex-1)
               \pParentModule  = *pModule
            EndWith
         Next 
      Next 
      If *pModule\IsSymmetry
         For RotateIdx = 0 To #Object_Rotate_Count-1
            *pDimImage.__Module_ImageInfo = *pModule\DimImage[RotateIdx+#Object_HorizontalFlip_180]
            With *pDimImage
               \ImageAddr = PeekL(*MemIndex+Pos) : Pos+4
               \ImageSize = PeekL(*MemIndex+Pos) : Pos+4
               \ImageW    = PeekF(*MemIndex+Pos) : Pos+4
               \ImageH    = PeekF(*MemIndex+Pos) : Pos+4
            EndWith
            
            CountParam = PeekW(*MemIndex+Pos)                  : Pos+2  ;<<<< 新增 V11 
            ReDim DimTempParam.i(CountParam)
            For x = 1 To CountParam
               *pPinParam.__Module_PinParam = AddElement(*pDimImage\ListPinParam())
               DimTempParam(x) = *pPinParam
               With *pPinParam
                  \OffsetX = PeekF(*MemIndex+Pos)          : Pos+4      ;引脚相对位置
                  \OffsetY = PeekF(*MemIndex+Pos)          : Pos+4      ;引脚相对位置   
                  \OffsetW = PeekF(*MemIndex+Pos)          : Pos+4      ;引脚相对位置
                  \OffsetH = PeekF(*MemIndex+Pos)          : Pos+4      ;引脚相对位置
                  \PinDirection = PeekL(*MemIndex+Pos)     : Pos+4      ;
                  
                  ;<<< 新增 V11{
                  \IsSocket   = PeekB(*MemIndex+Pos) : Pos+1      
                  \GroupType  = PeekB(*MemIndex+Pos) : Pos+1     
                  \GroupIndex = PeekW(*MemIndex+Pos) : Pos+2  
                  If \GroupType = #GroupType_Element And \GroupIndex
                     \pGroupParam = DimTempParam(\GroupIndex)
                  EndIf                                                          
                  ;<<< 新增 V11}
            
                  \pListPinAttri  = SelectElement(*pModule\ListPinAttri(), \GroupIndex-1)
                  \pParentModule  = *pModule
               EndWith
            Next 
         Next 
      EndIf 
      
      CountEffects = PeekW(*MemIndex+Pos) : Pos+2                       ;<<<< 新增 V11 {
;       Debug "[Module] CountEffects = " + Str(CountEffects), #DebugLevel_Module
      For x = 1 To CountEffects
         *pEffect.__Module_EffectInfo = AddElement(*pModule\ListEffect())
         With *pEffect
            \ImageAddr  = PeekL(*MemIndex+Pos) : Pos+4
            \ImageSize  = PeekL(*MemIndex+Pos) : Pos+4
            \OffsetX    = PeekW(*MemIndex+Pos) : Pos+2
            \OffsetY    = PeekW(*MemIndex+Pos) : Pos+2
            \ImageW     = PeekW(*MemIndex+Pos) : Pos+2
            \ImageH     = PeekW(*MemIndex+Pos) : Pos+2
            \EffectType = PeekW(*MemIndex+Pos) : Pos+2
            Lenght      = PeekA(*MemIndex+Pos)                   : Pos+1 
            \EffectNote$= PeekS(*MemIndex+Pos, -1, #PB_Ascii)    : Pos+Lenght  
         EndWith
      Next                                                              ;<<<< 新增 V11 }
      
   Next 
   FreeMemory(*MemIndex)
   FreeMemory(*MemImage)
   ProcedureReturn #True
EndProcedure

;-
;获取旋转的方向
Procedure.w Module_GetDirection(InitDirection, Rotate)
   Direction = InitDirection << Rotate
   If Direction > 8 
      Direction = (Direction >> 4) | (Direction & $0F)
   EndIf
   ProcedureReturn Direction   
EndProcedure

;解压模块信息-旋转90度
Procedure Module_Unpack_090(*pModule.__Module_BaseInfo, *pDimImage.__Module_ImageInfo, ImageH, ImageW, HorizFlip)
   *pCopyRotate.__Module_ImageInfo = *pModule\DimImage[#Object_Rotate_090+HorizFlip]
   *pCopyRotate\ImageW =  *pDimImage\ImageH
   *pCopyRotate\ImageH =  *pDimImage\ImageW
   Dim DimTempParam.i(ListSize(*pDimImage\ListPinParam()))
   ForEach *pDimImage\ListPinParam()
      *pCopyPins.__Module_PinParam = AddElement(*pCopyRotate\ListPinParam())
      GroupIndex+1 : DimTempParam(GroupIndex) = *pCopyPins
      With *pDimImage\ListPinParam()
         *pCopyPins\OffsetX = *pCopyRotate\ImageW-\OffsetY    ;重新计算引脚相对位置
         *pCopyPins\OffsetY = \OffsetX     ;重新计算引脚相对位置
         *pCopyPins\OffsetW = -\OffsetH    ;重新计算引脚相对位置
         *pCopyPins\OffsetH = -\OffsetW    ;重新计算引脚相对位置
         
         ;<<< 新增 V11 {
         *pCopyPins\GroupType   = \GroupType         
         *pCopyPins\IsSocket    = \IsSocket    
         *pCopyPins\GroupIndex  = \GroupIndex 
         If \GroupType = #GroupType_Element And \GroupIndex
            *pCopyPins\pGroupParam = DimTempParam(\GroupIndex)
         EndIf  

         ;<<< 新增 V11 }  

         *pCopyPins\pListPinAttri = \pListPinAttri
         *pCopyPins\PinDirection  = Module_GetDirection(\PinDirection, #Object_Rotate_090) 
         *pCopyPins\pParentModule = \pParentModule
      EndWith
   Next 
   *pCopyRotate\ImageID = CreateImage(#PB_Any, ImageH, ImageW, 32, #PB_Image_Transparent)
   If StartVectorDrawing(ImageVectorOutput(*pCopyRotate\ImageID))
      RotateCoordinates(0, 0, 090) 
      MovePathCursor(0, -ImageH)   
      DrawVectorImage(ImageID(*pDimImage\ImageID))
      StopVectorDrawing()
   EndIf 
EndProcedure

;解压模块信息-旋转180度
Procedure Module_Unpack_180(*pModule.__Module_BaseInfo, *pDimImage.__Module_ImageInfo, ImageH, ImageW, HorizFlip)
   *pCopyRotate.__Module_ImageInfo = *pModule\DimImage[#Object_Rotate_180+HorizFlip]
   *pCopyRotate\ImageW =  *pDimImage\ImageW
   *pCopyRotate\ImageH =  *pDimImage\ImageH
   Dim DimTempParam.i(ListSize(*pDimImage\ListPinParam()))
   ForEach *pDimImage\ListPinParam()
      *pCopyPins.__Module_PinParam = AddElement(*pCopyRotate\ListPinParam())
      GroupIndex+1 : DimTempParam(GroupIndex) = *pCopyPins
      With *pDimImage\ListPinParam()
         *pCopyPins\OffsetX  = *pCopyRotate\ImageW-\OffsetX   ;重新计算引脚相对位置
         *pCopyPins\OffsetY  = *pCopyRotate\ImageH-\OffsetY   ;重新计算引脚相对位置
         *pCopyPins\OffsetW  = -\OffsetW    ;引脚相对位置
         *pCopyPins\OffsetH  = -\OffsetH    ;引脚相对位置
         
         ;<<< 新增 V11 {
         *pCopyPins\GroupType   = \GroupType         
         *pCopyPins\IsSocket    = \IsSocket    
         *pCopyPins\GroupIndex  = \GroupIndex 
         If \GroupType = #GroupType_Element And \GroupIndex
            *pCopyPins\pGroupParam = DimTempParam(\GroupIndex)
         EndIf      
         ;<<< 新增 V11 }  
         
         *pCopyPins\pListPinAttri = \pListPinAttri
         *pCopyPins\PinDirection  = Module_GetDirection(\PinDirection, #Object_Rotate_180)  
         *pCopyPins\pParentModule = \pParentModule
      EndWith
   Next 
   *pCopyRotate\ImageID = CreateImage(#PB_Any, ImageW, ImageH, 32, #PB_Image_Transparent)
   If StartVectorDrawing(ImageVectorOutput(*pCopyRotate\ImageID))
      RotateCoordinates(0, 0, 180) 
      MovePathCursor(-ImageW, -ImageH)
      DrawVectorImage(ImageID(*pDimImage\ImageID))
      StopVectorDrawing()
   EndIf 
EndProcedure

;解压模块信息-旋转270度
Procedure Module_Unpack_270(*pModule.__Module_BaseInfo, *pDimImage.__Module_ImageInfo, ImageH, ImageW, HorizFlip)
   *pCopyRotate.__Module_ImageInfo = *pModule\DimImage[#Object_Rotate_270+HorizFlip]
   *pCopyRotate\ImageW =  *pDimImage\ImageH
   *pCopyRotate\ImageH =  *pDimImage\ImageW
   Dim DimTempParam.i(ListSize(*pDimImage\ListPinParam()))
   ForEach *pDimImage\ListPinParam()
      *pCopyPins.__Module_PinParam = AddElement(*pCopyRotate\ListPinParam())
      GroupIndex+1 : DimTempParam(GroupIndex) = *pCopyPins
      With *pDimImage\ListPinParam()
         *pCopyPins\OffsetX  = \OffsetY    ;引脚相对位置
         *pCopyPins\OffsetY  = *pCopyRotate\ImageH-\OffsetX    ;引脚相对位置
         *pCopyPins\OffsetW  = \OffsetH    ;重新计算引脚相对位置
         *pCopyPins\OffsetH  = \OffsetW    ;重新计算引脚相对位置
         
         ;<<< 新增 V11 {
         *pCopyPins\GroupType   = \GroupType         
         *pCopyPins\IsSocket    = \IsSocket    
         *pCopyPins\GroupIndex  = \GroupIndex 
         If \GroupType = #GroupType_Element And \GroupIndex
            *pCopyPins\pGroupParam = DimTempParam(\GroupIndex)
         EndIf      
         ;<<< 新增 V11 }  
         
         *pCopyPins\pListPinAttri = \pListPinAttri
         *pCopyPins\PinDirection  = Module_GetDirection(\PinDirection, #Object_Rotate_270)                
         *pCopyPins\pParentModule = \pParentModule
      EndWith
   Next 
   *pCopyRotate\ImageID = CreateImage(#PB_Any, ImageH, ImageW, 32, #PB_Image_Transparent)
   If StartVectorDrawing(ImageVectorOutput(*pCopyRotate\ImageID))
      RotateCoordinates(0, 0, 270) 
      MovePathCursor(-ImageW, 0)   
      DrawVectorImage(ImageID(*pDimImage\ImageID))
      StopVectorDrawing()
   EndIf 
EndProcedure

;解压模块信息-翻转图像
Procedure Module_HorizontalFlip(*pModule.__Module_BaseInfo, *pDimImage.__Module_ImageInfo, ImageH, ImageW)
   *pCopyRotate.__Module_ImageInfo = *pModule\DimImage[#Object_Rotate_000+#Object_HorizontalFlip_180]
   *pCopyRotate\ImageW =  *pDimImage\ImageW
   *pCopyRotate\ImageH =  *pDimImage\ImageH
   Dim DimTempParam.i(ListSize(*pDimImage\ListPinParam()))
   ForEach *pDimImage\ListPinParam()
      *pCopyPins.__Module_PinParam = AddElement(*pCopyRotate\ListPinParam())
      GroupIndex+1 : DimTempParam(GroupIndex) = *pCopyPins
      With *pDimImage\ListPinParam()
         *pCopyPins\OffsetX  = \OffsetX   ;重新计算引脚相对位置
         *pCopyPins\OffsetY  = \OffsetY   ;重新计算引脚相对位置
         *pCopyPins\OffsetW  = \OffsetW    ;引脚相对位置
         *pCopyPins\OffsetH  = \OffsetH    ;引脚相对位置
         
         ;<<< 新增 V11 {
         *pCopyPins\GroupType   = \GroupType         
         *pCopyPins\IsSocket    = \IsSocket    
         *pCopyPins\GroupIndex  = \GroupIndex 
         If \GroupType = #GroupType_Element And \GroupIndex
            *pCopyPins\pGroupParam = DimTempParam(\GroupIndex)
         EndIf      
         ;<<< 新增 V11 }  
         
         *pCopyPins\pListPinAttri = \pListPinAttri
         *pCopyPins\PinDirection  = Module_GetDirection(\PinDirection, #Object_Rotate_000)  
         *pCopyPins\pParentModule = \pParentModule
      EndWith
   Next 
   *pCopyRotate\ImageID = CreateImage(#PB_Any, ImageW, ImageH, 32, #PB_Image_Transparent)
   If StartVectorDrawing(ImageVectorOutput(*pCopyRotate\ImageID))
      FlipCoordinatesX(0) 
      MovePathCursor(-ImageW, 0)   
      DrawVectorImage(ImageID(*pDimImage\ImageID))
      StopVectorDrawing()
   EndIf 
   ProcedureReturn *pCopyRotate
EndProcedure

;解压模块信息
Procedure Module_Unpack(*pMainModule.__Module_MainInfo, *pModule.__Module_BaseInfo)

   If IsFile(*pMainModule\ModuleFileID) = #Null 
      _EngineErrorCode = #Module_Error_2008  ;文件被占用
      ProcedureReturn #Null
   EndIf       
   
   *pDimImage.__Module_ImageInfo = *pModule\DimImage[0]
   If *pDimImage\ImageSize = #Null 
      _EngineErrorCode = #Module_Error_2009  ;文件数据受损
      ProcedureReturn #Null
   EndIf 
   

   *MemImage = AllocateMemory(*pModule\MaxIconSize+1000)
   ForEach *pModule\ListEffect()                                        ;<<< 新增 V11 {
      *pEffect.__Module_EffectInfo = *pModule\ListEffect()
      FileSeek(*pMainModule\ModuleFileID, *pEffect\ImageAddr)        
      ReadData(*pMainModule\ModuleFileID, *MemImage, *pEffect\ImageSize)
      *pDecrypt.long = *MemImage : *pDecrypt\l ! *pEffect\ImageAddr    ;<--- 解密
      
      *pEffect\ImageID = CatchImage(#PB_Any, *MemImage)
      If IsImage(*pEffect\ImageID) = #Null : 
         _EngineErrorCode = #Module_Error_2011  ;文件数据受损
         Debug "[Module] Error_2011 = " + #Module_Error_2011, #DebugLevel_Module
         ProcedureReturn #Null
      EndIf 
   Next                                                                 ;<<< 新增 V11 }   
   
   
   *pDimImage.__Module_ImageInfo = *pModule\DimImage[0]
   If *pDimImage\ImageSize = #Null 
      FreeMemory(*MemImage)
      _EngineErrorCode = #Module_Error_2010  ;文件数据受损
      Debug "[Module] Error_2010 = " + #Module_Error_2010, #DebugLevel_Module
      ProcedureReturn #Null
   EndIf 
   
   FileSeek(*pMainModule\ModuleFileID, *pDimImage\ImageAddr)
   ReadData(*pMainModule\ModuleFileID, *MemImage, *pDimImage\ImageSize)
   *pDecrypt.long = *MemImage : *pDecrypt\l ! *pDimImage\ImageAddr    ;<--- 解密
   
   *pDimImage\ImageID = CatchImage(#PB_Any, *MemImage)
   If IsImage(*pDimImage\ImageID) = #Null : 
      _EngineErrorCode = #Module_Error_2011  ;文件数据受损
      ProcedureReturn #Null
   EndIf 
   
   
   ImageW = ImageWidth (*pDimImage\ImageID)
   ImageH = ImageHeight(*pDimImage\ImageID)
   Module_Unpack_090(*pModule, *pDimImage, ImageH, ImageW, #Null)  ;旋转90°
   Module_Unpack_180(*pModule, *pDimImage, ImageH, ImageW, #Null)  ;旋转180°
   Module_Unpack_270(*pModule, *pDimImage, ImageH, ImageW, #Null)  ;旋转270°
   
   If *pModule\IsSymmetry = #True
      *pDimImage = Module_HorizontalFlip(*pModule, *pDimImage, ImageH, ImageW) ;水平翻转180°
      Module_Unpack_090(*pModule, *pDimImage, ImageH, ImageW, #Object_HorizontalFlip_180)  ;旋转90°
      Module_Unpack_180(*pModule, *pDimImage, ImageH, ImageW, #Object_HorizontalFlip_180)  ;旋转180°
      Module_Unpack_270(*pModule, *pDimImage, ImageH, ImageW, #Object_HorizontalFlip_180)  ;旋转270°  
   EndIf 
   FreeMemory(*MemImage)
   
EndProcedure

;-
;初始化压缩文件
Procedure Module_Register(*pMainModule.__Module_MainInfo)
   *pCallRegister = *pMainModule\pCallRegister
   If *pCallRegister = #Null 
      _EngineErrorCode = #Module_Error_2012  ;文件初始化失败
      ProcedureReturn #Null
   EndIf 
   Count = ListSize(*pMainModule\ListModule()) * 2 + 1
   
   ;解压[模块类型]所需要用到的图像
   ForEach *pMainModule\ListModule()
      *pModule.__Module_BaseInfo = *pMainModule\ListModule()
      If *pCallRegister 
         Index + 1
         Note$ = "初始化: " + *pModule\ModuleTypes$         
         CallFunctionFast(*pCallRegister, Index, Count, @Note$) 
      EndIf 
      Module_Unpack(*pMainModule, *pModule)
   Next 
   
   ;重新组建[模块设置]文件
   FileID = *pMainModule\ModuleFileID
   FileSize = Lof(FileID)
   ;加载资源头部
   HeaderSize = SizeOf(__Module_Header)
   Header.__Module_Header
   FileSeek(FileID, 0)
   ReadData(FileID, @Header, HeaderSize)
   
   *MemData  = AllocateMemory(FileSize*100)
   *MemIndex = AllocateMemory($10000)
   *MemPack  = AllocateMemory($10000)

   FileSeek(FileID, 0)
   ReadData(FileID, *MemData, Header\HeadSize)
   CloseFile(FileID)
   *pMainModule\ModuleFileID = #Null
   
   *pHeader.__Module_Header = *MemData
   Posd = Header\HeadSize
   Posi = 0
   PinsAttriSize = SizeOf(__Module_PinAttri)
   PinsParamSize = 4*2
   ForEach *pMainModule\ListModule()
      *pModule.__Module_BaseInfo = *pMainModule\ListModule()
      If *pCallRegister
         Index + 1
         Note$ = "重组: " + *pModule\ModuleTypes$
         CallFunctionFast(*pCallRegister, Index, Count, @Note$)
      EndIf 
      With *pModule
         Lenght = StringByteLength(\ModuleTypes$, #PB_Ascii)+1
         PokeA(*MemIndex+Posi, Lenght)                            : Posi+1 
         PokeS(*MemIndex+Posi, \ModuleTypes$, -1, #PB_Ascii)      : Posi+Lenght
         
         Lenght = StringByteLength(\ModuleGroup$, #PB_Ascii)+1
         PokeA(*MemIndex+Posi, Lenght)                            : Posi+1 
         PokeS(*MemIndex+Posi, \ModuleGroup$, -1, #PB_Ascii)      : Posi+Lenght 
         
         Lenght = StringByteLength(\ModuleName$, #PB_Ascii)+1
         PokeA(*MemIndex+Posi, Lenght)                            : Posi+1 
         PokeS(*MemIndex+Posi, \ModuleName$, -1, #PB_Ascii)       : Posi+Lenght      
         
         Lenght = StringByteLength(\ModuleModel$, #PB_Ascii)+1
         PokeA(*MemIndex+Posi, Lenght)                            : Posi+1 
         PokeS(*MemIndex+Posi, \ModuleModel$, -1, #PB_Ascii)      : Posi+Lenght             
         
         Lenght = StringByteLength(\ModuleNote$, #PB_Ascii)+1
         PokeW(*MemIndex+Posi, Lenght)                            : Posi+2 
         PokeS(*MemIndex+Posi, \ModuleNote$, -1, #PB_Ascii)       : Posi+Lenght              
         
         PokeF(*MemIndex+Posi, \Resistance)                       : Posi+4    ;<<< 新增 V11
         PokeB(*MemIndex+Posi, \IsSymmetry)                       : Posi+1  
         *pMemMaxSize = *MemIndex+Posi  : Posi+4  ;加载图片,最大的Size
         
         ;引脚属性
         PinsCount = ListSize(\ListPinAttri())
         PokeW(*MemIndex+Posi, PinsCount)                         : Posi+2
         
         ForEach \ListPinAttri()
            Lenght = StringByteLength(\ListPinAttri()\PinsLabel$, #PB_Ascii)+1
            PokeA(*MemIndex+Posi, Lenght)                                       : Posi+1 
            PokeS(*MemIndex+Posi, \ListPinAttri()\PinsLabel$, -1, #PB_Ascii)    : Posi+Lenght    
            PokeW(*MemIndex+Posi, \ListPinAttri()\LinkTypes)     : Posi+2             
            PokeW(*MemIndex+Posi, \ListPinAttri()\LinkModes)     : Posi+2 
            PokeW(*MemIndex+Posi, \ListPinAttri()\Direction)     : Posi+2 
            PokeW(*MemIndex+Posi, \ListPinAttri()\PinsGroup)     : Posi+2 
            PokeL(*MemIndex+Posi, \ListPinAttri()\PinsColor)     : Posi+4 
            PokeF(*MemIndex+Posi, \ListPinAttri()\MaxVoltage)    : Posi+4    ;<<< 新增 V11 
            PokeF(*MemIndex+Posi, \ListPinAttri()\MinVoltage)    : Posi+4    ;<<< 新增 V11 
         Next 

         ;ICON
         *pMemImage = EncodeImage(\ModuleIconID, #PB_ImagePlugin_PNG)
         *pEncrypt.long = *pMemImage : *pEncrypt\l ! Posd      ;<--- 加密
         ImageSize  = MemorySize(*pMemImage)
         PokeL(*MemIndex+Posi, Posd)                              : Posi+4  
         PokeL(*MemIndex+Posi, ImageSize)                         : Posi+4  
         CopyMemory(*pMemImage, *MemData+Posd, ImageSize)         : Posd+ImageSize+1
         FreeMemory(*pMemImage)
      EndWith
      

      MaxSizeValue = 0
      For RotateIdx = 0 To #Object_Rotate_Count-1
         *pDimImage.__Module_ImageInfo = *pModule\DimImage[RotateIdx]
         With *pDimImage
            *pMemImage = EncodeImage(\ImageID, #PB_ImagePlugin_PNG)
            *pEncrypt.long = *pMemImage : *pEncrypt\l ! Posd    ;<--- 加密
            \ImageSize = MemorySize(*pMemImage)
            \ImageAddr = Posd
            If MaxSizeValue < \ImageSize : MaxSizeValue = \ImageSize : EndIf 
            PokeL(*MemIndex+Posi, \ImageAddr)              : Posi+4
            PokeL(*MemIndex+Posi, \ImageSize)              : Posi+4
            PokeF(*MemIndex+Posi, \ImageW)                 : Posi+4
            PokeF(*MemIndex+Posi, \ImageH)                 : Posi+4                
            FreeImage(\ImageID)
            ;数据块: {__Module_PinsParam + 图像数据}[4]
            CountParam = ListSize(\ListPinParam())                               ;<<< 新增 V11
            PokeW(*MemIndex+Posi, CountParam)                        : Posi+2    ;<<< 新增 V11
            ForEach \ListPinParam()
               PokeF(*MemIndex+Posi, \ListPinParam()\OffsetX)        : Posi+4
               PokeF(*MemIndex+Posi, \ListPinParam()\OffsetY)        : Posi+4
               PokeF(*MemIndex+Posi, \ListPinParam()\OffsetW)        : Posi+4
               PokeF(*MemIndex+Posi, \ListPinParam()\OffsetH)        : Posi+4
               PokeL(*MemIndex+Posi, \ListPinParam()\PinDirection)   : Posi+4
               
               PokeA(*MemIndex+Posi, \ListPinParam()\IsSocket)   : Posi+1    ;<<< 新增 V11
               PokeA(*MemIndex+Posi, \ListPinParam()\GroupType)  : Posi+1    ;<<< 新增 V11    
               PokeW(*MemIndex+Posi, \ListPinParam()\GroupIndex) : Posi+2    ;<<< 新增 V11   
            Next                                                                             
            CopyMemory(*pMemImage, *MemData+Posd, \ImageSize)         : Posd+\ImageSize+1
            FreeMemory(*pMemImage)
         EndWith
      Next 
      If *pModule\IsSymmetry
         For RotateIdx = 0 To #Object_Rotate_Count-1
            *pDimImage.__Module_ImageInfo = *pModule\DimImage[RotateIdx+#Object_HorizontalFlip_180]
            With *pDimImage
               *pMemImage = EncodeImage(\ImageID, #PB_ImagePlugin_PNG)
               *pEncrypt.long = *pMemImage : *pEncrypt\l ! Posd    ;<--- 加密
               \ImageSize = MemorySize(*pMemImage)
               \ImageAddr = Posd
               If MaxSizeValue < \ImageSize : MaxSizeValue = \ImageSize : EndIf 
               PokeL(*MemIndex+Posi, \ImageAddr)              : Posi+4
               PokeL(*MemIndex+Posi, \ImageSize)              : Posi+4
               PokeF(*MemIndex+Posi, \ImageW)                 : Posi+4
               PokeF(*MemIndex+Posi, \ImageH)                 : Posi+4             
               FreeImage(\ImageID)
               ;数据块: {__Module_PinsParam + 图像数据}[4]
               CountParam = ListSize(\ListPinParam())                               ;<<< 新增 V11
               PokeW(*MemIndex+Posi, CountParam)                        : Posi+2    ;<<< 新增 V11
               ForEach \ListPinParam()
                  PokeF(*MemIndex+Posi, \ListPinParam()\OffsetX)        : Posi+4
                  PokeF(*MemIndex+Posi, \ListPinParam()\OffsetY)        : Posi+4
                  PokeF(*MemIndex+Posi, \ListPinParam()\OffsetW)        : Posi+4
                  PokeF(*MemIndex+Posi, \ListPinParam()\OffsetH)        : Posi+4
                  PokeL(*MemIndex+Posi, \ListPinParam()\PinDirection)   : Posi+4  
                  
                  PokeA(*MemIndex+Posi, \ListPinParam()\IsSocket)   : Posi+1    ;<<< 新增 V11
                  PokeA(*MemIndex+Posi, \ListPinParam()\GroupType)  : Posi+1    ;<<< 新增 V11    
                  PokeW(*MemIndex+Posi, \ListPinParam()\GroupIndex) : Posi+2    ;<<< 新增 V11  
               Next 
               CopyMemory(*pMemImage, *MemData+Posd, \ImageSize) : Posd+\ImageSize+1
               FreeMemory(*pMemImage)
            EndWith
         Next  
      EndIf  
      
      
      CountEffects = ListSize(*pModule\ListEffect())                          ;<<< 新增 V11 {
      PokeW(*MemIndex+Posi, CountEffects)                         : Posi+2 
      ForEach *pModule\ListEffect()
         *pEffect.__Module_EffectInfo = *pModule\ListEffect()
         With *pEffect
            *pMemImage = EncodeImage(\ImageID, #PB_ImagePlugin_PNG)
            *pEncrypt.long = *pMemImage : *pEncrypt\l ! Posd    ;<--- 加密
            \ImageSize = MemorySize(*pMemImage)
            \ImageAddr = Posd
            If MaxSizeValue < \ImageSize : MaxSizeValue = \ImageSize : EndIf 
            PokeL(*MemIndex+Posi, \ImageAddr)                     : Posi+4
            PokeL(*MemIndex+Posi, \ImageSize)                     : Posi+4
            PokeW(*MemIndex+Posi, \OffsetX)                       : Posi+2
            PokeW(*MemIndex+Posi, \OffsetY)                       : Posi+2
            PokeW(*MemIndex+Posi, \ImageW)                        : Posi+2
            PokeW(*MemIndex+Posi, \ImageH)                        : Posi+2 
            PokeW(*MemIndex+Posi, \EffectType)                    : Posi+2 
            Lenght = StringByteLength(\EffectNote$, #PB_Ascii)+1
            PokeA(*MemIndex+Posi, Lenght)                         : Posi+1 
            PokeS(*MemIndex+Posi, \EffectNote$, -1, #PB_Ascii)    : Posi+Lenght   
            
            CopyMemory(*pMemImage, *MemData+Posd, \ImageSize) : Posd+\ImageSize+1
            FreeMemory(*pMemImage)   
            Posd+\ImageSize+1
         EndWith
      Next                                                                        ;<<< 新增 V11 }
      
      
      
      *pModule\MaxIconSize = MaxSizeValue
      PokeL(*pMemMaxSize, MaxSizeValue)  

   Next 
   
   Posi = (Posi+3)/4*4        ;4字节对齐
   Posd = (Posd+3)/4*4        ;4字节对齐
   ExtSize = Posi
   VirSize = Posi
   
   mcsZlibPack_(*MemPack, @VirSize, *MemIndex, ExtSize, 9)
   *pEncrypt.long = *MemPack : *pEncrypt\l ! Posd   ;<--- 加密  
   *pHeader\IdxAddr = Posd
   *pHeader\ExtSize = ExtSize   
   *pHeader\VirSize = VirSize   
   *pHeader\InitialTime = Date()   
   
   UseMD5Fingerprint()   
   MD5$ = Fingerprint(*MemPack, VirSize, #PB_Cipher_MD5)
   PokeS(@*pHeader\MD5, MD5$, -1,  #PB_Ascii)

   CopyMemory(*MemPack, *MemData+Posd, VirSize)
   SaveSize = Posd+VirSize
   mcsFileSave_(#Binary_Module_Module$, *MemData, 0, SaveSize, SaveSize)
   FreeMemory(*MemPack)
   FreeMemory(*MemData)
   FreeMemory(*MemIndex)
   
   FileID = ReadFile(#PB_Any, #Binary_Module_Module$)
   If FileID <= 0
      If *pCallRegister
         Note$ = #Binary_Module_Module$
         CallFunctionFast(*pCallRegister, Count, Count, @Note$)
      EndIf 
      _EngineErrorCode = #Module_Error_2013     ;文件重载失败
      ProcedureReturn #Null
   EndIf 
   *pMainModule\ModuleFileID = FileID
   *pMainModule\IsModuleInitial = #True
   ExamineDesktops()
   *pMainModule\DesktopW = DesktopWidth(0)
   *pMainModule\DesktopH = DesktopHeight(0)
   If *pCallRegister
      Note$ = "初始化完毕!"
      CallFunctionFast(*pCallRegister, Count, Count, @Note$)
   EndIf 
   ProcedureReturn #True
EndProcedure

;[模块类型]加载
Procedure Module_LoadBinary()
   FileSize = FileSize(#Binary_Module_Module$) 
   If FileSize < 0
      _EngineErrorCode = #Module_Error_2002 ; 文件不存在
      ProcedureReturn #Null
   EndIf    
   
   FileID = ReadFile(#PB_Any, #Binary_Module_Module$)
   If FileID <= 0
      _EngineErrorCode = #Module_Error_2003 ; 文件被占用
      ProcedureReturn #Null
   EndIf 
   
   ;加载资源头部
   HeaderSize = SizeOf(__Module_Header)
   Header.__Module_Header
   ReadData(FileID, @Header, HeaderSize)
   If Header\Flags <> #Binary_Module_Flags
      CloseFile(FileID)
      _EngineErrorCode = #Module_Error_2004 ; 文件标志有误
      ProcedureReturn #Null
   EndIf 
   
   If Header\Version <> #Binary_Version
      CloseFile(FileID)
      _EngineErrorCode = #Module_Error_2005 ; 文件版本有误
      ProcedureReturn #Null
   EndIf 
   
   ;加载资源索引区
   FileMD5$ = PeekS(@Header\MD5, -1,  #PB_Ascii)
   *MemPack  = AllocateMemory(Header\VirSize) 
   FileSeek(FileID, Header\IdxAddr)
   ReadData(FileID, *MemPack, Header\VirSize)
   DataMD5$ = Fingerprint(*MemPack, Header\VirSize, #PB_Cipher_MD5)
   Debug "[Module] FileMD5$ = " + FileMD5$, #DebugLevel_Module
   Debug "[Module] DataMD5$ = " + DataMD5$, #DebugLevel_Module
   If DataMD5$ <> FileMD5$
      FreeMemory(*MemPack)
      CloseFile(FileID)
      _EngineErrorCode = #Module_Error_2006 ; 文件数据受损
      ProcedureReturn #Null
   EndIf
   *pEncrypt.long = *MemPack : *pEncrypt\l ! Header\IdxAddr  ;<--- 解密
   
   *MemIndex = AllocateMemory(Header\ExtSize+1000) 
   mcsZlibUnpack_(*MemIndex, @Header\ExtSize, *MemPack, Header\VirSize)
   FreeMemory(*MemPack)
   
   *pModule.__Module_MainInfo = AllocateStructure(__Module_MainInfo)
   *pModule\ModuleFlags$    = #ModuleFlags$
   *pModule\ModuleFileID    = FileID
   *pModule\IsModuleInitial = Bool(Header\InitialTime)
   ExamineDesktops()
   *pModule\DesktopW        = DesktopWidth(0)
   *pModule\DesktopH        = DesktopHeight(0)
   If *pModule\IsModuleInitial = #True
      Result = Module_LoadData(*pModule, Header, *MemIndex) ;加载数据文件
   Else 
      Result = Module_LoadPack(*pModule, Header, *MemIndex) ;加载压缩文件
   EndIf 
   If Result = #Null
      FreeStructure(*pModule)
      ProcedureReturn #Null
   Else 
      ProcedureReturn *pModule
   EndIf 
EndProcedure

;[模块类型]初始化
Procedure Module_CatchImage(*pMainModule.__Module_MainInfo, *pModule.__Module_BaseInfo)
   If *pModule = #Null Or *pModule\IsInitial = #True : ProcedureReturn : EndIf 
   Debug "Module_CatchImage = " + *pModule\ModuleTypes$, #DebugLevel_Module 
   FileID = *pMainModule\ModuleFileID
   If IsFile(FileID) = #Null 
      _EngineErrorCode = #Module_Error_2008 ; 文件被占用
      ProcedureReturn #Null
   EndIf       
   
   *pDimImage.__Module_ImageInfo = *pModule\DimImage[0]
   If *pDimImage\ImageSize = #Null 
      _EngineErrorCode = #Module_Error_2009 ; 文件数据受损
      ProcedureReturn #Null
   EndIf 
   
   *MemImage = AllocateMemory(*pModule\MaxIconSize+1024)

   For RotateIdx = 0 To #Object_Rotate_Count-1
      *pDimImage.__Module_ImageInfo = *pModule\DimImage[RotateIdx]
      FileSeek(FileID, *pDimImage\ImageAddr)
      ReadData(FileID, *MemImage, *pDimImage\ImageSize)
      *pDecrypt.long = *MemImage : *pDecrypt\l ! *pDimImage\ImageAddr ;<--- 解密
      
      *pDimImage\ImageID = CatchImage(#PB_Any, *MemImage)
      If IsImage(*pDimImage\ImageID) = #Null : 
         FreeMemory(*MemImage)
         _EngineErrorCode = #Module_Error_2011 ; 文件数据受损
         ProcedureReturn #Null
      EndIf 
      FillMemory(*MemImage, *pDimImage\ImageSize)   
   Next 
   If *pModule\IsSymmetry
      For RotateIdx = 0 To #Object_Rotate_Count-1
         *pDimImage.__Module_ImageInfo = *pModule\DimImage[RotateIdx+#Object_HorizontalFlip_180]
         FileSeek(FileID, *pDimImage\ImageAddr)
         ReadData(FileID, *MemImage, *pDimImage\ImageSize)
         *pDecrypt.long = *MemImage : *pDecrypt\l ! *pDimImage\ImageAddr ;<--- 解密
         
         *pDimImage\ImageID = CatchImage(#PB_Any, *MemImage)
         If IsImage(*pDimImage\ImageID) = #Null : 
            FreeMemory(*MemImage)
            _EngineErrorCode = #Module_Error_2011 ; 文件数据受损
            ProcedureReturn #Null
         EndIf 
         FillMemory(*MemImage, *pDimImage\ImageSize)  
      Next 
   EndIf  

   *pModule\IsInitial = #True
   FreeMemory(*MemImage)
   ProcedureReturn #True
EndProcedure
   
;-
;注销[模块类型]
Procedure Module_Release(*pMainModule.__Module_MainInfo)
   If *pMainModule = #Null : ProcedureReturn #Null : EndIf 
   *pDimImage.__Module_ImageInfo
   ForEach *pMainModule\ListModule()
      With *pMainModule\ListModule()
         If IsImage(\ModuleIconID) : FreeImage(\ModuleIconID) : EndIf 
         FreeList(\ListPinAttri())
         For RotateIdx = 0 To #Object_Rotate_Count*2-1
            *pDimImage = \DimImage[RotateIdx]
            If IsImage(*pDimImage\ImageID) : FreeImage(*pDimImage\ImageID) : EndIf 
            FreeList(*pDimImage\ListPinParam())
         Next   
         ForEach \ListEffect()
            If IsImage(\ListEffect()\ImageID) : FreeImage(\ListEffect()\ImageID) : EndIf 
         Next
         FreeList(\ListEffect())
      EndWith 
   Next 
   FreeList(*pMainModule\ListModule())
   If IsImage(*pMainModule\ThumbnailID) : FreeImage(*pMainModule\ThumbnailID) : EndIf 
   FreeStructure(*pMainModule)
EndProcedure

;-
;- ******** [出错捕获] ******** 
;出错捕获
Procedure$ Module_ErrorMessage(ErrorCode)

   Select ErrorCode
      Case #Module_Error_2001 : ErrorMessage$ = #Module_Error_2001$
      Case #Module_Error_2002 : ErrorMessage$ = #Module_Error_2002$
      Case #Module_Error_2003 : ErrorMessage$ = #Module_Error_2003$
      Case #Module_Error_2004 : ErrorMessage$ = #Module_Error_2004$
      Case #Module_Error_2005 : ErrorMessage$ = #Module_Error_2005$
      Case #Module_Error_2006 : ErrorMessage$ = #Module_Error_2006$
      Case #Module_Error_2007 : ErrorMessage$ = #Module_Error_2007$
      Case #Module_Error_2008 : ErrorMessage$ = #Module_Error_2008$
      Case #Module_Error_2009 : ErrorMessage$ = #Module_Error_2009$
      Case #Module_Error_2010 : ErrorMessage$ = #Module_Error_2010$
      Case #Module_Error_2011 : ErrorMessage$ = #Module_Error_2011$
      Case #Module_Error_2012 : ErrorMessage$ = #Module_Error_2012$
      Case #Module_Error_2013 : ErrorMessage$ = #Module_Error_2013$
   EndSelect
   ProcedureReturn ErrorMessage$
EndProcedure

;-
;- ######## [测试程序] ######## 
CompilerIf  #PB_Compiler_IsMainFile = #True
   
   Procedure Binary_CallBack(Index, Count, Note$)
      Debug Str(Index)+"/"+Str(Count) + ":" + Note$
   EndProcedure
   UseMD5Fingerprint() 
   UsePNGImageDecoder()
   *pMainModule.__Module_MainInfo = Module_LoadBinary()
   If *pMainModule = #Null
      Debug Module_ErrorMessage(_EngineErrorCode)
      End
   EndIf 
   If *pMainModule\IsModuleInitial = #False
      *pMainModule\pCallRegister = @Binary_CallBack()
      UsePNGImageEncoder()
      *pMainModule\ThreadID = CreateThread(@Module_Register(), *pMainModule)
      WaitThread(*pMainModule\ThreadID)
   EndIf
   Module_Release(*pMainModule)
CompilerEndIf 














; IDE Options = PureBasic 5.62 (Windows - x86)
; CursorPosition = 59
; FirstLine = 51
; Folding = HA4--
; EnableXP