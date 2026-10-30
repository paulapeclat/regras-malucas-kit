"""Gera facil/RegrasMalucasKit.rbxmx: o kit + uma fase de exemplo, para arrastar no Roblox Studio.

Uso: python3 tools/gerar_kit_facil.py
O código vem de src/, então o arquivo fácil sempre acompanha a versão do kit.
Não há require por ID, HttpService nem nada que baixe código de fora.
"""
import base64
from pathlib import Path
from xml.sax.saxutils import escape

RAIZ = Path(__file__).resolve().parent.parent
SAIDA = RAIZ / "facil" / "RegrasMalucasKit.rbxmx"

_ref = 0


def novo_ref() -> str:
    global _ref
    _ref += 1
    return f"RBX{_ref}"


def cor(hexa: str) -> int:
    return 0xFF000000 | int(hexa.lstrip("#"), 16)


def item(classe: str, props: str, filhos: list[str] = (), ref: str | None = None) -> str:
    return (f'<Item class="{classe}" referent="{ref or novo_ref()}"><Properties>{props}</Properties>'
            + "".join(filhos) + "</Item>")


def nome(n: str) -> str:
    return f'<string name="Name">{escape(n)}</string>'


def codigo(classe: str, n: str, fonte: str, filhos: list[str] = ()) -> str:
    assert "]]>" not in fonte
    return item(classe, nome(n) + f'<ProtectedString name="Source"><![CDATA[{fonte}]]></ProtectedString>', filhos)


def rotulo(texto: str, hexa: str) -> str:
    r, g, b = (int(hexa.lstrip("#")[i:i + 2], 16) / 255 for i in (0, 2, 4))
    label = item("TextLabel", nome("Texto")
                 + f'<string name="Text">{escape(texto)}</string>'
                 + '<UDim2 name="Size"><XS>1</XS><XO>0</XO><YS>1</YS><YO>0</YO></UDim2>'
                 + '<float name="BackgroundTransparency">1</float>'
                 + '<bool name="TextScaled">true</bool>'
                 + f'<Color3 name="TextColor3"><R>{r:.3f}</R><G>{g:.3f}</G><B>{b:.3f}</B></Color3>'
                 + '<float name="TextStrokeTransparency">0</float>'
                 + '<Font name="FontFace"><Family><url>rbxasset://fonts/families/FredokaOne.json</url></Family>'
                   '<Weight>400</Weight><Style>Normal</Style></Font>')
    return item("BillboardGui", nome("Nome da regra")
                + '<UDim2 name="Size"><XS>0</XS><XO>220</XO><YS>0</YS><YO>50</YO></UDim2>'
                + '<Vector3 name="StudsOffset"><X>0</X><Y>4</Y><Z>0</Z></Vector3>'
                + '<float name="MaxDistance">120</float>', [label])


def bloco(n: str, pos, tamanho, hexa: str, tags: list[str], texto: str | None = None,
          filhos: list[str] = (), ref: str | None = None, material: int = 272) -> str:
    x, y, z = pos
    sx, sy, sz = tamanho
    props = (nome(n)
             + '<bool name="Anchored">true</bool>'
             + f'<CoordinateFrame name="CFrame"><X>{x}</X><Y>{y}</Y><Z>{z}</Z>'
               '<R00>1</R00><R01>0</R01><R02>0</R02><R10>0</R10><R11>1</R11><R12>0</R12>'
               '<R20>0</R20><R21>0</R21><R22>1</R22></CoordinateFrame>'
             + f'<Vector3 name="size"><X>{sx}</X><Y>{sy}</Y><Z>{sz}</Z></Vector3>'
             + f'<Color3uint8 name="Color3uint8">{cor(hexa)}</Color3uint8>'
             + f'<token name="Material">{material}</token>'
             + '<token name="TopSurface">0</token><token name="BottomSurface">0</token>')
    if tags:
        props += f'<BinaryString name="Tags">{base64.b64encode(chr(0).join(tags).encode()).decode()}</BinaryString>'
    f = list(filhos)
    if texto:
        f.append(rotulo(texto, "#ffffff"))
    return item("Part", props, f, ref)


def main():
    src = RAIZ / "src"
    ler = lambda n: (src / n).read_text(encoding="utf-8")
    kit = codigo("ModuleScript", "Kit", ler("init.luau"), [
        codigo("ModuleScript", "Regras", ler("Regras.luau")),
        codigo("ModuleScript", "Util", ler("Util.luau")),
        codigo("ModuleScript", "Cooldown", ler("Cooldown.luau")),
    ])
    ligar = codigo("Script", "LigarRegras", (
        "-- Liga as Regras Malucas. Não precisa mexer aqui.\n"
        "-- Qualquer bloco com a etiqueta (Tag) \"Regra:...\" passa a seguir a regra.\n"
        "local Kit = require(script.Parent:WaitForChild(\"Kit\"))\n"
        "Kit.iniciar()\n"))

    # Vitrine 3x3 na frente do ponto de nascimento do Baseplate
    regras = [
        ("Trampolim", "#ffc83d", "TRAMPOLIM"), ("Velocidade", "#38bdf8", "VELOCIDADE"),
        ("GravidadeLeve", "#8b5cf6", "GRAVIDADE LEVE"), ("Cura", "#3ddc84", "CURA"),
        ("Dano", "#fb923c", "DANO"), ("Morte", "#ff5d5d", "MORTE"),
        ("SomeAoTocar", "#f472b6", "SOME AO TOCAR"), ("PiscaPisca", "#facc15", "PISCA-PISCA"),
        ("Teleporte", "#22d3ee", "TELEPORTE"),
    ]
    chegada_ref = novo_ref()
    blocos = []
    for i, (regra, hexa, texto) in enumerate(regras):
        col, lin = i % 3, i // 3
        pos = (-16 + col * 16, 0.5, -24 - lin * 16)
        filhos = []
        if regra == "Teleporte":
            filhos.append(item("ObjectValue", nome("Destino") + f'<Ref name="Value">{chegada_ref}</Ref>'))
        blocos.append(bloco(texto.title(), pos, (10, 1, 10), hexa, [f"Regra:{regra}"], texto, filhos))
    # chegada do teleporte: uma torre ao lado da vitrine
    blocos.append(bloco("Chegada do teleporte", (40, 24, -40), (12, 1, 12), "#22d3ee", [],
                        "CHEGADA", ref=chegada_ref))
    blocos.append(bloco("Torre", (40, 11.75, -40), (4, 23.5, 4), "#2a2236", []))

    fase = item("Folder", nome("Fase de exemplo"), blocos)
    raiz = item("Folder", nome("RegrasMalucasKit"), [ligar, kit, fase])
    xml = ('<roblox xmlns:xmime="http://www.w3.org/2005/05/xmlmime" '
           'xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" '
           'xsi:noNamespaceSchemaLocation="http://www.roblox.com/roblox.xsd" version="4">'
           + raiz + "</roblox>")
    SAIDA.parent.mkdir(exist_ok=True)
    SAIDA.write_text(xml, encoding="utf-8")
    print(SAIDA, len(xml) // 1024, "KB")


if __name__ == "__main__":
    main()
