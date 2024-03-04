require "ISUI/ISSimpleTickBox"
require "ISUI/ISSimpleText"
require "ISUI/ISSimpleTickBox"

local ToDoList = require "ToDoList/ToDoList"
local ToDoListHelpers = require "ToDoList/Utility"

local ToDoListDecorations = {}
ToDoListDecorations.ISEquippedItem = {}


-- Changing icon depenging on UI state --

ToDoListDecorations.ISEquippedItem.prerender = ISEquippedItem.prerender

function ISEquippedItem:prerender()

	ToDoListDecorations.ISEquippedItem.prerender(self)
	
	if self.toDoListButton then
        if ToDoList.interface:getIsVisible() then
            self.toDoListButton:setImage(self.toDoListIconOn)
        else
            self.toDoListButton:setImage(self.toDoListIconOff)
        end
    end
end


-- Adding function to the to-do list button --

ToDoListDecorations.ISEquippedItem.onOptionMouseDown = ISEquippedItem.onOptionMouseDown

function ISEquippedItem:onOptionMouseDown(button, x, y)

	ToDoListDecorations.ISEquippedItem.onOptionMouseDown(self, button, x, y)
	
	if button.internal == "ToDoList" then
		ToDoList.interface:toggle()
	end

end


-- Setting up icons for to-do list button --

ToDoListDecorations.ISEquippedItem.new = ISEquippedItem.new

function ISEquippedItem:new (x, y, width, height, chr)

	local object = ToDoListDecorations.ISEquippedItem.new(self, x, y, width, height, chr)
	object.toDoListIconOff = getTexture("media/ui/icon_todolist_off.png")
    object.toDoListIconOn = getTexture("media/ui/icon_todolist_on.png")
	
	return object

end


-- Rendering the to-do list icon on the bottom of the list -- 

ToDoListDecorations.ISEquippedItem.initialise = ISEquippedItem.initialise

function ISEquippedItem:initialise()

	ToDoListDecorations.ISEquippedItem.initialise(self)
	
	if self.chr:getPlayerNum() == 0 then
	
		-- This is a rather hateful block of code that I have to include despite not wanting to. Apparently IS didn't think that someone would want to add their own buttons to the left menu. --
		local y = self.searchBtn:getY() + self.searchIconOff:getHeightOrig() + 5
		if ISWorldMap.IsAllowed() then y = self.mapBtn:getBottom() + 5 end
		if getCore():getDebug() or (ISDebugMenu.forceEnable and not isClient()) then y = self.debugBtn:getY() + self.debugIcon:getHeightOrig() + 10 end
		if isClient() then
			y = self.clientBtn:getY() + self.clientIcon:getHeightOrig() + 10
			y = self.adminBtn:getY() + self.adminIcon:getHeightOrig() + 10
		end
		-- End of the hateful block of code. --
		
		local width = 40
		local height = 40

		self.toDoListButton = ISButton:new(7, y, width, height, "", self, ISEquippedItem.onOptionMouseDown);

		self.toDoListButton:setImage(self.toDoListIconOff);
		self.toDoListButton.internal = "ToDoList";
		self.toDoListButton:initialise();
		self.toDoListButton:instantiate();
		self.toDoListButton:setDisplayBackground(false);

		self.toDoListButton.borderColor = {r=1, g=1, b=1, a=0.1};
		self.toDoListButton:ignoreWidthChange();
		self.toDoListButton:ignoreHeightChange();

		self:addChild(self.toDoListButton)
		self:setHeight(self.toDoListButton:getBottom())
		self.toDoListButton:setTooltip(getText("UI_LeftPanel_ToDoListButton_Tooltip") .. getKeyName(getCore():getKey('ToDoListToggle')))
		
		
		y = self.toDoListButton:getY() + self.toDoListIconOff:getHeightOrig() + 10
		
	end
end

----------------------

-- Adding function to tick box ticking (onMouseUp didn't exist in SimpleUI) --

function ISSimpleTickBox:onMouseUp(x, y)

	if self.parent.title == getText("UI_ToDoList_Title") then
		for k, v in pairs(self.parent) do 
			if self.parent[k] == self then
				local tickBoxId = k
				local tickBoxState = self.tickBox.selected[1]
				local itemId = tickBoxId:gsub("tickBox", "")
				ToDoList.onBoxTicked(itemId, tickBoxState)
			end
		end	
	end
end


----------------------


ToDoListDecorations.ISSimpleText = {}
ToDoListDecorations.ISSimpleText.setPositionAndSize = ISSimpleText.setPositionAndSize

function ISSimpleText:setPositionAndSize()

	if self.parent.title == getText("UI_ToDoList_Title") then
		self.pxlW = self.parentUI.elemW[self.line][self.column]
		self.pxlX = self.parentUI.elemX[self.line][self.column]
	
		self:setX(self.pxlX)
		self:setY(self.pxlY)
		self:setWidth(self.pxlW)
	
		self.textToDisplay, self.textW, self.textH, self.pxlH = ToDoListHelpers.getTextSize(self.textOriginal, self:getWidth(), self.font)
		self:setHeight(self.pxlH)
	else
		ToDoListDecorations.ISSimpleText.setPositionAndSize(self)
	end
end


----------------------


ToDoListDecorations.ISSimpleTickBox = {}
ToDoListDecorations.ISSimpleTickBox.setPositionAndSize = ISSimpleTickBox.setPositionAndSize

function ISSimpleTickBox:setPositionAndSize()
	
	if self.parent.title == getText("UI_ToDoList_Title") then
		self.pxlW = self.parentUI.elemW[self.line][self.column]
		self.pxlX = self.parentUI.elemX[self.line][self.column]
		self.pxlH = self.parentUI.elemH[self.line]
	
		self:setX(self.pxlX)
		self:setY(self.pxlY)
		self:setWidth(self.pxlW)
		self:setHeight(self.pxlH)
		
		local x, y
	
		self.tickSize = 16
		x = (self.pxlW - self.tickSize)/2
		y = (self.pxlH - self.tickSize)/2
	
		self.tickBox:setX(x)
		self.tickBox:setY(y)
		self.tickBox:setWidth(self.tickSize)
		self.tickBox:setHeight(self.tickSize)
		self.tickBox.borderColor = {r=1, g=1, b=1, a=1}
		self.tickBox:bringToTop()
	else
		ToDoListDecorations.ISSimpleTickBox.setPositionAndSize(self)
	end
end


return ToDoListDecorations