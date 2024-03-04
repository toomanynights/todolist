require "ISUI/GlobalFunctions"
local ToDoListHelpers = require "ToDoList/Utility"

local ToDoList = {}
ToDoList.interface = {}


-- Main interface builder --

ToDoList.create = function()

	ToDoList.interface = NewUI()
	local mainColumnWidth = 200
	ToDoList.interface:setTitle(getText("UI_ToDoList_Title"))
	ToDoList.interface:setColumnWidthPixel(1, 40)
	ToDoList.interface:setColumnWidthPixel(2, mainColumnWidth)
	ToDoList.interface:setColumnWidthPixel(3, 40)
	ToDoList.interface:setWidthPixel(280)
	ToDoList.interface:setDefaultLineHeightPixel(25)

	ToDoList.interface:addEmpty()
	ToDoList.interface:setLineHeightPixel(10)
	ToDoList.interface:nextLine()

	ToDoList.fillWithItems(mainColumnWidth)

	ToDoList.interface:addEmpty()
	ToDoList.interface:setLineHeightPixel(10)
	ToDoList.interface:nextLine()

	ToDoList.interface:setColumnWidthPixel(1, 40)
	ToDoList.interface:setColumnWidthPixel(2, 90)
	ToDoList.interface:setColumnWidthPixel(3, 20)
	ToDoList.interface:setColumnWidthPixel(4, 90)
	ToDoList.interface:setColumnWidthPixel(5, 40)
	
	ToDoList.interface:addEmpty()
	ToDoList.interface:addButton("addNew1", getText("UI_ToDoList_Button_AddNew"), ToDoList.createNewItem)
	ToDoList.interface["addNew1"]:setTooltip(getText("UI_ToDoList_Button_AddNew_Tooltip") .. getKeyName(getCore():getKey('ToDoListNew')))
	
	ToDoList.interface:addEmpty()
	ToDoList.interface:addButton("clean1", getText("UI_ToDoList_Button_CleanUp"), ToDoList.cleanUp)
	ToDoList.interface["clean1"]:setTooltip(getText("UI_ToDoList_Button_CleanUp_Tooltip") .. getKeyName(getCore():getKey('ToDoListCleanUp')))

	ToDoList.interface:addEmpty()
	ToDoList.interface:setLineHeightPixel(30)
	ToDoList.interface:nextLine()

	ToDoList.interface:addEmpty()
	ToDoList.interface:setLineHeightPixel(10)

	ToDoList.interface:saveLayout()

	local moddata = ToDoListHelpers.getValidModData()
	if moddata.position ~= nil then
		local x = moddata.position.x
		local y = moddata.position.y
		ToDoList.interface:setPositionPixel(x, y) 

		if moddata.position.isVisible == true then
			ToDoList.interface:open()
		end
	else 
		ToDoList.interface:setPositionPercent(1, 1)
		moddata.position = {}
		moddata.position.x = ToDoList.interface.x
		moddata.position.y = ToDoList.interface.y
	end
	ModData.add("ToDoList", moddata)
end


-- Filling main interface with to-do items --

ToDoList.fillWithItems = function(width)

	local moddata = ToDoListHelpers.getValidModData()
	local itemList = moddata.lists[1]
	local function byValue(first, second)
		if second.ticked ~= first.ticked then
			return second.ticked and not first.ticked
		end
		return second.id > first.id
	end

	table.sort(itemList, byValue)

	for key,value in pairs(itemList) do

		local lineHeight = select(4, ToDoListHelpers.getTextSize(value.text, width, UIFont["Medium"]))
		ToDoList.interface:setLineHeightPixel(lineHeight)
		print("Line " .. key .. " height is: " .. lineHeight)

		ToDoList.interface:addTickBox("tickBox" .. key)
		ToDoList.interface:addText("item" .. key, value.text, "Medium", "Left")

		if value.ticked == true then 
			ToDoList.interface["tickBox" .. key]:setValue(true)
			ToDoList.interface["item" .. key]:setColor(0.5, 96, 96, 96)
		end

		ToDoList.interface:addEmpty()
		ToDoList.interface:nextLine()
	end
end


-- Reaction on ticking or unticking the box --

