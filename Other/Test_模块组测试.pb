

;    [MapModule]
; 　　　↓               [CanvasObject] ┐
; [ListMatter()] ┐                     │
; 　　　↓　　　　├→ [*pListpObject()] ├→ [*pCurrObject]
;  [MapGroups()] ┘                     │
;                        [ActiveObject] ┘

; Object[对象],Canvas[画布],Matter[单元],Groups[单元组],Module[模块]
; *pListpObject(): [模块对象指针], 具有层级关系, 关系画布上的[实体对象]上下层关系
; CanvasObject: [画布对象],关系到鼠标选择的选框事件
; ActiveObject: [活动对象],当前鼠标选中的多个*pListpObject()
; MapGroups() : [模块单元组],由多个ListMatter()组成
; ListMatter(): [模块单元],由Module决定其属性
; MapModule() : [模块单元],通过加载[Module.bin]获取属性

;选框重绘事件, 多选选框及移动事件
;测试任务:
;1.[选择单一实物单元]和[选择多个实物单元]的功能
;2.[对齐多个实物单元]和[多个实物单元间距分布]的功能
;3.[实物单元]层级变动功能



;- [Constant]
#EModule_Pitch = 14


;- [Enumeration]
Enumeration
   #winScreen
   #cvsScreen
   #btnFloorTop
   #btnFloorPrev
   #btnFloorNext
   #btnFloorBottom
   #btnAddMatter
   
   #btnAlignLeft
   #btnAlignRight
   #btnAlignCenter
   #btnAlignTop  
   #btnAlignBottom
   #btnAlignMiddle
   
   #btnTraverse
   #btnVertical
   
EndEnumeration


;- [Structure]

Structure __DisableInfo
   FirstFloor.b   
   FinalFloor.b
EndStructure


Structure __MainMaker
   ModuleID.l
   MatterX.w
   MatterY.w
EndStructure


;- [Include]
XIncludeFile "Maker_Object.pb"  

;- [Global]
Global _Maker.__MainMaker


