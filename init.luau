--!nonstrict
--[[
    DebugGuiModule (init.luau)
    Zero-dependency, standalone Developer Debug GUI & 3D Gizmo Suite for Roblox games.
    Renders Header, Subtitle, Sidebar Tabs, Status Rows, Action Buttons, Sliders, and 3D Gizmos.
    Hotkey: 'P' key. Studio & Developer UserID permissions protected.
--]]

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local script = script

local Types = require(script.Types)
local DebugGuiView = require(script.DebugGuiView)
local GizmoRenderer = require(script.GizmoRenderer)

export type DebugPanel = Types.DebugPanel
export type DebugPanelEntry = Types.DebugPanelEntry
export type DebugPanelAction = Types.DebugPanelAction
export type DebugPanelDropdown = Types.DebugPanelDropdown

local DebugGuiModule = {}
DebugGuiModule.GizmoRenderer = GizmoRenderer
DebugGuiModule.ToggleKey = Enum.KeyCode.P
DebugGuiModule.StudioOnly = true
DebugGuiModule.EnableLogging = false :: boolean -- Configurable logging toggle
DebugGuiModule.AllowedUserIds = {} :: { number }

local localPlayer = Players.LocalPlayer
local panelsByKey: { [string]: any } = {}
local selectedPanelKey: string? = nil
local isGuiVisible = false
local viewInstance: any = nil
local initialized = false

-- Centralized logging helper controlled by DebugGuiModule.EnableLogging
local function log(message: string, ...: any)
	if DebugGuiModule.EnableLogging then
		print(string.format("[DebugGuiModule] " .. message, ...))
	end
end

local function isAllowed(): boolean
	if DebugGuiModule.StudioOnly and RunService:IsStudio() then
		return true
	end
	for _, userId in ipairs(DebugGuiModule.AllowedUserIds) do
		if localPlayer and localPlayer.UserId == userId then
			return true
		end
	end
	return false
end

local function renderGui()
	if not viewInstance then return end
	if not isGuiVisible then return end

	local orderedPanels = {}
	for key, panel in pairs(panelsByKey) do
		table.insert(orderedPanels, {
			key = key,
			displayName = panel.displayName,
			order = panel.order or 10,
			selected = (key == selectedPanelKey),
		})
	end
	table.sort(orderedPanels, function(a, b) return a.order < b.order end)

	if not selectedPanelKey and #orderedPanels > 0 then
		selectedPanelKey = orderedPanels[1].key
		orderedPanels[1].selected = true
	end

	local rows = {}
	if selectedPanelKey and panelsByKey[selectedPanelKey] then
		local activePanel = panelsByKey[selectedPanelKey]
		-- Add status entries
		local entryList = {}
		for _, entry in pairs(activePanel.entries) do
			table.insert(entryList, entry)
		end
		table.sort(entryList, function(a, b)
			local orderA = a.order or 999
			local orderB = b.order or 999
			if orderA ~= orderB then
				return orderA < orderB
			end
			return a.key < b.key
		end)
		for _, entry in ipairs(entryList) do
			table.insert(rows, {
				key = entry.key,
				displayName = entry.label,
				value = entry.value,
				order = entry.order or 50,
				rowType = "value",
			})
		end

		-- Add action buttons
		local actionList = {}
		for _, action in pairs(activePanel.actions) do
			table.insert(actionList, action)
		end
		table.sort(actionList, function(a, b)
			local orderA = a.order or 999
			local orderB = b.order or 999
			if orderA ~= orderB then
				return orderA < orderB
			end
			return a.key < b.key
		end)
		for _, action in ipairs(actionList) do
			table.insert(rows, {
				key = action.key,
				displayName = action.label,
				value = "Execute",
				order = action.order or 100,
				rowType = "action",
				callback = action.callback,
			})
		end

		-- Add dropdown selectors
		if activePanel.dropdowns then
			local dropdownList = {}
			for _, dropdown in pairs(activePanel.dropdowns) do
				table.insert(dropdownList, dropdown)
			end
			table.sort(dropdownList, function(a, b)
				local orderA = a.order or 999
				local orderB = b.order or 999
				if orderA ~= orderB then
					return orderA < orderB
				end
				return a.key < b.key
			end)
			for _, dropdown in ipairs(dropdownList) do
				table.insert(rows, {
					key = dropdown.key,
					displayName = dropdown.label,
					value = dropdown.selected,
					options = dropdown.options,
					order = dropdown.order or 25,
					rowType = "dropdown",
					callback = dropdown.callback,
				})
			end
		end

		table.sort(rows, function(a, b)
			if a.order ~= b.order then
				return a.order < b.order
			end
			return a.key < b.key
		end)
	end

	viewInstance:render({
		visible = isGuiVisible,
		title = "Developer Debug",
		subtitle = "Studio-only debug panel",
		hintText = string.format("%s to toggle", DebugGuiModule.ToggleKey.Name),
		panels = orderedPanels,
		rows = rows,
	})
