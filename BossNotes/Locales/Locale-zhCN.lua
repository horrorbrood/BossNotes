--[[

$Revision: 119 $

(C) Copyright 2009 Bethink (bethink at naef dot com)
See LICENSE.txt for license terms.

]]


----------------------------------------------------------------------
-- Initialization

local L = LibStub("AceLocale-3.0"):NewLocale("BossNotes", "zhCN")


----------------------------------------------------------------------
-- Translations

if L then
-- BossNotes.lua
L["OPTIONS"] = "Options"
L["OPTIONS_DESC"] = "显示选项面板."
L["INSTANCES"] = "Instances"
L["INSTANCES_DESC"] = "选择一个副本."
L["BOSS_NOTES"] = "Boss Notes"
L["SLASH_COMMANDS"] = { "bossnotes", "bn" }
L["UI_SOURCE_ON_CONTEXT"] = "|cff%.2x%.2x%.2x%s|r 在 |cffe76f00%s|r"
L["NO_NOTE"] = "没有备注."

-- BossNotesFrame.lua
L["RAID"] = "团队"
L["PARTY"] = "小队"
L["SAY"] = "说"
L["YELL"] = "大喊"
L["WHISPER"] = "密语目标"
L["GUILD"] = "公会"
L["OFFICER"] = "官员"
L["REFRESH"] = "重刷新"
L["SEND_TO"] = "发送到..."
L["CHAT_SOURCE_ON_CONTEXT"] = "Boss Notes: %s 在 %s"
L["ALL_INSTANCES"] = "所有副本"
L["ALL_ENCOUNTERS"] = "所有首领"
L["CLICK_TO_EDIT"] = "<点击来编辑>"

-- Data.lua
L["GENERAL"] = "一般"

