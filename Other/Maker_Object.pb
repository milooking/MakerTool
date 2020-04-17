

;    [MapModule]
; 　　　↓               [CanvasObject] ┐
; [ListMatter()] ┐                     │
; 　　　↓　　　　├→ [*pListObject()] ├→ [*pCurrObject]
;  [MapGroups()] ┘                     │
;                        [ActiveObject] ┘

; Object[对象],Canvas[画布],Matter[单元],Groups[单元组],Module[模块]
; *pListObject(): [模块对象指针], 具有层级关系, 关系画布上的[实体对象]上下层关系
; CanvasObject: [画布对象],关系到鼠标选择的选框事件
; ActiveObject: [活动对象],当前鼠标选中的多个*pListObject()
; MapGroups() : [模块单元组],由多个ListMatter()组成
; ListMatter(): [模块单元],由Module决定其属性
; MapModule() : [模块单元],通过加载[Module.bin]获取属性



;- [Constant]
;{
#ActiveGroup$ = "ActiveGroup"
;指针方向
#Direction_Up     = $000001
#Direction_Right  = $000002
#Direction_Down   = $000004
#Direction_Left   = $000008

;引脚功能
#ModulePin_VCC    = $01
#ModulePin_GND    = $02
#ModulePin_DO     = $04
#ModulePin_AO     = $08
#ModulePin_PIN    = $FF
#Prefer_Module$   = "Module.bin"

;各种控件标志
#Object_None      = 0
#Object_Canvas    = 1
#Object_Matter    = 2
#Object_Groups    = 3

#Object_Align_Left   = $1
#Object_Align_Right  = $2
#Object_Align_Center = $4
#Object_Traverse     = $8

#Object_Align_Top    = $10
#Object_Align_Bottom = $20
#Object_Align_Middle = $40
#Object_Vertical     = $80

#Layer_Floor_Top     = 1
#Layer_Floor_Bottom  = 2
#Layer_Floor_Prev    = 3
#Layer_Floor_Next    = 4
;}

;- [Enumeration]
; [实物单元]旋转角度
Enumeration
   #Object_Rotate_000
   #Object_Rotate_090
   #Object_Rotate_180
   #Object_Rotate_270
   #Object_Rotate_Count
EndEnumeration

;- [Structure]
;设置文件头部结构
Structure __Module_HeaderInfo
   Flags.q        ; 标志
   HeadSize.w     ; 头部大小
   NoteAddr.w     ; 备注地址
   Version.f      ; 版本号
   IdxCount.l     ; 索引数量
   IdxAddr.q      ; 索引地址
   CreateTime.l   ; 创建日期
   ModifyTime.l   ; 修改日期
   AddCount.l     ; 新增次数
   MD5.b[32]      ; ＭＤ5
   Keep.l
EndStructure

;[模块类型]引脚/插口的基本结构
Structure __Module_PinSocket
   LinkType.l     ;接线类型
   Direction.w    ;引脚方向
   PinGroup.w     ;引脚组编号
   OffsetX.w      ;引脚相对位置
   OffsetY.w      ;引脚相对位置   
   OffsetW.w      ;引脚相对位置
   OffsetH.w      ;引脚相对位置
   PinColor.l     ;引脚颜色
   *pParentModule.__Module_BaseInfo
EndStructure

;多个摆放方向上的[模块类型]基本结构
Structure __Module_Direction
   ImageID.l      ;模块图像ID
   ImageW.w       ;模块图像大小
   ImageH.w       ;模块图像大小
   List ListModulePins.__Module_PinSocket()
EndStructure

