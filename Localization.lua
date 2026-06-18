local addonName, ns = ...

local L = {}
ns.L = L

-- Fallback: return key if translation missing
setmetatable(L, { __index = function(_, k) return k end })

-- Detect game locale
local locale = GetLocale()

-- ═══════════════════════════════════════════════════════════════════════════════
-- English (default / fallback)
-- ═══════════════════════════════════════════════════════════════════════════════

-- General
L["PI_ASSISTANT"]            = "Will Pay 4 PI"
L["ENABLED"]                 = "Enabled"
L["DISABLED"]                = "Disabled"
L["ENABLE"]                  = "Enable"
L["DISABLE"]                 = "Disable"
L["STATUS"]                  = "Status"
L["VERSION"]                 = "Version"
L["SAVE"]                    = "Save"
L["CANCEL"]                  = "Cancel"
L["RESET"]                   = "Reset"
L["DELETE"]                  = "Delete"
L["IMPORT"]                  = "Import"
L["EXPORT"]                  = "Export"
L["ADD"]                     = "Add"
L["REMOVE"]                  = "Remove"
L["APPLY"]                   = "Apply"
L["CLOSE"]                   = "Close"
L["NONE"]                    = "None"
L["UNKNOWN"]                 = "Unknown"

-- Tabs
L["TAB_DASHBOARD"]           = "Dashboard"
L["TAB_PRIESTS"]             = "Priests"
L["TAB_BURST"]               = "Burst"
L["TAB_MESSAGES"]            = "Messages"
L["TAB_STATISTICS"]          = "Statistics"
L["TAB_ALERTS"]              = "Alerts"

-- Dashboard
L["DASH_CLASS"]              = "Class"
L["DASH_SPEC"]               = "Specialization"
L["DASH_HERO_TALENT"]        = "Hero Talent"
L["DASH_SELECTED_PRIEST"]    = "Selected Priest"
L["DASH_AVAILABLE_PRIESTS"]  = "Available Priests"
L["DASH_ADDON_STATUS"]       = "Addon Status"
L["DASH_LAST_REQUEST"]       = "Last Request"
L["DASH_LAST_PI"]            = "Last PI Received"
L["DASH_LAST_BURST"]         = "Last Burst"
L["DASH_NEVER"]              = "Never"
L["DASH_AGO"]                = "ago"
L["DASH_WAITING"]            = "Waiting..."
L["DASH_NONE_YET"]           = "None yet"
L["DASH_CD_REMAINING"]       = "CD: %s"

-- Priests
L["PRIEST_NAME"]             = "Name"
L["PRIEST_SPEC"]             = "Spec"
L["PRIEST_STATUS"]           = "Status"
L["PRIEST_SELECT"]           = "Select"
L["PRIEST_NO_PRIESTS"]       = "No priests found in your group."
L["PRIEST_ONLINE"]           = "Online"
L["PRIEST_OFFLINE"]          = "Offline"
L["PRIEST_DEAD"]             = "Dead"
L["PRIEST_ALIVE"]            = "Alive"
L["PRIEST_SCAN"]             = "Scan Group"

-- Burst
L["BURST_SPELLS"]            = "Burst Spells"
L["BURST_ADD"]               = "Add"
L["BURST_LOAD_DEFAULTS"]     = "Load Defaults"
L["BURST_TEST"]              = "Test Burst"
L["BURST_NO_SPELLS"]         = "No burst spells configured. Add spell IDs or load defaults."
L["BURST_INVALID_ID"]        = "Invalid Spell ID"

-- Messages
L["MSG_TEMPLATE"]            = "Template"
L["MSG_CHANNEL"]             = "Channel"
L["MSG_COOLDOWN"]            = "Cooldown"
L["MSG_PREVIEW"]             = "Preview"
L["MSG_VARIABLES"]           = "Variables"
L["MSG_SEND_NOW"]            = "Send Now"
L["MSG_QUICK_TEMPLATES"]     = "Quick Templates"
L["MSG_CHANNEL_WHISPER"]     = "Whisper"
L["MSG_CHANNEL_PARTY"]       = "Party"
L["MSG_CHANNEL_RAID"]        = "Raid"
L["MSG_CHANNEL_INSTANCE"]    = "Instance"
L["MSG_CHANNEL_SAY"]         = "Say"
L["MSG_CHANNEL_YELL"]        = "Yell"
L["MSG_SENT"]                = "PI request sent to %s"
L["MSG_FAILED"]              = "Failed to send: %s"