ToDoList.onBoxTicked = function(itemId, state)

	local moddata = ToDoListHelpers.getValidModData()
	moddata.lists[1][tonumber(itemId)].ticked = state
	ModData.add("ToDoList", moddata)

	ToDoList.rebuildInterface()

end


-- Adding new item --

ToDoList.addItemToList = function(button, args)

	local text = ToDoList.newItemUI.newItemText:getValue()
	ToDoList.newItemUI["newItemText"].javaObject:unfocus() -- otherwise in case of submitting with Enter the focus remains in a text field
	ToDoList.newItemUI:close()

	if text ~= "" then
		local moddata = ToDoListHelpers.getValidModData()
		table.insert(moddata.lists[1], {text=text, ticked=false, id = #moddata.lists[1] + 1})
		ModData.add("ToDoList", moddata)
		
		ToDoList.rebuildInterface()
	end
end


-- Function to remove checked items --

ToDoList.cleanUp = function()

	local moddata = ToDoListHelpers.getValidModData()
	local itemList = moddata.lists[1]

	for i=#itemList,1,-1 do
		local value = itemList[i]
		if value.ticked == true then table.remove(itemList, i) end
	end
	for key,value in pairs(itemList) do
		value.id = key
	end

	ModData.add("ToDoList", moddata)
	ToDoList.rebuildInterface()

end


-- Rebuild interface when something changed --

ToDoList.rebuildInterface = function()

	ToDoList.savePosition()
	ToDoList.interface:close()
	ToDoList.create()

end


-- To preserve UI position between sessions --

ToDoList.savePosition = function()

	local moddata = ToDoListHelpers.getValidModData()

	if ToDoList.interface.x ~= nil then
		moddata.position.x = ToDoList.interface.x
		moddata.position.y = ToDoList.interface.y
		moddata.position.isVisible = ToDoList.interface.isUIVisible
	end

	ModData.add("ToDoList", moddata)

end


-- To pass self to toggling when done via key binding --

ToDoList.toggleViaBinding = function()
	ToDoList.interface:toggle()
end


----------------------


-- New item interface --

ToDoList.newItemUI = {} 
ToDoList.createNewItem = function()

	ToDoList.newItemUI = NewUI()
	ToDoList.newItemUI:setTitle(getText("UI_NewToDoListItem_Title"))
	ToDoList.newItemUI:setLineHeightPixel(20)
	ToDoList.newItemUI:setColumnWidthPercent(1, 0.02)
	ToDoList.newItemUI:setColumnWidthPercent(2, 0.16)
	ToDoList.newItemUI:setColumnWidthPercent(3, 0.02)
	ToDoList.newItemUI:setWidthPercent(0.2)
	ToDoList.newItemUI:setInCenterOfScreen()
	
	ToDoList.newItemUI:addEmpty("", 3)
	ToDoList.newItemUI:nextLine()
	
	ToDoList.newItemUI:addEmpty()
	ToDoList.newItemUI:addEntry("newItemText", "", false)
	ToDoList.newItemUI["newItemText"]:setEnterFunc(ToDoList.addItemToList)
	ToDoList.newItemUI["newItemText"].javaObject:focus()
	ToDoList.newItemUI:addEmpty()
	ToDoList.newItemUI:nextLine()
	
	ToDoList.newItemUI:addEmpty("", 3)
	ToDoList.newItemUI:nextLine()
	
	ToDoList.newItemUI:setColumnWidthPercent(1, 0.07)
	ToDoList.newItemUI:setColumnWidthPercent(2, 0.06)
	ToDoList.newItemUI:setColumnWidthPercent(3, 0.07)
	ToDoList.newItemUI:addEmpty()
	ToDoList.newItemUI:addButton("save1", getText("UI_NewToDoListItem_Button_Save"), ToDoList.addItemToList)
	ToDoList.newItemUI:addEmpty()
	ToDoList.newItemUI:nextLine()
	
	ToDoList.newItemUI:addEmpty("", 3)	
	ToDoList.newItemUI:setLineHeightPixel(10)
	
	ToDoList.newItemUI:saveLayout()
	
end


----------------------


-- Warning interface --


ToDoList.warning = {}
ToDoList.createWarning = function()
	
	ToDoList.warning = NewUI()
	ToDoList.warning:setTitle(getText("UI_ToDoListWarning_Title"))

	local text1, textWidth, textHeight, textHeightWithMargin = select(1, ToDoListHelpers.getTextSize(getText("UI_ToDoListWarning_Text1"), 999, UIFont["Small"]))
	local widthWithMargin = textWidth + 40
	ToDoList.warning:setWidthPixel(widthWithMargin)
	ToDoList.warning:setInCenterOfScreen()
	
	ToDoList.warning:addEmpty()
	ToDoList.warning:nextLine()
	
	ToDoList.warning:addText("", text1, "Small", "Center")
	
	ToDoList.warning:nextLine()

	ToDoList.warning:addText("", getText("UI_ToDoListWarning_Text2"), "Small", "Center")
	ToDoList.warning:nextLine()
	
	ToDoList.warning:addEmpty()
	ToDoList.warning:nextLine()

	ToDoList.warning:setColumnWidthPixel(1, widthWithMargin * 0.15);
	ToDoList.warning:setColumnWidthPixel(2, widthWithMargin * 0.275);
	ToDoList.warning:setColumnWidthPixel(3, widthWithMargin * 0.15);
	ToDoList.warning:setColumnWidthPixel(4, widthWithMargin * 0.275);
	ToDoList.warning:setColumnWidthPixel(5, widthWithMargin * 0.15);
	
	ToDoList.warning:addEmpty()
	ToDoList.warning:addButton("clear1", getText("UI_ToDoListWarning_Button_Yes"), ToDoList.deleteAll)
	ToDoList.warning:addEmpty()
	ToDoList.warning:addButton("cancel1", getText("UI_ToDoListWarning_Button_No"), ToDoList.closeWarningViaButton)
	ToDoList.warning:addEmpty()
	ToDoList.warning:nextLine()
	
	ToDoList.warning:addEmpty()	
	
	ToDoList.warning:saveLayout()

end

ToDoList.closeWarningViaButton = function()

	ToDoList.warning:close()

end


-- And one to remove ALL items --

ToDoList.deleteAll = function()

	ToDoList.warning:close()

	local moddata = ToDoListHelpers.getValidModData()
	moddata.lists[1] = {}
	ModData.add("ToDoList", moddata)
	ToDoList.rebuildInterface()
end


-- Bind Enter to confirm removing all items --

ToDoList.bindEnterToConfirmation = function(key)

	if key == 156 or key == 28 then
		if ToDoList.warning.getIsVisible ~= nil and ToDoList.warning:getIsVisible() == true then
			ToDoList.deleteAll()
		end
	end

end

----------------------

-- Creating key bindings --

ToDoList.createBindings = function()

	local bindings = {
		{
            name = '[ToDoList]'
        },
        {
            value = "ToDoListToggle",
			action = ToDoList.toggleViaBinding,
            key = Keyboard.KEY_DECIMAL,
        },
		{
            value = "ToDoListNew",
			action = ToDoList.createNewItem,
            key = Keyboard.KEY_ADD,
        },
		{
            value = "ToDoListCleanUp",
			action = ToDoList.cleanUp,
            key = Keyboard.KEY_SUBTRACT,
        },
		{
            value = "ToDoListDeleteAll",
			action = ToDoList.createWarning,
            key = Keyboard.KEY_NUMPAD0,
        },
	}

	for _, bind in ipairs(bindings) do
        if bind.name then
            table.insert(keyBinding, { value = bind.name, key = nil })
		else if bind.key then
			table.insert(keyBinding, { value = bind.value, key = bind.key })
			end
		end
	end

	local createAction = function(key)
        local player = getSpecificPlayer(0)
        local action
        for _,bind in ipairs(bindings) do
            if key == getCore():getKey(bind.value) then
				action = bind.action
            end
        end

		if not action or not player or player:isDead() then
			return 
		end
		action(player)
	end

    Events.OnGameStart.Add(function()
        Events.OnKeyPressed.Add(createAction)
    end)
    
end

Events.OnGameBoot.Add(ToDoList.createBindings)
Events.OnLoad.Add(ToDoList.create)
Events.OnSave.Add(ToDoList.savePosition)
Events.OnCustomUIKeyPressed.Add(ToDoList.bindEnterToConfirmation)


return ToDoList



