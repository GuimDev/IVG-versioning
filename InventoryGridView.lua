------------------------------------------------------------------
--InventoryGridView.lua
--Author: ingeniousclown, Randactyl
--v1.3

--InventoryGridView was designed to try and leverage the default
--UI as much as possible to create a grid view.  The result is
--somewhat hacky, but it works well.

--Main functions for the mod.
------------------------------------------------------------------

local BAGS = ZO_PlayerInventoryBackpack		                          --bagId = 1
local QUEST = ZO_PlayerInventoryQuest		                          --bagId = 2
local BANK = ZO_PlayerBankBackpack			                          --bagId = 3
local GUILD_BANK = ZO_GuildBankBackpack		                          --bagId = 4
local STORE = ZO_StoreWindowList			                          --bagId = 5
local BUYBACK = ZO_BuyBackList				                          --bagId = 6
--local REFINE = ZO_SmithingTopLevelRefinementPanelInventoryBackpack    --bagId = 7

local IGVSettings = nil

local toggleButtonTextures = {}

local _

function InventoryGridView_SetToggleButtonTexture()
    for _,v in pairs(toggleButtonTextures) do
        v:SetTexture(IGVSettings:GetTextureSet().TOGGLE)
    end
end

local function ButtonClickHandler(button)
	IGVSettings:ToggleGrid(button.inventoryId)

    -- quest bag uses the same button as inventory, have to piggyback instead of making separate button
    if(button.inventoryId == INVENTORY_BACKPACK) then
        InventoryGridView_ToggleGrid(button.itemArea:GetParent():GetNamedChild("Quest"), not button.itemArea.isGrid)
    end
	InventoryGridView_ToggleGrid(button.itemArea, not button.itemArea.isGrid)
end

--parentWindow: parent of ZO_PlayerInventoryBackpack, etc
local function AddButton(parentWindow, inventoryId)
    --create the button
    local button = WINDOW_MANAGER:CreateControl(parentWindow:GetName() .. "_GridButton", parentWindow, CT_BUTTON)
    button:SetDimensions(24,24)
    button:SetAnchor(TOP, parentWindow, BOTTOM, 12, 6)
    button:SetFont("ZoFontGameSmall")
    button:SetHandler("OnClicked", ButtonClickHandler)
    button:SetMouseEnabled(true)

    --where should the button go?
    if inventoryId == STORE.bagId or inventoryId == BUYBACK.bagId then
    	button.itemArea = parentWindow:GetNamedChild("List")
    else
    	button.itemArea = parentWindow:GetNamedChild("Backpack")
    end
    button.inventoryId = inventoryId

    local texture = WINDOW_MANAGER:CreateControl(parentWindow:GetName() .. "_GridButtonTexture", button, CT_TEXTURE)
    texture:SetAnchorFill()

    table.insert(toggleButtonTextures, texture)

    -- texture:SetColor(1, 1, 1, 1)
end

--rowControl: the item control
local function AddGold(rowControl)
    if(not rowControl.dataEntry) then return end

    local bagId = rowControl.dataEntry.data.bagId or rowControl:GetParent():GetParent().bagId
    local slotIndex = rowControl.dataEntry.data.slotIndex
    local _, stack, sellPrice

    if bagId == STORE.bagId or bagId == BUYBACK.bagId then
    	sellPrice = rowControl.dataEntry.data.price
    	stack = rowControl.dataEntry.data.stack
    	ZO_ItemTooltip_AddMoney(ItemTooltip, sellPrice * stack)
    else
    	_, stack, sellPrice = GetItemInfo(bagId, slotIndex)
        ZO_ItemTooltip_AddMoney(ItemTooltip, sellPrice * stack)
    end
end

--rowControl: the item control
local function AddGoldSoon(rowControl)
    if(rowControl:GetParent():GetParent().bagId == INVENTORY_QUEST_ITEM) then return end
    if(rowControl and rowControl.isGrid and IGVSettings:IsShowValueTooltip()) then
        zo_callLater(function() AddGold(rowControl) end, 50)
    end
end

