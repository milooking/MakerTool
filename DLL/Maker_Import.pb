

#Object_Rotate_000 = 0
#Object_Rotate_090 = 1
#Object_Rotate_180 = 2
#Object_Rotate_270 = 3

#Object_Layer_Top     = 1
#Object_Layer_Bottom  = 2
#Object_Layer_Prev    = 3
#Object_Layer_Next    = 4

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

#Object_Selected = 0

#ObjectType_Canvas = 1  ;CanvasID: [画布]
#ObjectType_Active = 2  ;ActiveID: [临时组]
#ObjectType_Matter = 3  ;MatterID: [电子元件]
#ObjectType_String = 4  ;StringID: [字符串]
#ObjectType_Groups = 5  ;GroupsID: [对象组]
#ObjectType_Dupont = 6  ;DupontID: [杜邦线]


;属性值 
Enumeration
   #Attribute_None
   #Attribute_CanvasZoom         ;获取[画布]的比例值,   返回值: 25,50,75,100 
   #Attribute_CanvasInfo         ;获取[画布]的四围信息, 返回值: *pCanvasInfo__MCT_CanvasInfo  
   #Attribute_CanvasScrollX      ;获取[画布]的ScrollX,  返回值: ScrollX
   #Attribute_CanvasScrollY      ;获取[画布]的ScrollY,  返回值: ScrollY 
   #Attribute_CanvasWidth        ;获取[画布]的CanvasW,  返回值: CanvasW
   #Attribute_CanvasHeight       ;获取[画布]的CanvasH,  返回值: CanvasH
   #Attribute_MatterRotate       ;获取[元件]的旋转角度, 返回值: RotateIndex, ObjectID=#Null时,为当前选中状态下的[元件]
   #Attribute_ActiveObject       ;获取[对象]的ID,        返回值: ObjectID,  ObjectID为*pObjectID.long,则*pObjectID\l返回ObjectType                                        
   #Attribute_ActiveModule       ;获取[模块类型]的ID     返回值: ModuleID,  ObjectID=#Null时,为当前选中状态下的[对象]
   #Attribute_StringText         ;获取[文本标签]的Text,  返回值: @Text$  ,  ObjectID=#Null时,为当前选中状态下的[对象]   
   #Attribute_StringFontSize     ;获取[文本标签]的hFont, 返回值: FontSize,  ObjectID=#Null时,为当前选中状态下的[对象]  
   #Attribute_StringFontColor    ;获取[文本标签]的hFont, 返回值: FontColor, ObjectID=#Null时,为当前选中状态下的[对象]
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
   
   
EndEnumeration


Structure __Maker_ModuleType
   *pModuleGroup      ;模块编组
   *pModuleTypes      ;模块类型
   *pModuleModel      ;模块型号
   *pModuleName       ;模块名称
   *pModuleNote       ;模块说明
   hModuleIcon.l      ;模块图标ID
   ModuleID.l
EndStructure


;- 
;- ******** [Import] ******** 
Import "Engine.lib"
;- ****** [Engine] ******
Engine_Initial(*pRegister.long) 
;{
; 【说  明】: 初始化引擎, 同一个引擎,可以支持多个[设计文档]
; 【参  数】: @Register.long, 此参数为指针参数,用于回传引擎是否已经注册,类型为Long
; 【返回值】: EngineID, 为0，则初始化失败, 非零表示初始化成功
;     Register\l = 0 : 未注册
;     Register\l = 1 : 已注册
;}

Engine_Release(EngineID)
;{
; 【说  明】: 注销引擎
; 【参  数】: EngineID, 由Engine_Initial()获得
; 【返回值】: Result, 为0，注销引擎失败; 为1, 注销引擎成功
;}

Engine_SetCallBack(EngineID, CallBackType, *pCallFunction)
;{
; 【说  明】: 注册引擎,因为注册引擎时,需要解压[Module.bin],过程需要一定时间,所以这里有回调函数来获取解决进度.
; 【参  数】: EngineID, 由Engine_Initial()获得
; 【返回值】: Result
;     Result=00，注册引擎失败
;     Result=01, 注册引擎成功
;     Result=-1, 引擎已经注册过,无须再注册
; 【实  例】
;    Procedure Maker_CallBack_Register(Index, Count, Note$)
;       Debug Str(Index)+"/"+Str(Count) + ":" + Note$
;    EndProcedure
; 
;    EngineID = Engine_Initial(@Register.long)
;    If Register\l = #Null
;       Engine_Register(EngineID, @Maker_CallBack_Register())
;    EndIf 
;    Engine_Release(EngineID)
;}


