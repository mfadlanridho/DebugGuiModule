# 🛠 Standalone DebugGuiModule

A zero-dependency, self-contained Developer Debug GUI & 3D Gizmo Suite for Roblox games.

---

## 📂 Package Architecture

```text
DebugGuiModule/
├── init.luau           -- Main Debug GUI manager (panel registration, hotkey listener, status rows)
├── GizmoRenderer.luau  -- Object-pooled 3D debug gizmo renderer (lines, wireframes, labels)
├── Types.luau          -- Luau type definitions (DebugPanel, DebugPanelEntry, DebugPanelAction)
└── README.md           -- Package documentation & code examples
```

---

## 🛠 Features

- 🖥 **100% Procedural Dark UI**: Built entirely in Luau code — no drag-and-drop `.rbxm` UI models required.
- ⌨️ **Hotkey Toggle (`P` Key)**: Press `P` in Roblox Studio to toggle debug menu overlay open/closed.
- 🔒 **Developer Permission Protection**: Restricted to Roblox Studio or developer `UserId` whitelist.
- 🎨 **Bundled 3D Gizmos**: Includes `GizmoRenderer` for 3D trajectory lines, wireframes, and labels.
- 🔌 **Dynamic Tab Registration**: Easily register debug tabs for FSM, Combat, AI, Economy, or Audio.

---

## 🚀 Usage Example

```luau
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local DebugGui = require(ReplicatedStorage.Packages.DebugGuiModule)

-- 1. Initialize Debug GUI
DebugGui.Init()

-- 2. Register a custom Debug Panel Tab
DebugGui.registerPanel("PlayerState", "Player Telemetry", 1)

-- 3. Update status entries dynamically
DebugGui.setEntry("PlayerState", "State", "Active State", "Normal")
DebugGui.setEntry("PlayerState", "Speed", "WalkSpeed", "16.0 studs/s")

-- 4. Add interactive action buttons
DebugGui.setAction("PlayerState", "RagdollTest", "Trigger 3s Ragdoll", function()
    print("Triggering debug ragdoll!")
end)

-- 5. Use bundled 3D Gizmo Renderer
local gizmos = DebugGui.GizmoRenderer.new("DebugFolder")
local line = gizmos:getLine("RayLine", Color3.fromRGB(0, 255, 0))
gizmos:setLine(line, character.Position, target.Position)
```

---

## 📄 License
MIT License - Free for use across all your Roblox projects.
