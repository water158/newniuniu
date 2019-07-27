<GameFile>
  <PropertyGroup Name="DialogSafeBox" Type="Layer" ID="45ddf89e-439b-4ad4-b54c-cc3c22ae232f" Version="3.10.0.0" />
  <Content ctype="GameProjectContent">
    <Content>
      <Animation Duration="0" Speed="1.0000" />
      <ObjectData Name="Layer" Tag="632" ctype="GameLayerObjectData">
        <Size X="1280.0000" Y="720.0000" />
        <Children>
          <AbstractNodeData Name="bg" ActionTag="1552951022" Tag="860" IconVisible="False" LeftMargin="202.2621" RightMargin="197.7379" TopMargin="89.3394" BottomMargin="90.6606" Scale9Enable="True" LeftEage="15" RightEage="15" TopEage="15" BottomEage="15" Scale9OriginX="15" Scale9OriginY="15" Scale9Width="893" Scale9Height="588" ctype="ImageViewObjectData">
            <Size X="880.0000" Y="540.0000" />
            <AnchorPoint ScaleX="0.5000" ScaleY="0.5000" />
            <Position X="642.2621" Y="360.6606" />
            <Scale ScaleX="1.0000" ScaleY="1.0000" />
            <CColor A="255" R="255" G="255" B="255" />
            <PrePosition X="0.5018" Y="0.5009" />
            <PreSize X="0.6875" Y="0.7500" />
            <FileData Type="Normal" Path="bigImage/dialogbackground.png" Plist="" />
          </AbstractNodeData>
          <AbstractNodeData Name="text" ActionTag="1289251955" Tag="861" IconVisible="False" LeftMargin="570.0000" RightMargin="570.0000" TopMargin="115.5000" BottomMargin="555.5000" Scale9Enable="True" LeftEage="15" RightEage="15" TopEage="15" BottomEage="15" Scale9OriginX="15" Scale9OriginY="15" Scale9Width="110" Scale9Height="19" ctype="ImageViewObjectData">
            <Size X="140.0000" Y="49.0000" />
            <AnchorPoint ScaleX="0.5000" ScaleY="0.5000" />
            <Position X="640.0000" Y="580.0000" />
            <Scale ScaleX="1.0000" ScaleY="1.0000" />
            <CColor A="255" R="255" G="255" B="255" />
            <PrePosition X="0.5000" Y="0.8056" />
            <PreSize X="0.1094" Y="0.0681" />
            <FileData Type="MarkedSubImage" Path="Text/safeBox.png" Plist="text.plist" />
          </AbstractNodeData>
          <AbstractNodeData Name="exit" ActionTag="416971590" Tag="862" IconVisible="False" LeftMargin="997.6785" RightMargin="196.3215" TopMargin="92.2582" BottomMargin="541.7418" TouchEnable="True" FontSize="14" Scale9Enable="True" LeftEage="15" RightEage="15" TopEage="11" BottomEage="11" Scale9OriginX="15" Scale9OriginY="11" Scale9Width="56" Scale9Height="64" ShadowOffsetX="2.0000" ShadowOffsetY="-2.0000" ctype="ButtonObjectData">
            <Size X="86.0000" Y="86.0000" />
            <AnchorPoint ScaleX="0.5000" ScaleY="0.5000" />
            <Position X="1040.6785" Y="584.7418" />
            <Scale ScaleX="1.0000" ScaleY="1.0000" />
            <CColor A="255" R="255" G="255" B="255" />
            <PrePosition X="0.8130" Y="0.8121" />
            <PreSize X="0.0672" Y="0.1194" />
            <TextColor A="255" R="65" G="65" B="70" />
            <DisabledFileData Type="MarkedSubImage" Path="Common/exit.png" Plist="Common.plist" />
            <PressedFileData Type="MarkedSubImage" Path="Common/exit.png" Plist="Common.plist" />
            <NormalFileData Type="MarkedSubImage" Path="Common/exit.png" Plist="Common.plist" />
            <OutlineColor A="255" R="255" G="0" B="0" />
            <ShadowColor A="255" R="110" G="110" B="110" />
          </AbstractNodeData>
          <AbstractNodeData Name="current_coin_text" ActionTag="-1321539634" Tag="887" IconVisible="False" LeftMargin="288.8668" RightMargin="859.1332" TopMargin="198.0000" BottomMargin="498.0000" FontSize="24" LabelText="当前游戏币:" ShadowOffsetX="2.0000" ShadowOffsetY="-2.0000" ctype="TextObjectData">
            <Size X="132.0000" Y="24.0000" />
            <AnchorPoint ScaleX="0.5000" ScaleY="0.5000" />
            <Position X="354.8668" Y="510.0000" />
            <Scale ScaleX="1.0000" ScaleY="1.0000" />
            <CColor A="255" R="228" G="184" B="23" />
            <PrePosition X="0.2772" Y="0.7083" />
            <PreSize X="0.0000" Y="0.0000" />
            <OutlineColor A="255" R="255" G="0" B="0" />
            <ShadowColor A="255" R="110" G="110" B="110" />
          </AbstractNodeData>
          <AbstractNodeData Name="current_coins" ActionTag="-2097214173" Tag="888" IconVisible="False" LeftMargin="428.1841" RightMargin="791.8159" TopMargin="198.0000" BottomMargin="498.0000" FontSize="24" LabelText="0" ShadowOffsetX="2.0000" ShadowOffsetY="-2.0000" ctype="TextObjectData">
            <Size X="12.0000" Y="24.0000" />
            <AnchorPoint ScaleY="0.5000" />
            <Position X="428.1841" Y="510.0000" />
            <Scale ScaleX="1.0000" ScaleY="1.0000" />
            <CColor A="255" R="255" G="255" B="0" />
            <PrePosition X="0.3345" Y="0.7083" />
            <PreSize X="0.0000" Y="0.0000" />
            <OutlineColor A="255" R="255" G="0" B="0" />
            <ShadowColor A="255" R="110" G="110" B="110" />
          </AbstractNodeData>
          <AbstractNodeData Name="safebox_coin_text" ActionTag="867968228" Tag="889" IconVisible="False" LeftMargin="645.4234" RightMargin="478.5766" TopMargin="198.0000" BottomMargin="498.0000" FontSize="24" LabelText="保险箱游戏币:" ShadowOffsetX="2.0000" ShadowOffsetY="-2.0000" ctype="TextObjectData">
            <Size X="156.0000" Y="24.0000" />
            <AnchorPoint ScaleX="0.5000" ScaleY="0.5000" />
            <Position X="723.4234" Y="510.0000" />
            <Scale ScaleX="1.0000" ScaleY="1.0000" />
            <CColor A="255" R="228" G="184" B="23" />
            <PrePosition X="0.5652" Y="0.7083" />
            <PreSize X="0.0000" Y="0.0000" />
            <OutlineColor A="255" R="255" G="0" B="0" />
            <ShadowColor A="255" R="110" G="110" B="110" />
          </AbstractNodeData>
          <AbstractNodeData Name="safebox_coins" ActionTag="209052078" Tag="890" IconVisible="False" LeftMargin="810.0704" RightMargin="457.9296" TopMargin="198.0000" BottomMargin="498.0000" FontSize="24" LabelText="0" ShadowOffsetX="2.0000" ShadowOffsetY="-2.0000" ctype="TextObjectData">
            <Size X="12.0000" Y="24.0000" />
            <AnchorPoint ScaleY="0.5000" />
            <Position X="810.0704" Y="510.0000" />
            <Scale ScaleX="1.0000" ScaleY="1.0000" />
            <CColor A="255" R="255" G="255" B="0" />
            <PrePosition X="0.6329" Y="0.7083" />
            <PreSize X="0.0000" Y="0.0000" />
            <OutlineColor A="255" R="255" G="0" B="0" />
            <ShadowColor A="255" R="110" G="110" B="110" />
          </AbstractNodeData>
          <AbstractNodeData Name="toumingbg" ActionTag="29023912" Tag="895" IconVisible="False" LeftMargin="242.4577" RightMargin="237.5422" TopMargin="279.7032" BottomMargin="140.2968" Scale9Enable="True" LeftEage="13" RightEage="13" TopEage="13" BottomEage="13" Scale9OriginX="13" Scale9OriginY="13" Scale9Width="15" Scale9Height="14" ctype="ImageViewObjectData">
            <Size X="800.0000" Y="300.0000" />
            <AnchorPoint ScaleX="0.5000" ScaleY="0.5000" />
            <Position X="642.4577" Y="290.2968" />
            <Scale ScaleX="1.0000" ScaleY="1.0000" />
            <CColor A="255" R="255" G="255" B="255" />
            <PrePosition X="0.5019" Y="0.4032" />
            <PreSize X="0.6250" Y="0.4167" />
            <FileData Type="MarkedSubImage" Path="Common/touming.png" Plist="Common.plist" />
          </AbstractNodeData>
          <AbstractNodeData Name="touch_1" ActionTag="-1417085676" Tag="276" IconVisible="False" LeftMargin="245.0300" RightMargin="897.9700" TopMargin="239.0000" BottomMargin="437.0000" Scale9Enable="True" LeftEage="15" RightEage="15" TopEage="14" BottomEage="14" Scale9OriginX="15" Scale9OriginY="14" Scale9Width="107" Scale9Height="16" ctype="ImageViewObjectData">
            <Size X="137.0000" Y="44.0000" />
            <AnchorPoint ScaleX="0.5000" ScaleY="0.5000" />
            <Position X="313.5300" Y="459.0000" />
            <Scale ScaleX="1.0000" ScaleY="1.0000" />
            <CColor A="255" R="255" G="255" B="255" />
            <PrePosition X="0.2449" Y="0.6375" />
            <PreSize X="0.1070" Y="0.0611" />
            <FileData Type="MarkedSubImage" Path="Common/depositY.png" Plist="Common.plist" />
          </AbstractNodeData>
          <AbstractNodeData Name="touch_2" ActionTag="820080166" Tag="277" IconVisible="False" LeftMargin="367.4800" RightMargin="775.5200" TopMargin="239.0000" BottomMargin="437.0000" Scale9Enable="True" LeftEage="15" RightEage="15" TopEage="14" BottomEage="14" Scale9OriginX="15" Scale9OriginY="14" Scale9Width="107" Scale9Height="16" ctype="ImageViewObjectData">
            <Size X="137.0000" Y="44.0000" />
            <AnchorPoint ScaleX="0.5000" ScaleY="0.5000" />
            <Position X="435.9800" Y="459.0000" />
            <Scale ScaleX="1.0000" ScaleY="1.0000" />
            <CColor A="255" R="255" G="255" B="255" />
            <PrePosition X="0.3406" Y="0.6375" />
            <PreSize X="0.1070" Y="0.0611" />
            <FileData Type="MarkedSubImage" Path="Common/cashN.png" Plist="Common.plist" />
          </AbstractNodeData>
          <AbstractNodeData Name="touch_3" ActionTag="760281468" Tag="278" IconVisible="False" LeftMargin="490.8444" RightMargin="652.1556" TopMargin="238.9999" BottomMargin="437.0001" Scale9Enable="True" LeftEage="15" RightEage="15" TopEage="14" BottomEage="14" Scale9OriginX="15" Scale9OriginY="14" Scale9Width="107" Scale9Height="16" ctype="ImageViewObjectData">
            <Size X="137.0000" Y="44.0000" />
            <AnchorPoint ScaleX="0.5000" ScaleY="0.5000" />
            <Position X="559.3444" Y="459.0001" />
            <Scale ScaleX="1.0000" ScaleY="1.0000" />
            <CColor A="255" R="255" G="255" B="255" />
            <PrePosition X="0.4370" Y="0.6375" />
            <PreSize X="0.1070" Y="0.0611" />
            <FileData Type="MarkedSubImage" Path="Common/recordN.png" Plist="Common.plist" />
          </AbstractNodeData>
          <AbstractNodeData Name="touch_4" ActionTag="1660889120" Tag="279" IconVisible="False" LeftMargin="612.5000" RightMargin="530.5000" TopMargin="239.0000" BottomMargin="437.0000" Scale9Enable="True" LeftEage="15" RightEage="15" TopEage="14" BottomEage="14" Scale9OriginX="15" Scale9OriginY="14" Scale9Width="107" Scale9Height="16" ctype="ImageViewObjectData">
            <Size X="137.0000" Y="44.0000" />
            <AnchorPoint ScaleX="0.5000" ScaleY="0.5000" />
            <Position X="681.0000" Y="459.0000" />
            <Scale ScaleX="1.0000" ScaleY="1.0000" />
            <CColor A="255" R="255" G="255" B="255" />
            <PrePosition X="0.5320" Y="0.6375" />
            <PreSize X="0.1070" Y="0.0611" />
            <FileData Type="MarkedSubImage" Path="Common/changepasswordN.png" Plist="Common.plist" />
          </AbstractNodeData>
          <AbstractNodeData Name="ChangePanel_1" ActionTag="1840081589" Tag="432" IconVisible="False" LeftMargin="240.8234" RightMargin="239.1765" TopMargin="283.3213" BottomMargin="136.6787" TouchEnable="True" ClipAble="False" BackColorAlpha="0" ComboBoxIndex="1" ColorAngle="90.0000" ctype="PanelObjectData">
            <Size X="800.0000" Y="300.0000" />
            <Children>
              <AbstractNodeData Name="one_Text_tips" ActionTag="977505915" Tag="433" IconVisible="False" LeftMargin="42.0771" RightMargin="565.9229" TopMargin="18.0000" BottomMargin="258.0000" FontSize="24" LabelText="请选择存款金额：" ShadowOffsetX="2.0000" ShadowOffsetY="-2.0000" ctype="TextObjectData">
                <Size X="192.0000" Y="24.0000" />
                <AnchorPoint ScaleX="0.5000" ScaleY="0.5000" />
                <Position X="138.0771" Y="270.0000" />
                <Scale ScaleX="1.0000" ScaleY="1.0000" />
                <CColor A="255" R="228" G="184" B="23" />
                <PrePosition X="0.1726" Y="0.9000" />
                <PreSize X="0.0000" Y="0.0000" />
                <OutlineColor A="255" R="255" G="0" B="0" />
                <ShadowColor A="255" R="110" G="110" B="110" />
              </AbstractNodeData>
              <AbstractNodeData Name="one_safeminus" ActionTag="112668263" Tag="434" IconVisible="False" LeftMargin="32.5218" RightMargin="712.4782" TopMargin="73.5000" BottomMargin="169.5000" TouchEnable="True" FontSize="14" Scale9Enable="True" LeftEage="15" RightEage="15" TopEage="11" BottomEage="11" Scale9OriginX="15" Scale9OriginY="11" Scale9Width="25" Scale9Height="35" ShadowOffsetX="2.0000" ShadowOffsetY="-2.0000" ctype="ButtonObjectData">
                <Size X="55.0000" Y="57.0000" />
                <AnchorPoint ScaleX="0.5000" ScaleY="0.5000" />
                <Position X="60.0218" Y="198.0000" />
                <Scale ScaleX="1.0000" ScaleY="1.0000" />
                <CColor A="255" R="255" G="255" B="255" />
                <PrePosition X="0.0750" Y="0.6600" />
                <PreSize X="0.0688" Y="0.1900" />
                <TextColor A="255" R="65" G="65" B="70" />
                <PressedFileData Type="MarkedSubImage" Path="Common/safeminus.png" Plist="Common.plist" />
                <NormalFileData Type="MarkedSubImage" Path="Common/safeminus.png" Plist="Common.plist" />
                <OutlineColor A="255" R="255" G="0" B="0" />
                <ShadowColor A="255" R="110" G="110" B="110" />
              </AbstractNodeData>
              <AbstractNodeData Name="one_safeadd" ActionTag="554493742" Tag="435" IconVisible="False" LeftMargin="714.7309" RightMargin="30.2691" TopMargin="73.5000" BottomMargin="169.5000" TouchEnable="True" FontSize="14" Scale9Enable="True" LeftEage="15" RightEage="15" TopEage="11" BottomEage="11" Scale9OriginX="15" Scale9OriginY="11" Scale9Width="25" Scale9Height="35" ShadowOffsetX="2.0000" ShadowOffsetY="-2.0000" ctype="ButtonObjectData">
                <Size X="55.0000" Y="57.0000" />
                <AnchorPoint ScaleX="0.5000" ScaleY="0.5000" />
                <Position X="742.2309" Y="198.0000" />
                <Scale ScaleX="1.0000" ScaleY="1.0000" />
                <CColor A="255" R="255" G="255" B="255" />
                <PrePosition X="0.9278" Y="0.6600" />
                <PreSize X="0.0688" Y="0.1900" />
                <TextColor A="255" R="65" G="65" B="70" />
                <PressedFileData Type="MarkedSubImage" Path="Common/safeadd.png" Plist="Common.plist" />
                <NormalFileData Type="MarkedSubImage" Path="Common/safeadd.png" Plist="Common.plist" />
                <OutlineColor A="255" R="255" G="0" B="0" />
                <ShadowColor A="255" R="110" G="110" B="110" />
              </AbstractNodeData>
              <AbstractNodeData Name="one_Slider" ActionTag="1778557453" Tag="436" IconVisible="False" LeftMargin="144.9551" RightMargin="155.0449" TopMargin="85.0000" BottomMargin="181.0000" TouchEnable="True" ctype="SliderObjectData">
                <Size X="500.0000" Y="34.0000" />
                <AnchorPoint ScaleX="0.5000" ScaleY="0.5000" />
                <Position X="394.9551" Y="198.0000" />
                <Scale ScaleX="1.0000" ScaleY="1.0000" />
                <CColor A="255" R="255" G="255" B="255" />
                <PrePosition X="0.4937" Y="0.6600" />
                <PreSize X="0.3906" Y="0.0472" />
                <BackGroundData Type="MarkedSubImage" Path="Common/sliderbg.png" Plist="Common.plist" />
                <ProgressBarData Type="MarkedSubImage" Path="Common/slider.png" Plist="Common.plist" />
                <BallNormalData Type="MarkedSubImage" Path="Common/slidermenu.png" Plist="Common.plist" />
                <BallPressedData Type="MarkedSubImage" Path="Common/slidermenu.png" Plist="Common.plist" />
                <BallDisabledData Type="MarkedSubImage" Path="Common/slidermenu.png" Plist="Common.plist" />
              </AbstractNodeData>
              <AbstractNodeData Name="one_input_Bg" ActionTag="2091723245" Tag="437" IconVisible="False" LeftMargin="147.7173" RightMargin="152.2827" TopMargin="142.0000" BottomMargin="98.0000" Scale9Enable="True" LeftEage="9" RightEage="9" TopEage="9" BottomEage="9" Scale9OriginX="9" Scale9OriginY="9" Scale9Width="11" Scale9Height="12" ctype="ImageViewObjectData">
                <Size X="500.0000" Y="60.0000" />
                <AnchorPoint ScaleX="0.5000" ScaleY="0.5000" />
                <Position X="397.7173" Y="128.0000" />
                <Scale ScaleX="1.0000" ScaleY="1.0000" />
                <CColor A="255" R="255" G="255" B="255" />
                <PrePosition X="0.4971" Y="0.4267" />
                <PreSize X="0.6250" Y="0.2000" />
                <FileData Type="MarkedSubImage" Path="Common/InputboxCoins.png" Plist="Common.plist" />
              </AbstractNodeData>
              <AbstractNodeData Name="deposit" ActionTag="1152406521" Tag="438" IconVisible="False" LeftMargin="313.2984" RightMargin="315.7016" TopMargin="206.6280" BottomMargin="13.3720" TouchEnable="True" FontSize="14" Scale9Enable="True" LeftEage="15" RightEage="15" TopEage="11" BottomEage="11" Scale9OriginX="15" Scale9OriginY="11" Scale9Width="141" Scale9Height="62" ShadowOffsetX="2.0000" ShadowOffsetY="-2.0000" ctype="ButtonObjectData">
                <Size X="171.0000" Y="80.0000" />
                <AnchorPoint ScaleX="0.5000" ScaleY="0.5000" />
                <Position X="398.7984" Y="53.3720" />
                <Scale ScaleX="1.0000" ScaleY="1.0000" />
                <CColor A="255" R="255" G="255" B="255" />
                <PrePosition X="0.4985" Y="0.1779" />
                <PreSize X="0.2138" Y="0.2667" />
                <TextColor A="255" R="65" G="65" B="70" />
                <PressedFileData Type="MarkedSubImage" Path="Common/depositButton.png" Plist="Common.plist" />
                <NormalFileData Type="MarkedSubImage" Path="Common/depositButton.png" Plist="Common.plist" />
                <OutlineColor A="255" R="255" G="0" B="0" />
                <ShadowColor A="255" R="110" G="110" B="110" />
              </AbstractNodeData>
              <AbstractNodeData Name="DepositCoinsNums" ActionTag="-1739552256" Tag="439" IconVisible="False" LeftMargin="366.5567" RightMargin="377.4433" TopMargin="157.0228" BottomMargin="114.9772" FontSize="28" LabelText="0" ShadowOffsetX="2.0000" ShadowOffsetY="-2.0000" ctype="TextObjectData">
                <Size X="14.0000" Y="28.0000" />
                <AnchorPoint ScaleX="0.5000" ScaleY="0.5000" />
                <Position X="394.5567" Y="128.9772" />
                <Scale ScaleX="1.0000" ScaleY="1.0000" />
                <CColor A="255" R="255" G="255" B="0" />
                <PrePosition X="0.4932" Y="0.4299" />
                <PreSize X="0.0000" Y="0.0000" />
                <OutlineColor A="255" R="255" G="0" B="0" />
                <ShadowColor A="255" R="110" G="110" B="110" />
              </AbstractNodeData>
            </Children>
            <AnchorPoint ScaleX="0.5000" ScaleY="0.5000" />
            <Position X="640.8234" Y="286.6787" />
            <Scale ScaleX="1.0000" ScaleY="1.0000" />
            <CColor A="255" R="255" G="255" B="255" />
            <PrePosition X="0.5006" Y="0.3982" />
            <PreSize X="0.6250" Y="0.4167" />
            <SingleColor A="255" R="150" G="200" B="255" />
            <FirstColor A="255" R="150" G="200" B="255" />
            <EndColor A="255" R="255" G="255" B="255" />
            <ColorVector ScaleY="1.0000" />
          </AbstractNodeData>
          <AbstractNodeData Name="ChangePanel_2" ActionTag="-467130494" VisibleForFrame="False" Tag="440" IconVisible="False" LeftMargin="240.0000" RightMargin="240.0000" TopMargin="284.6203" BottomMargin="135.3797" TouchEnable="True" ClipAble="False" BackColorAlpha="0" ComboBoxIndex="1" ColorAngle="90.0000" ctype="PanelObjectData">
            <Size X="800.0000" Y="300.0000" />
            <Children>
              <AbstractNodeData Name="two_Text_tips" ActionTag="401839241" Tag="441" IconVisible="False" LeftMargin="42.0771" RightMargin="565.9229" TopMargin="31.6899" BottomMargin="244.3101" FontSize="24" LabelText="请选择取款金额：" ShadowOffsetX="2.0000" ShadowOffsetY="-2.0000" ctype="TextObjectData">
                <Size X="192.0000" Y="24.0000" />
                <AnchorPoint ScaleX="0.5000" ScaleY="0.5000" />
                <Position X="138.0771" Y="256.3101" />
                <Scale ScaleX="1.0000" ScaleY="1.0000" />
                <CColor A="255" R="228" G="184" B="23" />
                <PrePosition X="0.1726" Y="0.8544" />
                <PreSize X="0.0000" Y="0.0000" />
                <OutlineColor A="255" R="255" G="0" B="0" />
                <ShadowColor A="255" R="110" G="110" B="110" />
              </AbstractNodeData>
              <AbstractNodeData Name="two_safeminus" ActionTag="-1729347059" Tag="442" IconVisible="False" LeftMargin="32.5218" RightMargin="712.4782" TopMargin="83.6544" BottomMargin="159.3456" TouchEnable="True" FontSize="14" Scale9Enable="True" LeftEage="15" RightEage="15" TopEage="11" BottomEage="11" Scale9OriginX="15" Scale9OriginY="11" Scale9Width="25" Scale9Height="35" ShadowOffsetX="2.0000" ShadowOffsetY="-2.0000" ctype="ButtonObjectData">
                <Size X="55.0000" Y="57.0000" />
                <AnchorPoint ScaleX="0.5000" ScaleY="0.5000" />
                <Position X="60.0218" Y="187.8456" />
                <Scale ScaleX="1.0000" ScaleY="1.0000" />
                <CColor A="255" R="255" G="255" B="255" />
                <PrePosition X="0.0750" Y="0.6262" />
                <PreSize X="0.0688" Y="0.1900" />
                <TextColor A="255" R="65" G="65" B="70" />
                <PressedFileData Type="MarkedSubImage" Path="Common/safeminus.png" Plist="Common.plist" />
                <NormalFileData Type="MarkedSubImage" Path="Common/safeminus.png" Plist="Common.plist" />
                <OutlineColor A="255" R="255" G="0" B="0" />
                <ShadowColor A="255" R="110" G="110" B="110" />
              </AbstractNodeData>
              <AbstractNodeData Name="two_safeadd" ActionTag="-1075019349" Tag="443" IconVisible="False" LeftMargin="714.7309" RightMargin="30.2691" TopMargin="83.6544" BottomMargin="159.3456" TouchEnable="True" FontSize="14" Scale9Enable="True" LeftEage="15" RightEage="15" TopEage="11" BottomEage="11" Scale9OriginX="15" Scale9OriginY="11" Scale9Width="25" Scale9Height="35" ShadowOffsetX="2.0000" ShadowOffsetY="-2.0000" ctype="ButtonObjectData">
                <Size X="55.0000" Y="57.0000" />
                <AnchorPoint ScaleX="0.5000" ScaleY="0.5000" />
                <Position X="742.2309" Y="187.8456" />
                <Scale ScaleX="1.0000" ScaleY="1.0000" />
                <CColor A="255" R="255" G="255" B="255" />
                <PrePosition X="0.9278" Y="0.6262" />
                <PreSize X="0.0688" Y="0.1900" />
                <TextColor A="255" R="65" G="65" B="70" />
                <PressedFileData Type="MarkedSubImage" Path="Common/safeadd.png" Plist="Common.plist" />
                <NormalFileData Type="MarkedSubImage" Path="Common/safeadd.png" Plist="Common.plist" />
                <OutlineColor A="255" R="255" G="0" B="0" />
                <ShadowColor A="255" R="110" G="110" B="110" />
              </AbstractNodeData>
              <AbstractNodeData Name="two_Slider" ActionTag="-348573850" Tag="444" IconVisible="False" LeftMargin="144.9551" RightMargin="155.0449" TopMargin="95.1538" BottomMargin="170.8462" TouchEnable="True" ctype="SliderObjectData">
                <Size X="500.0000" Y="34.0000" />
                <AnchorPoint ScaleX="0.5000" ScaleY="0.5000" />
                <Position X="394.9551" Y="187.8462" />
                <Scale ScaleX="1.0000" ScaleY="1.0000" />
                <CColor A="255" R="255" G="255" B="255" />
                <PrePosition X="0.4937" Y="0.6262" />
                <PreSize X="0.3906" Y="0.0472" />
                <BackGroundData Type="MarkedSubImage" Path="Common/sliderbg.png" Plist="Common.plist" />
                <ProgressBarData Type="MarkedSubImage" Path="Common/slider.png" Plist="Common.plist" />
                <BallNormalData Type="MarkedSubImage" Path="Common/slidermenu.png" Plist="Common.plist" />
                <BallPressedData Type="MarkedSubImage" Path="Common/slidermenu.png" Plist="Common.plist" />
                <BallDisabledData Type="MarkedSubImage" Path="Common/slidermenu.png" Plist="Common.plist" />
              </AbstractNodeData>
              <AbstractNodeData Name="two_input_Bg" ActionTag="-1397869295" Tag="445" IconVisible="False" LeftMargin="48.8392" RightMargin="51.1608" TopMargin="162.7169" BottomMargin="77.2830" Scale9Enable="True" LeftEage="9" RightEage="9" TopEage="9" BottomEage="9" Scale9OriginX="9" Scale9OriginY="9" Scale9Width="11" Scale9Height="12" ctype="ImageViewObjectData">
                <Size X="700.0000" Y="60.0000" />
                <AnchorPoint ScaleX="0.5000" ScaleY="0.5000" />
                <Position X="398.8392" Y="107.2830" />
                <Scale ScaleX="1.0000" ScaleY="1.0000" />
                <CColor A="255" R="255" G="255" B="255" />
                <PrePosition X="0.4985" Y="0.3576" />
                <PreSize X="0.8750" Y="0.2000" />
                <FileData Type="MarkedSubImage" Path="Common/InputboxCoins.png" Plist="Common.plist" />
              </AbstractNodeData>
              <AbstractNodeData Name="withdrawals_button" ActionTag="-941568495" Tag="446" IconVisible="False" LeftMargin="521.1334" RightMargin="107.8666" TopMargin="247.0119" BottomMargin="-27.0119" TouchEnable="True" FontSize="14" Scale9Enable="True" LeftEage="15" RightEage="15" TopEage="11" BottomEage="11" Scale9OriginX="15" Scale9OriginY="11" Scale9Width="141" Scale9Height="62" ShadowOffsetX="2.0000" ShadowOffsetY="-2.0000" ctype="ButtonObjectData">
                <Size X="171.0000" Y="80.0000" />
                <AnchorPoint ScaleX="0.5000" ScaleY="0.5000" />
                <Position X="606.6334" Y="12.9881" />
                <Scale ScaleX="1.0000" ScaleY="1.0000" />
                <CColor A="255" R="255" G="255" B="255" />
                <PrePosition X="0.7583" Y="0.0433" />
                <PreSize X="0.1336" Y="0.1111" />
                <TextColor A="255" R="65" G="65" B="70" />
                <PressedFileData Type="MarkedSubImage" Path="Common/withdrawalsButton.png" Plist="Common.plist" />
                <NormalFileData Type="MarkedSubImage" Path="Common/withdrawalsButton.png" Plist="Common.plist" />
                <OutlineColor A="255" R="255" G="0" B="0" />
                <ShadowColor A="255" R="110" G="110" B="110" />
              </AbstractNodeData>
              <AbstractNodeData Name="giving_button" ActionTag="-73154946" Tag="447" IconVisible="False" LeftMargin="82.1826" RightMargin="546.8174" TopMargin="247.0119" BottomMargin="-27.0119" TouchEnable="True" FontSize="14" Scale9Enable="True" LeftEage="15" RightEage="15" TopEage="11" BottomEage="11" Scale9OriginX="15" Scale9OriginY="11" Scale9Width="141" Scale9Height="62" ShadowOffsetX="2.0000" ShadowOffsetY="-2.0000" ctype="ButtonObjectData">
                <Size X="171.0000" Y="80.0000" />
                <AnchorPoint ScaleX="0.5000" ScaleY="0.5000" />
                <Position X="167.6826" Y="12.9881" />
                <Scale ScaleX="1.0000" ScaleY="1.0000" />
                <CColor A="255" R="255" G="255" B="255" />
                <PrePosition X="0.2096" Y="0.0433" />
                <PreSize X="0.1336" Y="0.1111" />
                <TextColor A="255" R="65" G="65" B="70" />
                <PressedFileData Type="MarkedSubImage" Path="Common/givingButton.png" Plist="Common.plist" />
                <NormalFileData Type="MarkedSubImage" Path="Common/givingButton.png" Plist="Common.plist" />
                <OutlineColor A="255" R="255" G="0" B="0" />
                <ShadowColor A="255" R="110" G="110" B="110" />
              </AbstractNodeData>
              <AbstractNodeData Name="cashCoinNums" ActionTag="-1575576449" Tag="448" IconVisible="False" LeftMargin="296.8665" RightMargin="363.1335" TopMargin="178.5199" BottomMargin="93.4801" FontSize="28" LabelText="" ShadowOffsetX="2.0000" ShadowOffsetY="-2.0000" ctype="TextObjectData">
                <Size X="0.0000" Y="0.0000" />
                <AnchorPoint ScaleX="0.5000" ScaleY="0.5000" />
                <Position X="366.8665" Y="107.4801" />
                <Scale ScaleX="1.0000" ScaleY="1.0000" />
                <CColor A="255" R="255" G="255" B="0" />
                <PrePosition X="0.4586" Y="0.3583" />
                <PreSize X="0.0000" Y="0.0000" />
                <OutlineColor A="255" R="255" G="0" B="0" />
                <ShadowColor A="255" R="110" G="110" B="110" />
              </AbstractNodeData>
            </Children>
            <AnchorPoint ScaleX="0.5000" ScaleY="0.5000" />
            <Position X="640.0000" Y="285.3797" />
            <Scale ScaleX="1.0000" ScaleY="1.0000" />
            <CColor A="255" R="255" G="255" B="255" />
            <PrePosition X="0.5000" Y="0.3964" />
            <PreSize X="0.6250" Y="0.4167" />
            <SingleColor A="255" R="150" G="200" B="255" />
            <FirstColor A="255" R="150" G="200" B="255" />
            <EndColor A="255" R="255" G="255" B="255" />
            <ColorVector ScaleY="1.0000" />
          </AbstractNodeData>
          <AbstractNodeData Name="ChangePanel_3" ActionTag="1492795696" VisibleForFrame="False" Tag="449" IconVisible="False" LeftMargin="240.0000" RightMargin="240.0000" TopMargin="285.0000" BottomMargin="135.0000" TouchEnable="True" ClipAble="False" BackColorAlpha="0" ComboBoxIndex="1" ColorAngle="90.0000" ctype="PanelObjectData">
            <Size X="800.0000" Y="300.0000" />
            <Children>
              <AbstractNodeData Name="tips_text" ActionTag="-578580257" VisibleForFrame="False" Tag="450" IconVisible="False" LeftMargin="297.1081" RightMargin="322.8919" TopMargin="106.5947" BottomMargin="163.4053" FontSize="30" LabelText="暂无历史记录" ShadowOffsetX="2.0000" ShadowOffsetY="-2.0000" ctype="TextObjectData">
                <Size X="180.0000" Y="30.0000" />
                <AnchorPoint ScaleX="0.5000" ScaleY="0.5000" />
                <Position X="387.1081" Y="178.4053" />
                <Scale ScaleX="1.0000" ScaleY="1.0000" />
                <CColor A="255" R="255" G="165" B="0" />
                <PrePosition X="0.4839" Y="0.5947" />
                <PreSize X="0.0000" Y="0.0000" />
                <OutlineColor A="255" R="255" G="0" B="0" />
                <ShadowColor A="255" R="110" G="110" B="110" />
              </AbstractNodeData>
            </Children>
            <AnchorPoint ScaleX="0.5000" ScaleY="0.5000" />
            <Position X="640.0000" Y="285.0000" />
            <Scale ScaleX="1.0000" ScaleY="1.0000" />
            <CColor A="255" R="255" G="255" B="255" />
            <PrePosition X="0.5000" Y="0.3958" />
            <PreSize X="0.6250" Y="0.4167" />
            <SingleColor A="255" R="150" G="200" B="255" />
            <FirstColor A="255" R="150" G="200" B="255" />
            <EndColor A="255" R="255" G="255" B="255" />
            <ColorVector ScaleY="1.0000" />
          </AbstractNodeData>
          <AbstractNodeData Name="ChangePanel_4" ActionTag="-1364225096" VisibleForFrame="False" Tag="454" IconVisible="False" LeftMargin="240.0000" RightMargin="240.0000" TopMargin="283.0000" BottomMargin="137.0000" TouchEnable="True" ClipAble="False" BackColorAlpha="0" ComboBoxIndex="1" ColorAngle="90.0000" ctype="PanelObjectData">
            <Size X="800.0000" Y="300.0000" />
            <Children>
              <AbstractNodeData Name="originalCode" ActionTag="2117290709" Tag="455" IconVisible="False" LeftMargin="105.9764" RightMargin="574.0236" TopMargin="38.6274" BottomMargin="231.3726" FontSize="30" LabelText="原密码：" HorizontalAlignmentType="HT_Center" VerticalAlignmentType="VT_Center" ShadowOffsetX="2.0000" ShadowOffsetY="-2.0000" ctype="TextObjectData">
                <Size X="120.0000" Y="30.0000" />
                <AnchorPoint ScaleX="0.5000" ScaleY="0.5000" />
                <Position X="165.9764" Y="246.3726" />
                <Scale ScaleX="1.0000" ScaleY="1.0000" />
                <CColor A="255" R="255" G="165" B="0" />
                <PrePosition X="0.2075" Y="0.8212" />
                <PreSize X="0.1641" Y="0.0417" />
                <OutlineColor A="255" R="255" G="0" B="0" />
                <ShadowColor A="255" R="110" G="110" B="110" />
              </AbstractNodeData>
              <AbstractNodeData Name="input_bg1" ActionTag="1423377394" Tag="456" IconVisible="False" LeftMargin="229.8483" RightMargin="70.1517" TopMargin="23.6209" BottomMargin="216.3791" Scale9Enable="True" LeftEage="9" RightEage="9" TopEage="9" BottomEage="9" Scale9OriginX="9" Scale9OriginY="9" Scale9Width="11" Scale9Height="12" ctype="ImageViewObjectData">
                <Size X="500.0000" Y="60.0000" />
                <AnchorPoint ScaleX="0.5000" ScaleY="0.5000" />
                <Position X="479.8483" Y="246.3791" />
                <Scale ScaleX="1.0000" ScaleY="1.0000" />
                <CColor A="255" R="255" G="255" B="255" />
                <PrePosition X="0.5998" Y="0.8213" />
                <PreSize X="0.3906" Y="0.0833" />
                <FileData Type="MarkedSubImage" Path="Common/inputBox.png" Plist="Common.plist" />
              </AbstractNodeData>
              <AbstractNodeData Name="newCode" ActionTag="382901777" Tag="457" IconVisible="False" LeftMargin="105.9764" RightMargin="574.0236" TopMargin="121.6242" BottomMargin="148.3758" FontSize="30" LabelText="新密码：" HorizontalAlignmentType="HT_Center" VerticalAlignmentType="VT_Center" ShadowOffsetX="2.0000" ShadowOffsetY="-2.0000" ctype="TextObjectData">
                <Size X="120.0000" Y="30.0000" />
                <AnchorPoint ScaleX="0.5000" ScaleY="0.5000" />
                <Position X="165.9764" Y="163.3758" />
                <Scale ScaleX="1.0000" ScaleY="1.0000" />
                <CColor A="255" R="255" G="165" B="0" />
                <PrePosition X="0.2075" Y="0.5446" />
                <PreSize X="0.1406" Y="0.0417" />
                <OutlineColor A="255" R="255" G="0" B="0" />
                <ShadowColor A="255" R="110" G="110" B="110" />
              </AbstractNodeData>
              <AbstractNodeData Name="input_bg2" ActionTag="743286102" Tag="458" IconVisible="False" LeftMargin="229.8483" RightMargin="70.1517" TopMargin="106.6205" BottomMargin="133.3795" Scale9Enable="True" LeftEage="9" RightEage="9" TopEage="9" BottomEage="9" Scale9OriginX="9" Scale9OriginY="9" Scale9Width="11" Scale9Height="12" ctype="ImageViewObjectData">
                <Size X="500.0000" Y="60.0000" />
                <AnchorPoint ScaleX="0.5000" ScaleY="0.5000" />
                <Position X="479.8483" Y="163.3795" />
                <Scale ScaleX="1.0000" ScaleY="1.0000" />
                <CColor A="255" R="255" G="255" B="255" />
                <PrePosition X="0.5998" Y="0.5446" />
                <PreSize X="0.3906" Y="0.0833" />
                <FileData Type="MarkedSubImage" Path="Common/inputBox.png" Plist="Common.plist" />
              </AbstractNodeData>
              <AbstractNodeData Name="input_bg3" ActionTag="-1095678830" Tag="459" IconVisible="False" LeftMargin="230.9704" RightMargin="69.0296" TopMargin="189.6202" BottomMargin="50.3798" Scale9Enable="True" LeftEage="9" RightEage="9" TopEage="9" BottomEage="9" Scale9OriginX="9" Scale9OriginY="9" Scale9Width="11" Scale9Height="12" ctype="ImageViewObjectData">
                <Size X="500.0000" Y="60.0000" />
                <AnchorPoint ScaleX="0.5000" ScaleY="0.5000" />
                <Position X="480.9704" Y="80.3798" />
                <Scale ScaleX="1.0000" ScaleY="1.0000" />
                <CColor A="255" R="255" G="255" B="255" />
                <PrePosition X="0.6012" Y="0.2679" />
                <PreSize X="0.3906" Y="0.0833" />
                <FileData Type="MarkedSubImage" Path="Common/inputBox.png" Plist="Common.plist" />
              </AbstractNodeData>
              <AbstractNodeData Name="againCode" ActionTag="-1505279105" Tag="460" IconVisible="False" LeftMargin="72.9624" RightMargin="577.0376" TopMargin="204.6215" BottomMargin="65.3785" FontSize="30" LabelText="再输一次：" ShadowOffsetX="2.0000" ShadowOffsetY="-2.0000" ctype="TextObjectData">
                <Size X="150.0000" Y="30.0000" />
                <AnchorPoint ScaleX="0.5000" ScaleY="0.5000" />
                <Position X="147.9624" Y="80.3785" />
                <Scale ScaleX="1.0000" ScaleY="1.0000" />
                <CColor A="255" R="255" G="165" B="0" />
                <PrePosition X="0.1850" Y="0.2679" />
                <PreSize X="0.1172" Y="0.0833" />
                <OutlineColor A="255" R="255" G="0" B="0" />
                <ShadowColor A="255" R="110" G="110" B="110" />
              </AbstractNodeData>
              <AbstractNodeData Name="oldcode" ActionTag="-371205008" Tag="461" IconVisible="False" LeftMargin="232.8490" RightMargin="107.1510" TopMargin="33.6276" BottomMargin="226.3724" TouchEnable="True" FontSize="30" IsCustomSize="True" LabelText="" PlaceHolderText=" 请输入原密码" MaxLengthText="10" PasswordEnable="True" ctype="TextFieldObjectData">
                <Size X="460.0000" Y="40.0000" />
                <AnchorPoint ScaleY="0.5000" />
                <Position X="232.8490" Y="246.3724" />
                <Scale ScaleX="1.0000" ScaleY="1.0000" />
                <CColor A="255" R="255" G="255" B="255" />
                <PrePosition X="0.2911" Y="0.8212" />
                <PreSize X="0.3594" Y="0.0556" />
              </AbstractNodeData>
              <AbstractNodeData Name="newcodeagain" ActionTag="-1444740816" Tag="462" IconVisible="False" LeftMargin="232.8490" RightMargin="107.1510" TopMargin="199.6209" BottomMargin="60.3791" TouchEnable="True" FontSize="30" IsCustomSize="True" LabelText="" PlaceHolderText=" 请再次输入新密码" MaxLengthText="10" PasswordEnable="True" ctype="TextFieldObjectData">
                <Size X="460.0000" Y="40.0000" />
                <AnchorPoint ScaleY="0.5000" />
                <Position X="232.8490" Y="80.3791" />
                <Scale ScaleX="0.9929" ScaleY="1.0000" />
                <CColor A="255" R="255" G="255" B="255" />
                <PrePosition X="0.2911" Y="0.2679" />
                <PreSize X="0.3594" Y="0.0556" />
              </AbstractNodeData>
              <AbstractNodeData Name="newcode" ActionTag="-1963008071" Tag="463" IconVisible="False" LeftMargin="232.8490" RightMargin="107.1510" TopMargin="116.6244" BottomMargin="143.3756" TouchEnable="True" FontSize="30" IsCustomSize="True" LabelText="" PlaceHolderText=" 请输入新密码" MaxLengthText="10" PasswordEnable="True" ctype="TextFieldObjectData">
                <Size X="460.0000" Y="40.0000" />
                <AnchorPoint ScaleY="0.5000" />
                <Position X="232.8490" Y="163.3756" />
                <Scale ScaleX="1.0000" ScaleY="1.0000" />
                <CColor A="255" R="255" G="255" B="255" />
                <PrePosition X="0.2911" Y="0.5446" />
                <PreSize X="0.3594" Y="0.0556" />
              </AbstractNodeData>
              <AbstractNodeData Name="ruffer_button" ActionTag="-913698379" Tag="464" IconVisible="False" LeftMargin="332.3499" RightMargin="296.6501" TopMargin="256.2797" BottomMargin="-36.2797" TouchEnable="True" FontSize="14" Scale9Enable="True" LeftEage="15" RightEage="15" TopEage="11" BottomEage="11" Scale9OriginX="15" Scale9OriginY="11" Scale9Width="141" Scale9Height="63" ShadowOffsetX="2.0000" ShadowOffsetY="-2.0000" ctype="ButtonObjectData">
                <Size X="171.0000" Y="80.0000" />
                <AnchorPoint ScaleX="0.5000" ScaleY="0.5000" />
                <Position X="417.8499" Y="3.7203" />
                <Scale ScaleX="1.0000" ScaleY="1.0000" />
                <CColor A="255" R="255" G="255" B="255" />
                <PrePosition X="0.5223" Y="0.0124" />
                <PreSize X="0.1336" Y="0.1111" />
                <TextColor A="255" R="65" G="65" B="70" />
                <DisabledFileData Type="MarkedSubImage" Path="Common/referButton.png" Plist="Common.plist" />
                <PressedFileData Type="MarkedSubImage" Path="Common/referButton.png" Plist="Common.plist" />
                <NormalFileData Type="MarkedSubImage" Path="Common/referButton.png" Plist="Common.plist" />
                <OutlineColor A="255" R="255" G="0" B="0" />
                <ShadowColor A="255" R="110" G="110" B="110" />
              </AbstractNodeData>
            </Children>
            <AnchorPoint ScaleX="0.5000" ScaleY="0.5000" />
            <Position X="640.0000" Y="287.0000" />
            <Scale ScaleX="1.0000" ScaleY="1.0000" />
            <CColor A="255" R="255" G="255" B="255" />
            <PrePosition X="0.5000" Y="0.3986" />
            <PreSize X="0.6250" Y="0.4167" />
            <SingleColor A="255" R="150" G="200" B="255" />
            <FirstColor A="255" R="150" G="200" B="255" />
            <EndColor A="255" R="255" G="255" B="255" />
            <ColorVector ScaleY="1.0000" />
          </AbstractNodeData>
        </Children>
      </ObjectData>
    </Content>
  </Content>
</GameFile>