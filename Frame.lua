-- Author      : Walle
-- Create Date : 3/8/2014 9:49:36 AM

-- global variables
PokerClient = CreateFrame("Frame")




local TotalBets = 0
local lastBets = 0
local InitMoney = 1000
local TotalMoney = InitMoney

--[[
if BlackJackSavedVars == nil then
     print("init money")
     BlackJackSavedVars = InitMoney; -- This is the first time this addon is loaded; 
else
     TotalMoney =  BlackJackSavedVars
end    
]]-- 

local playerCards = {}
local computerCards = {}
local frame_cache = {}



local GameReady = 0
local GameRunning = 1
local GameState = GameReady
local PlayerCardPointX = 0
local PlayerCardMargin = 20
local PlayerCardStartX = -50
local PlayerCardStartY = -150
local ComputerCardPointX = 0
local ComputerCardStartX = -50
local ComputerCardStartY = 50
local constFrameNameBegin = 9 -- start from 9 because frame level less than 9 looks like background
local newFrameName = constFrameNameBegin
local playerBust = false

function PokerClient:DisplayMoneyAndBets()
   getglobal("BtnTotalMoney"):SetText(POKER_TOTAL_MONEY:format(TotalMoney))
   getglobal("BtnTotalBets"):SetText(POKER_TOTAL_BETS:format(TotalBets))
end



function PokerClient:SetNewMoney(newMoney)
   TotalMoney = newMoney
   self:DisplayMoneyAndBets()
   --BlackJackSavedVars = TotalMoney
end

function PokerClient:SetNewBets(newBets)
   TotalBets = newBets
   self:DisplayMoneyAndBets()
end


function PokerClient:Init()
  PokerClient:DisplayMoneyAndBets()
  -- create 20 frame for display cards
  for i = 1, 20 do
	local frame = CreateFrame("Frame","newFrame" .. i,MainTableFrame)
	tinsert(frame_cache, frame)
  end
end

PokerClient:Init()

function PokerClient:AddBets(bets)
   if TotalMoney < bets then
      self:SetNewMoney(InitMoney)	  
   end
 
  self:SetNewBets(TotalBets + bets)
  lastBets = TotalBets -- when rebet can use this variables
  self:SetNewMoney(TotalMoney - bets) 
end

function PokerClient:PlayerWin(flag)
   if flag then
      self:SetNewMoney(TotalMoney + (TotalBets * 2))	  
      PokerLib:PlayerWinMusic()
   end
   self:SetNewBets(0)
   --player now can rebet or new game
   NormalDecisionFrame:Hide()
   ReBetFrame:Show()
   
end

function PokerClient:PrintBets()
   --print (TotalBets)
end

function PokerClient:ClearBets()
   self:SetNewMoney(TotalMoney + TotalBets)
   self:SetNewBets(0)    
end

--true means show, false : hide
function PokerClient:DisplayBets(flag)
   if flag then
      getglobal("BetFrame"):Show()  	  
   else
      getglobal("BetFrame"):Hide()
   end
end

function PokerClient:ReleaseFrame(frame)
   frame:Hide()
   tinsert(frame_cache, frame)
end

function PokerClient:DisplayOneCard(imageFile)
	local newFrame = tremove(frame_cache) 
	--print("player card frame name:" .. newFrame:GetName())
    newFrame:Show()
	newFrame:SetPoint("CENTER",PlayerCardStartX + PlayerCardPointX,PlayerCardStartY)
    newFrame:SetWidth(400)
    newFrame:SetHeight(400)
	--print("player card frame level:" .. newFrameName)
	newFrame:SetFrameLevel(newFrameName)

	if newFrame.texture then
	   newFrame.texture:SetPoint("CENTER",0,0)
	   newFrame.texture:SetTexture(imageFile)
	else   
	   local oneCardTexture = newFrame:CreateTexture()
       oneCardTexture:SetPoint("CENTER",0,0)
       oneCardTexture:SetTexture(imageFile)
	   newFrame.texture = oneCardTexture
	end
    
	PlayerCardPointX = PlayerCardPointX + PlayerCardMargin
	newFrameName = newFrameName + 1
end

function PokerClient:DisplayOneComputerCard(imageFile, displayCover)
	local newFrame = tremove(frame_cache) 
	--print("computer card frame name:" .. newFrame:GetName())
	newFrame:Show()
    newFrame:SetPoint("CENTER",ComputerCardStartX + ComputerCardPointX,ComputerCardStartY)
    newFrame:SetWidth(400)
    newFrame:SetHeight(400)
	--print("computer card frame level:" .. newFrameName)
	newFrame:SetFrameLevel(newFrameName)

	if newFrame.texture then
	   newFrame.texture:SetPoint("CENTER",0,0)
	   if displayCover then
	      newFrame.texture:SetTexture(POKER_IMG_COVER_SRC)
       else
	      newFrame.texture:SetTexture(imageFile)
	   end
	else
       local oneCardTexture = newFrame:CreateTexture()
       oneCardTexture:SetPoint("CENTER",0,0)
	   if displayCover then
	       oneCardTexture:SetTexture(POKER_IMG_COVER_SRC)
       else
	       oneCardTexture:SetTexture(imageFile)
	   end
       newFrame.texture = oneCardTexture  	   
	end
	
	ComputerCardPointX = ComputerCardPointX + PlayerCardMargin
	newFrameName = newFrameName + 1
