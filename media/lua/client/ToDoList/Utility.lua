local ToDoListUtility = {}


-- Get mod data for To-Do List, create stuff if doesn't exist --

ToDoListUtility.getValidModData = function()

	local modData = ModData.getOrCreate("ToDoList")
	if modData.lists == nil then
		modData.lists = {}
	end
	if modData.lists[1] == nil then
		modData.lists[1] = {}
	end

	return modData

end


-- Replacement for a function that cuts text to fit (why cut if we can add line breaks?) --

function ToDoListUtility.getTextSize(text, width, font, zoom)

	if not zoom then zoom = 1 end
	local brokenText = {}
	table.insert(brokenText, text)
	local currentTextPart = brokenText[#brokenText]
	local brokenTextLastElementWidth = getTextManager():MeasureStringX(font, currentTextPart) * zoom
	while brokenTextLastElementWidth > width do
		local currentText = brokenText[#brokenText]
		local currentTextCut = string.sub(currentText, 1, #currentText-1)
		local currentTextWidth = getTextManager():MeasureStringX(font, currentText) * zoom
		while currentTextWidth >= width do
			currentTextCut = string.sub(currentTextCut, 1, #currentTextCut-1)
			currentTextWidth = getTextManager():MeasureStringX(font, currentTextCut) * zoom
		end
		brokenText[#brokenText] = currentTextCut
		table.insert(brokenText, string.sub(currentText, #currentTextCut + 1, #currentText))
		brokenTextLastElementWidth = getTextManager():MeasureStringX(font, brokenText[#brokenText]) * zoom
	end

	local fontSize = getTextManager():MeasureStringY(font, text) * zoom
	local margin = fontSize / 4
	local finalText = ""
	for key,value in pairs(brokenText) do
		local lineBreak = "\n"
		if finalText == "" then 
			lineBreak = "" 
		end
		finalText = finalText .. lineBreak .. value
	end

	local textWidth = getTextManager():MeasureStringX(font, finalText) * zoom
	local textHeight = getTextManager():MeasureStringY(font, finalText) * zoom
	local textHeightWithMargin = textHeight + margin

	return finalText, textWidth, textHeight, textHeightWithMargin

end

return ToDoListUtility
