--[[

$Revision: 320 $

(C) Copyright 2009 Bethink (bethink at naef dot com)
See LICENSE.txt for license terms.

]]


----------------------------------------------------------------------
-- Initialization

local L = LibStub("AceLocale-3.0"):NewLocale("BossNotes", "deDE")


----------------------------------------------------------------------
-- Translations

if L then
-- BossNotes.lua
L["TOGGLE"] = "Boss Notes-Fenster ein-/ausblenden"
L["TOGGLE_DESC"] = "Zeigt (oder verbirgt) das Boss Notes-Fenster."
L["OPTIONS"] = "Einstellungen"
L["OPTIONS_DESC"] = "Zeigt das Einstellungsfenster."
L["MINIMAP"] = "Minimap Icon"
L["MINIMAP_DESC"] = "Schaltet das Minimap-Icon dieses Add-Ons an oder aus."
L["HEADER"] = "Header"
L["HEADER_DESC"] = "Schaltet das Schreiben des Headers in den Chat an oder aus."
L["LEARN"] = "Lernen"
L["LEARN_DESC"] = "Schaltet das Lernen über NPCs in der aktuellen Zone ein oder aus."
L["CLEAR"] = "Löschen"
L["CLEAR_DESC"] = "Löschen gelernte Verknüpfungen von NPCs zu Instanzen und Begegnungen."
L["INSTANCES"] = "Instanzen"
L["INSTANCES_DESC"] = "Wähle die Instanzen aus, die angezeigt werden."
L["BOSS_NOTES"] = "Boss Notes"
L["SLASH_COMMANDS"] = { "bossnotes", "bn" }
L["UI_SOURCE_ON_CONTEXT"] = "|cff%.2x%.2x%.2x%s|r über |cffe76f00%s|r"
L["NO_NOTE"] = "Keine Notiz."
L["START_LEARNING"] = "Beginne über NPCs in der Zone %s zu lernen."
L["STOP_LEARNING"] = "Lernen über NPCs beendet."
L["CLEAR_LEARNED"] = "Gelernte Verknüpfungen von NPCs zu Instanzen und Begegnungen gelöscht."

-- BossNotesFrame.lua
L["RAID"] = "Schlachtzug"
L["PARTY"] = "Gruppe"
L["SAY"] = "Sagen"
L["YELL"] = "Schreien"
L["GUILD"] = "Gilde"
L["OFFICER"] = "Offizier"
L["REFRESH"] = "Neu laden"
L["SEND_TO"] = "Senden..."
L["CHAT_SOURCE_ON_CONTEXT"] = "Boss Notes: %s über %s"
L["ALL_INSTANCES"] = "Alle Instanzen"
L["ALL_ENCOUNTERS"] = "Alle Begegnungen"
L["CLICK_TO_EDIT"] = "<Klicken zum Bearbeiten>"

-- Data.lua
L["LEARNING"] = "Lerne NPC %s (%d) verknüpft mit %s."
L["GENERAL"] = "Allgemein"

-- Abilities.lua
L["ABILITIES"] = "Fähigkeiten"
L["ABILITIES_DESC"] = "Enthält die Einstellung des Fähigkeitenmoduls."
L["TOOLTIP_INFO"] = "Tooltip Information"
L["TOOLTIP_INFO_DESC"] = "Schaltet die Anzeige der NPC Fähigkeiten im Tooltip ein oder aus."
L["SPELL"] = "|cff71d5ff|Hspell:%d|h[%s]|h|r"
L["CAST"] = "Cast"
L["BUFF"] = "Buff"
L["DEBUFF"] = "Debuff"
L["STACK"] = "Stack"
L["ABILITIES_NOT_RECORDED"] = "NPC-Fähigkeiten für diese Instanz oder Begegnung wurden noch nicht aufgezeichnet."

-- Emotes.lua
L["EMOTES_NOT_RECORDED"] = "NPC-Emotes für diese Instanz oder Begegnung wurden noch nicht aufgezeichnet."
L["EMOTES"]  = "Emotes"

-- PersonalNotes.lua
L["PERSONAL_NOTES"] = "Persönliche Notizen"
L["PERSONAL_NOTES_DESC"] = "Enthält die Einstellung des Moduls für persönliche Notizen."
L["ALL_CHARACTERS"] = "Alle Charaktere"
L["ALL_CHARACTERS_DESC"] = "Steuert, ob die Notizen aller Charaktere auf dem Account angezeigt werden."
L["SYNDICATION"] = "Verbreitung"
L["ENTER_NOTE_NAME_PROMPT"] = "Bitte gib den Namen der Notiz ein:"
L["REMOVE_NOTE_PROMPT"] = "Willst du die Notiz \"%s\" entfernen?"
L["PRIVATE"] = "privat"
L["ADD_NOTE"] = "Notiz hinzufügen"
L["ADD_PRIVATE_NOTE"] = "Private Notiz hinzufügen"
L["REMOVE_NOTE"] = "Notiz entfernen"
L["PUBLIC_NOTES"] = "Dies ist eine einmalige Benachrichtigung, um dich zu erinnern, dass nicht-private Notizen standardmässig mit deiner Gilde, deiner Gruppe und deinem Raid geteilt werden."