-- Statistics
L["STAT_BURSTS_DETECTED"]    = "Bursts"
L["STAT_REQUESTS_SENT"]      = "Requests"
L["STAT_PI_RECEIVED"]        = "PI Received"
L["STAT_PI_LOST"]            = "Failed"
L["STAT_SUCCESS_RATE"]       = "Success Rate"
L["STAT_TOP_PRIEST"]         = "Top Priest"
L["STAT_AVG_RESPONSE"]       = "Avg Response"
L["STAT_HISTORY"]            = "Recent History"
L["STAT_NO_HISTORY"]         = "No history yet."
L["STAT_SUCCESS"]            = "Success"
L["STAT_FAILED"]             = "Failed"
L["STAT_RESET_CONFIRM"]      = "Reset all statistics?"

-- Alerts
L["ALERT_SETTINGS"]          = "Alert Settings"
L["ALERT_VISUAL"]            = "Visual"
L["ALERT_SOUND"]             = "Sound"
L["ALERT_POSITION"]          = "Position"
L["ALERT_TEST_VISUAL"]       = "Test Visual"
L["ALERT_TEST_SOUND"]        = "Test Sound"
L["ALERT_BURST_TITLE"]       = "BURST"
L["ALERT_PI_RECEIVED"]       = "Power Infusion Active!"
L["ALERT_NO_PRIEST"]         = "No Priest available"

-- Errors
L["ERR_NO_GROUP"]            = "Not in a group"
L["ERR_PRIEST_DEAD"]         = "Priest is dead"
L["ERR_PRIEST_OFFLINE"]      = "Priest is offline"
L["ERR_PRIEST_NOT_IN_GROUP"] = "Priest not in group"
L["ERR_ON_COOLDOWN"]         = "On cooldown (%.0fs remaining)"

-- Profiles
L["PROFILE_TITLE"]           = "Profiles"

-- ═══════════════════════════════════════════════════════════════════════════════
-- Portuguese (ptBR)
-- ═══════════════════════════════════════════════════════════════════════════════

if locale == "ptBR" then
    L["ENABLED"]                 = "Ativado"
    L["DISABLED"]                = "Desativado"
    L["ENABLE"]                  = "Ativar"
    L["DISABLE"]                 = "Desativar"
    L["NONE"]                    = "Nenhum"
    L["UNKNOWN"]                 = "Desconhecido"

    L["TAB_DASHBOARD"]           = "Painel"
    L["TAB_PRIESTS"]             = "Sacerdotes"
    L["TAB_BURST"]               = "Burst"
    L["TAB_MESSAGES"]            = "Mensagens"
    L["TAB_STATISTICS"]          = "Estatisticas"
    L["TAB_ALERTS"]              = "Alertas"

    L["DASH_CLASS"]              = "Classe"
    L["DASH_SPEC"]               = "Especializacao"
    L["DASH_HERO_TALENT"]        = "Talento Heroico"
    L["DASH_SELECTED_PRIEST"]    = "Sacerdote Selecionado"
    L["DASH_AVAILABLE_PRIESTS"]  = "Sacerdotes Disponiveis"
    L["DASH_ADDON_STATUS"]       = "Status do Addon"
    L["DASH_LAST_REQUEST"]       = "Ultimo Pedido"
    L["DASH_LAST_PI"]            = "Ultimo PI Recebido"
    L["DASH_LAST_BURST"]         = "Ultimo Burst"
    L["DASH_NEVER"]              = "Nunca"
    L["DASH_AGO"]                = "atras"
    L["DASH_WAITING"]            = "Aguardando..."
    L["DASH_NONE_YET"]           = "Nenhum ainda"
    L["DASH_CD_REMAINING"]       = "CD: %s"

    L["PRIEST_NO_PRIESTS"]       = "Nenhum sacerdote encontrado no grupo."
    L["PRIEST_ONLINE"]           = "Online"
    L["PRIEST_OFFLINE"]          = "Offline"
    L["PRIEST_DEAD"]             = "Morto"
    L["PRIEST_ALIVE"]            = "Vivo"
    L["PRIEST_SCAN"]             = "Escanear Grupo"
    L["PRIEST_SELECT"]           = "Selecionar"

    L["BURST_SPELLS"]            = "Spells de Burst"
    L["BURST_ADD"]               = "Adicionar"
    L["BURST_LOAD_DEFAULTS"]     = "Carregar Padrao"
    L["BURST_TEST"]              = "Testar Burst"
    L["BURST_NO_SPELLS"]         = "Nenhuma spell de burst configurada. Adicione IDs ou carregue o padrao."
    L["BURST_INVALID_ID"]        = "ID de Spell invalido"

    L["MSG_TEMPLATE"]            = "Modelo"
    L["MSG_CHANNEL"]             = "Canal"
    L["MSG_COOLDOWN"]            = "Cooldown"
    L["MSG_PREVIEW"]             = "Previa"
    L["MSG_VARIABLES"]           = "Variaveis"
    L["MSG_SEND_NOW"]            = "Enviar Agora"
    L["MSG_QUICK_TEMPLATES"]     = "Modelos Rapidos"
    L["MSG_SENT"]                = "PI pedido enviado para %s"
    L["MSG_FAILED"]              = "Falha ao enviar: %s"

    L["STAT_BURSTS_DETECTED"]    = "Bursts"
    L["STAT_REQUESTS_SENT"]      = "Pedidos"
    L["STAT_PI_RECEIVED"]        = "PI Recebido"
    L["STAT_PI_LOST"]            = "Falhas"
    L["STAT_SUCCESS_RATE"]       = "Taxa de Sucesso"
    L["STAT_TOP_PRIEST"]         = "Priest Mais Usado"
    L["STAT_AVG_RESPONSE"]       = "Tempo Medio"
    L["STAT_HISTORY"]            = "Historico Recente"
    L["STAT_NO_HISTORY"]         = "Sem historico ainda."
    L["STAT_SUCCESS"]            = "Sucesso"
    L["STAT_FAILED"]             = "Falhou"
    L["STAT_RESET_CONFIRM"]      = "Resetar todas as estatisticas?"

    L["ALERT_SETTINGS"]          = "Config. de Alertas"
    L["ALERT_TEST_VISUAL"]       = "Testar Visual"
    L["ALERT_TEST_SOUND"]        = "Testar Som"
    L["ALERT_PI_RECEIVED"]       = "Power Infusion Ativo!"
    L["ALERT_NO_PRIEST"]         = "Nenhum Priest disponivel"

    L["ERR_NO_GROUP"]            = "Nao esta em grupo"
    L["ERR_PRIEST_DEAD"]         = "Priest esta morto"
    L["ERR_PRIEST_OFFLINE"]      = "Priest esta offline"
    L["ERR_ON_COOLDOWN"]         = "Em cooldown (%.0fs restantes)"

    L["PROFILE_TITLE"]           = "Perfis"

