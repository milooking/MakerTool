;*****************************************
;******** 单片机仿真模拟器内核引擎 ********
;********    迷路仟 2020.02.04    ********
;*****************************************
;【Engine_Canvas.pbi】 ;画布绘制及事件相关的源代码文件




;- [Constant]
#CanvasFlags$       = "Flags_CanvasID"
#Canvas_Error_4001$ = "CanvasID无效."
#Canvas_Error_4002$ = "CanvasID无效."

; 出错代码
Enumeration
   #Canvas_Error_None
   #Canvas_Error_4001 = 4001
   #Canvas_Error_4002
EndEnumeration

;- [Structure]
;[对象]公共信息结构
Structure __Canvas_BaseInfo
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


;[画布]选区信息,与__Object_BaseInfo一致
Structure __Canvas_Selection
   ObjectType.l
   X.f
   Y.f
   W.f
   H.f
   R.f
   B.f 
   OffsetX.f
   OffsetY.f
EndStructure

;画布主结构,作为接口输出为:CanvasID
Structure __Canvas_MainInfo Extends __Canvas_BaseInfo
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


;- [Include]
XIncludeFile "Engine_Module.pbi"  ;模块设置流文件相关的源代码文件
XIncludeFile "Engine_Design.pbi"  ;设计文档流文件相关的源代码文件
XIncludeFile "Engine_Object.pbi"  ;电子元件相关及画布辅助的源代码

Declare Canvas_Thumbnail(*pMainCanvas.__Canvas_MainInfo)

