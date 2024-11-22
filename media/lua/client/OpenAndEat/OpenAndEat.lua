local OpenAndEat = {}

function OpenAndEat.OnOpenAndEat(player, cannedItem)
	local playerContainers = ISInventoryPaneContextMenu.getContainers(player)
	local recipe = nil
	local openedItem = nil
	
	print("Canned item:".. cannedItem:getName())
	
	-- Get recipe for opening canned food
	local recipes = RecipeManager.getUniqueRecipeItems(cannedItem, player, playerContainers)
	if recipes then
		print("Got some recipes!")
		
		for index = 0, recipes:size() - 1 do
			local tmp = recipes:get(index)
			recipe = tmp
			print("Recipe:".. recipe:getName())
		end
		if not recipe then return end
		
		if RecipeManager.IsRecipeValid(recipe, player, cannedItem, playerContainers) then
			print("Valid recipe")
		else
			print("Invalid recipe :(")
			return
		end
		
		local createdItem = RecipeManager.PerformMakeItem(recipe, cannedItem, player, playerContainers)
		openedItem = createdItem
		
		if createdItem then
			print("Created item from recipe!")
		else
			print("Item wasn't created from recipe :( :(")
			return
		end
		
		-- Remove canned food from inventory
		player:getInventory():Remove(cannedItem)
		print("Removed old canned thing from inventory?")
		
		-- Eat new opened canned food
		-- ISInventoryPaneContextMenu.eatItem(openedItem, 1, player)
		print("Ate food?")
	else
		print("No recipes :(")
		return
	end
end

--local containerList = ISInventoryPaneContextMenu.getContainers(playerObj)
--self.knownRecipes = RecipeManager.getKnownRecipesNumber(self.character);
--recipe = RecipeManager.getUniqueRecipeItems(itemsCraft[1], playerObj, containerList);
--local createdItem = InventoryItemFactory.CreateItem(recipe:getResult():getFullType())
-- RecipeManager.PerformMakeItem(recipe, selectedItem, character, containers)
--local resultItem = RecipeManager.PerformMakeItem(recipe, selectedItem, playerObj, containers)

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