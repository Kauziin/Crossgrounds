--!strict
-- Crossgrounds | Get Out
-- Configuracao de DESIGN, nao uma implementacao jogavel.
-- Nao habilite rotas/variantes automaticamente sem controllers, mapas e validacao do servidor.
-- Status: "defined" = decisao do criador; "proposed" = sugestao; "pending" = indefinido.
-- Compatibilidade: PC, console/gamepad e dispositivos moveis desde o inicio.

local GetOutConfig = {
    Id = "get_out",
    DisplayName = "Get Out",
    SchemaVersion = 1,
    ImplementationStatus = "design_only",

    QueueCategories = {
        Classic = { Id = "get_out_classic", Variants = { "Classic" }, Status = "defined" },
        Special = { Id = "get_out_special", Variants = { "Mutation", "Infestation", "Juggernaut" }, Status = "defined" },
    },

    -- A configuracao de matchmaking de Get Out Especial permanece pendente:
    -- nao iniciar um lobby de 9 pessoas e depois selecionar um modo de 5/7,
    -- deixando jogadores excedentes de fora.
    Matchmaking = {
        SpecialVotingStrategy = "pending",
        NeverEjectPlayersToFitVariant = true,
    },

    GeneralRules = {
        NoDraws = true,
        -- Ao fim do tempo, a Besta elimina quem ainda estiver na instalacao.
        OnTimerExpired = "beast_eliminates_remaining_survivors",
        -- Resultado individual deve ser persistido mesmo quando outras pessoas escapam.
        IndividualResults = { "escaped", "beast_contained", "captured", "eliminated_at_timeout" },
        -- Sao resultados definidos conceitualmente, nao triggers implementados.
        ServerAuthoritativeObjectives = true,
    },

    Variants = {
        Classic = {
            Status = "defined",
            PlayerCount = "pending", -- Nao presumir 5; a referencia original tinha ate 5.
            Teams = { "survivors", "beast" },
            Goals = { "complete_escape_objective", "escape", "contain_beast" },
            Endings = { "escaped", "beast_contained", "captured", "eliminated_at_timeout" },
            Notes = "Fuga e aprisionamento da Besta sao caminhos diferentes; condicoes detalhadas de contencao pendentes.",
        },
        Mutation = {
            Status = "defined",
            Players = 7,
            Survivors = 6,
            Beasts = 1,
            BeastModifiers = { AllClassPowersAtOnce = true, FasterThanNormal = true },
            EscapeComputerSecurity = "more_vulnerable", -- magnitude pendente
            AlternateObjective = "craft_and_administer_antidote",
            Notes = "Componentes, fabricacao e aplicacao do antidoto ainda nao definidos.",
        },
        Infestation = {
            Status = "defined",
            Players = 5,
            CaptureConvertsSurvivors = true,
            ConvertedBeastClass = "runner_default",
            RemainingSurvivorBenefits = {
                "beast_sprint_ability",
                "periodic_beast_location_ping",
                "expanded_hacking_reflex_hitbox",
            },
            HackSpeedBonusInterpretation = "pending", -- desacordo entre velocidade e tempo de hack
            Notes = "Progressao, valores e criterios de habilidades pendentes.",
        },
        Juggernaut = {
            Status = "defined",
            Players = 9,
            Exorcists = 1,
            Beasts = 8,
            ExorcistWeapon = "purification_weapon",
            HunterRole = "exorcist",
            VictoryConditions = "pending",
            Notes = "As Bestas possuem armas para deter o Exorcista; combate e vitorias exatos pendentes.",
        },
    },

    -- Metodos de fuga propostos pelo criador para Get Out.
    -- Nao estao implementados. Quais aparecem em cada mapa/variante ainda sera decidido.
    -- Recomenda-se configurar a disponibilidade em dados do mapa e nunca inferi-la
    -- apenas por existir uma porta/modelo no Workspace.
    EscapeRoutes = {
        ComputerHack = {
            Status = "defined",
            DisplayName = "Hacking de computadores",
            ObjectiveId = "hack_computers",
            ComputersRequired = 4,
            Completion = "unlock_exit",
            Description = "Hackear quatro computadores para abrir a saida (metodo padrao).",
            AvailabilityByMap = "pending",
        },
        SafeDial = {
            Status = "defined",
            DisplayName = "Cofre de combinacao",
            ObjectiveId = "solve_rotary_dial",
            Interface = "rotating_bank_vault_dial",
            Completion = "unlock_exit",
            Description = "Introduzir uma combinacao em disco rotativo para destrancar a rota de fuga.",
            AvailabilityByMap = "pending",
        },
        LaserShutdown = {
            Status = "defined",
            DisplayName = "Desativacao de lasers",
            ObjectiveId = "disable_laser_barriers",
            DisableEveryBlockingLaser = true,
            Completion = "unlock_exit",
            Description = "Desativar todos os lasers que bloqueiam a porta de saida.",
            AvailabilityByMap = "pending",
        },
        ThermalCutter = {
            Status = "defined",
            DisplayName = "Corte termico da porta",
            ObjectiveId = "assemble_door_cutting_tool",
            CraftTool = true,
            ToolType = "saw_or_dedicated_cutter", -- formato final pendente
            Completion = "cut_edges_and_knock_down_exit_door",
            Description = "Montar uma serra/ferramenta dedicada, derreter/cortar as bordas da porta e derruba-la.",
            AvailabilityByMap = "pending",
        },
        Demolition = {
            Status = "defined",
            DisplayName = "Demolicao da porta",
            ObjectiveId = "breach_exit_door",
            Completion = "destroy_exit_door",
            Description = "Explodir a porta de saida com recurso de demolicao dentro do jogo.",
            AvailabilityByMap = "pending",
        },
    },

    -- Abaixo sao ideias novas, NAO aprovadas nem habilitadas.
    Suggestions = {
        EscapeRouteDesign = {
            Status = "proposed",
            Ideas = {
                "Cada mapa oferece uma ou mais rotas distintas, mas nao necessariamente todas ao mesmo tempo.",
                "Mostrar indicios visuais e auditivos da rota disponivel antes de exigir uma acao complexa.",
                "Rotas silenciosas exigem mais investigacao; rotas barulhentas atraem a Besta.",
                "Cofre: pistas fragmentadas pelo mapa e disco operavel com teclado, controle e toque.",
                "Lasers: desligar paineis em pontos separados; a Besta recebe aviso apenas se isso melhorar o equilibrio.",
                "Cortador: pecas em salas diferentes e etapa final demorada junto a saida.",
                "Demolicao: barulho e contagem visivel criam janela de risco antes da abertura.",
            },
        },
        BeastClasses = {
            Status = "proposed",
            Entries = {
                Tracker = { Name = "Rastreadora", Specialty = "localizar pegadas e evidencias recentes", Counterplay = "andar com cautela e despistar", Weakness = "pouca mobilidade na perseguicao" },
                Warden = { Name = "Carcereira", Specialty = "controlar portas e rotas de resgate", Counterplay = "rotas alternativas e abertura coordenada", Weakness = "menor velocidade" },
                Saboteur = { Name = "Sabotadora", Specialty = "interromper temporariamente objetivos", Counterplay = "reparos rapidos e objetivos distribuidos", Weakness = "baixa capacidade de captura imediata" },
                Stalker = { Name = "Espreitadora", Specialty = "aproximacao silenciosa em distancias curtas", Counterplay = "observacao e sensores do cenario", Weakness = "perde eficiencia em campo aberto" },
                Brute = { Name = "Colosso", Specialty = "romper barreiras e encurtar caminhos", Counterplay = "agilidade, desvios e espacos estreitos", Weakness = "movimento lento e muito perceptivel" },
                Runner = { Name = "Corredora", Specialty = "perseguicao e corrida", Counterplay = "mudancas de direcao e obstaculos", Weakness = "pouco controle de area" },
            },
        },
        OptionalEndings = {
            Status = "proposed",
            Entries = {
                "Evacuacao parcial: cada sobrevivente recebe resultado individual, mesmo quando outros sao capturados.",
                "Evacuacao de emergencia: acionamento de uma unica saida temporaria depois de um evento raro.",
                "Confinamento perfeito: concluir uma cadeia de objetivos e aprisionar a Besta antes da fuga.",
                "Sacrificio: um jogador segura a instalacao e possibilita a fuga dos demais, mas nao escapa.",
            },
            Note = "Nenhuma proposta substitui os finais definidos ou cria empate.",
        },
        EnvironmentalSystems = {
            Status = "proposed",
            Entries = {
                "Quadro de energia: um setor apagado reduz visibilidade, mas abre rotas secundarias.",
                "Ruido por acao: portas arrombadas e ferramentas aumentam temporariamente a deteccao pela Besta.",
                "Eventos de mapa moderados: alarmes, fechamento de setores e falhas de iluminacao.",
                "Objetivos opcionais de risco/recompensa: localizar presos ou restaurar cameras para obter informacao.",
            },
        },
    },

    -- O codigo de gameplay deve ter implementacao autoritativa no servidor.
    -- Em especial: combinacao do cofre, progresso do hack, crafting, limites de
    -- detonacao in-game, liberacao de portas e conclusao de partida.
    SafetyAndAccessibility = {
        ValidateAllObjectivesOnServer = true,
        SupportInput = { "keyboard_mouse", "gamepad", "touch" },
        NoRequiredFreeTextInputForEscape = true,
        NoMapIsAutomaticallyLoadedByThisConfig = true,
    },
}

return GetOutConfig
