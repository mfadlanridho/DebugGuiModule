--!nonstrict
--[[
    DebugGuiView.luau
    Pure procedural UI View builder for DebugGuiModule.
    Renders Header, Subtitle, Hint, Sidebar Tabs, ScrollFrames, Status Rows, Action Buttons, Sliders.
--]]

local DebugGuiView = {}
DebugGuiView.__index = DebugGuiView

local GUI_NAME = "DeveloperDebugGui"
local ROOT_SIZE = UDim2.fromOffset(420, 340)
local ROOT_POSITION = UDim2.fromOffset(16, 16)
local PANEL_BACKGROUND = Color3.fromRGB(13, 17, 23)
local PANEL_BORDER = Color3.fromRGB(62, 72, 92)
local PANEL_SURFACE = Color3.fromRGB(20, 26, 36)
local PANEL_SURFACE_ALT = Color3.fromRGB(28, 35, 48)
local PANEL_TEXT = Color3.fromRGB(238, 242, 248)
local PANEL_TEXT_MUTED = Color3.fromRGB(149, 161, 184)
local PANEL_ACCENT = Color3.fromRGB(76, 163, 255)

local function createCorner(parent, radius)
	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, radius)
	corner.Parent = parent
	return corner
end

local function createStroke(parent, color, transparency)
	local stroke = Instance.new("UIStroke")
	stroke.Color = color
	stroke.Transparency = transparency or 0
	stroke.Parent = parent
	return stroke
end

local function clearChildren(container)
	for _, child in ipairs(container:GetChildren()) do
		if child:IsA("UIListLayout") or child:IsA("UIPadding") then
			continue
		end
		child:Destroy()
	end
end

