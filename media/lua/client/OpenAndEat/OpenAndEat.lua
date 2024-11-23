local OpenAndEat = {}

function OpenAndEat.OnOpenComplete(player, recipe, itemContainer, playerContainers)
	local openedCannedItem = player:getInventory():FindAndReturn(recipe:getResult():getType())

	if openedCannedItem then
		print("Created item from recipe! Item:".. openedCannedItem:getName())
	else
		print("Item wasn't created from recipe :( :(")
		return
	end
	
	-- Eat new opened canned food
	ISInventoryPaneContextMenu.eatItem(openedCannedItem, 1, player:getPlayerNum())
	print("Ate food?")
end

function OpenAndEat.OnOpenAndEat(player, cannedItem)
	local playerContainers = ISInventoryPaneContextMenu.getContainers(player)
	local recipe = nil
	
	print("Canned item:".. cannedItem:getName())

	-- Check if player is hungry
	if player:getStats():getHunger() < 0.1 then
		player:Say("I'm not hungry")
		return
	end
	
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

		local cannedItemContainer = cannedItem:getContainer()
		local craftAction = ISCraftAction:new(player, cannedItem, recipe:getTimeToMake(), recipe, cannedItemContainer, playerContainers)
		craftAction:setOnComplete(OpenAndEat.OnOpenComplete, player, recipe, cannedItemContainer, playerContainers)
		ISTimedActionQueue.add(craftAction)
	else
		print("No recipes :(")
		return
	end
end

--local container = itemsUsed[1]:getContainer()
--local containerList = ISInventoryPaneContextMenu.getContainers(playerObj)
--self.knownRecipes = RecipeManager.getKnownRecipesNumber(self.character);
--recipe = RecipeManager.getUniqueRecipeItems(itemsCraft[1], playerObj, containerList);
--local createdItem = InventoryItemFactory.CreateItem(recipe:getResult():getFullType())
-- RecipeManager.PerformMakeItem(recipe, selectedItem, character, containers)
--local resultItem = RecipeManager.PerformMakeItem(recipe, selectedItem, playerObj, containers)

-- returing to container?
-- local returnToContainer = {};
-- local container = itemsUsed[1]:getContainer()
-- if not selectedItem.recipe:isCanBeDoneFromFloor() then
-- 	container = self.character:getInventory()
-- 	for _,item in ipairs(itemsUsed) do
-- 		if item:getContainer() ~= self.character:getInventory() then
-- 			table.insert(returnToContainer, item)
-- 		end
-- 	end
-- end

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
end

Events.OnFillInventoryObjectContextMenu.Add(OpenAndEat.OnFillInventoryObjectContextMenu)