;[模块类型]基本信息结构
Structure __Module_BaseInfo
   ModuleType$       ;模块类型
   ModuleName$       ;模块名称
   ModuleImage$      ;模块图像
   DimRotate.__Module_Direction[#Object_Rotate_Count]
EndStructure

;[模块单元]引脚/插口的基本结构
Structure __Matter_PinSocket
   Direction.l   
   *pOriginPin.__Module_PinSocket
   *pTargetPin.__Matter_PinSocket
EndStructure

;[实物单元]基本信息结构
Structure __Object_BaseInfo
   ObjectType.l
   X.w
   Y.w
   W.w
   H.w
   R.w
   B.w 
   OffsetX.w
   OffsetY.w
EndStructure

;[模块单元]基本信息结构
Structure __Matter_BaseInfo Extends __Object_BaseInfo
   *pModule.__Module_BaseInfo
   *pRotate.__Module_Direction
   RotateIdx.l
   AliasName$
   List ListMatterPins.__Matter_PinSocket()
EndStructure

;[模块单元组]基本信息结构
Structure __Groups_BaseInfo Extends __Object_BaseInfo
   List *pListMatter.__Matter_BaseInfo()
EndStructure

Structure __Gadget_Disable
   FirstFloor.b   
   FinalFloor.b
EndStructure

Structure __MainObject
   Map MapModule.__Module_BaseInfo()         ;[模块类型]映射,用来加载[Module.bin]中的电子模块设置
   Map MapGroups.__Groups_BaseInfo()         ;[模块单元组]映射,用来记录各种[模块单元]的组合
   List ListMatter.__Matter_BaseInfo()       ;[模块单元]映射,
   List *pListObject.__Object_BaseInfo()     ;[模块对象指针]链表,用来指向[模块单元]或[模块单元组]
   CanvasObject.__Object_BaseInfo            ;鼠标选框
   ActiveObject.__Groups_BaseInfo            ;光标选中的[实物单元],即[活动组], [实物单元]按原来的层级关系,但选框及动作按[活动组]来
   *pCurrObject.__Object_BaseInfo            ;当前选中状态下的[模块单元]或[模块单元组], *pCurrObject或以指向ActiveObject,
   ;=============
   *pSelectModule.__Module_BaseInfo
   SelStartPos.Point
   Disable.__Gadget_Disable
   IsMouseDown.b
   IsAddMatter.b
EndStructure

;- [Global]
Global _Object.__MainObject

;-
;- **********[Procedure]**********
;获取旋转的方向
Procedure.w Fun_GetDirection(InitDirection, Rotate)
   Direction = InitDirection << Rotate
   If Direction > 8 
      Direction = (Direction >> 4) | (Direction & $0F)
   EndIf
   ProcedureReturn Direction   
EndProcedure

;添加[模块单元],返回_ListMatter()指针
Procedure Fun_AddMatter(*pModule.__Module_BaseInfo, X, Y, RotateIdx)
   *pMatter.__Matter_BaseInfo = AddElement(_Object\ListMatter()) 
   With *pMatter
      \ObjectType = #Object_Matter
      \RotateIdx  = RotateIdx
      \pModule    = *pModule
      \pRotate    = *pModule\DimRotate[\RotateIdx]
      \X = X
      \Y = Y
      \W = \pRotate\ImageW
      \H = \pRotate\ImageH
      \R = \X+\W
      \B = \Y+\H
      \AliasName$ = *pModule\ModuleName$
      ForEach \pRotate\ListModulePins()
         AddElement(\ListMatterPins())
         \ListMatterPins()\Direction  = \pRotate\ListModulePins()\Direction
         \ListMatterPins()\pOriginPin = \pRotate\ListModulePins()
      Next 
   EndWith
   AddElement(_Object\pListObject())
   _Object\pListObject() = *pMatter
   ProcedureReturn *pMatter
EndProcedure

;清空[活动组]
Procedure Fun_ClearActiveGroup()
   With _Object\ActiveObject
      ClearList(\pListMatter())
      \X = 09999
      \Y = 09999 
      \R = -9999
      \B = -9999
      \ObjectType = #Object_None
   EndWith
EndProcedure

;向[活动组]添加[模块单元]
Procedure Fun_AddActiveGroup(*pMatter.__Matter_BaseInfo)
   If *pMatter = #Null : ProcedureReturn : EndIf 
   AddElement(_Object\ActiveObject\pListMatter())
   With _Object\ActiveObject
      \pListMatter() = *pMatter
      If \X > *pMatter\X : \X = *pMatter\X : EndIf 
      If \Y > *pMatter\Y : \Y = *pMatter\Y : EndIf 
      If \R < *pMatter\R : \R = *pMatter\R : EndIf 
      If \B < *pMatter\B : \B = *pMatter\B : EndIf
      \W = \R - \X
      \H = \B - \Y
      \ObjectType = #Object_Groups
   EndWith
EndProcedure


;-
;[模块类型]初始化
Procedure Object_Initial()
   
   FileSize = FileSize(#Prefer_Module$) 
   If FileSize < 0
      MessageRequester("出错代码: 1000", "["+#Prefer_Module$+"]文件不存在或被占用.")
      ProcedureReturn #False
   EndIf    
   
   *MemData = mcsFileLoad_(#Prefer_Module$)
   *pHeader.__Module_HeaderInfo = *MemData
   If *pHeader\Flags <> $C3D6E8C9E9BFA3C4
      FreeMemory(*MemData)
      MessageRequester("出错代码: 1001", "["+#Prefer_Module$+"]文件标志有误.")
      ProcedureReturn #False
   EndIf 
   
   If *pHeader\Version <> 1.00
      FreeMemory(*MemData)
      MessageRequester("出错代码: 1002", "["+#Prefer_Module$+"]文件版本有误.")
      ProcedureReturn #False
   EndIf 
   
   UseMD5Fingerprint()   
   DataMD5$ = Fingerprint(*MemData+*pHeader\NoteAddr, FileSize-*pHeader\NoteAddr, #PB_Cipher_MD5)
   FileMD5$ = PeekS(@*pHeader\MD5, -1,  #PB_Ascii)
   
   If DataMD5$ <> FileMD5$
      FreeMemory(*MemData)
      MessageRequester("出错代码: 1003", "["+#Prefer_Module$+"]文件数据受损.")
      ProcedureReturn #False
   EndIf 
   
   UsePNGImageDecoder()
   CopySize = 24
   Pos = *pHeader\IdxAddr
   For k = 1 To *pHeader\IdxCount
      Lenght  = PeekA(*MemData+Pos)                               : Pos+1 
      MapKey$ = PeekS(*MemData+Pos, -1, #PB_Ascii)                : Pos+Lenght
      
      _Object\MapModule(MapKey$)    
      *pModule.__Module_BaseInfo = _Object\MapModule()
      
      Lenght               = PeekA(*MemData+Pos)                  : Pos+1 
      *pModule\ModuleName$ = PeekS(*MemData+Pos, -1, #PB_Ascii)   : Pos+Lenght      

      *pRotate.__Module_Direction = *pModule\DimRotate[#Object_Rotate_000]
      *pRotate\ImageW = PeekW(*MemData+Pos)                       : Pos+2
      *pRotate\ImageH = PeekW(*MemData+Pos)                       : Pos+2
      PinsCount       = PeekW(*MemData+Pos)                       : Pos+2
      For i = 1 To PinsCount
         AddElement(*pRotate\ListModulePins())
         CopyMemory_(*pRotate\ListModulePins(),*MemData+Pos,CopySize): Pos+CopySize
         *pRotate\ListModulePins()\pParentModule = *pModule
      Next 
      ImageSize = PeekL(*MemData+Pos)                          : Pos+4
      *pRotate\ImageID = CatchImage(#PB_Any, *MemData+Pos)     : Pos+ImageSize
      
      If *pRotate\ImageID = #Null
         FreeMemory(*MemData)
         MessageRequester("出错代码: 1004", "["+#Prefer_Module$+"]文件数据受损.")
         ProcedureReturn #False
      EndIf 
      
      ;旋转90°
      *pCopyRotate.__Module_Direction = *pModule\DimRotate[#Object_Rotate_090]
      *pCopyRotate\ImageW =  *pRotate\ImageH
      *pCopyRotate\ImageH =  *pRotate\ImageW
      ForEach *pRotate\ListModulePins()
         *pCopyPins.__Module_PinSocket = AddElement(*pCopyRotate\ListModulePins())
         With *pRotate\ListModulePins()
            *pCopyPins\pParentModule = \pParentModule
            *pCopyPins\LinkType = \LinkType
            *pCopyPins\Direction= Fun_GetDirection(\Direction, #Object_Rotate_090) 
            *pCopyPins\PinColor = \PinColor
            *pCopyPins\PinGroup = \PinGroup
            *pCopyPins\OffsetX  = *pCopyRotate\ImageW-\OffsetY    ;重新计算引脚相对位置
            *pCopyPins\OffsetY  = *pCopyRotate\ImageH-\OffsetX    ;重新计算引脚相对位置
            *pCopyPins\OffsetW  = -\OffsetH    ;重新计算引脚相对位置
            *pCopyPins\OffsetH  = -\OffsetW    ;重新计算引脚相对位置
         EndWith
      Next 
      *pCopyRotate\ImageID = CreateImage(#PB_Any, *pRotate\ImageH, *pRotate\ImageW, 32, #PB_Image_Transparent)
      If StartVectorDrawing(ImageVectorOutput(*pCopyRotate\ImageID))
         RotateCoordinates(0, 0, 090) 
         MovePathCursor(0, -*pRotate\ImageH)   
         DrawVectorImage(ImageID(*pRotate\ImageID))
         StopVectorDrawing()
      EndIf 

      ;旋转180°
      *pCopyRotate.__Module_Direction = *pModule\DimRotate[#Object_Rotate_180]
      *pCopyRotate\ImageW =  *pRotate\ImageW
      *pCopyRotate\ImageH =  *pRotate\ImageH
      ForEach *pRotate\ListModulePins()
         *pCopyPins.__Module_PinSocket = AddElement(*pCopyRotate\ListModulePins())
         With *pRotate\ListModulePins()
            *pCopyPins\pParentModule = \pParentModule
            *pCopyPins\LinkType = \LinkType
            *pCopyPins\Direction= Fun_GetDirection(\Direction, #Object_Rotate_180) 
            *pCopyPins\PinColor = \PinColor
            *pCopyPins\PinGroup = \PinGroup
            *pCopyPins\OffsetX  = *pCopyRotate\ImageW-\OffsetX   ;重新计算引脚相对位置
            *pCopyPins\OffsetY  = *pCopyRotate\ImageH-\OffsetY   ;重新计算引脚相对位置
            *pCopyPins\OffsetW  = -\OffsetW    ;引脚相对位置
            *pCopyPins\OffsetH  = -\OffsetH    ;引脚相对位置
         EndWith
      Next 
      *pCopyRotate\ImageID = CreateImage(#PB_Any, *pRotate\ImageW, *pRotate\ImageH, 32, #PB_Image_Transparent)
      If StartVectorDrawing(ImageVectorOutput(*pCopyRotate\ImageID))
         RotateCoordinates(0, 0, 180) 
         MovePathCursor(-*pRotate\ImageW, -*pRotate\ImageH)
         DrawVectorImage(ImageID(*pRotate\ImageID))
         StopVectorDrawing()
      EndIf 
      
      ;旋转270°
      *pCopyRotate.__Module_Direction = *pModule\DimRotate[#Object_Rotate_270]
      *pCopyRotate\ImageW =  *pRotate\ImageH
      *pCopyRotate\ImageH =  *pRotate\ImageW
      ForEach *pRotate\ListModulePins()
         *pCopyPins.__Module_PinSocket = AddElement(*pCopyRotate\ListModulePins())
         With *pRotate\ListModulePins()
            *pCopyPins\pParentModule = \pParentModule
            *pCopyPins\LinkType = \LinkType
            *pCopyPins\Direction= Fun_GetDirection(\Direction, #Object_Rotate_270) 
            *pCopyPins\PinColor = \PinColor
            *pCopyPins\PinGroup = \PinGroup
            *pCopyPins\OffsetX  = \OffsetY    ;引脚相对位置
            *pCopyPins\OffsetY  = \OffsetX    ;引脚相对位置
            *pCopyPins\OffsetW  = \OffsetH    ;重新计算引脚相对位置
            *pCopyPins\OffsetH  = \OffsetW    ;重新计算引脚相对位置
         EndWith
      Next 
      *pCopyRotate\ImageID = CreateImage(#PB_Any, *pRotate\ImageH, *pRotate\ImageW, 32, #PB_Image_Transparent)
      If StartVectorDrawing(ImageVectorOutput(*pCopyRotate\ImageID))
         RotateCoordinates(0, 0, 270) 
         MovePathCursor(-*pRotate\ImageW, 0)   
         DrawVectorImage(ImageID(*pRotate\ImageID))
         StopVectorDrawing()
      EndIf 
   Next 
   FreeMemory(*MemData)

   _Object\CanvasObject\ObjectType = #Object_Canvas
   _Object\ActiveObject\ObjectType = #Object_Groups
   ProcedureReturn #True
EndProcedure

;[模块类型]注销
Procedure Object_Release()
   ForEach _Object\MapModule()
      For Index = 0 To #Object_Rotate_Count-1
         With _Object\MapModule()\DimRotate[Index]
            If IsImage(\ImageID) : FreeImage(\ImageID) : EndIf
            FreeList(\ListModulePins())
         EndWith
      Next 
   Next 
   FreeMap(_Object\MapModule())
EndProcedure

;选择[模块类型]
Procedure Object_Select(ModuleType$)
   _Object\MapModule(ModuleType$)
   _Object\pSelectModule = _Object\MapModule()
   ProcedureReturn _Object\MapModule()
EndProcedure

;对齐对象
Procedure Object_Alignment(Alignment)
   If _Object\ActiveObject = #Null : ProcedureReturn #False : EndIf
   *pGroups.__Groups_BaseInfo = _Object\ActiveObject   
   Count = ListSize(*pGroups\pListMatter())
   If Count < 2 : ProcedureReturn #False : EndIf 
   Count-1
   X = 09999 : Y = 09999 : R = -9999 : B = -9999

   With *pGroups\pListMatter()
      Select Alignment & $F
         Case #Object_Align_Left
            X = *pGroups\X
            ForEach *pGroups\pListMatter()
               \X = *pGroups\X
               \R = \X+\W
               If Y > \Y : Y = \Y : EndIf 
               If R < \R : R = \R : EndIf 
               If B < \B : B = \B : EndIf
            Next 
            IsAlign = #True
         Case #Object_Align_Right
            R = *pGroups\R
            ForEach *pGroups\pListMatter()
               \R = *pGroups\R
               \X = \R-\W
               If X > \X : X = \X : EndIf 
               If Y > \Y : Y = \Y : EndIf 
               If B < \B : B = \B : EndIf
            Next 
            IsAlign = #True
         Case #Object_Align_Center
            Center = *pGroups\X+*pGroups\W/2
            ForEach *pGroups\pListMatter()
               \X = Center -\W/2
               \R = \X+\W
               If X > \X : X = \X : EndIf 
               If Y > \Y : Y = \Y : EndIf 
               If R < \R : R = \R : EndIf 
               If B < \B : B = \B : EndIf
            Next 
            IsAlign = #True
            
         Case #Object_Traverse
            Distance.f = *pGroups\W
            ForEach *pGroups\pListMatter()
               Distance- \W
            Next 
            Distance / Count
            Pos.f = *pGroups\X 
            ForEach *pGroups\pListMatter()
               \X = Pos
               \R = \X+\W
               Pos+\W+Distance
            Next 
            IsAlign = #True            
            ProcedureReturn #True
      EndSelect
      
      Select Alignment & $F0
         Case #Object_Align_Top
            Y = *pGroups\Y
            ForEach *pGroups\pListMatter()
               \Y = *pGroups\Y
               \B = \Y+\H
               If X > \X : X = \X : EndIf 
               If R < \R : R = \R : EndIf 
               If B < \B : B = \B : EndIf
            Next 
            IsAlign = #True
         Case #Object_Align_Bottom
            B = *pGroups\B
            ForEach *pGroups\pListMatter()
               \B = *pGroups\B
               \Y = \B-\H
               If X > \X : X = \X : EndIf 
               If Y > \Y : Y = \Y : EndIf 
               If R < \R : R = \R : EndIf 
            Next 
            IsAlign = #True
            
         Case #Object_Align_Middle
            Middle = *pGroups\Y+*pGroups\H/2
            ForEach *pGroups\pListMatter()
               \Y = Middle - \H/2
               \B = \Y+\H
               If X > \X : X = \X : EndIf 
               If Y > \Y : Y = \Y : EndIf 
               If R < \R : R = \R : EndIf 
               If B < \B : B = \B : EndIf
            Next 
            IsAlign = #True    
            
         Case #Object_Vertical
            Distance.f = *pGroups\H
            ForEach *pGroups\pListMatter()
               Distance- \H
            Next 
            Distance / Count
            Pos.f = *pGroups\Y 
            ForEach *pGroups\pListMatter()
               \Y = Pos
               \B = \Y+\H
               Pos+\H+Distance
            Next 
            IsAlign = #True            
            ProcedureReturn #True
      EndSelect
   EndWith
   If IsAlign = #True
      *pGroups\X = X
      *pGroups\Y = Y
      *pGroups\R = R
      *pGroups\B = B
      *pGroups\W = R-X
      *pGroups\H = B-Y
      ProcedureReturn #True
   EndIf 
   ProcedureReturn #False
EndProcedure

;设置层级关系
Procedure Object_SetLayerState(State)
   If _Object\pCurrObject = #Null : ProcedureReturn #False : EndIf 
   If _Object\pCurrObject\ObjectType < 2 : ProcedureReturn #False : EndIf  
   
   Count = ListSize(_Object\pListObject())
   If Count < 2 : ProcedureReturn #False : EndIf 
   *pFirst = FirstElement(_Object\pListObject())
   *pFinal = LastElement(_Object\pListObject())
   *pObject = _Object\pCurrObject
   Select State
      Case #Layer_Floor_Top
         If *pObject = *pFinal : ProcedureReturn #False : EndIf 
         ForEach _Object\pListObject()
            If _Object\pListObject() = *pObject
               MoveElement(_Object\pListObject(), #PB_List_Last)
               ProcedureReturn #True
            EndIf 
         Next 
      Case #Layer_Floor_Bottom
         If *pObject = *pFirst : ProcedureReturn #False : EndIf 
         ForEach _Object\pListObject()
            If _Object\pListObject() = *pObject
               MoveElement(_Object\pListObject(), #PB_List_First)
               ProcedureReturn #True
            EndIf 
         Next          
         
      Case #Layer_Floor_Prev
         If *pObject = *pFinal : ProcedureReturn #False : EndIf 
         ForEach _Object\pListObject()
            If _Object\pListObject() = *pObject
               *pObject = @_Object\pListObject()
               NextElement(_Object\pListObject())
               MoveElement(_Object\pListObject(), #PB_List_Before, *pObject)
               ProcedureReturn #True
            EndIf 
         Next 

      Case #Layer_Floor_Next
         If *pObject = *pFirst : ProcedureReturn #False : EndIf 
         ForEach _Object\pListObject()
            If _Object\pListObject() = *pObject
               *pObject = @_Object\pListObject()
               PreviousElement(_Object\pListObject())
               MoveElement(_Object\pListObject(), #PB_List_After, *pObject)
               ProcedureReturn #True
            EndIf 
         Next 
   EndSelect
   ProcedureReturn #False
EndProcedure

;获取层级关系
Procedure Object_GetLayerState()
   If _Object\pCurrObject = #Null : ProcedureReturn -1 : EndIf 
   If _Object\pCurrObject\ObjectType < 2 : ProcedureReturn -1 : EndIf  
   *pObject = _Object\pCurrObject
   ForEach _Object\pListObject()
      If _Object\pListObject() = *pObject
         ProcedureReturn Index
      EndIf
      Index+1
   Next 
   ProcedureReturn -1
EndProcedure

;获取控件禁用状态
Procedure Object_GetDisable()
   ProcedureReturn @_Object\Disable
EndProcedure

;-
;绘制[实物单元]
Procedure Object_RefreshRedraw()
   ;绘制各种[实物单元]图像
   ForEach _Object\pListObject()
      Select _Object\pListObject()\ObjectType
         Case #Object_Matter
            *pMatter.__Matter_BaseInfo = _Object\pListObject()
            With *pMatter
               MovePathCursor(\X, \Y)
               DrawVectorImage(ImageID(\pRotate\ImageID))
            EndWith    
         Case #Object_Groups
            *pGroups.__Groups_BaseInfo = _Object\pListObject()
            ForEach *pGroups\pListMatter()
               With *pGroups\pListMatter()
                  MovePathCursor(\X, \Y)
                  DrawVectorImage(ImageID(\pRotate\ImageID))
               EndWith 
            Next 
      EndSelect
   Next
   
   If _Object\pCurrObject = #Null : ProcedureReturn : EndIf 
   Select _Object\pCurrObject\ObjectType
      Case #Object_Canvas
         With _Object\CanvasObject
            AddPathBox(\X, \Y, \W, \H)
            VectorSourceColor($FF808080)
            DashPath(1, 5)
         EndWith      
         NeedRefresh = #True
      Case #Object_Matter
         With _Object\pCurrObject
            AddPathBox(\X-2, \Y-2, \W+3, \H+3)
            VectorSourceColor($FF0000FF)
            DashPath(1, 5)
         EndWith      
         NeedRefresh = #True
      Case #Object_Groups
         With _Object\ActiveObject
            AddPathBox(\X-2, \Y-2, \W+3, \H+3)
            VectorSourceColor($FF0000FF)
            DashPath(1, 5)
         EndWith      
         NeedRefresh = #True         
   EndSelect
EndProcedure

;画布中鼠标左键按下事件
Procedure Object_Event_LeftButtonDown(X, Y, IsAddMatter=#False)
   
   If IsAddMatter
      _Object\IsMouseDown = #True
      _Object\IsAddMatter = #True
      ;画布光标选择画件
      _Object\pCurrObject = _Object\CanvasObject
      With _Object\CanvasObject
         \X = X
         \Y = Y
         \W = 0
         \H = 0
      EndWith
      _Object\Disable\FirstFloor = #False 
      _Object\Disable\FinalFloor = #True
      ProcedureReturn #False
   ElseIf _Object\pCurrObject
      Select _Object\pCurrObject\ObjectType
         Case #Object_Canvas
            With _Object\CanvasObject
               If \X <= X And X <=\R And \Y < Y And Y <\B
                  \OffsetX = X - \X
                  \OffsetY = Y - \Y
                  NeedRefresh = #True
               EndIf 
            EndWith  
            
         Case #Object_Matter
            With _Object\pCurrObject
               If \X <= X And X <=\R And \Y < Y And Y <\B
                  \OffsetX = X - \X
                  \OffsetY = Y - \Y
                  NeedRefresh = #True
               EndIf 
            EndWith 

         Case #Object_Groups
            With _Object\ActiveObject
               If \X <= X And X <=\R And \Y < Y And Y <\B
                  \OffsetX = X - \X
                  \OffsetY = Y - \Y
                  ForEach \pListMatter()
                     \pListMatter()\OffsetX = X - \pListMatter()\X
                     \pListMatter()\OffsetY = Y - \pListMatter()\Y
                  Next 
                  NeedRefresh = #True
               EndIf 
            EndWith               
      EndSelect 
      If NeedRefresh = #True
         _Object\IsMouseDown = #True
         ProcedureReturn NeedRefresh
      EndIf 
   EndIf 
   
   ;层级按键的可用和禁用状态初始化
   DisableFinal = #True
   DisableFirst = #True
   If ListSize(_Object\pListObject())
      *pFirst = FirstElement(_Object\pListObject())
      *pFinal = LastElement(_Object\pListObject())
   EndIf  
   ;判断光标是否活在[实物单元]上
   ForEach _Object\pListObject()
      With _Object\pListObject()
         If \X <= X And X <=\R And \Y < Y And Y <\B
            \OffsetX = X - \X
            \OffsetY = Y - \Y
            _Object\pCurrObject = _Object\pListObject()
            NeedRefresh = #True
            DisableFinal = Bool(@_Object\pListObject() = *pFinal)
            DisableFirst = Bool(@_Object\pListObject() = *pFirst)
         EndIf 
      EndWith
   Next 
   _Object\IsMouseDown = #True
   ;处理层级按键的可用和禁用状态
   If NeedRefresh = #True
      _Object\Disable\FirstFloor = DisableFirst   
      _Object\Disable\FinalFloor = DisableFinal
      ProcedureReturn NeedRefresh
   EndIf
   
   ;画布光标选择画件
   _Object\pCurrObject = _Object\CanvasObject
   With _Object\CanvasObject
      \X = X
      \Y = Y
      \W = 0
      \H = 0
   EndWith
   ProcedureReturn NeedRefresh
EndProcedure 

Procedure Object_Event_LeftButtonUp(X, Y)
   If _Object\IsMouseDown = #False : ProcedureReturn : EndIf 
   If _Object\pCurrObject = #Null  : ProcedureReturn : EndIf 
   _Object\IsMouseDown = #False
   
   If _Object\IsAddMatter = #True
      With _Object\CanvasObject
         *pMatter = Fun_AddMatter(_Object\pSelectModule, \X, \Y, #Object_Rotate_000)
      EndWith
      _Object\IsAddMatter = #False
      _Object\pCurrObject = *pMatter
      ProcedureReturn #True
   EndIf 
   Select _Object\pCurrObject\ObjectType
      Case #Object_Canvas
         StartX = _Object\CanvasObject\X
         StartY = _Object\CanvasObject\Y
         If X >= StartX : InvolveX = #True : EndIf 
         If Y >= StartY : InvolveY = #True : EndIf    
         Fun_ClearActiveGroup()
         ForEach _Object\pListObject()
            With _Object\pListObject()
               BoolX = Bool(InvolveX = #True  And \X >= StartX And \R <= X)
               BoolX | Bool(InvolveX = #False And \R >= X)
               BoolY = Bool(InvolveY = #True  And \Y >= StartY And \B <= Y)
               BoolY | Bool(InvolveY = #False And \B >= Y)
               If BoolX = #True And BoolY = #True
                  Select \ObjectType
                     Case #Object_Matter  
                        *pObject = _Object\pListObject()
                        Fun_AddActiveGroup(*pObject)
                        FindCount + 1
                     Case #Object_Groups
                        
                  EndSelect 
               EndIf 
            EndWith
         Next
         
         If FindCount = 0
            _Object\pCurrObject = #Null
         ElseIf FindCount = 1
            _Object\pCurrObject = *pObject
         Else 
            _Object\pCurrObject = _Object\ActiveObject
         EndIf 
         NeedRefresh = #True
         
      Case #Object_Matter
         With _Object\pCurrObject
            \X = X - \OffsetX
            \Y = Y - \OffsetY
            \R = \X+\W
            \B = \Y+\H
         EndWith   
         NeedRefresh = #True
      Case #Object_Groups
         NeedRefresh = #True
   EndSelect
   ProcedureReturn NeedRefresh
EndProcedure 

Procedure Object_Event_MouseMove(X, Y)
   If _Object\IsMouseDown = #False : ProcedureReturn : EndIf 
   If _Object\pCurrObject = #Null  : ProcedureReturn : EndIf 

   Select _Object\pCurrObject\ObjectType
      Case #Object_Canvas
         With _Object\CanvasObject
            \R = X
            \B = Y
            \W = \R-\X
            \H = \B-\Y
         EndWith      
         NeedRefresh = #True
         
      Case #Object_Matter
         With _Object\pCurrObject
            \X = X - \OffsetX
            \Y = Y - \OffsetY
            \R = \X+\W
            \B = \Y+\H
         EndWith      
         NeedRefresh = #True
         
      Case #Object_Groups
         With _Object\ActiveObject
            \X = X - \OffsetX
            \Y = Y - \OffsetY
            \R = \X+\W
            \B = \Y+\H
            ForEach \pListMatter()
               \pListMatter()\X = X - \pListMatter()\OffsetX
               \pListMatter()\Y = Y - \pListMatter()\OffsetY
               \pListMatter()\R = \pListMatter()\X+\pListMatter()\W
               \pListMatter()\B = \pListMatter()\Y+\pListMatter()\H
            Next 
         EndWith      
         NeedRefresh = #True
   EndSelect
   ProcedureReturn NeedRefresh
EndProcedure 

;-
;- ********** 测试程序 **********
CompilerIf  #PB_Compiler_IsMainFile = #True
   #winScreen = 0
   #cvsScreen = 1
   If Object_Initial() = #False : End : EndIf 
   *pModule = Object_Select("Tracking Module")
   Fun_AddMatter(*pModule, 100, 100, #Object_Rotate_000)
   
   If OpenWindow(#winScreen, 0, 0, 800, 600, "模块类初始化测试", #PB_Window_SystemMenu|#PB_Window_ScreenCentered)
      CanvasGadget(#cvsScreen, 0, 0, 800, 600, #PB_Canvas_ClipMouse)
      If StartVectorDrawing(CanvasVectorOutput(#cvsScreen))
         VectorSourceColor($FFFFFFFF)
         FillVectorOutput()
         Object_RefreshRedraw()
         StopVectorDrawing()
      EndIf
      Repeat
         WinEvent = WindowEvent()
         Select WinEvent 
            Case #PB_Event_CloseWindow : IsExitWindow = #True
            Case #PB_Event_Gadget
         EndSelect
      Until IsExitWindow = #True
   EndIf
   Object_Release()   ;注销
CompilerEndIf 









; IDE Options = PureBasic 5.62 (Windows - x86)
; CursorPosition = 805
; Folding = AQAQw
; EnableXP