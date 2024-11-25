local OpenAndEat = {}

-- Triggered once player clicks on "Open and eat" context menu
function OpenAndEat.OnOpenAndEat(player, cannedItem, recipe, playerContainers)
	-- Check if player is hungry
	local isHungry = player:getMoodles():getMoodleLevel(MoodleType.FoodEaten) < 3 or player:getNutrition():getCalories() < 1000
	if not isHungry then
		player:Say(getText("Sandbox_OpenAndEat_Im_not_hungry"))
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

-- Triggered after player has finished animation for opening canned food
function OpenAndEat.OnOpenComplete(player, recipe, itemContainer, playerContainers)
	-- Most of the time the openedCannedItem will be returned to the player's main inventory
	local openedCannedItem = player:getInventory():FindAndReturn(recipe:getResult():getType())
	if not openedCannedItem then
		-- Sometimes though an item will go back to its original container
		for index = 1, playerContainers:size() do
			local container = playerContainers:get(index - 1)
			local foundOpenedItem = container:FindAndReturn(recipe:getResult():getType())

			if foundOpenedItem then
				openedCannedItem = foundOpenedItem
				break
			end
		end

		if not openedCannedItem then return end
	end
	
	-- Eat new opened canned food
	ISInventoryPaneContextMenu.eatItem(openedCannedItem, 1, player:getPlayerNum())
end

-- Triggered by OnFillInventoryObjectContextMenu event hook
function OpenAndEat.OnFillInventoryObjectContextMenu(playerIndex, contextMenu, clickedItems)
	local player = getSpecificPlayer(playerIndex)

	-- Check if item is an unopened canned food item
	local cannedItem = nil
	for _, clickedItem in ipairs(clickedItems) do
		local item = clickedItem
		if not instanceof(clickedItem, "InventoryItem") then
			item = clickedItem.items[1]
		end
		
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

	contextMenu:addOption(getText("ContextMenu_Open_and_eat"), player, OpenAndEat.OnOpenAndEat, cannedItem, recipe, playerContainers)
end

Events.OnFillInventoryObjectContextMenu.Add(OpenAndEat.OnFillInventoryObjectContextMenu)