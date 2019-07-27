<GameFile>
  <PropertyGroup Name="blinkeye" Type="Node" ID="8781fc5d-f6da-4dc9-9c86-b5d8cb969636" Version="3.10.0.0" />
  <Content ctype="GameProjectContent">
    <Content>
      <Animation Duration="300" Speed="1.0000">
        <Timeline ActionTag="958947761" Property="VisibleForFrame">
          <BoolFrame FrameIndex="0" Tween="False" Value="True" />
          <BoolFrame FrameIndex="70" Tween="False" Value="True" />
          <BoolFrame FrameIndex="300" Tween="False" Value="True" />
        </Timeline>
        <Timeline ActionTag="-2141948438" Property="VisibleForFrame">
          <BoolFrame FrameIndex="0" Tween="False" Value="False" />
          <BoolFrame FrameIndex="70" Tween="False" Value="True" />
          <BoolFrame FrameIndex="85" Tween="False" Value="False" />
        </Timeline>
      </Animation>
      <ObjectData Name="Node" Tag="324" ctype="GameNodeObjectData">
        <Size X="0.0000" Y="0.0000" />
        <Children>
          <AbstractNodeData Name="dealer" ActionTag="958947761" Tag="305" IconVisible="False" LeftMargin="-95.8222" RightMargin="-92.1778" TopMargin="-100.1788" BottomMargin="-93.8212" ctype="SpriteObjectData">
            <Size X="188.0000" Y="194.0000" />
            <AnchorPoint ScaleX="0.5000" ScaleY="0.5000" />
            <Position X="-1.8222" Y="3.1788" />
            <Scale ScaleX="1.0000" ScaleY="1.0000" />
            <CColor A="255" R="255" G="255" B="255" />
            <PrePosition />
            <PreSize X="0.0000" Y="0.0000" />
            <FileData Type="MarkedSubImage" Path="Common/Dealer.png" Plist="Common.plist" />
            <BlendFunc Src="770" Dst="771" />
          </AbstractNodeData>
          <AbstractNodeData Name="eye_2" ActionTag="-2141948438" VisibleForFrame="False" Tag="307" IconVisible="False" LeftMargin="-23.2413" RightMargin="-20.7587" TopMargin="-61.9461" BottomMargin="46.9461" ctype="SpriteObjectData">
            <Size X="44.0000" Y="15.0000" />
            <AnchorPoint ScaleX="0.5000" ScaleY="0.5000" />
            <Position X="-1.2413" Y="54.4461" />
            <Scale ScaleX="1.0000" ScaleY="1.0000" />
            <CColor A="255" R="255" G="255" B="255" />
            <PrePosition />
            <PreSize X="0.0000" Y="0.0000" />
            <FileData Type="MarkedSubImage" Path="Common/Blink_1 (2).png" Plist="Common.plist" />
            <BlendFunc Src="770" Dst="771" />
          </AbstractNodeData>
        </Children>
      </ObjectData>
    </Content>
  </Content>
</GameFile>