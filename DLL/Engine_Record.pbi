;*****************************************
;******** 单片机仿真模拟器内核引擎 ********
;********    迷路仟 2020.03.02    ********
;*****************************************
;【Engine_Record.ipb】 ;历史记录相关的源代码文件






;- [Include]
XIncludeFile "Engine_Design.pbi"

;- [Enumeration]
Enumeration 1
   #RecordEvent_CreateMatter  ;添加元件
   #RecordEvent_CreateString  ;添加文本
   #RecordEvent_CreateDupont  
   #RecordEvent_MergerGroups  ;组合
   #RecordEvent_DivideGroups  ;解散
   ;========================
   #RecordEvent_ModifyMatter
   #RecordEvent_ModifyString
   #RecordEvent_ModifyDupont
   #RecordEvent_ModifyGroups
   #RecordEvent_ModifyActive
   ;========================
   #RecordEvent_DeleteMatter
   #RecordEvent_DeleteString
   #RecordEvent_DeleteDupont
   #RecordEvent_DeleteGroups
   #RecordEvent_DeleteActive
   ;========================
   ;对齐,
EndEnumeration

;- [Structure]
Structure __Record_ItemInfo
   EventType.l
   ObjectID.l              ;对象ID, Matter/String/Dupont/Active使用
   List ListObjectID.l()  ;Active和Groups使用
   *pMemObject
EndStructure 


Structure __Object_ItemInfo
   *pListObject   
   ObjectType.l
EndStructure

Structure __Record_MainInfo

   List ListObject.__Object_ItemInfo()    
   ;用来对标__Design_MainInfo\pListObject.__Groups_BaseInfo(),
   ;并记录到具体某个Matter/String/Dupont, 
   ;当出现对象被删除后,ListObject()\pListObject=#Null, ObjectType不变
   ;当出现对象需要还原时,ListObject()\pListObject=新建的对象(由ObjectType诀定新建的对象类型)
   List ListRecord.__Record_ItemInfo() 
   ;用来记录编辑事件的记录.
   RecordIndex.l
   *pListRecord.__Record_ItemInfo
EndStructure

;- [Global]
Global _Record.__Record_MainInfo


;-
;- ******** [Save] ********
Procedure Record_SaveMatter(*pMatterID.__Matter_BaseInfo, *MemData, *pRecordObject)
   With *pMatterID
      PokeL(*MemData+Pos, *pRecordObject) : Pos+4 
      PokeA(*MemData+Pos, \pMapModule)    : Pos+1 
      PokeW(*MemData+Pos, \RotateIdx)     : Pos+2             
      PokeA(*MemData+Pos, \SymmetryIdx)   : Pos+1             
      PokeA(*MemData+Pos, \Reserve)       : Pos+1
      PokeF(*MemData+Pos, \X)             : Pos+4   
      PokeF(*MemData+Pos, \Y)             : Pos+4 
   EndWith
   ProcedureReturn Pos
EndProcedure