end

function PokerClient:DisplayTwoComputerCards()
   ComputerCardPointX = 0
   self:DisplayOneComputerCard(PokerLib:GetImgNameByCode(computerCards[1].code))
   self:DisplayOneComputerCard(PokerLib:GetImgNameByCode(computerCards[2].code))
end

function PokerClient:InitGame()
    playerCards = {}
	computerCards = {}
	PlayerCardPointX = 0
	ComputerCardPointX = 0
	BtnComputerTotalValue:SetText(0)
	playerBust = false
	
	frame_cache = {}
	
	for i = 1, 20 do
	   local cardFrame = getglobal("newFrame" .. i)
	   if cardFrame then
	      --can not release frame, only can hide
		  self:ReleaseFrame(cardFrame)
	   end
	end
	
	
end

function PokerClient:QuickCheck()
    if  PokerLib:CheckIsBlackJack(playerCards) and PokerLib:CheckIsBlackJack(computerCards) == false then	
		--player win
		self:DisplayTwoComputerCards()
		local computerTotalValue = PokerLib:GetTotalValue(computerCards)
		BtnComputerTotalValue:SetText(computerTotalValue)
		self:SetNewMoney(TotalMoney + TotalBets * 3)
		self:SetNewBets(0)
		PokerLib:PlayerHaveBJMusic()
		NormalDecisionFrame:Hide()
        ReBetFrame:Show()
	elseif PokerLib:CheckIsBlackJack(playerCards) and PokerLib:CheckIsBlackJack(computerCards) then
        --no people win	 
	    self:DisplayTwoComputerCards()
		BtnComputerTotalValue:SetText(21)
		self:SetNewMoney(TotalMoney + TotalBets)
		self:SetNewBets(0)
		NormalDecisionFrame:Hide()
        ReBetFrame:Show()	
	elseif PokerLib:CheckIsBlackJack(computerCards)	then
	    self:DisplayTwoComputerCards()
		--computer win
		PokerLib:DealHaveBJMusic()
		NormalDecisionFrame:Hide()
        ReBetFrame:Show()
		self:SetNewBets(0)
	else
        PokerLib:DealHaveNotBJMusic()
        NormalDecisionFrame:Show()		
	end	
end

function PokerClient:GameBegin()
   if TotalBets > 0 then
     self:DisplayBets(false)
     getglobal("DealFrame"):Hide()
	 GameState = GameRunning
	 PokerLib:ShuffleCards()
	 self:InitGame()
	 
	 -- each people draw two cards
	 playerCards[1] = PokerLib:DrawCard();
	 --while playerCards[1].value ~= 1 do
	 --   playerCards[1] = PokerLib:DrawCard();
	 --end
	 playerCards[2] = PokerLib:DrawCard();
	 --while playerCards[2].value ~= 10 do
	  --  playerCards[2] = PokerLib:DrawCard();
	 --end
	 
	 computerCards[1] = PokerLib:DrawCard();
	 --while computerCards[1].value ~= 10 do
	 --   computerCards[1] = PokerLib:DrawCard();
	 --end
	 computerCards[2] = PokerLib:DrawCard();
	 
	 --print("playercards:" .. playerCards[1].code  .. "," .. playerCards[2].code)
	 --print("computercards:" .. computerCards[1].code  .. "," .. computerCards[2].code)
	 
	 -- display these cards
	 self:DisplayOneCard(PokerLib:GetImgNameByCode(playerCards[1].code))
	 self:DisplayOneCard(PokerLib:GetImgNameByCode(playerCards[2].code))
	 
	 local playerTotalValue = PokerLib:GetTotalValue(playerCards)
	 BtnPlayerTotalValue:SetText(playerTotalValue)
	 
	 
	 self:DisplayOneComputerCard(PokerLib:GetImgNameByCode(computerCards[1].code))
	 self:DisplayOneComputerCard(PokerLib:GetImgNameByCode(computerCards[2].code), true)
	 
	 
	 if computerCards[1].value == 1 then -- first check insurance	 
		--player now can buy insurance
		NormalDecisionFrame:Hide()
		InsuranceFrame:Show()
		PokerLib:InsuranceIsAvaibalbeMusic()
	 elseif  PokerLib:CheckIsBlackJack(playerCards) and PokerLib:CheckIsBlackJack(computerCards) == false or 
	    PokerLib:CheckIsBlackJack(playerCards) and PokerLib:CheckIsBlackJack(computerCards) or 
        computerCards[1].value == 10 then	
		  self:QuickCheck()
	 else    
	    PokerLib:PlayMusicByValue(playerTotalValue)
        NormalDecisionFrame:Show()	 
	 end
     
   end	 
