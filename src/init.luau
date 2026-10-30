--!strict
--[[
	regras-malucas-kit
	Mecânicas de obby ligadas por Tags (CollectionService) e configuradas por Attributes.

	Uso (num Script do ServerScriptService):
		local Kit = require(caminho.para.RegrasMalucasKit)
		Kit.iniciar()

	No Studio, marque uma Part com a Tag "Regra:Trampolim" (ou outra do catálogo)
	e ajuste os Attributes dela. Pronto.
]]

local CollectionService = game:GetService("CollectionService")
local RunService = game:GetService("RunService")

local Regras = require(script.Regras)

local PREFIXO = "Regra:"

local Kit = {}
Kit.Regras = Regras

local ligadas: { [Instance]: { [string]: true } } = setmetatable({}, { __mode = "k" }) :: any
local iniciado = false

local function ligar(nome: string, inst: Instance)
	if not inst:IsA("BasePart") then
		warn(`[regras-malucas-kit] {inst:GetFullName()} tem a tag {PREFIXO}{nome}, mas não é BasePart`)
		return
	end
	local jaLigadas = ligadas[inst]
	if not jaLigadas then
		jaLigadas = {}
		ligadas[inst] = jaLigadas
	end
	if jaLigadas[nome] then
		return
	end
	jaLigadas[nome] = true
	Regras[nome](inst)
end

-- Liga todas as regras do catálogo. Só roda no servidor e só uma vez.
function Kit.iniciar()
	assert(RunService:IsServer(), "regras-malucas-kit precisa rodar no servidor")
	if iniciado then
		return
	end
	iniciado = true

	for nome in Regras do
		local tag = PREFIXO .. nome
		for _, inst in CollectionService:GetTagged(tag) do
			ligar(nome, inst)
		end
		CollectionService:GetInstanceAddedSignal(tag):Connect(function(inst)
			ligar(nome, inst)
		end)
	end
end

-- Lista os nomes de tag disponíveis (útil para documentação e para o plugin de tags).
function Kit.tags(): { string }
	local lista = {}
	for nome in Regras do
		table.insert(lista, PREFIXO .. nome)
	end
	table.sort(lista)
	return lista
end

return Kit
