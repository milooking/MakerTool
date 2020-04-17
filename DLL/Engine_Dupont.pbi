;*****************************************
;******** 单片机仿真模拟器内核引擎 ********
;********    迷路仟 2020.02.04    ********
;*****************************************
;【Engine_Dupont.pbi】 ;杜邦线相关的及画布辅助的源代码
;- [Constant]
;{
#Direction_Up     = $000001
#Direction_Down   = $000002
#Direction_Right  = $000004
#Direction_Left   = $000008
#Direction_PPUp   = $000010   ;垂直于平台向上
#Direction_PPDown = $000020   ;垂直于平台向下
#Direction_Socket =  #Direction_Up|#Direction_Right|#Direction_Down|#Direction_Left

#LinkMode_Plug       = $01
#LinkMode_Socket     = $02
#LinkMode_Terminal   = $04

#Direction_Horiz  = #Direction_Right|#Direction_Left
#Direction_Verti  = #Direction_Up|#Direction_Down

#Canvas_ErrorValue = 0.01
;}


XIncludeFile "Engine_Design.pbi"  ;设计文档流文件相关的源代码文件


;-
;- ******** [PinPerfer] ********
;判断[引脚]域
Procedure Dupont_PinPrefer_Search(*pListMatter.__Matter_BaseInfo, *pPinsParam.__Module_PinParam, X.f, Y.f)   
   With *pListMatter
      If *pPinsParam\OffsetW >= 0 
         PinX.f = \X+*pPinsParam\OffsetX   - #Module_DupontPitch/2
         PinR.f = PinX+*pPinsParam\OffsetW + #Module_DupontPitch
      Else 
         PinX.f = \X+*pPinsParam\OffsetX+*pPinsParam\OffsetW - #Module_DupontPitch/2
         PinR.f = PinX-*pPinsParam\OffsetW + #Module_DupontPitch
      EndIf 
      
      If *pPinsParam\OffsetH >= 0 
         PinY.f = \Y+*pPinsParam\OffsetY   - #Module_DupontPitch/2
         PinB.f = PinY+*pPinsParam\OffsetH + #Module_DupontPitch
      Else 
         PinY.f = \Y+*pPinsParam\OffsetY+*pPinsParam\OffsetH - #Module_DupontPitch/2
         PinB.f = PinY-*pPinsParam\OffsetH + #Module_DupontPitch
      EndIf 
      If PinX <= X And X <= PinR And PinY < Y And Y < PinB
         ProcedureReturn #True
      EndIf 
   EndWith
   ProcedureReturn #False
EndProcedure

;MouseMove状态下寻找[源引脚]
Procedure Dupont_PinPrefer_Origin(*pMainDesign.__Design_MainInfo, X.f, Y.f) 
   ForEach *pMainDesign\ListMatter()
      *pListMatter.__Matter_BaseInfo = *pMainDesign\ListMatter()
      With *pListMatter
         If \X <= X And X <=\R And \Y < Y And Y <\B 
            ForEach \ListPinPrefer()
               *pPinParam.__Module_PinParam = \ListPinPrefer()\pListPinParam
               ;如果[目标引脚]是[源引脚],则要跳过
               If \ListPinPrefer()\pOriginDupont : Continue : EndIf 
               If \ListPinPrefer()\pTargetDupont : Continue : EndIf 
               If \ListPinPrefer()\pListPinParam\GroupType = #GroupType_Group : Continue : EndIf 
               If Dupont_PinPrefer_Search(*pListMatter, *pPinParam, X, Y)
                  *pOriginPin = \ListPinPrefer()
                  *pPinAttri = *pPinParam\pListPinAttri
                  Break
               EndIf 
            Next 
         EndIf 
      EndWith 
   Next   
   
   If *pMainDesign\ActiveDupont\pOriginPin <> *pOriginPin
      *pMainDesign\ActiveDupont\pOriginPin = *pOriginPin
      *pMainDesign\pPinAttri   = *pPinAttri
      *pMainDesign\ToolTipX  = X
      *pMainDesign\ToolTipY  = Y
      NeedRefresh = #True
      Debug "[Dupont_Modify] 搜索[源引脚]", #DebugLevel_Dupont_Modify
   EndIf 
   ProcedureReturn NeedRefresh
EndProcedure

;MouseMove状态下寻找[目标引脚]
Procedure Dupont_PinPrefer_Target(*pMainDesign.__Design_MainInfo, X.f, Y.f) 
   ForEach *pMainDesign\ListMatter()
      *pListMatter.__Matter_BaseInfo = *pMainDesign\ListMatter()
      With *pListMatter
         If \X <= X And X <=\R And \Y < Y And Y <\B 
            ForEach \ListPinPrefer()
               *pPinParam.__Module_PinParam = \ListPinPrefer()\pListPinParam
               ;如果[目标引脚]是[源引脚],则要跳过
               If \ListPinPrefer()\pOriginDupont : Continue : EndIf 
               If \ListPinPrefer()\pTargetDupont : Continue : EndIf 
               If \ListPinPrefer()\pListPinParam\GroupType = #GroupType_Group : Continue : EndIf 
               If Dupont_PinPrefer_Search(*pListMatter, *pPinParam, X, Y)
                  *pTargetPin = \ListPinPrefer()
                  *pPinAttri = *pPinParam\pListPinAttri
                  Break
               EndIf 
            Next 
         EndIf 
      EndWith 
   Next         
   If *pMainDesign\ActiveDupont\pTargetPin <> *pTargetPin
      *pMainDesign\ActiveDupont\pTargetPin = *pTargetPin
      *pMainDesign\pPinAttri = *pPinAttri
      *pMainDesign\ToolTipX  = X
      *pMainDesign\ToolTipY  = Y
      NeedRefresh = #True
      Debug "[Dupont_Modify] 搜索[目标引脚]", #DebugLevel_Dupont_Modify
   EndIf 
   ProcedureReturn NeedRefresh
EndProcedure

;-
;- ******** [Active] ********
;创建[杜邦线]
Procedure Dupont_Active_Create(*pMainDesign.__Design_MainInfo, *pPinPrefer.__Matter_PinPrefer, OriginPosX, OriginPosY, X.f, Y.f)
   With *pMainDesign\ActiveDupont
      *pMainDesign\pCurrDupont = *pMainDesign\ActiveDupont
      \ObjectType    = #Object_Dupont|#Object_Event_Active
      \X             = X
      \Y             = Y
      \OffsetX       = X
      \OffsetY       = Y
      \OriginPos\X   = OriginPosX
      \OriginPos\Y   = OriginPosY
      \OriginPos\Direction = *pPinPrefer\PinDirection
      \TargetPos\X   = OriginPosX
      \TargetPos\Y   = OriginPosY  
      \TargetPos\Direction = *pPinPrefer\PinDirection
      \CurrDirection = *pPinPrefer\PinDirection
      \DupontColor   = *pPinPrefer\pListPinParam\pListPinAttri\PinsColor
      \pOriginPin    = *pPinPrefer
      \pTargetPin    = #Null
      \pListNodus    = #Null
   EndWith 
   ProcedureReturn #True 
EndProcedure