end

function PokerClient:HitMe()
   if playerBust == false then
      playerCards[#playerCards + 1] = PokerLib:DrawCard();
      self:DisplayOneCard(PokerLib:GetImgNameByCode(playerCards[#playerCards].code))
	  local playerTotalValue = PokerLib:GetTotalValue(playerCards)
	  BtnPlayerTotalValue:SetText(playerTotalValue)
	  PokerLib:PlayMusicByValue(playerTotalValue)
   end
   --print("total value" .. PokerLib:GetTotalValue(playerCards))
   if PokerLib:GetTotalValue(playerCards) > 21 then
      --bust, player loss
	  --print("player bust")
	  PokerLib:PlayerBushMusic()
	  playerBust = true
	  self:PlayerWin(false) 
	  NormalDecisionFrame:Hide()
	  ReBetFrame:Show()
	  self:DisplayTwoComputerCards()
   end
end

function PokerClient:Stand()
   -- open all computer cards
   self:DisplayTwoComputerCards()

   --computer now begin get cards
   if #playerCards == 2 and PokerLib:GetTotalValue(computerCards) >= (playerCards[1].value + 10)  then
      --do nothing, in this case, the computer might win, so he do not want any cards
   else
       while PokerLib:GetTotalValue(computerCards) < 17 do
         computerCards[#computerCards + 1] = PokerLib:DrawCard();
	     self:DisplayOneComputerCard(PokerLib:GetImgNameByCode(computerCards[#computerCards].code))
      end
   end
   
  
   
   
   
   local computerTotalValue = PokerLib:GetTotalValue(computerCards)
   
   BtnComputerTotalValue:SetText(computerTotalValue)
   local playerTotalValue = PokerLib:GetTotalValue(playerCards)
   --print("compete with player")
   --print("computer total value:" .. computerTotalValue)
   --print("player total value:" .. playerTotalValue)
   
   if computerTotalValue > 21 then
      --player win
	 self:PlayerWin(true) 
   else 
      if computerTotalValue > playerTotalValue then
      	  --computer win
		  self:PlayerWin(false)
		  PokerLib:PlayMusicByValue(computerTotalValue)
      else  
	    if computerTotalValue == playerTotalValue then
	       -- no people win
		   self:SetNewMoney(TotalMoney + TotalBets)
           self:SetNewBets(0)
        else		 
	       --player win
		   self:PlayerWin(true)
		end   
	  end
   end
   
   --player now can rebet or new game
   NormalDecisionFrame:Hide()
   ReBetFrame:Show()
end


function PokerClient:Double()
   if TotalMoney - TotalBets < 0 then
	   --print("insufficient money")
	   self:SetNewMoney(InitMoney)
   end
  
    self:SetNewMoney(TotalMoney - TotalBets)
	   self:SetNewBets(TotalBets * 2)
       playerCards[#playerCards + 1] = PokerLib:DrawCard();
       self:DisplayOneCard(PokerLib:GetImgNameByCode(playerCards[#playerCards].code))
	   BtnComputerTotalValue:SetText(0)
	   BtnPlayerTotalValue:SetText(PokerLib:GetTotalValue(playerCards))
	   if PokerLib:GetTotalValue(playerCards) > 21 then
	      --bush
		  self:PlayerWin(false)
		  PokerLib:PlayerBushMusic()
		  self:DisplayTwoComputerCards()
	   else
   	      self:Stand()
	   end   
end



function PokerClient:BuyInsurance()
   NormalDecisionFrame:Show()
   InsuranceFrame:Hide()
   if TotalMoney - TotalBets / 2 < 0 then
      self:SetNewMoney(InitMoney)
   end
   
   self:SetNewMoney(TotalMoney - TotalBets / 2)
   if PokerLib:CheckIsBlackJack(computerCards) then
        --player win
		PokerLib:InsurancePayMusic()
		self:SetNewMoney(TotalMoney + TotalBets / 2 + TotalBets * 2)
	    ReBetFrame:Show()
	    NormalDecisionFrame:Hide()
	    --display all computer cards
	    self:DisplayTwoComputerCards()
   else
	    PokerLib:DealHaveNotBJMusic()
   end
   self:QuickCheck()
end

function PokerClient:NoInsurance()
   NormalDecisionFrame:Show()
   InsuranceFrame:Hide()
   self:QuickCheck()
end

function PokerClient:ReBet()
   ReBetFrame:Hide()
   self:SetNewBets(lastBets)
   self:SetNewMoney(TotalMoney - TotalBets)
   if TotalMoney < 0 then
      self:SetNewMoney(InitMoney)
   end
   self:GameBegin()
end

function PokerClient:NewGame()
   self:SetNewBets(0)
   BetFrame:Show()
   DealFrame:Show()
   ReBetFrame:Hide()
end

-- a simple slash command to show the frame
SLASH_POKER1 = "/bj"
SlashCmdList["POKER"] = function(msg)
	MainTableFrame:Show()
end