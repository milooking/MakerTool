;*****************************************
;******** 单片机仿真模拟器窗体界面 ********
;********    迷路仟 2020.02.28    ********
;*****************************************
;【Maker_Dialog.pbi】 文件保存打开对话框源代码

#Dialog_OpenFile = 0
#Dialog_SaveFile = 1


;-[Enumeration]
Enumeration Screen
   #winDialog           ;对话框编号
   #btnDialogClose      ;对话框关闭按键编号
   #btnOpenSure         ;对话框Sure按键编号
   #btnSaveSure         ;对话框Sure按键编号
   #btnDialogCancel     ;对话框取消按键编号
   #btnPrevFolder  
   #btnDisplayMode   
   #btnMyComputer 
   #btnMyDesktop 
   
   #fcxDirectory
   #flvFileList
   #cmbFileName
   #cmbFileType
EndEnumeration





;-[IncludeFile]
XIncludeFile ".\Maker_Define.pbi"      ;定义类源代码



;-[Structure]
;信息对话框结构
Structure __Dialog_MainInfo Extends __WindowInfo
   hDialogIcon.i
   TitleH.l
   NoticeH.l
   Flags.l
   Title$
   FileName$
   Directory$
   hThumbnail.l
   
   ;=========
   *pColors.__ColorInfo
   *pWindow.__WindowInfo
   ;=========
   btnCloseBox.__GadgetInfo
   btnOpenSure.__GadgetInfo
   btnSaveSure.__GadgetInfo
   btnDialogCancel.__GadgetInfo
   
   btnPrevFolder.__GadgetInfo  
   btnDisplayMode.__GadgetInfo    
   btnMyComputer.__GadgetInfo    
   btnMyDesktop.__GadgetInfo    
   ;=========
   Events.__EventInfo
   ;=========
   *pCallGetThumbnail
   ;=========
   DialogType.b
   IsExitWindow.b
EndStructure

;-[Global]
Global _Dialog.__Dialog_MainInfo