;创建/修改[杜邦线]
Procedure Dupont_Active_Inital(*pMainDesign.__Design_MainInfo, *pListObject.__Object_BaseInfo, X.f, Y.f)
   If *pListObject = #Null : ProcedureReturn : EndIf 
   
   Select *pListObject\ObjectType & $FF
      Case #Object_Matter 
         With *pListObject
            If \X > X And X >\R And \Y > Y And Y >\B : ProcedureReturn : EndIf 
         EndWith   
         
         *pListMatter.__Matter_BaseInfo = *pListObject
         ForEach *pListMatter\ListPinPrefer()
            ;去除[编组]选项
            If *pListMatter\ListPinPrefer()\pListPinParam\GroupType = #GroupType_Group : Continue : EndIf 
            ;如果[杜邦线]存在,将[源引脚]数据转移动到[ModifyPos]上
            *pPinParam.__Module_PinParam = *pListMatter\ListPinPrefer()\pListPinParam
            If *pListMatter\ListPinPrefer()\pOriginDupont 
               If Dupont_PinPrefer_Search(*pListMatter, *pPinParam, X, Y)
                  *pDupont.__Dupont_BaseInfo = *pListMatter\ListPinPrefer()\pOriginDupont
                  *pDupont\ModifyPos\X = *pDupont\OriginPos\X
                  *pDupont\ModifyPos\Y = *pDupont\OriginPos\Y
                  *pDupont\ObjectType  = #Object_Dupont|#Object_Event_Modify     ;这里要改成#Object_Event_Origin,才不会被LeftButtonUp,清空
                  *pMainDesign\pCurrDupont = *pDupont
                  Debug "[Dupont_Modify] ==> 从[ 源引脚 ]进入[杜邦线]修改模式 <============== ", #DebugLevel_Dupont_Modify
                  ProcedureReturn #True
               EndIf 
            EndIf 
            
            ;如果[杜邦线]存在,将[目标引脚]数据转移动到[ModifyPos]上
            If *pListMatter\ListPinPrefer()\pTargetDupont 
               If Dupont_PinPrefer_Search(*pListMatter, *pPinParam, X, Y)
                  *pDupont.__Dupont_BaseInfo = *pListMatter\ListPinPrefer()\pTargetDupont
                  *pDupont\ModifyPos\X = *pDupont\TargetPos\X
                  *pDupont\ModifyPos\Y = *pDupont\TargetPos\Y
                  *pDupont\ObjectType  = #Object_Dupont|#Object_Event_Modify     ;这里要改成#Object_Event_Target,才不会被LeftButtonUp,清空
                  *pMainDesign\pCurrDupont = *pDupont
                  Debug "[Dupont_Modify] ==> 从[目标引脚]进入[杜邦线]修改模式 <============== ", #DebugLevel_Dupont_Modify
                  ProcedureReturn #True
               EndIf 
            EndIf 
            
            If Dupont_PinPrefer_Search(*pListMatter, *pPinParam, X, Y)
               *pPinPrefer.__Matter_PinPrefer = *pListMatter\ListPinPrefer()
               OriginPosX = *pListMatter\X+*pPinParam\OffsetX + *pPinParam\OffsetW
               OriginPosY = *pListMatter\Y+*pPinParam\OffsetY + *pPinParam\OffsetH
               *pPinPrefer\pOriginDupont = *pMainDesign\ActiveDupont
               Dupont_Active_Create(*pMainDesign, *pPinPrefer, OriginPosX, OriginPosY, X, Y)
               Debug "[Dupont_Create] ==> 从[ 源引脚 ]开头新建[杜邦线] <============== ", #DebugLevel_Dupont_Create
               ProcedureReturn #True
            EndIf 
         Next 
         
      Case #Object_Groups, #Object_Active
         *pGroups.__Groups_BaseInfo = *pListObject
         With *pGroups
            If \X <= X And X <=\R And \Y < Y And Y <\B 
               ForEach *pGroups\pListObject()
                  NeedRefresh = Dupont_Active_Inital(*pMainDesign, *pGroups\pListObject(), X, Y)
                  If NeedRefresh
                     ProcedureReturn #True
                  EndIf 
               Next 
            EndIf 
         EndWith
   EndSelect
   ProcedureReturn #False 
EndProcedure

;取消[杜邦线]的创建/修改
Procedure Dupont_Active_Cancel(*pMainDesign.__Design_MainInfo)
   If *pMainDesign\pCurrDupont = #Null : ProcedureReturn :EndIf 
   Select *pMainDesign\pCurrDupont\ObjectType & #Object_Event
      Case #Object_Event_Active
         With *pMainDesign\ActiveDupont
            If \pOriginPin
               \pOriginPin\pOriginDupont = #Null
               \pOriginPin\pTargetDupont = #Null
               \pOriginPin  = #Null
            EndIf 
            If \pTargetPin
               \pTargetPin\pOriginDupont = #Null
               \pTargetPin\pTargetDupont = #Null
               \pTargetPin             = #Null
            EndIf       
            \pListNodus   = #Null
            ClearList(\ListNodus())
            *pMainDesign\pCurrObject = #Null
         EndWith
         *pMainDesign\pCurrDupont = #Null
         Debug "[Dupont_Create] ==> 中断[杜邦线]创建模式 <============== ", #DebugLevel_Dupont_Create
         
      Case #Object_Event_Origin, #Object_Event_Target, #Object_Event_DuNode, #Object_Event_Modify, #Null
         *pMainDesign\pCurrDupont\ObjectType = #Object_Dupont
         *pMainDesign\pCurrDupont = #Null
         *pMainDesign\pCurrDuNode = #Null
         Debug "[Dupont_Modify] ==> 退出[杜邦线]修改模式 <============== ", #DebugLevel_Dupont_Modify
   EndSelect 
   ProcedureReturn #True
EndProcedure

;删除[杜邦线]
Procedure Dupont_Active_Delete(*pMainDesign.__Design_MainInfo, X.f, Y.f)
   If *pMainDesign\pCurrDupont = #Null : ProcedureReturn :EndIf 
   If *pMainDesign\pCurrDupont\ObjectType =  #Object_Dupont|#Object_Event_Modify
      ;如果右键点击在引脚上,且引脚上有[杜邦线],则视为删除它
      *pListDupont.__Dupont_BaseInfo = *pMainDesign\pCurrDupont
      *pListMatter.__Matter_BaseInfo = *pListDupont\pOriginPin\pParentMatter
      *pPinParam.__Module_PinParam  = *pListDupont\pOriginPin\pListPinParam
      IsDelete = Dupont_PinPrefer_Search(*pListMatter, *pPinParam, X, Y) 
      If IsDelete = #False
         *pListMatter.__Matter_BaseInfo = *pListDupont\pTargetPin\pParentMatter
         *pPinParam.__Module_PinParam  = *pListDupont\pTargetPin\pListPinParam
         IsDelete = Dupont_PinPrefer_Search(*pListMatter, *pPinParam, X, Y) 
      EndIf 
      If IsDelete = #True
         ForEach *pMainDesign\ListDupont()
            If *pMainDesign\ListDupont() = *pListDupont
               *pListDupont\pOriginPin\pOriginDupont = #Null
               *pListDupont\pOriginPin\pTargetDupont = #Null
               *pListDupont\pTargetPin\pOriginDupont = #Null
               *pListDupont\pTargetPin\pTargetDupont = #Null
               ClearList(*pListDupont\ListNodus())
               DeleteElement(*pMainDesign\ListDupont())
            EndIf 
         Next 
         *pMainDesign\pCurrDuNode = #Null
         *pMainDesign\pCurrDupont = #Null
         Debug "[Dupont_Modify] ==> 删除[杜邦线]成功 <============== ", #DebugLevel_Dupont_Modify
         ProcedureReturn #True         
      EndIf 
   EndIf 