local function InventoryGridViewLoaded(eventCode, addOnName)
    if(addOnName ~= "InventoryGridView") then
        return
    end

    IGVSettings = InventoryGridViewSettings:New()

    local controlWidth = BAGS.controlHeight
    local leftPadding = 25
    local contentsWidth = BAGS:GetNamedChild("Contents"):GetWidth()
    local itemsPerRow = zo_floor((contentsWidth - leftPadding) / (controlWidth))
    local gridSpacing = ((contentsWidth - leftPadding) % itemsPerRow) / itemsPerRow

    BAGS.forceUpdate = false
    BAGS.listHeight = controlWidth
    BAGS.leftPadding = leftPadding
    BAGS.contentsWidth = contentsWidth
    BAGS.itemsPerRow = itemsPerRow
    BAGS.gridSpacing = gridSpacing
    BAGS.bagId = INVENTORY_BACKPACK
    BAGS.isGrid = IGVSettings:IsGrid(BAGS.bagId)
    BAGS.isOutlines = IGVSettings:IsAllowOutline()
    BAGS.gridSize = IGVSettings:GetGridSize()

    controlWidth = QUEST.controlHeight
    contentsWidth = QUEST:GetNamedChild("Contents"):GetWidth()

    QUEST.forceUpdate = true
    QUEST.listHeight = controlWidth
    QUEST.leftPadding = leftPadding
    QUEST.contentsWidth = contentsWidth
    QUEST.itemsPerRow = itemsPerRow
    QUEST.gridSpacing = gridSpacing
    QUEST.bagId = INVENTORY_QUEST_ITEM
    QUEST.isGrid = IGVSettings:IsGrid(BAGS.bagId)
    QUEST.isOutlines = IGVSettings:IsAllowOutline()
    QUEST.gridSize = IGVSettings:GetGridSize()

    controlWidth = BANK.controlHeight
    contentsWidth = BANK:GetNamedChild("Contents"):GetWidth()

    BANK.forceUpdate = true
    BANK.listHeight = controlWidth
    BANK.leftPadding = leftPadding
    BANK.contentsWidth = contentsWidth
    BANK.itemsPerRow = itemsPerRow
    BANK.gridSpacing = gridSpacing
    BANK.bagId = INVENTORY_BANK
    BANK.isGrid = IGVSettings:IsGrid(BANK.bagId)
    BANK.isOutlines = IGVSettings:IsAllowOutline()
    BANK.gridSize = IGVSettings:GetGridSize()

    controlWidth = GUILD_BANK.controlHeight
    contentsWidth = GUILD_BANK:GetNamedChild("Contents"):GetWidth()

    GUILD_BANK.forceUpdate = true
    GUILD_BANK.listHeight = controlWidth
    GUILD_BANK.leftPadding = leftPadding
    GUILD_BANK.contentsWidth = contentsWidth
    GUILD_BANK.itemsPerRow = itemsPerRow
    GUILD_BANK.gridSpacing = gridSpacing
    GUILD_BANK.bagId = INVENTORY_GUILD_BANK
    GUILD_BANK.isGrid = IGVSettings:IsGrid(GUILD_BANK.bagId)
    GUILD_BANK.isOutlines = IGVSettings:IsAllowOutline()
    GUILD_BANK.gridSize = IGVSettings:GetGridSize()

    controlWidth = STORE.controlHeight
    contentsWidth = STORE:GetNamedChild("Contents"):GetWidth()

    STORE.forceUpdate = true
    STORE.listHeight = controlWidth
    STORE.leftPadding = leftPadding
    STORE.contentsWidth = contentsWidth
    STORE.itemsPerRow = itemsPerRow
    STORE.gridSpacing = gridSpacing
    STORE.bagId = 5
    STORE.isGrid = IGVSettings:IsGrid(STORE.bagId)
    STORE.isOutlines = IGVSettings:IsAllowOutline()
    STORE.gridSize = IGVSettings:GetGridSize()

    controlWidth = BUYBACK.controlHeight
    contentsWidth = BUYBACK:GetNamedChild("Contents"):GetWidth()

    BUYBACK.forceUpdate = true
    BUYBACK.listHeight = controlWidth
    BUYBACK.leftPadding = leftPadding
    BUYBACK.contentsWidth = contentsWidth
    BUYBACK.itemsPerRow = itemsPerRow
    BUYBACK.gridSpacing = gridSpacing
    BUYBACK.bagId = 6
    BUYBACK.isGrid = IGVSettings:IsGrid(BUYBACK.bagId)
    BUYBACK.isOutlines = IGVSettings:IsAllowOutline()
    BUYBACK.gridSize = IGVSettings:GetGridSize()

    --[[controlWidth = REFINE.controlHeight
    contentsWidth = REFINE:GetNamedChild("Contents"):GetWidth()

    REFINE.forceUpdate = true
    REFINE.listHeight = controlWidth
    REFINE.leftPadding = leftPadding
    REFINE.contentsWidth = contentsWidth
    REFINE.itemsPerRow = itemsPerRow
    REFINE.gridSpacing = gridSpacing
    REFINE.bagId = 7
    REFINE.isGrid = IGVSettings:IsGrid(REFINE.bagId)
    REFINE.isOutlines = IGVSettings:IsAllowOutline()
    REFINE.gridSize = IGVSettings:GetGridSize()]]

    InitGridView()
    InventoryGridView_ToggleOutlines(BAGS, IGVSettings:IsAllowOutline())
    InventoryGridView_ToggleOutlines(QUEST, IGVSettings:IsAllowOutline())
    InventoryGridView_ToggleOutlines(BANK, IGVSettings:IsAllowOutline())
    InventoryGridView_ToggleOutlines(GUILD_BANK, IGVSettings:IsAllowOutline())
    InventoryGridView_ToggleOutlines(STORE, IGVSettings:IsAllowOutline())
    InventoryGridView_ToggleOutlines(BUYBACK, IGVSettings:IsAllowOutline())
    --InventoryGridView_ToggleOutlines(REFINE, IGVSettings:IsAllowOutline())

    AddButton(BAGS:GetParent(), BAGS.bagId)
    AddButton(BANK:GetParent(), BANK.bagId)
    AddButton(GUILD_BANK:GetParent(), GUILD_BANK.bagId)
    AddButton(STORE:GetParent(), STORE.bagId)
    AddButton(BUYBACK:GetParent(), BUYBACK.bagId)
    --AddButton(REFINE:GetParent(), REFINE.bagId)
    InventoryGridView_SetToggleButtonTexture()

    ZO_PreHook("ZO_InventorySlot_OnMouseEnter", AddGoldSoon)
end

--initialize
local function InventoryGridViewInitialized()
	EVENT_MANAGER:RegisterForEvent("InventoryGridViewLoaded", EVENT_ADD_ON_LOADED, InventoryGridViewLoaded)
end

InventoryGridViewInitialized()