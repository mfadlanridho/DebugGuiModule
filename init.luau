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

local DebugGuiModule = {}
DebugGuiModule.GizmoRenderer = GizmoRenderer
DebugGuiModule.ToggleKey = Enum.KeyCode.P
DebugGuiModule.StudioOnly = true
DebugGuiModule.AllowedUserIds = {} :: { number }

local localPlayer = Players.LocalPlayer
local panelsByKey: { [string]: any } = {}
local selectedPanelKey: string? = nil
local isGuiVisible = false
local viewInstance: any = nil
local initialized = false

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
		for _, entry in pairs(activePanel.entries) do
			table.insert(rows, {
				key = entry.key,
				displayName = entry.label,
				value = entry.value,
				rowType = "value",
			})
		end
		-- Add action buttons
		for _, action in pairs(activePanel.actions) do
			table.insert(rows, {
				key = action.key,
				displayName = action.label,
				value = "Execute",
				rowType = "action",
				callback = action.callback,
			})
		end
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
		}
		panelsByKey[key] = panel
	end

	if not selectedPanelKey then
		selectedPanelKey = key
	end

	renderGui()
	return panel
end

--- Updates a status row entry on a debug panel tab.
function DebugGuiModule.setEntry(panelKey: string, entryKey: string, label: string, value: string)
	local panel = panelsByKey[panelKey] or DebugGuiModule.registerPanel(panelKey, panelKey)
	panel.entries[entryKey] = {
		key = entryKey,
		label = label,
		value = value,
	}
	renderGui()
end

--- Adds an interactive action button to a debug panel tab.
function DebugGuiModule.setAction(panelKey: string, actionKey: string, label: string, callback: () -> ())
	local panel = panelsByKey[panelKey] or DebugGuiModule.registerPanel(panelKey, panelKey)
	panel.actions[actionKey] = {
		key = actionKey,
		label = label,
		callback = callback,
	}
	renderGui()
end

--- Toggles debug menu overlay open/closed.
function DebugGuiModule.toggleVisibility()
	if not isAllowed() then return end
	isGuiVisible = not isGuiVisible

	if isGuiVisible and not viewInstance then
		local playerGui = localPlayer:WaitForChild("PlayerGui")
		viewInstance = DebugGuiView.new(playerGui)

		viewInstance.onSelectPanel = function(key: string)
			selectedPanelKey = key
			renderGui()
		end
	end

	renderGui()
end

--- Initializes the hotkey listener ('P' key).
function DebugGuiModule.Init()
	if initialized then return end
	if not isAllowed() then return end

	UserInputService.InputBegan:Connect(function(input, gameProcessed)
		if gameProcessed then return end
		if input.KeyCode == DebugGuiModule.ToggleKey then
			DebugGuiModule.toggleVisibility()
		end
	end)

	initialized = true
end

return DebugGuiModule