EndProcedure

;-
;- ******** [Modify] ********
;激活[杜邦线]引脚
Procedure Dupont_Modify_Active(*pMainDesign.__Design_MainInfo, X.f, Y.f)
   *pCurrDupont.__Dupont_BaseInfo = *pMainDesign\pCurrDupont

   ;判断是否要修改[杜邦线]的[源引脚]
   *pListMatter.__Matter_BaseInfo = *pCurrDupont\pOriginPin\pParentMatter
   *pPinPrefer.__Matter_PinPrefer = *pCurrDupont\pOriginPin
   *pPinsParam.__Module_PinParam  = *pPinPrefer\pListPinParam
   If Dupont_PinPrefer_Search(*pListMatter, *pPinsParam, X, Y)
      *pCurrDupont\ObjectType = #Object_Dupont|#Object_Event_Origin
      *pCurrDupont\OffsetX = X - *pCurrDupont\OriginPos\X
      *pCurrDupont\OffsetY = Y - *pCurrDupont\OriginPos\Y
      Debug "[Dupont_Modify] 修改目标 ==> OriginPin", #DebugLevel_Dupont_Modify
      ProcedureReturn #False
   EndIf   
   
   ;判断是否要修改[杜邦线]的[目标引脚]
   *pListMatter.__Matter_BaseInfo = *pCurrDupont\pTargetPin\pParentMatter
   *pPinPrefer.__Matter_PinPrefer = *pCurrDupont\pTargetPin
   *pPinsParam.__Module_PinParam  = *pPinPrefer\pListPinParam
   If Dupont_PinPrefer_Search(*pListMatter, *pPinsParam, X, Y)
      *pCurrDupont\ObjectType = #Object_Dupont|#Object_Event_Target
      *pCurrDupont\OffsetX = X - *pCurrDupont\TargetPos\X
      *pCurrDupont\OffsetY = Y - *pCurrDupont\TargetPos\Y
      Debug "[Dupont_Modify] 修改目标 TargetPin", #DebugLevel_Dupont_Modify
      ProcedureReturn #False
   EndIf   

   *pPrevDupont = #Null
   ForEach *pCurrDupont\ListNodus()
      *pListNodus.__DuNode_BaseInfo = *pCurrDupont\ListNodus() ;此处一定要采用*pListNodus来过渡,因为后有个NextElement()
      With *pListNodus
         If Abs(\X - X) < 30 And Abs(\Y - Y) < 30
            *pMainDesign\pCurrDuNode = *pCurrDupont\ListNodus()
            \OffsetX = X - \X
            \OffsetY = Y - \Y
            \pPrevDuNode = *pPrevDupont
            \pNextDuNode = NextElement(*pCurrDupont\ListNodus())
            *pCurrDupont\ObjectType = #Object_Dupont|#Object_Event_DuNode
            Debug "[Dupont_Modify] 修改目标 DuNode", #DebugLevel_Dupont_Modify
            ProcedureReturn #True
         EndIf 
      EndWith
      *pPrevDupont = *pCurrDupont\ListNodus()
   Next 
   If *pMainDesign\pCurrDuNode
      *pMainDesign\pCurrDuNode = #Null
      ProcedureReturn #True
   EndIf 
   ProcedureReturn #False
EndProcedure

;移动[杜邦线][源引脚]
Procedure Dupont_Modify_Origin(*pMainDesign.__Design_MainInfo, X.f, Y.f)
   *pCurrDupont.__Dupont_BaseInfo = *pMainDesign\pCurrDupont
   With *pCurrDupont
      \ModifyPos\X = X - \OffsetX
      \ModifyPos\Y = Y - \OffsetY
      *pListNodus.__DuNode_BaseInfo = FirstElement(\ListNodus())
      If *pListNodus  
         If *pListNodus\Direction = #Direction_Verti
            *pListNodus\X = \ModifyPos\X
         ElseIf *pListNodus\Direction = #Direction_Horiz 
            *pListNodus\Y = \ModifyPos\Y
         EndIf 
      EndIf 
      ;取消目标引脚
      If \pModifyPin
         \pModifyPin\pOriginDupont = #Null
         \pModifyPin = #Null
      EndIf 
      If \pOriginPin
         \pOriginPin\pOriginDupont = #Null
      EndIf   
   EndWith
; 
   ;寻找新的[目标引脚]
   ForEach *pMainDesign\ListMatter()
      *pListMatter.__Matter_BaseInfo = *pMainDesign\ListMatter()
      With *pListMatter
         If \X <= X And X <=\R And \Y < Y And Y <\B 
            ForEach *pListMatter\ListPinPrefer()
               ;如果[目标引脚]是[源引脚],则要跳过
               If \ListPinPrefer()\pOriginDupont : Continue : EndIf 
               If \ListPinPrefer()\pTargetDupont : Continue : EndIf 
               If \ListPinPrefer()\pListPinParam\GroupType = #GroupType_Group : Continue : EndIf 
               *pPinParam.__Module_PinParam = \ListPinPrefer()\pListPinParam
               If Dupont_PinPrefer_Search(*pListMatter, *pPinParam, X, Y)   
                  *pMatterPins.__Matter_PinPrefer = \ListPinPrefer()
                  *pMatterPins\pOriginDupont          = *pCurrDupont
                  *pMainDesign\pCurrDupont\pModifyPin = *pMatterPins
                  Break
               EndIf 
            Next 
         EndIf 
      EndWith
   Next 
   Debug "[Dupont_Modify] 移动[源引脚]:"+Str(*pCurrDupont\ModifyPos\X)+","+Str(*pCurrDupont\ModifyPos\Y), #DebugLevel_Dupont_Modify
   ProcedureReturn #True
EndProcedure

;移动[杜邦线][目标引脚]
Procedure Dupont_Modify_Target(*pMainDesign.__Design_MainInfo, X.f, Y.f)
   *pCurrDupont.__Dupont_BaseInfo = *pMainDesign\pCurrDupont
   With *pCurrDupont
      \ModifyPos\X = X - \OffsetX
      \ModifyPos\Y = Y - \OffsetY
      
      *pListNodus.__DuNode_BaseInfo = LastElement(\ListNodus())
      If *pListNodus  
         If *pListNodus\Direction = #Direction_Horiz
            *pListNodus\X = \ModifyPos\X
         ElseIf *pListNodus\Direction =  #Direction_Verti
            *pListNodus\Y = \ModifyPos\Y
         EndIf 
      EndIf 
      
      ;取消目标引脚
      If \pModifyPin
         \pModifyPin\pTargetDupont = #Null
         \pModifyPin = #Null
      EndIf 
      If \pTargetPin
         \pTargetPin\pTargetDupont = #Null
      EndIf       
   EndWith
   
   ;寻找新的[目标引脚]
   ForEach *pMainDesign\ListMatter()
      *pListMatter.__Matter_BaseInfo = *pMainDesign\ListMatter()
      With *pListMatter
         If \X <= X And X <=\R And \Y < Y And Y <\B 
            ForEach *pListMatter\ListPinPrefer()
               ;如果[目标引脚]是[源引脚],则要跳过
               If \ListPinPrefer()\pOriginDupont : Continue : EndIf 
               If \ListPinPrefer()\pTargetDupont : Continue : EndIf 
               If \ListPinPrefer()\pListPinParam\GroupType = #GroupType_Group : Continue : EndIf 
               *pPinParam.__Module_PinParam = \ListPinPrefer()\pListPinParam
               If Dupont_PinPrefer_Search(*pListMatter, *pPinParam, X, Y)   
                  *pMatterPins.__Matter_PinPrefer = \ListPinPrefer()
                  *pMatterPins\pTargetDupont          = *pCurrDupont
                  *pMainDesign\pCurrDupont\pModifyPin = *pMatterPins
                  Break
               EndIf 
            Next 
         EndIf  
      EndWith
   Next 
   Debug "[Dupont_Modify] 移动[目标引脚]:"+Str(*pCurrDupont\ModifyPos\X)+","+Str(*pCurrDupont\ModifyPos\Y), #DebugLevel_Dupont_Modify
   ProcedureReturn #True