-- ═══════════════════════════════════════════════════════════════════════════════
-- Spanish (esES / esMX)
-- ═══════════════════════════════════════════════════════════════════════════════

elseif locale == "esES" or locale == "esMX" then
    L["ENABLED"]                 = "Activado"
    L["DISABLED"]                = "Desactivado"
    L["ENABLE"]                  = "Activar"
    L["DISABLE"]                 = "Desactivar"
    L["NONE"]                    = "Ninguno"
    L["UNKNOWN"]                 = "Desconocido"

    L["TAB_DASHBOARD"]           = "Panel"
    L["TAB_PRIESTS"]             = "Sacerdotes"
    L["TAB_MESSAGES"]            = "Mensajes"
    L["TAB_STATISTICS"]          = "Estadisticas"
    L["TAB_ALERTS"]              = "Alertas"

    L["DASH_CLASS"]              = "Clase"
    L["DASH_SPEC"]               = "Especializacion"
    L["DASH_HERO_TALENT"]        = "Talento Heroico"
    L["DASH_SELECTED_PRIEST"]    = "Sacerdote Seleccionado"
    L["DASH_AVAILABLE_PRIESTS"]  = "Sacerdotes Disponibles"
    L["DASH_LAST_REQUEST"]       = "Ultima Solicitud"
    L["DASH_LAST_PI"]            = "Ultimo PI Recibido"
    L["DASH_LAST_BURST"]         = "Ultimo Burst"
    L["DASH_NEVER"]              = "Nunca"
    L["DASH_AGO"]                = "hace"
    L["DASH_WAITING"]            = "Esperando..."
    L["DASH_NONE_YET"]           = "Ninguno aun"

    L["PRIEST_NO_PRIESTS"]       = "No se encontraron sacerdotes en el grupo."
    L["PRIEST_ONLINE"]           = "En linea"
    L["PRIEST_OFFLINE"]          = "Desconectado"
    L["PRIEST_DEAD"]             = "Muerto"
    L["PRIEST_ALIVE"]            = "Vivo"
    L["PRIEST_SCAN"]             = "Escanear Grupo"
    L["PRIEST_SELECT"]           = "Seleccionar"

    L["BURST_SPELLS"]            = "Hechizos de Burst"
    L["BURST_TEST"]              = "Probar Burst"
    L["BURST_NO_SPELLS"]         = "Sin hechizos de burst. Agrega IDs o carga valores por defecto."

    L["MSG_TEMPLATE"]            = "Plantilla"
    L["MSG_CHANNEL"]             = "Canal"
    L["MSG_PREVIEW"]             = "Vista previa"
    L["MSG_SEND_NOW"]            = "Enviar Ahora"
    L["MSG_SENT"]                = "Solicitud de PI enviada a %s"

    L["STAT_HISTORY"]            = "Historial Reciente"
    L["STAT_NO_HISTORY"]         = "Sin historial."
    L["STAT_RESET_CONFIRM"]      = "Reiniciar todas las estadisticas?"

    L["ALERT_PI_RECEIVED"]       = "Power Infusion Activo!"
    L["ALERT_NO_PRIEST"]         = "Ningun Priest disponible"

    L["ERR_NO_GROUP"]            = "No estas en grupo"
    L["ERR_ON_COOLDOWN"]         = "En cooldown (%.0fs restantes)"

    L["PROFILE_TITLE"]           = "Perfiles"

