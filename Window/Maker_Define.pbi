;*****************************************
;******** 单片机仿真模拟器窗体界面 ********
;********    迷路仟 2020.02.24    ********
;*****************************************
;【Maker_Define.pbi】 定义类源代码

;-[Constant]
#WinSideL = 3                       ;左际留边大小
#WinSideR = 7                       ;右际留边大小
#WinSideT = 3                       ;顶部留边大小
#WinSideB = 7                       ;底部留边大小
#CaptionH = 40                      ;标题栏高度
#TIMER_SizeWindow     = 1           ;窗体调整计时器事件
#TIMER_ShowBalloon    = 2           ;提示文计时器事件
#TIMER_ChangeColor    = 3           ;提示文计时器事件

#Define_BackColor = $FFEAEAEA   
#Define_ForeColor = $FF1A1A1A
#Define_HighColor = $FF67D9FE

;四种风格的颜色表
#ViewStlye_Black = 0
#Black_BackColor = $FFF0F0F0   
#Black_ForeColor = $FF1A1A1A
#Black_HighColor = $FF67D9FE

#ViewStlye_Green = 1
#Green_BackColor = $FFF0F8F0
#Green_ForeColor = $FF303010
#Green_HighColor = $FF66c54d

#ViewStlye_Blue = 2
#Blue_BackColor = $FFF8F0F0   
#Blue_ForeColor = $FF3b0e03
#Blue_HighColor = $FFd69403

#ViewStlye_Red = 3
#Red_BackColor = $FFF0F0F8
#Red_ForeColor = $FF000010
#Red_HighColor = $FF5653ff

#Object_Event_Align = 32

;-[Enumeration]
Enumeration
   #CallBack_CreateDesign = 1
   #CallBack_OpenDesign
   #CallBack_LoadDesign
   #CallBack_SaveDesign
   #CallBack_CloseDesign
   #CallBack_ExportImage
   #CallBack_SelectDesign
   #CallBack_SelectMatter
   #CallBack_RedrawCanvas
   #CallBack_GetThumbnail
   #CallBack_ProgressBar
   
EndEnumeration


Enumeration Screen
   ;====== 标题栏
   #wmiSoftware         ;软件标志和名字
   #wmiSettings
   #wmiCreateDesign     ;创建设计文档
   #wmiOpenDesign       ;打开设计文档
   #wmiSaveDesign       ;保存设计文档
   #wmiSaveAsDesign     ;设计文档另存为
   #wmiSaveAllDesign    ;保存所有设计文档
   #wmiCloseDesign      ;关闭设计文档
   #wmiCloseAllDesign   ;关闭所有设计文档
   #wmiExportImage      ;导出画布图像
   #wmiResizeCanvas     ;重新设计画布尺寸
   #wmiExitSoftware     ;退出软件
   #wmiScrollLeft       ;左移分页项
   #wmiScrollRight      ;右移分页项
   ;====== 视图栏
   #wmiDisplayGrid    ;显示网格
   #wmiDisplayCoor    ;显示坐标
   #wmiStyleBlack     ;黑板风格
   #wmiStyleGreen     ;绿板风格
   #wmiStyleBlue      ;蓝板风格
   #wmiStyleRed       ;红板风格
   ;====== 工具栏
   #wtbComponents       ;电子元件
   #wtbCircuitMod       ;电子模块
   #wtbSensorsMod       ;传感器模块
   #wtbPowSwitchs       ;电源和开关
   #wtbAccessorys       ;辅助部件
   #wtbMainBoards       ;单片机开发板
   #wtbOperations       ;基本编辑
   #wtbMiscellane       ;基本编辑
   ;====== 导航
   #btnMovingBar
   #btnScrollUp         ;向上滚动画布
   #btnScrollDown       ;向下滚动画布
   #btnScrollLeft       ;向左滚动画布
   #btnScrollRight      ;向右滚动画布
   #btnScrollHome       ;画布滚动至主页
   #btnScaleUp          ;扩大画布比例
   #btnScaleDown        ;缩小画布比例 
   ;====== 基本操作
   #wmiCreateString     ;添加标签
   #wmiDeleteObject     ;删除对象
   #wmiMergerGroups     ;组合[活动组]
   #wmiDivideGroups     ;拆分[选中组]
   #wmiDupontsColor     ;[杜邦线]修改颜色
   #wmiLayerTop         ;置于顶层 
   #wmiLayerBottom      ;置于底层  
   #wmiLayerPrev        ;上移一层
   #wmiLayerNext        ;下移一层
   #wmiRotateTurnL90    ;左转90度
   #wmiRotateTurnR90    ;右转90度
   #wmiRotateFlip180    ;翻转对象
   #wmiAlignLeft        ;左对齐
   #wmiAlignCenter      ;水平中心对齐 
   #wmiAlignRight       ;右对齐   
   #wmiAlignTop         ;上对齐
   #wmiAlignMiddle      ;垂直中心对齐
   #wmiAlignBottom      ;下对齐
   
   #wmiEvenlyLeft       ;左侧分布
   #wmiEvenlyCenter     ;水平中心分布
   #wmiEvenlySpace      ;水平间距分布
   #wmiEvenlyRight      ;右侧分布
   #wmiEvenlyTop        ;上侧分布
   #wmiEvenlyMiddle     ;垂直中心分布
   #wmiEvenlyBorder     ;垂直间距分布
   #wmiEvenlyBottom     ;下侧分布
   
   #wmiAlignGrids