EndProcedure

;移动[杜邦线][节点]
Procedure Dupont_Modify_DuNode(*pMainDesign.__Design_MainInfo, X.f, Y.f, IsAlign)
   If *pMainDesign\pCurrDuNode
      With *pMainDesign\pCurrDuNode
         If \pPrevDuNode = #Null And \pNextDuNode = #Null 
         ElseIf \pPrevDuNode = #Null
            If \Direction = #Direction_Horiz
               \X = X - \OffsetX
               \pNextDuNode\X = \X
               If IsAlign And Int(\X) % #Object_Event_Align < 10 : VertiAlign = Int(\X)/#Object_Event_Align*#Object_Event_Align : EndIf 
            ElseIf \Direction = #Direction_Verti 
               \Y = Y - \OffsetY
               \pNextDuNode\Y = \Y
               If IsAlign And Int(\Y) % #Object_Event_Align < 10 : HorizAlign = Int(\Y)/#Object_Event_Align*#Object_Event_Align : EndIf
            EndIf 
         ElseIf \pNextDuNode = #Null 
            If \Direction = #Direction_Verti
               \X = X - \OffsetX
               \pPrevDuNode\X = \X
               If IsAlign And Int(\X) % #Object_Event_Align < 10 : VertiAlign = Int(\X)/#Object_Event_Align*#Object_Event_Align : EndIf 
            ElseIf \Direction = #Direction_Horiz 
               \Y = Y - \OffsetY
               \pPrevDuNode\Y = \Y
               If IsAlign And Int(\Y) % #Object_Event_Align < 10 : HorizAlign = Int(\Y)/#Object_Event_Align*#Object_Event_Align : EndIf
            EndIf
         Else 
            \X = X - \OffsetX
            \Y = Y - \OffsetY
            If IsAlign And Int(\X) % #Object_Event_Align < 10 : VertiAlign = Int(\X)/#Object_Event_Align*#Object_Event_Align : EndIf 
            If IsAlign And Int(\Y) % #Object_Event_Align < 10 : HorizAlign = Int(\Y)/#Object_Event_Align*#Object_Event_Align : EndIf
            If \Direction = #Direction_Horiz
               \pNextDuNode\X = \X               
               \pPrevDuNode\Y = \Y
            ElseIf \Direction = #Direction_Verti 
               \pPrevDuNode\X = \X
               \pNextDuNode\Y = \Y
            EndIf 
         EndIf 
         *pMainDesign\VertiAlign = VertiAlign
         *pMainDesign\HorizAlign = HorizAlign 
         Debug "[Dupont_Modify] 移动[节点]:"+Str(\X)+","+Str(\Y), #DebugLevel_Dupont_Modify
      EndWith
      ProcedureReturn #True
   EndIf 
   ProcedureReturn #False
EndProcedure

;-
;- ******** [Change] ********

;修改[杜邦线][源引脚]
Procedure Dupont_Change_Origin(*pMainDesign.__Design_MainInfo)
   With *pMainDesign\pCurrDupont
      If \pModifyPin = #Null
         \pOriginPin\pOriginDupont     = *pMainDesign\pCurrDupont
         \ModifyPos\X = \OriginPos\X
         \ModifyPos\Y = \OriginPos\Y
         *pListNodus.__DuNode_BaseInfo = FirstElement(\ListNodus())
         If *pListNodus  
            If *pListNodus\Direction = #Direction_Verti
               *pListNodus\X = \ModifyPos\X
            ElseIf *pListNodus\Direction = #Direction_Horiz 
               *pListNodus\Y = \ModifyPos\Y
            EndIf 
         EndIf 
         *pMainDesign\pCurrDupont\ObjectType = #Object_Dupont|#Object_Event_Modify
         Debug "[Dupont_Modify] 还原[源引脚] ************ ", #DebugLevel_Dupont_Modify 
      Else 
         \pOriginPin = \pModifyPin
         \pOriginPin\pOriginDupont      = *pMainDesign\pCurrDupont
         *pListMatter.__Matter_BaseInfo = \pOriginPin\pParentMatter
         *pPinParam.__Module_PinParam   = \pOriginPin\pListPinParam
         \OriginPos\X = *pListMatter\X + *pPinParam\OffsetX + *pPinParam\OffsetW
         \OriginPos\Y = *pListMatter\Y + *pPinParam\OffsetY + *pPinParam\OffsetH
         
         *pListNodus.__DuNode_BaseInfo = FirstElement(\ListNodus())
         If *pListNodus  
            If *pListNodus\Direction = #Direction_Verti
               *pListNodus\X = \OriginPos\X
            ElseIf *pListNodus\Direction = #Direction_Horiz 
               *pListNodus\Y = \OriginPos\Y
            EndIf 
         EndIf 
         \pModifyPin = #Null
         *pMainDesign\pCurrDupont\ObjectType = #Object_Dupont|#Object_Event_Modify
         Debug "[Dupont_Modify] 完成[源引脚]调换 ************ ", #DebugLevel_Dupont_Modify 
      EndIf 
   EndWith
   ProcedureReturn #True
EndProcedure

