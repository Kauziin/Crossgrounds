from pathlib import Path
R=Path(r'C:\Users\Kauziin\Documents\ChatGPT\RobloxStudio');p=R/'artifacts/ctf-kills-alerts-2026-10-27/src/StarterPlayer/StarterPlayerScripts/CTFFlagNotice.luau';s=p.read_text(encoding='utf-8-sig')
a='local height=math.max(110,18+16*f+messageH+6+actionH+17)';b='local headingH=math.max(16*f,TextService:GetTextSize(self.Heading.Text,self.Heading.TextSize,self.Heading.Font,Vector2.new(width-108,1000)).Y)\n local messageY=13+headingH+4\n local height=math.max(110,messageY+messageH+7+actionH+16)';assert a in s;s=s.replace(a,b)
s=s.replace('self.Heading.Size=UDim2.new(1,-104,0,16*f)','self.Heading.Size=UDim2.new(1,-104,0,headingH)')
s=s.replace('self.Message.Position=UDim2.fromOffset(86,29*f)','self.Message.Position=UDim2.fromOffset(86,messageY)')
s=s.replace('self.Action.Position=UDim2.fromOffset(86,29*f+messageH+7)','self.Action.Position=UDim2.fromOffset(86,messageY+messageH+7)')
s=s.replace('self.Host.Position=UDim2.fromOffset(0,self.Card.Visible and height+8 or 0)','self.Host.Visible=not(v.Y<500 and self.Card.Visible)\n self.Host.Position=UDim2.fromOffset(0,self.Card.Visible and height+8 or 0)')
s=s.replace('"A EQUIPE INIMIGA PONTUOU"or"BANDEIRA CAPTURADA · PONTO PARA SUA EQUIPE"','"PONTO PARA O INIMIGO"or"CAPTURA CONFIRMADA"')
p.write_text(s,encoding='utf-8');(R/'src/StarterPlayer/StarterPlayerScripts/CTFFlagNotice.luau').write_text(s,encoding='utf-8')
