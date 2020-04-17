
;引脚针距实测: 2.54 像素距离: 25%=8px  50%=16px  75%=24px  100%=32px
;创客开发板编程接线示意图工具: Maker development board programming wiring diagram tool
;接线示意图工具: Wiring Diagram Tool


;- [Constant]

#EffectType_None     =0      ;没有
#EffectType_Replace  =1      ;替找
#EffectType_Cover    =2      ;覆盖
#EffectType_Gradient =3      ;渐变

;指针方向
#Direction_Up     = $000001
#Direction_Down   = $000002
#Direction_Right  = $000004
#Direction_Left   = $000008
#Direction_PPUp   = $000010   ;垂直于平台向上
#Direction_PPDown = $000020   ;垂直于平台向下

#Direction_Socket =  #Direction_Up|#Direction_Right|#Direction_Down|#Direction_Left

;引脚功能
#LinkType_DC1    = $00000001
#LinkType_DC0    = $00000002
#LinkType_VCC    = $00000004
#LinkType_GND    = $00000008
#LinkType_DO     = $00000010
#LinkType_AO     = $00000020
#LinkType_OCL    = $00000040
#LinkType_PIN    = $FFFF

#LinkMode_Plug       = $01
#LinkMode_Socket     = $02
#LinkMode_Terminal   = $04
#GroupType_None   = 0       ;常规引脚
#GroupType_Group  = 1      ;编组
#GroupType_Element= 2      ;编组成员


#Version = 0.1

#HeadSize  = $24

; 模块旋转角度
Enumeration
   #Object_Rotate_000
   #Object_Rotate_090
   #Object_Rotate_180
   #Object_Rotate_270
   #Object_Rotate_Count
EndEnumeration

Structure __Module_PinSocket
   SocketX.W
   SocketY.W
EndStructure
   
   
;模块类-引脚属性
Structure __Module_PinsAttri
   PinsLabel$     ;引脚标签
   LinkTypes.w    ;接线类型   
   LinkModes.w    ;接线方式
   Direction.w    ;接线方向
   PinsGroup.w    ;引脚组
   PinsColor.l    ;引脚颜色
   MaxVoltage.f   ;最大电压
   MinVoltage.f   ;最小电压
   Reserve.l
EndStructure

;模块类-引脚参数
Structure __Module_PinsParam
   OffsetX.w      ;引脚相对位置
   OffsetY.w      ;引脚相对位置   
   OffsetW.w      ;引脚相对位置
   OffsetH.w      ;引脚相对位置
   GroupType.b    ;组类型:0表示
   IsSocket.b     ;是否是插孔
   GroupIndex.w   ;用于保存
EndStructure

Structure __Module_ImageInfo
   FileName$
   FileSize.l
   ImageW.w          ;模块图像大小
   ImageH.w          ;模块图像大小 
   List ListPinParam.__Module_PinsParam()
EndStructure

Structure __Module_EffectInfo
   FileName$
   FileSize.l
   OffsetX.w
   OffsetY.w
   ImageW.w          ;模块图像大小
   ImageH.w          ;模块图像大小 
   EffectType.w      
   EffectNote$
EndStructure

;模块类-定义
Structure __Module_BaseInfo
   ModuleGroup$      ;模块编组 
   ModuleTypes$      ;模块类型   
   ModuleModel$      ;模块编组   
   ModuleName$       ;模块名称
   ModuleNote$       ;模块说明
   ModuleIcon$       ;模块ICON
   ModuleFile$       ;模块图像
   Resistance.f
   SortIndex.l
   IconSize.l
   IsSymmetry.b      ;是否对称
   DimReserve.b[3]   
   CountPins.l       ;数量
   CountEffect.l     
   ModuleImage.__Module_ImageInfo
   List ListPinAttri.__Module_PinsAttri()
   List ListEffect.__Module_EffectInfo()
EndStructure