;修改[杜邦线][目标引脚]
Procedure Dupont_Change_Target(*pMainDesign.__Design_MainInfo)
   With *pMainDesign\pCurrDupont
      If \pModifyPin = #Null
         \pTargetPin\pTargetDupont    = *pMainDesign\pCurrDupont
         \ModifyPos\X = \TargetPos\X
         \ModifyPos\Y = \TargetPos\Y
         *pListNodus.__DuNode_BaseInfo = LastElement(\ListNodus())
         If *pListNodus  
            If *pListNodus\Direction = #Direction_Horiz
               *pListNodus\X = \TargetPos\X
            ElseIf *pListNodus\Direction =  #Direction_Verti
               *pListNodus\Y = \TargetPos\Y
            EndIf 
         EndIf 
         *pMainDesign\pCurrDupont\ObjectType = #Object_Dupont|#Object_Event_Modify
         Debug "[Dupont_Modify] 还原[目标引脚] ************", #DebugLevel_Dupont_Modify 
      Else 
         \pTargetPin = \pModifyPin
         \pTargetPin\pTargetDupont      = *pMainDesign\pCurrDupont
         *pListMatter.__Matter_BaseInfo = \pTargetPin\pParentMatter
         *pPinParam.__Module_PinParam   = \pTargetPin\pListPinParam
         \TargetPos\X = *pListMatter\X + *pPinParam\OffsetX + *pPinParam\OffsetW
         \TargetPos\Y = *pListMatter\Y + *pPinParam\OffsetY + *pPinParam\OffsetH
         
         *pListNodus.__DuNode_BaseInfo = LastElement(\ListNodus())
         If *pListNodus  
            If *pListNodus\Direction = #Direction_Horiz
               *pListNodus\X = \TargetPos\X
            ElseIf *pListNodus\Direction =  #Direction_Verti
               *pListNodus\Y = \TargetPos\Y
            EndIf 
         EndIf 
         \pModifyPin = #Null
         *pMainDesign\pCurrDupont\ObjectType = #Object_Dupont|#Object_Event_Modify
         Debug "[Dupont_Modify] 完成[目标引脚]调换 ************", #DebugLevel_Dupont_Modify 
      EndIf 
   EndWith
   ProcedureReturn #True
EndProcedure