;-
;- ******** [MainCanvas] ******** 
;创建一个[画布]
Procedure Canvas_Create(*pMainDesign.__Design_MainInfo)
   If *pMainDesign = #Null : ProcedureReturn #Null : EndIf 
   *pMainCanvas.__Canvas_MainInfo = AllocateStructure(__Canvas_MainInfo)
   With *pMainCanvas
      \ObjectType     = #Object_Canvas
      \CanvasFlags$   = #CanvasFlags$
      \pMainDesign    = *pMainDesign
      \LayerZoom      = 0.5
      \CanvasW        = *pMainDesign\pMainModule\DesktopW   
      \CanvasH        = *pMainDesign\pMainModule\DesktopH     
      \FontColor      = $FF000000   
      \BackColor      = $FFFFFFFF  
      \FontSize       = 60 
      \FontStyle      = 0  
      \FontID         = LoadFont(#PB_Any, "微软雅黑", 16) 
      \LayerImageID   = CreateImage(#PB_Any, \CanvasW, \CanvasH, 32, #PB_Image_Transparent)     ;<--这里改为全屏幕尺寸,从而实现无限画布尺寸
      
   EndWith
   *pMainDesign\pMainCanvas    = *pMainCanvas
   *pMainDesign\pCallThumbnail = @Canvas_Thumbnail()
   Debug "[Design] Canvas_Create = 0x"+Hex(*pMainCanvas)+" : "+Str(*pMainCanvas\CanvasW)+"x"+Str(*pMainCanvas\CanvasH), #DebugLevel_Design
   ProcedureReturn *pMainCanvas
EndProcedure

;释放一个[画布]
Procedure Canvas_Release(*pMainCanvas.__Canvas_MainInfo)
   If *pMainCanvas = #Null : ProcedureReturn #Null : EndIf 
   If IsImage(*pMainCanvas\LayerImageID)  : FreeImage(*pMainCanvas\LayerImageID) : EndIf 
   If IsImage(*pMainCanvas\ExportImageID) : FreeImage(*pMainCanvas\ExportImageID) : EndIf 
   If IsFont(*pMainCanvas\FontID) : FreeFont(*pMainCanvas\FontID) : EndIf 
   *pMainCanvas\pMainDesign = #Null
   FreeStructure(*pMainCanvas)
   ProcedureReturn #True
EndProcedure



;-
;- ******** [Redraw] ******** 
;绘制[杜邦线]
Procedure Canvas_Redraw_ListDupont(*pMainDesign.__Design_MainInfo, *pListDupont.__Dupont_BaseInfo, Zoom.f, X.f, Y.f, R.f, B.f)
   With *pListDupont
      ;判断是否在当前显示区上
      If \R*Zoom > X Or \B*Zoom > Y And \X*Zoom < R Or \Y*Zoom < B 
         VectorSourceColor(\DupontColor)
         ;判断是否是[杜邦线][源引脚]编辑状态
         If \ObjectType = #Object_Dupont|#Object_Event_Origin
            MovePathCursor(\ModifyPos\X*Zoom-X, \ModifyPos\Y*Zoom-Y) ;设置路径起始点
         Else 
            MovePathCursor(\OriginPos\X*Zoom-X, \OriginPos\Y*Zoom-Y) ;设置路径起始点
         EndIf  
         
         ForEach \ListNodus()
            AddPathLine(\ListNodus()\X*Zoom-X, \ListNodus()\Y*Zoom-Y)
         Next 
         
         ;判断是否是[杜邦线][源引脚]编辑状态
         If \pTargetPin And \ObjectType = #Object_Dupont|#Object_Event_Target
            AddPathLine(\ModifyPos\X*Zoom-ScrollX, \ModifyPos\Y*Zoom-ScrollY) ;设置路径起始点
         ElseIf \pTargetPin And \ObjectType <> #Object_Active
            AddPathLine(\TargetPos\X*Zoom-X, \TargetPos\Y*Zoom-Y) ;设置路径起始点
         EndIf 
         
         StrokePath(#Module_DupontWidth*Zoom)
         
         ;绘制[杜邦线]上的[节点]
         If \ObjectType <> #Object_Dupont
            DupontColor = ~\DupontColor & $FFFFFF
            VectorSourceColor($FF000000|DupontColor)
            ForEach \ListNodus()
               If *pMainDesign\pCurrDuNode = \ListNodus()
                  AddPathCircle(\ListNodus()\X*Zoom-X, \ListNodus()\Y*Zoom-Y, #Module_DupontWidth*Zoom*1.5)
                  StrokePath(5)
               Else 
                  AddPathCircle(\ListNodus()\X*Zoom-X, \ListNodus()\Y*Zoom-Y, #Module_DupontWidth*Zoom)
                  FillPath()
               EndIf 
            Next 
         EndIf 
      EndIf 
   EndWith
EndProcedure

;绘制[元件]上的[引脚]和[杜邦线]
Procedure Canvas_Redraw_ListMatter(*pMainDesign.__Design_MainInfo, Zoom.f, X.f, Y.f, R.f, B.f, *pListMatter.__Matter_BaseInfo)
   With *pListMatter
      ;判断是否在当前显示区上
      If \R*Zoom > X Or \B*Zoom > Y And \X*Zoom < R Or \Y*Zoom < B 
         *pOriginPin = *pMainDesign\ActiveDupont\pOriginPin 
         *pTargetPin = *pMainDesign\ActiveDupont\pTargetPin
         ;绘制[引脚PIN]
         ForEach \ListPinPrefer()
            If \ListPinPrefer()\pOriginDupont Or \ListPinPrefer()\pTargetDupont Or *pOriginPin = \ListPinPrefer() Or *pTargetPin = \ListPinPrefer()
               ;如果[源引脚]存在,正在编辑状态下的[杜邦线]
               If *pOriginPin
                  *pListDupont = *pMainDesign\ActiveDupont
                  DupontColor = *pMainDesign\ActiveDupont\DupontColor
               EndIf 
               
               ;如果[源引脚]存在[杜邦线],即有完整的[杜邦线]存在
               If \ListPinPrefer()\pOriginDupont
                  *pListDupont = \ListPinPrefer()\pOriginDupont
                  DupontColor =  \ListPinPrefer()\pOriginDupont\DupontColor
               ElseIf \ListPinPrefer()\pTargetDupont
                  DupontColor =  \ListPinPrefer()\pTargetDupont\DupontColor
               EndIf

               ;绘制[杜邦线],在[引脚]之前
               If *pListDupont
                  Canvas_Redraw_ListDupont(*pMainDesign, *pListDupont, Zoom, X, Y, R, B)
               EndIf  
               
               ;绘制[引脚]
               If \ListPinPrefer()\pListPinParam\pGroupParam 
                  If \ListPinPrefer()\pOriginDupont Or \ListPinPrefer()\pTargetDupont
                     *pOrigin.__Module_PinParam = \ListPinPrefer()\pListPinParam
                     If *pOrigin\GroupType = #GroupType_Element Or *pOrigin\pListPinAttri\LinkModes = #LinkMode_Socket
                        StartX.f = \X+*pOrigin\OffsetX-#Module_DupontPitch/2
                        StartY.f = \Y+*pOrigin\OffsetY-#Module_DupontPitch/2
                        AddPathBox(StartX*Zoom-X, StartY*Zoom-Y, #Module_DupontPitch*Zoom, #Module_DupontPitch*Zoom)
                        VectorSourceColor(DupontColor)   ;连接状态 
                        FillPath()      
                     Else 
                        StartX.f = \X+*pOrigin\OffsetX
                        StartY.f = \Y+*pOrigin\OffsetY
                        MovePathCursor(StartX*Zoom-X, StartY*Zoom-Y)
                        
                        ToEndX.f = \X+*pOrigin\OffsetX+*pOrigin\OffsetW
                        ToEndY.f = \Y+*pOrigin\OffsetY+*pOrigin\OffsetH
                        
                        AddPathLine(ToEndX*Zoom-X, ToEndY*Zoom-Y)
                        VectorSourceColor($FF404040)   ;连接状态 
                        StrokePath(#Module_DupontPitch*Zoom)                      
                     EndIf 
                  Else 
                     *pOrigin.__Module_PinParam = \ListPinPrefer()\pListPinParam\pGroupParam
                     StartX.f = \X+*pOrigin\OffsetX
                     StartY.f = \Y+*pOrigin\OffsetY
                     MovePathCursor(StartX*Zoom-X, StartY*Zoom-Y)
                     
                     ToEndX.f = \X+*pOrigin\OffsetX+*pOrigin\OffsetW
                     ToEndY.f = \Y+*pOrigin\OffsetY+*pOrigin\OffsetH
                     AddPathLine(ToEndX*Zoom-X, ToEndY*Zoom-Y)
                     VectorSourceColor($80404040)   ;激活状态
                     StrokePath(#Module_DupontPitch*Zoom)                       
                  EndIf 
               Else 
                  *pOrigin.__Module_PinParam = \ListPinPrefer()\pListPinParam
                  If *pOrigin\GroupType = #GroupType_Element Or *pOrigin\pListPinAttri\LinkModes = #LinkMode_Socket
                     StartX.f = \X+*pOrigin\OffsetX-#Module_DupontPitch/2
                     StartY.f = \Y+*pOrigin\OffsetY-#Module_DupontPitch/2
                     AddPathBox(StartX*Zoom-X, StartY*Zoom-Y, #Module_DupontPitch*Zoom, #Module_DupontPitch*Zoom)
                     VectorSourceColor(DupontColor)   ;连接状态 
                     FillPath()      
                  Else 
                     StartX.f = \X+*pOrigin\OffsetX
                     StartY.f = \Y+*pOrigin\OffsetY
                     MovePathCursor(StartX*Zoom-X, StartY*Zoom-Y)
                     
                     ToEndX.f = \X+*pOrigin\OffsetX+*pOrigin\OffsetW
                     ToEndY.f = \Y+*pOrigin\OffsetY+*pOrigin\OffsetH
                     
                     AddPathLine(ToEndX*Zoom-X, ToEndY*Zoom-Y)
                     VectorSourceColor($FF404040)   ;连接状态 
                     StrokePath(#Module_DupontPitch*Zoom)                      
                  EndIf   
               EndIf 
       
            EndIf 
         Next         
      EndIf
   EndWith 
EndProcedure

;绘制[对象组]
Procedure Canvas_Redraw_ListGroups(*pMainDesign.__Design_MainInfo, Zoom.f, X.f, Y.f, R.f, B.f, *pListObject.__Object_BaseInfo)
   Select *pListObject\ObjectType & $FF
      Case #Object_Matter 
         Canvas_Redraw_ListMatter(*pMainDesign, Zoom, X, Y, R, B, *pListObject)

      Case #Object_Groups
         *pListGroups.__Groups_BaseInfo = *pListObject
         ForEach *pListGroups\pListObject()
            Canvas_Redraw_ListGroups(*pMainDesign, Zoom, X, Y, R, B, *pListGroups\pListObject())
         Next 
   EndSelect
EndProcedure


Procedure Canvas_Redraw_ListObject(*pMainDesign.__Design_MainInfo, Zoom.f, X.f, Y.f, R.f, B.f, *pListObject.__Object_BaseInfo)
   Select *pListObject\ObjectType & $FF
      Case #Object_Matter
         *pListMatter.__Matter_BaseInfo = *pListObject
         With *pListMatter
            ;判断是否在当前显示区上
            If \R*Zoom > X Or \B*Zoom > Y And \X*Zoom < R Or \Y*Zoom < B 
               ;绘制[电子元件]      
               MovePathCursor(\X*Zoom-X, \Y*Zoom-Y)
               If IsImage(\pDimImage\ImageID)
                  DrawVectorImage(ImageID(\pDimImage\ImageID), 255, \pDimImage\ImageW*Zoom, \pDimImage\ImageH*Zoom) 
               EndIf        
            EndIf
         EndWith 
         
      Case #Object_String
         *pListString.__String_BaseInfo = *pListObject
         With *pListString
            ;判断是否在当前显示区上
            If \R*Zoom > X Or \B*Zoom > Y And \X*Zoom < R Or \Y*Zoom < B 
               VectorFont(FontID(*pMainDesign\pMainCanvas\FontID), \FontSize* Zoom)
               VectorSourceColor(\FontColor|$FF000000)
               MovePathCursor((\X+10)*Zoom-X, (\Y+0)*Zoom-Y)
               \W = (VectorTextWidth (\Text$))/Zoom+20
               \H = (VectorTextHeight(\Text$))/Zoom+10       
               \R = \X+\W
               \B = \Y+\H
               DrawVectorParagraph(\Text$, \W*2+100, \H*2+100)
            EndIf 
         EndWith
         
      Case #Object_Groups
         *pListGroups.__Groups_BaseInfo = *pListObject
         ForEach *pListGroups\pListObject()
            Canvas_Redraw_ListObject(*pMainDesign, Zoom, X, Y, R, B, *pListGroups\pListObject())
         Next 
   EndSelect
EndProcedure


Procedure Canvas_Redraw_CurrObject(*pMainDesign.__Design_MainInfo, Zoom.f, X.f, Y.f, R.f, B.f)
   If *pMainDesign\pCurrObject = #Null : ProcedureReturn : EndIf 
   Select *pMainDesign\pCurrObject\ObjectType & $FF
      Case #Object_Canvas : LineColor = $FF808080 : Active = #True
      Case #Object_Active : LineColor = $FFFF00FF : Active = #True
      Case #Object_Matter : LineColor = $FF0000FF : Active = #True
      Case #Object_String : LineColor = $FF0000FF : Active = #True
      Case #Object_Groups : LineColor = $FFFF0000 : Active = #True
      Default : ProcedureReturn    
   EndSelect

   With *pMainDesign\pCurrObject
      CanvasX.f = \X*Zoom : CanvasW.f =\W*Zoom : CanvasY.f = \Y*Zoom : CanvasH.f = \H*Zoom
      ;判断是否在当前显示区上
      If CanvasX+W > X Or CanvasY+CanvasH > Y Or CanvasX < R Or CanvasY < B 
         AddPathBox(CanvasX-X, CanvasY-Y, CanvasW, CanvasH)
         VectorSourceColor(LineColor)
         DashPath(2, 5)
      EndIf 
   EndWith

EndProcedure

Procedure Canvas_Redraw_Selection(*pMainDesign.__Design_MainInfo, Zoom.f, X.f, Y.f, R.f, B.f, *pMainCanvas.__Canvas_MainInfo)
   
   If *pMainDesign\HorizAlign
      VectorSourceColor($FFF0F030)
      MovePathCursor(00, *pMainDesign\HorizAlign*Zoom-Y)  
      AddPathLine(R-X, *pMainDesign\HorizAlign*Zoom-Y) 
      StrokePath(1.8)
   EndIf 

   If *pMainDesign\VertiAlign
      VectorSourceColor($FFF0F030)
      MovePathCursor(*pMainDesign\VertiAlign*Zoom-X, 00)  
      AddPathLine(*pMainDesign\VertiAlign*Zoom-X, B-Y) 
      StrokePath(1.8) 
   EndIf   
   
   If *pMainCanvas\pSelection
      With *pMainCanvas\pSelection
         CanvasX.f = \X*Zoom : CanvasW.f =\W*Zoom : CanvasY.f = \Y*Zoom : CanvasH.f = \H*Zoom
         ;判断是否在当前显示区上
         If CanvasX+CanvasW > X Or CanvasY+CanvasH > Y Or CanvasX < R Or CanvasY < B 
            AddPathBox(CanvasX-X, CanvasY-Y, CanvasW, CanvasH)
            VectorSourceColor($FF808080)
            DashPath(1, 3)
         EndIf 
      EndWith  
   EndIf 
   
   If *pMainDesign\pCurrDupont 
      Select *pMainDesign\pCurrDupont\ObjectType & #Object_Event
         Case #Object_Event_Active
            ;绘制光标位置,以示[杜邦线]编辑状态
            With *pMainDesign\pMainCanvas
               AddPathCircle (\X*Zoom-X, \Y*Zoom-Y, #Module_DupontWidth*Zoom) 
               VectorSourceColor($FF0000F0)
            EndWith
            StrokePath(3) 
         Case #Object_Event_Origin
            Canvas_Redraw_ListDupont(*pMainDesign, *pMainDesign\pCurrDupont, Zoom, X, Y, R, B)
         Case #Object_Event_Target
            Canvas_Redraw_ListDupont(*pMainDesign, *pMainDesign\pCurrDupont, Zoom, X, Y, R, B) 
      EndSelect 
   EndIf 
   
;    If *pMainDesign\pPinAttri
;       Text$ = *pMainDesign\pPinAttri\PinsLabel$
;       VectorSourceColor($FF000000)
;       ToolTipX = *pMainDesign\ToolTipX*Zoom + 15
;       ToolTipY = *pMainDesign\ToolTipY*Zoom + 15
;       MovePathCursor(ToolTipX, ToolTipY)
;       W = VectorTextWidth(Text$)
;       H = VectorTextHeight(Text$)
;       DrawVectorParagraph(Text$, W*2, H*2)
;    EndIf 
EndProcedure

Procedure Canvas_Redraw_DisplayGrid(*pMainCanvas.__Canvas_MainInfo, *pMainDesign.__Design_MainInfo, Zoom.f, CanvasW, CanvasH)
   If *pMainDesign\pMainModule\IsDisplayGrid
      With *pMainCanvas
         Align = #Object_Event_Align * Zoom
         
         Weight = Zoom*2000
         If Weight <= 125
            Align * 8
         ElseIf Weight <= 250
            Align * 4
         ElseIf Weight <= 750
            Align * 2            
         EndIf 

         GridX = \ScrollX
         GridX = GridX/Align * Align
         GridX - \ScrollX
         VectorSourceColor($80808080)
         While GridX <= CanvasW
            MovePathCursor(GridX, 00)  
            AddPathLine(GridX, CanvasH)
            GridX+Align
         Wend
         StrokePath(1) 
         
         
         GridY = \ScrollY
         GridY = GridY/Align * Align
         GridY -\ScrollY
         VectorSourceColor($80808080)
         While GridY <= CanvasH
            MovePathCursor(00, GridY)  
            AddPathLine(CanvasW, GridY)
            GridY+Align
         Wend      
         StrokePath(1) 
         
      EndWith
   EndIf 
EndProcedure

;绘制[画布]
Procedure Canvas_RedrawScreen(*pMainCanvas.__Canvas_MainInfo, CanvasW, CanvasH)
   
   With *pMainCanvas
      If StartDrawing(ImageOutput(\LayerImageID))
         DrawingMode(#PB_2DDrawing_AllChannels)
         Box(0, 0, CanvasW, CanvasH, $00FFFFFF)
         StopDrawing()
      EndIf
      If StartVectorDrawing(ImageVectorOutput(\LayerImageID))
         \CanvasR = \ScrollX + CanvasW
         \CanvasB = \ScrollY + CanvasH
         
         *pMainDesign.__Design_MainInfo = \pMainDesign
         Canvas_Redraw_DisplayGrid(*pMainCanvas, *pMainDesign, \LayerZoom, CanvasW, CanvasH)
         ForEach *pMainDesign\pListObject()
            Canvas_Redraw_ListObject(*pMainDesign, \LayerZoom, \ScrollX, \ScrollY, \CanvasR, \CanvasB, *pMainDesign\pListObject())
         Next 
         ForEach *pMainDesign\pListObject()
            Canvas_Redraw_ListGroups(*pMainDesign, \LayerZoom, \ScrollX, \ScrollY, \CanvasR, \CanvasB, *pMainDesign\pListObject())
         Next          
         Canvas_Redraw_CurrObject(*pMainDesign, \LayerZoom, \ScrollX, \ScrollY, \CanvasR, \CanvasB)
         Canvas_Redraw_Selection (*pMainDesign, \LayerZoom, \ScrollX, \ScrollY, \CanvasR, \CanvasB, *pMainCanvas)
         StopVectorDrawing()
      EndIf
      GrabImage(\LayerImageID, \ExportImageID, 0, 0, CanvasW, CanvasH)
      ProcedureReturn ImageID(\ExportImageID)
   EndWith
EndProcedure


;-
;- ******** [Screenshot] ******** 

Procedure Canvas_Screenshot_ListObject(*pMainCanvas.__Canvas_MainInfo, *pMainDesign.__Design_MainInfo)
   ForEach *pMainDesign\pListObject()
      *pListObject.__Object_BaseInfo = *pMainDesign\pListObject()
      Select *pListObject\ObjectType & $FF
         Case #Object_Matter
            *pListMatter.__Matter_BaseInfo = *pListObject
            With *pListMatter
               If *pMainCanvas\ScreenshotX > \X  : *pMainCanvas\ScreenshotX = \X: EndIf 
               If *pMainCanvas\ScreenshotY > \Y  : *pMainCanvas\ScreenshotY = \Y: EndIf 
               If *pMainCanvas\ScreenshotR < \R  : *pMainCanvas\ScreenshotR = \R: EndIf 
               If *pMainCanvas\ScreenshotB < \B  : *pMainCanvas\ScreenshotB = \B: EndIf 
            EndWith 
            
         Case #Object_String
            *pListString.__String_BaseInfo = *pListObject
            With *pListString
               If *pMainCanvas\ScreenshotX > \X  : *pMainCanvas\ScreenshotX = \X: EndIf 
               If *pMainCanvas\ScreenshotY > \Y  : *pMainCanvas\ScreenshotY = \Y: EndIf 
               If *pMainCanvas\ScreenshotR < \R  : *pMainCanvas\ScreenshotR = \R: EndIf 
               If *pMainCanvas\ScreenshotB < \B  : *pMainCanvas\ScreenshotB = \B: EndIf 
            EndWith
            
         Case #Object_Groups
            *pListGroups.__Groups_BaseInfo = *pListObject
            With *pListGroups
               If *pMainCanvas\ScreenshotX > \X  : *pMainCanvas\ScreenshotX = \X: EndIf 
               If *pMainCanvas\ScreenshotY > \Y  : *pMainCanvas\ScreenshotY = \Y: EndIf 
               If *pMainCanvas\ScreenshotR < \R  : *pMainCanvas\ScreenshotR = \R: EndIf 
               If *pMainCanvas\ScreenshotB < \B  : *pMainCanvas\ScreenshotB = \B: EndIf         
            EndWith
      EndSelect
   Next 
   
   ForEach *pMainDesign\ListDupont()
      *pListDupont.__Dupont_BaseInfo = *pMainDesign\ListDupont()
      ForEach *pListDupont\ListNodus()
         With *pListDupont\ListNodus()
            If *pMainCanvas\ScreenshotX > \X  : *pMainCanvas\ScreenshotX = \X: EndIf 
            If *pMainCanvas\ScreenshotY > \Y  : *pMainCanvas\ScreenshotY = \Y: EndIf 
            If *pMainCanvas\ScreenshotR < \X  : *pMainCanvas\ScreenshotR = \X: EndIf 
            If *pMainCanvas\ScreenshotB < \Y  : *pMainCanvas\ScreenshotB = \Y: EndIf         
         EndWith
      Next 
   Next  
EndProcedure


Procedure Canvas_Screenshot(*pMainCanvas.__Canvas_MainInfo, FileName$)
   With *pMainCanvas
      ScrollX.f = \ScrollX
      ScrollY.f = \ScrollY
      *pMainDesign.__Design_MainInfo = \pMainDesign
      ;统计一下画布内容占用的尺寸
      If ListSize(*pMainDesign\pListObject()) = 0
         CanvasW = 100
         CanvasH = 100
      Else  
         *pMainCanvas\ScreenshotX = 0999999
         *pMainCanvas\ScreenshotY = 0999999
         *pMainCanvas\ScreenshotR = -999999 
         *pMainCanvas\ScreenshotB = -999999
         Canvas_Screenshot_ListObject(*pMainCanvas, *pMainDesign)
         \ScrollX = *pMainCanvas\ScreenshotX * \LayerZoom - 50
         \ScrollY = *pMainCanvas\ScreenshotY * \LayerZoom - 50
         \CanvasR = *pMainCanvas\ScreenshotR * \LayerZoom + 50
         \CanvasB = *pMainCanvas\ScreenshotB * \LayerZoom + 50
         CanvasW = \CanvasR-\ScrollX
         CanvasH = \CanvasB-\ScrollY
      EndIf 

      ScreenshotID = CreateImage(#PB_Any, CanvasW, CanvasH, 32,  #PB_Image_Transparent)  
      If StartDrawing(ImageOutput(ScreenshotID))
         DrawingMode(#PB_2DDrawing_AllChannels)
         Box(0, 0, CanvasW, CanvasH, $00FFFFFF)
         StopDrawing()
      EndIf
      If StartVectorDrawing(ImageVectorOutput(ScreenshotID))
         ForEach *pMainDesign\pListObject()
            Canvas_Redraw_ListObject(*pMainDesign, \LayerZoom, \ScrollX, \ScrollY, \CanvasR, \CanvasB, *pMainDesign\pListObject())
         Next 
         ForEach *pMainDesign\pListObject()
            Canvas_Redraw_ListGroups(*pMainDesign, \LayerZoom, \ScrollX, \ScrollY, \CanvasR, \CanvasB, *pMainDesign\pListObject())
         Next  
;          Canvas_Redraw_CurrObject(*pMainDesign, \LayerZoom, \ScrollX, \ScrollY, \CanvasR, \CanvasB)
         StopVectorDrawing()
         \ScrollX = ScrollX
         \ScrollY = ScrollY
      EndIf
      Result = SaveImage(ScreenshotID, FileName$, #PB_ImagePlugin_PNG)
      FreeImage(ScreenshotID)
      ProcedureReturn Result
   EndWith
EndProcedure

Procedure Canvas_Thumbnail(*pMainCanvas.__Canvas_MainInfo)
   With *pMainCanvas
      ScrollX.f = \ScrollX
      ScrollY.f = \ScrollY
      *pMainDesign.__Design_MainInfo = \pMainDesign
      ;统计一下画布内容占用的尺寸
      If ListSize(*pMainDesign\pListObject()) = 0
         CanvasW = 100
         CanvasH = 100
      Else  
         *pMainCanvas\ScreenshotX = 0999999
         *pMainCanvas\ScreenshotY = 0999999
         *pMainCanvas\ScreenshotR = -999999 
         *pMainCanvas\ScreenshotB = -999999
         Canvas_Screenshot_ListObject(*pMainCanvas, *pMainDesign)
         \ScrollX = *pMainCanvas\ScreenshotX * \LayerZoom - 50
         \ScrollY = *pMainCanvas\ScreenshotY * \LayerZoom - 50
         \CanvasR = *pMainCanvas\ScreenshotR * \LayerZoom + 50
         \CanvasB = *pMainCanvas\ScreenshotB * \LayerZoom + 50
         CanvasW = \CanvasR-\ScrollX
         CanvasH = \CanvasB-\ScrollY
      EndIf 

      ScreenshotID = CreateImage(#PB_Any, CanvasW, CanvasH, 32,  #PB_Image_Transparent)  
      If StartDrawing(ImageOutput(ScreenshotID))
         DrawingMode(#PB_2DDrawing_AllChannels)
         Box(0, 0, CanvasW, CanvasH, $00FFFFFF)
         StopDrawing()
      EndIf
      If StartVectorDrawing(ImageVectorOutput(ScreenshotID))
         ForEach *pMainDesign\pListObject()
            Canvas_Redraw_ListObject(*pMainDesign, \LayerZoom, \ScrollX, \ScrollY, \CanvasR, \CanvasB, *pMainDesign\pListObject())
         Next 
         ForEach *pMainDesign\pListObject()
            Canvas_Redraw_ListGroups(*pMainDesign, \LayerZoom, \ScrollX, \ScrollY, \CanvasR, \CanvasB, *pMainDesign\pListObject())
         Next  
         StopVectorDrawing()
         \ScrollX = ScrollX
         \ScrollY = ScrollY
      EndIf
      If CanvasW >= CanvasH 
         Sale.f = 256 / CanvasW
         ImageW = CanvasW * Sale
         ImageH = CanvasH * Sale
      Else 
         Sale.f = 256 / CanvasH
         ImageW = CanvasW * Sale 
         ImageH = CanvasH * Sale    
      EndIf 
      ResizeImage(ScreenshotID, ImageW, ImageH)  
      *pMemImage = EncodeImage(ScreenshotID, #PB_ImagePlugin_PNG)
      FreeImage(ScreenshotID)
      ProcedureReturn *pMemImage
   EndWith
EndProcedure


;-
;- ******** [MouseEvent] ******** 

Procedure Canvas_Event_LeftButtonDown_Alt(*pMainCanvas.__Canvas_MainInfo, X.f, Y.f)
   *pMainDesign.__Design_MainInfo = *pMainCanvas\pMainDesign
   If *pMainDesign\pCurrObject And *pMainDesign\pCurrDupont
      Select *pMainDesign\pCurrDupont\ObjectType & #Object_Event
         Case #Object_Event_Modify : NeedRefresh = Dupont_Nodus_Delete(*pMainDesign, X, Y)
      EndSelect  
      ProcedureReturn NeedRefresh
   EndIf 
EndProcedure
   
   
Procedure Canvas_Event_LeftButtonDown_Ctrl(*pMainCanvas.__Canvas_MainInfo, X.f, Y.f)
   *pMainDesign.__Design_MainInfo = *pMainCanvas\pMainDesign
   
   If *pMainDesign\pCurrObject And *pMainDesign\pCurrDupont
      Select *pMainDesign\pCurrDupont\ObjectType & #Object_Event
         Case #Object_Event_Modify : NeedRefresh = Dupont_Nodus_Insert(*pMainDesign, X, Y)
      EndSelect  
      ProcedureReturn NeedRefresh
   EndIf 
   
   
   If *pMainDesign\pCurrObject
      ;判断是否点击在同一个活动对象组中的对象,则视为去除它
      With *pMainDesign\pCurrObject
         If \X <= X And X <=\R And \Y < Y And Y <\B
            NeedRefresh = Object_Selection_Sub(*pMainDesign, X, Y)
            If NeedRefresh : ProcedureReturn #True : EndIf 
         EndIf 
      EndWith
      
      ForEach *pMainDesign\pListObject()
         With *pMainDesign\pListObject()
            If \X <= X And X <=\R And \Y < Y And Y <\B
               *pObject = *pMainDesign\pListObject()
            EndIf 
         EndWith
      Next 
      If *pObject
         Object_Selection_Add(*pMainDesign, *pObject)
         ProcedureReturn #True
      EndIf 
      
   Else 
      ForEach *pMainDesign\pListObject()
         With *pMainDesign\pListObject()
            If \X <= X And X <=\R And \Y < Y And Y <\B
               *pMainDesign\pCurrObject = *pMainDesign\pListObject()
               \OffsetX = X-\X : \OffsetY = Y-\Y : \ObjectType|#Object_Event_Active
               ProcedureReturn #True
            EndIf 
         EndWith
      Next 
      ;定义画布选择区起点
      With *pMainCanvas
         \X = X : \Y = Y : \W = 0 : \H = 0 : \pSelection = *pMainCanvas
      EndWith  
   EndIf 
EndProcedure



Procedure Canvas_Event_LeftButtonDown_Null(*pMainCanvas.__Canvas_MainInfo, X.f, Y.f)
   *pMainDesign.__Design_MainInfo = *pMainCanvas\pMainDesign

   ;*pMainDesign\pCurrDupont不为空时,进入[杜邦线]创建或修改模式
   If *pMainDesign\pCurrObject And *pMainDesign\pCurrDupont
      Select *pMainDesign\pCurrDupont\ObjectType & #Object_Event
         Case #Object_Event_Active                                      ;初创状态
            NeedRefresh = Dupont_DuNode_Create(*pMainDesign, X, Y)      ;添加[杜邦线][节点]自带新建[杜邦线]代码
         Case #Object_Event_Modify, #Object_Event_DuNode
            NeedRefresh = Dupont_Modify_Active(*pMainDesign, X, Y)      ;激活修改目标
         Case #Object_Event_Origin                                     
         Case #Object_Event_Target                                   
      EndSelect    
      ProcedureReturn NeedRefresh
   EndIf 
   
   If *pMainDesign\pCurrObject
      ;判断是否点击在同一个活动对象中
      With *pMainDesign\pCurrObject
         If \X <= X And X <=\R And \Y < Y And Y <\B
            \OffsetX = X-\X : \OffsetY = Y-\Y : \ObjectType|#Object_Event_Active
            Debug "[Object_Select] 再次点中[活动对象] ", #DebugLevel_Object_Select
            ProcedureReturn #False
         EndIf 
      EndWith
      
      ;光标处没有点击的对象,视为取消
      Object_Selection_Cancel(*pMainDesign)
      
      ;搜索点中的对象.
      ForEach *pMainDesign\pListObject()
         With *pMainDesign\pListObject()
            If \X <= X And X <=\R And \Y < Y And Y <\B
               *pMainDesign\pCurrObject = *pMainDesign\pListObject()
               \OffsetX = X-\X : \OffsetY = Y-\Y : \ObjectType|#Object_Event_Active
               Debug "[Object_Select] 重新选中[活动对象] ****** ", #DebugLevel_Object_Select
               ProcedureReturn #True
            EndIf 
         EndWith
      Next  

      ;定义画布选择区起点
      With *pMainCanvas
         \X = X : \Y = Y : \W = 0 : \H = 0 : \pSelection = *pMainCanvas
         Debug "[Object_Select] 释放[活动对象] <<<<<<<< ", #DebugLevel_Object_Select
      EndWith     
      ProcedureReturn #True
   Else 
      ForEach *pMainDesign\pListObject()
         With *pMainDesign\pListObject()
            If \X <= X And X <=\R And \Y < Y And Y <\B
               *pMainDesign\pCurrObject = *pMainDesign\pListObject()
               \OffsetX = X-\X : \OffsetY = Y-\Y : \ObjectType|#Object_Event_Active
               Debug "[Object_Select] 新 选 中[活动对象] ...... ", #DebugLevel_Object_Select
               ProcedureReturn #True
            EndIf 
         EndWith
      Next 
      
      ;定义画布选择区起点
      With *pMainCanvas
         \X = X : \Y = Y : \W = 0 : \H = 0 : \pSelection = *pMainCanvas
      EndWith       
   EndIf 
EndProcedure

;左键按下事件
Procedure Canvas_Event_LeftButtonDown(*pMainCanvas.__Canvas_MainInfo, CanvasX, CanvasY, Modifiers)
   X.f = (CanvasX + *pMainCanvas\ScrollX) / *pMainCanvas\LayerZoom
   Y.f = (CanvasY + *pMainCanvas\ScrollY) / *pMainCanvas\LayerZoom
   *pMainDesign.__Design_MainInfo = *pMainCanvas\pMainDesign
   Select Modifiers
      Case #PB_Canvas_Alt     : NeedRefresh = Canvas_Event_LeftButtonDown_Alt (*pMainCanvas, X, Y)
      Case #PB_Canvas_Control : NeedRefresh = Canvas_Event_LeftButtonDown_Ctrl(*pMainCanvas, X, Y)
      Default                 : NeedRefresh = Canvas_Event_LeftButtonDown_Null(*pMainCanvas, X, Y)
   EndSelect
   If NeedRefresh = #True : *pMainDesign\IsModify = #True : EndIf 
   ProcedureReturn NeedRefresh
EndProcedure

;-
Procedure Canvas_Event_LeftButtonUp_Ctrl(*pMainCanvas.__Canvas_MainInfo, X.f, Y.f)
   *pMainDesign.__Design_MainInfo = *pMainCanvas\pMainDesign
EndProcedure

Procedure Canvas_Event_LeftButtonUp_Null(*pMainCanvas.__Canvas_MainInfo, X.f, Y.f)
   *pMainDesign.__Design_MainInfo = *pMainCanvas\pMainDesign
   If *pMainDesign\pCurrObject And *pMainDesign\pCurrDupont
      Select *pMainDesign\pCurrDupont\ObjectType & #Object_Event
         Case #Object_Event_Create
            *pMainDesign\pCurrDupont\ObjectType = #Object_Dupont
            *pMainDesign\pCurrDupont = #Null
            NeedRefresh = #True
            Debug "[Dupont_Create] 完成创建[杜邦线] ************ ", #DebugLevel_Dupont_Create 
         Case #Object_Event_Active : 
         Case #Object_Event_DuNode : NeedRefresh = Dupont_Change_DuNode(*pMainDesign)
         Case #Object_Event_Origin : NeedRefresh = Dupont_Change_Origin(*pMainDesign)
         Case #Object_Event_Target : NeedRefresh = Dupont_Change_Target(*pMainDesign)
      EndSelect  
      ProcedureReturn NeedRefresh
   EndIf 

   If *pMainDesign\pCurrObject
      ProcedureReturn Object_Selection_Change(*pMainDesign)
   EndIf 
   
   If *pMainCanvas\pSelection 
      Object_Selection_Search(*pMainDesign, X, Y)
      *pMainCanvas\pSelection = #Null
      ProcedureReturn #True
   EndIf 
   ProcedureReturn NeedRefresh
EndProcedure

;左键释放事件
Procedure Canvas_Event_LeftButtonUp(*pMainCanvas.__Canvas_MainInfo, CanvasX, CanvasY, Modifiers)
   X.f = (CanvasX + *pMainCanvas\ScrollX) / *pMainCanvas\LayerZoom
   Y.f = (CanvasY + *pMainCanvas\ScrollY) / *pMainCanvas\LayerZoom
   *pMainDesign.__Design_MainInfo = *pMainCanvas\pMainDesign
   
   Select Modifiers
      Case #PB_Canvas_Alt     : NeedRefresh = Canvas_Event_LeftButtonUp_Ctrl(*pMainCanvas, X, Y)
      Case #PB_Canvas_Control
      Default                 : NeedRefresh = Canvas_Event_LeftButtonUp_Null(*pMainCanvas, X, Y)
   EndSelect
   If NeedRefresh = #True :*pMainDesign\IsModify = #True : EndIf 
   ProcedureReturn NeedRefresh
EndProcedure

;-
;右键双击事件
Procedure Canvas_Event_LeftDoubleClick(*pMainCanvas.__Canvas_MainInfo, CanvasX, CanvasY)
   X.f = (CanvasX + *pMainCanvas\ScrollX) / *pMainCanvas\LayerZoom
   Y.f = (CanvasY + *pMainCanvas\ScrollY) / *pMainCanvas\LayerZoom
   *pMainDesign.__Design_MainInfo = *pMainCanvas\pMainDesign
   
   ;判断当前[杜邦线]是否存在,如果是,则进入[编辑模式],如果不存在,则进入[创建模式]
   If *pMainDesign\pCurrObject
      If *pMainDesign\pCurrDupont
         *pMainDesign\pCurrDupont\ObjectType = #Object_Dupont
         *pMainDesign\pCurrDupont = #Null
         NeedRefresh = #True
      EndIf 
      NeedRefresh + Dupont_Active_Inital(*pMainDesign, *pMainDesign\pCurrObject, X, Y)
      If *pMainDesign\pCurrObject\ObjectType & $FF= #Object_String 
         *pCallAddString = *pMainDesign\pMainModule\pCallAddString
         If *pCallAddString
            *pListString.__String_BaseInfo = *pMainDesign\pCurrObject
            With *pListString
               Zoom.f = *pMainCanvas\LayerZoom
               Object.__MCT_ObjectInfo
               Object\X     = \X*Zoom
               Object\Y     = \Y*Zoom
               Object\W     = \W*Zoom
               Object\H     = \H*Zoom
               Object\Text$ = \Text$
               Object\FontSize  = \FontSize
               Object\FontColor = \FontColor
               Result = CallFunctionFast(*pCallAddString, @Object, #True)
               If Result
                  *pMainDesign\pCurrObject = *pListString   
                  *pListString\FontColor   = Object\FontColor
                  *pListString\FontSize    = Object\FontSize
                  *pListString\X = Object\X/Zoom
                  *pListString\Y = Object\Y/Zoom
                  *pListString\R = Object\X/Zoom+*pListString\W
                  *pListString\B = Object\Y/Zoom+*pListString\H
                  NeedRefresh = #True
               EndIf 
            EndWith
         EndIf 
      EndIf 
      *pMainCanvas\X = X
      *pMainCanvas\Y = Y
   EndIf 
   ProcedureReturn NeedRefresh
EndProcedure

;-
;右键按下事件
Procedure Canvas_Event_RightButtonDown(*pMainCanvas.__Canvas_MainInfo, CanvasX, CanvasY, Modifiers)
   X.f = (CanvasX + *pMainCanvas\ScrollX) / *pMainCanvas\LayerZoom
   Y.f = (CanvasY + *pMainCanvas\ScrollY) / *pMainCanvas\LayerZoom
   *pMainDesign.__Design_MainInfo = *pMainCanvas\pMainDesign
   ;定义画布选择区起点
   With *pMainCanvas
      \X = X
      \Y = Y
      \W = 0
      \H = 0
      \pSelection = *pMainCanvas
   EndWith
   ProcedureReturn NeedRefresh
EndProcedure

;右键释放事件
Procedure Canvas_Event_RightButtonUp(*pMainCanvas.__Canvas_MainInfo, CanvasX, CanvasY, Modifiers)
   X.f = (CanvasX + *pMainCanvas\ScrollX) / *pMainCanvas\LayerZoom
   Y.f = (CanvasY + *pMainCanvas\ScrollY) / *pMainCanvas\LayerZoom
   *pMainDesign.__Design_MainInfo = *pMainCanvas\pMainDesign
   With *pMainDesign
      If \pCurrDupont
         NeedRefresh = Dupont_Active_Delete(*pMainDesign, X, Y)   ;右键点击在引脚上,表示删除[杜邦线]
         If NeedRefresh : ProcedureReturn #True : EndIf 
         Dupont_Active_Cancel(*pMainDesign)                       ;退出[编辑模式]
         ProcedureReturn #True
      EndIf 
      *pCallRightClick = \pMainModule\pCallRightClick
      If *pCallRightClick
         If \pCurrObject
            If \pCurrObject\X <= X And X <=\pCurrObject\R And \pCurrObject\Y < Y And Y <\pCurrObject\B
;                Debug "ObjectType = 0x" + Hex(\pCurrObject\ObjectType)
               Select \pCurrObject\ObjectType & $FF
                  Case #Object_Matter : CallFunctionFast(*pCallRightClick, *pMainDesign, #Object_Matter, \pCurrObject)
                  Case #Object_String : CallFunctionFast(*pCallRightClick, *pMainDesign, #Object_String, \pCurrObject)
                  Case #Object_Groups : CallFunctionFast(*pCallRightClick, *pMainDesign, #Object_Groups, \pCurrObject)
                  Case #Object_Active : CallFunctionFast(*pCallRightClick, *pMainDesign, #Object_Active, \pCurrObject) 
               EndSelect
            EndIf 
         EndIf 
      EndIf 
      \pCurrModule = #Null
      If *pMainCanvas\pSelection 
         *pMainCanvas\pSelection = #Null
         NeedRefresh = #True
      EndIf 
   EndWith
   ProcedureReturn NeedRefresh
EndProcedure
   
;右键双击事件
Procedure Canvas_Event_RightDoubleClick(*pMainCanvas.__Canvas_MainInfo, CanvasX, CanvasY)
   X.f = (CanvasX + *pMainCanvas\ScrollX) / *pMainCanvas\LayerZoom
   Y.f = (CanvasY + *pMainCanvas\ScrollY) / *pMainCanvas\LayerZoom
   *pMainDesign.__Design_MainInfo = *pMainCanvas\pMainDesign
   ProcedureReturn NeedRefresh
EndProcedure

;-
Procedure Canvas_Event_MouseMove_Left(*pMainCanvas.__Canvas_MainInfo, X.f, Y.f)
   *pMainDesign.__Design_MainInfo = *pMainCanvas\pMainDesign
   
   ;*pMainDesign\pCurrDupont不为空时,进入[杜邦线]创建或修改模式
   If *pMainDesign\pCurrObject And *pMainDesign\pCurrDupont
      Select *pMainDesign\pCurrDupont\ObjectType & #Object_Event
         Case #Object_Event_DuNode : NeedRefresh = Dupont_Modify_DuNode(*pMainDesign, X, Y, #True)
         Case #Object_Event_Origin : NeedRefresh = Dupont_Modify_Origin(*pMainDesign, X, Y)
         Case #Object_Event_Target : NeedRefresh = Dupont_Modify_Target(*pMainDesign, X, Y)
      EndSelect  
      If NeedRefresh = #True :*pMainDesign\IsModify = #True : EndIf 
      ProcedureReturn NeedRefresh
   EndIf 
   
   
   ;[对象]移动模式
   If *pMainDesign\pCurrObject
      With *pMainDesign\pCurrObject
         ;防止点击[对象]的小移动
         Select \ObjectType & #Object_Event
            Case #Object_Event_Active
               If Abs(\X-X+\OffsetX) > #Object_Event_Range Or Abs(\Y-Y+\OffsetY) > #Object_Event_Range
                  Debug "[Object_Select] 模式: [Active] ==> [Moving]", #DebugLevel_Object_Select  
                  Debug "[Object_Moving] 模式: [Active] ==> [Moving]", #DebugLevel_Object_Moving  
                  \ObjectType & ~#Object_Event_Active 
                  \ObjectType | #Object_Event_Moving
                  X = \X+\OffsetX : Y = \Y+\OffsetY
                  Object_Selection_Active(*pMainDesign, *pMainDesign\pCurrObject, X, Y)
                  Dupont_Selection_Active(*pMainDesign, X, Y)
                  *pMainDesign\IsModify = #True
               EndIf 
               ProcedureReturn #True
               
            Case #Object_Event_Moving
               Object_Selection_Moving(*pMainDesign\pCurrObject, X, Y)
               Dupont_Selection_Moving(*pMainDesign, X, Y)
               If Int(\X) % #Object_Event_Align < 10 : VertiAlign = Int(\X)/#Object_Event_Align*#Object_Event_Align : EndIf 
               If Int(\Y) % #Object_Event_Align < 10 : HorizAlign = Int(\Y)/#Object_Event_Align*#Object_Event_Align : EndIf   
               *pMainDesign\HorizAlign = HorizAlign
               *pMainDesign\VertiAlign = VertiAlign
               *pMainDesign\IsModify = #True
               ProcedureReturn #True
         EndSelect
      EndWith
   EndIf 
   
   With *pMainCanvas ;定义画布选择区尺寸
      \W = X-\X
      \H = Y-\Y
   EndWith  
   ProcedureReturn #True
EndProcedure

Procedure Canvas_Event_MouseMove_Right(*pMainCanvas.__Canvas_MainInfo, X.f, Y.f)
   *pMainDesign.__Design_MainInfo = *pMainCanvas\pMainDesign
   If *pMainCanvas\pSelection
      With *pMainCanvas
         \ScrollX + (\X - X) * \LayerZoom
         \ScrollY + (\Y - Y) * \LayerZoom
;          If \ScrollX < 0 : \ScrollX = 0 : EndIf 
;          If \ScrollY < 0 : \ScrollY = 0 : EndIf 
      EndWith
   EndIf 
   ProcedureReturn #True
EndProcedure

Procedure Canvas_Event_MouseMove_Null(*pMainCanvas.__Canvas_MainInfo, X.f, Y.f)
   ;*pMainDesign\pCurrDupont不为#Null时,表示[杜邦线]编辑状态
   ;注意: 这里坑过, 
   ;*pMainDesign\pCurrDupont == #Null ==> Dupont_PinPrefer_Origin()
   ;*pMainDesign\pCurrDupont <> #Null ==> Dupont_PinPrefer_Target()
   *pMainDesign.__Design_MainInfo = *pMainCanvas\pMainDesign
   
   If *pMainDesign\pCurrObject
      If *pMainDesign\pCurrDupont
         Select *pMainDesign\pCurrDupont\ObjectType & #Object_Event
            Case #Object_Event_Active     ;初创状态
               Dupont_PinPrefer_Target(*pMainDesign, X, Y)
            Case #Object_Event_Origin     ;移动[源引脚]
            Case #Object_Event_Target     ;移动[目标引脚]
         EndSelect   
         *pMainCanvas\X = X
         *pMainCanvas\Y = Y
         ProcedureReturn #True
      Else 
         Dupont_PinPrefer_Origin(*pMainDesign, X, Y)
      EndIf 
      ProcedureReturn #True
   EndIf 
   NeedRefresh = Dupont_PinPrefer_Origin(*pMainDesign, X, Y)
   If *pMainCanvas\pSelection 
      *pMainCanvas\pSelection = #Null
      ProcedureReturn #True
   EndIf 
   ProcedureReturn NeedRefresh
EndProcedure

;光标移动事件
Procedure Canvas_Event_MouseMove(*pMainCanvas.__Canvas_MainInfo, CanvasX, CanvasY, ButtonState)
   X.f = (CanvasX + *pMainCanvas\ScrollX) / *pMainCanvas\LayerZoom
   Y.f = (CanvasY + *pMainCanvas\ScrollY) / *pMainCanvas\LayerZoom
   Select ButtonState
      Case #PB_Canvas_LeftButton    : NeedRefresh = Canvas_Event_MouseMove_Left (*pMainCanvas, X, Y)
      Case #PB_Canvas_RightButton   : NeedRefresh = Canvas_Event_MouseMove_Right(*pMainCanvas, X, Y)
      Case #PB_Canvas_MiddleButton
      Default                       : NeedRefresh = Canvas_Event_MouseMove_Null(*pMainCanvas, X, Y)
   EndSelect
   ProcedureReturn NeedRefresh
EndProcedure

;-
Procedure Canvas_Event_KeyDown(*pMainCanvas.__Canvas_MainInfo, Button) 
   *pMainDesign.__Design_MainInfo = *pMainCanvas\pMainDesign
   Select Button
      Case #PB_Shortcut_Up, #PB_Shortcut_Down, #PB_Shortcut_Left, #PB_Shortcut_Right
         NeedRefresh = Object_Button_Moving(*pMainDesign\pCurrObject, Button)
      Case #PB_Shortcut_Delete
         NeedRefresh = Object_SetAttribute_ObjectDelete(*pMainDesign)
         Debug "[Object_Modify] Delete CountObject = "+ListSize(*pMainDesign\pListObject()), #DebugLevel_Object_Modify
         Debug "[Object_Modify] Delete CountMatter = "+ListSize(*pMainDesign\ListMatter()), #DebugLevel_Object_Modify
         Debug "[Object_Modify] Delete CountString = "+ListSize(*pMainDesign\ListString()), #DebugLevel_Object_Modify
         Debug "[Object_Modify] Delete CountGroups = "+ListSize(*pMainDesign\ListGroups()), #DebugLevel_Object_Modify
         Debug "[Object_Modify] Delete <<=============== ", #DebugLevel_Object_Modify
   EndSelect
   ProcedureReturn NeedRefresh
EndProcedure

Procedure Canvas_Event_KeyUp(*pMainCanvas.__Canvas_MainInfo, Button) 
   
EndProcedure

;-
;- ******** [Error] ******** 
;出错捕获
Procedure$  Canvas_ErrorMessage(ErrorCode)
   Select ErrorCode
      Case #Canvas_Error_4001 : ErrorMessage$ = #Canvas_Error_4001$
      Case #Canvas_Error_4002 : ErrorMessage$ = #Canvas_Error_4002$
   EndSelect
   ProcedureReturn ErrorMessage$
EndProcedure

;-
;- ######## [Test] ######## 
CompilerIf  #PB_Compiler_IsMainFile = #True
   #winScreen = 0
   #cvsScreen = 1
  
   Procedure Canvas_CallBack(Index, Count, Note$)
      Debug Str(Index)+"/"+Str(Count) + ":" + Note$
   EndProcedure
   
   UseMD5Fingerprint() 
   UsePNGImageDecoder()
   *pEngine.__Module_MainInfo = Module_LoadBinary()
   If *pEngine = #Null
      Debug Module_ErrorMessage(_EngineErrorCode)
      End
   EndIf 
   If *pEngine\IsModuleInitial = #False
      *pEngine\pCallRegister = @Canvas_CallBack()
      UsePNGImageEncoder()
      *pEngine\ThreadID = CreateThread(@Module_Register(), *pEngine)
      WaitThread(*pEngine\ThreadID)
   EndIf
   
   DesignID = Design_Create(*pEngine)
   CanvasID = Canvas_Create(DesignID)   
   
   ForEach *pEngine\ListModule()
      If *pEngine\ListModule()\ModuleTypes$ = "船型波动开关[KCD11]"
         *pModule = *pEngine\ListModule()
         Break
      EndIf 
   Next    

   Object_AddMatter(DesignID, *pModule, 0200, 100, 3)
   Object_AddMatter(DesignID, *pModule, 0600, 100)
   Object_AddMatter(DesignID, *pModule, 1000, 100)
   
   
   ForEach *pEngine\ListModule()
      If *pEngine\ListModule()\ModuleTypes$ = "小面包板[SYB-170]"
         *pModule = *pEngine\ListModule()
         Break
      EndIf 
   Next       
   
   Object_AddMatter(DesignID, *pModule, 700, 500)
   
   Object_AddString(DesignID, 0200, 500, "船型波动开关[KCD11]")
   
   
   OpenWindow(#winScreen, 0, 0, 1000, 750, "模块类初始化测试", #PB_Window_SystemMenu|#PB_Window_ScreenCentered)
   CanvasGadget(#cvsScreen, 0, 0, 1000, 750, #PB_Canvas_Keyboard)
   
   hImage = Canvas_RedrawScreen(CanvasID, 1000, 750)
   If StartDrawing(CanvasOutput(#cvsScreen))
      DrawImage(hImage, 0, 0)
      StopDrawing()
   EndIf

   Repeat
      WinEvent = WindowEvent()
      Select WinEvent 
         Case #PB_Event_CloseWindow : IsExitWindow = #True
         Case #PB_Event_Gadget
            If EventGadget() <> #cvsScreen : Continue : EndIf 
            X = GetGadgetAttribute(#cvsScreen, #PB_Canvas_MouseX)
            Y = GetGadgetAttribute(#cvsScreen, #PB_Canvas_MouseY)  
            Modifiers = GetGadgetAttribute(#cvsScreen, #PB_Canvas_Modifiers)  
            ButtonState = GetGadgetAttribute(#cvsScreen, #PB_Canvas_Buttons) 
            Select EventType() 
                  
               Case #PB_EventType_LeftButtonDown  : Refresh = Canvas_Event_LeftButtonDown (CanvasID, X, Y, Modifiers)
               Case #PB_EventType_LeftButtonUp    : Refresh = Canvas_Event_LeftButtonUp   (CanvasID, X, Y, Modifiers)
               Case #PB_EventType_RightButtonDown : Refresh = Canvas_Event_RightButtonDown(CanvasID, X, Y, Modifiers)
               Case #PB_EventType_RightButtonUp   : Refresh = Canvas_Event_RightButtonUp  (CanvasID, X, Y, Modifiers)
               Case #PB_EventType_LeftDoubleClick : Refresh = Canvas_Event_LeftDoubleClick(CanvasID, X, Y)                                   
               Case #PB_EventType_MouseMove       : Refresh = Canvas_Event_MouseMove(CanvasID, X, Y, ButtonState)
               Case #PB_EventType_KeyDown         : Refresh = Canvas_Event_KeyDown(CanvasID, GetGadgetAttribute(#cvsScreen, #PB_Canvas_Key) )                               
               Case #PB_EventType_KeyUp         
                           
            EndSelect
            If Refresh
               hImage = Canvas_RedrawScreen(CanvasID, 1000, 750)
               If StartDrawing(CanvasOutput(#cvsScreen))
                  DrawImage(hImage, 0, 0)
                  StopDrawing()
               EndIf
            EndIf 
      EndSelect
   Until IsExitWindow = #True
   Canvas_Release(CanvasID)   
   Design_Release(DesignID)
   Module_Release(EngineID)
   
CompilerEndIf 






















; IDE Options = PureBasic 5.62 (Windows - x86)
; CursorPosition = 898
; FirstLine = 777
; Folding = 7-z----
; EnableXP