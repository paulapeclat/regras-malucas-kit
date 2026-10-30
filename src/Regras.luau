--!strict
--[[
	Catálogo de regras malucas. Cada regra recebe uma BasePart e liga o comportamento
	nela. A configuração vem de Attributes da própria peça, então quem monta a fase
	não precisa abrir nenhum script.
]]

local Util = require(script.Parent.Util)
local Cooldown = require(script.Parent.Cooldown)

export type Regra = (parte: BasePart) -> ()

local Regras: { [string]: Regra } = {}

-- Trampolim: lança o jogador para cima.
-- Attributes: Forca (padrão 120)
Regras.Trampolim = function(parte)
	local cd = Cooldown.new(0.4)
	parte.Touched:Connect(function(hit)
		local alvo = Util.alvoDoToque(hit)
		if not alvo or not cd:pronto(alvo.player) then
			return
		end
		local v = alvo.root.AssemblyLinearVelocity
		alvo.root.AssemblyLinearVelocity = Vector3.new(v.X, Util.numero(parte, "Forca", 120), v.Z)
	end)
end

-- Velocidade: corre mais rápido por alguns segundos.
-- Attributes: Velocidade (40), Duracao (5)
Regras.Velocidade = function(parte)
	local cd = Cooldown.new(0.5)
	parte.Touched:Connect(function(hit)
		local alvo = Util.alvoDoToque(hit)
		if not alvo or not cd:pronto(alvo.player) then
			return
		end
		Util.propriedadeTemporaria(
			alvo.humanoid,
			"WalkSpeed",
			Util.numero(parte, "Velocidade", 40),
			Util.numero(parte, "Duracao", 5)
		)
	end)
end

-- GravidadeLeve: só o jogador que tocou fica leve (não muda a gravidade do servidor todo).
-- Attributes: Fator (0.3 = sente 30% da gravidade), Duracao (5)
Regras.GravidadeLeve = function(parte)
	local cd = Cooldown.new(0.5)
	parte.Touched:Connect(function(hit)
		local alvo = Util.alvoDoToque(hit)
		if not alvo or not cd:pronto(alvo.player) then
			return
		end
		local antiga = alvo.root:FindFirstChild("RegraGravidadeLeve")
		if antiga then
			antiga:Destroy()
		end

		local fator = math.clamp(Util.numero(parte, "Fator", 0.3), 0, 1)
		local anexo = Instance.new("Attachment")
		anexo.Name = "RegraGravidadeLeve"
		local forca = Instance.new("VectorForce")
		forca.RelativeTo = Enum.ActuatorRelativeTo.World
		forca.ApplyAtCenterOfMass = true
		forca.Attachment0 = anexo
		forca.Force = Vector3.new(0, alvo.root.AssemblyMass * workspace.Gravity * (1 - fator), 0)
		forca.Parent = anexo
		anexo.Parent = alvo.root

		task.delay(Util.numero(parte, "Duracao", 5), function()
			if anexo.Parent then
				anexo:Destroy()
			end
		end)
	end)
end

-- Cura: enche a vida.
Regras.Cura = function(parte)
	local cd = Cooldown.new(1)
	parte.Touched:Connect(function(hit)
		local alvo = Util.alvoDoToque(hit)
		if alvo and cd:pronto(alvo.player) then
			alvo.humanoid.Health = alvo.humanoid.MaxHealth
		end
	end)
end

-- Dano: tira um pouco de vida, no máximo uma vez por segundo por jogador.
-- Attributes: Dano (10)
Regras.Dano = function(parte)
	local cd = Cooldown.new(1)
	parte.Touched:Connect(function(hit)
		local alvo = Util.alvoDoToque(hit)
		if alvo and cd:pronto(alvo.player) then
			alvo.humanoid:TakeDamage(Util.numero(parte, "Dano", 10))
		end
	end)
end

-- Morte: o kill brick clássico.
Regras.Morte = function(parte)
	parte.Touched:Connect(function(hit)
		local alvo = Util.alvoDoToque(hit)
		if alvo then
			alvo.humanoid.Health = 0
		end
	end)
end

-- SomeAoTocar: a plataforma vai sumindo e volta depois.
-- Attributes: TempoSumir (1.5), TempoVoltar (3)
Regras.SomeAoTocar = function(parte)
	local transparenciaOriginal = parte.Transparency
	local ocupada = false
	parte.Touched:Connect(function(hit)
		if ocupada or not Util.alvoDoToque(hit) then
			return
		end
		ocupada = true
		local passos = 10
		local tempo = Util.numero(parte, "TempoSumir", 1.5)
		for i = 1, passos do
			parte.Transparency = transparenciaOriginal + (1 - transparenciaOriginal) * (i / passos)
			task.wait(tempo / passos)
		end
		parte.CanCollide = false
		task.wait(Util.numero(parte, "TempoVoltar", 3))
		parte.Transparency = transparenciaOriginal
		parte.CanCollide = true
		ocupada = false
	end)
end

-- PiscaPisca: aparece e some sozinha, em ciclo.
-- Attributes: TempoVisivel (2), TempoInvisivel (2)
Regras.PiscaPisca = function(parte)
	local transparenciaOriginal = parte.Transparency
	task.spawn(function()
		while parte.Parent do
			parte.Transparency = transparenciaOriginal
			parte.CanCollide = true
			task.wait(Util.numero(parte, "TempoVisivel", 2))
			parte.Transparency = 1
			parte.CanCollide = false
			task.wait(Util.numero(parte, "TempoInvisivel", 2))
		end
	end)
end

-- Teleporte: leva o jogador até a peça apontada por um ObjectValue filho chamado "Destino".
Regras.Teleporte = function(parte)
	local cd = Cooldown.new(1.5)
	parte.Touched:Connect(function(hit)
		local alvo = Util.alvoDoToque(hit)
		local destino = parte:FindFirstChild("Destino")
		if not alvo or not destino or not destino:IsA("ObjectValue") then
			return
		end
		local peca = destino.Value
		if peca and peca:IsA("BasePart") and cd:pronto(alvo.player) then
			alvo.character:PivotTo(peca.CFrame + Vector3.new(0, 4, 0))
		end
	end)
end

return Regras
