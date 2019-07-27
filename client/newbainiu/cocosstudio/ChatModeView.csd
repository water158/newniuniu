<GameFile>
  <PropertyGroup Name="ChatModeView" Type="Layer" ID="384208f0-312e-4986-85ca-59168211b1bf" Version="3.10.0.0" />
  <Content ctype="GameProjectContent">
    <Content>
      <Animation Duration="0" Speed="0.5000" />
      <ObjectData Name="Layer" Tag="185" ctype="GameLayerObjectData">
        <Size X="1280.0000" Y="720.0000" />
        <Children>
          <AbstractNodeData Name="bg" ActionTag="-1935360275" VisibleForFrame="False" Tag="1340" IconVisible="False" Scale9Enable="True" LeftEage="15" RightEage="15" TopEage="12" BottomEage="15" Scale9OriginX="15" Scale9OriginY="12" Scale9Width="1250" Scale9Height="693" ctype="ImageViewObjectData">
            <Size X="1280.0000" Y="720.0000" />
            <AnchorPoint ScaleX="0.5000" ScaleY="0.5000" />
            <Position X="640.0000" Y="360.0000" />
            <Scale ScaleX="1.0000" ScaleY="1.0000" />
            <CColor A="255" R="255" G="255" B="255" />
            <PrePosition X="0.5000" Y="0.5000" />
            <PreSize X="1.0000" Y="1.0000" />
            <FileData Type="Normal" Path="bigImage/bglayer.jpg" Plist="" />
          </AbstractNodeData>
          <AbstractNodeData Name="chatModebg" ActionTag="-2111366843" Tag="121" IconVisible="False" LeftMargin="1.4913" RightMargin="908.5087" TopMargin="516.2315" BottomMargin="3.7685" Scale9Enable="True" LeftEage="13" RightEage="13" TopEage="13" BottomEage="13" Scale9OriginX="13" Scale9OriginY="13" Scale9Width="15" Scale9Height="14" ctype="ImageViewObjectData">
            <Size X="370.0000" Y="200.0000" />
            <AnchorPoint ScaleX="0.5000" ScaleY="0.5000" />
            <Position X="186.4913" Y="103.7685" />
            <Scale ScaleX="1.0000" ScaleY="1.0000" />
            <CColor A="255" R="255" G="255" B="255" />
            <PrePosition X="0.1457" Y="0.1441" />
            <PreSize X="0.2891" Y="0.2778" />
            <FileData Type="MarkedSubImage" Path="Common/touming.png" Plist="Common.plist" />
          </AbstractNodeData>
          <AbstractNodeData Name="chatInputBg" ActionTag="-1515933727" Tag="119" IconVisible="False" LeftMargin="5.2730" RightMargin="984.7270" TopMargin="660.1565" BottomMargin="9.8435" TouchEnable="True" Scale9Enable="True" LeftEage="15" RightEage="15" TopEage="15" BottomEage="15" Scale9OriginX="15" Scale9OriginY="15" Scale9Width="18" Scale9Height="17" ctype="ImageViewObjectData">
            <Size X="290.0000" Y="50.0000" />
            <AnchorPoint ScaleX="0.5000" ScaleY="0.5000" />
            <Position X="150.2730" Y="34.8435" />
            <Scale ScaleX="1.0000" ScaleY="1.0000" />
            <CColor A="255" R="255" G="255" B="255" />
            <PrePosition X="0.1174" Y="0.0484" />
            <PreSize X="0.2266" Y="0.0694" />
            <FileData Type="MarkedSubImage" Path="mainSceneP/ChatInput.png" Plist="mainSceneP.plist" />
          </AbstractNodeData>
          <AbstractNodeData Name="Button_send" ActionTag="-407802128" Tag="117" IconVisible="False" LeftMargin="290.5361" RightMargin="911.4639" TopMargin="658.6800" BottomMargin="8.3200" TouchEnable="True" FontSize="14" Scale9Enable="True" LeftEage="15" RightEage="15" TopEage="11" BottomEage="11" Scale9OriginX="15" Scale9OriginY="11" Scale9Width="48" Scale9Height="31" ShadowOffsetX="2.0000" ShadowOffsetY="-2.0000" ctype="ButtonObjectData">
            <Size X="78.0000" Y="53.0000" />
            <AnchorPoint ScaleX="0.5000" ScaleY="0.5000" />
            <Position X="329.5361" Y="34.8200" />
            <Scale ScaleX="1.0000" ScaleY="1.0000" />
            <CColor A="255" R="255" G="255" B="255" />
            <PrePosition X="0.2575" Y="0.0484" />
            <PreSize X="0.0609" Y="0.0736" />
            <TextColor A="255" R="65" G="65" B="70" />
            <PressedFileData Type="MarkedSubImage" Path="Common/SendButton.png" Plist="Common.plist" />
            <NormalFileData Type="MarkedSubImage" Path="Common/SendButton.png" Plist="Common.plist" />
            <OutlineColor A="255" R="255" G="0" B="0" />
            <ShadowColor A="255" R="110" G="110" B="110" />
          </AbstractNodeData>
          <AbstractNodeData Name="TextField_msg" ActionTag="1621809859" Tag="118" IconVisible="False" LeftMargin="13.8600" RightMargin="991.1400" TopMargin="667.6600" BottomMargin="17.3400" TouchEnable="True" FontSize="30" IsCustomSize="True" LabelText="" PlaceHolderText="请输入聊天内容" MaxLengthText="10" ctype="TextFieldObjectData">
            <Size X="275.0000" Y="35.0000" />
            <AnchorPoint ScaleY="0.5000" />
            <Position X="13.8600" Y="34.8400" />
            <Scale ScaleX="1.0000" ScaleY="1.0000" />
            <CColor A="255" R="255" G="255" B="255" />
            <PrePosition X="0.0108" Y="0.0484" />
            <PreSize X="0.2148" Y="0.0486" />
          </AbstractNodeData>
          <AbstractNodeData Name="ListView_Chat" ActionTag="1965534906" VisibleForFrame="False" Tag="910" IconVisible="False" LeftMargin="2.0000" RightMargin="914.0000" TopMargin="522.0000" BottomMargin="62.0000" ClipAble="True" BackColorAlpha="167" ComboBoxIndex="1" ColorAngle="90.0000" IsBounceEnabled="True" ScrollDirectionType="0" DirectionType="Vertical" ctype="ListViewObjectData">
            <Size X="364.0000" Y="136.0000" />
            <AnchorPoint />
            <Position X="2.0000" Y="62.0000" />
            <Scale ScaleX="1.0000" ScaleY="1.0000" />
            <CColor A="255" R="255" G="255" B="255" />
            <PrePosition X="0.0016" Y="0.0861" />
            <PreSize X="0.2844" Y="0.1889" />
            <SingleColor A="255" R="150" G="150" B="255" />
            <FirstColor A="255" R="150" G="150" B="255" />
            <EndColor A="255" R="255" G="255" B="255" />
            <ColorVector ScaleY="1.0000" />
          </AbstractNodeData>
        </Children>
      </ObjectData>
    </Content>
  </Content>
</GameFile>