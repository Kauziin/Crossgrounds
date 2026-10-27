--!strict
-- Crossgrounds | Get Out
-- Configuracao de DESIGN, nao uma implementacao jogavel.
-- Nao habilite rotas/variantes automaticamente sem controllers, mapas e validacao do servidor.
-- Status: "defined" = decisao do criador; "proposed" = sugestao; "pending" = indefinido.
-- Compatibilidade: PC, console/gamepad e dispositivos moveis desde o inicio.

local GetOutConfig = {
    Id = "get_out",
    DisplayName = "Get Out",
    SchemaVersion = 2,
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

    -- A rodada seleciona UMA rota de fuga compativel com o mapa; as demais nao sao objetivos ativos.
    -- Escolha aleatoria entre rotas validas, com distribuicao/ponderacao a definir.
    EscapeRouteSelection = {
        Status = "defined",
        Method = "random_per_round",
        RoutesPerRound = 1,
        CompatibleMapRoutesOnly = true,
        Weighting = "pending", -- uniformidade/pesos ainda nao aprovados
        NoConcurrentEscapeRoutes = true,
        MapAssetsMustBeValidatedBeforeSelection = true,
    },

    GeneralRules = {
        NoDraws = true,
        -- 10 minutos regulares + 5 minutos de Besta enfurecida, sem terminar aos 10.
        PhaseDurations = {
            BaseSeconds = 600,
            EnragedSeconds = 300,
            TotalSeconds = 900,
        },
        EnragedPhase = {
            StartsAtElapsedSeconds = 600,
            EndsAtElapsedSeconds = 900,
            BeastBecomes = { "enraged", "unstable" },
            EnragedStatChanges = "pending", -- velocidade/dano/efeitos nao especificados
            UnlocksSecretContainment = true,
            ShowContainmentAsObjective = false,
        },
        SecretContainment = {
            Status = "defined",
            AvailableOnlyDuringEnragedPhase = true,
            ShowAsExplicitObjective = false,
            MechanismAndWinTrigger = "pending",
            CoexistsWithEscape = true,
        },
        -- Ao fim de 15 minutos, a Besta elimina os sobreviventes ainda dentro.
        OnTimerExpired = "beast_eliminates_remaining_survivors",
        IndividualResults = { "escaped", "beast_contained", "captured", "eliminated_at_timeout" },
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

    -- Rotas aprovadas CONCEITUALMENTE pelo criador, nao implementadas.
    -- Selecionar uma por rodada aleatoriamente entre as compativeis com o mapa.
    -- Escopo confirmado: dinamica de fuga do Get Out classico; aplicacao automatica
    -- aos modos especiais (sobretudo Juggernaut) permanece PENDENTE.
    EscapeRoutes = {
        ComputerHack = {
            Id = "locks",
            Status = "defined",
            DisplayName = "Travas",
            IsOriginalFleeTheFacilityMethod = true,
            ObjectiveId = "release_all_exit_locks",
            ComputersRequired = 4,
            LocksToRelease = 4,
            ExitDoorCount = 2,
            LockDistributionBetweenDoors = "pending",
            Unlocks = "release_four_locks_blocking_two_exit_doors",
            FinalInteraction = {
                Type = "long_manual_crank",
                RequiredAfterAllHacks = true,
                DurationSeconds = "pending",
                CrankBehaviorPerDoor = "pending",
            },
            EscapeResult = "individual",
            Completion = "open_door_with_crank_then_cross_exit_individually",
            RequiredMapObjects = { "four_hackable_pcs", "four_locks", "two_exit_doors", "exit_crank_interaction" },
            AvailabilityByMap = "pending",
        },
        SafeDial = {
            Id = "vault_code",
            Status = "defined",
            DisplayName = "Cofre",
            ObjectiveId = "reveal_four_digits_and_open_vault",
            Interface = "rotating_bank_vault_dial",
            ComputersRequired = 4,
            DigitsPerComputer = 1,
            CodeLength = 4,
            DigitsRevealedIndividually = true,
            -- Para nao contradizer o aparecimento de cada digito: cada PC publica
            -- seu digito/posicao; o codigo do cofre so e MONTADO e ativado depois
            -- do quarto digito ser revelado. O servidor e a fonte de verdade.
            CombinationFinalization = "assemble_only_after_all_four_digit_reveals",
            CanSubmitBeforeCodeFinalized = false,
            WrongCombinationLockoutSeconds = 30,
            LockoutAppliesTo = "vault_input",
            Completion = "enter_correct_rotary_code_to_open_escape",
            DigitOrderingRules = "pending",
            AvailabilityByMap = "pending",
        },
        LaserShutdown = {
            Id = "laser_shutdown",
            Status = "defined",
            DisplayName = "Lasers",
            ObjectiveId = "solve_security_panels_to_disable_lasers",
            BlockingLaserCount = 4,
            SecurityPanelsDistributedThroughoutMap = true,
            OneSuccessfulPanelDisablesOneBeam = true,
            AllFourBeamsMustBeDisabled = true,
            LaserContact = "instant_death_to_anyone_touching",
            PuzzleStyle = "among_us_like_minigames",
            PuzzleCatalog = "pending", -- minigames concretos ainda nao aprovados
            Completion = "all_four_laser_beams_off_then_exit",
            AvailabilityByMap = "pending",
        },
        ThermalCutter = {
            Id = "thermal_tool",
            Status = "defined",
            DisplayName = "Serra Termica / Arma de Calor",
            ObjectiveId = "collect_parts_assemble_tool_and_open_sealed_door",
            ToolType = "thermal_saw_or_heat_weapon_pending",
            PartsSpawnIn = { "lockers", "chests", "drawers", "other_containers" },
            PartsRequiredCount = "pending",
            MultipleCarriersCanDeliverParts = true,
            AssemblyRequires = { "all_parts", "workbench", "carriers_gathered_at_workbench" },
            OnePlayerUsesAssembledToolAtExit = true,
            DoorOpening = "cut_or_melt_sealed_door_edges_then_drop_door",
            Completion = "door_dropped_then_exit",
            AvailabilityByMap = "pending",
        },
        Demolition = {
            Id = "demolition",
            Status = "defined",
            DisplayName = "Demolicao",
            ObjectiveId = "collect_materials_build_charge_and_breach_door",
            ResourceExamples = { "gunpowder", "other_components_pending" },
            CollectionAndAssemblyFlow = "same_as_thermal_tool",
            AssembleAtWorkbench = true,
            PlantExplosivesOnExitDoor = true,
            DetonationDelaySeconds = 15,
            ChargeCountAndPlacementRules = "pending",
            Completion = "detonate_charge_to_destroy_exit_door",
            AvailabilityByMap = "pending",
        },
    },

    -- Hacker e uma classe/habilidade da BESTA; nao um poder de sobrevivente.
    BeastAbilityDefinitions = {
        Hacker = {
            Status = "defined",
            Role = "beast",
            Id = "hacker",
            SelectAbilityByActiveEscapeRoute = true,
            PCObjectives = {
                AppliesToEscapeRoutes = { "locks", "vault_code" },
                Action = "undo_pc_hacking_progress",
                CooldownSeconds = 150,
                -- Escopo exato do rollback: qual PC, quanto progresso, estado
                -- de digitos ja revelados e se pode reverter travas liberadas.
                RollbackTargetsAndAmount = "pending",
            },
            NonPCObjectives = {
                AppliesToEscapeRoutes = { "laser_shutdown", "thermal_tool", "demolition" },
                Action = "emp_wave_marks_metallic_items",
                CooldownSeconds = 180,
                Origin = "beast",
                Shape = "expanding_circular_wave",
                Pulses = 5,
                SecondsPerPulse = 2,
                TotalPulseDurationSeconds = 10,
                DetectableTargets = "metallic_objects_and_items",
                MetalTaggingAndRange = "pending",
                RevealAudienceAndVisibility = "pending",
                AdditionalDisruptionEffect = "pending", -- nao pressupor dano/desativacao
            },
        },
    },

    -- Abaixo sao ideias novas, NAO aprovadas nem habilitadas.
    Suggestions = {
        EscapeRouteDesign = {
            Status = "proposed",
            Ideas = {
                "Validar assets exigidos pelo objetivo antes do sorteio; nunca selecionar uma rota incompleta no mapa.",
                "Mostrar ao grupo apenas o metodo sorteado, mas manter o aprisionamento da Besta oculto.",
                "Nao remapear uma rota depois que a rodada comecou, mesmo que objetivos fiquem indisponiveis por bugs.",
            },
        },
        PuzzleDesign = {
            Status = "proposed",
            Entries = {
                CircuitPairs = { Name = "Pareamento de Fios", Task = "ligar 4 pares de terminais identificados por cor e icone; ordem livre", Win = "quatro pares corretos" },
                RotateNodes = { Name = "Reconectar Circuito", Task = "rotacionar 5 nos em 4 orientacoes para conduzir energia da origem ao destino", Win = "um caminho eletrico continuo" },
                SignalTuning = { Name = "Sincronizar Sinal", Task = "alinhar 3 frequencias com tres indicadores de referencia, usando botoes esquerdo/direito", Win = "todos os tres canais alinhados" },
            },
            Accessibility = "todos os puzzles com foco navegavel no controle e sem exigir arrastar com mouse",
        },
        SecretContainmentDesign = {
            Status = "proposed",
            Trigger = "durante a fase enfurecida, uma sala de contencao recebe energia automaticamente",
            PlayerSteps = {
                "ativar dois quadros de seguranca distintos, cada um com interacao de 8 segundos",
                "atrair a Besta para o interior da camara sinalizada por luzes intermitentes",
                "um sobrevivente aciona a alavanca externa durante 4 segundos; a porta fecha e a Besta fica contida",
            },
            Failure = "se a Besta sair antes do fechamento, cancelar e rearmar os dois quadros",
            NotShownAsObjective = true,
            BalanceNote = "a Besta percebe a sala energizada pelo cenario; nao recebe indicador de objetivo",
        },
        HackerBalance = {
            Status = "proposed",
            PCRollback = "reverter o ultimo PC integralmente hackeado, apenas se a porta ainda nao estiver aberta; nunca apagar mais de 1 dos 4 progressos por ativacao",
            EMPRangeStuds = 45,
            EMPMarksMetallicItemsForSeconds = 4,
            EMPThroughWalls = true,
            TelegraphSeconds = 1,
            Note = "proposta numerica de teste, nao substituir limites/efeitos ainda pendentes pela escolha do criador",
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
                -- A classe Hacker definida pelo criador encontra-se em BeastAbilityDefinitions, nao aqui.

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
        SecretObjectiveNotReplicatedToPublicHUD = true,
        LaserTouchAndEMPDetectionServerValidated = true,
    },
}

return GetOutConfig