;-
;- ******** [Redraw] ********
;绘制边框
Procedure Dialog_RedrawBorder()
   With _Dialog
      BackColor = \pColors\BackColor
      HighColor = \pColors\HighColor
      ForeColor = \pColors\ForeColor
      ;绘制背景
      DrawingMode(#PB_2DDrawing_AllChannels)
      Box(0, 0, \WindowW, \WindowH, ForeColor)
      Box(4, \TitleH, \WindowW-4-4, \WindowH-\TitleH-8, BackColor)
      
      ;高亮色
      Box(1, \TitleH-3, \WindowW-2, 2, HighColor)              ;标题
      Box(1, \TitleH-1, 2, \WindowH-\TitleH, HighColor)        ;左际
      Box(\WindowW-3,\TitleH-1,2,\WindowH-\TitleH, HighColor)  ;右际
      For k = 1 To 6
         Line(1, \TitleH-9+k, 100+k, 1, HighColor)             ;标题左侧
         Line(3, \WindowH-8+k, 90-k, 1, HighColor)             ;底部左侧  
         Line(\WindowW-3, \WindowH-8+k, -90+k, 1, HighColor)   ;底部右侧  
      Next 
      
      ;条纹色
      For k = 1 To 8
         Line(20+k*7, \TitleH-7, 5, 5, ForeColor)              ;标题左侧
         Line(21+k*7, \TitleH-7, 5, 5, ForeColor)              ;标题左侧 
         Line(22+k*7, \TitleH-7, 5, 5, ForeColor)              ;标题左侧 
         Line(14+k*7, \WindowH-6, -4, 4, ForeColor)            ;底部左侧
         Line(13+k*7, \WindowH-6, -4, 4, ForeColor)            ;底部左侧 
         Line(12+k*7, \WindowH-6, -4, 4, ForeColor)            ;底部左侧 
         Line(\WindowW-12-k*7, \WindowH-6, 4, 4, ForeColor)    ;底部左侧
         Line(\WindowW-13-k*7, \WindowH-6, 4, 4, ForeColor)    ;底部右侧             
         Line(\WindowW-14-k*7, \WindowH-6, 4, 4, ForeColor)    ;底部右侧             
      Next
   EndWith
EndProcedure

;绘制事件
Procedure Dialog_RedrawScreen()
   With _Dialog
      ;绘制与当前窗体与鼠标事件相关的界面
      If StartDrawing(ImageOutput(\LayerImageID))
         BackColor = \pColors\BackColor
         HighColor = \pColors\HighColor
         ForeColor = \pColors\ForeColor
         Dialog_RedrawBorder()

         ;绘制文本
         DrawingMode(#PB_2DDrawing_AlphaBlend|#PB_2DDrawing_Transparent)
         DrawingFont(FontID(\pWindow\Font12ID))
         DrawText(20, (\TitleH-TextHeight(\Title$)-8)/2, \Title$, BackColor)
         X = 40 : Y = \TitleH+20

         DrawText(020, 055, "查找范围:",ForeColor)
         DrawText(020, 330, "文件名称:", ForeColor)
         DrawText(020, 360, "文件类型:", ForeColor)
         
         Box(434, 089, 142, 142, ForeColor)
         Box(435, 090, 140, 140, $FFFFFFFF)
         Pos = 50
         If \hThumbnail
            DrawImage(\hThumbnail, 435+6, 090+6, 128, 128)
         EndIf 
;             
         ;绘制按键
         DrawingMode(#PB_2DDrawing_AlphaBlend) 
         ButtonX = \WindowW-1 - \btnCloseBox\W : ButtonY = 1  
         Define_RedrawGadget(\Events, \btnCloseBox,     ButtonX, ButtonY)
         Define_RedrawGadget(\Events, \btnOpenSure,     \WindowW-120, \WindowH-50)
         Define_RedrawGadget(\Events, \btnSaveSure,     \WindowW-120, \WindowH-50)
         Define_RedrawGadget(\Events, \btnDialogCancel, \WindowW-120, \WindowH-90)
         Define_RedrawGadget(\Events, \btnPrevFolder)
         Define_RedrawGadget(\Events, \btnDisplayMode)
         Define_RedrawGadget(\Events, \btnMyComputer)
         Define_RedrawGadget(\Events, \btnMyDesktop)
         StopDrawing()
      EndIf 

      ;将对话框图像渲染到窗体
      If \hLayerImage : DeleteObject_(\hLayerImage) : \hLayerImage = 0 : EndIf  ;释放窗体背景句柄
      \hLayerImage= CreatePatternBrush_(ImageID(\LayerImageID))
      If \hLayerImage
         SetClassLongPtr_(\hWindow, #GCL_HBRBACKGROUND, \hLayerImage)
         ;设置刷新域,去掉窗体界面控件部分 注意:*pRectScreen.RECT, *pRgnCombine是指针,不一样
         *pRgnCombine = CreateRectRgn_(0,0,\WindowW, \WindowH)           ;设置一个大的区域
         For GadgetID = #fcxDirectory To #cmbFileType
            X = GadgetX(GadgetID)
            Y = GadgetY(GadgetID)
            R = X+GadgetWidth(GadgetID)
            B = Y+GadgetHeight(GadgetID)
            *pRgnReserve = CreateRectRgn_(X,Y,R,B)                  ;设置[]的区域
            CombineRgn_(*pRgnCombine,*pRgnCombine,*pRgnReserve,#RGN_DIFF)   ;在大区域中挖去按键区域  
         Next    
         RedrawWindow_(\hWindow, #Null, *pRgnCombine, #RDW_UPDATENOW|#RDW_ERASE|#RDW_INVALIDATE)
      EndIf 
   EndWith
EndProcedure

;-
;- ******** [Hook] ********
;光标在上事件[独立HOOK]
Procedure Dialog_Hook_MOUSEMOVE(*pMouse.POINTS)
   With _Dialog
      If *pMouse = 0   
      ElseIf Macro_Gadget_InRect2(\btnCloseBox)    : *pEventGadget = \btnCloseBox
      ElseIf Macro_Gadget_InRect3(\btnOpenSure)    : *pEventGadget = \btnOpenSure
      ElseIf Macro_Gadget_InRect3(\btnSaveSure)    : *pEventGadget = \btnSaveSure
      ElseIf Macro_Gadget_InRect2(\btnDialogCancel): *pEventGadget = \btnDialogCancel
      ElseIf Macro_Gadget_InRect2(\btnPrevFolder)  : *pEventGadget = \btnPrevFolder
      ElseIf Macro_Gadget_InRect2(\btnDisplayMode) : *pEventGadget = \btnDisplayMode
      ElseIf Macro_Gadget_InRect2(\btnMyComputer)  : *pEventGadget = \btnMyComputer
      ElseIf Macro_Gadget_InRect2(\btnMyDesktop)   : *pEventGadget = \btnMyDesktop
      EndIf 
      ;整理响应事件
      If \Events\pMouseTop <> *pEventGadget : \Events\pMouseTop = *pEventGadget : Dialog_RedrawScreen() : EndIf
   EndWith
EndProcedure

;左键按下事件[独立HOOK]
Procedure Dialog_Hook_LBUTTONDOWN(*pMouse.POINTS)
   With _Dialog
      If *pMouse = 0   
      ElseIf Macro_Gadget_InRect2(\btnCloseBox)    : *pEventGadget = \btnCloseBox
      ElseIf Macro_Gadget_InRect3(\btnOpenSure)    : *pEventGadget = \btnOpenSure
      ElseIf Macro_Gadget_InRect3(\btnSaveSure)    : *pEventGadget = \btnSaveSure
      ElseIf Macro_Gadget_InRect2(\btnDialogCancel): *pEventGadget = \btnDialogCancel
      ElseIf Macro_Gadget_InRect2(\btnPrevFolder)  : *pEventGadget = \btnPrevFolder
      ElseIf Macro_Gadget_InRect2(\btnDisplayMode) : *pEventGadget = \btnDisplayMode
      ElseIf Macro_Gadget_InRect2(\btnMyComputer)  : *pEventGadget = \btnMyComputer
      ElseIf Macro_Gadget_InRect2(\btnMyDesktop)   : *pEventGadget = \btnMyDesktop
      Else
         SendMessage_(\hWindow, #WM_NCLBUTTONDOWN, #HTCAPTION, 0)      
      EndIf 
      ;整理响应事件
      If \Events\pHoldDown <> *pEventGadget : \Events\pHoldDown = *pEventGadget : Dialog_RedrawScreen() : EndIf   
   EndWith
EndProcedure

;左键释放事件[独立HOOK]
Procedure Dialog_Hook_LBUTTONUP(*pMouse.POINTS)
   With _Dialog
      
      If *pMouse = 0   
      ElseIf Macro_Gadget_InRect2(\btnCloseBox) 
         If \Events\pHoldDown = \btnCloseBox
            *pEventGadget = \btnCloseBox
            PostEvent(#PB_Event_Gadget, #winDialog, #btnDialogClose)
         EndIf 

      ElseIf Macro_Gadget_InRect3(\btnOpenSure)
         If \Events\pHoldDown = \btnOpenSure
            *pEventGadget = \btnOpenSure
            PostEvent(#PB_Event_Gadget, #winDialog, #btnOpenSure)
         EndIf    
         
      ElseIf Macro_Gadget_InRect3(\btnSaveSure)
         If \Events\pHoldDown = \btnSaveSure
            *pEventGadget = \btnSaveSure
            PostEvent(#PB_Event_Gadget, #winDialog, #btnSaveSure)
         EndIf             
         
      ElseIf Macro_Gadget_InRect2(\btnDialogCancel)
         If \Events\pHoldDown = \btnDialogCancel
            *pEventGadget = \btnDialogCancel
            PostEvent(#PB_Event_Gadget, #winDialog, #btnDialogCancel)
         EndIf
         
      ElseIf Macro_Gadget_InRect2(\btnPrevFolder)   
         If \Events\pHoldDown = \btnPrevFolder
            *pEventGadget = \btnPrevFolder
            PostEvent(#PB_Event_Gadget, #winDialog, #btnPrevFolder)
         EndIf         
         
      ElseIf Macro_Gadget_InRect2(\btnDisplayMode)    
         If \Events\pHoldDown = \btnDisplayMode
            *pEventGadget = \btnDisplayMode
            PostEvent(#PB_Event_Gadget, #winDialog, #btnDisplayMode)
         EndIf    
         
      ElseIf Macro_Gadget_InRect2(\btnMyComputer)    
         If \Events\pHoldDown = \btnMyComputer
            *pEventGadget = \btnMyComputer
            PostEvent(#PB_Event_Gadget, #winDialog, #btnMyComputer)
         EndIf             
         
      ElseIf Macro_Gadget_InRect2(\btnMyDesktop)    
         If \Events\pHoldDown = \btnMyDesktop
            *pEventGadget = \btnMyDesktop
            PostEvent(#PB_Event_Gadget, #winDialog, #btnMyDesktop)
         EndIf            
      EndIf 
      ;整理响应事件
      If \Events\pHoldDown Or \Events\pHoldDown
         \Events\pHoldDown = 0 : \Events\pMouseTop = 0 : Dialog_RedrawScreen()
      EndIf   
   EndWith
EndProcedure

;挂钩事件[独立HOOK]
Procedure Dialog_Hook(hWindow, uMsg, wParam, lParam) 
   With _Dialog
      If \hWindow <> hWindow
         ProcedureReturn DefWindowProc_(hWindow, uMsg, wParam, lParam)
      EndIf
      Select uMsg
         Case #WM_MOUSEMOVE     : Dialog_Hook_MOUSEMOVE  (@lParam)
         Case #WM_LBUTTONDOWN   : Dialog_Hook_LBUTTONDOWN(@lParam)
         Case #WM_LBUTTONUP     : Dialog_Hook_LBUTTONUP  (@lParam)
      EndSelect 
      Result = CallWindowProc_(\hWindowHook, hWindow, uMsg, wParam, lParam)
   EndWith
   ProcedureReturn Result
EndProcedure

;-
;- ******** [Function] ********

Procedure Dialog_GetSystemDirectory()
   
;    ClearList(_Dialog\cmbDirectory\ListDirectory())
;    SystemPath$ = Space(255)  
;    Result = GetSystemDirectory_(SystemPath$, 255)  
;    Directory$ = GetUserDirectory(#PB_Directory_Desktop)
;    hIcon = ExtractIcon_(0, SystemPath$+"\SetupAPI.dll",0)
;    *pDirectory.__Directory_Info = AddElement(_Dialog\cmbDirectory\ListDirectory())
;    *pDirectory\FilePath$ = Directory$
;    *pDirectory\FileName$ = "我的电脑"
;    *pDirectory\hIcon     = hIcon
;    *pDirectory\Floor     = 0
;    
;    For Char = 65 To 90 
;       Directory$ = Chr(Char)+":\" 
;       DirectType = GetDriveType_(Directory$) 
;       FileNames$ = Space(256) 
;       FileModes$ = Space(256) 
;       GetVolumeInformation_(@Directory$, @FileNames$, 255, @Serial, 0, 0, 0, 0) 
;       If DirectType = 3 
;          SHGetFileInfo_(Directory$, 0, @FileInfo.SHFILEINFO, SizeOf(SHFILEINFO), $20|#SHGFI_ICON|#SHGFI_SMALLICON)
;          *pDirectory.__Directory_Info = AddElement(_Dialog\cmbDirectory\ListDirectory())
;          *pDirectory\FilePath$ = Directory$
;          *pDirectory\FileName$ = FileNames$+" ("+Directory$+ ")"
;          *pDirectory\hIcon     = FileInfo\hIcon
;          *pDirectory\Floor     = 1
;       EndIf 
;    Next 
;    Directory$ = GetUserDirectory(#PB_Directory_Desktop)
;    SHGetFileInfo_(Directory$, 0, @FileInfo.SHFILEINFO, SizeOf(SHFILEINFO), $20|#SHGFI_ICON|#SHGFI_SMALLICON)
;    *pDirectory.__Directory_Info = AddElement(_Dialog\cmbDirectory\ListDirectory())
;    *pDirectory\FilePath$ = Directory$
;    *pDirectory\FileName$ = "桌面"
;    *pDirectory\hIcon     = FileInfo\hIcon
;    *pDirectory\Floor     = 0
;    
;    Directory$ = GetUserDirectory(#PB_Directory_Documents)
;    SHGetFileInfo_(Directory$, 0, @FileInfo.SHFILEINFO, SizeOf(SHFILEINFO), $20|#SHGFI_ICON|#SHGFI_SMALLICON)
;    *pDirectory.__Directory_Info = AddElement(_Dialog\cmbDirectory\ListDirectory())
;    *pDirectory\FilePath$ = Directory$
;    *pDirectory\FileName$ = "我的文档"
;    *pDirectory\hIcon     = FileInfo\hIcon
;    *pDirectory\Floor     = 0   
;    
EndProcedure


Procedure Dialog_Event_flvFileList()
   Select EventType()
      Case #PB_EventType_Change
      Case #PB_EventType_LeftClick
         Index = GetGadgetState(#flvFileList)
         If Index < 0 : ProcedureReturn : EndIf 
         FileName$ = GetGadgetItemText(#flvFileList, Index, 0)
         _Dialog\FileName$ = FileName$
         If FileSize(_Dialog\Directory$+_Dialog\FileName$) = -2
            If _Dialog\hThumbnail
               _Dialog\hThumbnail = #Null
               Dialog_RedrawScreen()
            EndIf 
         Else    
            SetGadgetText(#cmbFileName, FileName$)
            If _Dialog\pCallGetThumbnail
               Thumbnail$ = _Dialog\Directory$+FileName$
               _Dialog\hThumbnail = CallFunctionFast(_Dialog\pCallGetThumbnail, @Thumbnail$)
               Dialog_RedrawScreen()
               Debug "hThumbnail = " + _Dialog\hThumbnail
            EndIf 
         EndIf 
      
      
      Case #PB_EventType_LeftDoubleClick
         Directory$ = GetGadgetText(#flvFileList)
         Index = GetGadgetState(#flvFileList)
         FileName$ = GetGadgetItemText(#flvFileList, Index, 0)
         Directory$ + FileName$
         _Dialog\FileName$ = FileName$
         If FileSize(Directory$) = -2
            If Right (Directory$, 1) <> "\" : Directory$ + "\" : EndIf 
            _Dialog\Directory$ = Directory$
            If GetGadgetState(#cmbFileType) = 0 
               Flags$ = "*.mct"
            Else
               Flags$ = "*.*"
            EndIf 
            SetGadgetText(#fcxDirectory, Directory$)
            SetGadgetText(#flvFileList, Directory$+Flags$)
            For i = CountGadgetItems(#flvFileList) - 1 To 0 Step -1
               FileName$ = GetGadgetItemText(#flvFileList, i, 0)
               If GetFileAttributes(Directory$ + FileName$) & #PB_FileSystem_Hidden
                  RemoveGadgetItem(#flvFileList, i)
               EndIf
            Next
         EndIf 
   EndSelect  
EndProcedure

Procedure Dialog_Event_fcxDirectory()
   Directory$ = GetGadgetText(#fcxDirectory)
   If _Dialog\Directory$ <> Directory$
      _Dialog\Directory$ = Directory$      
      If Directory$ = #Null$
         Directory$ = ""
         SetGadgetText(#flvFileList, Directory$)
         For i = CountGadgetItems(#flvFileList) - 1 To 0 Step -1
            FileName$ = GetGadgetItemText(#flvFileList, i, 0)
         Next  
      Else 
         If GetGadgetState(#cmbFileType) = 0 
            Flags$ = "*.mct"
         Else
            Flags$ = "*.*"
         EndIf 
         SetGadgetText(#flvFileList, Directory$+Flags$)
         For i = CountGadgetItems(#flvFileList) - 1 To 0 Step -1
            FileName$ = GetGadgetItemText(#flvFileList, i, 0)
            If GetFileAttributes(Directory$ + FileName$) & #PB_FileSystem_Hidden
               RemoveGadgetItem(#flvFileList, i)
            EndIf
         Next         
      EndIf 
      SetActiveGadget(#flvFileList)
   EndIf 
EndProcedure

Procedure Dialog_Event_cmbFileType()
   If EventType() = #PB_EventType_Change
      If GetGadgetState(#cmbFileType) = 0 
         Flags$ = "*.mct"
      Else
         Flags$ = "*.*"
      EndIf 
      SetGadgetText(#flvFileList, _Dialog\Directory$+Flags$)
      For i = CountGadgetItems(#flvFileList) - 1 To 0 Step -1
         FileName$ = GetGadgetItemText(#flvFileList, i, 0)
         If GetFileAttributes(_Dialog\Directory$ + FileName$) & #PB_FileSystem_Hidden
            RemoveGadgetItem(#flvFileList, i)
         EndIf
      Next
      For i = 0 To CountGadgetItems(#flvFileList)-1
         FileName$ = GetGadgetItemText(#flvFileList, i, 0)
         If _Dialog\FileName$ = FileName$
            SetGadgetItemState(#flvFileList, i, #PB_Explorer_Selected)
         EndIf 
      Next
      SetActiveGadget(#flvFileList)
   EndIf
EndProcedure

Procedure$ Dialog_Event_btnOpenSure()
   FileName$ = GetGadgetText(#cmbFileName)
   If FileName$ = #Null$ : ProcedureReturn #Null$ : EndIf 
   _Dialog\FileName$ = FileName$
   If FileSize(_Dialog\Directory$+_Dialog\FileName$) = -2
      _Dialog\Directory$ +_Dialog\FileName$+"\"
      Directory$ = _Dialog\Directory$
      If Directory$ = #Null$
         Directory$ = ""
         SetGadgetText(#fcxDirectory, Directory$)
         SetGadgetText(#flvFileList, Directory$)
         For i = CountGadgetItems(#flvFileList) - 1 To 0 Step -1
            FileName$ = GetGadgetItemText(#flvFileList, i, 0)
         Next  
      Else 
         If GetGadgetState(#cmbFileType) = 0 
            Flags$ = "*.mct"
         Else
            Flags$ = "*.*"
         EndIf 
         SetGadgetText(#fcxDirectory, Directory$)
         SetGadgetText(#flvFileList, Directory$+Flags$)
         For i = CountGadgetItems(#flvFileList) - 1 To 0 Step -1
            FileName$ = GetGadgetItemText(#flvFileList, i, 0)
            If GetFileAttributes(Directory$ + FileName$) & #PB_FileSystem_Hidden
               RemoveGadgetItem(#flvFileList, i)
            EndIf
         Next         
      EndIf 
      SetActiveGadget(#flvFileList)
      ProcedureReturn #Null$
   Else 
      _Dialog\IsExitWindow = #True
      ProcedureReturn _Dialog\Directory$ +_Dialog\FileName$
   EndIf 
EndProcedure

Procedure$ Dialog_Event_btnSaveSure()
   FileName$ = GetGadgetText(#cmbFileName)
   If FileName$ = #Null$ : ProcedureReturn #Null$ : EndIf 
   _Dialog\FileName$ = FileName$
   If FileSize(_Dialog\Directory$+_Dialog\FileName$) = -2
      _Dialog\Directory$ +_Dialog\FileName$+"\"
      Directory$ = _Dialog\Directory$
      If Directory$ = #Null$
         Directory$ = ""
         SetGadgetText(#fcxDirectory, Directory$)
         SetGadgetText(#flvFileList, Directory$)
         For i = CountGadgetItems(#flvFileList) - 1 To 0 Step -1
            FileName$ = GetGadgetItemText(#flvFileList, i, 0)
         Next  
      Else 
         If GetGadgetState(#cmbFileType) = 0 
            Flags$ = "*.mct"
         Else
            Flags$ = "*.*"
         EndIf 
         SetGadgetText(#fcxDirectory, Directory$)
         SetGadgetText(#flvFileList, Directory$+Flags$)
         For i = CountGadgetItems(#flvFileList) - 1 To 0 Step -1
            FileName$ = GetGadgetItemText(#flvFileList, i, 0)
            If GetFileAttributes(Directory$ + FileName$) & #PB_FileSystem_Hidden
               RemoveGadgetItem(#flvFileList, i)
            EndIf
         Next         
      EndIf 
      SetActiveGadget(#flvFileList)
      ProcedureReturn #Null$
   Else 
      _Dialog\IsExitWindow = #True
      ProcedureReturn _Dialog\Directory$ +_Dialog\FileName$
   EndIf 
EndProcedure


Procedure Dialog_Event_btnPrevFolder()

   Count = CountString(_Dialog\Directory$, "\")
   If Count = 0 
      ProcedureReturn 
   ElseIf Count = 1 
      _Dialog\Directory$ =#Null$
      _Dialog\FileName$ = #Null$
      SetGadgetText(#fcxDirectory, _Dialog\Directory$)
      SetGadgetText(#flvFileList, _Dialog\Directory$+Flags$)
      For i = CountGadgetItems(#flvFileList) - 1 To 0 Step -1
         FileName$ = GetGadgetItemText(#flvFileList, i, 0)
      Next

   Else 
      Lenght = Len(StringField(_Dialog\Directory$, Count, "\")+"\")
      Lenght = Len(_Dialog\Directory$) - Lenght
      _Dialog\Directory$ = Left(_Dialog\Directory$, Lenght)
      _Dialog\FileName$ = StringField(_Dialog\Directory$, Count-1, "\")
      If GetGadgetState(#cmbFileType) = 0 
         Flags$ = "*.mct"
      Else
         Flags$ = "*.*"
      EndIf
      
      SetGadgetText(#fcxDirectory, _Dialog\Directory$)
      SetGadgetText(#flvFileList, _Dialog\Directory$+Flags$)
      For i = CountGadgetItems(#flvFileList) - 1 To 0 Step -1
         FileName$ = GetGadgetItemText(#flvFileList, i, 0)
         If GetFileAttributes(_Dialog\Directory$ + FileName$) & #PB_FileSystem_Hidden
            RemoveGadgetItem(#flvFileList, i)
         EndIf
      Next
      For i = 0 To CountGadgetItems(#flvFileList)-1
         FileName$ = GetGadgetItemText(#flvFileList, i, 0)
         If _Dialog\FileName$ = FileName$
            SetGadgetItemState(#flvFileList, i, #PB_Explorer_Selected)
         EndIf 
      Next  

   EndIf 

EndProcedure


Procedure Dialog_Event_btnDisplayMode()
   DisplayMode = GetGadgetAttribute(#flvFileList, #PB_Explorer_DisplayMode)
   Select DisplayMode
      Case #PB_Explorer_LargeIcon: SetGadgetAttribute(#flvFileList, #PB_Explorer_DisplayMode, #PB_Explorer_SmallIcon)
      Case #PB_Explorer_SmallIcon: SetGadgetAttribute(#flvFileList, #PB_Explorer_DisplayMode, #PB_Explorer_List)
      Case #PB_Explorer_List     : SetGadgetAttribute(#flvFileList, #PB_Explorer_DisplayMode, #PB_Explorer_Report)
      Case #PB_Explorer_Report   : SetGadgetAttribute(#flvFileList, #PB_Explorer_DisplayMode, #PB_Explorer_LargeIcon)
   EndSelect
EndProcedure


Procedure Dialog_Event_btnMyComputer()
   _Dialog\Directory$ = #Null$
   _Dialog\FileName$  = #Null$
   SetGadgetText(#fcxDirectory, _Dialog\Directory$)
   SetGadgetText(#flvFileList, _Dialog\Directory$+Flags$)
   For i = CountGadgetItems(#flvFileList) - 1 To 0 Step -1
      FileName$ = GetGadgetItemText(#flvFileList, i, 0)
   Next
EndProcedure

Procedure Dialog_Event_btnMyDesktop()
   _Dialog\Directory$ = GetUserDirectory(#PB_Directory_Desktop)
   _Dialog\FileName$  = #Null$
   SetGadgetText(#fcxDirectory, _Dialog\Directory$)
   SetGadgetText(#flvFileList, _Dialog\Directory$+Flags$)
   For i = CountGadgetItems(#flvFileList) - 1 To 0 Step -1
      FileName$ = GetGadgetItemText(#flvFileList, i, 0)
   Next
EndProcedure

;-
;- ******** [Create] ********
;创建按键
Procedure Dialog_CreateButton(*pGadget.__GadgetInfo, X, Y, W, H, IconX, IconY, IconW, IconH)
   With *pGadget
      \IsCreate = #True
      IconID    = _Dialog\pWindow\ResourIconID  
      FontColor = _Dialog\pColors\BackColor  
      SideColor = _Dialog\pColors\ForeColor
      BackColor = (Alpha(SideColor) << 23 & $FF000000) |(SideColor & $FFFFFF)

      HighColor1 = (Alpha(SideColor) << 20 & $FF000000) |(SideColor & $FFFFFF)
      HighColor2 = (Alpha(SideColor) << 21 & $FF000000) |(SideColor & $FFFFFF)
      
      \X = X : \Y = Y : \W = W : \H = H : \R = X+W : \B = Y+H
      If IsImage(\NormalcyID) : FreeImage(\NormalcyID) : EndIf 
      If IsImage(\MouseTopID) : FreeImage(\MouseTopID) : EndIf 
      If IsImage(\HoldDownID) : FreeImage(\HoldDownID) : EndIf 
      
      TempImageID = GrabImage(IconID, #PB_Any, IconX, IconY, IconW, IconH)
      \NormalcyID = CreateImage(#PB_Any, W, H, 32, #PB_Image_Transparent)
      If StartDrawing(ImageOutput(\NormalcyID))
         DrawingMode(#PB_2DDrawing_Transparent)
         DrawAlphaImage(ImageID(TempImageID), (W-IconW)/2, (H-IconH)/2)
         StopDrawing()
      EndIf
      FreeImage(TempImageID)
      
      \MouseTopID = CreateImage(#PB_Any, W, H, 32, #PB_Image_Transparent)
      If StartDrawing(ImageOutput(\MouseTopID))
         DrawingMode(#PB_2DDrawing_AlphaBlend)
         RoundBox(0, 0, W, H, 5, 5, HighColor1)
         
         DrawingMode(#PB_2DDrawing_AlphaBlend|#PB_2DDrawing_Outlined)
         RoundBox(0, 0, W, H, 5, 5, BackColor)         
         DrawAlphaImage(ImageID(\NormalcyID), 0, 0)
         StopDrawing()
      EndIf
      
      \HoldDownID = CreateImage(#PB_Any, W, H, 32, #PB_Image_Transparent)
      If StartDrawing(ImageOutput(\HoldDownID))
         DrawingMode(#PB_2DDrawing_AlphaBlend)
         RoundBox(0, 0, W, H, 5, 5, HighColor2)  
         DrawingMode(#PB_2DDrawing_AlphaBlend|#PB_2DDrawing_Outlined)
         RoundBox(0, 0, W, H, 5, 5, BackColor)         
         DrawAlphaImage(ImageID(\NormalcyID), 0, 0)
         StopDrawing()
      EndIf      
   EndWith
EndProcedure

;信息对话框初始化
Procedure$ Dialog_Requester(hParent, Title$, FileName$, IsEnable=#True, DialogType=#Dialog_OpenFile)
   With _Dialog
      \Flags    = Flags
      \Title$   = Title$
      \DialogType   = DialogType
      \IsExitWindow = #False      
      \TitleH   = 38
      \WindowW  = 595
      \WindowH  = 400
      \Directory$ = GetPathPart(FileName$)
      \FileName$  = GetFilePart(FileName$)

      If hParent = #Null
         WindowFlags = #PB_Window_BorderLess|#PB_Window_ScreenCentered
         \hWindow = OpenWindow(#winDialog, 0, 0, \WindowW, \WindowH, "", WindowFlags)
      ElseIf IsZoomed_(hParent) Or IsIconic_(hParent) ;判断父窗体是否最大化和最小化
         WindowFlags = #PB_Window_BorderLess|#PB_Window_ScreenCentered
         \hWindow = OpenWindow(#winDialog, 0, 0, \WindowW, \WindowH, "", WindowFlags, hParent)
      Else 
         WindowFlags = #PB_Window_BorderLess|#PB_Window_WindowCentered
         \hWindow = OpenWindow(#winDialog, 0, 0, \WindowW, \WindowH, "", WindowFlags, hParent)
      EndIf
      Flags = #PB_Explorer_FullRowSelect|#PB_Explorer_NoParentFolder|#PB_Explorer_NoDirectoryChange
      ExplorerComboGadget(#fcxDirectory, 100, 050, 320, 025, \Directory$)
      ExplorerListGadget (#flvFileList, 020, 085, 400, 230, \Directory$+"*.mct", Flags)
      ComboBoxGadget     (#cmbFileName, 100, 325, 320, 025, #PB_ComboBox_Editable)
      ComboBoxGadget     (#cmbFileType, 100, 355, 320, 025)

      SetGadgetFont(#fcxDirectory,   FontID(\pWindow\Font12ID))
      SetGadgetFont(#cmbFileName,   FontID(\pWindow\Font12ID))
      SetGadgetFont(#cmbFileType,   FontID(\pWindow\Font12ID))
      SetGadgetAttribute(#flvFileList, #PB_Explorer_DisplayMode, #PB_Explorer_LargeIcon)
      AddGadgetItem(#cmbFileType, -1, "设计文档(*.mct)|*.mct")
      AddGadgetItem(#cmbFileType, -1, "任意文件(*.*)|*.*")
      SetGadgetState(#cmbFileType, 0)
      SetGadgetText(#cmbFileName, \FileName$)
      For i = 0 To CountGadgetItems(#flvFileList)-1
         FileName$ = GetGadgetItemText(#flvFileList, i, 0)
         If _Dialog\FileName$ = FileName$
            SetGadgetItemState(#flvFileList, i, #PB_Explorer_Selected)
         EndIf 
      Next
      SetActiveGadget(#flvFileList)
      If _Dialog\pCallGetThumbnail
         Thumbnail$ = \Directory$+\FileName$
         _Dialog\hThumbnail = CallFunctionFast(_Dialog\pCallGetThumbnail, @Thumbnail$)
      EndIf 
      If DialogType = #Dialog_OpenFile
         \btnOpenSure\IsHide = #False
         \btnSaveSure\IsHide = #True
      Else 
         \btnOpenSure\IsHide = #True
         \btnSaveSure\IsHide = #False
      EndIf 
         
      Dialog_RedrawScreen()
      \hWindowHook = SetWindowLongPtr_(\hWindow, #GWL_WNDPROC, @Dialog_Hook()) 
      If IsEnable=#True And hParent
         EnableWindow_(hParent, #False)   ;禁用父窗体的响应动作
      EndIf 
      Repeat
         Select WindowEvent()
            Case #PB_Event_CloseWindow   : \IsExitWindow = #True
            Case #PB_Event_Gadget
               Select EventGadget()
                  Case #btnDialogClose   : \IsExitWindow = #True : Result$ = #Null$ 
                  Case #btnDialogCancel  : \IsExitWindow = #True : Result$ = #Null$
                  Case #btnOpenSure      : Result$ = Dialog_Event_btnOpenSure()
                  Case #btnSaveSure      : Result$ = Dialog_Event_btnSaveSure()
                  Case #btnPrevFolder    : Dialog_Event_btnPrevFolder()
                  Case #btnDisplayMode   : Dialog_Event_btnDisplayMode()
                  Case #btnMyComputer    : Dialog_Event_btnMyComputer()
                  Case #btnMyDesktop     : Dialog_Event_btnMyDesktop()
                  Case #fcxDirectory     : Dialog_Event_fcxDirectory()
                  Case #flvFileList      : Dialog_Event_flvFileList()  
                  Case #cmbFileType      : Dialog_Event_cmbFileType()
               EndSelect
            Default 
         EndSelect
      Until \IsExitWindow = #True 
      If \hLayerImage  ;释放窗体背景句柄
         DeleteObject_(\hLayerImage) 
         \hLayerImage = 0
      EndIf 
      CloseWindow(#winDialog)
      If IsEnable=#True And hParent
         EnableWindow_(hParent, #True)   ;恢复父窗体的响应动作
      EndIf 
      Delay(100)
   EndWith
   ProcedureReturn Result$
EndProcedure

;-
;- ======> [External Call] <======
;信息对话框初始化
Procedure Dialog_Initial(*pWindow.__WindowInfo, *pColors)
   With _Dialog
      \pWindow      = *pWindow
      \pColors      = *pColors
      \LayerImageID = CreateImage(#PB_Any, 600, 400)
      Define_CreateCloseBox(*pColors, \btnCloseBox)    ;创建关闭窗体小按键
      Define_CreateButton  (*pColors, \btnDialogCancel,0, 0, 100, 30, "取消", *pWindow\Font12ID)
      Define_CreateButton  (*pColors, \btnOpenSure,    0, 0, 100, 30, "打开", *pWindow\Font12ID)
      Define_CreateButton  (*pColors, \btnSaveSure,    0, 0, 100, 30, "保存", *pWindow\Font12ID)
      ButtonX = 435
      Dialog_CreateButton(\btnPrevFolder,  ButtonX, 047, 30, 30, 220, 032, 24, 24) : ButtonX+37
      Dialog_CreateButton(\btnDisplayMode, ButtonX, 047, 30, 30, 244, 032, 24, 24) : ButtonX+37
      Dialog_CreateButton(\btnMyDesktop,   ButtonX, 047, 30, 30, 268, 032, 24, 24) : ButtonX+37       
      Dialog_CreateButton(\btnMyComputer,  ButtonX, 047, 30, 30, 292, 032, 24, 24) : ButtonX+37  
    
   EndWith
EndProcedure

;信息对话框初始化
Procedure$ Dialog_OpenFile(hParent, FileName$, IsEnable=#True)
   ProcedureReturn Dialog_Requester(hParent, "请选择要打开的文件", FileName$, IsEnable, #Dialog_OpenFile)
EndProcedure

;信息对话框初始化
Procedure$ Dialog_SaveFile(hParent, FileName$, IsEnable=#True)
   ProcedureReturn Dialog_Requester(hParent, "请选择要保存的文件", FileName$, IsEnable, #Dialog_SaveFile)
EndProcedure


Procedure Dialog_ChangeStyle(*pColors)
   With _Dialog
      \pColors      = *pColors
      Define_CreateCloseBox(*pColors, \btnCloseBox)    ;创建关闭窗体小按键
      Define_CreateButton  (*pColors, \btnDialogCancel,0, 0, 100, 30, "取消", \pWindow\Font12ID)
      Define_CreateButton  (*pColors, \btnOpenSure,    0, 0, 100, 30, "打开", \pWindow\Font12ID)
      Define_CreateButton  (*pColors, \btnSaveSure,    0, 0, 100, 30, "保存", \pWindow\Font12ID)
      ButtonX = 435
      Dialog_CreateButton(\btnPrevFolder,  ButtonX, 047, 30, 30, 220, 032, 24, 24) : ButtonX+37
      Dialog_CreateButton(\btnDisplayMode, ButtonX, 047, 30, 30, 244, 032, 24, 24) : ButtonX+37
      Dialog_CreateButton(\btnMyDesktop,   ButtonX, 047, 30, 30, 268, 032, 24, 24) : ButtonX+37       
      Dialog_CreateButton(\btnMyComputer,  ButtonX, 047, 30, 30, 292, 032, 24, 24) : ButtonX+37   
   EndWith
EndProcedure

;注销信息对话框
Procedure Dialog_Release()
   With _Dialog
      Define_FreeGadget(\btnCloseBox)
      Define_FreeGadget(\btnDialogCancel)
      Define_FreeGadget(\btnOpenSure)
      Define_FreeGadget(\btnSaveSure)
      
      Define_FreeGadget(\btnPrevFolder)
      Define_FreeGadget(\btnDisplayMode)
      Define_FreeGadget(\btnMyComputer)      
      Define_FreeGadget(\btnMyDesktop)      
      
      If IsImage(\LayerImageID) 
         FreeImage(\LayerImageID)
      EndIf 
   EndWith
EndProcedure


   
;设置CallBack函数
Procedure Dialog_CallBack(CallBackType, *pCallFunction)
   With _Dialog
      Select CallBackType
         Case #CallBack_GetThumbnail : \pCallGetThumbnail = *pCallFunction
      EndSelect
   EndWith
EndProcedure



;-
;- ######## [Test] ######## 
CompilerIf  #PB_Compiler_IsMainFile = #True
   #winScreen = 1000
   Color.__ColorInfo
   Color\BackColor = #Define_BackColor   
   Color\ForeColor = #Define_ForeColor
   Color\HighColor = #Define_HighColor
   Window.__WindowInfo
   Window\Font12ID = LoadFont(#PB_Any, "宋体", 12)  
   UsePNGImageDecoder()
   Window\ResourIconID  = CatchImage(#PB_Any, ?_ICON_Resources)
   ;======================
   WindowFlags = #PB_Window_SystemMenu|#PB_Window_MinimizeGadget|#PB_Window_ScreenCentered
   hWindow = OpenWindow(#winScreen, 0, 0, 500, 250, "Dialog-测试" , WindowFlags)
   Dialog_Initial(@Window, @Color)
   ;======================
   Repeat
      WindowEvent = WindowEvent()
      Select WindowEvent
         Case #PB_Event_CloseWindow : IsExitWindow = #True
         Case #WM_LBUTTONUP : Debug Dialog_OpenFile(hWindow, "F:\桌面\新建文档.mct")
         Case #WM_RBUTTONUP : Debug Dialog_SaveFile(hWindow, "F:\桌面\新建文档.mct")
      EndSelect
   Until IsExitWindow = #True 
   FreeFont(Window\Font12ID)   
   Dialog_Release()
   End
   
DataSection
_ICON_Resources:
   IncludeBinary ".\ICON.png" 
EndDataSection

CompilerEndIf 














; IDE Options = PureBasic 5.62 (Windows - x86)
; CursorPosition = 9
; Folding = 8Z4--
; EnableXP
; Executable = DEMO.exe