--=============================================================
--  GHOST SCRIPTS - PAINEL DE ESCOLHA (PC / MOBILE)
--  Nada roda antes do clique.
--  O jogador escolhe o modo -> SO ENTAO o loadstring executa.
--=============================================================
local PHIL_UIS = game:GetService("UserInputService")
local PHIL_LP  = game:GetService("Players").LocalPlayer

--========================== LINKS ============================
local URL_PC     = "https://raw.githubusercontent.com/ghosthub031-dev/Script-ghost-Scripts-para-arcenal-/refs/heads/main/ghost_scripts_arsenal_pc.lua"
local URL_MOBILE = "https://raw.githubusercontent.com/ghosthub031-dev/Script-ghost-Scripts-para-arcenal-/refs/heads/main/ghost_scripts_arsenal_mobile.lua"

--============= DETECCAO AUTOMATICA (SO VISUAL) ===============
-- Nao executa nada: apenas sugere e destaca o botao certo.
local modo_detectado = "pc"
if PHIL_UIS.TouchEnabled and not PHIL_UIS.KeyboardEnabled then
    modo_detectado = "mobile"
end

--========================= GUI BASE ==========================
local gui = Instance.new("ScreenGui")
gui.Name = "GhostScriptsLoader"
gui.ResetOnSpawn = false
gui.IgnoreGuiInset = true
gui.DisplayOrder = 2000000
gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

local okParent = false
pcall(function()
    local alvo = (gethui and gethui()) or game:GetService("CoreGui")
    gui.Parent = alvo
    okParent = gui.Parent ~= nil
end)
if not okParent then
    pcall(function() gui.Parent = PHIL_LP:WaitForChild("PlayerGui") end)
end

--====================== PAINEL CENTRAL =======================
local painel = Instance.new("Frame")
painel.Name = "Painel"
painel.AnchorPoint = Vector2.new(0.5, 0.5)
painel.Position = UDim2.fromScale(0.5, 0.5)
painel.Size = UDim2.fromOffset(440, 300)
painel.BackgroundColor3 = Color3.fromRGB(17, 17, 21)
painel.BorderSizePixel = 0
painel.Active = true
painel.Parent = gui

local pCorner = Instance.new("UICorner")
pCorner.CornerRadius = UDim.new(0, 16)
pCorner.Parent = painel

local pStroke = Instance.new("UIStroke")
pStroke.Color = Color3.fromRGB(72, 72, 84)
pStroke.Thickness = 2
pStroke.Parent = painel

-- escala para caber em telas de celular
local escala = Instance.new("UIScale")
escala.Parent = painel
pcall(function()
    local cam = workspace.CurrentCamera
    local vp = cam and cam.ViewportSize or Vector2.new(1280, 720)
    escala.Scale = math.clamp(math.min(vp.X / 560, vp.Y / 430), 0.58, 1)
end)

--==================== TITULO / SUBTITULO =====================
local titulo = Instance.new("TextLabel")
titulo.Size = UDim2.new(1, 0, 0, 40)
titulo.Position = UDim2.fromOffset(0, 16)
titulo.BackgroundTransparency = 1
titulo.Text = "👻 GHOST SCRIPTS (ARCENAL)"
titulo.TextColor3 = Color3.fromRGB(255, 255, 255)
titulo.TextSize = 26
titulo.Font = Enum.Font.GothamBlack
titulo.Parent = painel

local subtitulo = Instance.new("TextLabel")
subtitulo.Size = UDim2.new(1, -20, 0, 36)
subtitulo.Position = UDim2.fromOffset(10, 54)
subtitulo.BackgroundTransparency = 1
subtitulo.Text = "Escolha o seu dispositivo\nChoose your device"
subtitulo.TextColor3 = Color3.fromRGB(160, 160, 172)
subtitulo.TextSize = 14
subtitulo.TextWrapped = true
subtitulo.Font = Enum.Font.Gotham
subtitulo.Parent = painel

--========================= BOTOES ============================
local function novoBotao(texto, cor)
    local b = Instance.new("TextButton")
    b.BackgroundColor3 = cor
    b.Text = texto
    b.TextColor3 = Color3.fromRGB(255, 255, 255)
    b.TextSize = 19
    b.Font = Enum.Font.GothamBold
    b.AutoButtonColor = true
    b.BorderSizePixel = 0
    b.Parent = painel

    local c = Instance.new("UICorner")
    c.CornerRadius = UDim.new(0, 12)
    c.Parent = b

    local s = Instance.new("UIStroke")
    s.Color = Color3.fromRGB(78, 78, 90)
    s.Thickness = 1.5
    s.Parent = b

    return b, s
end

-- Botoes: emoji + nome do modo e a traducao (PT em cima, EN embaixo)
local txtPC     = "🖥️ PC\nComputador | Computer"
local txtMobile = "📱 MOBILE\nCelular | Phone"

