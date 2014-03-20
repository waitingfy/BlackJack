-- dofile is not available in WoW, so the following line will not be executed in WoW
if dofile then dofile("localization.en.lua") end

local ranks = {"K", "Q", "J", "10", "9", "8", "7", "6", "5", "4", "3", "2", "A"}
local suits = {"H", "D", "C", "S"}
local cards = {}
local cardsByRank = {}

local value = 10
for i, r in ipairs(ranks) do
	cardsByRank[r] = {}
	for i, s in ipairs(suits) do
		cards[#cards + 1] = {
			rank = POKER_CARDS[r],
			suit = POKER_SUITS[s],
			name = POKER_CARD_NAME:format(POKER_CARDS[r], POKER_SUITS[s]),
			code = r..s,
			value = value
		}
		cardsByRank[r][s] = cards[#cards]
	end
	if i >= 4 then
	   value = value - 1
	end
	
end

PokerLib = {}

function PokerLib.GetCard(rank, suit)
	return cardsByRank[rank] and cardsByRank[rank][suit]
end


function PokerLib.GetAllCards()
	return unpack(cards)
end

PokerLib.stackPointer = 1
PokerLib.cards = {PokerLib.GetAllCards()}


function PokerLib.GetCardByCode(code)
	local rank, suit = code:sub(1, 1), code:sub(2, 2)
	if rank and suit then
		return PokerLib.GetCard(rank, suit)
	end
end


do
	-- compare function
	local function compare(v1, v2)
		return v1.random > v2.random
	end

	function PokerLib:ShuffleCards()
		self.stackPointer = 1 -- reset the stack pointer
		for i, v in ipairs(self.cards) do
			v.random = math.random() -- assign random values to all cards
		end
		table.sort(self.cards, compare) -- sort the array
		--for i, v in ipairs(self.cards) do
		--	print(v.name .. " " .. v.value)
		--end
		
	end
end

function PokerLib:DrawCard()
    if self.stackPointer == 53 then
	   self:ShuffleCards()
	end
	local card = self.cards[self.stackPointer]
	self.stackPointer = self.stackPointer + 1
	return card
end

function PokerLib:GetImgNameByCode(code)
    return POKER_IMG_SRC:format(code)
end

function PokerLib:CheckIsBlackJack(cards)
    if self:GetTotalValue(cards) == 21 then
	   return true
	else   
	   return false
	end
end

function PokerLib:GetTotalValue(cards)
   local containAce = false
   local totalValue = 0
   local anotherTotalValue = 0
   for i, v in ipairs(cards) do
       totalValue = totalValue + v.value
	   if v.value == 1 then
	      containAce = true
	   end
   end
   if containAce then
      anotherTotalValue = totalValue + 10 -- change Ace's value to 11
   end
   
   if containAce and anotherTotalValue <= 21 then
      return anotherTotalValue
   end
   
   return totalValue
end

function PokerLib:PlayMusicByValue(value)
    if value >= 1 and value <= 21 then
	   PlaySoundFile("Interface\\AddOns\\BlackJack\\sounds\\s_" .. value .. ".ogg")
	end
end

function PokerLib:PlayerWinMusic()
    PlaySoundFile("Interface\\AddOns\\BlackJack\\sounds\\p_wins.ogg")
end

function PokerLib:PlayerBushMusic()
    PlaySoundFile("Interface\\AddOns\\BlackJack\\sounds\\p_bust.ogg")
end

function PokerLib:InsuranceIsAvaibalbeMusic()
    PlaySoundFile("Interface\\AddOns\\BlackJack\\sounds\\ins_aw.ogg")
end

function PokerLib:InsurancePayMusic()
    PlaySoundFile("Interface\\AddOns\\BlackJack\\sounds\\ins_pay.ogg")
end

function PokerLib:InsuranceNotPayMusic()
    PlaySoundFile("Interface\\AddOns\\BlackJack\\sounds\\ins_d_pay.ogg")
end

function PokerLib:DealHaveBJMusic()
    PlaySoundFile("Interface\\AddOns\\BlackJack\\sounds\\d_h_bj.ogg")
end

function PokerLib:DealHaveNotBJMusic()
    PlaySoundFile("Interface\\AddOns\\BlackJack\\sounds\\d_n_bj.ogg")
end

function PokerLib:PlayerHaveBJMusic()
    PlaySoundFile("Interface\\AddOns\\BlackJack\\sounds\\p_h_bj.ogg")
end