-- Rules.lua
L["RULES"] = "Regeln"
L["RULES_DESC"] = "Enthält die Einstellungen des Moduls für Regeln."
L["GLOBAL_RULES"] = "Globale Regeln"
L["GLOBAL_RULES_DESC"] = "Legt fest, ob Boss Notes Regeln pro Charakter oder global pro Account verwaltet."
L["FIRE"] = "Feuer"
L["FIRE_DESC"] = "Feuert eine Regel gemäss Name zum Testen. Du musst im Kampf sein."
L["REMOVE_RULE_PROMPT"] = "Willst Du die Regel \"%s\" entfernen?"
L["ACCEPT_RULE_PROMPT"] = "Willst Du die Regel \"%s\" gesendet von %s? annehmen? Die Regel ersetzt eine bestehende Regel mit demselben Namen."
L["ACCEPT_RULES_PROMPT"] = "Willst Du %d Regel(n) gesendet von %s annehmen? Die Regeln ersetzen bestehende Regeln mit demselben Namen."
L["DISPLAYS"] = "Anzeigen und Bridges"
L["RULE_ACTION_RAID_TARGET"] = "Setzte Raid-Ziel %s."
L["RULE_ACTION_RAID_TARGETS"] = "Setzte Raid-Ziele von %s bis %s."
L["RULE_ACTION_NOTIFICATION"] = "Zeige Benachrichtigung |cfffedc00%s|r."
L["RULE_ACTION_TIMER"] = "Zeige Timer |cfffedc00%s|r für %g Sekunden."
L["RULE_ACTION_YELL"] = "Schreie |cfffedc00%s|r."
L["RULE_NO_ACTIONS"] = "Diese Regel hat keine Aktionen."
L["RULE_DISABLED"] = "Diese Regel ist |cffff0000inaktiv|r."
L["EDIT_RULE"] = "Regel bearbeiten"
L["REMOVE_RULE"] = "Regel entfernen"
L["BROADCAST_RULE"] = "Regel senden"
L["NO_RULES"] = "Für diese Instanz oder Begegnung wurden keine Regeln definiert."
L["ADD_RULE"] = "Regel hinzufügen"
L["BROADCAST_RULES"] = "Regeln senden"
L["SENDING_RULE"] = "Sende Regel \"%s\"."
L["INVALID_RULE"] = "Regel \"%s\" ist ungültig und wurde nicht gesendet."
L["SENDING_RULES"] = "Sende %d Regeln(n)."
L["NEW_RULE"] = "Neue Regel"
L["INVALID_RULES"] = "%d Regel(n) sind ungültig und wurden nicht gesendet."
L["VALIDATION_FAILED"] = "Überprüfung fehlgeschlagen: %s"
L["NOT_IN_RAID_OR_PARTY"] = "Du bist nicht in einer Gruppe oder in einem Raid."