end

--- Registers or gets a debug panel tab by key.
function DebugGuiModule.registerPanel(key: string, displayName: string, order: number?): any
	local panel = panelsByKey[key]
	if not panel then
		panel = {
			key = key,
			displayName = displayName,
			order = order or 10,
			entries = {},
			actions = {},
			dropdowns = {},
			nextEntryOrder = 1,
			nextActionOrder = 100,
		}
		panelsByKey[key] = panel
		log("📌 Registered debug panel tab: %q (%s)", displayName, key)
	end

	if not selectedPanelKey then
		selectedPanelKey = key
	end

	renderGui()
	return panel
end

--- Updates a status row entry on a debug panel tab.
function DebugGuiModule.setEntry(panelKey: string, entryKey: string, label: string, value: string, order: number?)
	local panel = panelsByKey[panelKey] or DebugGuiModule.registerPanel(panelKey, panelKey)
	if not panel.nextEntryOrder then
		panel.nextEntryOrder = 1
	end
	local existing = panel.entries[entryKey]
	local entryOrder = order or (existing and existing.order) or panel.nextEntryOrder
	if not existing and not order then
		panel.nextEntryOrder += 1
	end
	panel.entries[entryKey] = {
		key = entryKey,
		label = label,
		value = value,
		order = entryOrder,
	}
	renderGui()
end

--- Adds an interactive action button to a debug panel tab.
function DebugGuiModule.setAction(panelKey: string, actionKey: string, label: string, callback: () -> (), order: number?)
	local panel = panelsByKey[panelKey] or DebugGuiModule.registerPanel(panelKey, panelKey)
	if not panel.nextActionOrder then
		panel.nextActionOrder = 100
	end
	local existing = panel.actions[actionKey]
	local actionOrder = order or (existing and existing.order) or panel.nextActionOrder
	if not existing and not order then
		panel.nextActionOrder += 1
	end
	panel.actions[actionKey] = {
		key = actionKey,
		label = label,
		callback = callback,
		order = actionOrder,
	}
	renderGui()
end

--- Adds or updates an interactive dropdown selector on a debug panel tab.
function DebugGuiModule.setDropdown(
	panelKey: string,
	dropdownKey: string,
	label: string,
	options: { string },
	selected: string?,
	callback: (selected: string) -> (),
	order: number?
)
	local panel = panelsByKey[panelKey] or DebugGuiModule.registerPanel(panelKey, panelKey)
	if not panel.dropdowns then
		panel.dropdowns = {}
	end
	local existing = panel.dropdowns[dropdownKey]
	local dropdownOrder = order or (existing and existing.order) or 25
	local selectedVal = selected or (existing and existing.selected) or (options and options[1]) or "Select..."
	panel.dropdowns[dropdownKey] = {
		key = dropdownKey,
		label = label,
		options = options or {},
		selected = selectedVal,
		callback = callback,
		order = dropdownOrder,
	}
	renderGui()
end

--- Toggles debug menu overlay open/closed.
function DebugGuiModule.toggleVisibility()
	log("🔄 toggleVisibility called! isAllowed=%s", tostring(isAllowed()))
	if not isAllowed() then return end
	isGuiVisible = not isGuiVisible
	log("👁️ Debug GUI visibility toggled to: %s", tostring(isGuiVisible))

	if isGuiVisible and not viewInstance then
		local playerGui = localPlayer:WaitForChild("PlayerGui")
		viewInstance = DebugGuiView.new(playerGui)

		viewInstance.onSelectPanel = function(key: string)
			log("🖱️ Panel tab selected: %q", key)
			selectedPanelKey = key
			if viewInstance.dropdownModal then
				viewInstance.dropdownModal.Visible = false
			end
			renderGui()
		end
	end

	if viewInstance then
		viewInstance.screenGui.Enabled = isGuiVisible
		if not isGuiVisible and viewInstance.dropdownModal then
			viewInstance.dropdownModal.Visible = false
		end
	end

	if isGuiVisible then
		renderGui()
	end
end

--- Initializes the hotkey listener ('P' key).
function DebugGuiModule.Init()
	log("🚀 Init() called! initialized=%s, isAllowed=%s", tostring(initialized), tostring(isAllowed()))
	if initialized then return end
	if not isAllowed() then
		if DebugGuiModule.EnableLogging then
			warn("[DebugGuiModule] ⚠️ Init cancelled: isAllowed() returned false!")
		end
		return
	end

	UserInputService.InputBegan:Connect(function(input, gameProcessed)
		if input.KeyCode == DebugGuiModule.ToggleKey then
			log("🔑 'P' key pressed! gameProcessed=%s", tostring(gameProcessed))
			if gameProcessed then return end
			DebugGuiModule.toggleVisibility()
		end
	end)

	initialized = true
	log("✅ Initialized successfully! Registered ToggleKey: %s", DebugGuiModule.ToggleKey.Name)
end

return DebugGuiModule