function DebugGuiView.new(playerGui)
	local self = setmetatable({}, DebugGuiView)

	local existingGui = playerGui:FindFirstChild(GUI_NAME)
	if existingGui ~= nil then
		existingGui:Destroy()
	end

	local screenGui = Instance.new("ScreenGui")
	screenGui.Name = GUI_NAME
	screenGui.DisplayOrder = 200
	screenGui.ResetOnSpawn = false
	screenGui.IgnoreGuiInset = false
	screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

	local rootFrame = Instance.new("Frame")
	rootFrame.Name = "Root"
	rootFrame.BackgroundColor3 = PANEL_BACKGROUND
	rootFrame.Position = ROOT_POSITION
	rootFrame.Size = ROOT_SIZE
	rootFrame.Parent = screenGui
	createCorner(rootFrame, 16)
	createStroke(rootFrame, PANEL_BORDER, 0.15)

	local titleBar = Instance.new("Frame")
	titleBar.Name = "TitleBar"
	titleBar.BackgroundTransparency = 1
	titleBar.Position = UDim2.fromOffset(14, 12)
	titleBar.Size = UDim2.new(1, -28, 0, 48)
	titleBar.Parent = rootFrame

	local titleLabel = Instance.new("TextLabel")
	titleLabel.Name = "Title"
	titleLabel.BackgroundTransparency = 1
	titleLabel.Size = UDim2.new(0.6, 0, 0, 24)
	titleLabel.Font = Enum.Font.GothamBold
	titleLabel.Text = "Developer Debug"
	titleLabel.TextColor3 = PANEL_TEXT
	titleLabel.TextSize = 20
	titleLabel.TextXAlignment = Enum.TextXAlignment.Left
	titleLabel.Parent = titleBar

	local subtitleLabel = Instance.new("TextLabel")
	subtitleLabel.Name = "Subtitle"
	subtitleLabel.BackgroundTransparency = 1
	subtitleLabel.Position = UDim2.fromOffset(0, 24)
	subtitleLabel.Size = UDim2.new(0.7, 0, 0, 20)
	subtitleLabel.Font = Enum.Font.Gotham
	subtitleLabel.Text = "Studio-only debug panel"
	subtitleLabel.TextColor3 = PANEL_TEXT_MUTED
	subtitleLabel.TextSize = 13
	subtitleLabel.TextXAlignment = Enum.TextXAlignment.Left
	subtitleLabel.Parent = titleBar

	local hintLabel = Instance.new("TextLabel")
	hintLabel.Name = "Hint"
	hintLabel.AnchorPoint = Vector2.new(1, 0)
	hintLabel.BackgroundTransparency = 1
	hintLabel.Position = UDim2.new(1, 0, 0, 0)
	hintLabel.Size = UDim2.new(0.35, 0, 0, 20)
	hintLabel.Font = Enum.Font.GothamMedium
	hintLabel.Text = "P to toggle"
	hintLabel.TextColor3 = PANEL_TEXT_MUTED
	hintLabel.TextSize = 12
	hintLabel.TextXAlignment = Enum.TextXAlignment.Right
	hintLabel.Parent = titleBar

	local bodyFrame = Instance.new("Frame")
	bodyFrame.Name = "Body"
	bodyFrame.BackgroundTransparency = 1
	bodyFrame.Position = UDim2.fromOffset(14, 68)
	bodyFrame.Size = UDim2.new(1, -28, 1, -82)
	bodyFrame.Parent = rootFrame

	local sidebarFrame = Instance.new("Frame")
	sidebarFrame.Name = "Sidebar"
	sidebarFrame.BackgroundColor3 = PANEL_SURFACE
	sidebarFrame.Size = UDim2.new(0, 120, 1, 0)
	sidebarFrame.Parent = bodyFrame
	createCorner(sidebarFrame, 12)
	createStroke(sidebarFrame, PANEL_BORDER, 0.3)

	local tabList = Instance.new("ScrollingFrame")
	tabList.Name = "TabList"
	tabList.Active = true
	tabList.AutomaticCanvasSize = Enum.AutomaticSize.Y
	tabList.ScrollingDirection = Enum.ScrollingDirection.Y
	tabList.BackgroundTransparency = 1
	tabList.Size = UDim2.fromScale(1, 1)
	tabList.CanvasSize = UDim2.new(0, 0, 0, 0)
	tabList.ScrollBarThickness = 2
	tabList.ScrollBarImageColor3 = PANEL_BORDER
	tabList.Parent = sidebarFrame

	local tabPadding = Instance.new("UIPadding")
	tabPadding.PaddingTop = UDim.new(0, 6)
	tabPadding.PaddingBottom = UDim.new(0, 6)
	tabPadding.PaddingLeft = UDim.new(0, 6)
	tabPadding.PaddingRight = UDim.new(0, 6)
	tabPadding.Parent = tabList

	local tabLayout = Instance.new("UIListLayout")
	tabLayout.SortOrder = Enum.SortOrder.LayoutOrder
	tabLayout.Padding = UDim.new(0, 4)
	tabLayout.Parent = tabList

	local contentFrame = Instance.new("Frame")
	contentFrame.Name = "Content"
	contentFrame.BackgroundColor3 = PANEL_SURFACE
	contentFrame.Position = UDim2.fromOffset(128, 0)
	contentFrame.Size = UDim2.new(1, -128, 1, 0)
	contentFrame.Parent = bodyFrame
	createCorner(contentFrame, 12)
	createStroke(contentFrame, PANEL_BORDER, 0.3)

	local rowList = Instance.new("ScrollingFrame")
	rowList.Name = "RowList"
	rowList.Active = true
	rowList.AutomaticCanvasSize = Enum.AutomaticSize.Y
	rowList.ScrollingDirection = Enum.ScrollingDirection.Y
	rowList.BackgroundTransparency = 1
	rowList.Size = UDim2.fromScale(1, 1)
	rowList.CanvasSize = UDim2.new(0, 0, 0, 0)
	rowList.ScrollBarThickness = 4
	rowList.ScrollBarImageColor3 = PANEL_BORDER
	rowList.Parent = contentFrame

	local rowPadding = Instance.new("UIPadding")
	rowPadding.PaddingTop = UDim.new(0, 8)
	rowPadding.PaddingBottom = UDim.new(0, 8)
	rowPadding.PaddingLeft = UDim.new(0, 10)
	rowPadding.PaddingRight = UDim.new(0, 10)
	rowPadding.Parent = rowList

	local rowLayout = Instance.new("UIListLayout")
	rowLayout.SortOrder = Enum.SortOrder.LayoutOrder
	rowLayout.Padding = UDim.new(0, 6)
	rowLayout.Parent = rowList

	local placeholderLabel = Instance.new("TextLabel")
	placeholderLabel.Name = "Placeholder"
	placeholderLabel.BackgroundTransparency = 1
	placeholderLabel.Size = UDim2.fromScale(1, 1)
	placeholderLabel.Font = Enum.Font.GothamMedium
	placeholderLabel.Text = "No debug panels available"
	placeholderLabel.TextColor3 = PANEL_TEXT_MUTED
	placeholderLabel.TextSize = 13
	placeholderLabel.Visible = false
	placeholderLabel.Parent = contentFrame

	-- Floating Dropdown Overlay Modal
	local dropdownModal = Instance.new("Frame")
	dropdownModal.Name = "DropdownModal"
	dropdownModal.BackgroundColor3 = PANEL_SURFACE
	dropdownModal.Position = UDim2.fromOffset(130, 56)
	dropdownModal.Size = UDim2.new(1, -144, 1, -68)
	dropdownModal.ZIndex = 50
	dropdownModal.Visible = false
	dropdownModal.Parent = rootFrame
	createCorner(dropdownModal, 10)
	createStroke(dropdownModal, PANEL_ACCENT, 0.3)

	local modalHeader = Instance.new("Frame")
	modalHeader.Name = "ModalHeader"
	modalHeader.BackgroundTransparency = 1
	modalHeader.Size = UDim2.new(1, 0, 0, 36)
	modalHeader.ZIndex = 51
	modalHeader.Parent = dropdownModal

	local searchBox = Instance.new("TextBox")
	searchBox.Name = "SearchBox"
	searchBox.BackgroundColor3 = PANEL_BACKGROUND
	searchBox.Position = UDim2.fromOffset(8, 6)
	searchBox.Size = UDim2.new(1, -44, 0, 24)
	searchBox.Font = Enum.Font.Gotham
	searchBox.PlaceholderText = "🔍 Filter..."
	searchBox.PlaceholderColor3 = PANEL_TEXT_MUTED
	searchBox.Text = ""
	searchBox.TextColor3 = PANEL_TEXT
	searchBox.TextSize = 11
	searchBox.TextXAlignment = Enum.TextXAlignment.Left
	searchBox.ClearTextOnFocus = false
	searchBox.ZIndex = 52
	searchBox.Parent = modalHeader
	createCorner(searchBox, 6)
	local searchPad = Instance.new("UIPadding")
	searchPad.PaddingLeft = UDim.new(0, 8)
	searchPad.Parent = searchBox

	local closeBtn = Instance.new("TextButton")
	closeBtn.Name = "CloseButton"
	closeBtn.BackgroundColor3 = PANEL_BACKGROUND
	closeBtn.Position = UDim2.new(1, -30, 0, 6)
	closeBtn.Size = UDim2.fromOffset(24, 24)
	closeBtn.Font = Enum.Font.GothamBold
	closeBtn.Text = "✕"
	closeBtn.TextColor3 = PANEL_TEXT_MUTED
	closeBtn.TextSize = 12
	closeBtn.ZIndex = 52
	closeBtn.Parent = modalHeader
	createCorner(closeBtn, 6)

	closeBtn.MouseButton1Click:Connect(function()
		dropdownModal.Visible = false
	end)

	local dropdownScroll = Instance.new("ScrollingFrame")
	dropdownScroll.Name = "OptionList"
	dropdownScroll.BackgroundTransparency = 1
	dropdownScroll.Position = UDim2.fromOffset(8, 40)
	dropdownScroll.Size = UDim2.new(1, -16, 1, -46)
	dropdownScroll.CanvasSize = UDim2.new(0, 0, 0, 0)
	dropdownScroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
	dropdownScroll.ScrollBarThickness = 4
	dropdownScroll.ScrollBarImageColor3 = PANEL_BORDER
	dropdownScroll.ZIndex = 51
	dropdownScroll.Parent = dropdownModal

	local dLayout = Instance.new("UIListLayout")
	dLayout.SortOrder = Enum.SortOrder.LayoutOrder
	dLayout.Padding = UDim.new(0, 4)
	dLayout.Parent = dropdownScroll

	screenGui.Parent = playerGui

	self.screenGui = screenGui
	self.rootFrame = rootFrame
	self.titleLabel = titleLabel
	self.subtitleLabel = subtitleLabel
	self.hintLabel = hintLabel
	self.tabList = tabList
	self.rowList = rowList
	self.placeholderLabel = placeholderLabel
	self.dropdownModal = dropdownModal
	self.dropdownSearchBox = searchBox
	self.dropdownScroll = dropdownScroll
	self.searchConn = nil
	self.onSelectPanel = nil
	self.onToggleRow = nil
	self.actionCallbacks = {}
	self.toggleValues = {}
	self.dropdownCallbacks = {}
	self.dropdownOptions = {}
	self.dropdownCurrentValues = {}

	return self