Procedure Record_SaveString(*pStringID.__String_BaseInfo, *pRecordObject)
   *MemData = AllocateMemory(10240)
   With *pStringID
      PokeL(*MemData+Pos, *pRecordObject)          : Pos+4 
      PokeF(*MemData+Pos, \X)                      : Pos+4  
      PokeF(*MemData+Pos, \Y)                      : Pos+4 
      PokeL(*MemData+Pos, \FontColor)              : Pos+4 
      PokeL(*MemData+Pos, \BackColor)              : Pos+4 
      PokeW(*MemData+Pos, \FontSize)               : Pos+2 
      PokeW(*MemData+Pos, \FontStyle)              : Pos+2 
      Lenght = StringByteLength(\Text$, #PB_Ascii)+1               
      PokeW(*MemData+Pos, Lenght)                  : Pos+2
      PokeS(*MemData+Pos, \Text$, -1, #PB_Ascii)   : Pos+Lenght 
   EndWith  
   *MemData = ReAllocateMemory(*MemData, Pos)
   ProcedureReturn *MemData
EndProcedure

Procedure Record_SaveDupont(*pDupontID.__Dupont_BaseInfo, *pRecordObject)
   *MemData = AllocateMemory(10240)
   With *pDupontID
      PokeL(*MemData+Pos, *pRecordObject)             : Pos+4 
      PokeL(*MemData+Pos, \DupontColor)               : Pos+4  ;杜邦线颜色
      PokeL(*MemData+Pos, \pOriginPin\pParentMatter)  : Pos+4  ;写入ListMatter()的索引号
      PokeL(*MemData+Pos, \pOriginPin)                : Pos+4  ;写入ListPinPrefer()的索引号
      PokeL(*MemData+Pos, \pTargetPin\pParentMatter)  : Pos+4  ;写入ListMatter()的索引号
      PokeL(*MemData+Pos, \pTargetPin)                : Pos+4  ;写入ListPinPrefer()的索引号 
         
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
   
      CountNodus  = ListSize(\ListNodus())
      PokeW(*MemData+Pos, CountNodus)          : Pos+2  ;杜邦线节点数量
      ForEach \ListNodus()
         *pDuNode.__DuNode_BaseInfo = \ListNodus()
         PokeW(*MemData+Pos, *pDuNode\Direction): Pos+2
         PokeF(*MemData+Pos, *pDuNode\X)        : Pos+4 
         PokeF(*MemData+Pos, *pDuNode\Y)        : Pos+4 
      Next 
   EndWith
   *MemData = ReAllocateMemory(*MemData, Pos)
   ProcedureReturn *MemData
EndProcedure

Procedure Record_SaveGroups(*pListGroups.__Groups_BaseInfo, *pRecordObject)
   *MemData = AllocateMemory(10240)
   With *pListGroups
      PokeL(*MemData+Pos, *pRecordObject)          : Pos+4 
      PokeF(*MemData+Pos, \X)                      : Pos+4  
      PokeF(*MemData+Pos, \Y)                      : Pos+4 
      PokeF(*MemData+Pos, \W)                      : Pos+4  
      PokeF(*MemData+Pos, \H)                      : Pos+4 
      Count = ListSize(\pListObject())
      PokeW(*MemData+Pos, Count)                   : Pos+2 
      ForEach \pListObject()
         PokeL(*MemData+Pos, \pListObject())       : Pos+4 
      Next 
   EndWith
   *MemData = ReAllocateMemory(*MemData, Pos)
   ProcedureReturn *MemData
EndProcedure

;-
;- ******** [] ********
Procedure Record_AddEvent_CreateMatter(*pObjectID.__Object_BaseInfo)
   With _Record
      AddElement(\ListObject())
      \ListObject()\pListObject = *pObjectID
      \ListObject()\ObjectType  = #Object_Matter
      *pMemObject = AllocateMemory(10240)
      MemorySize  = Record_SaveMatter(*pObjectID, *pMemObject, @\ListObject())
      *pMemObject = AllocateMemory(*pMemObject, MemorySize)
   EndWith
   ProcedureReturn *pMemObject
EndProcedure

Procedure Record_AddEvent_CreateString(*pObjectID.__Object_BaseInfo)
   With _Record
      AddElement(\ListObject())
      \ListObject()\pListObject = *pObjectID
      \ListObject()\ObjectType  = #Object_String
      *pMemObject = AllocateMemory(10240)
      MemorySize  = Record_SaveMatter(*pObjectID, *pMemObject, @\ListObject())
      *pMemObject = AllocateMemory(*pMemObject, MemorySize)
   EndWith
   ProcedureReturn *pMemObject
EndProcedure

Procedure Record_AddEvent_CreateDupont(*pObject.__Object_BaseInfo)
   With _Record
      AddElement(\ListObject())
      \ListObject()\pListObject = *pObject
      \ListObject()\ObjectType  = #Object_Dupont
      *pMemObject = Record_SaveDupont(*pObject, @\ListObject())
   EndWith
   ProcedureReturn *pMemObject
EndProcedure

Procedure Record_AddEvent_MergerGroups(*pObject.__Object_BaseInfo)
   With _Record
      AddElement(\ListObject())
      \ListObject()\pListObject = *pObject
      \ListObject()\ObjectType  = #Object_Groups
      *pMemObject = Record_SaveGroups(*pObject, @\ListObject())
   EndWith
   ProcedureReturn *pMemObject
EndProcedure

Procedure Record_AddEvent_DivideGroups(*pObject.__Object_BaseInfo)
   With _Record
      AddElement(\ListObject())
      \ListObject()\pListObject = *pObject
      \ListObject()\ObjectType  = #Object_Groups
      *pMemObject = Record_SaveGroups(*pObject, @\ListObject())
   EndWith
   ProcedureReturn *pMemObject
EndProcedure

;-
Procedure Record_AddEvent_ModifyMatter(*pObjectID.__Object_BaseInfo)
   With _Record
      ForEach \ListObject()
         If \ListObject()\pListObject = *pObjectID
            *pMemObject = AllocateMemory(10240)
            MemorySize  = Record_SaveMatter(*pObjectID, *pMemObject, @\ListObject())
            *pMemObject = AllocateMemory(*pMemObject, MemorySize)
         EndIf 
      Next 
   EndWith   
   ProcedureReturn *pMemObject
EndProcedure



Procedure Record_AddEvent(EventType, *pObject.__Object_BaseInfo)
   With _Record
      If \RecordIndex < ListSize(\ListRecord())
         ForEach \ListRecord()
            Index + 1
            If Index > \RecordIndex 
               FreeImage(\ListRecord()\pMemObject)
               DeleteElement(\ListRecord())
            EndIf 
         Next 
      EndIf 
      \pListRecord = AddElement(\ListRecord())
      \RecordIndex + 1
   EndWith 
   
   With _Record\pListRecord
      
      Select EventType
         Case #RecordEvent_CreateMatter : \pMemObject = Record_AddEvent_CreateMatter(*pObject)
         Case #RecordEvent_CreateString : \pMemObject = Record_AddEvent_CreateString(*pObject)
         Case #RecordEvent_CreateDupont : \pMemObject = Record_AddEvent_CreateDupont(*pObject)
         Case #RecordEvent_MergerGroups : \pMemObject = Record_AddEvent_MergerGroups(*pObject)
         Case #RecordEvent_DivideGroups : \pMemObject = Record_AddEvent_DivideGroups(*pObject)
         ;===============================
         Case #RecordEvent_ModifyMatter : \pMemObject = Record_AddEvent_ModifyMatter(*pObject)
         Case #RecordEvent_ModifyString
         Case #RecordEvent_ModifyDupont
         Case #RecordEvent_ModifyGroups
         ;===============================
         Case #RecordEvent_DeleteMatter
         Case #RecordEvent_DeleteString
         Case #RecordEvent_DeleteDupont
         Case #RecordEvent_DeleteGroups
         ;===============================            
      EndSelect
      \EventType = EventType
   EndWith   
EndProcedure






















; IDE Options = PureBasic 5.62 (Windows - x86)
; CursorPosition = 40
; FirstLine = 29
; Folding = fM+
; EnableXP