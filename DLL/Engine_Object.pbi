;*****************************************
;******** 单片机仿真模拟器内核引擎 ********
;********    迷路仟 2020.02.04    ********
;*****************************************
;【Engine_Object.pbi】 ;电子元件相关及画布辅助的源代码


;- [Enumeration]
;画布属性值 
Enumeration
   #Attribute_None
   #Attribute_CanvasZoom         ;获取[画布]的比例值,   返回值: 25,50,75,100 
   #Attribute_CanvasInfo         ;获取[画布]的四围信息, 返回值: *pCanvasInfo__MCT_CanvasInfo  
   #Attribute_CanvasScrollX      ;获取[画布]的ScrollX,  返回值: ScrollX
   #Attribute_CanvasScrollY      ;获取[画布]的ScrollY,  返回值: ScrollY 
   #Attribute_CanvasWidth        ;获取[画布]的CanvasW,  返回值: CanvasW
   #Attribute_CanvasHeight       ;获取[画布]的CanvasH,  返回值: CanvasH
   #Attribute_DisplayGrid        ;获取[画布]
   #Attribute_MatterRotate       ;获取[元件]的旋转角度, 返回值: RotateIndex, ObjectID=#Null时,为当前选中状态下的[元件]
   #Attribute_ActiveObject       ;获取[对象]的ID,        返回值: ObjectID,  ObjectID为*pObjectID.long,则*pObjectID\l返回ObjectType                                        
   #Attribute_ActiveModule       ;获取[模块类型]的ID     返回值: ModuleID,  ObjectID=#Null时,为当前选中状态下的[对象]
   #Attribute_StringText         ;获取[文本标签]的Text,  返回值: @Text$  ,  ObjectID=#Null时,为当前选中状态下的[对象]   
   #Attribute_StringFontSize     ;获取[文本标签]的hFont, 返回值: FontSize,  ObjectID=#Null时,为当前选中状态下的[对象]  
   #Attribute_StringFontColor    ;获取[文本标签]的颜色值, 返回值: FontColor, ObjectID=#Null时,为当前选中状态下的[对象]
   #Attribute_DupontColor        ;获取[杜邦线]的颜色值,  返回值: FontColor, 
   #Attribute_ObjectLayer        ;获取[对象]的层级,     返回值: LayerIndex,  ObjectID=#Null时,为当前选中状态下的[对象]
   #Attribute_ObjectName         ;获置[对象]名称
   #Attribute_ObjectType         ;获取[对象]的类型,     返回值: ObjectType,  ObjectID=#Null时,为当前选中状态下的[对象]
   #Attribute_ObjectX            ;获置[对象]X坐标
   #Attribute_ObjectY            ;获置[对象]Y坐标
   #Attribute_ObjectModify
   #Attribute_ObjectDelete       ;删除[对象]           返回值: 1/0,   ObjectID=#Null时,为当前选中状态下的[对象]
   #Attribute_ActiveGroups       ;设置当前选中的[对象组], Value:合并/解散   ObjectID=#null
   #Attribute_Alignment          ;设置[活动对象]的对齐方式, Value:为对齐方式   ObjectID=#null
   #Attribute_Distribute         ;设置[活动对象]的分布方式, Value:为分布方式   ObjectID=#null
   #Attribute_AlignGrids
EndEnumeration


;- [Constant]
;{

#Object_Layer_Bottom  = 00     ;到底层   
#Object_Layer_Top     = -1     ;到顶层
#Object_Layer_Next    = -2     ;上一层
#Object_Layer_Prev    = -3     ;下一层

#Object_Rotate_TurnL90 = -1
#Object_Rotate_TurnR90 = -2
#Object_Rotate_Flip180 = -3

#Canvas_Align_Left   = $1
#Canvas_Align_Right  = $2
#Canvas_Align_Center = $4

#Canvas_Align_Top    = $10
#Canvas_Align_Bottom = $20
#Canvas_Align_Middle = $40

#Canvas_Evenly_Left   = $1
#Canvas_Evenly_Right  = $2
#Canvas_Evenly_Center = $4
#Canvas_Evenly_Space  = $8

#Canvas_Evenly_Top    = $10
#Canvas_Evenly_Bottom = $20
#Canvas_Evenly_Middle = $40
#Canvas_Evenly_Border = $80

#Object_Group_Divide = 0   ;解散指定的[对象组]
#Object_Group_Merger = 1   ;将[临时组]组合为[对象组]

;}


;- [Structure]
;外接变量[画布信息]结构
Structure __MCT_CanvasInfo
   ScrollX.l   ;画布偏移值
   ScrollY.l   ;画布偏移值 
   CanvasW.l   ;画布大小
   CanvasH.l   ;画布大小
EndStructure

Structure __MCT_ObjectInfo
   X.l
   Y.l
   W.l
   H.l
   FontSize.l
   FontColor.l
   Text$
EndStructure

;- [Include]
XIncludeFile "Engine_Module.pbi"  ;模块设置流文件相关的源代码文件
XIncludeFile "Engine_Design.pbi"  ;设计文档流文件相关的源代码文件
XIncludeFile "Engine_Dupont.pbi"  ;杜邦线相关的及画布辅助的源代码