;-
;- ******** [函数] ********
;-
;- ******** [线程] ********
Procedure Redraw_Graphics() 
   If StartVectorDrawing(CanvasVectorOutput(#cvsScreen))
      VectorSourceColor($FFFFFFFF)
      FillVectorOutput()
      Object_RefreshRedraw()
      StopVectorDrawing()
   EndIf
EndProcedure


;画布事件
Procedure EventGadget_cvsScreen()

   Select EventType()
      Case #PB_EventType_RightClick
         X = GetGadgetAttribute(#cvsScreen, #PB_Canvas_MouseX)
         Y = GetGadgetAttribute(#cvsScreen, #PB_Canvas_MouseY)
         
      Case #PB_EventType_LeftButtonDown
         X = GetGadgetAttribute(#cvsScreen, #PB_Canvas_MouseX)
         Y = GetGadgetAttribute(#cvsScreen, #PB_Canvas_MouseY)
         NeedRefresh = Object_Event_LeftButtonDown(X, Y, _Maker\ModuleID)
         *pDisable.__DisableInfo = Object_GetDisable()
         DisableGadget(#btnFloorTop,    *pDisable\FinalFloor)
         DisableGadget(#btnFloorPrev,   *pDisable\FinalFloor)
         DisableGadget(#btnFloorBottom, *pDisable\FirstFloor)
         DisableGadget(#btnFloorNext,   *pDisable\FirstFloor)

      Case #PB_EventType_LeftButtonUp
         X = GetGadgetAttribute(#cvsScreen, #PB_Canvas_MouseX)
         Y = GetGadgetAttribute(#cvsScreen, #PB_Canvas_MouseY)
         NeedRefresh = Object_Event_LeftButtonUp(X, Y)        
         _Maker\ModuleID = #Null
         SetGadgetState(#btnAddMatter, #False)
      Case #PB_EventType_MouseMove
         X = GetGadgetAttribute(#cvsScreen, #PB_Canvas_MouseX)
         Y = GetGadgetAttribute(#cvsScreen, #PB_Canvas_MouseY)
         NeedRefresh = Object_Event_MouseMove(X, Y)            
   EndSelect
   If NeedRefresh = #True
      Redraw_Graphics()
   EndIf 
EndProcedure

;-
Procedure EventGadget_btnAddMatter()
   _Maker\ModuleID = Object_Select("Tracking Module")
EndProcedure

Procedure EventGadget_btnAlignLeft()
   If Object_Alignment(#Object_Align_Left)
      Redraw_Graphics()
   EndIf 
EndProcedure


Procedure EventGadget_btnAlignRight()
   If Object_Alignment(#Object_Align_Right)
      Redraw_Graphics()
   EndIf 
EndProcedure


Procedure EventGadget_btnAlignTop()
   If Object_Alignment(#Object_Align_Top)
      Redraw_Graphics()
   EndIf 
EndProcedure

Procedure EventGadget_btnAlignCenter()
   If Object_Alignment(#Object_Align_Center)
      Redraw_Graphics()
   EndIf 
EndProcedure

Procedure EventGadget_btnAlignBottom()
   If Object_Alignment(#Object_Align_Bottom)
      Redraw_Graphics()
   EndIf 
EndProcedure


Procedure EventGadget_btnAlignMiddle()
   If Object_Alignment(#Object_Align_Middle)
      Redraw_Graphics()
   EndIf 
EndProcedure


Procedure EventGadget_btnTraverse()
   If Object_Alignment(#Object_Traverse)
      Redraw_Graphics()
   EndIf 
EndProcedure


Procedure EventGadget_btnVertical()
   If Object_Alignment(#Object_Vertical)
      Redraw_Graphics()
   EndIf 
EndProcedure

Procedure EventGadget_btnFloorTop()
   If Object_SetLayerState(#Layer_Floor_Top)
      Redraw_Graphics()
   EndIf  
EndProcedure 
   
Procedure EventGadget_btnFloorPrev()
   If Object_SetLayerState(#Layer_Floor_Prev)
      Redraw_Graphics()
   EndIf  
EndProcedure 
   
Procedure EventGadget_btnFloorNext()
   If Object_SetLayerState(#Layer_Floor_Next)
      Redraw_Graphics()
   EndIf    
EndProcedure 
   
   
Procedure EventGadget_btnFloorBottom()
   If Object_SetLayerState(#Layer_Floor_Bottom)
      Redraw_Graphics()
   EndIf   
EndProcedure 
   
   
;-
;- ######## [主程] ########


If Object_Initial() = #False : End : EndIf 
*pModule = Object_Select("Tracking Module")
Fun_AddMatter(*pModule, 100, 100, #Object_Rotate_000)
Fun_AddMatter(*pModule, 200, 100, #Object_Rotate_000)
Fun_AddMatter(*pModule, 300, 100, #Object_Rotate_000)


If OpenWindow(#winScreen, 0, 0, 1000, 750, "模块类初始化测试", #PB_Window_SystemMenu|#PB_Window_ScreenCentered)
   ButtonGadget(#btnFloorTop,    010, 050, 080, 030, "到顶层")
   ButtonGadget(#btnFloorBottom, 010, 080, 080, 030, "到底层")
   ButtonGadget(#btnFloorPrev,   010, 110, 080, 030, "上一层")
   ButtonGadget(#btnFloorNext,   010, 140, 080, 030, "下一层")
   
   ButtonGadget(#btnAddMatter,   010, 200, 080, 030, "添加", #PB_Button_Toggle)
   
   ButtonGadget(#btnAlignLeft,   010, 250, 080, 030, "左对齐")
   ButtonGadget(#btnAlignRight,  010, 280, 080, 030, "右对齐")
   ButtonGadget(#btnAlignCenter, 010, 310, 080, 030, "中心对齐")
   ButtonGadget(#btnAlignTop,    010, 350, 080, 030, "上对齐")
   ButtonGadget(#btnAlignBottom, 010, 380, 080, 030, "下对齐")
   ButtonGadget(#btnAlignMiddle, 010, 410, 080, 030, "居中对齐")

   ButtonGadget(#btnTraverse, 010, 450, 080, 030, "水平分布")   
   ButtonGadget(#btnVertical, 010, 480, 080, 030, "垂直分布")   
   
   
   
   
   CanvasGadget(#cvsScreen, 100, 0, 900, 750, #PB_Canvas_ClipMouse)
   Redraw_Graphics()
   BindGadgetEvent(#cvsScreen,      @EventGadget_cvsScreen())
   BindGadgetEvent(#btnAddMatter,   @EventGadget_btnAddMatter())
   BindGadgetEvent(#btnAlignLeft,   @EventGadget_btnAlignLeft())
   BindGadgetEvent(#btnAlignRight,  @EventGadget_btnAlignRight())
   BindGadgetEvent(#btnAlignCenter, @EventGadget_btnAlignCenter())
   
   BindGadgetEvent(#btnAlignTop,    @EventGadget_btnAlignTop())
   BindGadgetEvent(#btnAlignBottom, @EventGadget_btnAlignBottom())
   BindGadgetEvent(#btnAlignMiddle, @EventGadget_btnAlignMiddle())
   
   BindGadgetEvent(#btnTraverse,    @EventGadget_btnTraverse())
   BindGadgetEvent(#btnVertical,    @EventGadget_btnVertical()) 
   
   BindGadgetEvent(#btnFloorTop,    @EventGadget_btnFloorTop())   
   BindGadgetEvent(#btnFloorBottom, @EventGadget_btnFloorBottom())   
   BindGadgetEvent(#btnFloorPrev,   @EventGadget_btnFloorPrev())   
   BindGadgetEvent(#btnFloorNext,   @EventGadget_btnFloorNext())   
   
   Repeat
      WinEvent = WindowEvent()
      Select WinEvent 
         Case #PB_Event_CloseWindow : IsExitWindow = #True
         Case #PB_Event_Gadget
      EndSelect
   Until IsExitWindow = #True
EndIf
Object_Release()   ;注销
End
























; IDE Options = PureBasic 5.62 (Windows - x86)
; CursorPosition = 101
; FirstLine = 56
; Folding = 1---
; EnableXP