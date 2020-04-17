;*****************************************
;******** 单片机仿真模拟器内核引擎 ********
;********    迷路仟 2020.02.04    ********
;*****************************************
;【Engine_Design.ipb】 ;设计文档流文件相关的源代码文件




;- [Constant]
#DesignFlags$ = "Flags_DesignID"
#Design_Error_3001$ = "创建CanvasID失败."
#Design_Error_3002$ = "[设计文档]不存在."
#Design_Error_3003$ = "[设计文档]被占用."
#Design_Error_3004$ = "[设计文档]标志有误."
#Design_Error_3005$ = "[设计文档]版本有误."
#Design_Error_3006$ = "[设计文档]数据有误."

#Design_Error_3007$ = "[设计文档]<摘要信息>有误."
#Design_Error_3008$ = "[设计文档]<画布信息>有误."
#Design_Error_3009$ = "[设计文档]<元件信息>有误."
#Design_Error_3010$ = "[设计文档]<杜邦线信息>有误."
#Design_Error_3011$ = "[设计文档]<代码信息>有误."



;{
#Object_Event_Range = 10
#Object_Event_Align = 32

#Module_DupontPitch = 25
#Module_DupontWidth = 10
#Module_CellSpacing = 32

#Object_Event_Active = $0100
#Object_Event_Moving = $0200
#Object_Event_Origin = $0400  
#Object_Event_Target = $0800 
#Object_Event_DuNode = $1000
#Object_Event_Modify = $2000
#Object_Event_Create = $4000
#Object_Event        = $FF00



#Design_Version = 1.0

;设计文档流文件块标志
#Design_Flags_MCT  = $54434D89
#Design_Flags_MSMY = $594D534D
#Design_Flags_MCVS = $5356434D
#Design_Flags_MOBJ = $4A424F4D
#Design_Flags_MDPL = $4C50444D
#Design_Flags_MCDS = $5344434D 
;}

;- [Enumeration]
;各种控件标志
Enumeration
   #Object_None      ;空
   #Object_Canvas    ;[画布]
   #Object_Active    ;临时[激活组]
   #Object_Matter    ;[电子元件]
   #Object_String    ;[字符串]
   #Object_Groups    ;[电子元件组]
   #Object_Dupont    ;[杜邦线]
EndEnumeration

;设计文档流文件块标志索引
Enumeration
   #Design_Block_MSMY   ;信息块
   #Design_Block_MCVS   ;画布
   #Design_Block_MOBJ   ;元件
   #Design_Block_MDPL   ;杜邦线
   #Design_Block_MCDS   ;代码
   #Design_Block_Count
EndEnumeration

; 出错代码
Enumeration
   #Design_Error_None
   #Design_Error_3001 = 3001
   #Design_Error_3002 
   #Design_Error_3003 
   #Design_Error_3004 
   #Design_Error_3005 
   #Design_Error_3006 
   #Design_Error_3007 
   #Design_Error_3008 
   #Design_Error_3009 
   #Design_Error_3010 
   #Design_Error_3011
EndEnumeration