-- RuleEditor.lua
L["RULE_EDITOR"] = "Regeleditor"
L["RULE_NAME"] = "Regelname"
L["EMPTY_RULE_NAME"] = "Regelname darf nicht leer sein."
L["DUPLICATE_RULE_NAME"] = "Regelname muss einzigartig sein."
L["ENABLED"] = "Aktiv"
L["TAB_EVENT"] = "Ereignis"
L["TAB_CONDITION"] = "Bedingung"
L["TAB_ACTION"] = "Aktion"
L["TAB_CANCEL"] = "Abbruch"
L["TAB_SPELL"] = "Zauber"
L["EVENT_HEADING"] = "Spezifiziere die Ereignisse, welche diese Regel individuell auslösen."
L["ADD_EVENT"] = "Ereignis hinzufügen..."
L["TYPE_CAST"] = "Wirken"
L["TYPE_AURA"] = "Buff/Debuff"
L["TYPE_EMOTE"] = "Emote"
L["TYPE_UNIT"] = "Unit"
L["CONDITION_HEADING"] = "Spezifiziere die Bedingungen, die kollektiv erfüllt sein müssen, damit diese Regel feuert."
L["ADD_CONDITION"] = "Bedingung hinzufügen..."
L["TYPE_PROPERTY"] = "Eigenschaft"
L["TYPE_NPC"] = "NPC"
L["TYPE_RANGE"] = "Reichweite"
L["ACTION_HEADING"] = "Spezifiziere die die Aktionen, die kollektiv ausgeführt werden, wenn diese Regel feuert."
L["ADD_ACTION"] = "Aktion hinzufügen..."
L["TYPE_RAID_TARGET"] = "Raid-Ziel"
L["TYPE_NOTIFICATION"] = "Benachrichtigung"
L["TYPE_TIMER"] = "Timer"
L["TYPE_YELL"] = "Schreien"
L["CANCEL_HEADING"] = "Bezeichne die Ereignisse, welche individuell die ausgeführten Aktionen dieser Regel abbrechen."
L["ADD_CANCEL"] = "Abbruch hinzufügen..."
L["SPELL_HEADING"] = "Spezifizier die speziellen Zauber, die in dieser Regel verwendet werden."
L["ADD_SPELL"] = "Zauber hinzufügen..."
L["SUFFIX"] = "Suffix"
L["LABEL_REMOVE"] = "(Entfernen)"
L["ENTER_COMBAT"] = "Kampf betreten"
L["CHANGE_TARGET"] = "Ziel wechseln"
L["DEATH"] = "Tod"
L["OPERATOR"] = "Operator"
L["OPERATOR_IS"] = "ist"
L["OPERATOR_ISNOT"] = "ist nicht"
L["PROP_PLAYER"] = "ein Spieler"
L["PROP_PLAYER_CONTROLLED"] = "spielergesteuert"
L["PROP_PARTY"] = "in der Gruppe"
L["PROP_RAID"] = "im Raid"
L["PROP_MAIN_TANK"] = "Main Tank"
L["PROP_MAIN_ASSIST"] = "Main Assist"
L["OPERATOR_HAS"] = "hat"
L["OPERATOR_HASNOT"] = "hat nicht"
L["COUNT"] = "Anzahl"
L["INVALID_COUNT"] = "Der Wert für die Anzahl ist ungültig."
L["DOSE"] = "Stacks"
L["INVALID_DOSE"] = "Der Wert für die Stacks ist ungültig."
L["OPERATOR_INRANGE"] = "in Reichweite"
L["OPERATOR_NOTINRANGE"] = "nicht in Reichweite"
L["RANGE_10"] = "10 m"
L["RANGE_11"] = "11 m"
L["RANGE_18"] = "18 m"
L["RANGE_28"] = "28 m"
L["PLAYER"] = "Spieler"
L["UNIT"] = "Unit"
L["FOCUS"] = "Fokus"
L["PET"] = "Pet"
L["EVENT_SOURCE"] = "Ereignisquelle"
L["EVENT_DEST"] = "Ereignisziel"
L["NONE"] = "keines"
L["TARGET"] = "Ziel"
L["TARGET_TARGET"] = "Ziel des Ziels"
L["FIRST_RAID_TARGET"] = "Erstes Raid-Ziel"
L["LAST_RAID_TARGET"] = "Letztes Raid-Ziel"
L["SET_ON"] = "Setzen auf"
L["DURATION"] = "Dauer"
L["INVALID_DURATION"] = "Die Dauer ist ungültig."
L["EMPTY_DURATION"] = "Die Dauer darf nicht leer sein."
L["COLLAPSE"] = "Zus.fallen"
L["INVALID_COLLAPSE"] = "Das Zusammenfallintervall ist ungültiug."
L["DISTRIBUTED"] = "Verteilt"
L["TEXT"] = "Text"
L["IMPORTANT"] = "Wichtig"
L["RAID_WARNING"] = "Raid-Warnung"
L["REPEAT"] = "Wiederholen"
L["INVALID_REPEAT"] = "Das Wiederholintervall ist ungültig."
L["PREWARN"] = "Vorwarnen"
L["INVALID_PREWARN"] = "Das Vorwarnintervall ist ungültig."
L["SPELL_ID"] = "Zauber ID"
L["INVALID_SPELL_ID"] = "Die Zauber ID ist ungültig."

-- Engine.lua
L["FIRING_RULE"] = "Feuere Regel \"%s\"."
L["SKIPPING_RULE"] = "Regel \"%s\" wird ausgelassen, da sie ungültig ist."
L["SOON"] = "%s bald"

-- SimpleDisplay.lua
L["SIMPLE_DISPLAY"] = "Einfache Anzeige"
L["SIMPLE_DISPLAY_DESC"] = "Eine einfache Anzeige für Regelaktionen. Wenn aktiviert, so werden Aktionen als Raid-Warnung angezeigt."

-- DbmDisplay.lua
L["DBM_DISPLAY"] = "DBM Bridge"
L["DBM_DISPLAY_DESC"] = "Eine Bridge für Deadly Boss Mods (DBM). Wenn aktiviert, so werden Aktionen in DBM angezeigt."

-- BigWigsDisplay.lua
L["BIGWIGS_DISPLAY"] = "BigWigs Bridge"
L["BIGWIGS_DISPLAY_DESC"] = "Eine Bridge für BigWigs. Wenn aktiviert, so werden Aktionen in BigWigs angezeigt."

-- DxeDisplay.lua
L["DXE_DISPLAY"] = "DXE Bridge"
L["DXE_DISPLAY_DESC"] = "Eine Bridge für Deus Vox Encounters (DXE). Wenn aktiviet, so werden Aktionen in DXE angezeigt."

-- Tactics.lia
L["TACTICS"] = "Taktiken"
L["COPY"] = "Kopieren"
end