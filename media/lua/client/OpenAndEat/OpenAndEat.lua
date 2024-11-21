local OpenAndEat = {}

function OpenAndEat.OnOpenAndEat(player, cannedItem)
	print("Canned item:".. cannedItem:getName())
	-- Get type of opened canned food item
	local openedFoodType = cannedItem:getReplaceOnUse() or cannedItem:getReplaceOnUseOn() or cannedItem:getReplaceOnUseFullType()

	-- Replace canned food with opened food
	if openedFoodType then
		player:getInventory():Remove(item)
		local openedFoodItem = InventoryItemFactory.CreateItem(openedFoodType)
		player:getInventory():AddItem(openedFoodItem)
		print("Added opened item to inventory")
		
		-- Eat opened food
		ISInventoryPaneContextMenu.eatItem(openedFoodItem, 1, player)
	else
		print("No openedFoodType")
		return
	end
end

function OpenAndEat.OnFillInventoryObjectContextMenu(playerIndex, contextMenu, clickedItems)
	local playerObj = getSpecificPlayer(playerIndex)
	
	print("---------------------------------")
	print("Mod started")
	
	-- Check for can opener
	local canOpener = playerObj:getInventory():FindAndReturn("Base.TinOpener")
	if not canOpener then
		print("Can't seem to find a can opener")
		return
	end
	
	-- Check if item is a canned food item
	local cannedItem = nil
	for _, clickedItem in ipairs(clickedItems) do
		local item = clickedItem
		if not instanceof(clickedItem, "InventoryItem") then
			item = clickedItem.items[1]
		end
		
--		if string.find(string.lower(item:getFullType()), "canned") then
		if item:getStringItemType() == "CannedFood" then
			cannedItem = item
		end
	end
	
	if cannedItem then 
		contextMenu:addOption("Open and eat", playerObj, OpenAndEat.OnOpenAndEat, cannedItem)
	end
	
--	Check if item is canned food
--	local itemName = item:getName()
	
	
--	-- Get type of opened canned food item
--	local openedFoodType = item:getReplaceOnUse()
--	
--	-- Replace canned food with opened food
--	if openedFoodType then
--		playerObj:getInventory():Remove(item)
--		local openedFoodItem = InventoryItemFactory.CreateItem(openedFoodType)
--		playerObj:getInventory():AddItem(openedFoodItem)
--		print("Added opened item to inventory")
--		
--		-- Eat opened food
--		ISInventoryPaneContextMenu.eatItem(openedFoodItem, 1, playerObj)
--	else
--		print("No openedFoodType")
--		return
--	end
end

Events.OnFillInventoryObjectContextMenu.Add(OpenAndEat.OnFillInventoryObjectContextMenu)