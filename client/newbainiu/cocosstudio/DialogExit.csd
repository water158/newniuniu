<GameFile>
  <PropertyGroup Name="DialogExit" Type="Layer" ID="cc454da2-5093-43ab-b079-7e62aac903f4" Version="3.10.0.0" />
  <Content ctype="GameProjectContent">
    <Content>
      <Animation Duration="0" Speed="1.0000" />
      <ObjectData Name="Layer" Tag="138" ctype="GameLayerObjectData">
        <Size X="1280.0000" Y="720.0000" />
        <Children>
          <AbstractNodeData Name="bg" ActionTag="893622239" Tag="139" IconVisible="False" LeftMargin="183.0005" RightMargin="173.9995" TopMargin="48.5370" BottomMargin="53.4630" Scale9Enable="True" LeftEage="15" RightEage="15" TopEage="15" BottomEage="15" Scale9OriginX="15" Scale9OriginY="15" Scale9Width="893" Scale9Height="588" ctype="ImageViewObjectData">
            <Size X="923.0000" Y="618.0000" />
            <AnchorPoint ScaleX="0.5000" ScaleY="0.5000" />
            <Position X="644.5005" Y="362.4630" />
            <Scale ScaleX="0.8000" ScaleY="0.8000" />
            <CColor A="255" R="255" G="255" B="255" />
            <PrePosition X="0.5035" Y="0.5034" />
            <PreSize X="0.7211" Y="0.8583" />
            <FileData Type="Normal" Path="bigImage/dialogbackground.png" Plist="" />
          </AbstractNodeData>
          <AbstractNodeData Name="warmpromptText" ActionTag="593752236" Tag="140" IconVisible="False" LeftMargin="547.0000" RightMargin="547.0000" TopMargin="129.1083" BottomMargin="542.8917" Scale9Enable="True" LeftEage="15" RightEage="15" TopEage="13" BottomEage="13" Scale9OriginX="15" Scale9OriginY="13" Scale9Width="156" Scale9Height="22" ctype="ImageViewObjectData">
            <Size X="186.0000" Y="48.0000" />
            <AnchorPoint ScaleX="0.5000" ScaleY="0.5000" />
            <Position X="640.0000" Y="566.8917" />
            <Scale ScaleX="1.1000" ScaleY="1.1000" />
            <CColor A="255" R="255" G="255" B="255" />
            <PrePosition X="0.5000" Y="0.7873" />
            <PreSize X="0.1453" Y="0.0667" />
            <FileData Type="MarkedSubImage" Path="Text/tips.png" Plist="text.plist" />
          </AbstractNodeData>
          <AbstractNodeData Name="exit" ActionTag="1240827819" CallBackType="Click" Tag="141" IconVisible="False" LeftMargin="933.4727" RightMargin="260.5273" TopMargin="110.0130" BottomMargin="523.9870" TouchEnable="True" FontSize="14" Scale9Enable="True" LeftEage="15" RightEage="15" TopEage="11" BottomEage="11" Scale9OriginX="15" Scale9OriginY="11" Scale9Width="56" Scale9Height="64" ShadowOffsetX="2.0000" ShadowOffsetY="-2.0000" ctype="ButtonObjectData">
            <Size X="86.0000" Y="86.0000" />
            <AnchorPoint ScaleX="0.5000" ScaleY="0.5000" />
            <Position X="976.4727" Y="566.9870" />
            <Scale ScaleX="1.0000" ScaleY="1.0000" />
            <CColor A="255" R="255" G="255" B="255" />
            <PrePosition X="0.7629" Y="0.7875" />
            <PreSize X="0.0672" Y="0.1194" />
            <TextColor A="255" R="65" G="65" B="70" />
            <DisabledFileData Type="MarkedSubImage" Path="Common/exit.png" Plist="Common.plist" />
            <PressedFileData Type="MarkedSubImage" Path="Common/exit.png" Plist="Common.plist" />
            <NormalFileData Type="MarkedSubImage" Path="Common/exit.png" Plist="Common.plist" />
            <OutlineColor A="255" R="255" G="0" B="0" />
            <ShadowColor A="255" R="110" G="110" B="110" />
          </AbstractNodeData>
          <AbstractNodeData Name="tipscontent" ActionTag="-220841032" Tag="142" IconVisible="False" LeftMargin="469.0000" RightMargin="469.0000" TopMargin="321.4575" BottomMargin="360.5425" FontSize="38" LabelText="确定要退出游戏吗？" HorizontalAlignmentType="HT_Center" VerticalAlignmentType="VT_Center" ShadowOffsetX="2.0000" ShadowOffsetY="-2.0000" ctype="TextObjectData">
            <Size X="342.0000" Y="38.0000" />
            <AnchorPoint ScaleX="0.5000" ScaleY="0.5000" />
            <Position X="640.0000" Y="379.5425" />
            <Scale ScaleX="1.0000" ScaleY="1.0000" />
            <CColor A="255" R="255" G="165" B="0" />
            <PrePosition X="0.5000" Y="0.5271" />
            <PreSize X="0.2672" Y="0.0528" />
            <OutlineColor A="255" R="255" G="0" B="0" />
            <ShadowColor A="255" R="110" G="110" B="110" />
          </AbstractNodeData>
          <AbstractNodeData Name="ensure" ActionTag="-296086904" Tag="143" IconVisible="False" LeftMargin="395.5306" RightMargin="713.4694" TopMargin="463.4181" BottomMargin="172.5819" TouchEnable="True" FontSize="14" Scale9Enable="True" LeftEage="15" RightEage="15" TopEage="11" BottomEage="11" Scale9OriginX="15" Scale9OriginY="11" Scale9Width="141" Scale9Height="62" ShadowOffsetX="2.0000" ShadowOffsetY="-2.0000" ctype="ButtonObjectData">
            <Size X="171.0000" Y="84.0000" />
            <AnchorPoint ScaleX="0.5000" ScaleY="0.5000" />
            <Position X="481.0306" Y="214.5819" />
            <Scale ScaleX="1.0000" ScaleY="1.0000" />
            <CColor A="255" R="255" G="255" B="255" />
            <PrePosition X="0.3758" Y="0.2980" />
            <PreSize X="0.1336" Y="0.1167" />
            <TextColor A="255" R="65" G="65" B="70" />
            <PressedFileData Type="MarkedSubImage" Path="Common/ensure.png" Plist="Common.plist" />
            <NormalFileData Type="MarkedSubImage" Path="Common/ensure.png" Plist="Common.plist" />
            <OutlineColor A="255" R="255" G="0" B="0" />
            <ShadowColor A="255" R="110" G="110" B="110" />
          </AbstractNodeData>
          <AbstractNodeData Name="cancel" ActionTag="1797547132" CallBackType="Touch" Tag="144" IconVisible="False" LeftMargin="714.5000" RightMargin="394.5000" TopMargin="463.4203" BottomMargin="172.5797" TouchEnable="True" FontSize="14" Scale9Enable="True" LeftEage="15" RightEage="15" TopEage="11" BottomEage="11" Scale9OriginX="15" Scale9OriginY="11" Scale9Width="141" Scale9Height="62" ShadowOffsetX="2.0000" ShadowOffsetY="-2.0000" ctype="ButtonObjectData">
            <Size X="171.0000" Y="84.0000" />
            <AnchorPoint ScaleX="0.5000" ScaleY="0.5000" />
            <Position X="800.0000" Y="214.5797" />
            <Scale ScaleX="1.0000" ScaleY="1.0000" />
            <CColor A="255" R="255" G="255" B="255" />
            <PrePosition X="0.6250" Y="0.2980" />
            <PreSize X="0.1336" Y="0.1167" />
            <TextColor A="255" R="65" G="65" B="70" />
            <PressedFileData Type="MarkedSubImage" Path="Common/cancel.png" Plist="Common.plist" />
            <NormalFileData Type="MarkedSubImage" Path="Common/cancel.png" Plist="Common.plist" />
            <OutlineColor A="255" R="255" G="0" B="0" />
            <ShadowColor A="255" R="110" G="110" B="110" />
          </AbstractNodeData>
        </Children>
      </ObjectData>
    </Content>
  </Content>
</GameFile>