;修改[杜邦线][节点]
Procedure Dupont_Change_DuNode(*pMainDesign.__Design_MainInfo)
   With *pMainDesign\pCurrDuNode
      If *pMainDesign\HorizAlign And *pMainDesign\VertiAlign 
         X.f = *pMainDesign\VertiAlign+\OffsetX
         Y.f = *pMainDesign\HorizAlign+\OffsetY      ;对象自动对        
         Dupont_Modify_DuNode(*pMainDesign, X, Y, #False)
      ElseIf *pMainDesign\HorizAlign 
         X.f = \X+\OffsetX
         Y.f = *pMainDesign\HorizAlign+\OffsetY      ;对象自动对        
         Dupont_Modify_DuNode(*pMainDesign, X, Y, #False)
      ElseIf *pMainDesign\VertiAlign 
         X.f = *pMainDesign\VertiAlign+\OffsetX
         Y.f = \Y+\OffsetY                           ;对象自动对             
         Dupont_Modify_DuNode(*pMainDesign, X, Y, #False)
      EndIf 
      
      *pMainDesign\HorizAlign = #Null           ;取消对齐线  
      *pMainDesign\VertiAlign = #Null           ;取消对齐线      
      *pMainDesign\pCurrDupont\ObjectType = #Object_Dupont|#Object_Event_Modify
      NeedRefresh = #True 
   EndWith
   Debug "[Dupont_Modify] 完成[节点] ************ ", #DebugLevel_Dupont_Modify 
   ProcedureReturn #True
EndProcedure

;-
;- ******** [DuNode]********
;计算[杜邦线]选择域
Procedure Dupont_DuNode_Search(*pListDupont.__Dupont_BaseInfo)        
   ;获取[杜邦线]的空间尺寸
   LimitX.f = 09999
   LimitY.f = 09999 
   LimitR.f = -9999
   LimitB.f = -9999
   With *pListDupont
      If LimitX > \OriginPos\X : LimitX = \OriginPos\X : EndIf
      If LimitY > \OriginPos\Y : LimitY = \OriginPos\Y : EndIf 
      If LimitR < \OriginPos\X : LimitR = \OriginPos\X : EndIf 
      If LimitB < \OriginPos\Y : LimitB = \OriginPos\Y : EndIf
      
      If LimitX > \TargetPos\X : LimitX = \TargetPos\X : EndIf
      If LimitY > \TargetPos\Y : LimitY = \TargetPos\Y : EndIf 
      If LimitR < \TargetPos\X : LimitR = \TargetPos\X : EndIf 
      If LimitB < \TargetPos\Y : LimitB = \TargetPos\Y : EndIf
      ForEach \ListNodus()
         If LimitX > \ListNodus()\X : LimitX = \ListNodus()\X : EndIf
         If LimitY > \ListNodus()\Y : LimitY = \ListNodus()\Y : EndIf 
         If LimitR < \ListNodus()\X : LimitR = \ListNodus()\X : EndIf 
         If LimitB < \ListNodus()\Y : LimitB = \ListNodus()\Y : EndIf
      Next 
      \X = LimitX
      \Y = LimitY
      \R = LimitR
      \B = LimitB
      \W = LimitR-LimitX
      \H = LimitB-LimitY
   EndWith
EndProcedure
  
;添加[杜邦线][节点]自带新建[杜邦线]代码
Procedure Dupont_DuNode_Create(*pMainDesign.__Design_MainInfo, X.f, Y.f)

   With *pMainDesign\ActiveDupont
      If Abs(\TargetPos\X - X) < #Module_CellSpacing : X = \TargetPos\X : EndIf 
      If Abs(\TargetPos\Y - Y) < #Module_CellSpacing : Y = \TargetPos\Y : EndIf 
      ;如果[目标引脚]出现,则修改当前[杜邦线]节点为[目标引脚]处的[节点]
      If \pTargetPin
         *pListMatter.__Matter_BaseInfo = \pTargetPin\pParentMatter
         *pPinParam.__Module_PinParam   = \pTargetPin\pListPinParam
         X = *pListMatter\X + *pPinParam\OffsetX + *pPinParam\OffsetW
         Y = *pListMatter\Y + *pPinParam\OffsetY + *pPinParam\OffsetH
      EndIf 
      ;#Direction_Verti: 垂直方向
      ;#Direction_Horiz: 水平方向
      Select \CurrDirection
         Case #Direction_PPUp, #Direction_PPDown 
            If Abs(\TargetPos\X - X) <= Abs(\TargetPos\Y - Y)
               \pListNodus = AddElement(\ListNodus())     ;添加一个[节点]
               \ListNodus()\X         = \TargetPos\X      ;采用[源引脚]的X坐标
               \ListNodus()\Y         = Y                 ;采用光标处的Y坐标
               \ListNodus()\Direction = #Direction_Verti  ;定义[节点]方向
               \TargetPos\X           = X                 ;刷新[目标节点]的Y坐标                
               \TargetPos\Y           = Y                 ;刷新[目标节点]的Y坐标 
               \CurrDirection = #Direction_Verti
               Debug "[Dupont_Create]⊥A New ("+RSet(Str(\ListNodus()\X), 4, " ")+","+RSet(Str(\ListNodus()\Y), 4, " ")+ ") = #Direction_Verti", #DebugLevel_Dupont_Create
            Else
               \pListNodus = AddElement(\ListNodus())     ;添加一个[节点]
               \ListNodus()\X         = X                 ;采用[源引脚]的X坐标
               \ListNodus()\Y         = \TargetPos\Y      ;采用光标处的Y坐标
               \ListNodus()\Direction = #Direction_Horiz  ;定义[节点]方向
               \TargetPos\X           = X                 ;刷新[目标节点]的Y坐标  
               \TargetPos\Y           = Y                 ;刷新[目标节点]的Y坐标  
               \CurrDirection = #Direction_Horiz
               Debug "[Dupont_Create]⊥B New ("+RSet(Str(\ListNodus()\X), 4, " ")+","+RSet(Str(\ListNodus()\Y), 4, " ")+ ") = #Direction_Horiz", #DebugLevel_Dupont_Create
            EndIf 
 
            
         Case #Direction_Down, #Direction_Up, #Direction_Verti
            If \TargetPos\X <> X : \CurrDirection = #Direction_Horiz : EndIf ;切换至水平方向
            If \pListNodus = #Null
               \pListNodus = AddElement(\ListNodus())     ;添加一个[节点]
               \ListNodus()\X         = \TargetPos\X      ;采用[源引脚]的X坐标
               \ListNodus()\Y         = Y                 ;采用光标处的Y坐标
               \ListNodus()\Direction = #Direction_Verti  ;定义[节点]方向
               \TargetPos\Y           = Y                 ;刷新[目标节点]的Y坐标  
               Debug "[Dupont_Create]↑↓ New ("+RSet(Str(\ListNodus()\X), 4, " ")+","+RSet(Str(\ListNodus()\Y), 4, " ")+ ") = #Direction_Verti", #DebugLevel_Dupont_Create
               If \pListNodus\X <> X Or \pListNodus\Y <> Y    ;相当于绘制一个L型的连线
                  \pListNodus = AddElement(\ListNodus())      ;添加一个[节点]      
                  \ListNodus()\X         = X                 ;采用光标处的X坐标
                  \ListNodus()\Y         = Y                 ;采用光标处的Y坐标
                  \ListNodus()\Direction = #Direction_Horiz  ;定义[节点]方向 
                  Debug "[Dupont_Create]↑↓ Add ("+RSet(Str(\ListNodus()\X), 4, " ")+","+RSet(Str(\ListNodus()\Y), 4, " ")+ ") = #Direction_Horiz", #DebugLevel_Dupont_Create
               EndIf 
               If \pTargetPin
                  \TargetPos\X           = X                 ;刷新[目标节点]的Y坐标  
               EndIf 
            Else
               \pListNodus\Y         = Y                 ;修正原来的节点
               \TargetPos\X          = X                 ;刷新[目标节点]的X坐标
               \TargetPos\Y          = Y                 ;刷新[目标节点]的Y坐标
               Debug "[Dupont_Create]↑↓ Mod ("+RSet(Str(\ListNodus()\X), 4, " ")+","+RSet(Str(\ListNodus()\Y), 4, " ")+ ") = #Direction_Horiz", #DebugLevel_Dupont_Create
               If \CurrDirection = #Direction_Horiz         ;如果连线发生拐弯
                  \pListNodus = AddElement(\ListNodus())      ;添加一个[节点]      
                  \ListNodus()\X         = X                 ;采用光标处的X坐标
                  \ListNodus()\Y         = Y                 ;采用光标处的Y坐标
                  \ListNodus()\Direction = #Direction_Horiz  ;定义[节点]方向 
                  Debug "[Dupont_Create]↑↓ Add ("+RSet(Str(\ListNodus()\X), 4, " ")+","+RSet(Str(\ListNodus()\Y), 4, " ")+ ") = #Direction_Horiz", #DebugLevel_Dupont_Create
               EndIf 
            EndIf 
            
         Case #Direction_Left, #Direction_Right, #Direction_Horiz
            If \TargetPos\Y <> Y : \CurrDirection = #Direction_Verti : EndIf ;切换至垂直方向
            If \pListNodus = #Null
               \pListNodus = AddElement(\ListNodus())      ;添加一个[节点]
               \ListNodus()\X         = X                 ;采用光标处的X坐标
               \ListNodus()\Y         = \TargetPos\Y      ;采用[源引脚]的Y坐标
               \ListNodus()\Direction = #Direction_Horiz  ;定义[节点]方向
               \TargetPos\Y           = Y                 ;刷新[目标节点]的Y坐标 
               Debug "[Dupont_Create]←→ New ("+RSet(Str(\ListNodus()\X), 4, " ")+","+RSet(Str(\ListNodus()\Y), 4, " ")+ ") = #Direction_Horiz", #DebugLevel_Dupont_Create
               If \pListNodus\X <> X Or \pListNodus\Y <> Y   ;相当于绘制一个L型的连线
                  \pListNodus = AddElement(\ListNodus())      ;添加一个[节点]      
                  \ListNodus()\X         = X                 ;采用光标处的X坐标
                  \ListNodus()\Y         = Y                 ;采用光标处的Y坐标
                  \ListNodus()\Direction = #Direction_Verti  ;定义[节点]方向 
                  Debug "[Dupont_Create]←→ Add ("+RSet(Str(\ListNodus()\X), 4, " ")+","+RSet(Str(\ListNodus()\Y), 4, " ")+ ") = #Direction_Verti", #DebugLevel_Dupont_Create
               EndIf 
               If \pTargetPin
                  \TargetPos\X           = X                 ;刷新[目标节点]的Y坐标  
               EndIf 
            Else 
               \pListNodus\X            = X                 ;修正原来的节点
               \TargetPos\X             = X                 ;刷新[目标节点]的X坐标
               \TargetPos\Y             = Y                 ;刷新[目标节点]的Y坐标
               Debug "[Dupont_Create]←→ Mod ("+RSet(Str(\ListNodus()\X), 4, " ")+","+RSet(Str(\ListNodus()\Y), 4, " ")+ ") = #Direction_Verti" , #DebugLevel_Dupont_Create              
               If \CurrDirection = #Direction_Verti         ;如果连线发生拐弯
                  \pListNodus = AddElement(\ListNodus())      ;添加一个[节点]      
                  \ListNodus()\X         = X                 ;采用光标处的X坐标
                  \ListNodus()\Y         = Y                 ;采用光标处的Y坐标
                  \ListNodus()\Direction = #Direction_Verti  ;定义[节点]方向 
                  Debug "[Dupont_Create]←→ Add ("+RSet(Str(\ListNodus()\X), 4, " ")+","+RSet(Str(\ListNodus()\Y), 4, " ")+ ") = #Direction_Verti", #DebugLevel_Dupont_Create
               EndIf 
            EndIf 
      EndSelect
      ;新建一个完成的[杜邦线]对象
      If \pTargetPin
         *pListDupont.__Dupont_BaseInfo = AddElement(*pMainDesign\ListDupont())
         *pListDupont\ObjectType   = #Object_Dupont|#Object_Event_Create
         *pListDupont\pOriginPin   = \pOriginPin
         *pListDupont\pTargetPin   = \pTargetPin

         *pListDupont\OriginPos\X  = \OriginPos\X
         *pListDupont\OriginPos\Y  = \OriginPos\Y

         *pListDupont\TargetPos\Direction = \OriginPos\Direction
         *pListDupont\TargetPos\X  = \TargetPos\X
         *pListDupont\TargetPos\Y  = \TargetPos\Y
         *pListDupont\TargetPos\Direction = \pTargetPin\PinDirection
         *pListDupont\DupontColor  = \DupontColor
         \pOriginPin\pOriginDupont = *pListDupont
         \pTargetPin\pTargetDupont = *pListDupont
      
         LastElement(\ListNodus())
         DeleteElement(\ListNodus())
         ForEach \ListNodus()
            AddElement(*pListDupont\ListNodus())
            *pListDupont\ListNodus()\X         = \ListNodus()\X
            *pListDupont\ListNodus()\Y         = \ListNodus()\Y
            *pListDupont\ListNodus()\Direction = \ListNodus()\Direction
         Next 
         
         ;获取[杜邦线]的空间尺寸
         Dupont_DuNode_Search(*pListDupont) 
         ;清空 *pMainDesign\ActiveDupont 和 *pMainDesign\pActiveDupont
         \pOriginPin  = #Null
         \pListNodus  = #Null
         If \pTargetPin : \pTargetPin = #Null : EndIf 
         ClearList(\ListNodus())
         *pMainDesign\pCurrDupont = *pListDupont   ;防止自动完成新建[杜邦线]后出现[对象]移动的现象
         Debug "[Dupont_Create] ==> 由[目标引脚]结束新建[杜邦线] <============== ", #DebugLevel_Dupont_Create
      EndIf 

   EndWith
   ProcedureReturn #True
EndProcedure


;向[杜邦线]插入[节点]
Procedure Dupont_Nodus_Insert(*pMainDesign.__Design_MainInfo, X.f, Y.f)
   With *pMainDesign\pCurrDupont
      PosX.f = \OriginPos\X
      PosY.f = \OriginPos\Y
      *pNodus.__DuNode_BaseInfo = FirstElement(\ListNodus())
      ForEach \ListNodus()
         ;三点共线
         If IsCollinear = #False
            Collinear.f = Abs((\ListNodus()\Y - Y)*(PosX - X)-(\ListNodus()\X - X)*(PosY - Y))
            Distance0.f = (PosX-\ListNodus()\X)*(PosX-\ListNodus()\X)+(PosY-\ListNodus()\Y)*(PosY-\ListNodus()\Y)
            If Collinear < #Canvas_ErrorValue * Distance0
               ;判断是否在两个端点之间
               Distance1.f = (PosX-X)*(PosX-X)+(PosY-Y)*(PosY-Y) 
               Distance2.f = (\ListNodus()\X-X)*(\ListNodus()\X-X)+(\ListNodus()\Y-Y)*(\ListNodus()\Y-Y) 
               If Distance0 >= Distance1 And Distance0 >= Distance2
                  If *pNodus = \ListNodus()
                     If *pNodus\Direction = #Direction_Verti 
                        InsertElement(\ListNodus())
                        *pNodus\X + #Module_DupontPitch
                        \ListNodus()\X = *pNodus\X
                        \ListNodus()\Y = \OriginPos\Y
                        \ListNodus()\Direction = #Direction_Horiz
                     Else 
                        InsertElement(\ListNodus())
                        *pNodus\Y + #Module_DupontPitch
                        \ListNodus()\X = \OriginPos\X
                        \ListNodus()\Y = *pNodus\Y
                        \ListNodus()\Direction = #Direction_Verti
                     EndIf 
                     Debug "[Dupont_DuNode] 在起点处添加单个[节点] ************ ", #DebugLevel_Dupont_DuNode 
                  Else    
                     *pNodus.__DuNode_BaseInfo = \ListNodus()
                     If *pNodus\Direction = #Direction_Verti 
                        InsertElement(\ListNodus())
                        \ListNodus()\X = *pNodus\X + #Module_DupontPitch
                        \ListNodus()\Y = Y
                        \ListNodus()\Direction = #Direction_Horiz
                        InsertElement(\ListNodus())
                        \ListNodus()\X = *pNodus\X
                        \ListNodus()\Y = Y
                        \ListNodus()\Direction = #Direction_Verti
                        *pNodus\X + #Module_DupontPitch
                     Else 
                        InsertElement(\ListNodus())
                        \ListNodus()\X = X
                        \ListNodus()\Y = *pNodus\Y + #Module_DupontPitch
                        \ListNodus()\Direction = #Direction_Verti
                        InsertElement(\ListNodus())
                        \ListNodus()\X = X
                        \ListNodus()\Y = *pNodus\Y
                        \ListNodus()\Direction = #Direction_Horiz
                        *pNodus\Y + #Module_DupontPitch
                     EndIf 
                     Debug "[Dupont_DuNode] 在中间添加一对[节点] ************ ", #DebugLevel_Dupont_DuNode 
                  EndIf 
                  IsCollinear = #True
                  Break 
               EndIf 
            EndIf  
            PosX = \ListNodus()\X
            PosY = \ListNodus()\Y
         EndIf 
      Next 
      
      If IsCollinear = #False
         Collinear.f = Abs((\TargetPos\Y - Y)*(PosX - X)-(\TargetPos\X - X)*(PosY - Y))
         Distance0.f = (PosX-\TargetPos\X)*(PosX-\TargetPos\X)+(PosY-\TargetPos\Y)*(PosY-\TargetPos\Y)
         If Collinear < #Canvas_ErrorValue * Distance0
            ;判断是否在两个端点之间
            Distance1.f = (PosX-X)*(PosX-X)+(PosY-Y)*(PosY-Y) 
            Distance2.f = (\TargetPos\X-X)*(\TargetPos\X-X)+(\TargetPos\Y-Y)*(\TargetPos\Y-Y) 
            If Distance0 >= Distance1 And Distance0 >= Distance2
               *pNodus.__DuNode_BaseInfo = LastElement(\ListNodus())
               If *pNodus\Direction = #Direction_Horiz 
                  AddElement(\ListNodus())
                  *pNodus\X + #Module_DupontPitch
                  \ListNodus()\X = *pNodus\X
                  \ListNodus()\Y = \TargetPos\Y
                  \ListNodus()\Direction = #Direction_Verti
               Else 
                  AddElement(\ListNodus())
                  *pNodus\Y + #Module_DupontPitch
                  \ListNodus()\X = \TargetPos\X
                  \ListNodus()\Y = *pNodus\Y
                  \ListNodus()\Direction = #Direction_Horiz
               EndIf 
               IsCollinear = #True
               Debug "[Dupont_DuNode] 在终点处添加单个[节点] ************ ", #DebugLevel_Dupont_DuNode 
            EndIf 
         EndIf   
      EndIf  
   EndWith
;    *pMainDesign\pCurrDupont = #Null
   ProcedureReturn IsCollinear
EndProcedure

;在[杜邦线]删除[节点]
Procedure Dupont_Nodus_Delete(*pMainDesign.__Design_MainInfo, X.f, Y.f)
   With *pMainDesign\pCurrDupont
      If ListSize(\ListNodus()) <= 1 : ProcedureReturn : EndIf 
      *pFirstNodus.__DuNode_BaseInfo = FirstElement(\ListNodus())    ;起点
      *pFinalNodus.__DuNode_BaseInfo = LastElement(\ListNodus())     ;终点
      ForEach \ListNodus()
         If Abs(\ListNodus()\X-X) <= 30 And Abs(\ListNodus()\Y-Y) <= 30
            If *pFirstNodus = \ListNodus()
               If *pFirstNodus\Direction = #Direction_Horiz 
                  DeleteElement(\ListNodus())
                  *pCurrNodus.__DuNode_BaseInfo = NextElement(\ListNodus())
                  If *pCurrNodus : *pCurrNodus\X = \OriginPos\X : EndIf 
               Else 
                  DeleteElement(\ListNodus()) 
                  *pCurrNodus.__DuNode_BaseInfo = NextElement(\ListNodus())
                  If *pCurrNodus : *pCurrNodus\Y = \OriginPos\Y : EndIf 
               EndIf 
               Debug "[Dupont_DuNode] 在起点处删除单个[节点] ************ ", #DebugLevel_Dupont_DuNode 
               ProcedureReturn #True
            ElseIf *pFinalNodus = \ListNodus()
               If *pFinalNodus\Direction = #Direction_Horiz 
                  *pCurrNodus.__DuNode_BaseInfo = DeleteElement(\ListNodus())
                  If *pCurrNodus : *pCurrNodus\Y = \TargetPos\Y : EndIf 
               Else 
                  Y = *pFinalNodus\Y
                  *pCurrNodus.__DuNode_BaseInfo = DeleteElement(\ListNodus()) 
                  If *pCurrNodus : *pCurrNodus\X = \TargetPos\X : EndIf 
               EndIf 
               Debug "[Dupont_DuNode] 在终点处删除单个[节点] ************ ", #DebugLevel_Dupont_DuNode 
               ProcedureReturn #True
            Else 
               *pNodus.__DuNode_BaseInfo = DeleteElement(\ListNodus())
               If *pNodus\Direction = #Direction_Horiz 
                  *pCurrNodus.__DuNode_BaseInfo = NextElement(\ListNodus())
                  If *pCurrNodus
                     DeleteElement(\ListNodus())
                     *pCurrNodus.__DuNode_BaseInfo = NextElement(\ListNodus())
                     If *pCurrNodus 
                        *pNodus\X = *pCurrNodus\X 
                     Else 
                        *pNodus\X = \TargetPos\X
                     EndIf 
                  EndIf
               Else 
                  *pCurrNodus.__DuNode_BaseInfo = NextElement(\ListNodus())
                  If *pCurrNodus
                     DeleteElement(\ListNodus())
                     *pCurrNodus.__DuNode_BaseInfo = NextElement(\ListNodus())
                     If *pCurrNodus 
                        *pNodus\Y = *pCurrNodus\Y 
                     Else 
                        *pNodus\Y = \TargetPos\Y 
                     EndIf 
                  EndIf 
               EndIf 
               Debug "[Dupont_DuNode] 在中间删除一对[节点] ************ ", #DebugLevel_Dupont_DuNode 
               ProcedureReturn #True
            EndIf 
            ProcedureReturn 
         EndIf 
      Next 
   EndWith
EndProcedure


;-
;- ******** [Selection] ********
;激活[杜邦线]选区
Procedure Dupont_Selection_Active(*pMainDesign.__Design_MainInfo, X.f, Y.f)
   If MapSize(*pMainDesign\pMapDupont()) = #Null : ProcedureReturn : EndIf 
   ForEach *pMainDesign\pMapDupont()
      With *pMainDesign\pMapDupont()
         If \IsGroupOrigin = #True And \IsGroupTarget = #True 
            \OriginPos\OffsetX = X - \OriginPos\X
            \OriginPos\OffsetY = Y - \OriginPos\Y
            \TargetPos\OffsetX = X - \TargetPos\X
            \TargetPos\OffsetY = Y - \TargetPos\Y
            ForEach \ListNodus()
               \ListNodus()\OffsetX = X - \ListNodus()\X
               \ListNodus()\OffsetY = Y - \ListNodus()\Y
            Next 
         Else 
            \IsGroupOrigin = #False
            \IsGroupTarget = #False
            DeleteMapElement(*pMainDesign\pMapDupont())
         EndIf 
      EndWith
   Next 
   Debug "[Object_Select] 激活[杜邦线]", #DebugLevel_Object_Select
EndProcedure

;移动[杜邦线]单个引脚
Procedure Dupont_Selection_Single(*pListMatter.__Matter_BaseInfo)
   If *pListMatter = #Null : ProcedureReturn : EndIf 
   With *pListMatter
      ForEach \ListPinPrefer()
         *pMatterPins.__Matter_PinPrefer  = \ListPinPrefer()
         *pPinParam.__Module_PinParam     = \ListPinPrefer()\pListPinParam
         *pOriginDupont.__Dupont_BaseInfo = *pMatterPins\pOriginDupont
         *pTargetDupont.__Dupont_BaseInfo = *pMatterPins\pTargetDupont 
         If *pMatterPins\pOriginDupont
            If *pOriginDupont\IsGroupOrigin = #True : Continue : EndIf 
            OriginPosX.f = \X+*pPinParam\OffsetX + *pPinParam\OffsetW
            OriginPosY.f = \Y+*pPinParam\OffsetY + *pPinParam\OffsetH
            *pDuNode.__DuNode_BaseInfo = FirstElement(*pOriginDupont\ListNodus())
            Select *pDuNode\Direction 
               Case #Direction_Verti : If *pDuNode\X = *pOriginDupont\OriginPos\X : *pDuNode\X = OriginPosX : EndIf   
               Case #Direction_Horiz : If *pDuNode\Y = *pOriginDupont\OriginPos\Y : *pDuNode\Y = OriginPosY : EndIf 
            EndSelect               
            *pOriginDupont\OriginPos\X = OriginPosX
            *pOriginDupont\OriginPos\Y = OriginPosY
            Debug "[Object_Moving] 移动[杜邦线] ==> OriginPin ", #DebugLevel_Object_Moving  
            
         ElseIf *pMatterPins\pTargetDupont
            If *pTargetDupont\IsGroupTarget = #True : Continue : EndIf 
            TargetPosX.f = \X+*pPinParam\OffsetX + *pPinParam\OffsetW
            TargetPosY.f = \Y+*pPinParam\OffsetY + *pPinParam\OffsetH
            *pDuNode.__DuNode_BaseInfo = LastElement(*pTargetDupont\ListNodus())
            Select *pDuNode\Direction 
               Case #Direction_Horiz : If *pDuNode\X = *pTargetDupont\TargetPos\X : *pDuNode\X = TargetPosX : EndIf   
               Case #Direction_Verti : If *pDuNode\Y = *pTargetDupont\TargetPos\Y : *pDuNode\Y = TargetPosY : EndIf 
            EndSelect          
            *pTargetDupont\TargetPos\X = TargetPosX
            *pTargetDupont\TargetPos\Y = TargetPosY  
            Debug "[Object_Moving] 移动[杜邦线] ==> TargetPin ", #DebugLevel_Object_Moving  
         EndIf 
      Next 
      
   EndWith 
EndProcedure

;整体[杜邦线]移动
Procedure Dupont_Selection_Moving(*pMainDesign.__Design_MainInfo, X.f, Y.f)
   If MapSize(*pMainDesign\pMapDupont()) = #Null : ProcedureReturn : EndIf 
   ForEach *pMainDesign\pMapDupont()
      With *pMainDesign\pMapDupont()
         \OriginPos\X = X - \OriginPos\OffsetX
         \OriginPos\Y = Y - \OriginPos\OffsetY
         \TargetPos\X = X - \TargetPos\OffsetX
         \TargetPos\Y = Y - \TargetPos\OffsetY
         ForEach \ListNodus()
            \ListNodus()\X = X - \ListNodus()\OffsetX
            \ListNodus()\Y = Y - \ListNodus()\OffsetY
         Next 
         Dupont_DuNode_Search(*pMainDesign\pMapDupont())  
      EndWith
   Next  
   Debug "[Object_Moving] 移动[杜邦线]", #DebugLevel_Object_Moving
EndProcedure





















; IDE Options = PureBasic 5.62 (Windows - x86)
; CursorPosition = 18
; Folding = -YRw
; EnableXP