Structure __Binary_Module_Header
   Flags.q        ; 标志
   HeadSize.w     ; 头部大小
   NoteAddr.w     ; 备注地址
   Version.f      ; 版本号
   IdxCount.l     ; 索引数量
   ExtSize.l      ; 索引大小     
   VirSize.l      ; 索引大小     
   IdxAddr.l      ; 索引地址
   MaxIconSize.l
   CreateTime.l   ; 创建日期
   InitalTime.l   ; 初始化日期
   MD5.b[32]      ; ＭＤ5
   Reserve.l
EndStructure

;索引块: 长度[1Byte]+模块类型[nByte]+长度[1Byte]+模块名称[nByte]+引脚数量[2Byte]+{__Module_PinsAttri}(引脚数量)+DimImageAddr.l[4]
;数据块: {__Module_PinsParam + 图像数据}[4]

Global NewList _ListModule.__Module_BaseInfo()
Global NewMap MapModule()


;加载[模块设置.ini]
Procedure Load_Module(FilePath$)
   
   NewList ListModuleINI$()
   mcsEnumFiles_(FilePath$, ResetList(ListModuleINI$()), 0, "ini")
   ForEach ListModuleINI$()
;       
      ModulePath$ = GetPathPart(ListModuleINI$())
      If OpenPreferences(ListModuleINI$())  
         PreferenceGroup("模块信息")       
         *pModule.__Module_BaseInfo = AddElement(_ListModule())         
         *pModule\ModuleGroup$ = ReadPreferenceString("模块编组", #Null$)
         *pModule\ModuleTypes$ = ReadPreferenceString("模块类型", #Null$)
         *pModule\ModuleName$  = ReadPreferenceString("模块名称", #Null$)         
         *pModule\ModuleModel$ = ReadPreferenceString("模块型号", #Null$)         
         *pModule\ModuleNote$  = ReadPreferenceString("模块说明", #Null$)          
         *pModule\ModuleIcon$  = ReadPreferenceString("模块图标", #Null$)          
         IsSymmetry$           = ReadPreferenceString("是否对称", #Null$) 
         *pModule\Resistance   = ReadPreferenceFloat ("元件电阻", #Null) 
         *pModule\CountEffect  = ReadPreferenceLong  ("特效数量", #Null) 
         *pModule\CountPins    = ReadPreferenceLong  ("引脚数量", #Null) 
         
         MapModule(*pModule\ModuleGroup$)
         *pModule\SortIndex = MapModule()
         If IsSymmetry$ = "是" : *pModule\IsSymmetry = #True : EndIf 
         
;          *pModule\ModuleName$  = ListModuleINI$()
         FileName$ = ModulePath$+*pModule\ModuleIcon$
         FileSize = FileSize(FileName$)
         If FileSize <= 0 
            Debug  ListModuleINI$()
            Debug "出错1001: [图像不存在]" + FileName$
            ProcedureReturn #Null 
         EndIf 
         *pModule\ModuleIcon$ = FileName$
         *pModule\IconSize = FileSize
         
         PreferenceGroup("模块图像")
         FileName$ = ReadPreferenceString("模块图像", #Null$)
         FileName$ = ModulePath$+FileName$
         FileSize = FileSize(FileName$)
         If FileSize <= 0 
            Debug  ListModuleINI$()
            Debug "出错1002: [图像不存在]" + FileName$ 
            ProcedureReturn #Null 
         EndIf 
         With *pModule\ModuleImage
            \FileName$ = FileName$
            \FileSize  = FileSize
            For i = 1 To *pModule\CountPins
               PinsParam$ = ReadPreferenceString("引脚-"+Str(i), #Null$) 
               *PinsParam.__Module_PinsParam = AddElement(\ListPinParam())
               *PinsParam\OffsetX = Val(StringField(PinsParam$, 1, ","))
               *PinsParam\OffsetY = Val(StringField(PinsParam$, 2, ","))
               *PinsParam\OffsetW = Val(StringField(PinsParam$, 3, ","))
               *PinsParam\OffsetH = Val(StringField(PinsParam$, 4, ","))
               *PinsParam\GroupIndex = i
            Next 
         EndWith    

         For k = 1 To *pModule\CountEffect
            PreferenceGroup("特效-"+Str(k)) 
            *pEffect.__Module_EffectInfo = AddElement(*pModule\ListEffect())
            FileName$   = ReadPreferenceString("模块图像", #Null$) 
            OffsetPos$  = ReadPreferenceString("特效位置", #Null$) 
            LinkModes$  = ReadPreferenceString("特效形式", #Null$) 
            EffectType$ = ReadPreferenceString("特效方式", #Null$) 
            EffectNote$ = ReadPreferenceString("特效描述", #Null$) 
            
            FileName$ = ModulePath$+FileName$
            FileSize = FileSize(FileName$)
            If FileSize <= 0 
               Debug  ListModuleINI$()
               Debug "出错1006: [图像不存在]" + FileName$ 
               ProcedureReturn #Null 
            EndIf 
            
            *pEffect\FileName$ = FileName$
            *pEffect\FileSize  = FileSize
            *pEffect\OffsetX   = Val(StringField(OffsetPos$, 1, ","))
            *pEffect\OffsetY   = Val(StringField(OffsetPos$, 2, ","))
            *pEffect\EffectNote$ = EffectNote$
            Select EffectType$
               Case "替换"   : *pEffect\EffectType = #EffectType_Replace
               Case "覆盖"   : *pEffect\EffectType = #EffectType_Cover
               Case "渐变"   : *pEffect\EffectType = #EffectType_Gradient
               Default  
                  Debug  ListModuleINI$()
                  Debug "出错1007: [特效方式不存在]" + EffectType$ 
                  ProcedureReturn #Null
            EndSelect  
  
         Next 
         For k = 1 To *pModule\CountPins
            PreferenceGroup("引脚-"+Str(k))  
            *pPinsAttri.__Module_PinsAttri = AddElement(*pModule\ListPinAttri())
            LinkModes$ = ReadPreferenceString ("接线方式", #Null$) 
            LinkTypes$ = ReadPreferenceString ("接线类型", #Null$) 
            Direction$ = ReadPreferenceString ("接线方向", #Null$) 
            PinsColor$ = ReadPreferenceString ("接线颜色", #Null$) 
            PinsGroup  = ReadPreferenceLong   ("引脚编组", #Null) 
            PinsLabel$ = ReadPreferenceString ("引脚标签", #Null$) 
            MaxVoltage.f = ReadPreferenceFloat("最大电压", #Null) 
            MinVoltage.f = ReadPreferenceFloat("最小电压", #Null) 
            
            LinkSocket$ = ReadPreferenceString("插孔排列", #Null$) 
            If LinkSocket$ <> #Null$
               
               CountSocket = Val(StringField(LinkSocket$, 1, "#"))
               If CountSocket
                  *pGroupParam.__Module_PinsParam = SelectElement(*pModule\ModuleImage\ListPinParam(), k-1)
                  *pGroupParam\GroupType = #GroupType_Group
                  *pGroupParam\IsSocket  = #True
                  LinkSocket$ = StringField(LinkSocket$, 2, "#")
                  For x = 1 To CountSocket
                     SocketPos$ = StringField(LinkSocket$, x, "|")
                     LastElement(*pModule\ModuleImage\ListPinParam())
                     *pPinsParam.__Module_PinsParam = AddElement(*pModule\ModuleImage\ListPinParam())
                     *pPinsParam\GroupIndex= *pGroupParam\GroupIndex
                     *pPinsParam\GroupType = #GroupType_Element
                     *pPinsParam\IsSocket  = #True
                     *pPinsParam\OffsetX = *pGroupParam\OffsetX+Val(StringField(SocketPos$, 1, ","))
                     *pPinsParam\OffsetY = *pGroupParam\OffsetY+Val(StringField(SocketPos$, 2, ","))
                     *pPinsParam\OffsetW = 0
                     *pPinsParam\OffsetH = 0
                  Next 
               EndIf
            EndIf 
            
            *pPinsAttri\PinsColor = Val(PinsColor$)
            *pPinsAttri\PinsGroup = PinsGroup
            *pPinsAttri\MaxVoltage= MaxVoltage
            *pPinsAttri\MinVoltage= MinVoltage
            *pPinsAttri\PinsLabel$= PinsLabel$
            Select LinkModes$
               Case "#LinkMode_Plug"      : *pPinsAttri\LinkModes = #LinkMode_Plug
               Case "#LinkMode_Socket"    : *pPinsAttri\LinkModes = #LinkMode_Socket
               Case "#LinkMode_Terminal"  : *pPinsAttri\LinkModes = #LinkMode_Terminal
               Default  
                  Debug  ListModuleINI$()
                  Debug "出错1003: [接线方式不存在]" + LinkModes$ 
                  ProcedureReturn #Null
            EndSelect    
            
            Select LinkTypes$
               Case "#LinkType_DC+" : *pPinsAttri\LinkTypes = #LinkType_DC1
               Case "#LinkType_DC-" : *pPinsAttri\LinkTypes = #LinkType_DC0
               Case "#LinkType_VCC" : *pPinsAttri\LinkTypes = #LinkType_VCC
               Case "#LinkType_GND" : *pPinsAttri\LinkTypes = #LinkType_GND
               Case "#LinkType_DO"  : *pPinsAttri\LinkTypes = #LinkType_DO
               Case "#LinkType_AO"  : *pPinsAttri\LinkTypes = #LinkType_AO
               Case "#LinkType_OCL" : *pPinsAttri\LinkTypes = #LinkType_OCL
               Case "#LinkType_PIN" : *pPinsAttri\LinkTypes = #LinkType_PIN
               Default 
                  Debug  ListModuleINI$()
                  Debug "出错1004: [接线类型]" + LinkTypes$ 
                  ProcedureReturn #Null
            EndSelect

            Count = CountString(Direction$, ",")+1
            For x = 1 To Count
               PartDirection$ = StringField(Direction$, x, ",")
               Select PartDirection$
                  Case "#Direction_Up"     : *pPinsAttri\Direction | #Direction_Up
                  Case "#Direction_Down"   : *pPinsAttri\Direction | #Direction_Down
                  Case "#Direction_Left"   : *pPinsAttri\Direction | #Direction_Left
                  Case "#Direction_Right"  : *pPinsAttri\Direction | #Direction_Right
                  Case "#Direction_PPUp"   : *pPinsAttri\Direction | #Direction_PPUp
                  Case "#Direction_PPDown" : *pPinsAttri\Direction | #Direction_PPDown
                  Case "#Direction_Socket" : *pPinsAttri\Direction | #Direction_Socket
                  Case "" : *pPinsAttri\Direction | #Direction_Socket
                  Default 
                     Debug  ListModuleINI$()
                     Debug "出错1005: [接线方向]" + PartDirection$ 
                     ProcedureReturn #Null 
               EndSelect            
            Next 
         Next  
         ClosePreferences()
         UseCount+1
         Debug "[OK]解析完毕: " + ListModuleINI$()
      Else 
         Debug "[NG]出错提示: [设置文件打不开] " + ListModuleINI$()
         ProcedureReturn #False
      EndIf 
   Next 
   SortStructuredList(_ListModule(), 0, OffsetOf(__Module_BaseInfo\ModuleName$), #PB_String)      
   SortStructuredList(_ListModule(), 0, OffsetOf(__Module_BaseInfo\SortIndex), #PB_Long)   
   ProcedureReturn UseCount
EndProcedure


;保存[模块设置.ini]到[模块设置.bin]
Procedure Save_Module(SaveName$)
   ;BIN结构: 头部+数据区+索引区 
   UsePNGImageDecoder()
   *MemData  = AllocateMemory($1000000)
   *MemIndex = AllocateMemory($10000)
   *MemPack  = AllocateMemory($10000)
   
   Notice$   = "创客电路图制图工具〖模块设置〗 开发:迷路仟"
   NoteAddr  = SizeOf(__Binary_Module_Header)
   NoteSize  = StringByteLength(Notice$, #PB_Ascii)+1
   NoteSize  = (NoteSize+3)/4*4        ;4字节对齐
   DataAddr  = NoteAddr+NoteSize
   *pHeader.__Binary_Module_Header = *MemData
   
   IdxCount = ListSize(_ListModule())
   With *pHeader
      \Flags      = $C3D6E8C9E9BFA3C4
      \HeadSize   = DataAddr
      \NoteAddr   = NoteAddr
      \Version    = #Version
      \IdxCount   = IdxCount
;       \IdxAddr    = DataAddr
      \CreateTime = Date()
      \InitalTime = #Null
   EndWith
   
   PokeS(*MemData+NoteAddr, Notice$,-1, #PB_Ascii) 
   PinsAttriSize = SizeOf(__Module_PinsAttri)
   PinsParamSize = 4*2
   
   Posd = DataAddr
   Posi = 0
   ForEach _ListModule()
      *pModule.__Module_BaseInfo = _ListModule()
      Debug *pModule\ModuleIcon$
      With *pModule
         ;索引块: 长度[1Byte]+模块类型[nByte]+长度[1Byte]+模块名称[nByte]+长度[1Byte]+模块说明[nByte]
         ;        +引脚数量[2Byte]+{__Module_PinsAttri}(引脚数量)+DimImageAddr.l[4]
         Lenght = StringByteLength(\ModuleTypes$, #PB_Ascii)+1
         PokeA(*MemIndex+Posi, Lenght)                            : Posi+1 
         PokeS(*MemIndex+Posi, \ModuleTypes$, -1, #PB_Ascii)      : Posi+Lenght
         
         Lenght = StringByteLength(\ModuleGroup$, #PB_Ascii)+1
         PokeA(*MemIndex+Posi, Lenght)                            : Posi+1 
         PokeS(*MemIndex+Posi, \ModuleGroup$, -1, #PB_Ascii)      : Posi+Lenght 
         
         Lenght = StringByteLength(\ModuleName$, #PB_Ascii)+1
         PokeA(*MemIndex+Posi, Lenght)                            : Posi+1 
         PokeS(*MemIndex+Posi, \ModuleName$, -1, #PB_Ascii)       : Posi+Lenght      
         
         Lenght = StringByteLength(\ModuleModel$, #PB_Ascii)+1
         PokeA(*MemIndex+Posi, Lenght)                            : Posi+1 
         PokeS(*MemIndex+Posi, \ModuleModel$, -1, #PB_Ascii)      : Posi+Lenght             
         
         Lenght = StringByteLength(\ModuleNote$, #PB_Ascii)+1
         PokeW(*MemIndex+Posi, Lenght)                            : Posi+2 
         PokeS(*MemIndex+Posi, \ModuleNote$, -1, #PB_Ascii)       : Posi+Lenght              
         
         PokeF(*MemIndex+Posi, \Resistance)                       : Posi+4    ;电阻值  <<<<<
         PokeB(*MemIndex+Posi, \IsSymmetry)                       : Posi+1  
         *pMemMaxSize = *MemIndex+Posi  : Posi+4  ;加载图片,最大的Size
         
         
         ;引脚属性
         CountPins = ListSize(\ListPinAttri())
         PokeW(*MemIndex+Posi, CountPins)                         : Posi+2
         ForEach \ListPinAttri()
            Lenght = StringByteLength(\ListPinAttri()\PinsLabel$, #PB_Ascii)+1
            PokeA(*MemIndex+Posi, Lenght)                                       : Posi+1 
            PokeS(*MemIndex+Posi, \ListPinAttri()\PinsLabel$, -1, #PB_Ascii)    : Posi+Lenght   
            PokeW(*MemIndex+Posi, \ListPinAttri()\LinkTypes)     : Posi+2             
            PokeW(*MemIndex+Posi, \ListPinAttri()\LinkModes)     : Posi+2 
            PokeW(*MemIndex+Posi, \ListPinAttri()\Direction)     : Posi+2 
            PokeW(*MemIndex+Posi, \ListPinAttri()\PinsGroup)     : Posi+2 
            PokeL(*MemIndex+Posi, \ListPinAttri()\PinsColor)     : Posi+4 
            PokeF(*MemIndex+Posi, \ListPinAttri()\MaxVoltage)    : Posi+4 
            PokeF(*MemIndex+Posi, \ListPinAttri()\MinVoltage)    : Posi+4 
         Next 

         ;ICON的数据地址
         PokeL(*MemIndex+Posi, Posd)                              : Posi+4  
         PokeL(*MemIndex+Posi, \IconSize)                         : Posi+4 
         If MaxIconSize < \IconSize : MaxIconSize = \IconSize : EndIf 

         ImageID = LoadImage(#PB_Any, \ModuleIcon$)
         If IsImage(ImageID) = 0 
            Debug "出错2001: [图像加载出错]" + \ModuleIcon$ 
            ProcedureReturn #Null 
         EndIf 
         FreeImage(ImageID)   
         mcsFileLoad_(\ModuleIcon$, *MemData+Posd, 0, \IconSize)  
         *pEncrypt.long = *MemData+Posd : *pEncrypt\l ! Posd   ;<--- 加密
         Posd+\IconSize+1

      EndWith
      
     
      MaxSizeValue = 0
      *pImageInfo.__Module_ImageInfo = *pModule\ModuleImage
      With *pImageInfo
         ImageID = LoadImage(#PB_Any, \FileName$)
         If IsImage(ImageID) = 0 
            Debug "出错2002: [图像加载出错]" + \FileName$ 
            ProcedureReturn #Null
         EndIf 
         If MaxSizeValue < \FileSize : MaxSizeValue = \FileSize : EndIf 
         PokeL(*MemIndex+Posi, Posd)                           : Posi+4
         PokeL(*MemIndex+Posi, \FileSize)                      : Posi+4
         PokeW(*MemIndex+Posi, ImageWidth (ImageID))           : Posi+2
         PokeW(*MemIndex+Posi, ImageHeight(ImageID))           : Posi+2             
         FreeImage(ImageID)
         
         CountParam = ListSize(\ListPinParam())
         PokeW(*MemIndex+Posi, CountParam)                    : Posi+2
         
         ;数据块: {__Module_PinsParam + 图像数据}[4]
         ForEach \ListPinParam()    
            PokeW(*MemIndex+Posi, \ListPinParam()\OffsetX)    : Posi+2      ;引脚相对位置
            PokeW(*MemIndex+Posi, \ListPinParam()\OffsetY)    : Posi+2      ;引脚相对位置
            PokeW(*MemIndex+Posi, \ListPinParam()\OffsetW)    : Posi+2      ;引脚相对位置
            PokeW(*MemIndex+Posi, \ListPinParam()\OffsetH)    : Posi+2      ;引脚相对位置
            
            PokeA(*MemIndex+Posi, \ListPinParam()\IsSocket)   : Posi+1    
            PokeA(*MemIndex+Posi, \ListPinParam()\GroupType)  : Posi+1    
            PokeW(*MemIndex+Posi, \ListPinParam()\GroupIndex) : Posi+2  
            
         Next 
         mcsFileLoad_(\FileName$, *MemData+Posd, 0, \FileSize)   
         *pEncrypt.long = *MemData+Posd : *pEncrypt\l ! Posd   ;<--- 加密
         Posd+\FileSize+1
      EndWith
      
      CountEffects = ListSize(*pModule\ListEffect())
      PokeW(*MemIndex+Posi, CountEffects)                         : Posi+2 
      ForEach *pModule\ListEffect()
         *pEffect.__Module_EffectInfo = *pModule\ListEffect()
         With *pEffect
            ImageID = LoadImage(#PB_Any, \FileName$)
            If IsImage(ImageID) = 0 
               Debug "出错2003: [图像加载出错]" + \FileName$ 
               ProcedureReturn #Null
            EndIf 
            If MaxSizeValue < \FileSize : MaxSizeValue = \FileSize : EndIf 
            PokeL(*MemIndex+Posi, Posd)                           : Posi+4
            PokeL(*MemIndex+Posi, \FileSize)                      : Posi+4
            PokeW(*MemIndex+Posi, \OffsetX)                       : Posi+2
            PokeW(*MemIndex+Posi, \OffsetY)                       : Posi+2
            PokeW(*MemIndex+Posi, ImageWidth (ImageID))           : Posi+2
            PokeW(*MemIndex+Posi, ImageHeight(ImageID))           : Posi+2 
            PokeW(*MemIndex+Posi, \EffectType)                    : Posi+2 
            Lenght = StringByteLength(\EffectNote$, #PB_Ascii)+1
            PokeA(*MemIndex+Posi, Lenght)                         : Posi+1 
            PokeS(*MemIndex+Posi, \EffectNote$, -1, #PB_Ascii)    : Posi+Lenght   
            
            FreeImage(ImageID)
            
            mcsFileLoad_(\FileName$, *MemData+Posd, 0, \FileSize)   
            *pEncrypt.long = *MemData+Posd : *pEncrypt\l ! Posd   ;<--- 加密
            Posd+\FileSize+1
         EndWith
      Next 
      PokeL(*pMemMaxSize, MaxSizeValue)  
   Next 

   Posi = (Posi+3)/4*4        ;4字节对齐
   Posd = (Posd+3)/4*4        ;4字节对齐
   ExtSize = Posi
   VirSize = Posi
   
   mcsZlibPack_(*MemPack, @VirSize, *MemIndex, ExtSize, 9)
   
   *pEncrypt.long = *MemPack : *pEncrypt\l ! Posd  ;<--- 加密
   *pHeader\IdxAddr = Posd
   *pHeader\ExtSize = ExtSize   
   *pHeader\VirSize = VirSize   
   *pHeader\MaxIconSize = MaxIconSize   
   
   UseMD5Fingerprint()   
   MD5$ = Fingerprint(*MemPack, VirSize, #PB_Cipher_MD5)
   PokeS(@*pHeader\MD5, MD5$, -1,  #PB_Ascii)
   CopyMemory(*MemPack, *MemData+Posd, VirSize)
   
   SaveSize = Posd+VirSize
   mcsFileSave_(SaveName$, *MemData, 0, SaveSize, SaveSize)
   FreeMemory(*MemPack)
   FreeMemory(*MemData)
   FreeMemory(*MemIndex)
   Debug "======================="
   Debug "打包成功!"
   MessageRequester(SaveName$, "打包成功!")
   
EndProcedure
; 
; 

MapModule("电子元件")    = Idx : Idx+1
MapModule("发光二极管")  = Idx : Idx+1
MapModule("开关元件")    = Idx : Idx+1
MapModule("光电模块")    = Idx : Idx+1
MapModule("电源模块")    = Idx : Idx+1

If Load_Module(".\Resources\")
   Save_Module(".\Module.bin")
Else
   MessageRequester("", "加载失败!")
EndIf 
; 
; 





; IDE Options = PureBasic 5.62 (Windows - x86)
; CursorPosition = 14
; Folding = c9
; EnableXP