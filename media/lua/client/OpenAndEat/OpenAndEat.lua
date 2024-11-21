local OpenAndEat = {}

function OpenAndEat.OnFillInventoryObjectContextMenu(playerIndex, contextMenu, clickedItems)
	local playerObj = getSpecificPlayer(playerIndex)
	
	print("---------------------------------")
	print("Mod started")
	
	-- Ensure player is alive before doing anything. idk if this is needed
	if not playerObj or playerObj:isDead() then
		print("Player is dead or something, idk")
		return
	end
	
	-- Figure out if clickedItem is a stack or a single item
	local item = clickedItems
	if not instanceof(item, "InventoryItem") then
		item = tmpItem.items[1]
	end
	
	-- Check for can opener
	local canOpener = invItems:getFirstTypeRecurse("Base.CanOpener")
	if not canOpener then
		print("Can't seem to find a can opener")
		return
	end
	
	-- Check if item is canned food
	local itemName = item:getName()
	if not string.find(string.lower(itemName), "canned") then
		print("Item does not contain word 'canned': ", itemName)
		return
	end
	print("Canned food: ", itemName)
	
	-- Get type of opened canned food item
	local openedFoodType = item:getReplaceOnUse()
	
	-- Replace canned food with opened food
	if openedFoodType then
		playerObj:getInventory():Remove(item)
		local openedFoodItem = InventoryItemFactory.CreateItem(openedFoodType)
		playerObj:getInventory():AddItem(openedFoodItem)
		print("Added opened item to inventory")
		
		-- Eat opened food
		ISInventoryPaneContextMenu.eatItem(openedFoodItem, 1, playerObj)
	else
		print("No openedFoodType")
		return
	end
end

Events.OnFillInventoryObjectContextMenu.Add(OpenAndEat.OnFillInventoryObjectContextMenu)