local btnPC, strokePC = novoBotao(txtPC, Color3.fromRGB(32, 78, 150))
btnPC.Size = UDim2.fromOffset(185, 92)
btnPC.Position = UDim2.fromOffset(20, 100)
btnPC.TextSize = 16
btnPC.TextWrapped = true

local btnMobile, strokeMobile = novoBotao(txtMobile, Color3.fromRGB(32, 120, 82))
btnMobile.Size = UDim2.fromOffset(185, 92)
btnMobile.Position = UDim2.fromOffset(235, 100)
btnMobile.TextSize = 16
btnMobile.TextWrapped = true

--=================== STATUS / DETECCAO =======================
local status = Instance.new("TextLabel")
status.Size = UDim2.new(1, -40, 0, 48)
status.Position = UDim2.new(0, 20, 1, -60)
status.BackgroundTransparency = 1
status.TextSize = 13
status.Font = Enum.Font.GothamMedium
status.TextXAlignment = Enum.TextXAlignment.Left
status.TextYAlignment = Enum.TextYAlignment.Center
status.TextWrapped = true
status.Parent = painel

if modo_detectado == "mobile" then
    status.Text = "📱 Detectado: MOBILE (toque)\nDetected: MOBILE (touch) - tap MOBILE to load"
    status.TextColor3 = Color3.fromRGB(120, 205, 145)
    strokeMobile.Color = Color3.fromRGB(120, 205, 145)
    strokeMobile.Thickness = 2.5
else
    status.Text = "🖥️ Detectado: PC (teclado e mouse)\nDetected: PC (keyboard & mouse) - click PC to load"
    status.TextColor3 = Color3.fromRGB(120, 170, 235)
    strokePC.Color = Color3.fromRGB(120, 170, 235)
    strokePC.Thickness = 2.5
end

--================= ARRASTAR O PAINEL (mobile) ================
do
    local arrastando, inicio, posInicial = false, nil, nil
    titulo.InputBegan:Connect(function(input)
        local t = input.UserInputType
        if t == Enum.UserInputType.Touch or t == Enum.UserInputType.MouseButton1 then
            arrastando = true
            inicio = input.Position
            posInicial = painel.Position
        end
    end)
    PHIL_UIS.InputChanged:Connect(function(input)
        if not arrastando then return end
        local t = input.UserInputType
        if t == Enum.UserInputType.Touch or t == Enum.UserInputType.MouseMovement then
            local d = input.Position - inicio
            painel.Position = UDim2.new(posInicial.X.Scale, posInicial.X.Offset + d.X,
                                        posInicial.Y.Scale, posInicial.Y.Offset + d.Y)
        end
    end)
    PHIL_UIS.InputEnded:Connect(function(input)
        local t = input.UserInputType
        if t == Enum.UserInputType.Touch or t == Enum.UserInputType.MouseButton1 then
            arrastando = false
        end
    end)
end

--=================== CARREGAR (SO NO CLIQUE) ==================
local executando = false

local function carregar(modo)
    if executando then return end
    executando = true

    local url = (modo == "mobile") and URL_MOBILE or URL_PC
    local botao = (modo == "mobile") and btnMobile or btnPC

    botao.Text = "⏳ CARREGANDO...\nLOADING..."
    status.TextColor3 = Color3.fromRGB(230, 200, 120)
    status.Text = "Baixando script / Downloading: " .. string.upper(modo) .. "..."
    task.wait(0.15)

    -- 1) baixa o script escolhido (nada executado ainda)
    local fonte, erro
    local okDownload = pcall(function()
        fonte = game:HttpGet(url)
    end)

    if not okDownload or type(fonte) ~= "string" or #fonte < 20 then
        executando = false
        botao.Text = (modo == "mobile") and txtMobile or txtPC
        status.TextColor3 = Color3.fromRGB(240, 120, 120)
        status.Text = "❌ Falha ao baixar o script\nDownload failed - check your internet and try again"
        warn("[Ghost Scripts] Falha no download: " .. tostring(fonte or erro))
        return
    end

    -- 2) fecha o painel para nao ficar em cima do menu do script
    gui:Destroy()

    -- 3) SO AQUI o loadstring roda - e somente do modo escolhido
    local okRun, erroRun = pcall(function()
        local chunk = loadstring(fonte)
        if not chunk then
            error("loadstring retornou nil (executor sem loadstring?)")
        end
        return chunk()
    end)

    if not okRun then
        warn("[Ghost Scripts] Erro ao executar (" .. modo .. "): " .. tostring(erroRun))
    end
end

btnPC.MouseButton1Click:Connect(function() carregar("pc") end)
btnMobile.MouseButton1Click:Connect(function() carregar("mobile") end)