EndEnumeration

;颜色结构
Structure __ColorInfo
   BackColor.l
   ForeColor.l
   HighColor.l
   SideColor.l
   BordColor.l
   FontColor.l
EndStructure

;域结构
Structure __AreaInfo
   X.l            ;左际/X坐标
   Y.l            ;上际/Y坐标
   R.l            ;右际
   B.l            ;下际
   W.l
   H.l
EndStructure

;事件结构
Structure __EventDataInfo
   MouseX.l
   MouseY.l
   Button.l
EndStructure

;控件基本结构
Structure __GadgetInfo Extends __AreaInfo
   NormalcyID.i   ;正常状态下的控件图像编号
   MouseTopID.i   ;鼠标置顶时的控件图像编号
   HoldDownID.i   ;左键按下时的控件图像编号
   ;======
   BalloonTip$    ;按键提示文
   Text$
   GadgetID.l
   OffsetX.w
   OffsetY.w
   IconX.w
   IconY.w
   ;======
   IsHide.b       ;控件是否隐藏
   IsCreate.b     ;控件是否创建
   Keep.b[2]      ;保留空间/对齐
EndStructure

;窗体基本结构
Structure __WindowInfo
   WindowX.w         ;主界面窗体X坐标
   WindowY.w         ;主界面窗体Y坐标
   WindowW.w         ;主界面窗体宽度
   WindowH.w         ;主界面窗体高度
   ;=================
   WindowID.l
   hWindow.i         ;主界面窗体句柄
   hWindowHook.i     ;主界面HOOK句柄
   LayerImageID.l  
   hLayerImage.l
   ;=================
   *pCurrDesign.__Caption_DesignInfo
   NaviOffsetX.w
   NaviOffsetY.w
   NaviOffsetR.w
   NaviOffsetB.w
   IsNaviLockedR.b
   IsNaviLockedB.b
   ;=================
   IsCreateString.b
   IsDisplayGrid.b
   ;=================
   ResourIconID.l
   Font12ID.l  
   Font09ID.l  
   LayerZoom.f
EndStructure

;事件基本结构
Structure __EventInfo
   *pMouseTop.__GadgetInfo    ;当前光标在上
   *pHoldDown.__GadgetInfo    ;当前光标按住
   *pSelected.__GadgetInfo    ;选中状态
   *pMoving
EndStructure

;模块基本结构
Structure __ModuleInfo
   ModuleGroup$      ;模块编组
   ModuleTypes$      ;模块类型
   ModuleModel$      ;模块型号
   ModuleName$       ;模块名称
   ModuleNote$       ;模块说明
   hModuleIcon.l     ;模块图标ID
   ModuleID.l
   X.w
   Y.w
   W.w
   H.w
   R.w
   B.w 
