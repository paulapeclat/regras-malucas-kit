--!strict
--[[
	Cooldown por chave (normalmente um Player).
	Evita que o mesmo toque dispare a regra várias vezes por segundo,
	sem bloquear os outros jogadores.

	Puro: recebe o relógio por parâmetro, então pode ser testado fora do Roblox.
]]

export type Cooldown<K> = {
	pronto: (self: Cooldown<K>, chave: K) -> boolean,
	limpar: (self: Cooldown<K>, chave: K) -> (),
}

type Interno<K> = Cooldown<K> & {
	_duracao: number,
	_relogio: () -> number,
	_ultimo: { [K]: number },
}

local Cooldown = {}
Cooldown.__index = Cooldown

function Cooldown.new<K>(duracao: number, relogio: (() -> number)?): Cooldown<K>
	assert(duracao >= 0, "duracao precisa ser >= 0")
	local self = setmetatable({
		_duracao = duracao,
		_relogio = relogio or os.clock,
		_ultimo = {},
	}, Cooldown)
	return (self :: any) :: Cooldown<K>
end

-- Retorna true e marca o uso se a chave estiver liberada.
function Cooldown.pronto<K>(self: Interno<K>, chave: K): boolean
	local agora = self._relogio()
	local ultimo = self._ultimo[chave]
	if ultimo ~= nil and agora - ultimo < self._duracao then
		return false
	end
	self._ultimo[chave] = agora
	return true
end

function Cooldown.limpar<K>(self: Interno<K>, chave: K)
	self._ultimo[chave] = nil
end

return Cooldown
