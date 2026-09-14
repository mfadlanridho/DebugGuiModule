--!strict
--[[
    Types.luau
    Type definitions for DebugGuiModule.
--]]

export type DebugPanelEntry = {
	key: string,
	label: string,
	value: string,
	color: Color3?,
	order: number?,
}

export type DebugPanelAction = {
	key: string,
	label: string,
	callback: () -> (),
	order: number?,
}

export type DebugPanel = {
	key: string,
	displayName: string,
	order: number?,
	entries: { [string]: DebugPanelEntry },
	actions: { [string]: DebugPanelAction },
}

return {}
