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

function OpenAndEat.OnOpenAndEat(player, cannedItem, recipe, playerContainers)
	print("Canned item:".. cannedItem:getName())

	-- Check if player is hungry
	if player:getStats():getHunger() < 0.1 then
		player:Say("I'm not hungry")
		return
	end

	-- Get needed items for recipe
	local items = RecipeManager.getAvailableItemsNeeded(recipe, player, playerContainers, cannedItem, nil)

	-- Keep track of which items came from other containers and transer them all to the main inventory
	local cannedItemContainer = cannedItem:getContainer()
	local returnToContainer = {}
	for index = 1, items:size() do
		local item = items:get(index - 1)

		if item:getContainer() ~= player:getInventory() then
			ISTimedActionQueue.add(ISInventoryTransferAction:new(player, item, item:getContainer(), player:getInventory(), nil))
			table.insert(returnToContainer, item)
		end
	end
	
	-- Initiate craft action to open canned food
	local craftAction = ISCraftAction:new(player, cannedItem, recipe:getTimeToMake(), recipe, cannedItemContainer, playerContainers)
	craftAction:setOnComplete(OpenAndEat.OnOpenComplete, player, recipe, cannedItemContainer, playerContainers)
	ISTimedActionQueue.add(craftAction)

	-- Return items to their original containers
	ISCraftingUI.ReturnItemsToOriginalContainer(player, returnToContainer)
end

--local container = itemsUsed[1]:getContainer()
--local containerList = ISInventoryPaneContextMenu.getContainers(player)
--self.knownRecipes = RecipeManager.getKnownRecipesNumber(self.character);
--recipe = RecipeManager.getUniqueRecipeItems(itemsCraft[1], player, containerList);
--local createdItem = InventoryItemFactory.CreateItem(recipe:getResult():getFullType())
-- RecipeManager.PerformMakeItem(recipe, selectedItem, character, containers)
--local resultItem = RecipeManager.PerformMakeItem(recipe, selectedItem, player, containers)

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
	local player = getSpecificPlayer(playerIndex)
	
	print("---------------------------------")
	print("Mod started")

	-- Check if item is an unopened canned food item
	local cannedItem = nil
	for _, clickedItem in ipairs(clickedItems) do
		local item = clickedItem
		if not instanceof(clickedItem, "InventoryItem") then
			item = clickedItem.items[1]
		end
		
		print("Item type:", item:getType())
		if item:getStringItemType() == "CannedFood" and not string.find(item:getType(), "Open") then
			cannedItem = item
		end
	end

	if not cannedItem then return end

	-- Get list of recipes for cannedItem. One of these should be the recipe to open it
	local playerContainers = ISInventoryPaneContextMenu.getContainers(player)
	local recipes = RecipeManager.getUniqueRecipeItems(cannedItem, player, playerContainers)

	if not recipes then return end

	-- Find the recipe to open cannedItem
	local recipe = nil
	for index = 0, recipes:size() - 1 do
		local tmpRecipe = recipes:get(index)
		-- We want the recipe where the result item type contains the word "Open"
		if string.find(tmpRecipe:getResult():getType(), "Open") then
			recipe = tmpRecipe
		end
	end

	if not recipe then return end

	-- Check if recipe is valid (you have a can opener)
	if not RecipeManager.IsRecipeValid(recipe, player, cannedItem, playerContainers) then return end

	contextMenu:addOption("Open and eat", player, OpenAndEat.OnOpenAndEat, cannedItem, recipe, playerContainers)
end

Events.OnFillInventoryObjectContextMenu.Add(OpenAndEat.OnFillInventoryObjectContextMenu)