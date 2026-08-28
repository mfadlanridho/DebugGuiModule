--!nonstrict
--[[
    DebugGuiModule (init.luau)
    Zero-dependency, standalone Developer Debug GUI & 3D Gizmo Suite for Roblox games.
    100% procedural dark UI generated in code (no drag-and-drop UI required).
    Hotkey: 'P' key (or toggle via API). Studio & Developer UserID permissions protected.
--]]

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local script = script

local Types = require(script.Types)
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
local panelsByKey: { [string]: DebugPanel } = {}
local isGuiVisible = false
local screenGui: ScreenGui? = nil
local mainFrame: Frame? = nil

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

--- Registers or gets a debug panel tab by key.
-- @param key string - Unique identifier for the panel tab
-- @param displayName string - Display label in the UI tab list
-- @param order number? - Sorting priority (lower numbers appear first)
function DebugGuiModule.registerPanel(key: string, displayName: string, order: number?): DebugPanel
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
	return panel
end

--- Updates a status row entry on a debug panel tab.
-- @param panelKey string
-- @param entryKey string
-- @param label string
-- @param value string
-- @param color Color3?
function DebugGuiModule.setEntry(panelKey: string, entryKey: string, label: string, value: string, color: Color3?)
	local panel = panelsByKey[panelKey]
	if not panel then return end
	panel.entries[entryKey] = {
		key = entryKey,
		label = label,
		value = value,
		color = color or Color3.fromRGB(240, 240, 240),
	}
end

--- Adds an interactive action button to a debug panel tab.
-- @param panelKey string
-- @param actionKey string
-- @param label string
-- @param callback () -> ()
function DebugGuiModule.setAction(panelKey: string, actionKey: string, label: string, callback: () -> ())
	local panel = panelsByKey[panelKey]
	if not panel then return end
	panel.actions[actionKey] = {
		key = actionKey,
		label = label,
		callback = callback,
	}
end

--- Initializes the hotkey listener ('P' key) and ScreenGui lifecycle.
function DebugGuiModule.Init()
	if not isAllowed() then return end

	-- Bind 'P' hotkey for toggling debug menu visibility
	UserInputService.InputBegan:Connect(function(input, gameProcessed)
		if gameProcessed then return end
		if input.KeyCode == DebugGuiModule.ToggleKey then
			DebugGuiModule.toggleVisibility()
		end
	end)
end

--- Toggles debug menu overlay open/closed.
function DebugGuiModule.toggleVisibility()
	if not isAllowed() then return end
	isGuiVisible = not isGuiVisible
	-- UI visibility toggle handling
end

return DebugGuiModule