;-
;- ******** [ListMatter] ********
;添加[模块单元],返回_ListMatter()指针
Procedure Object_AddMatter(*pMainDesign.__Design_MainInfo, *pMapModule.__Module_BaseInfo, X.f, Y.f, RotateIdx=#Object_Rotate_000)
   If *pMapModule = #Null : ProcedureReturn #Null  : EndIf 
   Module_CatchImage(*pMainDesign\pMainModule, *pMapModule)
   *pListMatter.__Matter_BaseInfo = AddElement(*pMainDesign\ListMatter()) 
   With *pListMatter
      *pMainDesign\MatterNameIndex+1
      \ObjectType  = #Object_Matter
      \ObjectName$ = "元件-"+Str(*pMainDesign\MatterNameIndex)
      \RotateIdx   = RotateIdx
      \pMapModule  = *pMapModule
      \pDimImage   = *pMapModule\DimImage[\RotateIdx]
      \X = X
      \Y = Y
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
   EndWith
   AddElement(*pMainDesign\pListObject())
   *pMainDesign\pListObject() = *pListMatter
   ProcedureReturn *pListMatter
EndProcedure

;删除[模块单元]
Procedure Object_FreeMatter(*pMainDesign.__Design_MainInfo, *pListMatter.__Matter_BaseInfo)
   If *pListMatter = #Null : ProcedureReturn #Null : EndIf 
   ForEach *pMainDesign\ListMatter()
      ;找到元件
      If *pMainDesign\ListMatter() = *pListMatter
         ;历遍元件引脚或插口
         ForEach *pListMatter\ListPinPrefer()
            *pPinPrefer.__Matter_PinPrefer = *pListMatter\ListPinPrefer()
            ;如果引脚或插口有杜邦线,则找出杜邦线,
            If *pPinPrefer\pOriginDupont
               ForEach *pMainDesign\ListDupont()
                  ;找到杜邦线后,将目标引脚的杜邦线信息也删除,最后再删除杜邦线
                  If *pMainDesign\ListDupont() = *pPinPrefer\pOriginDupont
                     *pTargetPin.__Matter_PinPrefer = *pMainDesign\ListDupont()\pTargetPin
                     *pTargetPin\pTargetDupont = #Null
                     *pPinPrefer\pOriginDupont = #Null
                     ClearList(*pMainDesign\ListDupont()\ListNodus())
                     DeleteElement(*pMainDesign\ListDupont())
                     Break
                  EndIf 
               Next 
            EndIf
            
            If *pPinPrefer\pTargetDupont
               ForEach *pMainDesign\ListDupont()
                  If *pMainDesign\ListDupont() = *pPinPrefer\pTargetDupont
                     *pOriginPin.__Matter_PinPrefer = *pMainDesign\ListDupont()\pOriginPin
                     *pOriginPin\pTargetDupont = #Null
                     *pPinPrefer\pTargetDupont = #Null
                     ClearList(*pMainDesign\ListDupont()\ListNodus())
                     DeleteElement(*pMainDesign\ListDupont())
                     Break
                  EndIf 
               Next 
            EndIf
         Next 
         ClearList(*pListMatter\ListPinPrefer())
         DeleteElement(*pMainDesign\ListMatter())
         ForEach *pMainDesign\pListObject()
            If  *pMainDesign\pListObject() = *pListMatter
               DeleteElement(*pMainDesign\pListObject())
               Break
            EndIf 
         Next 
         If *pMainDesign\pCurrObject = *pListMatter
            *pMainDesign\pCurrObject = #Null
         EndIf 
        ProcedureReturn #True
      EndIf 
   Next 
   ProcedureReturn #False
EndProcedure

;-
;- ******** [ListString] ********
;添加[文本]
Procedure Object_AddString(*pMainDesign.__Design_MainInfo, X.f, Y.f, Text$)
   *pCanvas.__Design_CanvasInfo = *pMainDesign\pMainCanvas
   *pListString.__String_BaseInfo = AddElement(*pMainDesign\ListString()) 
   With *pListString
      *pMainDesign\StringNameIndex+1
      \ObjectType  = #Object_String
      \ObjectName$ = "标签-"+Str(*pMainDesign\StringNameIndex)
      \X          = X
      \Y          = Y
      \Text$      = Text$
      \FontColor  = *pCanvas\FontColor
      \BackColor  = *pCanvas\BackColor
      \FontSize   = *pCanvas\FontSize
   EndWith  
   AddElement(*pMainDesign\pListObject())
   *pMainDesign\pListObject() = *pListString
   ProcedureReturn *pListString
EndProcedure

;删除[文本]
Procedure Object_FreeString(*pMainDesign.__Design_MainInfo, *pListString.__String_BaseInfo)
   If *pListString = #Null : ProcedureReturn #Null : EndIf 
   
   ForEach *pMainDesign\ListString()
      If *pMainDesign\ListString() = *pListString
         DeleteElement(*pMainDesign\ListString())
         ForEach *pMainDesign\pListObject()
            If *pMainDesign\pListObject() = *pListString
               DeleteElement(*pMainDesign\pListObject()) 
               Break
            EndIf 
         Next 
         If *pMainDesign\pCurrObject = *pListString
            *pMainDesign\pCurrObject = #Null
         EndIf
         ProcedureReturn #True
      EndIf 
   Next 
   ProcedureReturn #False
EndProcedure


;-
;- ******** [Selection] ********
;重新计算[对象组]选择域
Procedure Object_Selection_Search(*pMainDesign.__Design_MainInfo, X.f, Y.f)
   StartX.f = *pMainDesign\pMainCanvas\X
   StartY.f = *pMainDesign\pMainCanvas\Y
  

   If *pMainDesign\pCurrObject
      With *pMainDesign\pCurrObject
         If \X <= X And X <=\R And \Y < Y And Y <\B
            ProcedureReturn #True
         EndIf 
      EndWith
   EndIf 
   
   ;如果有指定, *pMainDesign\pCurrModule,表示要新建模块
   If *pMainDesign\pCurrModule
      
      MatterX = *pMainDesign\pMainCanvas\X/#Object_Event_Align*#Object_Event_Align  
      MatterY = *pMainDesign\pMainCanvas\Y/#Object_Event_Align*#Object_Event_Align
      If *pMainDesign\pCurrModule\ModuleTypes$ = #ModuleType_String$
         If *pMainDesign\MaxStringIndex = 0
            Text$ = "标签控件"
            *pMainDesign\MaxStringIndex = 1
         Else 
            *pMainDesign\MaxStringIndex+1
            Text$ = "标签控件"+Str(*pMainDesign\MaxStringIndex)
         EndIf 
         *pCallAddString = *pMainDesign\pMainModule\pCallAddString
         If *pCallAddString
            Zoom.f = *pMainDesign\pMainCanvas\LayerZoom
            Object.__MCT_ObjectInfo
            Object\X     = MatterX*Zoom
            Object\Y     = MatterY*Zoom
            Object\W     = (X-MatterX)*Zoom
            Object\H     = (Y-MatterY)*Zoom
            Object\Text$ = Text$
            Object\FontSize  = 60
            Object\FontColor = 0
            Result = CallFunctionFast(*pCallAddString, @Object, #False)
         EndIf 
         If Result And Object\Text$ <> #Null$
            *pListString.__String_BaseInfo = Object_AddString(*pMainDesign, Object\X/Zoom, Object\Y/Zoom, Object\Text$)
            *pMainDesign\pCurrObject = *pListString   
            *pListString\FontColor = Object\FontColor
            *pListString\FontSize  = Object\FontSize
            *pListString\X = Object\X/Zoom
            *pListString\Y = Object\Y/Zoom
            *pListString\R = Object\X/Zoom+*pListString\W
            *pListString\B = Object\Y/Zoom+*pListString\H
         EndIf 
      Else 
         *pListMatter = Object_AddMatter(*pMainDesign, *pMainDesign\pCurrModule, MatterX, MatterY, #Object_Rotate_000)
         *pMainDesign\pCurrObject = *pListMatter
      EndIf 
      *pMainDesign\pCurrModule = #Null
   EndIf 
   
   ;[选择域]搜索
   If X >= StartX : InvolveX = #True : EndIf 
   If Y >= StartY : InvolveY = #True : EndIf    
   
   ;清空[临时组]
   With *pMainDesign\ActiveObject
      ClearList(\pListObject())
      \X = 09999
      \Y = 09999 
      \R = -9999
      \B = -9999
   EndWith
   
   ;历遍[对象]
   ForEach *pMainDesign\pListObject()
      *pObject.__Object_BaseInfo = *pMainDesign\pListObject()
      With *pObject
         BoolX = Bool(InvolveX = #True  And \X >= StartX And \R <= X)
         BoolX | Bool(InvolveX = #False And \X >= X And \X <= StartX)
         BoolX | Bool(InvolveX = #False And \R >= X And \R <= StartX)
         
         BoolY = Bool(InvolveY = #True  And \Y >= StartY And \B <= Y)
         BoolY | Bool(InvolveY = #False And \Y >= Y And \Y <= StartY)
         BoolY | Bool(InvolveY = #False And \B >= Y And \B <= StartY)
      EndWith

      If BoolX = #True And BoolY = #True
         ;向[临时组]添加对象
         With *pMainDesign\ActiveObject
            AddElement(\pListObject())
            \pListObject() = *pObject
            If \X > *pObject\X : \X = *pObject\X : EndIf 
            If \Y > *pObject\Y : \Y = *pObject\Y : EndIf 
            If \R < *pObject\R : \R = *pObject\R : EndIf 
            If \B < *pObject\B : \B = *pObject\B : EndIf
            \W = \R - \X
            \H = \B - \Y
         EndWith
         *pMainDesign\pCurrObject = *pObject
         ActiveObject = #True
      EndIf 

   Next
   With *pMainDesign\ActiveObject
      CountObject = ListSize(\pListObject())
      If CountObject > 1
         *pMainDesign\pCurrObject = *pMainDesign\ActiveObject
      EndIf 
   EndWith
   Debug "[Object_Select] 选择[对象]: " + Str(CountObject), #DebugLevel_Object_Select
   ProcedureReturn ActiveObject    
EndProcedure

;激活[对象组]选择域
Procedure Object_Selection_Active(*pMainDesign.__Design_MainInfo, *pObject.__Object_BaseInfo, X.f, Y.f)
   If *pObject = #Null : ProcedureReturn : EndIf 
   With *pObject
      \OffsetX = X-\X : \OffsetY = Y-\Y 
   EndWith
   Select *pObject\ObjectType & $FF
      Case #Object_Matter 
         *pListMatter.__Matter_BaseInfo = *pObject
         With *pListMatter
            ForEach \ListPinPrefer()
               If \ListPinPrefer()\pOriginDupont
                  *pListDupont.__Dupont_BaseInfo = \ListPinPrefer()\pOriginDupont
                  *pMainDesign\pMapDupont(Str(*pListDupont))
                  *pMainDesign\pMapDupont()  = *pListDupont
                  *pListDupont\IsGroupOrigin = #True 
               EndIf 
               If \ListPinPrefer()\pTargetDupont   
                  *pListDupont.__Dupont_BaseInfo = \ListPinPrefer()\pTargetDupont
                  *pMainDesign\pMapDupont(Str(*pListDupont))
                  *pMainDesign\pMapDupont()  = *pListDupont
                  *pListDupont\IsGroupTarget = #True                      
               EndIf 
            Next 
         EndWith
      Case #Object_String
         
      Case #Object_Active 
         *pGroups.__Groups_BaseInfo = *pObject
         ForEach *pGroups\pListObject()
            Object_Selection_Active(*pMainDesign, *pGroups\pListObject(), X, Y)
         Next  
         
      Case #Object_Groups   
         *pGroups.__Groups_BaseInfo = *pObject
         ForEach *pGroups\pListObject()
            Object_Selection_Active(*pMainDesign, *pGroups\pListObject(), X, Y)
         Next 
   EndSelect    
   Debug "[Object_Select] 激活[ObjectType="+Str(*pObject\ObjectType & $FF)+ "] 0x"+Hex(*pObject), #DebugLevel_Object_Select
   ProcedureReturn NeedRefresh
EndProcedure

;激活[对象组]选择域
Procedure Object_Selection_Moving(*pObject.__Object_BaseInfo, X.f, Y.f)
   If *pObject = #Null : ProcedureReturn : EndIf 
   With *pObject
      \X = X - \OffsetX : \R = \X+\W
      \Y = Y - \OffsetY : \B = \Y+\H
   EndWith
   Select *pObject\ObjectType & $FF
      Case #Object_Matter 
         Dupont_Selection_Single(*pObject)
      Case #Object_String
      Case #Object_Active
         *pGroups.__Groups_BaseInfo = *pObject
         ForEach *pGroups\pListObject()
            Object_Selection_Moving(*pGroups\pListObject(), X, Y)
         Next 
      Case #Object_Groups   
         *pGroups.__Groups_BaseInfo = *pObject
         ForEach *pGroups\pListObject()
            Object_Selection_Moving(*pGroups\pListObject(), X, Y)
         Next 
   EndSelect      
   Debug "[Object_Moving] 移动[ObjectType="+Str(*pObject\ObjectType & $FF)+ "] 0x"+Hex(*pObject)+" : "+Str(*pObject\X)+","+Str(*pObject\Y), #DebugLevel_Object_Moving
   ProcedureReturn #True
EndProcedure

;取消[对象组]选择域
Procedure Object_Selection_Cancel(*pMainDesign.__Design_MainInfo)
   With *pMainDesign
      If *pMainDesign\pCurrObject = #Null : ProcedureReturn : EndIf 
      Select \pCurrObject\ObjectType & $FF
         Case #Object_Matter 
         Case #Object_String
         Case #Object_Active
            *pGroups.__Groups_BaseInfo = \pCurrObject
            ClearList(*pGroups\pListObject())
         Case #Object_Groups   
      EndSelect      
      \pCurrObject\ObjectType & ~#Object_Event
      \pCurrObject = #Null
   EndWith
   ForEach *pMainDesign\pMapDupont() 
      *pMainDesign\pMapDupont()\IsGroupOrigin = #False
      *pMainDesign\pMapDupont()\IsGroupTarget = #False
   Next 
   ClearMap(*pMainDesign\pMapDupont())
   ProcedureReturn #True
EndProcedure

;完成[对象组]选择域
Procedure Object_Selection_Change(*pMainDesign.__Design_MainInfo)
   With *pMainDesign\pCurrObject
      If \ObjectType & #Object_Event_Moving
         If *pMainDesign\HorizAlign And *pMainDesign\VertiAlign 
            X.f = *pMainDesign\VertiAlign+\OffsetX      ;对象自动对 
            Y.f = *pMainDesign\HorizAlign+\OffsetY      ;对象自动对 
            *pMainDesign\HorizAlign = #Null           ;取消对齐线  
            *pMainDesign\VertiAlign = #Null           ;取消对齐线  
            Object_Selection_Moving(*pMainDesign\pCurrObject, X, Y)
            Dupont_Selection_Moving(*pMainDesign, X, Y)
            Debug "[Object_Moving] 水平校齐", #DebugLevel_Object_Moving
            NeedRefresh = #True
         ElseIf *pMainDesign\HorizAlign 
            X.f = \X+\OffsetX
            Y.f = *pMainDesign\HorizAlign+\OffsetY      ;对象自动对 
            *pMainDesign\HorizAlign = #Null           ;取消对齐线               
            Object_Selection_Moving(*pMainDesign\pCurrObject, X, Y)
            Dupont_Selection_Moving(*pMainDesign, X, Y)
            Debug "[Object_Moving] 水平校齐", #DebugLevel_Object_Moving
            NeedRefresh = #True
         ElseIf *pMainDesign\VertiAlign 
            X.f = *pMainDesign\VertiAlign+\OffsetX
            Y.f = \Y+\OffsetY                           ;对象自动对 
            *pMainDesign\VertiAlign = #Null           ;取消对齐线               
            Object_Selection_Moving(*pMainDesign\pCurrObject, X, Y)
            Dupont_Selection_Moving(*pMainDesign, X, Y)
            Debug "[Object_Moving] 垂线校齐", #DebugLevel_Object_Moving
            NeedRefresh = #True 
         EndIf          
      EndIf 
      If \ObjectType & #Object_Event
         \ObjectType & ~#Object_Event
         Debug "[Object_Moving] 结束移动 *************** ", #DebugLevel_Object_Moving
         ProcedureReturn #True
      EndIf 
   EndWith
   
EndProcedure


;-
;向选择域减去[对象]
Procedure Object_Selection_Sub(*pMainDesign.__Design_MainInfo, X.f, Y.f)
   
   ForEach *pMainDesign\ActiveObject\pListObject()
      With *pMainDesign\ActiveObject\pListObject()
         If \X <= X And X <=\R And \Y < Y And Y <\B
            DeleteElement(*pMainDesign\ActiveObject\pListObject())
            IsDelete = #True
            Break
         EndIf 
      EndWith
   Next 
   
   If IsDelete = #True
      CountObject = ListSize(*pMainDesign\ActiveObject\pListObject())       
      Debug "[Object_Select] 从活动[对象组]中除去选中[对象] : "+Str(CountObject), #DebugLevel_Object_Select
      If CountObject = 0
         *pMainDesign\pCurrObject = #Null
         ProcedureReturn #True
         
      ElseIf CountObject = 1
         FirstElement(*pMainDesign\ActiveObject\pListObject())
         *pMainDesign\pCurrObject = *pMainDesign\ActiveObject\pListObject()
         ClearList(*pMainDesign\ActiveObject\pListObject())
         ProcedureReturn #True
      Else 
         With *pMainDesign\ActiveObject
            \X = 09999
            \Y = 09999 
            \R = -9999
            \B = -9999
            ForEach \pListObject()
               *pObject.__Object_BaseInfo = \pListObject()
               If \X > *pObject\X : \X = *pObject\X : EndIf 
               If \Y > *pObject\Y : \Y = *pObject\Y : EndIf 
               If \R < *pObject\R : \R = *pObject\R : EndIf 
               If \B < *pObject\B : \B = *pObject\B : EndIf
               \W = \R - \X
               \H = \B - \Y
            Next            
         EndWith
         *pMainDesign\pCurrObject = *pMainDesign\ActiveObject
         *pMainDesign\ActiveObject\ObjectType = #Object_Active
         ProcedureReturn #True
      EndIf 
   EndIf 
EndProcedure

;向选择域添加[对象]
Procedure Object_Selection_Add(*pMainDesign.__Design_MainInfo, *pObject.__Object_BaseInfo)
   If *pObject = #Null : ProcedureReturn : EndIf 
   If *pMainDesign\pCurrObject = *pMainDesign\ActiveObject
      With *pMainDesign\ActiveObject
         AddElement(\pListObject())
         \pListObject() = *pObject
         If \X > *pObject\X : \X = *pObject\X : EndIf 
         If \Y > *pObject\Y : \Y = *pObject\Y : EndIf 
         If \R < *pObject\R : \R = *pObject\R : EndIf 
         If \B < *pObject\B : \B = *pObject\B : EndIf
         \W = \R - \X
         \H = \B - \Y
      EndWith
      
   ElseIf *pMainDesign\pCurrObject 
      With *pMainDesign\ActiveObject
         ClearList(\pListObject())
         \X = 09999
         \Y = 09999 
         \R = -9999
         \B = -9999
         
         *pActive.__Object_BaseInfo = *pMainDesign\pCurrObject
         AddElement(\pListObject())
         \pListObject() = *pActive
         If \X > *pActive\X : \X = *pActive\X : EndIf 
         If \Y > *pActive\Y : \Y = *pActive\Y : EndIf 
         If \R < *pActive\R : \R = *pActive\R : EndIf 
         If \B < *pActive\B : \B = *pActive\B : EndIf
         \W = \R - \X
         \H = \B - \Y
         
         AddElement(\pListObject())
         \pListObject() = *pObject
         If \X > *pObject\X : \X = *pObject\X : EndIf 
         If \Y > *pObject\Y : \Y = *pObject\Y : EndIf 
         If \R < *pObject\R : \R = *pObject\R : EndIf 
         If \B < *pObject\B : \B = *pObject\B : EndIf
         \W = \R - \X
         \H = \B - \Y     
         *pMainDesign\pCurrObject = *pMainDesign\ActiveObject
         *pMainDesign\ActiveObject\ObjectType = #Object_Active
      EndWith
   EndIf 
   Debug "[Object_Select] 添加选中[对象]到活动[对象组]: "+Str(ListSize(*pMainDesign\ActiveObject\pListObject())), #DebugLevel_Object_Select
EndProcedure


;-
Procedure Object_Button_Moving(*pObject.__Object_BaseInfo, Button) 
   If *pObject = #Null: ProcedureReturn #False: EndIf 
   With *pObject
      Select \ObjectType & $FF
         Case #Object_Matter, #Object_String, #Object_Active,  #Object_Groups
            Select Button
               Case #PB_Shortcut_Up
                  If \Y > 0 
                     \Y = Int(*pObject\Y-#Object_Event_Align)/#Object_Event_Align*#Object_Event_Align
                     \B = \Y+\H
                     NeedRefresh = #True
                  EndIf 
               Case #PB_Shortcut_Down
                  If \Y > 0 
                     \Y = Int(*pObject\Y+#Object_Event_Align)/#Object_Event_Align*#Object_Event_Align
                     \B = \Y+\H
                     NeedRefresh = #True
                  EndIf  
               Case #PB_Shortcut_Left
                  If \X > 0 
                     \X = Int(*pObject\X-#Object_Event_Align)/#Object_Event_Align*#Object_Event_Align
                     \R = \X+\W
                     NeedRefresh = #True
                  EndIf  
               Case #PB_Shortcut_Right
                  If \X > 0 
                     \X = Int(*pObject\X+#Object_Event_Align)/#Object_Event_Align*#Object_Event_Align
                     \R = \X+\W
                     NeedRefresh = #True
                  EndIf
            EndSelect
      EndSelect 
   EndWith
   
   Select *pObject\ObjectType & $FF
      Case #Object_Active, #Object_Groups
         *pGroups.__Groups_BaseInfo = *pObject
         ForEach *pGroups\pListObject()
            NeedRefresh | Object_Button_Moving(*pGroups\pListObject(), Button) 
         Next 
   EndSelect 
   ProcedureReturn NeedRefresh
EndProcedure




;-
;- ******** [SetAttribute] ********
Procedure Object_SetAttribute_CanvasZoom(*pMainDesign.__Design_MainInfo, Value)
   Debug Value
   If Value > 2000 : Value = 2000 : EndIf 
   If Value < 0100 : Value = 0100 : EndIf 
   *pMainDesign\pMainCanvas\LayerZoom = Value/2000
   ProcedureReturn #True
EndProcedure
   
Procedure Object_SetAttribute_CanvasInfo(*pMainDesign.__Design_MainInfo, *pCanvasInfo.__MCT_CanvasInfo)
   With *pMainDesign\pMainCanvas
      If *pCanvasInfo
         \ScrollX = *pCanvasInfo\ScrollX   
         \ScrollY = *pCanvasInfo\ScrollY   
         \CanvasW = *pCanvasInfo\CanvasW   
         \CanvasH = *pCanvasInfo\CanvasH 
         ProcedureReturn #True
      EndIf 
   EndWith
   ProcedureReturn #False
EndProcedure   

Procedure Object_SetAttribute_ObjectLayer(*pMainDesign.__Design_MainInfo, LayerIndex, *pObject.__Groups_BaseInfo)
   If *pObject = #Null
      *pObject.__Groups_BaseInfo = *pMainDesign\pCurrObject
   EndIf 
   If *pObject = #Null : ProcedureReturn #False : EndIf 
   If LayerIndex > 0
      *pElement = SelectElement(*pMainDesign\pListObject(), LayerIndex)
      If *pElement : ProcedureReturn #False : EndIf 
      ForEach *pMainDesign\pListObject()
         If *pMainDesign\pListObject() = *pObject
            MoveElement(*pMainDesign\pListObject(), #PB_List_Before, *pElement)
            ProcedureReturn #True
         EndIf 
      Next       
   ElseIf LayerIndex >= #Object_Layer_Prev
      ForEach *pMainDesign\pListObject()
         If *pMainDesign\pListObject() = *pObject
            Select LayerIndex
               Case #Object_Layer_Bottom 
                  MoveElement(*pMainDesign\pListObject(),  #PB_List_First)
                  ProcedureReturn #True
               Case #Object_Layer_Top    
                  MoveElement(*pMainDesign\pListObject(),  #PB_List_Last)
                  ProcedureReturn #True
               Case #Object_Layer_Next  
                  *pCurrElement = @*pMainDesign\pListObject()
                  *pPrevElement = PreviousElement(*pMainDesign\pListObject())
                  If *pPrevElement
                     SwapElements(*pMainDesign\pListObject(), *pCurrElement, *pPrevElement)
                     ProcedureReturn #True
                  EndIf 
               Case #Object_Layer_Prev
                  *pCurrElement = @*pMainDesign\pListObject()
                  *pPrevElement = NextElement(*pMainDesign\pListObject())
                  If *pPrevElement
                     SwapElements(*pMainDesign\pListObject(), *pCurrElement, *pPrevElement)
                     ProcedureReturn #True
                  EndIf 
            EndSelect
            ProcedureReturn #False
         EndIf 
      Next
   EndIf 
   ProcedureReturn #False
EndProcedure   

Procedure Object_SetAttribute_MatterRotate(*pMainDesign.__Design_MainInfo, RotateIndex, *pObject.__Groups_BaseInfo)
   If *pObject = #Null
      *pObject.__Groups_BaseInfo = *pMainDesign\pCurrObject
   EndIf 
   If RotateIndex > 0 
      ForEach *pMainDesign\pListObject()
         If *pMainDesign\pListObject() = *pObject
            If *pObject\ObjectType & $FF = #Object_Matter
               *pMatter.__Matter_BaseInfo = *pObject
               If *pMatter\pMapModule\IsSymmetry
                  *pMatter\RotateIdx = RotateIndex % (#Object_Rotate_Count*2)
               Else 
                  *pMatter\RotateIdx = RotateIndex % #Object_Rotate_Count
               EndIf 
               ProcedureReturn #False
            Else 
               ProcedureReturn #False
            EndIf 
         EndIf 
      Next  
   ElseIf  RotateIndex >= #Object_Rotate_Flip180

      ForEach *pMainDesign\pListObject()
         If *pMainDesign\pListObject() = *pObject
            If *pObject\ObjectType & $FF = #Object_Matter
               *pMatter.__Matter_BaseInfo = *pObject
            EndIf 
            Break
         EndIf 
      Next  
      If *pMatter
         With *pMatter
            Select RotateIndex
               Case #Object_Rotate_TurnL90 : RotateValue = 01
               Case #Object_Rotate_TurnR90 : RotateValue = -1   
               Case #Object_Rotate_Flip180
                  If \SymmetryIdx : \SymmetryIdx = 0 : Else : \SymmetryIdx = \pMapModule\IsSymmetry * #Object_Rotate_Count : EndIf 
            EndSelect         
            RotateIdx = \RotateIdx+RotateValue
            If RotateIdx < 0 : RotateIdx+#Object_Rotate_Count : EndIf 
            If RotateIdx >= #Object_Rotate_Count : RotateIdx-#Object_Rotate_Count : EndIf 
            
            \RotateIdx = RotateIdx
            \pDimImage = \pMapModule\DimImage[\RotateIdx+\SymmetryIdx]
            \W = \pDimImage\ImageW
            \H = \pDimImage\ImageH
            \R = \X+\W
            \B = \Y+\H
            FirstElement(\ListPinPrefer())
            ForEach \pDimImage\ListPinParam()
               \ListPinPrefer()\PinDirection  = \pDimImage\ListPinParam()\PinDirection
               \ListPinPrefer()\pListPinParam = \pDimImage\ListPinParam()
               NextElement(\ListPinPrefer())
            Next 
         EndWith 
         ProcedureReturn #True
      EndIf 
   EndIf 
   ProcedureReturn #False
EndProcedure   

Procedure Object_SetAttribute_ActiveObject(*pMainDesign.__Design_MainInfo, *pObject.__Groups_BaseInfo)
   If *pObject
      ForEach *pMainDesign\pListObject()
         If *pMainDesign\pListObject() = *pObject
            *pMainDesign\pCurrObject = *pObject
            ProcedureReturn #True
         EndIf 
      Next    
   EndIf 
   ProcedureReturn #False
EndProcedure   

Procedure Object_SetAttribute_ActiveModule(*pMainDesign.__Design_MainInfo, *pModule.__Module_BaseInfo)
   If *pModule = #Null
      *pMainDesign\pCurrModule = #Null
      ProcedureReturn
   ElseIf *pMainDesign\pMainModule 
      ForEach *pMainDesign\pMainModule\ListModule()
         If *pMainDesign\pMainModule\ListModule() = *pModule
            *pMainDesign\pCurrModule = *pModule
            ProcedureReturn #True
         EndIf 
      Next    
   EndIf 
   ProcedureReturn #False
EndProcedure

Procedure Object_SetAttribute_StringText(*pMainDesign.__Design_MainInfo, *pMemText, *pString.__String_BaseInfo)
   If *pString = #Null
      *pString = *pMainDesign\pCurrObject
      If *pString And *pString\ObjectType & $FF = #Object_String
         *pString\Text$ = PeekS(*pMemText)
         ProcedureReturn #True
      EndIf 
   EndIf 
   If *pString 
      ForEach *pMainDesign\ListString()
         If *pMainDesign\ListString() = *pString
            *pString\Text$ = PeekS(*pMemText)
            ProcedureReturn #True
         EndIf 
      Next 
   EndIf 
   ProcedureReturn #False
EndProcedure

Procedure Object_SetAttribute_StringFontSize(*pMainDesign.__Design_MainInfo, FontSize, *pString.__String_BaseInfo)
   If *pString = #Null
      *pString = *pMainDesign\pCurrObject
      If *pString And *pString\ObjectType & $FF = #Object_String
         *pString\FontSize = FontSize
         ProcedureReturn #True
      EndIf 
   EndIf 
   If *pString 
      ForEach *pMainDesign\ListString()
         If *pMainDesign\ListString() = *pString
            *pString\FontSize = FontSize
            ProcedureReturn #True
         EndIf 
      Next 
   EndIf 
   ProcedureReturn #False
EndProcedure

Procedure Object_SetAttribute_StringFontColor(*pMainDesign.__Design_MainInfo, FontColor, *pString.__String_BaseInfo)
   If *pString = #Null
      *pString = *pMainDesign\pCurrObject
      If *pString And *pString\ObjectType & $FF = #Object_String
         *pString\FontColor = FontColor
         ProcedureReturn #True
      EndIf 
   EndIf 
   If *pString 
      ForEach *pMainDesign\ListString()
         If *pMainDesign\ListString() = *pString
            *pString\FontColor = FontColor
            ProcedureReturn #True
         EndIf 
      Next 
   EndIf 
   ProcedureReturn #False
EndProcedure


Procedure Object_SetAttribute_DupontColor(*pMainDesign.__Design_MainInfo, FontColor)
   If FontColor = -1 : ProcedureReturn : EndIf 
   If *pMainDesign\pCurrObject And *pMainDesign\pCurrDupont
      *pMainDesign\pCurrDupont\DupontColor = FontColor | $FF000000
      ProcedureReturn #True
   EndIf 
   ProcedureReturn #False
EndProcedure

Procedure Object_SetAttribute_ActiveGroups(*pMainDesign.__Design_MainInfo, GroupMode, *pGroups.__Groups_BaseInfo) 
   
   Select GroupMode
      Case #Object_Group_Divide    ;解散指定的[对象组]
         If *pGroups = #Null 
            *pGroups = *pMainDesign\pCurrObject
         EndIf             
         If *pGroups = #Null Or *pGroups\ObjectType & $FF <> #Object_Groups
            ProcedureReturn #False
         EndIf 
         *pMainDesign\pCurrObject = #Null
         *pMergerGroups.__Groups_BaseInfo = *pGroups
         *pActiveGroups.__Groups_BaseInfo = *pMainDesign\ActiveObject
         ClearList(*pMainDesign\ActiveObject\pListObject())
         ForEach *pMainDesign\pListObject()
            If *pMainDesign\pListObject() = *pMergerGroups        ;这里主要是为了找到级层关系
               ForEach *pMergerGroups\pListObject()
                  AddElement(*pActiveGroups\pListObject())
                  *pActiveGroups\pListObject() = *pMergerGroups\pListObject()  
                  Debug "[Object_Modify] [对象组] Add 0x" + Hex(*pActiveGroups\pListObject()), #DebugLevel_Object_Modify
                  
                  InsertElement(*pMainDesign\pListObject())
                  *pMainDesign\pListObject() = *pMergerGroups\pListObject()
                  Debug "[Object_Modify] [对象链表] Add 0x" + Hex(*pMainDesign\pListObject()), #DebugLevel_Object_Modify
                  
                  NextElement(*pMainDesign\pListObject())
               Next 
               CopySize = SizeOf(__Object_BaseInfo)
               CopyMemory(*pMergerGroups, *pActiveGroups, CopySize)
               *pMainDesign\ActiveObject\ObjectType  = #Object_Active
               *pMainDesign\ActiveObject\DeleteFlags = #Null
               
               ClearList(*pMainDesign\pListObject()\pListObject())
               Debug "[Object_Modify] [对象链表] Delete 0x" + Hex(*pMainDesign\pListObject()), #DebugLevel_Object_Modify
               DeleteElement(*pMainDesign\pListObject())    ;删除
               *pMainDesign\pCurrObject = *pActiveGroups
               IsFind = #True
               Break
            EndIf 
         Next 
         Debug "[Object_Modify] 解散[对象组] Count = " + ListSize(*pMainDesign\pListObject()), #DebugLevel_Object_Modify
         Debug "[Object_Modify] ********************", #DebugLevel_Object_Modify
         
      Case #Object_Group_Merger    ;将[临时组]组合为[对象组]
         If *pMainDesign\pCurrObject And *pMainDesign\pCurrObject = *pMainDesign\ActiveObject
            *pMergerGroups.__Groups_BaseInfo = AddElement(*pMainDesign\ListGroups())   ;新建一个[对象组]  
            *pMainDesign\GroupsNameIndex+1
            *pMergerGroups\ObjectName$ = "对象组-"+Str(*pMainDesign\GroupsNameIndex)
            *pActiveGroups.__Groups_BaseInfo = *pMainDesign\ActiveObject               ;当前[临时组]
            CopySize = SizeOf(__Object_BaseInfo)
            CopyMemory(*pActiveGroups, *pMergerGroups, CopySize)
            
            ForEach *pActiveGroups\pListObject()
               AddElement(*pMergerGroups\pListObject())
               *pMergerGroups\pListObject() = *pActiveGroups\pListObject()             ;复制组成员[对象]
               Debug "[Object_Modify] [对象组] Add 0x" + Hex(*pMergerGroups\pListObject()), #DebugLevel_Object_Modify
               Index = 0
               ForEach *pMainDesign\pListObject()
                  If *pMainDesign\pListObject() = *pActiveGroups\pListObject()   
                     Debug "[Object_Modify] [对象链表] Flags 0x" + Hex(*pMainDesign\pListObject()), #DebugLevel_Object_Modify
                     *pMainDesign\pListObject()\DeleteFlags = #True
                     If MaxIndex < Index : MaxIndex = Index : EndIf                    ;获取最大的级层,合并后的组,以最大级层为主
                  EndIf
                  Index+1
               Next 
            Next 

            If SelectElement(*pMainDesign\pListObject(), MaxIndex) 
               InsertElement(*pMainDesign\pListObject())
               *pMainDesign\pListObject() = *pMergerGroups
               *pMergerGroups\ObjectType  = #Object_Groups
               *pMainDesign\pCurrObject   = *pMergerGroups               
               Debug "[Object_Modify] [对象链表] Add 0x" + Hex(*pMainDesign\pListObject()), #DebugLevel_Object_Modify
            Else
               AddElement(*pMainDesign\pListObject())
               *pMainDesign\pListObject() = *pMergerGroups
               *pMergerGroups\ObjectType  = #Object_Groups
               *pMainDesign\pCurrObject   = *pMergerGroups
               Debug "[Object_Modify] [对象链表] Add 0x" + Hex(*pMainDesign\pListObject()), #DebugLevel_Object_Modify
            EndIf 
            ClearList(*pMainDesign\ActiveObject\pListObject())
            ;删除掉[临时组]的成员在*pMainDesign\pListObject()的指针
            ForEach *pMainDesign\pListObject() 
               If *pMainDesign\pListObject()\DeleteFlags = #True
                  Debug "[Object_Modify] [对象链表] Delete 0x" + Hex(*pMainDesign\pListObject()), #DebugLevel_Object_Modify
                  *pMainDesign\pListObject()\DeleteFlags = #False    ;<--这里是一个坑,一定要去掉删除标志
                  DeleteElement(*pMainDesign\pListObject())
               EndIf 
            Next 
            Debug "[Object_Modify] 合并[活动组] Count = " + ListSize(*pMainDesign\pListObject()), #DebugLevel_Object_Modify
            Debug "[Object_Modify] ********************", #DebugLevel_Object_Modify
            ProcedureReturn *pMergerGroups
         EndIf 
         
   EndSelect
   ProcedureReturn #False
EndProcedure

;对齐对象
Procedure Object_SetAttribute_Alignment(*pMainDesign.__Design_MainInfo, Alignment)
   If *pMainDesign\pCurrObject = #Null : ProcedureReturn #False : EndIf 
   If *pMainDesign\pCurrObject <> *pMainDesign\ActiveObject : ProcedureReturn #False : EndIf 
   
   *pGroups.__Groups_BaseInfo = *pMainDesign\pCurrObject
   Count = ListSize(*pGroups\pListObject())
   If Count < 2 : ProcedureReturn #False : EndIf 
   Count-1
   X = 09999 : Y = 09999 : R = -9999 : B = -9999

   With *pGroups\pListObject()
      Select Alignment & $F
         Case #Canvas_Align_Left
            X = *pGroups\X
            ForEach *pGroups\pListObject()
               \X = *pGroups\X
               \R = \X+\W
               If Y > \Y : Y = \Y : EndIf 
               If R < \R : R = \R : EndIf 
               If B < \B : B = \B : EndIf
            Next 
            IsAlign = #True
         Case #Canvas_Align_Right
            R = *pGroups\R
            ForEach *pGroups\pListObject()
               \R = *pGroups\R
               \X = \R-\W
               If X > \X : X = \X : EndIf 
               If Y > \Y : Y = \Y : EndIf 
               If B < \B : B = \B : EndIf
            Next 
            IsAlign = #True
         Case #Canvas_Align_Center
            Center = *pGroups\X+*pGroups\W/2
            ForEach *pGroups\pListObject()
               \X = Center -\W/2
               \R = \X+\W
               If X > \X : X = \X : EndIf 
               If Y > \Y : Y = \Y : EndIf 
               If R < \R : R = \R : EndIf 
               If B < \B : B = \B : EndIf
            Next 
            IsAlign = #True
      EndSelect
      
      Select Alignment & $F0
         Case #Canvas_Align_Top
            Y = *pGroups\Y
            ForEach *pGroups\pListObject()
               \Y = *pGroups\Y
               \B = \Y+\H
               If X > \X : X = \X : EndIf 
               If R < \R : R = \R : EndIf 
               If B < \B : B = \B : EndIf
            Next 
            IsAlign = #True
         Case #Canvas_Align_Bottom
            B = *pGroups\B
            ForEach *pGroups\pListObject()
               \B = *pGroups\B
               \Y = \B-\H
               If X > \X : X = \X : EndIf 
               If Y > \Y : Y = \Y : EndIf 
               If R < \R : R = \R : EndIf 
            Next 
            IsAlign = #True
            
         Case #Canvas_Align_Middle
            Middle = *pGroups\Y+*pGroups\H/2
            ForEach *pGroups\pListObject()
               \Y = Middle - \H/2
               \B = \Y+\H
               If X > \X : X = \X : EndIf 
               If Y > \Y : Y = \Y : EndIf 
               If R < \R : R = \R : EndIf 
               If B < \B : B = \B : EndIf
            Next 
            IsAlign = #True    
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

;分布对象
Procedure Object_SetAttribute_Distribute(*pMainDesign.__Design_MainInfo, Distribute)
   If *pMainDesign\pCurrObject = #Null : ProcedureReturn #False : EndIf 
   If *pMainDesign\pCurrObject <> *pMainDesign\ActiveObject : ProcedureReturn #False : EndIf 
   
   *pGroups.__Groups_BaseInfo = *pMainDesign\pCurrObject
   Count = ListSize(*pGroups\pListObject())
   If Count < 2 : ProcedureReturn #False : EndIf 
   Count-1
   X = 09999 : Y = 09999 : R = -9999 : B = -9999
   With *pGroups\pListObject()
      Select Distribute & $F
         Case #Canvas_Evenly_Left
         Case #Canvas_Evenly_Right  
         Case #Canvas_Evenly_Center 
         Case #Canvas_Evenly_Space  
            Distance.f = *pGroups\W
            ForEach *pGroups\pListObject()
               Distance- \W
            Next 
            Distance / Count
            Pos.f = *pGroups\X 
            ForEach *pGroups\pListObject()
               \X = Pos
               \R = \X+\W
               Pos+\W+Distance
            Next 
            ProcedureReturn #True
      EndSelect
      
      Select Distribute & $F0
         Case #Canvas_Evenly_Top   
         Case #Canvas_Evenly_Bottom 
         Case #Canvas_Evenly_Middle 
         Case #Canvas_Evenly_Border
            Distance.f = *pGroups\H
            ForEach *pGroups\pListObject()
               Distance- \H
            Next 
            Distance / Count
            Pos.f = *pGroups\Y 
            ForEach *pGroups\pListObject()
               \Y = Pos
               \B = \Y+\H
               Pos+\H+Distance
            Next 
            IsAlign = #True            
            ProcedureReturn #True
      EndSelect
   EndWith
   ProcedureReturn #False
EndProcedure

Procedure Object_SetAttribute_ObjectName(*pMainDesign.__Design_MainInfo, *pName, *pObject.__Groups_BaseInfo)
   If *pObject = #Null
      *pObject.__Groups_BaseInfo = *pMainDesign\pCurrObject
   EndIf 
   If *pObject And *pObject <> *pMainDesign\ActiveObject
      If *pObject = *pMainDesign\pCurrObject
         ObjectType = *pObject\ObjectType & $FF
         If ObjectType > #Object_Active And ObjectType <= #Object_Groups
            *pObject\ObjectName$ = PeekS(*pName)
            ProcedureReturn #True            
         EndIf 
      EndIf 
      ForEach *pMainDesign\pListObject()
         If *pMainDesign\pListObject() = *pObject
            ObjectType = *pObject\ObjectType & $FF
            If ObjectType > #Object_Active And ObjectType <= #Object_Groups
               *pObject\ObjectName$ = PeekS(*pName)
               ProcedureReturn #True            
            EndIf 
         EndIf 
      Next    
   EndIf 
   ProcedureReturn #False
EndProcedure   

;删除控件
Procedure Object_SetAttribute_ObjectDelete(*pMainDesign.__Design_MainInfo, *pObject.__Object_BaseInfo=#Null)
   If *pObject = #Null
      *pObject = *pMainDesign\pCurrObject     
   EndIf 
   If *pObject = #Null : ProcedureReturn : EndIf 

   Select *pObject\ObjectType & $FF
      Case #Object_Matter 
         IsDelete = Object_FreeMatter(*pMainDesign, *pObject)
         
      Case #Object_String
         IsDelete = Object_FreeString(*pMainDesign, *pObject)
         
      Case #Object_Active
         *pGroups.__Groups_BaseInfo = *pObject
         ForEach *pGroups\pListObject()
            IsDelete | Object_SetAttribute_ObjectDelete(*pMainDesign, *pGroups\pListObject())
         Next 
         ForEach *pMainDesign\pListObject()
            If *pMainDesign\pListObject() = *pObject
               IsDelete | DeleteElement(*pMainDesign\pListObject())
            EndIf 
         Next 
         *pMainDesign\pCurrObject = #Null
         
      Case #Object_Groups  
         *pGroups.__Groups_BaseInfo = *pObject
         ForEach *pGroups\pListObject()
            IsDelete | Object_SetAttribute_ObjectDelete(*pMainDesign, *pGroups\pListObject())
         Next 
         FreeList(*pGroups\pListObject())
         ForEach *pMainDesign\ListGroups()
            If *pMainDesign\ListGroups() = *pObject
               FreeList(*pMainDesign\ListGroups()\pListObject())
               IsDelete | DeleteElement(*pMainDesign\ListGroups())
            EndIf 
         Next 
         ForEach *pMainDesign\pListObject()
            If *pMainDesign\pListObject() = *pObject
               IsDelete | DeleteElement(*pMainDesign\pListObject())
            EndIf 
         Next 
         If *pMainDesign\pCurrObject = *pObject : *pMainDesign\pCurrObject = #Null : EndIf 
   EndSelect 
   ProcedureReturn IsDelete
EndProcedure

;删除控件
Procedure Object_SetAttribute_AlignGrids(*pMainDesign.__Design_MainInfo, *pObject.__Object_BaseInfo=#Null)
   *pObject.__Object_BaseInfo = *pMainDesign\pCurrObject
   If *pObject = #Null : ProcedureReturn : EndIf 
   Select *pObject\ObjectType & $FF
      Case #Object_Active
         *pListGroups.__Groups_BaseInfo = *pObject
         *pListGroups\X = 09999
         *pListGroups\Y = 09999 
         *pListGroups\R = -9999
         *pListGroups\B = -9999
      
         ForEach *pListGroups\pListObject()
            With *pListGroups\pListObject()
               AlignX = (Int(\X)+#Object_Event_Align/2)/#Object_Event_Align*#Object_Event_Align
               AlignY = (Int(\Y)+#Object_Event_Align/2)/#Object_Event_Align*#Object_Event_Align
               \X = AlignX
               \Y = AlignY
               \R = \X+\W
               \B = \Y+\H
               If *pListGroups\X > \X : *pListGroups\X = \X : EndIf 
               If *pListGroups\Y > \Y : *pListGroups\Y = \Y : EndIf 
               If *pListGroups\R < \R : *pListGroups\R = \R : EndIf 
               If *pListGroups\B < \B : *pListGroups\B = \B : EndIf
            EndWith
         Next 
         *pListGroups\W = *pListGroups\R - *pListGroups\X
         *pListGroups\H = *pListGroups\B - *pListGroups\Y
         
         
      Case #Object_Matter, #Object_String, #Object_Groups
         With *pObject
            AlignX = (Int(\X)+#Object_Event_Align/2)/#Object_Event_Align*#Object_Event_Align
            AlignY = (Int(\Y)+#Object_Event_Align/2)/#Object_Event_Align*#Object_Event_Align
            \X = AlignX
            \Y = AlignY
            \R = \X+\W
            \B = \Y+\H
         EndWith
   EndSelect 
   ProcedureReturn IsDelete
EndProcedure






;设置[画布]属性
Procedure Object_SetAttribute(*pMainDesign.__Design_MainInfo, Attribute, Value, ObjectID=#Null)
   Select Attribute
      Case #Attribute_CanvasZoom         ;设置[画布]的比例值,   Value: 25,50,75,100 
         ProcedureReturn Object_SetAttribute_CanvasZoom(*pMainDesign, Value)
      Case #Attribute_CanvasInfo         ;设置[画布]的四围信息, Value: *pCanvasInfo.__MCT_CanvasInfo 
         ProcedureReturn Object_SetAttribute_CanvasInfo(*pMainDesign, Value)         
      Case #Attribute_CanvasScrollX      ;设置[画布]的ScrollX,  Value: ScrollX
         If ObjectID = #True
            *pMainDesign\pMainCanvas\ScrollX + Value : ProcedureReturn #True
         Else 
            *pMainDesign\pMainCanvas\ScrollX = Value : ProcedureReturn #True
         EndIf 
      Case #Attribute_CanvasScrollY      ;设置[画布]的ScrollY,  Value: ScrollY 
         If ObjectID = #True
            *pMainDesign\pMainCanvas\ScrollY + Value : ProcedureReturn #True
         Else 
            *pMainDesign\pMainCanvas\ScrollY = Value : ProcedureReturn #True
         EndIf 
      Case #Attribute_CanvasWidth        ;设置[画布]的CanvasW,  Value: CanvasW
         *pMainDesign\pMainCanvas\CanvasW = Value : ProcedureReturn #True
      Case #Attribute_CanvasHeight       ;设置[画布]的CanvasH,  Value: CanvasH
         *pMainDesign\pMainCanvas\CanvasH = Value : ProcedureReturn #True
      Case #Attribute_DisplayGrid
         *pMainDesign\pMainModule\IsDisplayGrid = Value : ProcedureReturn #True 
         
      Case #Attribute_ObjectLayer        ;设置[对象]的层级,     Value: LayerIndex,  ObjectID=#Null时,为当前选中状态下的[对象
         ProcedureReturn Object_SetAttribute_ObjectLayer(*pMainDesign, Value, ObjectID)   
      Case #Attribute_MatterRotate       ;设置[元件]的旋转角度, Value: RotateIndex, ObjectID=#Null时,为当前选中状态下的[元件]
         ProcedureReturn Object_SetAttribute_MatterRotate(*pMainDesign, Value, ObjectID)
      Case #Attribute_ActiveObject       ;设置[对象]为当前选中状态,      Value=#Object_Selected,  ObjectID   
         ProcedureReturn Object_SetAttribute_ActiveObject(*pMainDesign, ObjectID)
      Case #Attribute_ActiveModule       ;设置[模块类型]为当前选中状态   Value=#Object_Selected,  ObjectID = ModuleID
         ProcedureReturn Object_SetAttribute_ActiveModule(*pMainDesign, ObjectID)
      Case #Attribute_StringText         ;设置[文本标签]的Text,  Value: @Text$  ,  ObjectID=#Null时,为当前选中状态下的[对象] 
         ProcedureReturn Object_SetAttribute_StringText(*pMainDesign, Value, ObjectID)
      Case #Attribute_StringFontSize     ;设置[文本标签]的hFont, Value: FontSize,  ObjectID=#Null时,为当前选中状态下的[对象] 
         ProcedureReturn Object_SetAttribute_StringFontSize(*pMainDesign, Value, ObjectID)
      Case #Attribute_StringFontColor    ;设置[文本标签]的hFont, Value: FontColor, ObjectID=#Null时,为当前选中状态下的[对象]
         ProcedureReturn Object_SetAttribute_StringFontColor(*pMainDesign, Value, ObjectID) 
      Case #Attribute_DupontColor
         ProcedureReturn Object_SetAttribute_DupontColor(*pMainDesign, Value) 
      Case #Attribute_ActiveGroups       ;设置当前选中的[对象组], Value:合并/解散   ObjectID
         ProcedureReturn Object_SetAttribute_ActiveGroups(*pMainDesign, Value, ObjectID) 
      Case #Attribute_Alignment          ;设置[活动对象]的对齐方式, Value:为对齐方式   ObjectID=#null
         ProcedureReturn Object_SetAttribute_Alignment(*pMainDesign, Value)
      Case #Attribute_Distribute         ;设置[活动对象]的分布方式, Value:为分布方式   ObjectID=#null
         ProcedureReturn Object_SetAttribute_Distribute(*pMainDesign, Value)   
      Case #Attribute_ObjectName         
         ProcedureReturn Object_SetAttribute_ObjectName(*pMainDesign, Value, ObjectID) 
      Case #Attribute_ObjectDelete         
         ProcedureReturn Object_SetAttribute_ObjectDelete(*pMainDesign, ObjectID)    
      Case #Attribute_AlignGrids         
         ProcedureReturn Object_SetAttribute_AlignGrids(*pMainDesign)             
         
   EndSelect
EndProcedure


;-
;- ******** [GetAttribute] ********

Procedure Object_GetAttribute_ObjectLayer(*pMainDesign.__Design_MainInfo, *pObject.__Groups_BaseInfo)
   If *pObject = #Null
      *pObject = *pMainDesign\pCurrObject
   EndIf 
   LayerIndex = 0
   ForEach *pMainDesign\pListObject()
      If *pMainDesign\pListObject() = *pObject
         ProcedureReturn LayerIndex
      EndIf 
      LayerIndex+1
   Next 
   ProcedureReturn -1
EndProcedure

Procedure Object_GetAttribute_MatterRotate(*pMainDesign.__Design_MainInfo, *pMatter.__Matter_BaseInfo)
   If *pMatter = #Null
      *pMatter = *pMainDesign\pCurrObject
      If *pMatter And *pMatter\ObjectType & $FF = #Object_Matter
         ProcedureReturn *pMatter\RotateIdx
      EndIf    
   ElseIf *pMainDesign\pCurrObject = *pMatter And *pMatter\ObjectType & $FF = #Object_Matter
      ProcedureReturn *pMatter\RotateIdx
   Else 
      ForEach *pMainDesign\ListMatter()
         If *pMainDesign\ListMatter() = *pMatter
            ProcedureReturn *pMatter\RotateIdx
        EndIf 
      Next 
   EndIf 
   ProcedureReturn -1
EndProcedure

Procedure Object_GetAttribute_ActiveObject(*pMainDesign.__Design_MainInfo, *pObjectType.long)
   *pObject.__Groups_BaseInfo = *pMainDesign\pCurrObject
   If *pObject And *pObjectType 
      *pObjectType\l = *pObject\ObjectType & $FF
   EndIf 
   ProcedureReturn *pObject
EndProcedure

Procedure Object_GetAttribute_ActiveModule(*pMainDesign.__Design_MainInfo, *pMatter.__Matter_BaseInfo)
   If *pMatter = #Null
      *pMatter = *pMainDesign\pCurrObject
      If *pMatter And *pMatter\ObjectType & $FF = #Object_Matter
         ProcedureReturn *pMatter\pMapModule
      EndIf 
   ElseIf *pMainDesign\pCurrObject = *pMatter And *pMatter\ObjectType & $FF = #Object_Matter
      ProcedureReturn *pMatter\pMapModule 
   Else 
      ForEach *pMainDesign\ListMatter()
         If *pMainDesign\ListMatter() = *pMatter
            ProcedureReturn *pMatter\pMapModule
         EndIf 
      Next 
   EndIf 
   ProcedureReturn #False
EndProcedure

Procedure Object_GetAttribute_StringText(*pMainDesign.__Design_MainInfo, *pString.__String_BaseInfo)
   If *pString = #Null
      *pString = *pMainDesign\pCurrObject
      If *pString And *pString\ObjectType & $FF = #Object_String
         ProcedureReturn @*pString\Text$
      EndIf 
   ElseIf *pMainDesign\pCurrObject = *pString And *pString\ObjectType & $FF = #Object_String
      ProcedureReturn @*pString\Text$
   Else 
      ForEach *pMainDesign\ListString()
         If *pMainDesign\ListString() = *pString
            ProcedureReturn @*pString\Text$
         EndIf 
      Next 
   EndIf 
   ProcedureReturn #False
EndProcedure

Procedure Object_GetAttribute_StringFontSize(*pMainDesign.__Design_MainInfo, *pString.__String_BaseInfo)
   If *pString = #Null
      *pString = *pMainDesign\pCurrObject
      If *pString And *pString\ObjectType & $FF = #Object_String
         ProcedureReturn *pString\FontSize
      EndIf 
   Else 
      ForEach *pMainDesign\ListString()
         If *pMainDesign\ListString() = *pString
            ProcedureReturn *pString\FontSize
         EndIf 
      Next 
   EndIf 
   ProcedureReturn #False
EndProcedure

Procedure Object_GetAttribute_StringFontColor(*pMainDesign.__Design_MainInfo, *pString.__String_BaseInfo)
   If *pString = #Null
      *pString = *pMainDesign\pCurrObject
      If *pString And *pString\ObjectType & $FF = #Object_String
         ProcedureReturn *pString\FontSize
      EndIf 
   Else
      ForEach *pMainDesign\ListString()
         If *pMainDesign\ListString() = *pString
            ProcedureReturn *pString\FontSize
         EndIf 
      Next 
   EndIf 
   ProcedureReturn #False
EndProcedure

Procedure Object_GetAttribute_DupontColor(*pMainDesign.__Design_MainInfo)
   If *pMainDesign\pCurrObject And *pMainDesign\pCurrDupont
      ProcedureReturn *pMainDesign\pCurrDupont\DupontColor & $FFFFFF
   EndIf 
   ProcedureReturn -1
EndProcedure


Procedure Object_GetAttribute_ObjectType(*pMainDesign.__Design_MainInfo, *pObject.__Groups_BaseInfo)
   If *pObject = #Null
      If *pMainDesign\pCurrObject
         ProcedureReturn *pMainDesign\pCurrObject\ObjectType & $FF
      EndIf 
   ElseIf *pMainDesign\pCurrObject = *pObject
      ProcedureReturn @*pMainDesign\pCurrObject\ObjectType & $FF
   Else 
      ForEach *pMainDesign\pListObject()
         If *pMainDesign\pListObject() = *pObject
            ProcedureReturn *pObject\ObjectType & $FF
         EndIf 
      Next 
   EndIf 
   ProcedureReturn #False
EndProcedure


Procedure Object_GetAttribute_ObjectName(*pMainDesign.__Design_MainInfo, *pObject.__Groups_BaseInfo)
   If *pObject = #Null
      If *pMainDesign\pCurrObject
         ProcedureReturn @*pMainDesign\pCurrObject\ObjectName$
      EndIf 
   ElseIf *pMainDesign\pCurrObject = *pObject
      ProcedureReturn @*pMainDesign\pCurrObject\ObjectName$
   Else  
      ForEach *pMainDesign\pListObject()
         If *pMainDesign\pListObject() = *pObject
            ProcedureReturn @*pObject\ObjectName$
         EndIf 
      Next 
   EndIf 
   ProcedureReturn #False
EndProcedure

Procedure Object_GetAttribute_ObjectX(*pMainDesign.__Design_MainInfo, *pObject.__Groups_BaseInfo)
   If *pObject = #Null
      If *pMainDesign\pCurrObject
         ProcedureReturn *pMainDesign\pCurrObject\X
      EndIf 
   ElseIf *pMainDesign\pCurrObject = *pObject
      ProcedureReturn *pMainDesign\pCurrObject\X
   Else  
      ForEach *pMainDesign\pListObject()
         If *pMainDesign\pListObject() = *pObject
            ProcedureReturn *pObject\X
         EndIf 
      Next 
   EndIf 
   ProcedureReturn #False
EndProcedure

Procedure Object_GetAttribute_ObjectY(*pMainDesign.__Design_MainInfo, *pObject.__Groups_BaseInfo)
   If *pObject = #Null
      If *pMainDesign\pCurrObject
         ProcedureReturn *pMainDesign\pCurrObject\Y
      EndIf 
   ElseIf *pMainDesign\pCurrObject = *pObject
      ProcedureReturn *pMainDesign\pCurrObject\Y
   Else  
      ForEach *pMainDesign\pListObject()
         If *pMainDesign\pListObject() = *pObject
            ProcedureReturn *pObject\Y
         EndIf 
      Next 
   EndIf 
   ProcedureReturn #False
EndProcedure


;设置[画布]属性
Procedure Object_GetAttribute(*pMainDesign.__Design_MainInfo, Attribute, ObjectID=#Null)

   Select Attribute
      Case #Attribute_CanvasZoom         ;获取[画布]的比例值,   返回值: 25,50,75,100 
         ProcedureReturn *pMainDesign\pMainCanvas\LayerZoom * 2000
      Case #Attribute_CanvasInfo         ;获取[画布]的四围信息, 返回值: *pCanvasInfo__MCT_CanvasInfo
         ProcedureReturn @*pMainDesign\pMainCanvas\ScrollX
      Case #Attribute_CanvasScrollX      ;获取[画布]的ScrollX,  返回值: ScrollX
         ProcedureReturn *pMainDesign\pMainCanvas\ScrollX
      Case #Attribute_CanvasScrollY      ;获取[画布]的ScrollY,  返回值: ScrollY
         ProcedureReturn *pMainDesign\pMainCanvas\ScrollY
      Case #Attribute_CanvasWidth        ;获取[画布]的CanvasW,  返回值: CanvasW
         ProcedureReturn *pMainDesign\pMainCanvas\CanvasW
      Case #Attribute_CanvasHeight       ;获取[画布]的CanvasH,  返回值: CanvasH
         ProcedureReturn *pMainDesign\pMainCanvas\CanvasH
         
      Case #Attribute_DisplayGrid
         ProcedureReturn *pMainDesign\pMainModule\IsDisplayGrid
      ;===================================
      Case #Attribute_ObjectLayer        ;获取[对象]的层级,      返回值: LayerIndex,  ObjectID=#Null时,为当前选中状态下的[对象]
         ProcedureReturn Object_GetAttribute_ObjectLayer(*pMainDesign, ObjectID)
      Case #Attribute_MatterRotate       ;获取[元件]的旋转角度,  返回值: RotateIndex, ObjectID=#Null时,为当前选中状态下的[元件]
         ProcedureReturn Object_GetAttribute_MatterRotate(*pMainDesign, ObjectID)
      Case #Attribute_ActiveObject       ;获取[对象]的ID,        返回值: ObjectID,  ObjectID为*pObjectID.long,则*pObjectID\l返回ObjectType 
         ProcedureReturn Object_GetAttribute_ActiveObject(*pMainDesign, ObjectID)
      Case #Attribute_ActiveModule       ;获取[模块类型]的ID     返回值: ModuleID,  ObjectID=#Null时,为当前选中状态下的[对象]
         ProcedureReturn Object_GetAttribute_ActiveModule(*pMainDesign, ObjectID)
      Case #Attribute_StringText         ;获取[文本标签]的Text,  返回值: @Text$  ,  ObjectID=#Null时,为当前选中状态下的[对象] 
         ProcedureReturn Object_GetAttribute_StringText(*pMainDesign, ObjectID)          
      Case #Attribute_StringFontSize     ;获取[文本标签]的hFont, 返回值: FontSize,  ObjectID=#Null时,为当前选中状态下的[对象] 
         ProcedureReturn Object_GetAttribute_StringFontSize(*pMainDesign, ObjectID) 
      Case #Attribute_StringFontColor    ;获取[文本标签]的hFont, 返回值: FontColor, ObjectID=#Null时,为当前选中状态下的[对象]  
         ProcedureReturn Object_GetAttribute_StringFontColor(*pMainDesign, ObjectID) 
      Case #Attribute_DupontColor
         ProcedureReturn Object_GetAttribute_DupontColor(*pMainDesign) 
      Case #Attribute_ObjectType         ;获取[对象]的类型,      返回值: ObjectType,  ObjectID=#Null时,为当前选中状态下的[对象]
         ProcedureReturn Object_GetAttribute_ObjectType(*pMainDesign, ObjectID) 
      Case #Attribute_ObjectName
         ProcedureReturn Object_GetAttribute_ObjectName(*pMainDesign, ObjectID)               
      Case #Attribute_ObjectX
         ProcedureReturn Object_GetAttribute_ObjectX(*pMainDesign, ObjectID) 
      Case #Attribute_ObjectY
         ProcedureReturn Object_GetAttribute_ObjectY(*pMainDesign, ObjectID) 
      Case #Attribute_ObjectModify
         ProcedureReturn *pMainDesign\IsModify
   EndSelect

EndProcedure


















; IDE Options = PureBasic 5.62 (Windows - x86)
; CursorPosition = 99
; FirstLine = 15
; Folding = wfTK--b7
; EnableXP