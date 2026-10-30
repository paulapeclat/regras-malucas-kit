--!strict
local ServerScriptService = game:GetService("ServerScriptService")
local Kit = require(ServerScriptService:WaitForChild("RegrasMalucasKit"))

Kit.iniciar()
print("Regras disponíveis:", table.concat(Kit.tags(), ", "))