;- [Structure]
;设计文档流文件头部结构
Structure __Design_HeaderInfo
   Flags.l
   Version.l
   CRC32.l
   IdxCount.l
   DimIdxAddr.l[#Design_Block_Count]
EndStructure

;[电子元件]引脚/插口的基本结构
Structure __Matter_PinPrefer
   PinDirection.l                    ;引脚方向
   DupontType.l                      ;杜邦线类型
   *pOriginDupont.__Dupont_BaseInfo  ;[杜邦线]指针   
   *pTargetDupont.__Dupont_BaseInfo  ;[杜邦线]指针   
   *pListPinParam.__Module_PinParam  ;[模块类型]-引脚参数指针
   *pParentMatter.__Matter_BaseInfo  ;[模块单元]指针 
EndStructure

;[对象]公共信息结构
Structure __Object_BaseInfo
   ObjectType.l
   X.f
   Y.f
   W.f
   H.f
   R.f
   B.f 
   OffsetX.f
   OffsetY.f
   ObjectName$
EndStructure

;[电子元件]基本信息结构
Structure __Matter_BaseInfo Extends __Object_BaseInfo
   *pMapModule.__Module_BaseInfo
   *pDimImage.__Module_ImageInfo
   *pListString.__String_BaseInfo
   BinaryIndex.l     ;保存[设计文档所需]
   RotateIdx.w
   SymmetryIdx.b     ;Rotate的偏移量
   Reserve.b 
   List ListPinPrefer.__Matter_PinPrefer()
EndStructure

;[杜邦线]节点结构
Structure __DuNode_BaseInfo
   X.f
   Y.f
   Direction.l
   OffsetX.f
   OffsetY.f
   *pPrevDuNode.__DuNode_BaseInfo
   *pNextDuNode.__DuNode_BaseInfo
EndStructure

;[杜邦线]基本信息结构
Structure __Dupont_BaseInfo Extends __Object_BaseInfo
   *pOriginPin.__Matter_PinPrefer
   *pTargetPin.__Matter_PinPrefer
   *pModifyPin.__Matter_PinPrefer
   *pListNodus.__DuNode_BaseInfo
   OriginPos.__DuNode_BaseInfo
   TargetPos.__DuNode_BaseInfo
   ModifyPos.__DuNode_BaseInfo
   ;============================
   CurrDirection.l
   DupontColor.l
   IsGroupOrigin.b
   IsGroupTarget.b
   Reserve.W
   ;============================
   List ListNodus.__DuNode_BaseInfo()
EndStructure

;[文本标签]基本信息结构
Structure __String_BaseInfo Extends __Object_BaseInfo
   Text$
   FontSize.w
   FontStyle.w
   FontColor.l
   BackColor.l
EndStructure

;[对象组]基本信息结构,
Structure __Groups_BaseInfo Extends __Object_BaseInfo
   List *pListObject.__Groups_BaseInfo()
   DeleteFlags.l  ;删除标志,用于组的合并   
EndStructure

;设计文档流文件画布结构
Structure __Design_CanvasInfo Extends __Object_BaseInfo 
   CanvasFlags$
   LayerZoom.f       ;缩放比例值
   LayerImageID.l    ;图层ID,用于内部重绘
   ExportImageID.l   ;图层ID,用于输出到DLL外面
   ScrollX.l         ;画布偏移值
   ScrollY.l         ;画布偏移值 
   CanvasW.l         ;画布大小
   CanvasH.l         ;画布大小
   CanvasR.l
   CanvasB.l
   ScreenshotX.f     ;截图时统计坐标大小
   ScreenshotY.f     ;截图时统计坐标大小
   ScreenshotR.f     ;截图时统计坐标大小
   ScreenshotB.f     ;截图时统计坐标大小
   FontSize.w    ;默认的字体大小
   FontStyle.w
   FontColor.l   ;默认的字体颜色
   BackColor.l   ;默认的背景颜色
   FontName$
   ;====================
   *pMainDesign.__Design_MainInfo
   *pSelection.__Object_BaseInfo          ;当前[对象指针]
   FontID.l
EndStructure



;设计文档主体结构,作为接口输出为:DesignID
Structure __Design_MainInfo
   DesignFlags$         ;标志,用于判断ID
   CreateDate.l         ;创建设计文档的时间
   ModifyDate.l         ;最后修改设计文档的时间
   FileName$            ;设计文档的文件名
   MatterBinIdx.l       ;保存文件时所需
   BinaryVersion.f
   MatterNameIndex.l
   StringNameIndex.l
   GroupsNameIndex.l
   ;=====================
   HorizAlign.l         ;水平对齐线
   VertiAlign.l         ;垂直对齐线
   ;=====================
   *pMainModule.__Module_MainInfo
   *pMainCanvas.__Design_CanvasInfo
   *pMainEngine
   *pPinAttri.__Module_PinAttri
   ToolTipX.f 
   ToolTipY.f 
   MaxStringIndex.l
   IsModify.l           ;是否被修改过
   ;=====================
   List ListMatter.__Matter_BaseInfo()       ;[电子元件]集合
   List ListString.__String_BaseInfo()       ;[文本标签]集合
   List ListDupont.__Dupont_BaseInfo()       ;[杜邦线]集合
   List ListGroups.__Groups_BaseInfo()       ;[对象组]集合对象包括:[电子元件],[文本标签]和[对象组], 不包括[杜邦线]

   ;=====================
   Map *pMapDupont.__Dupont_BaseInfo()       ;用于记录成组移动的杜邦线
   ;=====================
   *pCallAddString
   *pCallThumbnail
   ;=====================
   List *pListObject.__Groups_BaseInfo()     ;[对象指针]集合,包括: [电子元件],[文本标签]和[对象组]
   ActiveObject.__Groups_BaseInfo            ;[临时组]
   ActiveDupont.__Dupont_BaseInfo 
   ;=====================
   *pCurrModule.__Module_BaseInfo
   *pCurrObject.__Object_BaseInfo            ;当前[对象指针]
   *pCurrDupont.__Dupont_BaseInfo            ;不为NULL时, 用于表示[杜邦线]激活状态,可以修改节点
   *pCurrDuNode.__DuNode_BaseInfo            ;不为NULL时, 用于表示[节点]激活状态,可以调整节点位置 
EndStructure


;- [Include]
XIncludeFile "Engine_Module.pbi"  ;流文件相关的源代码文件

;-
;- ******** [MainCanvas] ******** 
;创建一个[对象]
Procedure Design_Create(*pMainModule.__Module_MainInfo)
   If *pMainModule = #Null : ProcedureReturn #Null : EndIf  
   *pMainDesign.__Design_MainInfo = AllocateStructure(__Design_MainInfo)
   With *pMainDesign
      \DesignFlags$ = #DesignFlags$
      \ActiveDupont\ObjectType  = #Object_Dupont      
      \ActiveObject\ObjectType  = #Object_Active
      \ActiveObject\ObjectName$ = "活动组"
      \BinaryVersion= #Binary_Version
      \CreateDate   = Date()
      \ModifyDate   = Date()
      \pMainModule  = *pMainModule
      \pCurrDuNode  = #Null
   EndWith
   ProcedureReturn *pMainDesign
EndProcedure

;释放一个[对象]
Procedure Design_Release_Groups(*pMainDesign.__Design_MainInfo, *pListGroups.__Groups_BaseInfo)
   ForEach *pListGroups\pListObject()
      Design_Release_Groups(*pMainDesign, *pListGroups\pListObject())
   Next  
   FreeList(*pListGroups\pListObject()) 
EndProcedure

Procedure Design_Release(*pMainDesign.__Design_MainInfo)
   If *pMainModule = #Null : ProcedureReturn #Null : EndIf  
   With *pMainDesign
      \pMainCanvas = #Null
      ForEach \ListMatter() 
         FreeList(\ListMatter()\ListPinPrefer()) 
      Next 
      ForEach \ListDupont() 
         FreeList(\ListDupont()\ListNodus()) 
      Next   
      ForEach \ListGroups() 
         Design_Release_Groups(*pMainDesign, \ListGroups())
      Next    
      FreeList(\ListGroups())
      FreeList(\ListString())
      FreeList(\ListMatter())
      FreeList(\pListObject())
      FreeMap(\pMapDupont())

      FreeStructure(*pMainDesign)
   EndWith
   ProcedureReturn #True
EndProcedure

;-
;- ******** 保存[设计文档] ******** 
;保存摘要信息[MSMY]
Procedure Design_SaveFile_MSMY(*pMainDesign.__Design_MainInfo, *MemData, Pos)
   With *pMainDesign
      PokeL(*MemData+Pos, #Design_Flags_MSMY)   : Pos+4 ; MSMY
      PokeF(*MemData+Pos, \BinaryVersion)       : Pos+4 ; 版本号 
      PokeL(*MemData+Pos, \CreateDate)          : Pos+4 ; 创建时间
      PokeL(*MemData+Pos, \ModifyDate)          : Pos+4 ; 修改时间
      PokeL(*MemData+Pos, \MatterNameIndex)     : Pos+4 
      PokeL(*MemData+Pos, \StringNameIndex)     : Pos+4 
      PokeL(*MemData+Pos, \GroupsNameIndex)     : Pos+4 
      If \pCallThumbnail                        ;保存缩略图
         Debug "\pCallThumbnail = " + \pCallThumbnail
         *pMemImage = CallFunctionFast(\pCallThumbnail, \pMainCanvas)
         If *pMemImage
            *pEncode.long = *pMemImage
            *pEncode\l = *pEncode\l ! #Design_Flags_MSMY
            ImageSize = MemorySize(*pMemImage)
            PokeL(*MemData+Pos, ImageSize)                     : Pos+4 
            
            CopyMemory(*pMemImage, *MemData+Pos, ImageSize)    : Pos+ImageSize
            FreeMemory(*pMemImage)
         Else 
            PokeL(*MemData+Pos, 0)              : Pos+4 
         EndIf 
      Else 
         PokeL(*MemData+Pos, 0)                 : Pos+4 
      EndIf 
   EndWith
   ProcedureReturn Pos
EndProcedure  


;保存画布信息[MCVS]
Procedure Design_SaveFile_MCVS(*pMainDesign.__Design_MainInfo, *MemData, Pos)
   *pMainCanvas.__Design_CanvasInfo = *pMainDesign\pMainCanvas
   With *pMainCanvas
      PokeL(*MemData+Pos, #Design_Flags_MCVS)   : Pos+4 ; MCVS
      PokeF(*MemData+Pos, \LayerZoom)           : Pos+4 ; 画布比例 
      PokeL(*MemData+Pos, \ScrollX)             : Pos+4 ; 画布偏移值   
      PokeL(*MemData+Pos, \ScrollY)             : Pos+4 ; 画布偏移值   
      PokeL(*MemData+Pos, \CanvasW)             : Pos+4 ; 画布大小   
      PokeL(*MemData+Pos, \CanvasH)             : Pos+4 ; 画布大小 
      PokeL(*MemData+Pos, \FontColor)           : Pos+4 ; 默认的字体颜色   
      PokeL(*MemData+Pos, \BackColor)           : Pos+4 ; 默认的背景颜色   
      PokeW(*MemData+Pos, \FontSize)            : Pos+2 ; 默认的字体大小  
      PokeW(*MemData+Pos, \FontStyle)           : Pos+2 ; 默认的字体大小  
      Lenght = StringByteLength(\FontName$, #PB_Ascii)+1               
      PokeA(*MemData+Pos, Lenght)                       : Pos+1 
      PokeS(*MemData+Pos, \FontName$, -1, #PB_Ascii)    : Pos+Lenght 
   EndWith    
   ProcedureReturn Pos
EndProcedure


Procedure Design_SaveFile_Object(*pMainDesign.__Design_MainInfo, *pListObject.__Object_BaseInfo, *MemData, Pos)
   Select *pListObject\ObjectType & $FF
      Case #Object_Matter 
         *pListMatter.__Matter_BaseInfo = *pListObject
         With *pListMatter
            \BinaryIndex = *pMainDesign\MatterBinIdx
            ModuleTypes$ = \pMapModule\ModuleTypes$
            Lenght = StringByteLength(ModuleTypes$, #PB_Ascii)+1               
            PokeL(*MemData+Pos, #Object_Matter)                 : Pos+4 
            PokeA(*MemData+Pos, Lenght)                         : Pos+1 
            PokeS(*MemData+Pos, ModuleTypes$, -1, #PB_Ascii)    : Pos+Lenght 
            PokeW(*MemData+Pos, \RotateIdx)                     : Pos+2             
            PokeA(*MemData+Pos, \SymmetryIdx)                   : Pos+1             
            PokeA(*MemData+Pos, \Reserve)                       : Pos+1
            ;===============================
            PokeF(*MemData+Pos, \X)          : Pos+4   
            PokeF(*MemData+Pos, \Y)          : Pos+4   
         EndWith
         *pMainDesign\MatterBinIdx+1
         Debug "[Design] Save [Matter] " + Hex(*pListObject), #DebugLevel_Design
         
      Case #Object_String
         *pListString.__String_BaseInfo = *pListObject
         With *pListString
            PokeL(*MemData+Pos, #Object_String)          : Pos+4 
            PokeF(*MemData+Pos, \X)    : Pos+4  
            PokeF(*MemData+Pos, \Y)    : Pos+4 
            PokeL(*MemData+Pos, \FontColor)              : Pos+4 
            PokeL(*MemData+Pos, \BackColor)              : Pos+4 
            PokeW(*MemData+Pos, \FontSize)               : Pos+2 
            PokeW(*MemData+Pos, \FontStyle)              : Pos+2 
            Lenght = StringByteLength(\Text$, #PB_Ascii)+1               
            PokeW(*MemData+Pos, Lenght)                  : Pos+2
            PokeS(*MemData+Pos, \Text$, -1, #PB_Ascii)   : Pos+Lenght 
         EndWith  
         Debug "[Design] Save [String] " + Hex(*pListObject), #DebugLevel_Design
         
      Case #Object_Groups
         *pListGroups.__Groups_BaseInfo = *pListObject
         With *pListGroups
            PokeL(*MemData+Pos, #Object_Groups)          : Pos+4 
            PokeF(*MemData+Pos, \X)                      : Pos+4  
            PokeF(*MemData+Pos, \Y)                      : Pos+4 
            PokeF(*MemData+Pos, \W)                      : Pos+4  
            PokeF(*MemData+Pos, \H)                      : Pos+4 
            Count = ListSize(\pListObject())
            PokeW(*MemData+Pos, Count)                   : Pos+2 
            Debug "[Design] Save [Groups] = $"+ Hex(*pListGroups)+" : "+Str(\X)+","+Str(\Y)+" - "+Str(\W)+","+Str(\H), #DebugLevel_Design
            Debug "[Design] Save [Groups] " + Hex(*pListObject), #DebugLevel_Design
            ForEach \pListObject()
               Pos = Design_SaveFile_Object(*pMainDesign, \pListObject(), *MemData, Pos)
            Next     
         EndWith          
   EndSelect
   ProcedureReturn Pos
EndProcedure


;保存元件信息[MOBJ]
Procedure Design_SaveFile_MOBJ(*pMainDesign.__Design_MainInfo, *MemData, Pos)
   CountObject = ListSize(*pMainDesign\pListObject())
   PokeL(*MemData+Pos, #Design_Flags_MOBJ)      : Pos+4 ; MOBJ
   PokeL(*MemData+Pos, CountObject)             : Pos+4 
   With *pMainDesign
      \MatterBinIdx = 0    ;保存文件时所需
      ForEach \pListObject()
         Pos = Design_SaveFile_Object(*pMainDesign, \pListObject(), *MemData, Pos)
      Next 
   EndWith
   ProcedureReturn Pos
EndProcedure

;保存杜邦线信息[MDPL]
Procedure Design_SaveFile_MDPL(*pMainDesign.__Design_MainInfo, *MemData, Pos)
   PokeL(*MemData+Pos, #Design_Flags_MDPL)  : Pos+4 ; MDPL
   CountDupont = ListSize(*pMainDesign\ListDupont())
   PokeL(*MemData+Pos, CountDupont)          : Pos+4  ;杜邦线节点数量
   ForEach *pMainDesign\ListDupont()
      ;获取[源引脚]的ListMatter()和ListPinPrefer()索引号
      *pListDupont.__Dupont_BaseInfo = *pMainDesign\ListDupont()
      ChangeCurrentElement(*pMainDesign\ListMatter(), *pListDupont\pOriginPin\pParentMatter)
      *pListMatter.__Matter_BaseInfo = *pMainDesign\ListMatter()
      OriginMatter = *pListMatter\BinaryIndex
       ChangeCurrentElement(*pListMatter\ListPinPrefer(), *pListDupont\pOriginPin)
      *pListPrefer.__Matter_PinPrefer = *pListMatter\ListPinPrefer()
      OriginPrefer = ListIndex(*pListMatter\ListPinPrefer())
      
      ;获取[目标引脚]的ListMatter()和ListPinPrefer()索引号
      *pListDupont.__Dupont_BaseInfo = *pMainDesign\ListDupont()
      ChangeCurrentElement(*pMainDesign\ListMatter(), *pListDupont\pTargetPin\pParentMatter)
      *pListMatter.__Matter_BaseInfo = *pMainDesign\ListMatter()
      TargetMatter = *pListMatter\BinaryIndex
      ChangeCurrentElement(*pListMatter\ListPinPrefer(), *pListDupont\pTargetPin)
      *pListPrefer.__Matter_PinPrefer = *pListMatter\ListPinPrefer()
      TargetPrefer = ListIndex(*pListMatter\ListPinPrefer())

      DupontColor = *pListDupont\DupontColor
      CountNoduss  = ListSize(*pListDupont\ListNodus())

      PokeL(*MemData+Pos, DupontColor)       : Pos+4  ;杜邦线颜色
      PokeL(*MemData+Pos, OriginMatter)      : Pos+4  ;写入ListMatter()的索引号
      PokeL(*MemData+Pos, OriginPrefer)      : Pos+4  ;写入ListPinPrefer()的索引号
      PokeL(*MemData+Pos, TargetMatter)      : Pos+4  ;写入ListMatter()的索引号
      PokeL(*MemData+Pos, TargetPrefer)      : Pos+4  ;写入ListPinPrefer()的索引号 
      
      With *pListDupont
         PokeF(*MemData+Pos, \X)    : Pos+4  
         PokeF(*MemData+Pos, \Y)    : Pos+4 
         PokeF(*MemData+Pos, \W)    : Pos+4  
         PokeF(*MemData+Pos, \H)    : Pos+4 
         PokeF(*MemData+Pos, \R)    : Pos+4  
         PokeF(*MemData+Pos, \B)    : Pos+4 
         
         PokeW(*MemData+Pos, \OriginPos\Direction) : Pos+2
         PokeF(*MemData+Pos, \OriginPos\X)         : Pos+4
         PokeF(*MemData+Pos, \OriginPos\Y)         : Pos+4
         PokeW(*MemData+Pos, \TargetPos\Direction) : Pos+2
         PokeF(*MemData+Pos, \TargetPos\X)         : Pos+4 
         PokeF(*MemData+Pos, \TargetPos\Y)         : Pos+4 
      
         
         PokeW(*MemData+Pos, CountNoduss)          : Pos+2  ;杜邦线节点数量
         ForEach \ListNodus()
            *pDuNode.__DuNode_BaseInfo = \ListNodus()
            PokeW(*MemData+Pos, *pDuNode\Direction): Pos+2
            PokeF(*MemData+Pos, *pDuNode\X)        : Pos+4 
            PokeF(*MemData+Pos, *pDuNode\Y)        : Pos+4 
         Next 
      EndWith
   Next 
   ProcedureReturn Pos
EndProcedure

;保存代码信息[MCDS]
Procedure Design_SaveFile_MCDS(*pMainDesign.__Design_MainInfo, *MemData, Pos)
   PokeL(*MemData+Pos, #Design_Flags_MCDS)     : Pos+4 ; MCDS
   ProcedureReturn Pos
EndProcedure  

;保存[设计文档]
Procedure Design_SaveFile(*pMainDesign.__Design_MainInfo, FileName$)
   ;编辑文件结构: 文件头部[.MCT]+摘要信息[MSMY]+画布信息[MCVS]+电子元件信息[MOBJ]+杜邦线信息[MDPL]+代码信息[MCDS] 
   CountMatter = ListSize(*pMainDesign\ListMatter())
   Pos = SizeOf(__Design_HeaderInfo)
   *MemData = AllocateMemory($10000+CountMatter*512)
   ;========== 文件头部[.MCT] ==========
   *pHeader.__Design_HeaderInfo = *MemData
   *pHeader\Flags    = #Design_Flags_MCT      
   *pHeader\Version  = #Design_Version 
   *pHeader\IdxCount = #Design_Block_Count  
   *pMainDesign\ModifyDate = Date()
   *pMainDesign\FileName$  = FileName$
   ;==========
   Debug "[Design] Save: "+FileName$, #DebugLevel_Design
   *pHeader\DimIdxAddr[#Design_Block_MSMY] = Pos   
   Pos = Design_SaveFile_MSMY(*pMainDesign, *MemData, Pos)     ;摘要信息[MSMY]
   *pHeader\DimIdxAddr[#Design_Block_MCVS] = Pos 
   Pos = Design_SaveFile_MCVS(*pMainDesign, *MemData, Pos)     ;画布信息[MCVS] 
   *pHeader\DimIdxAddr[#Design_Block_MOBJ] = Pos   
   Pos = Design_SaveFile_MOBJ(*pMainDesign, *MemData, Pos)     ;电子元件信息[MOBJ] 
   *pHeader\DimIdxAddr[#Design_Block_MDPL] = Pos
   Pos = Design_SaveFile_MDPL(*pMainDesign, *MemData, Pos)     ;杜邦线信息[MDPL]
   *pHeader\DimIdxAddr[#Design_Block_MCDS] = Pos   
   Pos = Design_SaveFile_MCDS(*pMainDesign, *MemData, Pos)     ;代码信息[MCDS] 
   ; 保存文件
   Result = mcsFileSave_(FileName$, *MemData, 0, Pos, Pos)
   FreeMemory(*MemData)
   Debug "[Design] Save CountObject = "+ListSize(*pMainDesign\pListObject()), #DebugLevel_Design
   Debug "[Design] Save CountMatter = "+ListSize(*pMainDesign\ListMatter()), #DebugLevel_Design
   Debug "[Design] Save CountString = "+ListSize(*pMainDesign\ListString()), #DebugLevel_Design
   Debug "[Design] Save CountGroups = "+ListSize(*pMainDesign\ListGroups()), #DebugLevel_Design
   Debug "[Design] Save <<=============== ", #DebugLevel_Design
   ProcedureReturn Result 
EndProcedure


;-
;- ******** 加载[设计文档] ********
;加载检测
Procedure Design_LoadFile_Check(FileName$)
   FileSize = FileSize(FileName$)
   If FileSize < 0
      _EngineErrorCode = #Design_Error_3002
      ProcedureReturn #False
   EndIf 
      
   *MemData = mcsFileLoad_(FileName$)
   If *MemData = 0
      _EngineErrorCode = #Design_Error_3003
      ProcedureReturn #False
   EndIf  
   
   ;========== 文件头部[.MCT] ==========
   *pHeader.__Design_HeaderInfo = *MemData
   If *pHeader\Flags <> #Design_Flags_MCT    
      FreeMemory(*MemData)
      _EngineErrorCode = #Design_Error_3004
      ProcedureReturn #False
   EndIf   
   If *pHeader\Version > #Design_Version
      FreeMemory(*MemData)
      _EngineErrorCode = #Design_Error_3005
      ProcedureReturn #False
   EndIf   
   If *pHeader\IdxCount <> #Design_Block_Count 
      FreeMemory(*MemData)
      _EngineErrorCode = #Design_Error_3006
      ProcedureReturn #False
   EndIf  
   
   ;========== 摘要信息[MSMY] ==========
   Pos = *pHeader\DimIdxAddr[#Design_Block_MSMY] 
   Flags = PeekL(*MemData+Pos)            : Pos+4 ; MSMY
   If Flags <> #Design_Flags_MSMY
      FreeMemory(*MemData)
      _EngineErrorCode = #Design_Error_3007
      ProcedureReturn #False
   EndIf  
   
   ;========== 画布信息[MCVS] ==========
   Pos = *pHeader\DimIdxAddr[#Design_Block_MCVS] 
   Flags = PeekL(*MemData+Pos)            : Pos+4 ; MCVS
   If Flags <> #Design_Flags_MCVS
      FreeMemory(*MemData)
      _EngineErrorCode = #Design_Error_3008
      ProcedureReturn #False
   EndIf 
   
   ;========== 电子元件信息[MOBJ] ==========
   Pos = *pHeader\DimIdxAddr[#Design_Block_MOBJ] 
   Flags = PeekL(*MemData+Pos)            : Pos+4 ; MOBJ
   If Flags <> #Design_Flags_MOBJ
      FreeMemory(*MemData)
      _EngineErrorCode = #Design_Error_3009
      ProcedureReturn #False
   EndIf
   
   ;========== 杜邦线信息[MDPL] ==========
   Pos = *pHeader\DimIdxAddr[#Design_Block_MDPL] 
   Flags = PeekL(*MemData+Pos)            : Pos+4 ; MDPL
   If Flags <> #Design_Flags_MDPL
      FreeMemory(*MemData)
      _EngineErrorCode = #Design_Error_3010
      ProcedureReturn #False
   EndIf
      
   ;========== 代码信息[MCDS] ==========
   Pos = *pHeader\DimIdxAddr[#Design_Block_MCDS] 
   Flags = PeekL(*MemData+Pos)            : Pos+4 ; MCDS
   If Flags <> #Design_Flags_MCDS
      FreeMemory(*MemData)
      _EngineErrorCode = #Design_Error_3011
      ProcedureReturn #False
   EndIf
   
   ProcedureReturn *MemData
EndProcedure


;加载摘要信息[MSMY]
Procedure Design_LoadFile_MSMY(*pMainDesign.__Design_MainInfo, *MemData, Pos)
   With *pMainDesign
      \BinaryVersion    =  PeekF(*MemData+Pos)     : Pos+4 ; 版本号
      \CreateDate       =  PeekL(*MemData+Pos)     : Pos+4 ; 创建时间
      \ModifyDate       =  PeekL(*MemData+Pos)     : Pos+4 ; 创建时间
      \MatterNameIndex  =  PeekL(*MemData+Pos)     : Pos+4 ;
      \StringNameIndex  =  PeekL(*MemData+Pos)     : Pos+4 ;
      \GroupsNameIndex  =  PeekL(*MemData+Pos)     : Pos+4 ;
   EndWith
   ProcedureReturn Pos
EndProcedure

;加载画布信息[MCVS]
Procedure Design_LoadFile_MCVS(*pMainDesign.__Design_MainInfo, *MemData, Pos, *pCallFunction)
   LayerZoom.f = PeekF(*MemData+Pos)      : Pos+4 ; 画布比例 
   ScrollX     = PeekL(*MemData+Pos)      : Pos+4 ; 画布偏移值   
   ScrollY     = PeekL(*MemData+Pos)      : Pos+4 ; 画布偏移值   
   CanvasW     = PeekL(*MemData+Pos)      : Pos+4 ; 画布大小   
   CanvasH     = PeekL(*MemData+Pos)      : Pos+4 ; 画布大小  
   FontColor   = PeekL(*MemData+Pos)      : Pos+4 ; 默认的字体颜色   
   BackColor   = PeekL(*MemData+Pos)      : Pos+4 ; 默认的背景颜色   
   FontSize    = PeekW(*MemData+Pos)      : Pos+2 ; 默认的字体大小    
   FontStyle   = PeekW(*MemData+Pos)      : Pos+2 ; 默认的字体大小    
   Lenght      = PeekA(*MemData+Pos)                 : Pos+1
   FontName$   = PeekS(*MemData+Pos, -1, #PB_Ascii)  : Pos+Lenght  

   *pMainCanvas.__Design_CanvasInfo = CallFunctionFast(*pCallFunction, *pMainDesign)  
   With *pMainCanvas  
      \LayerZoom    = LayerZoom
      \ScrollX      = ScrollX  
      \ScrollY      = ScrollY  
      \CanvasW      = CanvasW
      \CanvasH      = CanvasH
      \FontColor    = FontColor
      \BackColor    = BackColor
      \FontSize     = FontSize
      \FontStyle    = FontStyle
      \FontName$    = FontName$
      Debug "[Design] Load Canvas = "+Str(CanvasW)+"x"+Str(CanvasH), #DebugLevel_Design
      Debug "[Design] Load LayerZoom = "+StrF(LayerZoom *100), #DebugLevel_Design
   EndWith   
   *pMainDesign\pMainCanvas = *pMainCanvas
   ProcedureReturn *pMainCanvas
EndProcedure

Procedure Design_LoadFile_Object(*pMainModule.__Module_MainInfo, *pMainDesign.__Design_MainInfo, *MemData, Pos, *pGroups.__Groups_BaseInfo=#Null)
   ObjectType = PeekL(*MemData+Pos)        : Pos+4 
   Select ObjectType
      Case #Object_Matter 
         *pListMatter.__Matter_BaseInfo = AddElement(*pMainDesign\ListMatter())
         With *pListMatter
            Lenght       = PeekA(*MemData+Pos)                 : Pos+1
            ModuleTypes$ = PeekS(*MemData+Pos, -1, #PB_Ascii)  : Pos+Lenght               
            \RotateIdx   = PeekW(*MemData+Pos)   : Pos+2
            \SymmetryIdx = PeekA(*MemData+Pos)   : Pos+1
            \Reserve     = PeekA(*MemData+Pos)   : Pos+1
            \X           = PeekF(*MemData+Pos)   : Pos+4
            \Y           = PeekF(*MemData+Pos)   : Pos+4
            ForEach *pMainModule\ListModule()
               If *pMainModule\ListModule()\ModuleTypes$ = ModuleTypes$
                  *pModule.__Module_BaseInfo = *pMainModule\ListModule()
                  Break
               Else 
                  *pModule.__Module_BaseInfo = #Null
               EndIf 
            Next                
            \ObjectType  = #Object_Matter
            \pMapModule  = *pModule 
            If *pModule
               If *pGroups = #Null
                  AddElement(*pMainDesign\pListObject())       ;添加到[对象链表]
                  *pMainDesign\pListObject() = *pListMatter                  
               Else 
                  AddElement(*pGroups\pListObject())       ;添加到[对象组]
                  *pGroups\pListObject() = *pListMatter
               EndIf 
               Module_CatchImage(*pMainModule, *pModule)
               \pDimImage = *pModule\DimImage[*pListMatter\RotateIdx]
               \W = \pDimImage\ImageW
               \H = \pDimImage\ImageH
               \R = \X+\W
               \B = \Y+\H
               ForEach \pDimImage\ListPinParam()
                  AddElement(\ListPinPrefer())
                  \ListPinPrefer()\PinDirection  = \pDimImage\ListPinParam()\PinDirection
                  \ListPinPrefer()\pListPinParam = \pDimImage\ListPinParam()
                  \ListPinPrefer()\pParentMatter = *pListMatter
               Next 
               Debug "[Design] Load [Module] = 0x"+ Hex(\pMapModule) + " : " + ModuleTypes$, #DebugLevel_Design
               Debug "[Design] Load [Matter] = $"+ Hex(*pListMatter)+" : "+Str(\X)+","+Str(\Y)+" - "+Str(\W)+","+Str(\W), #DebugLevel_Design
            EndIf
         EndWith
      Case #Object_String
         *pListString.__String_BaseInfo = AddElement(*pMainDesign\ListString())
         With *pListString
            \ObjectType  = #Object_String   
            \X = PeekF(*MemData+Pos)   : Pos+4    
            \Y = PeekF(*MemData+Pos)   : Pos+4 
            \FontColor = PeekL(*MemData+Pos)             : Pos+4
            \BackColor = PeekL(*MemData+Pos)             : Pos+4
            \FontSize  = PeekW(*MemData+Pos)             : Pos+2
            \FontStyle = PeekW(*MemData+Pos)             : Pos+2
            Lenght = PeekA(*MemData+Pos)                 : Pos+1
            \Text$ = PeekS(*MemData+Pos, -1, #PB_Ascii)  : Pos+Lenght    
            If *pGroups
               AddElement(*pMainDesign\pListObject())             ;添加到[对象链表]
               *pMainDesign\pListObject() = *pListString                          
            Else 
               AddElement(*pGroups\pListObject())          ;添加到[对象组]
               *pGroups\pListObject() = *pListString
            EndIf 
            Debug "[Design] Load [String] = $"+ Hex(*pListString)+" : "+Str(\X)+","+Str(\Y), #DebugLevel_Design
         EndWith 
      Case #Object_Groups
         *pListGroups.__Groups_BaseInfo = AddElement(*pMainDesign\ListGroups())
         With *pListGroups
            \ObjectType  = #Object_Groups  
            \X = PeekF(*MemData+Pos)   : Pos+4    
            \Y = PeekF(*MemData+Pos)   : Pos+4 
            \W = PeekF(*MemData+Pos)   : Pos+4    
            \H = PeekF(*MemData+Pos)   : Pos+4 
            \R = \X+\W
            \B = \Y+\H
            If *pGroups
               AddElement(*pGroups\pListObject())          ;添加到[对象组]
               *pGroups\pListObject() = *pListGroups
            Else 
               AddElement(*pMainDesign\pListObject())             ;添加到[对象链表]
               *pMainDesign\pListObject() = *pListGroups                 
            EndIf 
            Debug "[Design] Load [Groups] = $"+ Hex(*pListGroups)+" : "+Str(\X)+","+Str(\Y)+" - "+Str(\W)+","+Str(\H), #DebugLevel_Design
            Count = PeekW(*MemData+Pos)             : Pos+2
            For k = 1 To Count
               Pos = Design_LoadFile_Object(*pMainModule, *pMainDesign, *MemData, Pos, *pListGroups)
            Next 
         EndWith  
   EndSelect
   ProcedureReturn Pos
EndProcedure

;加载元件信息[MOBJ]
Procedure Design_LoadFile_MOBJ(*pMainDesign.__Design_MainInfo, *MemData, Pos, *pMainModule)
   CountObject = PeekL(*MemData+Pos)          : Pos+4 
   For k = 1 To CountObject
      Pos = Design_LoadFile_Object(*pMainModule, *pMainDesign, *MemData, Pos)
   Next 
EndProcedure

;加载杜邦线信息[MDPL]
Procedure Design_LoadFile_MDPL(*pMainDesign.__Design_MainInfo, *MemData, Pos)
   CountDuponts = PeekL(*MemData+Pos)           : Pos+4     ;杜邦线节点数量
   For k = 1 To CountDuponts
      DupontColor  = PeekL(*MemData+Pos)        : Pos+4     ;杜邦线颜色
      OriginMatter = PeekL(*MemData+Pos)        : Pos+4     ;ListMatter()的索引号
      OriginPrefer = PeekL(*MemData+Pos)        : Pos+4     ;ListPinPrefer()的索引号
      TargetMatter = PeekL(*MemData+Pos)        : Pos+4     ;ListMatter()的索引号
      TargetPrefer = PeekL(*MemData+Pos)        : Pos+4     ;ListPinPrefer()的索引号      
      *pListMatter.__Matter_BaseInfo 
      *pListMatter = SelectElement(*pMainDesign\ListMatter(),    OriginMatter)
      *pOriginPin  = SelectElement(*pListMatter\ListPinPrefer(), OriginPrefer)
      *pListMatter = SelectElement(*pMainDesign\ListMatter(),    TargetMatter)
      *pTargetPin  = SelectElement(*pListMatter\ListPinPrefer(), TargetPrefer)
      
      *pListDupont.__Dupont_BaseInfo = AddElement(*pMainDesign\ListDupont())
      With  *pListDupont
         \ObjectType  = #Object_Dupont
         \DupontColor = DupontColor
         \pOriginPin  = *pOriginPin
         \pTargetPin  = *pTargetPin
         \pOriginPin\pOriginDupont = *pListDupont
         \pTargetPin\pTargetDupont = *pListDupont
         
         \X = PeekF(*MemData+Pos)   : Pos+4    
         \Y = PeekF(*MemData+Pos)   : Pos+4 
         \W = PeekF(*MemData+Pos)   : Pos+4    
         \H = PeekF(*MemData+Pos)   : Pos+4 
         \R = PeekF(*MemData+Pos)   : Pos+4 
         \B = PeekF(*MemData+Pos)   : Pos+4 
         
         \OriginPos\Direction = PeekW(*MemData+Pos)   : Pos+2    
         \OriginPos\X         = PeekF(*MemData+Pos)   : Pos+4    
         \OriginPos\Y         = PeekF(*MemData+Pos)   : Pos+4    
         \TargetPos\Direction = PeekW(*MemData+Pos)   : Pos+2    
         \TargetPos\X         = PeekF(*MemData+Pos)   : Pos+4    
         \TargetPos\Y         = PeekF(*MemData+Pos)   : Pos+4             
      EndWith
      CountDuNodes   = PeekW(*MemData+Pos)             : Pos+2     ;杜邦线颜色
      For x = 1 To CountDuNodes
         *pDuNode.__DuNode_BaseInfo = AddElement(*pListDupont\ListNodus())
         *pDuNode\Direction = PeekW(*MemData+Pos): Pos+2    
         *pDuNode\X = PeekF(*MemData+Pos)        : Pos+4    
         *pDuNode\Y = PeekF(*MemData+Pos)        : Pos+4    
      Next 
   Next
EndProcedure


;加载代码信息[MCDS]
Procedure Design_LoadFile_MCDS(*pMainDesign.__Design_MainInfo, *MemData, Pos)
   ProcedureReturn Pos
EndProcedure

;加载[设计文档]
Procedure Design_LoadFile(*pMainModule.__Module_MainInfo, FileName$, *pCallFunction)
   ;*pCallFunction 注意这里:
   ;基于源代码文件是相互独立的前提下,巧用CallFunctionFast()来调用下一层的源代码文件
   ;编辑文件结构: 文件头部[.MCT]+摘要信息[MSMY]+画布信息[MCVS]+电子元件信息[MOBJ]+杜邦线信息[MDPL]+代码信息[MCDS] 

   *MemData = Design_LoadFile_Check(FileName$)
   If *MemData = #Null : ProcedureReturn #False : EndIf 
   *pHeader.__Design_HeaderInfo = *MemData
   ;========== 创建新设稿 ==========
   *pMainDesign.__Design_MainInfo = AllocateStructure(__Design_MainInfo)
   *pMainDesign\DesignFlags$ = #DesignFlags$
   *pMainDesign\ActiveDupont\ObjectType = #Object_Dupont
   *pMainDesign\ActiveObject\ObjectType  = #Object_Active
   *pMainDesign\ActiveObject\ObjectName$ = "活动组"
   *pMainDesign\pMainModule  = *pMainModule
   *pMainDesign\pCurrDuNode  = #Null
   
   Debug "[Design] Load: "+FileName$, #DebugLevel_Design
   Design_LoadFile_MSMY(*pMainDesign, *MemData, *pHeader\DimIdxAddr[#Design_Block_MSMY]+4)                  ;摘要信息[MSMY] 
   If *pMainDesign\BinaryVersion <> #Binary_Version
      FreeMemory(*MemData)
      Design_Release(*pMainDesign)
      _EngineErrorCode = #Design_Error_3005
      Debug "[Design] Load 出错 ************** ", #DebugLevel_Design
      ProcedureReturn #False
   EndIf 
   Design_LoadFile_MCVS(*pMainDesign, *MemData, *pHeader\DimIdxAddr[#Design_Block_MCVS]+4, *pCallFunction)  ;画布信息[MCVS]
   If *pMainDesign\pMainCanvas = #Null
      FreeMemory(*MemData)
      Design_Release(*pMainDesign)
      _EngineErrorCode = #Design_Error_3001
      Debug "[Design] Load 出错 ************** ", #DebugLevel_Design
      ProcedureReturn #False
   EndIf                                        ;    
   Design_LoadFile_MOBJ(*pMainDesign, *MemData, *pHeader\DimIdxAddr[#Design_Block_MOBJ]+4, *pMainModule)    ;元件信息[MOBJ]
   Design_LoadFile_MDPL(*pMainDesign, *MemData, *pHeader\DimIdxAddr[#Design_Block_MDPL]+4)   ;杜邦线信息[MDPL]
   Design_LoadFile_MCDS(*pMainDesign, *MemData, *pHeader\DimIdxAddr[#Design_Block_MCDS]+4)   ;代码信息[MCDS]
   Debug "[Design] Load CountObject = "+ListSize(*pMainDesign\pListObject()), #DebugLevel_Design
   Debug "[Design] Load CountMatter = "+ListSize(*pMainDesign\ListMatter()), #DebugLevel_Design
   Debug "[Design] Load CountString = "+ListSize(*pMainDesign\ListString()), #DebugLevel_Design
   Debug "[Design] Load CountGroups = "+ListSize(*pMainDesign\ListGroups()), #DebugLevel_Design
   Debug "[Design] Load <<=============== ", #DebugLevel_Design
   ProcedureReturn *pMainDesign
EndProcedure


;-
Procedure Design_Thumbnail(*pMainModule.__Module_MainInfo, FileName$)
   *MemData = Design_LoadFile_Check(FileName$)
   If *MemData = #Null : ProcedureReturn #False : EndIf 
   *pHeader.__Design_HeaderInfo = *MemData
   
   With *pMainModule
      Pos = *pHeader\DimIdxAddr[#Design_Block_MSMY]+4 + 4*6
;       \BinaryVersion    =  PeekF(*MemData+Pos)     : Pos+4 ; 版本号
;       \CreateDate       =  PeekL(*MemData+Pos)     : Pos+4 ; 创建时间
;       \ModifyDate       =  PeekL(*MemData+Pos)     : Pos+4 ; 创建时间
;       \MatterNameIndex  =  PeekL(*MemData+Pos)     : Pos+4 ;
;       \StringNameIndex  =  PeekL(*MemData+Pos)     : Pos+4 ;
;       \GroupsNameIndex  =  PeekL(*MemData+Pos)     : Pos+4 ;
      ImageSize = PeekL(*MemData+Pos)                 : Pos+4 
      *pEncode.long = *MemData+Pos
      *pEncode\l = *pEncode\l ! #Design_Flags_MSMY
      If IsImage(\ThumbnailID) : FreeImage(\ThumbnailID) : EndIf 
      \ThumbnailID = CatchImage(#PB_Any, *MemData+Pos)
      hThumbnail = ImageID(\ThumbnailID)
   EndWith
   ProcedureReturn hThumbnail
   
EndProcedure
   
   
;-
;- ******** [Error] ******** 
;出错捕获
Procedure$ Design_ErrorMessage(ErrorCode)
   Select ErrorCode
      Case #Design_Error_3001 : ErrorMessage$ = #Design_Error_3001$
      Case #Design_Error_3002 : ErrorMessage$ = #Design_Error_3002$
      Case #Design_Error_3003 : ErrorMessage$ = #Design_Error_3003$
      Case #Design_Error_3004 : ErrorMessage$ = #Design_Error_3004$
      Case #Design_Error_3005 : ErrorMessage$ = #Design_Error_3005$
      Case #Design_Error_3006 : ErrorMessage$ = #Design_Error_3006$
      Case #Design_Error_3007 : ErrorMessage$ = #Design_Error_3007$
      Case #Design_Error_3008 : ErrorMessage$ = #Design_Error_3008$
      Case #Design_Error_3009 : ErrorMessage$ = #Design_Error_3009$
      Case #Design_Error_3010 : ErrorMessage$ = #Design_Error_3010$
      Case #Design_Error_3011 : ErrorMessage$ = #Design_Error_3011$
   EndSelect
   ProcedureReturn ErrorMessage$
EndProcedure









; IDE Options = PureBasic 5.62 (Windows - x86)
; CursorPosition = 897
; FirstLine = 692
; Folding = DA+-f0
; EnableXP