-- ═══════════════════════════════════════════════════════════════════════════════
-- German (deDE)
-- ═══════════════════════════════════════════════════════════════════════════════

elseif locale == "deDE" then
    L["ENABLED"]                 = "Aktiviert"
    L["DISABLED"]                = "Deaktiviert"
    L["ENABLE"]                  = "Aktivieren"
    L["DISABLE"]                 = "Deaktivieren"
    L["NONE"]                    = "Keiner"
    L["UNKNOWN"]                 = "Unbekannt"

    L["TAB_DASHBOARD"]           = "Uebersicht"
    L["TAB_PRIESTS"]             = "Priester"
    L["TAB_MESSAGES"]            = "Nachrichten"
    L["TAB_STATISTICS"]          = "Statistiken"
    L["TAB_ALERTS"]              = "Alarme"

    L["DASH_CLASS"]              = "Klasse"
    L["DASH_SPEC"]               = "Spezialisierung"
    L["DASH_HERO_TALENT"]        = "Heldentalent"
    L["DASH_SELECTED_PRIEST"]    = "Ausgewaehlter Priester"
    L["DASH_AVAILABLE_PRIESTS"]  = "Verfuegbare Priester"
    L["DASH_LAST_REQUEST"]       = "Letzte Anfrage"
    L["DASH_LAST_PI"]            = "Letztes PI"
    L["DASH_LAST_BURST"]         = "Letzter Burst"
    L["DASH_NEVER"]              = "Nie"
    L["DASH_AGO"]                = "her"
    L["DASH_WAITING"]            = "Warte..."
    L["DASH_NONE_YET"]           = "Noch keiner"

    L["PRIEST_NO_PRIESTS"]       = "Keine Priester in der Gruppe gefunden."
    L["PRIEST_SCAN"]             = "Gruppe scannen"
    L["PRIEST_SELECT"]           = "Waehlen"

    L["BURST_SPELLS"]            = "Burst-Zauber"
    L["BURST_TEST"]              = "Burst testen"

    L["MSG_SEND_NOW"]            = "Jetzt senden"
    L["MSG_SENT"]                = "PI-Anfrage an %s gesendet"

    L["ALERT_PI_RECEIVED"]       = "Power Infusion aktiv!"
    L["ERR_ON_COOLDOWN"]         = "Abklingzeit (%.0fs verbleibend)"

    L["PROFILE_TITLE"]           = "Profile"

-- ═══════════════════════════════════════════════════════════════════════════════
-- French (frFR)
-- ═══════════════════════════════════════════════════════════════════════════════