Engine_ErrorCode() 
;{
; 【说  明】: 获取出错信息
; 【参  数】: 无
; 【返回值】: ErrorCode

;}

Engine_ErrorMessage(ErrorCode=#PB_Ignore) 
;{
; 【说  明】: 获取出错信息
; 【参  数】: ErrorCode, 由Engine_ErrorCode()获取, ErrorCode=-65535时,函数内部自动获取ErrorCode
; 【返回值】: ErrorMessage$, 文本类型,
; 【实  例】
;    Procedure Maker_CallBack_Register(Index, Count, Note$)
;       Debug Str(Index)+"/"+Str(Count) + ":" + Note$
;    EndProcedure
; 
;    EngineID = Engine_Initial(@Register.long)
;    If EngineID = #Null
;       Debug Engine_ErrorMessage() 
;       End
;    ElseIf Register\l = #Null
;       Engine_Register(EngineID, @Maker_CallBack_Register())
;    EndIf 
;    Engine_Release(EngineID)
;}

;- ****** [Module] ******
Engine_CountModule(EngineID) 
;{
; 【说  明】: 获取[模块类型]数量, 一个引擎只有个一个ListModule()
; 【参  数】: EngineID
; 【返回值】: Count
;}

Engine_GetModule(EngineID, Index, *pModule.__Maker_ModuleType)   
;{
; 【说  明】: 获取[模块类型]数量
; 【参  数】: Index:索引号,以下标0开始,以Count-1结束, 
;             *pModule.__Maker_ModuleType,用于回传[模块类型]的相关信息
; 【返回值】: 无
; 【注  意】: 在Engine_Register()之前,可以使用该函数,目标是可以让Engine_Register()在窗体建立后再进行弹窗显示进度
; 【实  例】
;    EngineID = Engine_Initial(@Register.long)
;    If EngineID
;       Count = Engine_CountModule(EngineID)
;       For Index = 0 To Count-1
;          Engine_GetModule(EngineID, Index, @ListModule.__Maker_ModuleType)
;          Debug "ModuleGroup$ = " + ListModule\ModuleGroup$  ;模块编组
;          Debug "ModuleTypes$ = " + ListModule\ModuleTypes$  ;模块类型
;          Debug "ModuleModel$ = " + ListModule\ModuleModel$  ;模块型号
;          Debug "ModuleName$  = " + ListModule\ModuleName$   ;模块名称
;          Debug "ModuleNote$  = " + ListModule\ModuleNote$   ;模块说明
;          Debug "hModuleIcon  = " + ListModule\hModuleIcon   ;模块图标ID
;          Debug "ModuleID     = " + ListModule\ModuleID      ;模块ID
;       Next 
;    EndIf 
;    Engine_Release(EngineID)
;}

;- 
;【注  意】: 以下函数,必须在Engine_Register()注册过后,才可以调用
;- ****** [Design] ******
Engine_CreateDesign(EngineID, CanvasW=1280, CanvasH=720)
;{
; 【说  明】: 创建[设计文档],[设计文档]是[画布],[电子元件],[杜邦线],[文本标签],[对象组]等等的容器
; 【参  数】: EngineID, CanvasW,CanvasH:窗体界面当屏显示区的大小,用于加速Engine_RedrawCanvas()
; 【返回值】: DesignID, 非零表示成功, 同一个引擎,可以支持多个DesignID
;}

Engine_FreeDesign(DesignID)
;{
; 【说  明】: 注销[设计文档],[设计文档]包括的[画布],[电子元件],[杜邦线],[文本标签],[对象组]等等一并被注销掉
; 【参  数】: DesignID
; 【返回值】: Result, 为0，注销引擎失败; 为1, 注销引擎成功
; 【实  例】
;    EngineID = Engine_Initial(@Register.long)
;    If EngineID
;       DesignID = Engine_CreateDesign(EngineID)
;       Engine_FreeDesign(DesignID)
;    EndIf 
;    Engine_Release(EngineID)
;}

Engine_LoadDesign(EngineID, FileName$)
;{
; 【说  明】: 加载[设计文档]
; 【参  数】: EngineID 注意不是DesignID; FileName$为[设计文档]的文件件,加载后,自动创建一个[设计文档],即Engine_CreateDesign()
; 【返回值】: DesignID, 注销要用Engine_FreeDesign()
;}

Engine_SaveDesign(DesignID, SaveName$)
;{
; 【说  明】: 保存[设计文档]
; 【参  数】: DesignID, 要保存的[设计文档]的名称
; 【返回值】: Result, 小于等于0，保存失败; 大于0, 保存成功
; 【实  例】
;    EngineID = Engine_Initial(@Register.long)
;    If EngineID
;       DesignID = Engine_LoadDesign(EngineID, "设计文档1.mct")
;       Engine_SaveDesign(DesignID, "设计文档2.mct")
;    EndIf 
;    Engine_Release(EngineID)
;}

;- ****** [Object] ******
Engine_NewMatter(DesignID, ModuleID, X.f, Y.f, RotateIdx=#Object_Rotate_000)
;{
; 【说  明】: 新建一个[电子元件]
; 【参  数】: DesignID, 坐标: X.f, Y.f, 方向: RotateIdx
; 【返回值】: MatterID, 为0表示失败
;}

Engine_FreeMatter(DesignID, MatterID)
;{
; 【说  明】: 删除一个[电子元件]
; 【参  数】: DesignID, MatterID:由Engine_NewMatter()产生
; 【返回值】: Result, 为0表示失败
;}

Engine_NewString(DesignID, X.f, Y.f, Text$)
;{
; 【说  明】: 新建一个[文本标签]
; 【参  数】: DesignID, 坐标: X.f, Y.f, Text$: 文本内容
; 【返回值】: StringID, 为0表示失败
;}

Engine_FreeString(DesignID, StringID)
;{
; 【说  明】: 删除一个[文本标签]
; 【参  数】: DesignID, StringID:由Engine_NewString()产生
; 【返回值】: Result, 为0表示失败
;}

;- ****** [Canvas] ******
Engine_RedrawCanvas(DesignID, ScrollX, ScrollY)
;{
; 【说  明】: 重绘[画布]
; 【参  数】: DesignID; ScrollX, ScrollY[画布]的滚动坐标
; 【返回值】: hImage,返回图像句柄, 为0表示失败; Engine_FreeDesign()时自动注销掉hImage
;}

Engine_Screenshot(DesignID, FileName$)
;{
; 【说  明】: 保存[画布]为图像
; 【参  数】: DesignID, FileName$要保存的图像名
; 【返回值】: Result, 为0表示失败
;}

Engine_EventCanvas(DesignID, X, Y, EventType, Button=#Null)
;{
; 【说  明】: [画布]响应事件
; 【参  数】: DesignID; X, Y为鼠标坐标; EventType为影响事件, Button为按键状态
; 【返回值】: Result, 为0表示失败

; 【EventType】
;    #PB_EventType_LeftButtonDown  ;左键按下事件
;    #PB_EventType_LeftButtonUp    ;左键释放事件
;    #PB_EventType_LeftDoubleClick ;左键双击事件
;    #PB_EventType_RightButtonDown ;右键按下事件
;    #PB_EventType_RightButtonUp   ;右键释放事件
;    #PB_EventType_RightDoubleClick;右键双击事件
;    #PB_EventType_MouseMove       ;光标移动事件

; 【Button】
;    当 EventType = #PB_EventType_MouseMove时
;    #PB_Canvas_LeftButton   ;按住鼠标左键
;    #PB_Canvas_RightButton  ;按住鼠标右键

;    其它情况为
;    #PB_Canvas_Alt      ;按住ALT键
;    #PB_Canvas_Control  ;按住CTRL键
;}


;- ****** [Attribute] ******
Engine_GetAttribute(DesignID, Attribute, ObjectID=#Null)
;{
; 【说  明】: 设置[属性]
; 【参  数】: DesignID, Attribute为属性类型, ObjectID为对象ID,可选ObjectID包括[MatterID,StringID,GroupID]
; 【返回值】: Value 返回属性值

; 【Attribute】
;    #Attribute_CanvasZoom         ;获取[画布]的比例值,   返回值: 25,50,75,100 
;    #Attribute_CanvasInfo         ;获取[画布]的四围信息, 返回值: *pCanvasInfo__MCT_CanvasInfo  
;    #Attribute_CanvasScrollX      ;获取[画布]的ScrollX,  返回值: ScrollX
;    #Attribute_CanvasScrollY      ;获取[画布]的ScrollY,  返回值: ScrollY 
;    #Attribute_CanvasWidth        ;获取[画布]的CanvasW,  返回值: CanvasW
;    #Attribute_CanvasHeight       ;获取[画布]的CanvasH,  返回值: CanvasH

;    #Attribute_MatterRotate       ;获取[元件]的旋转角度, 返回值: RotateIndex, ObjectID=#Null时,为当前选中状态下的[元件]
;                                  #Object_Rotate_000 = 0
;                                  #Object_Rotate_090 = 1
;                                  #Object_Rotate_180 = 2
;                                  #Object_Rotate_270 = 3
;    #Attribute_ActiveObject       ;获取[对象]的ID,        返回值: ObjectID,  ObjectID为*pObjectID.long,则*pObjectID\l返回ObjectType                                        
;    #Attribute_ActiveModule       ;获取[模块类型]的ID     返回值: ModuleID,  ObjectID=#Null时,为当前选中状态下的[对象]
;    #Attribute_StringText         ;获取[文本标签]的Text,  返回值: @Text$  ,  ObjectID=#Null时,为当前选中状态下的[对象]  
;    #Attribute_StringFontSize     ;获取[文本标签]的hFont, 返回值: FontSize,  ObjectID=#Null时,为当前选中状态下的[对象]  
;    #Attribute_StringFontColor    ;获取[文本标签]的hFont, 返回值: FontColor, ObjectID=#Null时,为当前选中状态下的[对象]  

;    #Attribute_ObjectLayer        ;获取[对象]的层级,     返回值: LayerIndex,  ObjectID=#Null时,为当前选中状态下的[对象]
;    #Attribute_ObjectName         ;设置[对象]名称        返回值: *pMemName,   ObjectID=#Null时,为当前选中状态下的[对象]  
;    #Attribute_ObjectType         ;获取[对象]的类型,     返回值: ObjectType,  ObjectID=#Null时,为当前选中状态下的[对象]
;                                  #ObjectType_Canvas = 1  ;CanvasID: [画布]
;                                  #ObjectType_Active = 2  ;ActiveID: 临时[对象组]
;                                  #ObjectType_Matter = 3  ;MatterID: [电子元件]
;                                  #ObjectType_String = 4  ;StringID: [字符串]
;                                  #ObjectType_Groups = 5  ;GroupsID: [对象组]
;                                  #ObjectType_Dupont = 6  ;DupontID: [杜邦线]
;    #Attribute_ObjectX           ;获置[对象]X坐标     返回值: ObjectX,  ObjectID=#Null时,为当前选中状态下的[对象]
;    #Attribute_ObjectY           ;获置[对象]Y坐标     返回值: ObjectY,  ObjectID=#Null时,为当前选中状态下的[对象]
;    #Attribute_ObjectModify      ;获取设计文件是否被修改过
;    #Attribute_ObjectDelete    [×]
;    #Attribute_ActiveGroups    [×]
;    #Attribute_Alignment       [×]
;    #Attribute_Distribute      [×]                              
;}


Engine_SetAttribute(DesignID, Attribute, Value, ObjectID=#Null)
;{
; 【说  明】: 获取[属性]
; 【参  数】: DesignID, Attribute为属性类型, Value为属性值, ObjectID为对象ID,可选
; 【返回值】: 无
; 【Attribute】
;    #Attribute_CanvasZoom         ;设置[画布]的比例值,   Value: 25,50,75,100 
;    #Attribute_CanvasInfo         ;设置[画布]的四围信息, Value: *pCanvasInfo__MCT_CanvasInfo  
;    #Attribute_CanvasScrollX      ;设置[画布]的ScrollX,  Value: ScrollX
;    #Attribute_CanvasScrollY      ;设置[画布]的ScrollY,  Value: ScrollY 
;    #Attribute_CanvasWidth        ;设置[画布]的CanvasW,  Value: CanvasW
;    #Attribute_CanvasHeight       ;设置[画布]的CanvasH,  Value: CanvasH
;    

; 
;    #Attribute_MatterRotate       ;设置[元件]的旋转角度, Value: RotateIndex, ObjectID=#Null时,为当前选中状态下的[元件]
;                                  #Object_Rotate_LTurn90 = -1   ;左转90
;                                  #Object_Rotate_RTurn90 = -2   ;右转90
;                                  #Object_Rotate_Flip180 = -3   ;翻转180
;    
;    #Attribute_ActiveObject       ;设置[对象]为当前选中状态,      Value=#Null,  ObjectID                                       
;    #Attribute_ActiveModule       ;设置[模块类型]为当前选中状态   Value=#Null,  ObjectID = ModuleID
;    #Attribute_StringText         ;设置[文本标签]的Text,  Value: @Text$  ,  ObjectID=#Null时,为当前选中状态下的[对象]  
;    #Attribute_StringFontSize     ;设置[文本标签]的hFont, Value: FontSize,  ObjectID=#Null时,为当前选中状态下的[对象]  
;    #Attribute_StringFontColor    ;设置[文本标签]的hFont, Value: FontColor, ObjectID=#Null时,为当前选中状态下的[对象]

;    #Attribute_ObjectLayer        ;设置[对象]的层级,     Value: LayerIndex,  ObjectID=#Null时,为当前选中状态下的[对象]
;                                  #Object_Layer_Bottom  = 00     ;到底层   
;                                  #Object_Layer_Top     = -1     ;到顶层
;                                  #Object_Layer_Next    = -2     ;上一层
;                                  #Object_Layer_Prev    = -3     ;下一层
;    #Attribute_ObjectName         ;设置[对象]名称      Value=*pMemName,  ObjectID=#Null时,为当前选中状态下的[对象]     
;    #Attribute_ObjectType      [×]
;    #Attribute_ObjectX         [×];获置[对象]X坐标
;    #Attribute_ObjectY         [×];获置[对象]Y坐标
;    #Attribute_ObjectModify    [×];获置[对象]Y坐标
;    #Attribute_ObjectDelete      ;删除[对象]           Value=#Null;  ObjectID=#Null时,为当前选中状态下的[对象]
;    #Attribute_ActiveGroups      ;设置当前选中的[对象组], Value:合并/解散   ObjectID=#null
;                                  #Object_Group_Divide = 0    ;解散指定的[对象组]
;                                  #Object_Group_Merger = 1    ;将[临时组]组合为[对象组]
;
;    #Attribute_Alignment          ;设置[活动对象]的对齐方式, Value:为对齐方式   ObjectID=#null
;                                  #Canvas_Align_Left   = $1
;                                  #Canvas_Align_Right  = $2
;                                  #Canvas_Align_Center = $4
;                                  
;                                  #Canvas_Align_Top    = $10
;                                  #Canvas_Align_Bottom = $20
;                                  #Canvas_Align_Middle = $40
;    
;    #Attribute_Distribute         ;设置[活动对象]的分布方式, Value:为分布方式   ObjectID=#null
;                                  #Canvas_Evenly_Right  = $2
;                                  #Canvas_Evenly_Center = $4
;                                  #Canvas_Evenly_Space  = $8
;                                  
;                                  #Canvas_Evenly_Top    = $10
;                                  #Canvas_Evenly_Bottom = $20
;                                  #Canvas_Evenly_Middle = $40
;                                  #Canvas_Evenly_Border = $80    

;}

EndImport


















; IDE Options = PureBasic 5.62 (Windows - x86)
; ExecutableFormat = Shared dll
; CursorPosition = 62
; FirstLine = 49
; Folding = BAA9
; EnableXP
; Executable = Engine.dll