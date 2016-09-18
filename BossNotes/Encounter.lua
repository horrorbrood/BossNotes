--[[

$Revision: 386 $

(C) Copyright 2009,2010 Bethink (bethink at naef dot com)
See LICENSE.txt for license terms.

]]


----------------------------------------------------------------------
-- Initialization

local L = LibStub("AceLocale-3.0"):GetLocale("BossNotes")


----------------------------------------------------------------------
-- Encounters

BOSS_NOTES_ENCOUNTERS = {
	{
		-- Legion Dungeons - Added by Horrorbrood
		instanceSetId = "LegionDungeon",
		raid = false,
		instances = {
			{
				--Eye of Azshara
				instanceId = "LEOA",
				npcIds = {91784, 97269, 97264, 91789, 91808,91797, 96028},
				encounters = {
					{
						-- "Warlord Parjesh"
						encounterId = 91784,
						npcIds = {91784, 97269, 97264}
					},
					
					{
						-- "Lady Hatecoil"
						encounterId = 91789
					},
					{
						-- "Serpentrix"
						encounterId = 91808
					},
					
					{
						-- "King Deepbeard"
						encounterId = 91797
					},
					{
						-- "Wrath Of Azshara"
						encounterId = 96028
					},
				},
			},	
			{
				--Halls of Valor 
				instanceId = "LHOV",
				npcIds = {94960, 96646, 99868, 97226, 98196},
				encounters = {
					{
						-- "Hymdall"
						encounterId = 94960
					},
					{
						-- "Hyrja"
						encounterId = 96646
					},
					{
						-- "Fenryr"
						encounterId = 99868
					},
					{
						-- "God-King Skovald"
						encounterId = 97226
					},
					{
						-- "Odyn"
						encounterId = 98196
					},
				},
			},
			{
				--Neltharions Lair
				instanceId = "LNL",
				npcIds = {91003, 97827, 91005, 99460},
				encounters = {
					{
						-- "Rokmora"
						encounterId = 91003
					},
					{
						-- "Ularogg Cragshaper"
						encounterId = 97827
					},
					{
						-- "Naraxas"
						encounterId = 91005
					},
					{
						-- "Dargul the Underking"
						encounterId = 99460
					},
				},
			},
			{
				--Darkheart Thicket
				instanceId = "LDT",
				npcIds = {96512, 103344, 99200, 101403},
				encounters = {
					{
						-- "Archdruid Glaidalis"
						encounterId = 96512
					},
					{
						-- "Oakheart"
						encounterId = 103344
					},
					{
						-- "Dresaron"
						encounterId = 99200
					},
					
					{
						-- "Shade of Xavius"
						encounterId = 101403
					},
				},
			},
			{
				--Violet Hold
				instanceId = "LVH",
				npcIds = {102618, 102616, 102615, 102619, 102617, 102387, 102614, 106373},
				encounters = {
					{
						-- "MindFlayer Kaahrj"
						encounterId = 102618
					},
					{
						-- "Millificent Manastorm"
						encounterId = 102616
					},
					{
						-- "Festerface"
						encounterId = 102615
					},
					{
						-- "Shivermaw"
						encounterId = 102619
					},
					{
						-- "Anub'esset"
						encounterId = 102617
					},
					{
						-- "Sael'orn"
						encounterId = 102387
					},
					{
						-- "Blood-Princess Thal'ena"
						encounterId = 102614
					},
					{
						-- "Fel Lord Betrug"
						encounterId = 106373
					},
				},
			},
			{
				--Black Rook Hold
				instanceId = "LBRH",
				npcIds = {98542, 98696, 98949, 94923},
				encounters = {
					{
						-- "The Amalgam Of Souls"
						encounterId = 98542
					},
					{
						-- "Illysanna Ravencrest"
						encounterId = 98696
					},
					{
						-- "Smashspite the Hateful"
						encounterId = 98949
					},
					{
						-- "Lord Kur'talos Ravencrest"
						encounterId = 94923
					},
				},
			},
			{
				--Maw Of Souls
				instanceId = "LMOS",
				npcIds = {96756, 96754, 96759},
				encounters = {
					{
						-- "Ymiron, the Fallen King"
						encounterId = 96756
					},
					{
						-- "Harbaron"
						encounterId = 96754
					},
					{
						-- "Helya"
						encounterId = 96759
					},

				},
			},
			{
				--Vault of the Wardens
				instanceId = "LVOTW",
				npcIds = {99198, 95886, 99865, 95888, 96015},
				encounters = {
					{
						-- "Tirathon Saltheril"
						encounterId = 99198
					},
					{
						-- "Ash'golm"
						encounterId = 95886
					},
					{
						-- "Glazer"
						encounterId = 99865
					},
					{
						-- "Cordana Felsong"
						encounterId = 95888
					},
					{
						-- "Inqisitor Tormentorum"
						encounterId = 96015
					},
				},
			},
			{
				--The Arcway
				instanceId = "LTA",
				npcIds = {98203, 98205, 98206, 98207, 98208},
				encounters = {
					{
						-- "Ivanyr"
						encounterId = 98203
					},
					{
						-- "Corstilax"
						encounterId = 98205
					},
					{
						-- "General Xakal"
						encounterId = 98206
					},
					{
						-- "Nal'tira"
						encounterId = 98207
					},
					{
						-- "Advisor Vandros"
						encounterId = 98208
					},
				},
			},
			{
				--Court Of Stars
				instanceId = "LCOF",
				npcIds = {104215, 104217, 106576},
				encounters = {
					{
						-- "Patrol Captain Gerdo"
						encounterId = 104215
					},
					{
						-- "Talixae Flamewreath"
						encounterId = 104217
					},
					{
						-- "Advisor Melandrus"
						encounterId = 106576
					},

				},
			},
		},
	},
	{
		-- Draenor Dungeons - Added by Linty Druid
		instanceSetId = "DraenorDungeon",
		raid = false,
		instances = {
			{
				--Auchindoun
				instanceId = "wodAuchindoun",
				npcIds = { },
				encounters = {
					{
						-- 
						encounterId = 75839
					},
					
					{
						-- 
						encounterId = 76177
					},
					{
						-- 
						encounterId = 75927
					},
					
					{
						-- 
						encounterId = 77734
					},
				},
			},
			{
				--slagmines
				instanceId = "slagmines",
				npcIds = { },
				encounters = {
					{
						-- 
						encounterId = 74787
					},
					
					{
						-- 
						encounterId = 74366,
						npcIds = {
							74366, 74475,
							}
					},
					{
						-- 
						encounterId = 75768
					},
					
					{
						-- 
						encounterId = 74790
					},
				},
			},
			{
				--Everbloom
				instanceId = "TheEverbloom",
				npcIds = { },
				encounters = {
					{
						-- 
						encounterId = 83894,
						npcIds = {
							83894, 83892,83893,
							}
					},
					
					{
						-- 
						encounterId = 82682
					},
					{
						-- 
						encounterId = 84550
					},
					
					{
						-- 
						encounterId = 81522
					},
					{
						-- 
						encounterId = 83864
					},
				},
			},
			{
				--GrimrailDepot
				instanceId = "GrimrailDepot",
				npcIds = { },
				encounters = {
					{
						-- 
						encounterId = 80005
					},
					
					{
						-- 
						encounterId = 77803,
						npcIds = {
							77803, 77816,
							}
						
					},
					{
						-- 
						encounterId = 79545
					},
					
			
				},
			},
			{
				--IronDocks
				instanceId = "IronDocks",
				npcIds = { },
				encounters = {
					{
						-- 
						encounterId = 81305
					},
					
					{
						-- 
						encounterId = 80816
					},
					{
						-- 
						encounterId = 79852
					},
					
					{
						-- 
						encounterId = 83612,
						npcIds = {
							83612, 83613,83616,
							}
						
					},
				},
			},
			{
				--ShadowmoonBurial
				instanceId = "ShadowmoonBurial",
				npcIds = { },
				encounters = {
					{
						-- 
						encounterId = 75509
					},
					
					{
						-- 
						encounterId = 75452
					},
					{
						-- 
						encounterId = 76407
					},
					
					{
						-- 
						encounterId = 75829
					},
				},
			},
			{
				--Skyreach
				instanceId = "Skyreach",
				npcIds = { },
				encounters = {
					{
						-- 
						encounterId = 75954
					},
					
					{
						-- 
						encounterId = 76141
					},
					{
						-- 
						encounterId = 76379
					},
					
					{
						-- 
						encounterId = 76266
					},
				},
			},
			{
				--wodubs
				instanceId = "wodubs",
				npcIds = { },
				encounters = {
					{
						-- 
						encounterId = 76413
					},
					
					{
						-- 
						encounterId = 76021
					},
					{
						-- 
						encounterId = 79912
					},
					
					{
						-- 
						encounterId = 76585
					},
					{
						-- 
						encounterId = 77120
					},
					
					
				},
			},
		},
	},
	{
		-- Draenor Raids - Added by Linty Druid
		instanceSetId = "DraenorRaid",
		raid = true,
		instances = {
			{
				--HighMaul
				instanceId = "HighMaul",
				npcIds = { },
				encounters = {
					{
						-- Kargath Bladefist
						encounterId = 78714
					},
					
					{
						-- Butcher
						encounterId = 77404
					},
					
					{
						-- Brackenspore
						encounterId = 78491
					},
					
					{
						-- Tectus
						encounterId = 78948,
						npcIds = {
							78948, 86071, 86072,86073
							}
					},
					{
						-- Twin Ogron
						encounterId = 78238,
						npcIds = {
							78238, 78237
							}
					},
					{
						-- Ko'ragh
						encounterId = 79015
					},
					{
						--Imperator Mar'gok
						encounterId = 77428
					},

				},
			},
			{
				--Black Rock Foundry
				instanceId = "BlackRockF",
				npcIds = { },
				encounters = {
					{
						-- Blackhand
						encounterId = 77325
					},
					
					{
						-- Beastlord Darmac
						encounterId = 76865
					},
					
					{
						-- Flamebender Ka'graz
						encounterId = 76814
					},
					
					{
						-- Operator Thogar
						encounterId = 76906
					},
					
					{
						-- Blast Furnace
						encounterId = 76809,
						npcIds = {
							76806,76809,
							}
					},
					{
						-- Hans'gar & Franzok
						encounterId = 76974,
						npcIds = {
							76974, 76973
							}
					},
					{
						-- Gruul
						encounterId = 76877
					},
					{
						--Kromog
						encounterId = 77692
					},
					
					{
						--Oregorger
						encounterId = 77182
					},
					
					{
						-- Iron Maidens
						encounterId = 77557,
						npcIds = {
							77557, 77231, 77477
							}
					},

				},
			},
			{
				--Outdoor
				instanceId = "WODWorld",
				npcIds = { },
				encounters = {
					{
						-- Tarlna the Ageless
						encounterId = 81535
					},
					
					{
						-- Drov the Ruiner
						encounterId = 81252
					},
					
					{
						-- Rukhmar
						encounterId = 87493
					},
					
				},
			},
		},
	},
	{
		-- Mists Raid
		instanceSetId = "MoPRaid",
		raid = true,
		instances = {
			{
				-- Seige of Orgrimmar
				instanceId = "SeigeOfOrgrimmar",
				npcIds = { },
				encounters = {
					{
						-- Immerseus
						encounterId = 71543
					},
					{
						-- The Fallen Protectors
						encounterId = 71475,
						npcIds = {
							71475, 71479, 71480
						}
					},
					{
						-- Norushen
						encounterId = 71965
					},
					{
						-- Sha of Pride
						encounterId = 71734
					},
					{
						-- Galakras
						encounterId = 72957
					},
					{
						-- Iron Juggernaut
						encounterId = 71466
					},
					{
						-- Kor'kron Dark Shaman
						encounterId = 71859,
						npcIds = {
							71859, 71858
						}
					},
					{
						-- General Nazgrim
						encounterId = 73939
					},
					{
						-- Malkorok
						encounterId = 71454
					},
					{
						-- Spoils of Pandaria
						encounterId = 71889
					},
					{
						-- Thok the Bloodthirsty
						encounterId = 71529
					},
					{
						-- Seigecrafter Blackfuse
						encounterId = 72964
					},
					{
						-- Paragons of the Klaxxi
						encounterId = 71152,
						npcIds = {
							71152, 71161, 71157, 71156, 71155, 71160, 71154, 71158, 71153
						}
					},
					{
						-- Garrosh Hellscream
						encounterId = 71865
					}
				}
			},
			{
				-- Throne of Thunder
				instanceId = "ThroneOfThunder",
				npcIds = { },
				encounters = {
					{
						-- Jin'rokh the Breaker
						encounterId = 69465
					},
					{
						-- Horridon
						encounterId = 68476
					},
					{
						-- Council of Elders
						encounterId = 69134
					},
					{
						-- Tortos
						encounterId = 67977
					},
					{
						-- Megaera
						encounterId = 70229
					},
					{
						-- Ji-Kun
						encounterId = 69712
					},
					{
						-- Durumu the Forgotten
						encounterId = 68036
					},
					{
						-- Primordius
						encounterId = 69017
					},
					{
						-- Dark Animus
						encounterId = 69427
					},
					{
						-- Iron Qon
						encounterId = 68078
					},
					{
						-- Twin Consorts
						encounterId = 68905
					},
					{
						-- Lei Shen
						encounterId = 68397
					},
					{
						-- Ra-den
						encounterId = 69473
					}
				}
			},
			{
				-- Heart of Fear
				instanceId = "HeartOfFear",
				npcIds = { },
				encounters = {
					{
						-- Imperial Vizier Zor'lok
						encounterId = 62980
					},
					{
						-- Blade Lord Ta'yak
						encounterId = 62543
					},
					{
						-- Garalon
						encounterId = 62164
					},
					{
						-- Wind Lord Mel'jarak
						encounterId = 62397
					},
					{
						-- Amber-Shaper Un'sok
						encounterId = 62511
					},
					{
						-- Grand Empress Shek'zeer
						encounterId = 62837
					}
				}
			},
			{
				-- Terrace of Endless Spring
				instanceId = "TerraceOfEndlessSpring",
				npcIds = { },
				encounters = {
					{
						-- Protectors of the Endless
						encounterId = 60583,
						npcIds = {
							60586, 60583
						}

					},
					{
						-- Tsulong
						encounterId = 62442
					},
					{
						-- Lei Shi
						encounterId = 62983
					},
					{
						-- Sha of Fear
						encounterId = 60999
					}
				}
			},
			{
				-- Mogu'shan Vaults
				instanceId = "MogushanVaults",
				npcIds = { },
				encounters = {
					{
						-- The Stone Guard
						encounterId = 60047,
						npcIds = {
							60043, 60047, 60051, 59915
						}
					},
					{
						-- Feng the Accursed
						encounterId = 60009
					},
					{
						-- Gara'jal the Spiritbinder
						encounterId = 60143
					},
					{
						-- The Spirit Kings
						encounterId = 61421,
						npcIds = {
							61423, 61427, 61429
						}

					},
					{
						-- Elegon
						encounterId = 60410
					},
					{
						-- Will of the Emperor
						encounterId = 60399,
						npcIds = {
							60399, 60400
						}
					}
				}
			},
			{
				-- Outdoor
				instanceId = "Outdoor",
				npcIds = { },
				encounters = {
					{
						-- Sha of Anger
						encounterId = 60491
					},
					{
						-- Galleon
						encounterId = 62346
					},
					{
						-- Nalak
						encounterId = 69099
					},
					{
						-- Oondasta
						encounterId = 69161
					},
					{	
						-- Chi-Ji
						encounterId = 71952
					},
					{	
						-- Xuen
						encounterId = 71953
					},
					{	
						-- Niuzao
						encounterId = 71954
					},
					{	
						-- Yu'lon
						encounterId = 71955
						
					},
					{	
						-- Ordos
						encounterId = 72057
						
					}
				}
			}
		}
	},
	{
		-- MoP Dungeon
		instanceSetId = "MoPDungeon",
		raid = false, 
		instances = {
			{
				-- Scarlet Halls
				instanceId = "ScarletHalls",
				npcIds = { },
				encounters = {
					{
						-- Houndmaster Braun
						encounterId = 59303
					},
					{
						-- Armsmaster Harlan
						encounterId = 58632
					},
					{
						-- Flameweaver Koegler
						encounterId = 59150
					}
				}
			},
			{
				-- Scarlet Monastery
				instanceId = "ScarletMonastery",
				npcIds = { },
				encounters = {
					{
						-- Thalnos the Soulrender
						encounterId = 59789
					},
					{
						-- Brother Korloff
						encounterId = 59223
					},
					{
						-- Commander Durand and High Inquisitor Whitemane
						encounterId = 60040
					}
				}
			},
			{
				-- Scholomance
				instanceId = "Scholomance",
				npcIds = { },
				encounters = {
					{
						-- Instructor Chillheart
						encounterId = 58633
					},
					{
						-- Jandice Barov
						encounterId = 59184
					},
					{
						-- Rattlegore
						encounterId = 59153
					},
					{
						-- Lilian Voss
						encounterId = 59200
					},
					{
						-- Darkmaster Gandling
						encounterId = 59080
					}
				}
			},			{
				-- Gate of the Setting Sun
				instanceId = "GateOfTheSettingSun",
				npcIds = { },
				encounters = {
					{
						-- Saboteur Kip'tilak
						encounterId = 56906
					},
					{
						-- Striker Ga'dok
						encounterId = 56589
					},
					{
						-- Commander Ri'Mok
						encounterId = 56636
					},
					{
						-- Raigonn
						encounterId = 61177
					}
				}
			},
			{
				-- Mogu'shan Palace
				instanceId = "MogushanPalace",
				npcIds = { },
				encounters = {
					{
						-- Trial of the King
						encounterId = 61442
					},
					{
						-- Gekkan
						encounterId = 61243
					},
					{
						-- Xin the Weaponmaster
						encounterId = 61884
					}
				}
			},
			{
				-- Shado-Pan Monastery
				instanceId = "ShadoPanMonastery",
				npcIds = { },
				encounters = {
					{
						-- Gu Cloudstrike
						encounterId = 56747
					},
					{
						-- Master Snowdrift
						encounterId = 64387
					},
					{
						-- Sha of Violence
						encounterId = 56719
					},
					{
						-- Taran Zhu
						encounterId = 56884
					}
				}
			},
			{
				-- Siege Of Niuzao Temple
				instanceId = "SiegeOfNiuzaoTemple",
				npcIds = { },
				encounters = {
					{
						-- Vizier Jin'bak
						encounterId = 61567
					},
					{
						-- Commander Vo'jak
						encounterId = 61634
					},
					{
						-- General Pa'valak
						encounterId = 61485
					},
					{
						-- Wing Leader Ner'onok
						encounterId = 62205
					}
				}
			},
			{
				-- Stormstout Brewery
				instanceId = "StormstoutBrewery",
				npcIds = { },
				encounters = {
					{
						-- Ook-Ook
						encounterId = 57963
					},
					{
						-- Hoptallus
						encounterId = 56717
					},
					{
						-- Yan-Zhu the Uncasked
						encounterId = 59479
					}
				}
			},
			{
				-- Temple of the Jade Serpent
				instanceId = "TempleOfTheJadeSerpent",
				npcIds = { },
				encounters = {
					{
						-- Wise Mari
						encounterId = 56787
					},
					{
						-- Lorewalker Stonestep
						encounterId = 56843
					},
					{
						-- Liu Flameheart
						encounterId = 56732
					},
					{
						-- Sha of Doubt
						encounterId = 56439
					}
				}
			}
		}
	},

	{
		-- Cataclysm Raid
		instanceSetId = "CataRaid",
		raid = true,
		instances = {
			{
				-- Dragon Soul
				instanceId = "DragonSoul",
				nopcIds = { },
				encounters = {
					{
						-- Morchok 
						encounterId = 55265
					},
					{
						-- Warlord Zon'ozz 
						encounterId = 55308
					},
					{
						-- Yor'sahj the Unsleeping 
						encounterId = 55312
					},
					{
						-- Hagara the Stormbinder 
						encounterId = 55689
					},
					{
						-- Ultraxion 
						encounterId = 55294
					},
					{
						-- Warmaster Blackhorn 
						encounterId = 56427
					},
					{
						-- Spine of Deathwing 
						encounterId = 53879
					},
					{
						-- Madness of Deathwing 
						encounterId = 56173
					}
				}
			},
			{
				-- Firelands
				instanceId = "Firelands",
				npcIds = { },
				encounters = {
					{
						-- Beth'thilac
						encounterId = 52498
					},
					{
						-- Lord Rhyolith
						encounterId = 52558,
						npcIds = { 52558, 52620 }
					},
					{
						-- Alysrazor
						encounterId = 52530
					},
					{
						-- Shannox
						encounterId = 53691
					},
					{
						-- Baleroc
						encounterId = 53494
					},
					{
						-- Majordomo Fandral Staghelm
						encounterId = 52571
					},
					{
						-- Ragnaros
						encounterId = 52409
					}
				}
			},
			{
				-- Baradin Hold
				instanceId = "BaradinHold",
				npcIds = { 47901 },
				encounters = {
					{
						-- Argaloth
						encounterId = 47120,
						npcIds = { 47120, 47829 }
					},
					{
						-- Occu'thar
						encounterId = 52363
					},
					{
						-- Alizabal
						encounterId = 55869
					}

				}
			},
			{
				-- Blackwing Descent
				instanceId = "BlackwingDescent",
				npcIds = {
					43128, 43126, 43119, 42767, 43122, 42768, 42649,
					42800, 43130, 43129, 43127, 43125, 42803, 46083,
					42802
				},
				encounters = {
					{
						-- Magmaw
						encounterId = 41570,
						npcIds = {
							41570, 42321, 47330, 48270, 41806, 41843, 42347
						}
					},
					{
						-- Omnotron Defense System
						encounterId = 42180,
						npcIds = { 42180, 42179, 42166, 42897, 42178, 42733 }
					},
					{
						-- Atramedes
						encounterId = 41442,
						npcIds = {
							41879, 41962, 42960, 42954, 41546, 41442, 42956, 42947,
							42949, 42951, 41445, 42958, 49740
						},
					},
					{
						-- Chimaeron
						encounterId = 43296,
						npcIds = { 43296, 44418 }
					},
					{
						-- Maloriak
						encounterId = 41378,
						npcIds = {
							41378, 41440, 41576, 41961, 41841, 43037, 49811
						}
					},
					{
						-- Nefarian
						encounterId = 41376,
						npcIds = {
							41376, 42596, 41270, 42595, 41918, 41948, 51089
						}
					}
				}
			},
			{
				-- The Bastion of Twilight
				instanceId = "TheBastionOfTwilight",
				npcIds = {
					45261, 45265, 45267, 45264, 45266, 47017, 46951, 47087,
					47086, 47081, 47016, 46952, 47150, 47161, 47151, 47152,
					49825, 45676, 45699, 49817, 45700, 45858, 45721, 45687,
					45703, 49813, 49821, 49826
				},
				encounters = {
					{
						-- Halfus Wyrmbreaker
						encounterId = 44600,
						npcIds = { 44600, 44687, 44797, 44641, 44650, 44645 }
					},
					{
						-- Theralion and Valiona
						encounterId = 45993,
						npcIds = { 45993, 46147, 46448, 49864 }
					},
					{
						-- Ascendant Council
						encounterId = 43689,
						npcIds = {
							43689, 43686, 43688, 44201, 43687, 44824, 44747, 43735
						}
					},
					{
						-- Cho'gall
						encounterId = 43324,
						npcIds = {
							43324, 43585, 43406, 43622, 43707, 43888, 43592, 44045
						}
					},
					{
						-- Sinestra
						encounterId = 45213
					}
				}
			},
			{
				-- Throne of the Four Winds
				instanceId = "ThroneOfTheFourWinds",
				encounters = {
					{
						-- Conclave of Wind
						encounterId = 45870,
						npcIds = { 45870, 45871, 45872, 46186, 45812 }
					},
					{
						-- Al'Akir
						encounterId = 46753,
						npcIds = { 46753, 48977, 25305, 47175, 47807 }
					}
				}
			}
		}
	},
	
	{
		-- Cataclysm Dungeons
		instanceSetId = "CataDungeon",
		raid = false,
		instances = {
			{
				-- End Time
				instanceId = "EndTime",
				npcIds = { },
				encounters = {
					{
						-- Echo of Baine
						encounterId = 54431
					},
					{
						-- Echo of Jaina
						encounterId = 54445
					},
					{
						-- Echo of Sylvanas
						encounterId = 54123
					},
					{
						-- Echo of Tyrande
						encounterId = 54544
					},
					{
						-- Murozond
						encounterId = 54432
					}
				}
			},
			{
				-- Well of Eternity
				instanceId = "WellOfEternity",
				npcIds = { },
				encounters = {
					{
						-- Peroth'arn
						encounterId = 55085
					},
					{
						-- Queen Azshara
						encounterId = 54853
					},
					{
						-- Mannoroth and Varo'then
						encounterId = 54969
					}
				}
			},
			{
				-- Hour of Twilight
				instanceId = "HourOfTwilight",
				npcIds = { },
				encounters = {
					{
						-- Arcurion
						encounterId = 54590
					},
					{
						-- Asira Dawnslayer
						encounterId = 54968
					},
					{
						-- Archbishop Benedictus
						encounterId = 54938
					}
				}
			},
			{
				-- Zul'Gurub
				instanceId = "ZulGurub",
				npcIds =  {
					52436, 52438, 52377, 52379, 52381, 52322, 52076, 52086,
					52340, 52405, 52348, 52350, 52606, 52419, 52362, 52364,
					52435, 52437, 52376, 52380, 52323, 52325, 52327, 52392,
					52079, 52339, 52345, 52422, 52311, 52137, 52087, 52373,
					52434, 52077, 52417, 52085
				},
				encounters = {
					{
						-- High Priest Venoxis
						encounterId = 52155,
						npcIds = { 52155, 52525 }
					},
					{
						-- Bloodlord Mandokir
						encounterId = 52151,
						npcIds = { 52151, 52156 }
					},
					{
						-- High Priestess Kilnara
						encounterId = 52059,
						npcIds = { 52059, 52061 }
					},
					{
						-- Zanzil
						encounterId = 52053
					}

				}
			},
			{
				-- Zul'Aman
				instanceId = "ZulAman",
				npcIds = {
					23596, 24530, 52962, 24064, 23597, 24138, 52958, 23581,
					23584, 23580, 24059, 24374, 23834, 24065, 23889, 24043,
					23582, 23586, 23542, 23774, 23587, 24217, 23822
				},
				encounters = {
					{
						-- Akil'zon
						encounterId = 23574,
						npcIds = { 23574,  24858 }
					},
					{
						-- Nalorakk
						encounterId = 23576
					},
					{
						-- Jan'alai
						encounterId = 23578,
						npcIds = { 23578, 23598 }
					},
					{
						-- Halazzi
						encounterId = 23577,
						npcIds = { 23577, 24143, 52755, 24224 }
						
					},
					{
						-- Hex Lord Malacrass
						encounterId = 24239,
						npcIds = { 24239, 24240, 24246, 24338 }
					},
					{
						-- Daakara
						encounterId = 23863,
						npcIds = { 23863, 24136, 23878, 23879, 23880, 23877 }
					}
				}
			},
			{
				-- Grim Batol
				instanceId = "GrimBatol",
				npcIds = {
					39962, 39909, 41045, 40291, 40167, 39854, 39415, 39870, 
					41073, 39626, 39890, 40270, 40272, 39392, 41095, 39900, 
					41040, 40290, 40166, 39414, 39294, 40306, 39873, 40268, 
					40448, 41091, 39381, 39954, 39450, 40269, 39956, 40273, 
					39855, 39405, 39390, 40953, 39892, 39961
				},
				encounters = {
					{
						-- General Umbriss
						encounterId = 39625,
						npcIds = { 39625, 39984, 45467 }
					},
					{
						-- Forgemaster Throngus
						encounterId = 40177,
						npcIds = { 40177, 40197 }
					},
					{
						-- Drahga Shadowburner
						encounterId = 40319,
						npcIds = { 40319, 40320, 40357 }
					},
					{
						-- Erudax
						encounterId = 40484,
						npcIds = { 40484, 40490, 40486, 39388, 40600, 48844 }
					}
				}
			},
			{
				-- Halls of Origination
				instanceId = "HallsOfOrigination",
				npcIds = {
					41371, 39266, 39366, 40787, 40669, 42556, 40170, 39804,
					48139, 48140, 48141, 39369, 48143, 40630, 40033, 39373,
					39258, 39800, 41364, 40715, 39440, 39803, 40310, 40311,
					40808, 40251, 41264, 39370, 39801, 40668
				},
				encounters = {
					{
						-- Temple Guardian Anhuur
						encounterId = 39425,
						npcIds = { 39425, 40283, 39444 }
					},
					{
						-- Earthrager Ptah
						encounterId = 39428,
						npcIds = { 39428, 40450, 40503 }
					},
					{
						-- Anraphet
						encounterId = 39788
					},
					{
						-- Isiset
						encounterId = 39587,
						npcIds = { 39587, 39722, 39721, 39795, 39720 }
					},
					{
						-- Ammunae
						encounterId = 39731,
						npcIds = { 39731, 40550, 40620, 40585 }
					},
					{
						-- Setesh
						encounterId = 39732,
						npcIds = { 39732, 41208, 41148, 41126 }
 					},
					{
						-- Rajh
						encounterId = 39378,
						npcIds = { 39378, 39635, 40927, 47040 }
					}
				}
			},
			{
				-- Lost City of the Tol'vir
				instanceId = "LostCityOfTheTolVir",
				npcIds = {
					45122, 45062, 45063, 45126, 44260, 44261, 44976, 44977,
					44980, 44981, 44982, 44922, 44924, 44926, 44897, 44898,
					44932, 45377
				},
				encounters = {
					{
						-- General Husam
						encounterId = 44577
					},
					{
						-- Lockmaw
						encounterId = 43614,
						npcIds = { 43614, 43658, 49045, 43650, 45378, 45379 }
					},
					{
						-- High Prophet Barim
						encounterId = 43612,
						npcIds = { 43612, 43801, 43927 }
					},
					{
						-- Siamat
						encounterId = 44819,
						npcIds = { 44819, 45268, 44541, 44704, 45259, 44713, 45269 }
					}
				}
			},
			{
				-- The Vortex Pinnacle
				instanceId = "TheVortexPinnacle",
				npcIds = {
					45704, 45922, 45915, 45932, 45991, 45924, 45917, 47085,
					47238, 45926, 45919, 45477, 45935, 45928, 45912, 45930
				},
				encounters = {
					{
						-- Grand Vizier Ertan
						encounterId = 43878,
						npcIds = { 43878, 46007 }
					},
					{
						-- Altairus
						encounterId = 43873,
						npcIds = { 43873, 47305 }
					},
					{
						-- Asaad
						encounterId = 43875,
						npcIds = { 43875, 46492, 47000 }
					}
				}
			},
			{
				-- The Stonecore
				instanceId = "TheStonecore",
				npcIds = {
					43537, 42810, 42691, 42789, 42692, 49473, 43391, 42845,
					43662, 43430, 42808, 42696, 43014
				},
				encounters = {
					{
						-- Corborus
						encounterId = 43438,
						npcIds = { 43438, 43917 }
					},
					{
						-- Slabhide
						encounterId = 43214,
						npcIds = { 43214, 43242 },
					},
					{
						-- Ozruk
						encounterId = 42188
					},
					{
						-- High Priestess Azil
						encounterId = 42333
					}
				}
			},
			{
				-- Throne of the Tides
				instanceId = "ThroneOfTheTides",
				npcIds = {
					40634, 41139, 39960, 40943, 39616, 40584, 40577, 40923,
					41096, 41201, 40935, 40936, 40579, 40925
				},
				encounters = {
					{
						-- Lady Naz'jar
						encounterId = 40586,
						npcIds = { 40586, 44404, 40597, 40633, 48983 }
 					},
					{
						-- Commander Ulthok
						encounterId = 40765
					},
					{
						-- Mindbender Ghur'sha
						encounterId = 40788,
						npcIds = { 40788, 40825, 45469 }
					},
					{
						-- Ozumat
						encounterId = 42172,
						npcIds = {
							42172, 44834, 40792, 44715, 44648, 44566, 44658, 44801,
							44841, 44752
						}
					}
				}
			},
			{
				-- Blackrock Caverns
				instanceId = "BlackrockCaverns",
				npcIds = {
					40019, 39982, 39990, 40013, 40021, 40164, 39978, 39985, 
					40008, 39670, 50284, 40017, 39980, 40023, 39987, 39708, 
					40011, 40004, 39994
				},
				encounters = {
					{
						-- Rom'oog Bonecrusher
						encounterId = 39665,
						npcIds = { 39665, 40447 }
					},
					{
						-- Corla, Herald of Twilight
						encounterId = 39679
					},
					{
						-- Karsh Steelbender
						encounterId = 39698,
						npcIds = { 39698, 40084, 50417 }
					},
					{
						-- Beauty
						encounterId = 39700
					},
					{
						-- Ascendant Lord Obsidius
						encounterId = 39705,
						npcIds = { 39705, 40817 }
					}
				}
			},
			{
				-- Shadowfang Keep
				instanceId = "ShadowfangKeep",
				npcIds = {
					47137, 47145, 47138, 47131, 47132, 47140, 47146, 47231,
					47134, 47232, 47135, 47143, 47136, 47141, 3869, 3870,
					3877, 3873
				},
				encounters = {
					{
						-- Baron Ashbury
						encounterId = 46962
					},
					{
						-- Baron Silverlaine
						encounterId = 3887,
						npcIds = { 3887, 50869 }
					},
					{
						-- Commander Springvale
						encounterId = 4278,
						npcIds = { 4278, 50615, 50613 }
					},
					{
						-- Lord Walden
						encounterId = 46963,
						npcIds = { 46963, 50439 },
					},
					{
						-- Lord Godfrey
						encounterId = 46964,
						npcIds = { 46964, 50561 }
					}
				}
			},
			{
				-- The Deadmines
				instanceId = "TheDeadmines",
				npcIds = {
					48284, 48440, 48505, 48351, 48445, 48229, 48230, 48417,
					48418, 47403, 47404, 48521, 48522, 48338, 48279, 48502,
					48262, 48266, 48420, 48450, 48419, 48266, 48447
				},
				encounters = {
					{
						-- Glubtok
						encounterId = 47162
					},
					{
						-- Helix Gearbreaker
						encounterId = 47296,
						npcIds = { 47296, 47314, 47297 }
					},
					{
						-- Foe Reaper 5000
						encounterId = 43778,
						npcIds = { 43778, 49229, 49208 }
					},
					{
						-- Admiral Ripsnarl
						encounterId = 47626,
						npcIds = { 47626, 47714 }
					},
					{
						-- "Captain" Cookie
						encounterId = 47739,
						npcIds = { 47739, 48302, 48298, 48293, 48295, 48276, 48299 }
					},
					{
						-- Vanessa VanCleef
						encounterId = 49541,
						npcIds = {
							49534, 49535, 49536, 49541, 49493, 49674, 49457, 49481,
							49429, 49670, 49520, 49671, 49850, 49681, 49854, 49852
						}
					}
				}
			}
		}
	},
	
	{
		-- Wrath of the Lich King Raid
		instanceSetId = "WotlkRaid",
		raid = true,
		instances = {
			{
				-- The Ruby Sanctum
				instanceId = "TheRubySanctum",
				npcIds = { 40423, 40417, 40419, 40421 },
				encounters = {
					{
						-- Saviana Ragefire
						encounterId = 39747
					},
					{
						-- Baltharus the Warborn
						encounterId = 39751,
						npcIds = { 39751, 39899 }
					},
					{
						-- General Zarithrian
						encounterId = 39746,
						npcIds = { 39746, 39814 }
					},
					{
						-- Halion
						encounterId = 39863,
						npcIds = {
							39863, 29863, 40681, 40142, 40683, 40083, 40029, 40468
						}
					}
				}
			},
			{
				-- Icecrown Citadel
				instanceId = "IcecrownCitadel",
				npcIds = {
					37744, 37928, 37666, 37662, 37571, 37665, 37744, 37901,
					36880, 37098, 37595, 37038, 37662, 37663, 37571, 37665,
					38410, 38104, 37011, 37022, 37023, 37996, 37025, 37217,
					36934, 37664, 37666, 37012, 36811, 36807, 36829, 36805,
					36808, 37007, 37546, 37586, 31185, 36725, 37044, 37032,
					37033, 37149, 37031, 37030, 37029, 37146, 37028, 37035,
					36844, 36724, 37017, 37004, 37027, 37016, 37144, 36998,
					37026, 37003, 37148, 37021, 37230, 37544, 37545, 10404,
					38879, 37782, 37123, 37868, 37125, 37126, 37127, 37531,
					37129, 38154, 37132, 38125, 37134, 38223, 37133, 37124,
					38184, 38494, 37532, 37533, 37534, 37122, 37228, 37229,
					37502, 37501, 37232
				},
				encounters = {
					{
						-- Lord Marrowgar
						encounterId = 36612,
						npcIds = { 36612, 36672, 36619 }
					},
					{
						-- Lady Deathwhisper
						encounterId = 36855,
						npcIds = { 36855, 38222, 37949, 37890 } 
						
					},
					{
						-- Gunship Battle
						encounterId = 36839,
						npcIds = {
							36839, 36939, 36948, 36961, 36969, 36978, 37116, 36950
						}
					},
					{
						-- Deathbringer Saurfang
						encounterId = 37813,
						npcIds = { 37813, 38508 }
					},
					{
						-- Rotface
						encounterId = 36627,
						npcIds = { 36627, 36897, 36899, 37006 }
					},
					{
						-- Festergut
						encounterId = 36626
					},
					{
						-- Professor Putricide
						encounterId = 36678,
						npcIds = { 36678, 37690, 37697, 37562, 38285 },
					},
					{
						-- Blood Prince Council
						encounterId = 37970,
						npcIds = {
							37970, 37972, 37973, 38008, 38369, 38454, 38332, 38422,
							38451
						}
					},
					{
						-- Blood-Queen Lana'thel
						encounterId = 37955,
						npcIds = { 37955, 38163 }
					},
					{
						-- Valithria Dreamwalker
						encounterId = 36789,
						npcIds = {
							36789, 37868, 37863, 37886, 36791, 37934, 38068, 37907, 38421
						}
					},
					{
						-- Sindragosa
						encounterId = 36853,
						npcIds = { 36853, 37186 }
					},
					{
						-- The Lich King
						encounterId = 36597,
						npcIds = {
							36597, 36633, 36701, 38757, 37698, 37695, 36609, 37799,
							38579, 39217, 39189, 39137, 39190
						}
					}
				}
			},
			{
				-- Onyxia's Lair
				instanceId = "OnyxiasLair",
				npcIds = { 12129 },
				encounters = {
					{
						-- Onyxia
						encounterId = 10184,
						npcIds = { 10184, 11262, 36561 }
					}
				}
			},
			{
				-- Trial of the Crusader
				instanceId = "TrialOfTheCrusader",
				encounters = {
					{
						-- The Beasts of Northrend
						encounterId = 34796,
						npcIds = {
							34796, 35144, 34799, 34797, 34800, 34854
						}
					},
					{
						-- Lord Jaraxxus
						encounterId = 34780,
						npcIds = {
							34780, 34825, 34813, 34815, 34784, 34826
						}
					},
					{
						-- Faction Champions
						encounterId = 34469,
						npcIds = {
							35465, 34469, 34470, 34471, 34473, 34474, 34475, 34468,
							34461, 35610, 34463, 34472, 34466, 34467, 34460, 34465
						}
					},
					{
						-- Twin Val'kyr
						encounterId = 34496,
						npcIds = {
							34496, 34497, 34628, 34630
						}
					},
					{
						-- Anub'arak
						encounterId = 34564,
						npcIds = {
							34564, 34606, 34605, 34607, 34660 
						}
					}
				}
			},
			{
				-- Ulduar
				instanceId = "Ulduar",
				npcIds = {
					34197, 34133, 33715, 33354, 33431, 34085, 33430, 33528,
					34190, 34198, 33526, 32882, 34199, 34086, 33525, 33355,
					33527, 34267, 33768, 34196, 32872, 33699, 33722, 34137,
					34134, 34135, 34273, 34271, 34269, 34161, 33090, 34164,
					33572, 34234, 33236, 34069, 33237, 33255, 33264, 33754,
					34203, 33838, 33824, 33772, 33818, 33819, 33820, 33806,
					33822, 33823, 34193, 34183, 34184, 34224, 33755, 34288,
					34194
				},
				encounters = {
					{
						-- Flame Leviathan
						encounterId = 33113,
						npcIds = {
							33113, 33139, 33367, 33114, 34275, 33143, 33212, 33369,
							33370, 33189, 33387, 33365, 33142
						}
					},
					{
						-- Razorscale
						encounterId = 33186,
						npcIds = { 33186, 33388, 33846, 33453 }
					},
					{
						-- Ignis the Furnace Master
						encounterId = 33118,
						npcIds = { 33118, 33221, 33121 }
					},
					{
						-- XT-002 Deconstructor
						encounterId = 33293,
						npcIds = { 33293, 33329, 33346, 33344, 33337, 34004, 34001 }
					},
					{
						-- Assembly of Iron
						encounterId = 32867,
						npcIds = { 32867, 32927, 32857, 33705 }
					},
					{
						-- Kologarn
						encounterId = 32930
					},
					{
						-- Auriaya
						encounterId = 33515,
						npcIds = { 33515, 34035, 34014, 34034 }
					},
					{
						-- Hodir
						encounterId = 32845,
						npcIds = {
							32845, 32938, 32926, 33169, 33173, 33332, 33333, 32941,
							32946, 32948, 32950, 33330, 33331, 33342
						}
					},
					{
						-- Thorim
						encounterId = 32865,
						npcIds = {
							32865, 32873, 32908, 32885, 32886, 32957, 33110, 32876,
							32904, 32878, 32877, 33125, 32874, 33196, 32875, 33138
						},
					},
					{
						-- Freya
						encounterId = 32906,
						npcIds = {
							32906, 32915, 32913, 32914, 33203, 33202, 32918, 33228,
							33088, 32916, 32919, 33050, 33215, 34129, 33170
						}
					},
					{
						-- Mimiron
						encounterId = 33350,
						npcIds = {
							33350, 33432, 33651, 33670, 34071, 34057, 33855, 34362,
							33836, 34047, 34192, 34149, 34147
						}
					},
					{
						-- General Vezax
						encounterId = 33271,
						npcIds = { 33271, 33524 }
					},
					{
						-- Yogg-Saron
						encounterId = 33288,
						npcIds = {
							33288, 33411, 33412, 33413, 33410, 33134, 33991, 33136,
							33983, 33985, 33966, 33890, 33990, 33719, 33720, 33280,
							33716, 33717, 33433, 33988, 33567
						}
					},
					{
						-- Algalon the Observer
						encounterId = 32871,
						npcIds = {
							32871, 33052, 33089, 32953, 33052
						}
					}
				}
			},
			{
				-- Naxxramas
				instanceId = "Naxxramas",
				npcIds = {
					16018, 15975, 15978, 16156, 16146, 16145, 16163, 29818,
					15974, 16024, 16236, 16036, 16244, 16385, 16021, 16027,
					16020, 30083, 16297, 15981, 15980, 16165, 16017, 16034,
					16037, 16375, 16164, 16193, 16029, 30071, 16025, 16168,
					16022, 15979, 16194, 16215, 16216, 15976
				},
				encounters = {
					{
						-- Anub'rekhan
						encounterId = 15956,
						npcIds = { 15956, 16573 }
					},
					{
						-- Grand Widow Faerlina
						encounterId = 15953,
						npcIds = { 15953, 16505, 16506 }
					},
					{
						-- Maexxna
						encounterId = 15952,
					},
					{
						-- Noth the Plaguebringer
						encounterId = 15954,
						npcIds = { 15954, 16983, 16984 }
					},
					{
						-- Heigan the Unclean
						encounterId = 15936
					},
					{
						-- Loatheb
						encounterId = 16011,
						npcIds = { 16011, 16286 }
					},
					{
						-- Instructor Razuvious
						encounterId = 16061
					},
					{
						-- Gothik the Harvester
						encounterId = 16060,
						npcIds = {
							16060, 16148, 16149, 16150, 16127, 16125, 16126,
							16124
						}
					},
					{
						-- The Four Horsemen
						encounterId = 16063,
						npcIds = { 30549, 16065, 16063, 16064 }
					},
					{
						-- Patchwerk
						encounterId = 16028
					},
					{
						-- Grobbulus
						encounterId = 15931,
						npcIds = { 15931, 16363 }
					},
					{
						-- Gluth
						encounterId = 15932
					},
					{
						-- Thaddius
						encounterId = 15928,
						npcIds = {15928, 15930, 15929 }
					},
					{
						-- Sapphiron
						encounterId = 15989,
						npcIds = { 15989, 16474 }
					},
					{
						-- Kel'Thuzad
						encounterId = 15990,
						npcIds = { 15990, 16441, 16129, 16428 }
					}
				}
			},
			{
				-- The Eye of Eternity
				instanceId = "TheEyeOfEternity",
				encounters = {
					{
						-- Malygos
						encounterId = 28859,
						npcIds = { 28859, 30245, 30249, 30592, 30084 }
					}
				}
			},
			{
				-- The Obsidian Sanctum
				instanceId = "TheObsidianSanctum",
				npcIds = { 30681, 30680, 30682, 30453 },
				encounters = {
					{
						-- Sartharion
						encounterId = 28860,
						npcIds = { 28860, 30451, 30452, 30449, 30641, 31214 }
					}
				}
			},
			{
				-- Vault of Archavon
				instanceId = "VaultOfArchavon",
				npcIds = { 32353, 34015, 35143, 38482 },
				encounters = {
					{
						-- Archavon the Stone Watcher
						encounterId = 31125
					},
					{
						-- Emalon the Storm Watcher
						encounterId = 33993,
						npcIds = { 33993, 33998, 34049 }
					},
					{
						-- Koralon the Flame Watcher
						encounterId = 35013
					},
					{
						-- Toravon the Ice Watcher
						encounterId = 38433,
						npcIds = { 38433, 38456 }
					}
				}
			}
		}
	},
	{
		-- Wrath of the Lich King Dungeons
		instanceSetId = "WotlkDungeon",
		instances = {
			{
				-- Halls of Reflection
				instanceId = "HallsOfReflection",
				npcIds = {
					37071, 38175, 38176, 38177, 38567, 38173, 38172, 37554,
					36723, 37068, 37107
				},
				encounters = {
					{
						-- Falric
						encounterId = 38112
					},
					{
						-- Marwyn
						encounterId = 38113
					},
					{
						-- The Lich King
						encounterId = 36954,
						npcIds = { 36954, 36941, 36940, 37069 }
					}
				}
			},
			{
				-- Pit of Saron
				instanceId = "PitOfSaron",
				npcIds = {
					37587, 37584, 37588, 36847, 37779, 37583, 36788, 36874,
					36841, 37670, 36886, 36770, 36772, 36990, 36891, 36879,
					36794, 36881, 36842, 36830, 36877, 36893, 31260, 36892,
					36840
				},
				encounters = {
					{
						-- Forgemaster Garfrost
						encounterId = 36494,
						npcIds = { 36494, 36907 }
					},
					{
						-- Ick & Krick
						encounterId = 36476,
						npcIds = { 36476, 36477, 36610 }
					},
					{
						-- Scourgelord Tyrannus
						encounterId = 36658,
						npcIds = {
							36658, 36661, 37579, 37577, 37578, 37581, 36731, 38487,
							37728, 37729
						}
					}
				},
			},
			{
				-- The Forge of Souls
				instanceId = "TheForgeOfSouls",
				npcIds = {
					36564, 36666, 36620, 36551, 36499, 36478, 36522, 36516
				},
				encounters = {
					{
						-- Bronjahm
						encounterId = 36497
					},
					{
						-- Devourer of Souls
						encounterId = 36502,
						npcIds = { 36502, 36595, 36536 }
					}
				}
			},
			{
				-- Trial of the Champion
				instanceId = "TrialOfTheChampion",
				npcIds = {
					35305, 35307, 35309, 35311
				},
				encounters = {
					-- Grand Champions
					{
						encounterId = 33361,
						npcIds = {
							33361, 33372, 33373, 33379, 33403, 34657, 34701, 34702,
							34703, 34705, 35331, 35332, 35328, 35329, 35633, 35636,
							34658, 35637, 35644, 35768, 35330
						}
					},
					-- Argent Confessor Paletress 
					{
						encounterId = 34928,
						npcIds = {
							34928, 35047, 35034, 35049
						}
					},
					-- Eadric the Pure
					{
						encounterId = 35119
					},
					-- The Black Knight
					{
						encounterId = 35451,
						npcIds = {
							35451, 35545, 35590
						}
					}
				}
			},
			{
				-- Halls of Lightning
				instanceId = "HallsOfLightning",
				npcIds = {
					28583, 28579, 28578, 28580, 28585, 28835, 28920,
					28582, 28836, 28837, 28581, 28826, 28547, 28961,
					28965, 28838, 28584
				},
				encounters = {
					{
						-- General Bjarngrim
						encounterId = 28586,
						npcIds = { 28586, 29240 }
					},
					{
						-- Volkhan
						encounterId = 28587,
						npcIds = { 28587, 28695 }
					},
					{
						-- Ionar
						encounterId = 28546,
						npcIds = { 28546, 28926 }
					},
					{
						-- Loken
						encounterId = 28923
					}
				}
			},
			{
				-- The Culling of Stratholme
				instanceId = "TheCullingOfStratholme",
				npcIds = {
					27731, 28201, 27734, 28200, 28249, 27729, 27742, 27744,
					28341, 27743, 28340, 27732
				},
				encounters = {
					{
						-- Meathook
						encounterId = 26529
					},
					{
						-- Salramm the Fleshcrafter
						encounterId = 26530
					},
					{
						-- Chrono-Lord Epoch
						encounterId = 26532
					},
					{
						-- Mal'Ganis
						encounterId = 26533
					},
					{
						-- Infinite Corruptor
						encounterId = 32273
					}
				}
			},
			{
				-- The Oculus
				instanceId = "TheOculus",
				npcIds = {
					27645, 27692, 27755, 27647, 27756, 27648, 27649, 27650,
					27651, 27653, 27638, 27639, 27640, 28276, 27641, 28153,
					27642, 27644
				},
				encounters = {
					{
						-- Drakos The Interrogator
						encounterId = 27654
					},
					{
						-- Varos Cloudstrider
						encounterId = 27447
					},
					{
						-- Mage-Lord Urom
						encounterId = 27655
					},
					{
						-- Ley-Guardian Eregos
						encounterId = 27656,
						npcIds = { 27656, 30879 }
					}
				}
			},
			{
				-- Utgarde Pinnacle
				instanceId = "UtgardePinnacle",
				npcIds = {
					26672, 26550, 26553, 26554, 26555, 26696, 26694, 26670,
					28368, 26669
				},
				encounters = {
					{
						-- Svala Sorrowgrave
						encounterId = 26668,
						npcIds = { 26668, 27281 }
					},
					{
						-- Gortok Palehoof
						encounterId = 26687,
						npcIds = {26687, 26686, 26683, 26685, 26684 }
					},
					{
						-- Skdadi the Ruthless
						encounterId = 26693,
						npcIds = { 26693, 26692, 26690, 26691 }
					},
					{
						-- King Ymiron
						encounterId = 26861,
						npcIds = { 26861, 27339 }
					}
				}
			},
			{
				-- Halls of Stone
				instanceId = "HallsOfStone",
				npcIds = {
					27966, 27962, 27969, 27964, 27965, 27963, 27960, 27961,
					28384, 27972, 27970, 27971
				},
				encounters = {
					{
						-- Maiden of Grief
						encounterId = 27975
					},
					{
						-- Krystallus
						encounterId = 27977
					},
					{
						-- Tribunal of Ages
						encounterId = 27983,
						npcIds = { 28235, 27983, 27984, 27985 }
					},
					{
						-- Sjonnir The Ironshaper
						encounterId = 27978,
						npcIds = { 27978, 27982, 27979 }
					}
				}
			},
			{
				-- Gundrak
				instanceId = "Gundrak",
				npcIds = {
					29836, 29829, 29822, 29820, 29832, 29874, 29819, 29826,
					29982, 29830, 29920, 29774, 29768, 29838
				},
				encounters = {
					{
						-- Slad'ran
						encounterId = 29304,
						npcIds = { 29304, 29713, 29680, 29742 }
					},
					{
						-- Drakkari Colossus
						encounterId = 29307,
						npcIds = { 29307, 29573 }
					},
					{
						-- Moorabi
						encounterId = 29305
					},
					{
						-- Gal'darah
						encounterId = 29306,
						npcIds = { 29306, 29791 }
					},
					{
						-- Eck the Ferocious
						encounterId = 29932
					}
				}
			},
			{
				-- The Violet Hold
				instanceId = "TheVioletHold",
				npcIds = {
					30918, 30666, 30661, 30961, 30664, 30668, 31079, 30667,
					32191, 30837, 30660, 30892, 30695, 30893, 31009, 31008,
					30663, 31007, 30665, 31010
				},
				encounters = {
					{
						-- Erekem
						encounterId = 29315,
						npcIds = { 29315, 29395 }
					},
					{
						-- Moragg
						encounterId = 29316
					},
					{
						-- Ichoron
						encounterId = 29313,
						npcIds = { 29313, 29321 }
					},
					{
						-- Xevozz
						encounterId = 29266
					},
					{
						-- Lavanthor
						encounterId = 29312
					},
					{
						-- Zuramat The Obliterator
						encounterId = 29314,
						npcIds = { 29314, 29365 }
					},
					{
						-- Cayanigosa
						encounterId = 31134
					}
				}
			},
			{
				-- Drak'Tharon Keep
				instanceId = "DrakTharonKeep",
				npcIds = {
					26625, 26620, 26641, 26639, 27431, 27871, 26621, 26638,
					26830, 26637, 26636, 26635, 26623, 26626, 26624
				},
				encounters = {
					{
						-- Trollgore
						encounterId = 26630
					},
					{
						-- Novos The Summonor
						encounterId = 26631,
						npcIds = { 26631, 26627, 27600 },
					},
					{
						-- King Dred
						encounterId = 27483,
						npcIds = { 27483, 26628 }
					},
					{
						-- The Prophet Tharon'ja
						encounterId = 26632
					}
				}
			},
			{
				-- Ahn'kahet: The Old Kingdom
				instanceId = "AhnKahetTheOldKingdom",
				npcIds = {
					30179, 30416, 30285, 30319, 30419, 30286, 30329, 30414,
					30418, 30287, 30111, 30284
				},
				encounters = {
					{
						-- Elder Nadox
						encounterId = 29309
					},
					{
						-- Prince Taldaram
						encounterId = 29308,
						npcIds = { 29308, 30106, 31686, 31687 }
					},
					{
						-- Jedoga Shadowseeker
						encounterId = 29310
					},
					{
						-- Herald Volazj
						encounterId = 29311,
						npcIds = { 29311, 30622, 30623, 30624, 30625 }
					},
					{
						-- Amanitar
						encounterId = 30258,
						npcIds = { 30258, 30391, 30435 }
					}
				}
			},
			{
				-- Azjol'Nerub
				instanceId = "AzjolNerub",
				encounters = {
					{
						-- Krik'thir the Gatewatcher
						encounterId = 28684
					},
					{
						-- Hadronox
						encounterId = 28921
					},
					{
						-- Anub'arak
						encounterId = 29120
					}
				}
			},
			{
				-- The Nexus
				instanceId = "TheNexus",
				npcIds = {
					26730, 26746, 26793, 26716, 26918, 26734, 26735, 26782,
					26737, 26722, 26800, 26723, 26802, 26727, 26805, 26728,
					26792, 26729, 28231, 27949
				},
				encounters = {
					{
						-- Grand Magus Telestra
						encounterId = 26731,
						npcIds = { 26731, 26928, 26929, 26930 }
					},
					{
						-- Anomalus
						encounterId = 26763,
					},
					{
						-- Ormorok The Tree-Shaper
						encounterId = 26794
					},
					{
						-- Keristrsza
						encounterId = 27723,
						npcIds = { 26723 }
					},
					{
						-- Commander Stoutbeard
						encounterId = 26796
					},
					{
						-- Commander Kolurg
						encounterId = 26798
					}
				}
			},
			{
				-- Utgarde Keep
				instanceId = "UtgardeKeep",
				npcIds = {
					24069, 24079, 24071, 23961, 24078, 24085, 23960, 28410,
					23956, 24080, 24082, 24849, 29735, 32246, 24084
				},
				encounters = {
					{
						-- Prince Keleseth
						encounterId = 23953,
						npcIds = { 23953, 23970 },
					},
					{
						-- Skarvald & Dalronn
						encounterId = 24200,
						npcIds = { 24200, 24201 }
					},
					{
						-- Ingvar the Punderer
						encounterId = 23954
					}
				}
			}
		}
	},
	
	{
		-- The Burning Crusade Raid
		instanceSetId = "TbcRaid",
		raid = true,
		instances = {
			{
				-- Sunwell Plateau
				instanceId = "SunwellPlateau",
				npcIds = {
					25368, 25867, 25369, 25639, 26101, 25370, 25507, 25363,
					25367, 25371, 25372
				},
				encounters = {
					{
						-- Kalecgos
						encounterId = 24850,
						npcIds = { 24850, 24892, 24891 }
					},
					{
						-- Brutallus
						encounterId = 24882,
						npcIds = { 24882, 24895 }
					},
					{
						-- Felmyst
						encounterId = 25038,
						npcIds = { 25038, 25268 }
					},
					{
						-- Eredar Twins
						encounterId = 25164,
						npcIds = { 25166, 25164 }
					},
					{
						-- M'uru
						encounterId = 25741,
						npcIds = { 25741, 25840 }
					},
					{
						-- Kil'jaeden
						encounterId = 25315
					}
				}
			},
			{
				-- Black Temple
				instanceId = "BlackTemple",
				encounters = {
					{
						-- High Warlord Naj'entus
						encounterId = 22887
					},
					{
						-- Supremus
						encounterId = 22898
					},
					{
						-- Shade of Akama
						encounterId = 22841
					},
					{
						-- Teron Gorefiend
						encounterId = 22871
					},
					{
						-- Gurtogg Bloodboil
						encounterId = 22948
					},
					{
						-- Reqliquary of Souls
						encounterId = 23418,
						npcIds = { 23418, 23419, 23420 }
					},
					{
						-- Mother Shahraz
						encounterId = 22947
					},
					{
						-- The Illidari Council
						encounterId = 22949,
						npcIds = { 22949, 22950, 22951, 22952 }
					},
					{
						-- Illidan Stormrage
						encounterId = 22917
					}
				}
			},
			{
				-- Hyjal Summit
				instanceId = "HyjalSummit",
				encounters = {
					{
						-- Rage Winterchill
						encounterId = 17767
					},
					{
						-- Anetheron
						encounterId = 17808
					},
					{
						-- Kaz'rogal
						encounterId = 17888
					},
					{
						-- Azgalor
						encounterId = 17842
					},
					{
						-- Archimonde
						encounterId = 17968
					}
				}
			},
			{
				instanceId = "SerpentshrineCavern",
				encounters = {
					{
						-- Hydross the Unstable
						encounterId = 21216
					},
					{
						-- The Lurker Below
						encounterId = 21217
					},
					{
						-- Leotheras the Blind
						encounterId = 21215
					},
					{
						-- Fathom-Lord Karathress
						encounterId = 21214
					},
					{
						-- Morogrim Tidewalker
						encounterId = 21213
					},
					{
						-- Lady Vashj
						encounterId = 21212
					}
				}
			},
			{
				-- The Eye
				instanceId = "TheEye",
				encounters = {
					{
						-- Void Reaver
						encounterId = 19516
					},
					{
						-- A'lar
						encounterId = 19514
					},
					{
						-- High Astromancer Solarian
						encounterId = 18805
					},
					{
						-- Kael'thas Sunstrider
						encounterId = 19622
					}
				}
			},
			{
				instanceId = "MagtheridonsLair",
				encounters = {
					{
						-- Magtheridon
						encounterId = 17257
					}
				}
			},
			{
				instanceId = "GruulsLair",
				encounters = {
					{
						-- High King Maulgar
						encounterId = 18831,
						npcIds = { 18831, 18836, 18835, 18832, 18834 }
					},
					{
						-- Gruul the Dragonkiller
						encounterId = 19044
					}
				}
			},
			{
				-- Karazhan
				instanceId = "Karazhan",
				encounters = {
					{
						-- Hyakiss the Lurker
						encounterId = 16179
					},
					{
						-- Rokad the Ravager
						encounterId = 16181
					},
					{
						-- Shadikith the Glider
						encounterId = 16180
					},
					{
						-- Atumen the Huntsman
						encounterId = 15550,
						npcIds = { 15550, 16151 }
					},
					{
						-- Moroes
						encounterId = 15687
					},
					{
						-- Maiden of Virtue
						encounterId = 16457
					},
					{
						-- Romulo and Julianne
						encounterId = 17533,
						npcIds = { 17533, 17534 }
					},
					{
						-- The Big Bad Wolf
						encounterId = 17521
					},
					{
						-- Wizard of Oz
						encounterId = 18168,
						npcIds = { 18168,  17535, 17546, 17543, 17547, 17548 }
					},
					{
						-- Nightbane
						encounterId = 17225
					},
					{
						-- The Curator
						encounterId = 15691
					},
					{
						-- Terestian Illhoof
						encounterId = 15688
					},
					{
						-- Shade of Aran
						encounterId = 16524
					},
					{
						-- Netherspite
						encounterId = 15689
					},
					{
						-- Chess Event
						encounterId = 16816
					},
					{
						-- Prince Malchezaar
						encounterId = 15690
					}
				}
			}
		}
	},
	
	{
		-- The Burning Crusade Dungeon
		instanceSetId = "TbcDungeon",
		instances = {
			{
				-- Magisters' Terrace
				instanceId = "MagistersTerrace",
				encounters = {
					{
						-- Selin Fireheart
						encounterId = 24723
					},
					{
						-- Vexallus
						encounterId = 24744
					},
					{
						-- Priestess Delrissa
						encounterId = 24560
					},
					{
						-- Kael'thas Sunstrider
						encounterId = 24664
					}
				}
			},
			{
				-- Shadow Labyrinth
				instanceId = "ShadowLabyrinth",
				encounters = {
					{
						-- Ambassador Hellmaw
						encounterId = 18731
					},
					{
						-- Blackheart the Inciter
						encounterId = 18667
					},
					{
						-- Grandmaster Vorpil
						encounterId = 18732
					},
					{
						-- Murmur
						encounterId = 18708
					}
				}
			},
			{
				-- The Arcatraz
				instanceId = "TheArcatraz",
				encounters = {
					{
						-- Zereketh the Unbound
						encounterId = 20870
					},
					{
						-- Dalliah the Doomsayer
						encounterId = 20885
					},
					{
						-- Wrath-Scryer Soccothrates
						encounterId = 20886
					},
					{
						-- Harbinger Skyriss
						encounterId = 20912
					}
				}
			},
			{
				-- The Black Morass
				instanceId = "TheBlackMorass",
				encounters = {
					{
						-- Chrono Lord Deja
						encounterId = 17879
					},
					{
						-- Temporus
						encounterId = 17880
					},
					{
						-- Aeonus
						encounterId = 17881
					}
				}
			},
			{
				-- The Botanica
				instanceId = "TheBotanica",
				encounters = {
					{
						-- Commander Sarannis
						encounterId = 17976
					},
					{
						-- High Botanist Freywinn
						encounterId = 17975
					},
					{
						-- Thorngrin the Tender
						encounterId = 17978
					},
					{
						-- Laj
						encounterId = 17980
					},
					{
						-- Warp Splinter
						encounterId = 17977
					}
				}
			},
			{
				-- The Mechanar
				instanceId = "TheMechanar",
				encounters = {
					{
						-- Gatewatcher Gyro-Kill
						encounterId = 19218
					},
					{
						-- Gatewatcher Iron-Hand
						encounterId = 19710
					},
					{
						-- Mechano-Lord Capacitus
						encounterId = 19219
					},
					{
						-- Nethermancer Sepethrea
						encounterId = 19221
					},
					{
						-- Pathaleon the Calculator
						encounterId = 19220
					}
				}
			},
			{
				-- The Shattered Halls
				instanceId = "TheShatteredHalls",
				encounters = {
					{
						-- Grand Warlock Nethekurse
						encounterId = 16807
					},
					{
						-- Blood Guard Porung
						encounterId = 20923
					},
					{
						-- Warbringer O'mrogg
						encounterId = 16809
					},
					{
						-- Warchief Kargath Bladefist
						encounterId = 16808
					}
				}
			},
			{
				-- The Steamvault
				instanceId = "TheSteamvault",
				encounters = {
					{
						-- Hydromancer Thespia
						encounterId = 17797
					},
					{
						-- Mekgineer Steamrigger
						encounterId = 17796
					},
					{
						-- Warlord Kalithresh
						encounterId = 17798
					}
				}
			},
			{
				-- Sethekk Halls
				instanceId = "SethekkHalls",
				npcIds = {
					18701, 18703, 18318, 18319, 18320, 18321, 18322, 18323,
					21904, 18325, 21891, 18326, 18327, 19428, 18328, 19429,
					20343
				},
				encounters = {
					{
						-- Darkweaver Syth
						encounterId = 18472,
						npcIds = { 18472, 19204, 19205, 19206, 19203 }
					},
					{
						-- Anzu
						encounterId = 23035,
						npcIds = { 23035, 23132 }
					},
					{
						-- Talon King Ikiss
						encounterId = 18473
					}
				}
			},
			{
				-- Old Hillsbrad Foothills
				instanceId = "OldHillsbradFoothills",
				encounters = {
					{
						-- Lieutenant Drake
						encounterId = 17848
					},
					{
						-- Captain Skarloc
						encounterId = 17862
					},
					{
						-- Epoch Hunter
						encounterId = 18096
					}
				}
			},
			{
				-- Auchenai Crypts
				instanceId = "AuchenaiCrypts",
				encounters = {
					{
						-- Shirrak the Dead Watcher
						encounterId = 18371
					},
					{
						-- Exarch Maladaar
						encounterId = 18373
					}
				}
			},
			{
				-- Mana-Tombs
				instanceId = "ManaTombs",
				encounters = {
					{
						-- Pandemonius
						encounterId = 18341
					},
					{
						-- Tavarok
						encounterId = 18343
					},
					{
						-- Nexus-Prince Shaffar
						encounterId = 18344
					},
					{
						-- Yor
						encounterId = 22930
					}
				}
			},
			{
				-- The Underbog
				instanceId = "TheUnderbog",
				encounters = {
					{
						-- Hungarfen
						encounterId = 17770
					},
					{
						-- Ghaz'an
						encounterId = 18105
					},
					{
						-- Swamplord Musel'ek
						encounterId = 17826
					},
					{
						-- The Black Stalker
						encounterId = 17882
					}
				}
			},
			{
				-- The Slave Pens
				instanceId = "TheSlavePens",
				encounters = {
					{
						-- Mennu the Betrayer
						encounterId = 17941
					},
					{
						-- Rokmar the Crackler
						encounterId = 17991
					},
					{
						-- Quagmirran
						encounterId = 17942
					}
				}
			},
			{
				-- The Blood Furnace
				instanceId = "TheBloodFurnace",
				encounters = {
					{
						-- The Maker
						encounterId = 17381
					},
					{
						-- Broggok
						encounterId = 17380
					},
					{
						-- Keli'dan the Breaker
						encounterId = 17377
					}
				}
			},
			{
				-- Hellfire Ramparts
				instanceId = "HelfireRamparts",
				encounters = {
					{
						-- Watchkeeper Gargolmar
						encounterId = 17306
					},
					{
						-- Omor the Unscarred
						encounterId = 17308
					},
					{
						-- Vazruden
						encounterId = 17537,
						npcIds = { 17537, 17536 }
					}
				}
			}
		}
	},
	
	{
		-- Classic Raid
		instanceSetId = "ClassicRaid",
		raid = true,
		instances = {
			{
				-- Temple of Ahn'Qiraj
				instanceId = "TempleOfAhnQiraj",
				npcIds = {
					15264, 15311, 15537, 15725, 15726, 15262, 15312, 15247,
					15252, 15249, 15246, 15250, 15233, 15240, 15229, 15230,
					15236, 15235, 15277, 15538
				},
				encounters = {
					{
						-- The Prophet Skeram
						encounterId = 15263
					},
					{
						-- Bug Trio
						encounterId = 15511,
						npcIds = { 15543, 15544, 15511, 15933, 15621 }
 					},
					{
						-- Battleguard Sartura
						encounterId = 15516,
						npcIds = { 15516, 15984 }
					},
					{
						-- Fankriss the Unyielding
						encounterId = 15510
					},
					{
						-- Viscidus
						encounterId = 15299
					},
					{
						-- Princess Huhuran
						encounterId = 15509
					},
					{
						-- Twin Emperors
						encounterId = 15275,
						npcIds = { 15276, 15275, 15316, 15317 }
					},
					{
						-- Ouro
						encounterId = 15517,
						npcIds = { 15517, 15712 }
					},
					{
						-- C'Thun
						encounterId = 15727,
						npcIds = { 15589, 15727, 15726, 15802, 15728, 15334 }
					}
				}
			},
			{
				-- Blackwing Lair
				instanceId = "BlackwingLair",
				npcIds = {
					12464, 13996, 12468, 12457, 12459, 12461, 12463, 12465,
					12467, 12458, 12460
				},
				encounters = {
					{
						-- Razorgore the Untamed
						encounterId = 12435,
						npcIds = { 12435, 14456, 12420, 12557, 12422, 12416 }
					},
					{
						-- Vaelastrasz the Corrupt
						encounterId = 13020
					},
					{
						-- Broodlord Lashlayer
						encounterId = 12017
					},
					{
						-- Firemaw
						encounterId = 11983
					},
					{
						-- Ebonroc
						encounterId = 14601
					},
					{
						-- Flamegor
						encounterId = 11981
					},
					{
						-- Chromaggus
						encounterId = 14020
					},
					{
						-- Nefarian
						encounterId = 11583,
						npcIds = {
							11583, 14302, 10162, 14261, 14605, 14263, 14668, 14264,
							14262, 14265
						}
					}
				}
			},
			{
				-- Molten Core
				instanceId = "MoltenCore",
				npcIds = {
					11673, 11671, 11668, 11666, 11667, 11669, 12076, 12100,
					12265, 12101, 11659, 11658
				},
				encounters = {
					{
						-- Lucifron
						encounterId = 12118,
						npcIds = { 12118, 12119 }
					},
					{
						-- Magmadar
						encounterId = 11982
					},
					{
						-- Gehenas
						encounterId = 12259,
						npcIds = { 12259, 11661 }
					},
					{
						-- Garr
						encounterId = 12057,
						npcIds = { 12057, 12099 }
					},
					{
						--Shazzrah
						encounterId = 12264,
					},
					{
						-- Baron Geddon
						encounterId = 12056
					},
					{
						-- Golemagg the Incinerator
						encounterId = 11988,
						npcIds = { 11988, 11672 }
					},
					{
						-- Sulfuron Harbinger
						encounterId = 12098,
						npcIds = { 12098, 11662 }
					},
					{
						-- Majordomo Executus
						encounterId = 12018,
						npcIds = { 12018, 11663, 11664 }
					},
					{
						-- Ragnaros
						encounterId = 11502
					}
				}
			},
			{
				-- Ruins of Ahn'Qiraj
				instanceId = "RuinsOfAhnQiraj",
				encounters = {
					{
						-- Kurinnaxx
						encounterId = 15348
					},
					{
						-- General Rajaxx
						encounterId = 15341
					},
					{
						-- Moam
						encounterId = 15340
					},
					{
						-- Buru the Gorger
						encounterId = 15370
					},
					{
						-- Ayamiss the Hunter
						encounterId = 15369
					},
					{
						-- Ossirian the Unscarred
						encounterId = 15339
					}
				}
			}
		}
	},
	
	{
		-- Classic Dungeon
		instanceSetId = "ClassicDungeon",
		instances = {
			{
				-- Blackrock Spire
				instanceId = "BlackrockSpire",
				npcIds = {
					9269, 10372, 9239, 9240, 10217, 9241, 9716, 9717,
					10317, 10318, 10319, 9817, 9692, 9693, 9096, 9200,
					9097, 10366, 10799, 9261, 9257, 10083, 9258, 9583,
					9259, 10299, 9260, 9818, 9198, 9819, 9262, 10680,
					9263, 10681, 9264, 9098, 9197, 9045, 9266, 10374,
					9267, 9199, 9268, 10371, 9201
				},
				encounters = {
					{
						-- Highlord Omokk
						encounterId = 9196
					},
					{
						-- Shadow Hunter Vosh'Gaijn
						encounterId = 9236
					},
					{
						-- War Master Voone
						encounterId = 9237
					},
					{
						-- Mor Grayhoof
						encounterId = 16080
					},
					{
						-- Mother Smolderweb
						encounterId = 10596
					},
					{
						-- Urok Doomhowl
						encounterId = 10584,
						npcIds = { 10584, 10601, 10602 }
					},
					{
						-- Quartermaster Zigris
						encounterId = 9736
					},
					{
						-- Halycon
						encounterId = 10220,
						npcIds = { 10220, 10268 }
					},
					{
						-- Overlord Wyrmthalak
						encounterId = 9568
					},
					{
						-- Pyroguard Emberseer
						encounterId = 9816,
						npcIds = { 9816, 10316 }
					},
					{
						-- Solakar Flamewreath
						encounterId = 10264,
						npcIds = { 10264, 10258, 10683 }
					},
					{
						-- Goraluk Anvilcrack
						encounterId = 10899
					},
					{
						-- Warchief Rend Blackhand
						encounterId = 10429,
						npcIds = { 10429, 10339, 10442, 10447, 10162, 10742 }
					},
					{
						-- The Beast
						encounterId = 10430
					},
					{
						-- Lord Valthalak
						encounterId = 16042,
						npcIds = { 16042, 16066 }
					},
					{
						-- General Drakkisath
						encounterId = 10363,
						npcIds = { 10363, 10814 }
					}
				}
			},
			{
				-- Dire Maul
				instanceId = "DireMaul",
				npcIds = {
					11475, 11444, 11476, 13021, 13022, 11448, 11480, 11450,
					11451, 11483, 11484, 11454, 11455, 11456, 14386, 11457,
					11458, 13160, 11461, 11462, 13196, 11464, 13197, 11465,
					11466, 13285, 14397, 14303, 14398, 11469, 14399, 11470,
					14400, 11471, 11459, 11472, 11441, 11473, 13036
				},
				encounters = {
					{
						-- Pusillin
						encounterId = 14354
					},
					{
						-- Hydrospawn
						encounterId = 13280,
						npcIds = { 13280, 14350, 14122 }
					},
					{
						-- Zevrim Thornhoof
						encounterId = 11490
					},
					{
						-- Lethendris
						encounterId = 14327,
						npcIds = { 14327, 14349 }
					},
					{
						-- Alzzin the Wildshaper
						encounterId = 11492
					},
					{
						-- Isalien
						encounterId = 16097,
						npcIds = { 16097, 16098 },
					},
					{
						-- Tendris Warpwood
						encounterId = 11489
					},
					{
						-- Magister Kalendris
						encounterId = 11487
					},
					{
						-- Illyanna Ravenoak
						encounterId = 11488,
						npcIds = { 11488, 14308 }
					},
					{
						-- Immol'thar
						encounterId = 11496,
						npcIds = { 11496, 14396 }
					},
					{
						-- Prince Tortheldrin
						encounterId = 11486
					},
					{
						-- Guard Mol'dar
						encounterId = 14326
					},
					{
						-- Stomper Kreeg
						encounterId = 14322
					},
					{
						-- Guard Fengus
						encounterId = 14321
					},
					{
						-- Guard Slip'kik
						encounterId = 14323
					},
					{
						-- Captain Kromcrush
						encounterId = 14325
					},
					{
						-- King Gordok
						encounterId = 11501,
						npcIds = { 11501, 14324, 14353 }
					}
				}
			},
			{
				-- Stratholme
				instanceId = "Stratholme",
				npcIds = {
					10412, 10405, 10413, 10390, 10398, 10406, 10414, 10391,
					10407, 10400, 10408, 10416, 10393, 10463, 10409, 10417,
					10464, 10411, 10382, 10383, 10381, 10424, 10426, 11043,
					10419, 10421, 10423, 10425, 10418, 10420, 10422, 10441,
					10536
				},
				encounters = {
					{
						-- Stratholme Courier
						encounterId = 11082
					},
					{
						-- Fras Siabi
						encounterId = 11058
					},
					{
						-- Hearthsinger Forresten
						encounterId = 10558
					},
					{
						-- The Unforgiven
						encounterId = 10516,
						npcIds = { 10516, 10387 }
					},
					{
						-- Postmaster Malown
						encounterId = 11143,
						npcIds = { 11143, 11142 }
					},
					{
						-- Timmy the Cruel
						encounterId = 10808
					},
					{
						-- Malor the Zealous
						encounterId = 11032
					},
					{
						-- Cannon Master Willey
						encounterId = 10997,
						npcIds = { 10997, 11054 }
					},
					{
						-- Crimson Hammersmith
						encounterId = 11120
					},
					{
						-- Archivist Galford
						encounterId = 10811
					},
					{
						-- Nerub'enkan
						encounterId = 10437,
						npcIds = { 10437, 10876 },
					},
					{
						-- Baroness Anastari
						encounterId = 10436
					},
					{
						-- Black Guard Swordsmith
						encounterId = 11121
					},
					{
						-- Maleki the Pallid
						encounterId = 10438
					},
					{
						-- Magistrate Barthilas
						encounterId = 10435
					},
					{
						-- Ramstein the Gorger
						encounterId = 10439
					},
					{
						-- Lord Aurius Rivendare
						encounterId = 45412
					}
				}
			},
			{
				-- Blackrock Depths
				instanceId = "BlackrockDepths",
				npcIds = {
					8893, 8901, 8909, 8894, 8902, 8910, 9956, 8895,
					8903, 8911, 8921, 8896, 8904, 8912, 8920, 8897,
					8905, 8913, 8890, 8982, 8906, 8914, 8891, 8899,
					8907, 8915, 8892, 8900, 8908, 8916, 8889, 8922
				},
				encounters = {
					{
						-- High Interrogator Gerstahn
						encounterId = 9018
					},
					{
						-- Houndmaster Grebmar
						encounterId = 9319
					},
					{
						-- Lord Roccor
						encounterId = 9025
					},
					{
						-- Pyromancer Loregrain
						encounterId = 9024
					},
					{
						-- Warder Stilgiss
						encounterId = 9041,
						npcIds = { 9041, 9042 }
					},
					{
						-- Fineous Darkvire
						encounterId = 9056
					},
					{
						-- Lord Incendius
						encounterId = 9017
					},
					{
						-- Bael'Gar
						encounterId = 9016
					},
					{
						-- General Angerforge
						encounterId = 9033
					},
					{
						-- Golem Lord Argelmach
						encounterId = 8983
					},
					{
						-- Hurley Blackbreath
						encounterId = 9537
					},
					{
						-- Ambassador Flamelash
						encounterId = 9156,
						npcIds = { 9156, 9178 }
					},
					{
						-- The Seven
						encounterId = 9039,
						npcIds = { 9034, 9035, 9036, 9037, 9038, 9039, 9040 }
					},
					{
						-- Magmus
						encounterId = 9938
					},
					{
						-- Emperor Thaurissan
						encounterId = 9019,
						npcIds = { 9019, 8929 }
					}
				}
			},
			{
				-- Sunken Temple
				instanceId = "SunkenTemple",
				npcIds = {
					5280, 5267, 5283, 5256, 8336, 5228, 5259, 5277,
					5291, 8438, 5273, 5271, 8384
				},
				encounters = {
					{
						-- Atal'alarion
						encounterId = 8580
					},
					{
						-- Jammal'an the Prophet
						encounterId = 5710,
						npcIds = { 5710, 5711 }
					},
					{
						-- Dreamscythe
						encounterId = 5721
					},
					{
						-- Weaver
						encounterId = 5720
					},
					{
						-- Morphaz
						encounterId = 5719
					},
					{
						-- Hazzas
						encounterId = 5722
					},
					{
						-- Shade of Eranikus
						encounterId = 5709
					}
				}
			},
			{
				-- Maraudon
				instanceId = "Maraudon",
				npcIds = {
					12218, 11792, 12242, 12219, 11793, 13142, 12220, 11794,
					12221, 12206, 11789, 12222, 13718, 12207, 13323, 12223,
					11783, 13696, 12216, 11790, 11784, 12224, 12217, 11791,
					13141, 12243
				},
				encounters = {
					{
						-- Noxxion
						encounterId = 13282
					},
					{
						-- Razorlash
						encounterId = 12258
					},
					{
						-- Lord Vyletongue
						encounterId = 12236
					},
					{
						-- Celebras the Cursed
						encounterId = 12225
					},
					{
						-- Landslide
						encounterId = 12203
					},
					{
						-- Tinkerer Gizlock
						encounterId = 13601
					},
					{
						-- Rotgrip
						encounterId = 13596
					},
					{
						-- Princess Theradras
						encounterId = 12201
					}
				}
			},
			{
				-- Zul'Farrak
				instanceId = "ZulFarrak",
				npcIds = { 5650, 8095, 5649, 8120, 7268, 5648, 7246 },
				encounters = {
					{
						-- Theka the Martyr
						encounterId = 7272
					},
					{
						-- Antu'sul
						encounterId = 8127,
						npcIds = { 8127, 8138, 8156 }
					},
					{
						-- Witch Doctor Zum'rah
						encounterId = 7271
					},
					{
						-- Sergeant Bly
						encounterId = 7604,
						npcIds = {
							7604, 7605, 7789, 7606, 7608, 7607, 7789, 8876,
							8877, 7274, 7796
						}
					},
					{
						-- Hydromancer Velrath
						encounterId = 7795
					},
					{
						-- Gahz'rilla
						encounterId = 7273
					},
					{
						-- Chief Ukorz Sandscalp
						encounterId = 7267,
						npcIds = { 7267, 7797 }
					}
				}
			},
			{
				-- Uldaman
				instanceId = "Uldaman",
				npcIds = {
					4853, 4857, 4861, 7012, 7078, 7175, 7396, 24830,
					4847, 2892, 4855, 4863, 7320, 4848, 4852, 7030,
					4860, 7397, 7011, 7290, 7321, 4849, 4850
				},
				encounters = {
					{
						-- Revelosh
						encounterId = 6910
					},
					{
						-- The Lost Dwarves
						encounterId = 6906,
						npcIds = { 6906, 6907, 6908 }
					},
					{
						-- Ironaya
						encounterId = 7228
					},
					{
						-- Obsidian Sentinel
						encounterId = 7023
					},
					{
						-- Ancient Stone Keeper
						encounterId = 7206
					},
					{
						-- Galgann Firehammer
						encounterId = 7291
					},
					{
						-- Grimlok
						encounterId = 4854
					},
					{
						-- Archaedas
						encounterId = 2748,
						npcIds = { 2748, 7077, 10120, 7076, 7309 }
					}
				}
			},
			{
				-- Razorfen Downs
				instanceId = "RazorfenDowns",
				npcIds = {
					7337, 7341, 7345, 7353, 7342, 7346, 7327, 7335,
					7347, 7328, 7332, 7344, 7348, 7352, 7329
				},
				encounters = {
					{
						-- Tuten'kash
						encounterId = 7355,
						npcIds = { 7355, 7351 },
					},
					{
						-- Plaguemaw the Rotting
						encounterId = 7356
					},
					{
						-- Mordresh Fire Eye
						encounterId = 7357
					},
					{
						-- Glutton
						encounterId = 8567
					},
					{
						-- Amnennar the Coldbringer
						encounterId = 7358
					}
				}
			},
			{
				-- Gnomeregan
				instanceId = "Gnomeregan",
				npcIds = {
					6225, 6206, 6218, 6222, 6226, 6230, 6234, 6207,
					6211, 6219, 6223, 6227, 6212, 6220, 6224, 8035,
					6232, 6391, 6392, 7849, 6329
				},
				encounters = {
					{
						-- Grubbis
						encounterId = 7361,
						npcIds = { 7361, 7998 }
					},
					{
						-- Viscous Fallout
						encounterId = 7079
					},
					{
						-- Electrocutioner 6000
						encounterId = 6235
					},
					{
						-- Crowd Pummeler 9-60
						encounterId = 6229
					},
					{
						-- Dark Iron Ambassador
						encounterId = 6228
					},
					{
						-- Mekgineer Thermaplugg
						encounterId = 7800
					}
				}
			},
			{
				-- The Stockade
				instanceId = "TheStockade",
				npcIds = { 1708, 1706, 1707, 1711, 1715 },
				encounters = {
					{
						-- Randolph Moloch
						encounterId = 46383
					},
					{
						-- Lord Overheat
						encounterId = 46264
					},
					{
						-- Hogger
						encounterId = 46254
					}
				}
			},
			{
				-- Razorfen Kraul
				instanceId = "RazorfenKraul",
				npcIds = {
					4512, 6035, 4520, 4532, 4517, 4436, 4541, 4514,
					4437, 4511, 4530, 4519, 4523, 4442, 4531, 4535,
					4623, 4516, 4438, 4522, 4515
				},
				encounters = {
					{
						-- Roogug
						encounterId = 6168
					},
					{
						-- Aggem Thorncurse
						encounterId = 4424
					},
					{
						-- Death Speaker Jargba
						encounterId = 4428
					},
					{
						-- Overlord Ramtusk
						encounterId = 4420
					},
					{
						-- Agathelos the Raging
						encounterId = 4422
					},
					{
						-- Charlga Razorflank
						encounterId = 4421
					}
				}
			},
			{
				-- Blackfathom Deeps
				instanceId = "BlackfathomDeeps",
				npcIds = {
					4799, 4807, 4811, 4815, 4819, 4978, 4827, 4812,
					4820, 4805, 4813, 4825, 4798, 4810, 4814, 4818
				},
				encounters = {
					{
						-- Ghamoo-ra
						encounterId = 4887
					},
					{
						-- Lady Sarevess
						encounterId = 4831
					},
					{
						-- Gelihast
						encounterId = 6243
					},
					{
						-- Lorgus Jett
						encounterId = 12902
					},
					{
						-- Baron Aquanis
						encounterId = 12876
					},
					{
						-- Old Serra'kis
						encounterId = 4830
					},
					{
						-- Twilight Lord Kelris
						encounterId = 4832
					},
					{
						-- Aku'mai
						encounterId = 4829
					}
				}
			},
			{
				-- Wailing Caverns
				instanceId = "WailingCaverns",
				npcIds = {
					5055, 3840, 3835, 5761, 5756, 5056, 5755, 5048
				},
				encounters = {
					{
						-- Lady Anacondra
						encounterId = 3671
					},
					{
						-- Lord Cobrahn
						encounterId = 3669
					},
					{
						-- Kresh
						encounterId = 3653
					},
					{
						-- Lord Pythas
						encounterId = 3670
					},
					{
						-- Skum
						encounterId = 3674
					},
					{
						-- Lord Serpentis
						encounterId = 3673
					},
					{
						-- Verdan the Everliving
						encounterId = 5775
					},
					{
						-- Mutanus the Devourer
						encounterId = 3654
					}
				}
			},
			{
				-- Ragefire Chasm
				instanceId = "RagefireChasm",
				npcIds = {  },
				encounters = {
					{
						-- Adarogg
						encounterId = 61408
					},
					{
						-- Dark Shaman Koranthal
						encounterId = 61412
					},
					{
						-- Slagmaw
						encounterId = 61463
					},
					{
						-- Lava Guard Gordoth
						encounterId = 61528
					}
				}
			}
		}
	}
}

-- Fixup
for _, instanceSet in ipairs(BOSS_NOTES_ENCOUNTERS) do
	instanceSet.name = L[instanceSet.instanceSetId]
	for _, instance in ipairs(instanceSet.instances) do
		instance.name = L["instance:" .. instance.instanceId]
		instance.raid = instanceSet.raid
		if not instance.npcIds then
			instance.npcIds = { }
		end
		for _, encounter in ipairs(instance.encounters) do
			encounter.name = L["encounter:" .. encounter.encounterId]
			if not encounter.npcIds then
				encounter.npcIds = { encounter.encounterId }
			end
		end
	end
	table.sort(instanceSet.instances, function (a, b) return a.name <= b.name end)
end