EndStructure

;模块类型,用于引擎函数导出数据
Structure __Maker_ModuleType
   *pModuleGroup      ;模块编组
   *pModuleTypes      ;模块类型
   *pModuleModel      ;模块型号
   *pModuleName       ;模块名称
   *pModuleNote       ;模块说明
   hModuleIcon.l      ;模块图标ID
   ModuleID.l
EndStructure

Structure __Maker_ColorTable
   Color.l
   X.w
   Y.w
EndStructure

Structure __Maker_ObjectInfo
   X.l
   Y.l
   W.l
   H.l
   FontSize.l
   FontColor.l
   Text$
EndStructure

;- [Global]
Global NewMap _MapModule.__Maker_ModuleType()
Global Dim _DimColorTable.__Maker_ColorTable(40)
For k = 0 To 40
   _DimColorTable(k)\Color = -1
Next 

;-
;- ======> [Global Call] <======
;创建关闭按键
Procedure Define_CreateCloseBox(*pColors.__ColorInfo, *pGadget.__GadgetInfo)
   With *pGadget
      \IsCreate = #True
      If IsImage(\NormalcyID) : FreeImage(\NormalcyID) : EndIf 
      If IsImage(\MouseTopID) : FreeImage(\MouseTopID) : EndIf 
      If IsImage(\HoldDownID) : FreeImage(\HoldDownID) : EndIf 
      
      ForeColor1 = *pColors\BackColor
      ForeColor2  = (Alpha(ForeColor1) << 23 & $FF000000) |(ForeColor1 & $FFFFFF)
      \W = 36 : \H = 36 : x = (\W-30)/2 : y = (\H-30)/2 : i = (\W-13)/2 : j = (\H-12)/2
      ;绘制背景小圆圈
      TempImageID = CreateImage(#PB_Any, \W, \H, 32, #PB_Image_Transparent)
      If StartVectorDrawing(ImageVectorOutput(TempImageID))
         AddPathCircle(x+14, y+14, 15)
         VectorSourceCircularGradient(x+14, y+14, 15)
         VectorSourceGradientColor($00000000, 0.00)
         VectorSourceGradientColor($00000000, 0.60)
         VectorSourceGradientColor($80000000, 0.80)
         VectorSourceGradientColor($80FFFFFF, 0.95)
         VectorSourceGradientColor($00000000, 1.00)
         FillPath() 
         StopVectorDrawing()
      EndIf

      ;绘制[X]符号
      If StartDrawing(ImageOutput(TempImageID))
         DrawingMode(#PB_2DDrawing_AlphaBlend)
         LineXY(i+0, j+0, i+9+0, j+9, ForeColor2)
         LineXY(i+1, j+0, i+9+1, j+9, ForeColor1)
         LineXY(i+2, j+0, i+9+2, j+9, ForeColor2)
         LineXY(i+0, j+9, i+9+0, j+0, ForeColor2)   
         LineXY(i+1, j+9, i+9+1, j+0, ForeColor1) 
         LineXY(i+2, j+9, i+9+2, j+0, ForeColor2) 
         StopDrawing()
      EndIf

      ;绘制正常状态下的控件图像
      \NormalcyID = CreateImage(#PB_Any, \W, \H, 32, #PB_Image_Transparent)
      If StartDrawing(ImageOutput(\NormalcyID))
         DrawingMode(#PB_2DDrawing_AlphaBlend)
         Circle(x+14, y+14, 10, $E05060FF)     ;背景渲染
         DrawAlphaImage(ImageID(TempImageID), 0, 0)
         StopDrawing()
      EndIf

      ;绘制鼠标置顶时的控件图像
      \MouseTopID = CreateImage(#PB_Any, \W, \H, 32, #PB_Image_Transparent)
      If StartDrawing(ImageOutput(\MouseTopID))
         DrawingMode(#PB_2DDrawing_AlphaBlend)
         Circle(x+14, y+14, 10, $FF919BFF)     ;背景渲染
         DrawAlphaImage(ImageID(TempImageID), 0, 0)
         StopDrawing()
      EndIf

      ;绘制左键按下时的控件图像
      \HoldDownID = CreateImage(#PB_Any, \W, \H, 32, #PB_Image_Transparent)
      If StartDrawing(ImageOutput(\HoldDownID))
         DrawingMode(#PB_2DDrawing_AlphaBlend)
         Circle(x+14, y+14, 10, $FF0D1CB5)     ;背景渲染
         DrawAlphaImage(ImageID(TempImageID), 0, 0)
         StopDrawing()
      EndIf
      FreeImage(TempImageID)

   EndWith
EndProcedure

;创建最小化按键
Procedure Define_CreateMinimize(*pColors.__ColorInfo, *pGadget.__GadgetInfo)
   With *pGadget
      \IsCreate = #True
      If IsImage(\NormalcyID) : FreeImage(\NormalcyID) : EndIf 
      If IsImage(\MouseTopID) : FreeImage(\MouseTopID) : EndIf 
      If IsImage(\HoldDownID) : FreeImage(\HoldDownID) : EndIf 

      ForeColor1 = *pColors\BackColor
      ForeColor2  = (Alpha(ForeColor1) << 23 & $FF000000) |(ForeColor1 & $FFFFFF)
      \W = 36 : \H = 36 : x = (\W-30)/2 : y = (\H-30)/2 : i = (\W-09)/2 : j = (\H-03)/2
 
      ;绘制背景小圆圈
      TempImageID = CreateImage(#PB_Any, \W, \H, 32, #PB_Image_Transparent)
      If StartVectorDrawing(ImageVectorOutput(TempImageID))
         AddPathCircle(x+14, y+14, 15)
         VectorSourceCircularGradient(x+14, y+14, 15)
         VectorSourceGradientColor($00000000, 0.00)
         VectorSourceGradientColor($00000000, 0.60)
         VectorSourceGradientColor($80000000, 0.80)
         VectorSourceGradientColor($80FFFFFF, 0.95)
         VectorSourceGradientColor($00000000, 1.00)
         FillPath() 
         StopVectorDrawing()
      EndIf

      ;绘制[-]符号
      If StartDrawing(ImageOutput(TempImageID))
         DrawingMode(#PB_2DDrawing_AlphaBlend)
         Box(i, j+0, 09, 03, ForeColor2)
         Box(i, j+1, 09, 01, ForeColor1)
         StopDrawing()
      EndIf

      ;绘制正常状态下的控件图像
      \NormalcyID = CreateImage(#PB_Any, \W, \H, 32, #PB_Image_Transparent)
      If StartDrawing(ImageOutput(\NormalcyID))
         DrawingMode(#PB_2DDrawing_AlphaBlend)
         Circle(x+14, y+14, 10, $E020E080)     ;背景渲染
         DrawAlphaImage(ImageID(TempImageID), 0, 0)
         StopDrawing()
      EndIf

      ;绘制鼠标置顶时的控件图像
      \MouseTopID = CreateImage(#PB_Any, \W, \H, 32, #PB_Image_Transparent)
      If StartDrawing(ImageOutput(\MouseTopID))
         DrawingMode(#PB_2DDrawing_AlphaBlend)
         Circle(x+14, y+14, 10, $FF4ADF95)     ;背景渲染
         DrawAlphaImage(ImageID(TempImageID), 0, 0)
         StopDrawing()
      EndIf

      ;绘制左键按下时的控件图像
      \HoldDownID = CreateImage(#PB_Any, \W, \H, 32, #PB_Image_Transparent)
      If StartDrawing(ImageOutput(\HoldDownID))
         DrawingMode(#PB_2DDrawing_AlphaBlend)
         Circle(x+14, y+14, 10, $FF048B48)     ;背景渲染
         DrawAlphaImage(ImageID(TempImageID), 0, 0)
         StopDrawing()
      EndIf
      FreeImage(TempImageID)

   EndWith
EndProcedure

;创建最大化按键
Procedure Define_CreateMaximize(*pColors.__ColorInfo, *pGadget.__GadgetInfo)
   With *pGadget
      \IsCreate = #True
      If IsImage(\NormalcyID) : FreeImage(\NormalcyID) : EndIf 
      If IsImage(\MouseTopID) : FreeImage(\MouseTopID) : EndIf 
      If IsImage(\HoldDownID) : FreeImage(\HoldDownID) : EndIf 
      
      ForeColor1 = *pColors\BackColor
      ForeColor2  = (Alpha(ForeColor1) << 23 & $FF000000) |(ForeColor1 & $FFFFFF)
      \W = 36 : \H = 36 : x = (\W-30)/2 : y = (\H-30)/2 : i = (\W-13)/2 : j = (\H-09)/2
      
      ;绘制背景小圆圈
      TempImageID = CreateImage(#PB_Any, \W, \H, 32, #PB_Image_Transparent)
      If StartVectorDrawing(ImageVectorOutput(TempImageID))
         AddPathCircle(x+14, y+14, 15)
         VectorSourceCircularGradient(x+14, y+14, 15)
         VectorSourceGradientColor($00000000, 0.00)
         VectorSourceGradientColor($00000000, 0.60)
         VectorSourceGradientColor($80000000, 0.80)
         VectorSourceGradientColor($80FFFFFF, 0.95)
         VectorSourceGradientColor($00000000, 1.00)
         FillPath() 
         StopVectorDrawing()
      EndIf

      ;绘制[□]符号
      If StartDrawing(ImageOutput(TempImageID))
         DrawingMode(#PB_2DDrawing_AlphaBlend|#PB_2DDrawing_Outlined)
         Box(i+00, j+00, 12, 08, ForeColor1)
         Box(i+01, j+00, 10, 08, ForeColor2)
         StopDrawing()
      EndIf

      ;绘制正常状态下的控件图像
      \NormalcyID = CreateImage(#PB_Any, \W, \H, 32, #PB_Image_Transparent)
      If StartDrawing(ImageOutput(\NormalcyID))
         DrawingMode(#PB_2DDrawing_AlphaBlend)
         Circle(x+14, y+14, 10, $FFFF8060)     ;背景渲染
         DrawAlphaImage(ImageID(TempImageID), 0, 0)
         StopDrawing()
      EndIf

      ;绘制鼠标置顶时的控件图像
      \MouseTopID = CreateImage(#PB_Any, \W, \H, 32, #PB_Image_Transparent)
      If StartDrawing(ImageOutput(\MouseTopID))
         DrawingMode(#PB_2DDrawing_AlphaBlend)
         Circle(x+14, y+14, 10, $FFFFBA87)     ;背景渲染
         DrawAlphaImage(ImageID(TempImageID), 0, 0)
         StopDrawing()
      EndIf

      ;绘制左键按下时的控件图像
      \HoldDownID = CreateImage(#PB_Any, \W, \H, 32, #PB_Image_Transparent)
      If StartDrawing(ImageOutput(\HoldDownID))
         DrawingMode(#PB_2DDrawing_AlphaBlend)
         Circle(x+14, y+14, 10, $FF993A22)     ;背景渲染
         DrawAlphaImage(ImageID(TempImageID), 0, 0)
         StopDrawing()
      EndIf
      FreeImage(TempImageID)

   EndWith
EndProcedure

;创建正常化按键
Procedure Define_CreateNormalcy(*pColors.__ColorInfo, *pGadget.__GadgetInfo)
   With *pGadget
      \IsCreate = #True
      \IsHide   = #True
      If IsImage(\NormalcyID) : FreeImage(\NormalcyID) : EndIf 
      If IsImage(\MouseTopID) : FreeImage(\MouseTopID) : EndIf 
      If IsImage(\HoldDownID) : FreeImage(\HoldDownID) : EndIf 
      ForeColor1 = *pColors\BackColor
      ForeColor2  = (Alpha(ForeColor1) << 23 & $FF000000) |(ForeColor1 & $FFFFFF)
      \W = 36 : \H = 36 : x = (\W-30)/2 : y = (\H-30)/2 : i = (\W-13)/2 : j = (\H-11)/2

      ;绘制背景小圆圈
      TempImageID = CreateImage(#PB_Any, \W, \H, 32, #PB_Image_Transparent)
      If StartVectorDrawing(ImageVectorOutput(TempImageID))
         AddPathCircle(x+14, y+14, 15)
         VectorSourceCircularGradient(x+14, y+14, 15)
         VectorSourceGradientColor($00000000, 0.00)
         VectorSourceGradientColor($00000000, 0.60)
         VectorSourceGradientColor($80000000, 0.80)
         VectorSourceGradientColor($80FFFFFF, 0.95)
         VectorSourceGradientColor($00000000, 1.00)
         FillPath() 
         StopVectorDrawing()
      EndIf

      ;绘制[□□]符号
      If StartDrawing(ImageOutput(TempImageID))
         DrawingMode(#PB_2DDrawing_AlphaBlend|#PB_2DDrawing_Outlined)
         Box(i+05, j+00, 07, 06, ForeColor1)
         DrawingMode(#PB_2DDrawing_AllChannels) 
         Box(i+00, j+03, 09, 07, $0)
         DrawingMode(#PB_2DDrawing_AlphaBlend|#PB_2DDrawing_Outlined)
         Box(i+00, j+03, 09, 07, ForeColor1)
         Box(i+01, j+03, 07, 07, ForeColor2)  
         StopDrawing()
      EndIf

      ;绘制正常状态下的控件图像
      \NormalcyID = CreateImage(#PB_Any, \W, \H, 32, #PB_Image_Transparent)
      If StartDrawing(ImageOutput(\NormalcyID))
         DrawingMode(#PB_2DDrawing_AlphaBlend)
         Circle(x+14, y+14, 10, $FFFF8060)     ;背景渲染
         DrawAlphaImage(ImageID(TempImageID), 0, 0)
         StopDrawing()
      EndIf

      ;绘制鼠标置顶时的控件图像
      \MouseTopID = CreateImage(#PB_Any, \W, \H, 32, #PB_Image_Transparent)
      If StartDrawing(ImageOutput(\MouseTopID))
         DrawingMode(#PB_2DDrawing_AlphaBlend)
         Circle(x+14, y+14, 10, $FFFFBA87)     ;背景渲染
         DrawAlphaImage(ImageID(TempImageID), 0, 0)
         StopDrawing()
      EndIf

      ;绘制左键按下时的控件图像
      \HoldDownID = CreateImage(#PB_Any, \W, \H, 32, #PB_Image_Transparent)
      If StartDrawing(ImageOutput(\HoldDownID))
         DrawingMode(#PB_2DDrawing_AlphaBlend)
         Circle(x+14, y+14, 10, $FF993A22)     ;背景渲染
         DrawAlphaImage(ImageID(TempImageID), 0, 0)
         StopDrawing()
      EndIf
      FreeImage(TempImageID)

   EndWith
EndProcedure

;创建窗体设置按键
Procedure Define_CreateSettings(*pColors.__ColorInfo, *pGadget.__GadgetInfo)
   With *pGadget
      \IsCreate = #True
      If IsImage(\NormalcyID) : FreeImage(\NormalcyID) : EndIf 
      If IsImage(\MouseTopID) : FreeImage(\MouseTopID) : EndIf 
      If IsImage(\HoldDownID) : FreeImage(\HoldDownID) : EndIf
      
      ForeColor1 = *pColors\BackColor
      ForeColor2  = (Alpha(ForeColor1) << 23 & $FF000000) |(ForeColor1 & $FFFFFF)
      \W = 36 : \H = 36 : x = (\W-30)/2 : y = (\H-30)/2 : i = (\W-14)/2 : j = (\H-07)/2
        
      ;绘制背景小圆圈
      TempImageID = CreateImage(#PB_Any, \W, \H, 32, #PB_Image_Transparent)
      If StartVectorDrawing(ImageVectorOutput(TempImageID))
         AddPathCircle(x+14, y+14, 15)
         VectorSourceCircularGradient(x+14, y+14, 15)
         VectorSourceGradientColor($00000000, 0.00)
         VectorSourceGradientColor($00000000, 0.60)
         VectorSourceGradientColor($80000000, 0.80)
         VectorSourceGradientColor($80FFFFFF, 0.95)
         VectorSourceGradientColor($00000000, 1.00)
         FillPath() 
         StopVectorDrawing()
      EndIf

      ;绘制[V]符号
      If StartDrawing(ImageOutput(TempImageID))
         DrawingMode(#PB_2DDrawing_AlphaBlend)
         Line(i+0, j+0, 07, 07, ForeColor2)
         Line(i+7, j+5, 06, -6, ForeColor2)
         Line(i+2, j+0, 05, 05, ForeColor2)
         Line(i+7, j+3, 04, -4, ForeColor2)
         Line(i+1, j+0, 06, 06, ForeColor1)
         Line(i+7, j+4, 05, -5, ForeColor1)
         StopDrawing()
      EndIf

      ;绘制正常状态下的控件图像
      \NormalcyID = CreateImage(#PB_Any, \W, \H, 32, #PB_Image_Transparent)
      If StartDrawing(ImageOutput(\NormalcyID))
         DrawingMode(#PB_2DDrawing_AlphaBlend)
         Circle(x+14, y+14, 10, $FFE43ADE)     ;背景渲染
         DrawAlphaImage(ImageID(TempImageID), 0, 0)
         StopDrawing()
      EndIf

      ;绘制鼠标置顶时的控件图像
      \MouseTopID = CreateImage(#PB_Any, \W, \H, 32, #PB_Image_Transparent)
      If StartDrawing(ImageOutput(\MouseTopID))
         DrawingMode(#PB_2DDrawing_AlphaBlend)
         Circle(x+14, y+14, 10, $FFFF53F8)     ;背景渲染
         DrawAlphaImage(ImageID(TempImageID), 0, 0)
         StopDrawing()
      EndIf

      ;绘制左键按下时的控件图像
      \HoldDownID = CreateImage(#PB_Any, \W, \H, 32, #PB_Image_Transparent)
      If StartDrawing(ImageOutput(\HoldDownID))
         DrawingMode(#PB_2DDrawing_AlphaBlend)
         Circle(x+14, y+14, 10, $FF9E1799)     ;背景渲染
         DrawAlphaImage(ImageID(TempImageID), 0, 0)
         StopDrawing()
      EndIf
      FreeImage(TempImageID)

   EndWith
EndProcedure

;创建通用按键
Procedure Define_CreateButton(*pColors.__ColorInfo, *pGadget.__GadgetInfo, X, Y, W, H, Text$, FontID)
   With *pGadget
      \IsCreate = #True
      FontColor = *pColors\BackColor  
      SideColor = *pColors\ForeColor
      BackColor = (Alpha(SideColor) << 23 & $FF000000) |(SideColor & $FFFFFF)
      
      HighColor1 = *pColors\HighColor
      HighColor2 = (Alpha(HighColor1) << 22 & $FF000000) |(HighColor1 & $FFFFFF)
      \X = X : \Y = Y : \W = W : \H = H : \R = X+W : \B = Y+H
      If IsImage(\NormalcyID) : FreeImage(\NormalcyID) : EndIf 
      If IsImage(\MouseTopID) : FreeImage(\MouseTopID) : EndIf 
      If IsImage(\HoldDownID) : FreeImage(\HoldDownID) : EndIf 
      \NormalcyID = CreateImage(#PB_Any, W, H, 32, #PB_Image_Transparent)
      If StartDrawing(ImageOutput(\NormalcyID))
         DrawingMode(#PB_2DDrawing_AllChannels)
         Box(0,0,\W, \H, SideColor)
         Box(1,1,\W-2, \H-2, BackColor)
         DrawingMode(#PB_2DDrawing_Transparent)
         DrawingFont(FontID(FontID))
         X = (W-TextWidth(Text$ ))/2
         Y = (H-TextHeight(Text$))/2
         DrawText(X+0, Y+0, Text$, FontColor)
         StopDrawing()
      EndIf
      
      \MouseTopID = CreateImage(#PB_Any, W, H, 32, #PB_Image_Transparent)
      If StartDrawing(ImageOutput(\MouseTopID))
         DrawAlphaImage(ImageID(\NormalcyID), 0, 0)
         DrawingMode(#PB_2DDrawing_AlphaBlend)
         Box(1, 1, \W-2, \H-2, HighColor2)
         StopDrawing()
      EndIf
      
      \HoldDownID = CreateImage(#PB_Any, W, H, 32, #PB_Image_Transparent)
      If StartDrawing(ImageOutput(\HoldDownID))
         DrawAlphaImage(ImageID(\NormalcyID), 0, 0)
         DrawingMode(#PB_2DDrawing_AlphaBlend)
         Box(1, 1, \W-2, \H-2, HighColor2)
         DrawingMode(#PB_2DDrawing_Outlined|#PB_2DDrawing_AlphaBlend)
         Box(0, 0, W, H, HighColor1)
         StopDrawing()
      EndIf      
   EndWith
EndProcedure

;-
;绘制控件
Procedure Define_RedrawGadget(*pEvent.__EventInfo, *pGadget.__GadgetInfo, X=#PB_Ignore, Y=#PB_Ignore)
   With *pGadget
      If *pGadget = 0 : ProcedureReturn : EndIf
      If *pGadget\IsHide = #True : ProcedureReturn : EndIf
      If *pGadget\IsCreate = #False : ProcedureReturn : EndIf
      If X <> #PB_Ignore : \X = X : \R = \X+\W : EndIf
      If Y <> #PB_Ignore : \Y = Y : \B = \Y+\H : EndIf
      If *pEvent\pHoldDown = *pGadget And IsImage(\HoldDownID)
         DrawAlphaImage(ImageID(\HoldDownID), \X, \Y)
      ElseIf *pEvent\pMouseTop = *pGadget And IsImage(\MouseTopID)
         DrawAlphaImage(ImageID(\MouseTopID), \X, \Y)
      ElseIf IsImage(\NormalcyID)
         DrawAlphaImage(ImageID(\NormalcyID), \X, \Y)
      EndIf 
   EndWith
EndProcedure

;注销控件
Procedure Define_FreeGadget(*pGadget.__GadgetInfo)
   If *pGadget = 0 : ProcedureReturn #False: EndIf
   If *pGadget\IsCreate = #False : ProcedureReturn #False: EndIf
   With *pGadget
      \X = 0 : \Y = 0 : \R = 0: \B = 0 
      If IsImage(\NormalcyID) : FreeImage(\NormalcyID) : EndIf : \NormalcyID = 0
      If IsImage(\MouseTopID) : FreeImage(\MouseTopID) : EndIf : \MouseTopID = 0
      If IsImage(\HoldDownID) : FreeImage(\HoldDownID) : EndIf : \HoldDownID = 0
   EndWith
EndProcedure


;-
;- ======> [Global Macro] <======
;[宏]判断操作域
Macro Macro_Gadget_InRect1(Gadget)
   *pMouse\X > Gadget\X And *pMouse\X < Gadget\R And *pMouse\Y > Gadget\Y And *pMouse\Y < Gadget\B
EndMacro

Macro Macro_Gadget_InRect2(Gadget)
   Gadget\IsHide = #False And *pMouse\X > Gadget\X And *pMouse\X < Gadget\R And *pMouse\Y > Gadget\Y And *pMouse\Y < Gadget\B
EndMacro

Macro Macro_Gadget_InRect3(Gadget)
   Gadget\IsCreate = #True And *pMouse\X > Gadget\X And *pMouse\X < Gadget\R And *pMouse\Y > Gadget\Y And *pMouse\Y < Gadget\B
EndMacro












; IDE Options = PureBasic 5.62 (Windows - x86)
; CursorPosition = 130
; FirstLine = 103
; Folding = rAjn
; EnableXP
; Executable = DEMO.exe