elseif locale == "frFR" then
    L["ENABLED"]                 = "Active"
    L["DISABLED"]                = "Desactive"
    L["ENABLE"]                  = "Activer"
    L["DISABLE"]                 = "Desactiver"
    L["NONE"]                    = "Aucun"
    L["UNKNOWN"]                 = "Inconnu"

    L["TAB_DASHBOARD"]           = "Tableau de bord"
    L["TAB_PRIESTS"]             = "Pretres"
    L["TAB_MESSAGES"]            = "Messages"
    L["TAB_STATISTICS"]          = "Statistiques"
    L["TAB_ALERTS"]              = "Alertes"

    L["DASH_CLASS"]              = "Classe"
    L["DASH_SPEC"]               = "Specialisation"
    L["DASH_HERO_TALENT"]        = "Talent heroique"
    L["DASH_SELECTED_PRIEST"]    = "Pretre selectionne"
    L["DASH_AVAILABLE_PRIESTS"]  = "Pretres disponibles"
    L["DASH_NEVER"]              = "Jamais"
    L["DASH_AGO"]                = "il y a"
    L["DASH_WAITING"]            = "En attente..."

    L["PRIEST_NO_PRIESTS"]       = "Aucun pretre trouve dans le groupe."
    L["PRIEST_SCAN"]             = "Scanner le groupe"
    L["PRIEST_SELECT"]           = "Choisir"

    L["MSG_SEND_NOW"]            = "Envoyer"
    L["MSG_SENT"]                = "Demande de PI envoyee a %s"

    L["ALERT_PI_RECEIVED"]       = "Infusion de puissance active !"
    L["ERR_ON_COOLDOWN"]         = "En recharge (%.0fs restantes)"

    L["PROFILE_TITLE"]           = "Profils"

-- ═══════════════════════════════════════════════════════════════════════════════
-- Korean (koKR)
-- ═══════════════════════════════════════════════════════════════════════════════

elseif locale == "koKR" then
    L["TAB_DASHBOARD"]           = "대시보드"
    L["TAB_PRIESTS"]             = "사제"
    L["TAB_MESSAGES"]            = "메시지"
    L["TAB_STATISTICS"]          = "통계"
    L["TAB_ALERTS"]              = "알림"
    L["ALERT_PI_RECEIVED"]       = "마력 주입 활성화!"
    L["PRIEST_NO_PRIESTS"]       = "그룹에서 사제를 찾을 수 없습니다."

-- ═══════════════════════════════════════════════════════════════════════════════
-- Chinese Simplified (zhCN)
-- ═══════════════════════════════════════════════════════════════════════════════

elseif locale == "zhCN" then
    L["TAB_DASHBOARD"]           = "面板"
    L["TAB_PRIESTS"]             = "牧师"
    L["TAB_MESSAGES"]            = "消息"
    L["TAB_STATISTICS"]          = "统计"
    L["TAB_ALERTS"]              = "警报"
    L["ALERT_PI_RECEIVED"]       = "能量灌注已激活!"
    L["PRIEST_NO_PRIESTS"]       = "队伍中没有找到牧师。"

-- ═══════════════════════════════════════════════════════════════════════════════
-- Chinese Traditional (zhTW)
-- ═══════════════════════════════════════════════════════════════════════════════

elseif locale == "zhTW" then
    L["TAB_DASHBOARD"]           = "面板"
    L["TAB_PRIESTS"]             = "牧師"
    L["TAB_MESSAGES"]            = "訊息"
    L["TAB_STATISTICS"]          = "統計"
    L["TAB_ALERTS"]              = "警報"
    L["ALERT_PI_RECEIVED"]       = "能量灌注已啟動!"

-- ═══════════════════════════════════════════════════════════════════════════════
-- Russian (ruRU)
-- ═══════════════════════════════════════════════════════════════════════════════

elseif locale == "ruRU" then
    L["TAB_DASHBOARD"]           = "Панель"
    L["TAB_PRIESTS"]             = "Жрецы"
    L["TAB_MESSAGES"]            = "Сообщения"
    L["TAB_STATISTICS"]          = "Статистика"
    L["TAB_ALERTS"]              = "Оповещения"
    L["ALERT_PI_RECEIVED"]       = "Вливание силы активно!"
    L["PRIEST_NO_PRIESTS"]       = "Жрецы в группе не найдены."

-- ═══════════════════════════════════════════════════════════════════════════════
-- Italian (itIT)
-- ═══════════════════════════════════════════════════════════════════════════════

elseif locale == "itIT" then
    L["TAB_DASHBOARD"]           = "Pannello"
    L["TAB_PRIESTS"]             = "Sacerdoti"
    L["TAB_MESSAGES"]            = "Messaggi"
    L["TAB_STATISTICS"]          = "Statistiche"
    L["TAB_ALERTS"]              = "Avvisi"
    L["ALERT_PI_RECEIVED"]       = "Infusione di Potere attiva!"
    L["PRIEST_NO_PRIESTS"]       = "Nessun sacerdote trovato nel gruppo."

end
