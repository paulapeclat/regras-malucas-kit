# regras-malucas-kit

![Luau](https://img.shields.io/badge/Luau-strict-00A2FF)
![Roblox](https://img.shields.io/badge/Roblox-Studio-000000)
![License: MIT](https://img.shields.io/badge/license-MIT-green)
[![CI](https://github.com/paulapeclat/regras-malucas-kit/actions/workflows/ci.yml/badge.svg)](https://github.com/paulapeclat/regras-malucas-kit/actions)

**PT** · Mecânicas de obby para Roblox que você liga **sem abrir script**: marque uma Part com uma
Tag, ajuste os Attributes e a regra funciona. Nasceu das regras do meu jogo
[**Regras Malucas!**](https://github.com/paulapeclat/regras-malucas-showcase).

**EN** · Tag-driven obby mechanics for Roblox. Tag a Part, tweak its Attributes, done.
Extracted from my game *Regras Malucas!* (Crazy Rules!).

> 📘 **Livro:** *Crie o primeiro obby com seu filho(a)*, um passo a passo para pais e crianças
> construírem juntos o primeiro jogo, com as regras deste kit explicadas do zero.
> **[Entre na lista de espera →](https://paulapeclat.github.io/primeiro-obby/)**

---

## Por que existe

As primeiras versões das regras eram um script por peça, copiado e colado. Isso gerava três bugs
recorrentes, que este kit resolve por design:

| Problema no script copiado | Como o kit resolve |
|---|---|
| Um toque dispara a regra dezenas de vezes (o `Touched` repete enquanto o pé encosta) | `Cooldown` **por jogador**, que não bloqueia os outros |
| Pisar duas vezes no bônus guardava o valor já aumentado e o bônus ficava para sempre | `Util.propriedadeTemporaria` guarda o valor **original** só no primeiro efeito |
| `workspace.Gravity = 10` deixava **o servidor inteiro** leve | `GravidadeLeve` usa uma `VectorForce` só no jogador que tocou |
| 40 cópias do mesmo script para manter | Um módulo; as peças só têm Tags e Attributes |

## Regras disponíveis

| Tag | O que faz | Attributes (padrão) |
|---|---|---|
| `Regra:Trampolim` | Lança o jogador para cima | `Forca` (120) |
| `Regra:Velocidade` | Corre mais rápido por um tempo | `Velocidade` (40), `Duracao` (5) |
| `Regra:GravidadeLeve` | Só quem tocou fica leve | `Fator` (0.3), `Duracao` (5) |
| `Regra:Cura` | Enche a vida | – |
| `Regra:Dano` | Tira vida, 1×/s por jogador | `Dano` (10) |
| `Regra:Morte` | Kill brick | – |
| `Regra:SomeAoTocar` | Some aos poucos e volta | `TempoSumir` (1.5), `TempoVoltar` (3) |
| `Regra:PiscaPisca` | Aparece e some em ciclo | `TempoVisivel` (2), `TempoInvisivel` (2) |
| `Regra:Teleporte` | Leva até a peça do `ObjectValue` filho `Destino` | – |

## Instalação

**Com Rojo** (recomendado): copie a pasta `src` para o seu projeto e mapeie como `RegrasMalucasKit`
no `ServerScriptService`.

**Com Wally:**
```toml
[server-dependencies]
RegrasMalucasKit = "paulapeclat/regras-malucas-kit@0.1.0"
```

**Sem ferramentas:** crie um ModuleScript `RegrasMalucasKit` com o conteúdo de `src/init.luau` e,
dentro dele, os ModuleScripts `Regras`, `Util` e `Cooldown`.

## Uso

```lua
-- ServerScriptService/IniciarRegras (Script)
local Kit = require(game.ServerScriptService.RegrasMalucasKit)
Kit.iniciar()
```

No Studio: selecione a Part → **Properties → Tags → +** → `Regra:Trampolim`.
Para ajustar, adicione o Attribute `Forca` (number).

### Criando sua própria regra

```lua
local Kit = require(game.ServerScriptService.RegrasMalucasKit)

Kit.Regras.Gigante = function(parte: BasePart)
	parte.Touched:Connect(function(hit)
		-- sua regra aqui; veja src/Regras.luau como modelo
	end)
end

Kit.iniciar() -- registre antes de iniciar
```

## Desenvolvimento

```bash
rokit install                       # rojo, stylua, selene
rojo serve demo.project.json        # place de teste
stylua --check src tests examples
selene src examples
luau tests/Cooldown.spec.luau       # testes, rodam fora do Roblox
```

Decisões técnicas:
- `--!strict` em todos os módulos.
- `Cooldown` não depende do Roblox (recebe o relógio por parâmetro), por isso é testável em Luau puro.
- Tabelas internas com `__mode = "k"` para não segurar peças e humanoids destruídos na memória.
- Toda a lógica roda no **servidor**: o cliente não decide dano, cura nem teleporte.

## Autora

**Paula Peclat** · pedagoga e game developer · [paulapeclat.com.br](https://paulapeclat.com.br)

Licença MIT.