end

function DebugGuiView:render(model)
	self.screenGui.Enabled = model.visible
	if not model.visible then return end

	self.titleLabel.Text = model.title or "Developer Debug"
	self.subtitleLabel.Text = model.subtitle or "Studio-only debug panel"
	self.hintLabel.Text = model.hintText or "P to toggle"

	-- Render Sidebar Tabs with in-place reconciliation
	local existingTabs: { [string]: Instance } = {}
	for _, child in ipairs(self.tabList:GetChildren()) do
		if not (child:IsA("UIListLayout") or child:IsA("UIPadding")) then
			existingTabs[child.Name] = child
		end
	end

	for i, panel in ipairs(model.panels or {}) do
		local tabKey = "Tab_" .. panel.key
		local tabButton = existingTabs[tabKey] :: TextButton?
		if tabButton ~= nil then
			-- Update in-place
			tabButton.BackgroundColor3 = if panel.selected then PANEL_SURFACE_ALT else PANEL_SURFACE
			tabButton.TextColor3 = if panel.selected then PANEL_ACCENT else PANEL_TEXT_MUTED
			tabButton.Text = panel.displayName
			tabButton.LayoutOrder = i
			existingTabs[tabKey] = nil
		else
			-- Create new
			tabButton = Instance.new("TextButton")
			tabButton.Name = tabKey
			tabButton.BackgroundColor3 = if panel.selected then PANEL_SURFACE_ALT else PANEL_SURFACE
			tabButton.Size = UDim2.new(1, 0, 0, 28)
			tabButton.Font = Enum.Font.GothamMedium
			tabButton.Text = panel.displayName
			tabButton.TextColor3 = if panel.selected then PANEL_ACCENT else PANEL_TEXT_MUTED
			tabButton.TextSize = 12
			tabButton.LayoutOrder = i
			tabButton.Parent = self.tabList
			createCorner(tabButton, 8)

			tabButton.MouseButton1Click:Connect(function()
				if self.onSelectPanel then
					self.onSelectPanel(panel.key)
				end
			end)
		end
	end

	for _, stale in pairs(existingTabs) do
		stale:Destroy()
	end

	-- Render Panel Rows & Buttons with in-place reconciliation
	local existingRows: { [string]: Instance } = {}
	for _, child in ipairs(self.rowList:GetChildren()) do
		if not (child:IsA("UIListLayout") or child:IsA("UIPadding")) then
			existingRows[child.Name] = child
		end
	end

	local rows = model.rows or {}

	if #rows == 0 then
		self.placeholderLabel.Text = model.placeholderText or "No data registered for this panel."
		self.placeholderLabel.Visible = true
		self.rowList.Visible = false
		for _, stale in pairs(existingRows) do
			stale:Destroy()
		end
	else
		self.placeholderLabel.Visible = false
		self.rowList.Visible = true

		for i, row in ipairs(rows) do
			local rowKey = "Row_" .. row.key
			local rowFrame = existingRows[rowKey] :: Frame?

			if rowFrame ~= nil and rowFrame:GetAttribute("RowType") ~= row.rowType then
				rowFrame:Destroy()
				rowFrame = nil
			end

			if rowFrame ~= nil then
				-- Update in-place
				rowFrame.LayoutOrder = i
				local label = rowFrame:FindFirstChild("Label") :: TextLabel?
				if label then
					label.Text = row.displayName
				end

				if row.rowType == "action" then
					local button = rowFrame:FindFirstChild("ActionButton") :: TextButton?
					if button then
						button.Text = row.value or "Execute"
					end
					self.actionCallbacks[rowKey] = row.callback
				elseif row.rowType == "dropdown" then
					local dropBtn = rowFrame:FindFirstChild("DropdownButton") :: TextButton?
					if dropBtn then
						dropBtn.Text = string.format("%s  ▼", tostring(row.value or "Select..."))
					end
					self.dropdownCallbacks[rowKey] = row.callback
					self.dropdownOptions[rowKey] = row.options
					self.dropdownCurrentValues[rowKey] = tostring(row.value or "")
				elseif row.rowType == "toggle" then
					local toggleBtn = rowFrame:FindFirstChild("ToggleBtn") :: TextButton?
					if toggleBtn then
						toggleBtn.BackgroundColor3 = if row.value then PANEL_ACCENT else PANEL_BACKGROUND
						toggleBtn.Text = if row.value then "ON" else "OFF"
						toggleBtn.TextColor3 = if row.value then PANEL_BACKGROUND else PANEL_TEXT_MUTED
					end
					self.toggleValues[rowKey] = row.value
				else
					local valLabel = rowFrame:FindFirstChild("Value") :: TextLabel?
					if valLabel then
						valLabel.Text = tostring(row.value)
					end
				end

				existingRows[rowKey] = nil
			else
				-- Create new rowFrame
				rowFrame = Instance.new("Frame")
				rowFrame.Name = rowKey
				rowFrame:SetAttribute("RowType", row.rowType)
				rowFrame.BackgroundColor3 = PANEL_SURFACE_ALT
				rowFrame.Size = UDim2.new(1, 0, 0, 32)
				rowFrame.LayoutOrder = i
				rowFrame.Parent = self.rowList
				createCorner(rowFrame, 6)

				local label = Instance.new("TextLabel")
				label.Name = "Label"
				label.BackgroundTransparency = 1
				label.Position = UDim2.fromOffset(8, 0)
				label.Size = UDim2.new(0.42, -8, 1, 0)
				label.Font = Enum.Font.GothamMedium
				label.Text = row.displayName
				label.TextColor3 = PANEL_TEXT
				label.TextSize = 12
				label.TextXAlignment = Enum.TextXAlignment.Left
				label.Parent = rowFrame

				if row.rowType == "action" then
					self.actionCallbacks[rowKey] = row.callback
					local button = Instance.new("TextButton")
					button.Name = "ActionButton"
					button.BackgroundColor3 = PANEL_ACCENT
					button.Position = UDim2.new(0.45, 0, 0.15, 0)
					button.Size = UDim2.new(0.55, -8, 0.7, 0)
					button.Font = Enum.Font.GothamBold
					button.Text = row.value or "Execute"
					button.TextColor3 = PANEL_BACKGROUND
					button.TextSize = 11
					button.Parent = rowFrame
					createCorner(button, 6)

					button.MouseButton1Click:Connect(function()
						local cb = self.actionCallbacks[rowKey]
						if cb then
							cb()
						end
					end)
				elseif row.rowType == "dropdown" then
					self.dropdownCallbacks[rowKey] = row.callback
					self.dropdownOptions[rowKey] = row.options
					self.dropdownCurrentValues[rowKey] = tostring(row.value or "")

					local dropBtn = Instance.new("TextButton")
					dropBtn.Name = "DropdownButton"
					dropBtn.BackgroundColor3 = PANEL_SURFACE
					dropBtn.Position = UDim2.new(0.45, 0, 0.15, 0)
					dropBtn.Size = UDim2.new(0.55, -8, 0.7, 0)
					dropBtn.Font = Enum.Font.GothamMedium
					dropBtn.Text = string.format("%s  ▼", tostring(row.value or "Select..."))
					dropBtn.TextColor3 = PANEL_ACCENT
					dropBtn.TextSize = 11
					dropBtn.Parent = rowFrame
					createCorner(dropBtn, 6)
					createStroke(dropBtn, PANEL_BORDER, 0.5)

					dropBtn.MouseButton1Click:Connect(function()
						local opts = self.dropdownOptions[rowKey] or {}
						local curVal = self.dropdownCurrentValues[rowKey] or ""
						self:openDropdown(rowKey, opts, curVal)
					end)
				elseif row.rowType == "toggle" then
					self.toggleValues[rowKey] = row.value
					local toggleBtn = Instance.new("TextButton")
					toggleBtn.Name = "ToggleBtn"
					toggleBtn.BackgroundColor3 = if row.value then PANEL_ACCENT else PANEL_BACKGROUND
					toggleBtn.Position = UDim2.new(0.85, 0, 0.2, 0)
					toggleBtn.Size = UDim2.new(0.15, -4, 0.6, 0)
					toggleBtn.Font = Enum.Font.GothamBold
					toggleBtn.Text = if row.value then "ON" else "OFF"
					toggleBtn.TextColor3 = if row.value then PANEL_BACKGROUND else PANEL_TEXT_MUTED
					toggleBtn.TextSize = 10
					toggleBtn.Parent = rowFrame
					createCorner(toggleBtn, 4)

					toggleBtn.MouseButton1Click:Connect(function()
						if self.onToggleRow then
							local curVal = self.toggleValues[rowKey]
							self.onToggleRow(row.key, not curVal)
						end
					end)
				else
					local valLabel = Instance.new("TextLabel")
					valLabel.Name = "Value"
					valLabel.BackgroundTransparency = 1
					valLabel.Position = UDim2.new(0.5, 0, 0, 0)
					valLabel.Size = UDim2.new(0.5, -8, 1, 0)
					valLabel.Font = Enum.Font.Gotham
					valLabel.Text = tostring(row.value)
					valLabel.TextColor3 = PANEL_TEXT_MUTED
					valLabel.TextSize = 12
					valLabel.TextXAlignment = Enum.TextXAlignment.Right
					valLabel.Parent = rowFrame
				end
			end
		end

		for staleKey, stale in pairs(existingRows) do
			stale:Destroy()
			self.actionCallbacks[staleKey] = nil
			self.toggleValues[staleKey] = nil
			self.dropdownCallbacks[staleKey] = nil
			self.dropdownOptions[staleKey] = nil
			self.dropdownCurrentValues[staleKey] = nil
		end
	end
