--!strict
-- Testes do Cooldown. Rodam no Luau puro (sem Roblox):
--   luau tests/Cooldown.spec.luau
-- O require por caminho de arquivo funciona no runtime do Luau 0.6xx+.

local Cooldown = require("../src/Cooldown")

local agora = 0
local function relogio(): number
	return agora
end

local function esperar(cond: boolean, msg: string)
	if not cond then
		error("FALHOU: " .. msg, 2)
	end
	print("ok  " .. msg)
end

local cd = Cooldown.new(1, relogio)

esperar(cd:pronto("ana") == true, "primeiro toque passa")
esperar(cd:pronto("ana") == false, "toque repetido no mesmo instante é bloqueado")
esperar(cd:pronto("bia") == true, "outro jogador não é afetado")

agora = 0.99
esperar(cd:pronto("ana") == false, "ainda dentro do cooldown")

agora = 1.0
esperar(cd:pronto("ana") == true, "libera exatamente quando o tempo acaba")

cd:limpar("ana")
esperar(cd:pronto("ana") == true, "limpar libera na hora")

local zero = Cooldown.new(0, relogio)
esperar(zero:pronto("x") and zero:pronto("x"), "cooldown zero nunca bloqueia")

local ok = pcall(function()
	Cooldown.new(-1, relogio)
end)
esperar(not ok, "duração negativa é rejeitada")

print("\nTodos os testes passaram.")