-- Encounter.lua
L["WotlkRaid"] = "WOTLK团队副本"
L["instance:VaultOfArchavon"] = "阿尔卡冯的宝库"
L["encounter:31125"] = "岩石看守者阿尔卡冯"
L["instance:Naxxramas"] = "纳克萨玛斯"
L["encounter:15956"] = "阿努布雷坎"
L["encounter:15953"] = "黑女巫法琳娜"
L["encounter:15952"] = "迈克斯纳"
L["encounter:15954"] = "瘟疫使者诺斯"
L["encounter:15936"] = "肮脏的希尔盖"
L["encounter:16011"] = "洛欧塞布"
L["encounter:16061"] = "教官拉苏维奥斯"
L["encounter:16060"] = "收割者戈提克"
L["encounter:16063"] = "天启四骑士"
L["encounter:16028"] = "帕奇维克"
L["encounter:15931"] = "格罗布鲁斯"
L["encounter:15932"] = "格拉斯"
L["encounter:15928"] = "塔迪乌斯"
L["encounter:15989"] = "萨菲隆"
L["encounter:15990"] = "克尔苏加德"
L["instance:TheObsidianSanctum"] = "黑曜石圣殿"
L["encounter:28860"] = "萨塔里奥"
L["instance:TheEyeOfEternity"] = "永恒之眼"
L["encounter:28859"] = "玛里苟斯"
L["WotlkDungeon"] = "WOTLK地下城"
L["instance:UtgardeKeep"] = "乌特加德城堡"
L["encounter:23953"] = "凯雷塞斯王子"
L["encounter:24200"] = "斯卡瓦尔德 & 达尔隆"
L["encounter:23954"] = "劫掠者因格瓦尔"
L["instance:TheNexus"] = "魔枢"
L["encounter:26731"] = "大魔导师泰蕾丝塔"
L["encounter:26763"] = "阿诺玛鲁斯"
L["encounter:26794"] = "塑树者奥莫洛克"
L["encounter:27723"] = "克莉斯塔萨"
L["encounter:26795"] = "指挥官斯托比德"
L["encounter:26798"] = "指挥官库鲁尔格"
L["instance:AzjolNerub"] = "艾卓-尼鲁布"
L["encounter:28684"] = "看门者克里克希尔"
L["encounter:28921"] = "哈多诺克斯"
L["encounter:29120"] = "阿努巴拉克"
L["instance:AhnKahetTheOldKingdom"] = "安卡赫特：古代王国"
L["encounter:29309"] = "纳多克斯长老"
L["encounter:29308"] = "塔达拉姆王子"
L["encounter:29310"] = "耶戈达·觅影者"
L["encounter:29311"] = "传令官沃拉兹"
L["encounter:30258"] = "埃曼尼塔"
L["instance:DrakTharonKeep"] = "达克萨隆要塞"
L["encounter:26630"] = "托尔戈"
L["encounter:26631"] = "召唤者诺沃斯"
L["encounter:27483"] = "暴龙之王爵德"
L["encounter:26632"] = "先知萨隆亚"
L["instance:TheVioletHold"] = "紫罗兰监狱"
L["encounter:29315"] = "埃雷克姆"
L["encounter:29316"] = "摩拉格"
L["encounter:29313"] = "艾库隆"
L["encounter:29266"] = "谢沃兹"
L["encounter:29312"] = "拉文索尔"
L["encounter:29314"] = "湮灭者祖拉玛特"
L["encounter:31134"] = "塞安妮苟萨"
L["instance:Gundrak"] = "古达克"
L["encounter:29304"] = "斯拉德兰"
L["encounter:29307"] = "达卡莱巨像"
L["encounter:29305"] = "莫拉比"
L["encounter:29306"] = "迦尔达拉"
L["encounter:29932"] = "凶残的伊克"
L["instance:HallsOfStone"] = "岩石大厅"
L["encounter:27975"] = "悲伤圣女"
L["encounter:27977"] = "克莱斯塔卢斯"
L["encounter:27983"] = "远古法庭宝箱"
L["encounter:27978"] = "塑铁者斯约尼尔"
L["instance:TheCullingOfStratholme"] = "净化斯坦索姆"
L["encounter:26529"] = "肉钩"
L["encounter:26530"] = "塑血者沙尔拉姆"
L["encounter:26532"] = "时光领主埃博克"
L["encounter:26533"] = "玛尔加尼斯"
L["encounter:32273"] = "永恒腐蚀者"
L["instance:TheOculus"] = "魔环"
L["encounter:27654"] = "审讯者达库斯"
L["encounter:27447"] = "瓦尔洛斯·云击"
L["encounter:27655"] = "法师领主伊洛姆"
L["encounter:27656"] = "魔网守护者埃雷苟斯"
L["instance:HallsOfLightning"] = "闪电大厅"
L["encounter:28586"] = "比亚格里将军"
L["encounter:28587"] = "沃尔坎"
L["encounter:28546"] = "艾欧纳尔"
L["encounter:28923"] = "洛肯"
L["instance:UtgardePinnacle"] = "乌特加德之巅"
L["encounter:26668"] = "席瓦拉·索格蕾"
L["encounter:26687"] = "戈托克·苍蹄"
L["encounter:26693"] = "残忍的斯卡迪"
L["encounter:26861"] = "伊米隆国王"
L["TbcRaid"] = "TBC团队副本"
L["TbcDungeon"] = "TBC地下城"
L["ClassicRaid"] = "经典团队副本"
L["ClassicDungeon"] = "经典地下城"

-- Abilities.lua
L["ABILITIES"] = "技能"
L["SPELL"] = "|cff71d5ff|H法术:%d|h[%s]|h|r"
L["HEROIC"] = "英雄"
L["ABILITIES_NOT_RECORDED"] = "这个首领的法术技能还未被纪录."

-- PersonalNotes.lua
L["SYNDICATION"] = "Syndication"
L["SYNDICATION_DESC"] = "选择一个发布BOSS备注的频道."

-- Tactics.lua
L["TACTICS"] = "战术"
end