end

function DebugGuiView:openDropdown(rowKey: string, options: { string }, currentSelected: string)
	self.dropdownModal.Visible = true
	self.dropdownSearchBox.Text = ""

	clearChildren(self.dropdownScroll)

	local optionButtons: { [string]: TextButton } = {}
	for idx, opt in ipairs(options) do
		local isSelected = (opt == currentSelected)
		local optBtn = Instance.new("TextButton")
		optBtn.Name = "Opt_" .. opt
		optBtn.BackgroundColor3 = if isSelected then PANEL_ACCENT else PANEL_SURFACE_ALT
		optBtn.Size = UDim2.new(1, 0, 0, 26)
		optBtn.Font = Enum.Font.GothamMedium
		optBtn.Text = (if isSelected then "✓  " else "   ") .. opt
		optBtn.TextColor3 = if isSelected then PANEL_BACKGROUND else PANEL_TEXT
		optBtn.TextSize = 11
		optBtn.TextXAlignment = Enum.TextXAlignment.Left
		optBtn.LayoutOrder = idx
		optBtn.ZIndex = 52
		optBtn.Parent = self.dropdownScroll
		createCorner(optBtn, 4)

		local btnPad = Instance.new("UIPadding")
		btnPad.PaddingLeft = UDim.new(0, 8)
		btnPad.Parent = optBtn

		optBtn.MouseButton1Click:Connect(function()
			self.dropdownModal.Visible = false
			local cb = self.dropdownCallbacks[rowKey]
			if cb then
				cb(opt)
			end
		end)

		optionButtons[opt] = optBtn
	end

	if self.searchConn then
		self.searchConn:Disconnect()
		self.searchConn = nil
	end

	self.searchConn = self.dropdownSearchBox:GetPropertyChangedSignal("Text"):Connect(function()
		local query = string.lower(self.dropdownSearchBox.Text)
		for opt, btn in pairs(optionButtons) do
			if query == "" or string.find(string.lower(opt), query, 1, true) ~= nil then
				btn.Visible = true
			else
				btn.Visible = false
			end
		end
	end)
end

function DebugGuiView:destroy()
	if self.screenGui then
		self.screenGui:Destroy()
	end
end

return DebugGuiView
