-- Trecho ILUSTRATIVO do fluxo; não substituir o módulo inteiro por este arquivo.
-- Reutilizar os serviços reais do Crossgrounds já presentes em ExperienceMenu.
-- Premissa: entry tem o id validado em LoadoutDefinitions.List("arena").

local function conectarCard(nav, card, entry, callbacks)
    -- Foco inspeciona, mas NÃO envia escolha ao servidor.
    local focusConnection = nav.FocusChanged:Connect(function(focused)
        if focused == card then
            callbacks.Preview(entry)
        end
    end)

    -- Apenas Activated / A / clique confirma.
    -- ExperienceMenu já fornece callback Select e o servidor valida a escolha.
    local activateConnection = nav:Connect(card, function()
        callbacks.Preview(entry)
        callbacks.Select(entry.id)
    end)

    return function()
        focusConnection:Disconnect()
        activateConnection:Disconnect()
    end
end

return conectarCard
