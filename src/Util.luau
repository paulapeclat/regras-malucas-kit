--!strict
-- Funções compartilhadas pelas regras.

local Players = game:GetService("Players")

local Util = {}

export type Alvo = {
	player: Player,
	character: Model,
	humanoid: Humanoid,
	root: BasePart,
}

-- Converte a peça que tocou em um jogador vivo, ou nil.
function Util.alvoDoToque(hit: BasePart): Alvo?
	local character = hit.Parent
	if not character or not character:IsA("Model") then
		return nil
	end
	local player = Players:GetPlayerFromCharacter(character)
	if not player then
		return nil
	end
	local humanoid = character:FindFirstChildOfClass("Humanoid")
	local root = character:FindFirstChild("HumanoidRootPart")
	if not humanoid or humanoid.Health <= 0 or not root or not root:IsA("BasePart") then
		return nil
	end
	return { player = player, character = character, humanoid = humanoid, root = root }
end

-- Lê um atributo numérico com valor padrão.
function Util.numero(inst: Instance, nome: string, padrao: number): number
	local v = inst:GetAttribute(nome)
	return if type(v) == "number" then v else padrao
end

type Efeito = { original: any, token: number }
local ativos: { [Instance]: { [string]: Efeito } } = setmetatable({}, { __mode = "k" }) :: any

--[[
	Muda uma propriedade por um tempo e depois devolve o valor ORIGINAL.

	O original é guardado só no primeiro efeito. Se o jogador pisar de novo
	antes de acabar, o tempo renova, mas o valor guardado continua o certo.
	(Sem isso, o segundo toque "guardaria" o valor já aumentado e o bônus
	ficaria para sempre: um bug clássico de obby.)
]]
function Util.propriedadeTemporaria(inst: Instance, prop: string, valor: any, duracao: number)
	local porInst = ativos[inst]
	if not porInst then
		porInst = {}
		ativos[inst] = porInst
	end
	local efeito = porInst[prop]
	if not efeito then
		efeito = { original = (inst :: any)[prop], token = 0 }
		porInst[prop] = efeito
	end
	efeito.token += 1
	local meuToken = efeito.token
	;(inst :: any)[prop] = valor

	task.delay(duracao, function()
		if porInst[prop] == efeito and efeito.token == meuToken then
			if inst.Parent then
				(inst :: any)[prop] = efeito.original
			end
			porInst[prop] = nil
		end
	end)
end

return Util
