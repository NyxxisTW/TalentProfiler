SLASH_TALENTPROFILER1 = "/tp"
BINDING_HEADER_TALENTPROFILER = "Talent Profiler"

local Addon = CreateFrame("frame")

TALENT_PROFILES = {}
TALENT_PROFILE_ORDER = {}
TP_CONFIG = {
	SyncWithCurrentTalents = false,
	ContentArrow = true,
	Debug = true,
}

local PlayerClass
local TP_DragPoint, TP_DragX, TP_DragY
TP_MaxLevel = false
TP_MaxTalentPoints = 51

local PROFILE_TO_DELETE = nil
local PROFILE_TO_DELETE_FRAME = nil
local SelectedProfileFrame = nil

local LoadingTalents = false
local TalentFramesCreated = false

local DisplayProfile = {
	[1] = {},
	[2] = {},
	[3] = {},
}
local CurrentProfile = {
	[1] = {},
	[2] = {},
	[3] = {},
}

local Specializations = {
	Druid = {
		Spec1 = "Balance",
		Spec2 = "Feral",
		Spec3 = "Restoration",
	},
	Hunter = {
		Spec1 = "Beast Mastery",
		Spec2 = "Marksmanship",
		Spec3 = "Survival",
	},
	Mage = {
		Spec1 = "Arcane",
		Spec2 = "Fire",
		Spec3 = "Frost",
	},
	Paladin = {
		Spec1 = "Holy",
		Spec2 = "Protection",
		Spec3 = "Retribution",
	},
	Priest = {
		Spec1 = "Discipline",
		Spec2 = "Holy",
		Spec3 = "Shadow",
	},
	Rogue = {
		Spec1 = "Assassination",
		Spec2 = "Combat",
		Spec3 = "Subtlety",
	},
	Shaman = {
		Spec1 = "Elemental",
		Spec2 = "Enhancement",
		Spec3 = "Restoration",
	},
	Warlock = {
		Spec1 = "Affliction",
		Spec2 = "Demonology",
		Spec3 = "Destruction",
	},
	Warrior = {
		Spec1 = "Arms",
		Spec2 = "Fury",
		Spec3 = "Protection",
	},
}

local Icons = {
	Druid = {
		Spec1 = "Interface\\Icons\\spell_nature_starfall",
		Spec2 = "Interface\\Icons\\ability_racial_bearform",
		Spec3 = "Interface\\Icons\\spell_nature_healingtouch",
	},
	Hunter = {
		Spec1 = "Interface\\Icons\\ability_hunter_beasttaming",
		Spec2 = "Interface\\Icons\\ability_marksmanship",
		Spec3 = "Interface\\Icons\\ability_hunter_swiftstrike",
	},
	Mage = {
		Spec1 = "Interface\\Icons\\spell_holy_magicalsentry",
		Spec2 = "Interface\\Icons\\spell_fire_flamebolt",
		Spec3 = "Interface\\Icons\\spell_frost_frostbolt02",
	},
	Paladin = {
		Spec1 = "Interface\\Icons\\spell_holy_holybolt",
		Spec2 = "Interface\\Icons\\spell_holy_devotionaura",
		Spec3 = "Interface\\Icons\\spell_holy_auraoflight",
	},
	Priest = {
		Spec1 = "Interface\\Icons\\spell_holy_powerwordshield",
		Spec2 = "Interface\\Icons\\spell_holy_holybolt",
		Spec3 = "Interface\\Icons\\spell_shadow_shadowwordpain",
	},
	Rogue = {
		Spec1 = "Interface\\Icons\\ability_rogue_eviscerate",
		Spec2 = "Interface\\Icons\\ability_backstab",
		Spec3 = "Interface\\Icons\\ability_stealth",
	},
	Shaman = {
		Spec1 = "Interface\\Icons\\spell_nature_lightning",
		Spec2 = "Interface\\Icons\\spell_nature_lightningshield",
		Spec3 = "Interface\\Icons\\spell_nature_magicimmunity",
	},
	Warlock = {
		Spec1 = "Interface\\Icons\\spell_shadow_deathcoil",
		Spec2 = "Interface\\Icons\\spell_shadow_metamorphosis",
		Spec3 = "Interface\\Icons\\spell_shadow_rainoffire",
	},
	Warrior = {
		Spec1 = "Interface\\Icons\\ability_warrior_savageblow",
		Spec2 = "Interface\\Icons\\ability_warrior_innerrage",
		Spec3 = "Interface\\Icons\\ability_warrior_defensivestance",
	},
}

local Backgrounds = {
	Druid = {
		Spec1 = "Interface\\TalentFrame\\DruidBalance",
		Spec2 = "Interface\\TalentFrame\\DruidFeralCombat",
		Spec3 = "Interface\\TalentFrame\\DruidRestoration",
	},
	Hunter = {
		Spec1 = "Interface\\TalentFrame\\HunterBeastMastery",
		Spec2 = "Interface\\TalentFrame\\HunterMarksmanship",
		Spec3 = "Interface\\TalentFrame\\HunterSurvival",
	},
	Mage = {
		Spec1 = "Interface\\TalentFrame\\MageArcane",
		Spec2 = "Interface\\TalentFrame\\MageFire",
		Spec3 = "Interface\\TalentFrame\\MageFrost",
	},
	Paladin = {
		Spec1 = "Interface\\TalentFrame\\PaladinHoly",
		Spec2 = "Interface\\TalentFrame\\PaladinProtection",
		Spec3 = "Interface\\TalentFrame\\PaladinCombat",
	},
	Priest = {
		Spec1 = "Interface\\TalentFrame\\PriestDiscipline",
		Spec2 = "Interface\\TalentFrame\\PriestHoly",
		Spec3 = "Interface\\TalentFrame\\PriestShadow",
	},
	Rogue = {
		Spec1 = "Interface\\TalentFrame\\RogueAssassination",
		Spec2 = "Interface\\TalentFrame\\RogueCombat",
		Spec3 = "Interface\\TalentFrame\\RogueSubtlety",
	},
	Shaman = {
		Spec1 = "Interface\\TalentFrame\\ShamanElementalCombat",
		Spec2 = "Interface\\TalentFrame\\ShamanEnhancement",
		Spec3 = "Interface\\TalentFrame\\ShamanRestoration",
	},
	Warlock = {
		Spec1 = "Interface\\TalentFrame\\WarlockCurses",
		Spec2 = "Interface\\TalentFrame\\WarlockSummoning",
		Spec3 = "Interface\\TalentFrame\\WarlockDestruction",
	},
	Warrior = {
		Spec1 = "Interface\\TalentFrame\\WarriorArms",
		Spec2 = "Interface\\TalentFrame\\WarriorFury",
		Spec3 = "Interface\\TalentFrame\\WarriorProtection",
	},
}

local TalentDependencies = {
	Druid = {
		[1] = {
			[3] = {
				index = 2,
				value = 1,
			},
			[9] = {
				index = 6,
				value = 3,
			},
			[11] = {
				index = 5,
				value = 5,
			},
			[15] = {
				index = 13,
				value = 1,
			},
		},
		[2] = {
			[11] = {
				index = 8,
				value = 3,
			},
			[12] = {
				index = 8,
				value = 3,
			},
			[15] = {
				index = 10,
				value = 3,
			},
		},
		[3] = {
			[10] = {
				index = 3,
				value = 5,
			},
			[11] = {
				index = 6,
				value = 1,
			},
			[13] = {
				index = 9,
				value = 3,
			},
			[14] = {
				index = 13,
				value = 5,
			},
		},
	},
	Hunter = {
		[1] = {
			[15] = {
				index = 11,
				value = 5,
			},
			[16] = {
				index = 13,
				value = 1,
			},
		},
		[2] = {
			[9] = {
				index = 4,
				value = 5,
			},
			[14] = {
				index = 11,
				value = 3,
			},
		},
		[3] = {
			[14] = {
				index = 9,
				value = 1,
			},
			[16] = {
				index = 13,
				value = 3,
			},
		},
	},
	Mage = {
		[1] = {
			[14] = {
				index = 9,
				value = 1,
			},
			[15] = {
				index = 13,
				value = 1,
			},
			[16] = {
				index = 15,
				value = 5,
			},
			[17] = {
				index = 14,
				value = 3,
			},
			[18] = {
				index = 17,
				value = 3,
			},
		},
		[2] = {
			[14] = {
				index = 8,
				value = 1,
			},
			[16] = {
				index = 13,
				value = 3,
			},
		},
		[3] = {
			[13] = {
				index = 6,
				value = 2,
			},
			[17] = {
				index = 14,
				value = 1,
			},
		},
	},
	Paladin = {
		[1] = {
			[11] = {
				index = 9,
				value = 5,
			},
			[14] = {
				index = 11,
				value = 1,
			},
		},
		[2] = {
			[8] = {
				index = 2,
				value = 5,
			},
			[15] = {
				index = 12,
				value = 1,
			},
		},
		[3] = {
			[14] = {
				index = 7,
				value = 5,
			},
			[15] = {
				index = 13,
				value = 1,
			},
		},
	},
	Priest = {
		[1] = {
			[13] = {
				index = 5,
				value = 3
			},
			[15] = {
				index = 12,
				value = 5
			},
		},
		[2] = {
			[11] = {
				index = 5,
				value = 5
			},
			[16] = {
				index = 13,
				value = 1
			},
		},
		[3] = {
			[12] = {
				index = 6,
				value = 2
			},
			[14] = {
				index = 13,
				value = 1
			},
			[16] = {
				index = 13,
				value = 1
			}
		},
	},
	Rogue = {
		[1] = {
			[9] = {
				index = 3,
				value = 5,
			},
			[14] = {
				index = 12,
				value = 1,
			},
		},
		[2] = {
			[8] = {
				index = 5,
				value = 5,
			},
			[12] = {
				index = 6,
				value = 5,
			},
			[17] = {
				index = 14,
				value = 1,
			},
		},
		[3] = {
			[15] = {
				index = 11,
				value = 3,
			},
			[17] = {
				index = 13,
				value = 1,
			},
		},
	},
	Shaman = {
		[1] = {
			[14] = {
				index = 8,
				value = 5,
			},
			[15] = {
				index = 13,
				value = 1,
			},
		},
		[2] = {
			[8] = {
				index = 6,
				value = 3,
			},
			[9] = {
				index = 4,
				value = 5,
			},
			[16] = {
				index = 13,
				value = 3,
			},
		},
		[3] = {
			[15] = {
				index = 10,
				value = 5,
			},
		},
	},
	Warlock = {
		[1] = {
			[13] = {
				index = 9,
				value = 1,
			},
			[14] = {
				index = 13,
				value = 1,
			},
			[15] = {
				index = 12,
				value = 1,
			},
		},
		[2] = {
			[10] = {
				index = 8,
				value = 1,
			},
			[14] = {
				index = 11,
				value = 5,
			},
			[15] = {
				index = 13,
				value = 1,
			},
		},
		[3] = {
			[12] = {
				index = 9,
				value = 2,
			},
			[14] = {
				index = 7,
				value = 5,
			},
			[16] = {
				index = 13,
				value = 5,
			},
		},
	},
	Warrior = {
		[1] = {
			[8] = {
				index = 5,
				value = 5,
			},
			[9] = {
				index = 3,
				value = 3,
			},
			[11] = {
				index = 9,
				value = 3,
			},
			[18] = {
				index = 13,
				value = 1,
			},
		},
		[2] = {
			[16] = {
				index = 11,
				value = 5,
			},
			[17] = {
				index = 13,
				value = 1,
			},
		},
		[3] = {
			[6] = {
				index = 3,
				value = 2,
			},
			[7] = {
				index = 1,
				value = 5,
			},
			[17] = {
				index = 14,
				value = 1,
			},
		},
	},
}


local START_COLOR = "|CFF"
local END_COLOR = "|R"
local COLOR = "FF00FF"

local CLASS_COLORS = {
	Druid = "|CFFFF7D0A",
	Hunter = "|CFFABD473",
	Mage = "|CFF69CCF0",
	Paladin = "|CFFf58CBA",
	Priest = "|CFFFFFFFF",
	Rogue = "|CFFFFF569",
	Shaman = "|CFF0070DE",
	Warlock = "|CFF9482C9",
	Warrior = "|CFFC79C6E",
}


----------------------------------------------------------------
-------------------- DEFAULT CHAT FUNCTION ---------------------
----------------------------------------------------------------


local function Print(msg, r, g, b, a)
	DEFAULT_CHAT_FRAME:AddMessage(CLASS_COLORS[PlayerClass].."[Talent Profiler]: "..END_COLOR..tostring(msg), r, g, b, a)
end

local function DPrint(msg, r, g, b, a)
	if (TP_CONFIG) then
		DEFAULT_CHAT_FRAME:AddMessage(CLASS_COLORS[PlayerClass].."[Talent Profiler]: "..END_COLOR..tostring(msg), r, g, b, a)
	end
end


----------------------------------------------------------------
------------------------ BASIC GETTERS -------------------------
----------------------------------------------------------------


local function GetRank(tree, talent)
	local _,_,_,_,rank = GetTalentInfo(tree, talent)
	return rank
end

local function GetMaxRank(tree, talent)
	local _,_,_,_,_,maxRank = GetTalentInfo(tree, talent)
	return maxRank
end

local function GetTier(tree, talent)
	local _,_,tier,_,_,_ = GetTalentInfo(tree, talent)
	return tier
end

local function GetPointsSpent(profile)
	local points = 0
	for tree = 1, 3 do
		for talent in profile[tree] do
			points = points + profile[tree][talent]
		end
	end
	return points
end

local function GetPointsSpentInTree(profile, tree)
	local points = 0
	for talent in profile[tree] do
		points = points + profile[tree][talent]
	end
	return points
end

local function GetPointsSpentSync()
	local points = {}
	for i = 1, 3 do
		local _,_,spent = GetTalentTabInfo(i)
		points[i] = spent
	end
	return points[1], points[2], points[3]
end

local function GetUnspentTalentPointsSync()
	if (TP_MaxLevel) then
		return TP_MaxTalentPoints
	else
		local tree1, tree2, tree3 = GetPointsSpentSync()
		local unspent = UnitLevel("player") - tree1 - tree2 - tree3 - 9
		return unspent
	end
end

local function GetTalentFrame(tree, talent)
	return getglobal("TP_Talent_"..tree.."_"..talent)
end

local function GetNextProfileNumber()
	local index = 1
	for p in TALENT_PROFILE_ORDER do
		index = index + 1
	end
	return index
end


----------------------------------------------------------------
----------------- BASIC OPERATIONS ON PROFILES -----------------
----------------------------------------------------------------


local function Swap(table, pos1, pos2)
	table[pos1], table[pos2] = table[pos2], table[pos1]
	return table
end

local function CopyTree(src, dst, tree)
	for talent in src[tree] do
		dst[tree][talent] = src[tree][talent]
	end
end

local function CopyProfile(src, dst)
	for tree = 1, 3 do
		for talent in src[tree] do
			dst[tree][talent] = src[tree][talent]
		end
	end
end

local function SaveTree(profileName, tree)
	TALENT_PROFILES[profileName][tree] = {}
	local talent = 1
	while true do
		local talentName,_,_,_,rank = GetTalentInfo(tree, talent)
		if (talentName == nil) then break end
		TALENT_PROFILES[profileName][tree][talent] = rank
		talent = talent + 1
	end
end

local function SaveTalents(profileName)
	if (not TALENT_PROFILES) then TALENT_PROFILES = {} end
	TALENT_PROFILES[profileName] = {}
	SaveTree(profileName, 1)
	SaveTree(profileName, 2)
	SaveTree(profileName, 3)
end

local function SaveProfile(profileName)
	if (not TALENT_PROFILES) then TALENT_PROFILES = {} end
	TALENT_PROFILES[profileName] = {}
	for tree = 1, 3 do
		TALENT_PROFILES[profileName][tree] = {}
		for index in DisplayProfile[tree] do
			TALENT_PROFILES[profileName][tree][index] = DisplayProfile[tree][index]
		end
	end
end

local function PickTalents(profile, tree)
	local n = table.getn(profile[tree])
	local limit = 5
	for talent = 1, n do
		local _,_,_,_,rank = GetTalentInfo(tree, talent)
		if (rank < profile[tree][talent]) then
			LearnTalent(tree, talent)
			limit = limit - 1
			if (limit == 0) then break end
		end
	end
end

local function SimpleLoad()
	CopyProfile(DisplayProfile, CurrentProfile)
	LoadingTalents = true
	PickTalents(DisplayProfile, 1)
	PickTalents(DisplayProfile, 2)
	PickTalents(DisplayProfile, 3)
end

local function IsProfileLoaded(profile)
	for tree = 1, 3 do
		for talent in profile[tree] do
			local rank = GetRank(tree, talent)
			if (profile[tree][talent] ~= rank) then
				return false
			end
		end
	end
	return true
end





----------------------------------------------------------------
------------------- PROFILE OPERATION CHECKS -------------------
----------------------------------------------------------------


local function HasFreePoints(pointsTotal)
	if (TP_MaxLevel) then
		return 60 - pointsTotal > 9
	else
		return UnitLevel("player") - pointsTotal > 9
	end
end

local function HasGoodBasis(targetProfile)
	for tree = 1, 3 do
		for talent in targetProfile[tree] do
			local _,_,_,_,rank = GetTalentInfo(tree, talent)
			if (rank > targetProfile[tree][talent]) then
				return false
			end
		end
	end
	return true
end

local function CanPointBeRemoved(profile, tree, talent)
	local highestTier = 1
	local lastTalent = nil
	for t in profile[tree] do
		local tier = GetTier(tree, t)
		if (profile[tree][t] > 0 and tier > highestTier) then
			highestTier = tier
		end
	end

	local pointsPerTiers = {}
	for t in profile[tree] do
		pointsPerTiers[GetTier(tree, t)] = (pointsPerTiers[GetTier(tree, t)] or 0) + profile[tree][t]
	end
	pointsPerTiers[GetTier(tree, talent)] = pointsPerTiers[GetTier(tree, talent)] - 1

	local required = 5
	local stairs = {}
	for tier = 1, highestTier - 1 do
		local sum = 0
		for t = 1, tier do
			sum = sum + pointsPerTiers[t]
		end
		if (sum < required) then DPrint("Point can't be removed") return false end
		required = required + 5
	end
	return true
end

local function CompareProfiles(profile1, profile2)
	for tree = 1, 3 do
		for tlaent in profile1[tree] do
			if (profile1[tree][talent] ~= profile2[tree][talent]) then
				return false
			end
		end
	end
	return true
end


----------------------------------------------------------------
--------------------------- BORDER -----------------------------
----------------------------------------------------------------


local function CreateBorder(frame, r, g, b, a, onEnter, onLeave)
	local border = {}
	local highlight = {}

	border.Top = frame:CreateTexture(nil, "ARTWORK")
	border.Top:SetWidth(frame:GetWidth())
	border.Top:SetHeight(3)
	border.Top:SetPoint("TOP", 0, 0)
	border.Top:SetTexture(0.15, 0.15, 0.15, 1)

	border.Left = frame:CreateTexture(nil, "ARTWORK")
	border.Left:SetWidth(3)
	border.Left:SetHeight(frame:GetHeight())
	border.Left:SetPoint("LEFT", 0, 0)
	border.Left:SetTexture(0.15, 0.15, 0.15, 1)

	border.Bottom = frame:CreateTexture(nil, "ARTWORK")
	border.Bottom:SetWidth(frame:GetWidth())
	border.Bottom:SetHeight(3)
	border.Bottom:SetPoint("BOTTOM", 0, 0)
	border.Bottom:SetTexture(0.15, 0.15, 0.15, 1)

	border.Right = frame:CreateTexture(nil, "ARTWORK")
	border.Right:SetWidth(3)
	border.Right:SetHeight(frame:GetHeight())
	border.Right:SetPoint("RIGHT", 0, 0)
	border.Right:SetTexture(0.15, 0.15, 0.15, 1)

	highlight.Top = frame:CreateTexture(nil, "OVERLAY")
	highlight.Top:SetWidth(frame:GetWidth())
	highlight.Top:SetHeight(0.6)
	highlight.Top:SetPoint("TOP", 0, 0)
	highlight.Top:SetTexture(r, g, b, a)

	highlight.Left = frame:CreateTexture(nil, "OVERLAY")
	highlight.Left:SetWidth(0.6)
	highlight.Left:SetHeight(frame:GetHeight())
	highlight.Left:SetPoint("LEFT", 0, 0)
	highlight.Left:SetTexture(r, g, b, a)

	highlight.Bottom = frame:CreateTexture(nil, "OVERLAY")
	highlight.Bottom:SetWidth(frame:GetWidth())
	highlight.Bottom:SetHeight(0.6)
	highlight.Bottom:SetPoint("BOTTOM", 0, 0)
	highlight.Bottom:SetTexture(r, g, b, a)

	highlight.Right = frame:CreateTexture(nil, "OVERLAY")
	highlight.Right:SetWidth(0.6)
	highlight.Right:SetHeight(frame:GetHeight())
	highlight.Right:SetPoint("RIGHT", 0, 0)
	highlight.Right:SetTexture(r, g, b, a)

	frame.Border = border
	frame.Highlight = highlight

	if (onEnter) then frame:SetScript("OnEnter", onEnter) end
	if (onLeave) then frame:SetScript("OnLeave", onLeave) end
end

local function CreateThinBorder(frame, r, g, b, a, onEnter, onLeave)
	local highlight = {}

	highlight.Top = frame:CreateTexture(nil, "OVERLAY")
	highlight.Top:SetWidth(frame:GetWidth())
	highlight.Top:SetHeight(0.6)
	highlight.Top:SetPoint("TOP", 0, 0)
	highlight.Top:SetTexture(r, g, b, a)

	highlight.Left = frame:CreateTexture(nil, "OVERLAY")
	highlight.Left:SetWidth(0.6)
	highlight.Left:SetHeight(frame:GetHeight())
	highlight.Left:SetPoint("LEFT", 0, 0)
	highlight.Left:SetTexture(r, g, b, a)

	highlight.Bottom = frame:CreateTexture(nil, "OVERLAY")
	highlight.Bottom:SetWidth(frame:GetWidth())
	highlight.Bottom:SetHeight(0.6)
	highlight.Bottom:SetPoint("BOTTOM", 0, 0)
	highlight.Bottom:SetTexture(r, g, b, a)

	highlight.Right = frame:CreateTexture(nil, "OVERLAY")
	highlight.Right:SetWidth(0.6)
	highlight.Right:SetHeight(frame:GetHeight())
	highlight.Right:SetPoint("RIGHT", 0, 0)
	highlight.Right:SetTexture(r, g, b, a)

	frame.Highlight = highlight

	if (onEnter) then frame:SetScript("OnEnter", onEnter) end
	if (onLeave) then frame:SetScript("OnLeave", onLeave) end
end

local function SetHighlightColor(frame, r, g, b, a)
	local highlight = frame.Highlight
	highlight.Top:SetTexture(r, g, b, a)
	highlight.Left:SetTexture(r, g, b, a)
	highlight.Bottom:SetTexture(r, g, b, a)
	highlight.Right:SetTexture(r, g, b, a)
end


----------------------------------------------------------------
-------------------------- COUNTER -----------------------------
----------------------------------------------------------------


local function CreateCounterFrame(parent, rank, r, g, b, a)
	local frame = CreateFrame("FRAME", nil, parent)
	frame:SetWidth(6)
	frame:SetHeight(10)
	frame:SetPoint("BOTTOMRIGHT", 2, -2)
	frame:SetToplevel(true)
	parent.Counter = frame

	local text = frame:CreateFontString(nil, "OVERLAY")
	text:SetFont("Interface\\AddOns\\TalentProfiler\\Arial-Nova.ttf", 11, "THICKOUTLINE")
	text:SetPoint("CENTER", -0.49, 0)
	text:SetText(rank)
	text:SetTextColor(r, g, b, a)
	parent.Counter.Text = text
end


----------------------------------------------------------------
------------------------ UPDATE VIEW ---------------------------
----------------------------------------------------------------


local function UpdateTalentView(profile, tree, talent, pointsTotal, pointsInTree)
	local tier = GetTier(tree, talent)
	local maxRank = GetMaxRank(tree, talent)
	local frame = GetTalentFrame(tree, talent)
	local counter = frame.Counter.Text
	local texture = frame.Texture
	local rank = profile[tree][talent]

	if (pointsInTree >= (tier - 1) * 5) then
		if (rank == maxRank) then
			SetHighlightColor(frame, 1, 1, 0, 1)
		elseif (HasFreePoints(pointsTotal) or rank > 0) then
			SetHighlightColor(frame, 0, 1, 0, 1)
		else
			SetHighlightColor(frame, 0, 0, 0, 1)
		end
	else
		SetHighlightColor(frame, 0, 0, 0, 1)
	end
	if (rank == maxRank) then
		counter:SetTextColor(1, 1, 0, 1)
	elseif (rank > 0) then
		counter:SetTextColor(0, 1, 0, 1)
	else
		counter:SetTextColor(1, 1, 1, 1)
	end
	counter:SetText(rank)
	texture:SetDesaturated(rank == 0)
end

local function UpdateTreeView(profile, tree)
	local pointsTotal = GetPointsSpent(profile)
	local pointsInTree = GetPointsSpentInTree(profile, tree)
	for talent in profile[tree] do
		UpdateTalentView(profile, tree, talent, pointsTotal, pointsInTree)
	end
end

local function UpdateView(profile)
	local pointsTotal = GetPointsSpent(profile)
	for tree = 1, 3 do
		local pointsInTree = GetPointsSpentInTree(profile, tree)
		for talent in profile[tree] do
			UpdateTalentView(profile, tree, talent, pointsTotal, pointsInTree)
		end
	end
end

local function UpdatePointsSpentTrackers(profile)
	local t1 = GetPointsSpentInTree(profile, 1)
	local t2 = GetPointsSpentInTree(profile, 2)
	local t3 = GetPointsSpentInTree(profile, 3)
	local pointsRemaining
	if (TP_MaxLevel) then
		pointsRemaining = TP_MaxTalentPoints - GetPointsSpent(DisplayProfile)
	else
		pointsRemaining = UnitLevel("player") - 9 - GetPointsSpent(DisplayProfile)
	end
	TP_Tree1_Description_PointsSpent:SetText("Points spent: "..t1)
	TP_Tree2_Description_PointsSpent:SetText("Points spent: "..t2)
	TP_Tree3_Description_PointsSpent:SetText("Points spent: "..t3)
	TP_Profiles_PointsRemaining_Text:SetText("Points remaining: "..pointsRemaining)
	TP_Profiles_PointsRemaining_Summary:SetText("("..t1.."/"..t2.."/"..t3..")")
end


----------------------------------------------------------------
----------------------- UPDATE VIEW SYNC -----------------------
----------------------------------------------------------------


local function GetPointsSpentInTreeSync(tree)
	local points = 0
	local talent = 1
	while true do
		local talentName,_,_,_,rank = GetTalentInfo(tree, talent)
		if (talentName == nil) then break end
		points = points + rank
		talent = talent + 1
	end
	return points
end

local function UpdateTalentViewSync(tree, talent, pointsInTree, tier, rank, maxRank)
	local frame = GetTalentFrame(tree, talent)
	local counter = frame.Counter.Text
	local texture = frame.Texture

	if (pointsInTree >= (tier - 1) * 5) then
		if (rank == maxRank) then
			SetHighlightColor(frame, 1, 1, 0, 1)
		elseif (GetUnspentTalentPointsSync() > 0 or rank > 0) then
			SetHighlightColor(frame, 0, 1, 0, 1)
		else
			SetHighlightColor(frame, 0, 0, 0, 1)
		end
	else
		SetHighlightColor(frame, 0, 0, 0, 1)
	end
	if (rank == maxRank) then
		counter:SetTextColor(1, 1, 0, 1)
	elseif (rank > 0) then
		counter:SetTextColor(0, 1, 0, 1)
	else
		counter:SetTextColor(1, 1, 1, 1)
	end
	counter:SetText(rank)
	texture:SetDesaturated(rank == 0)
end

local function UpdateTreeViewSync(tree)
	local pointsInTree = GetPointsSpentInTreeSync(tree)
	local talent = 1
	while true do
		local talentName,_,tier,_,rank, maxRank = GetTalentInfo(tree, talent)
		if (talentName == nil) then break end
		UpdateTalentViewSync(tree, talent, pointsInTree, tier, rank, maxRank)
		talent = talent + 1
	end
	getglobal("TP_Tree"..tree.."_Description_PointsSpent"):SetText("Points spent: "..pointsInTree)
end

local function SyncDisplayProfile()
	for tree = 1, 3 do
		for talent in DisplayProfile[tree] do
			local _,_,_,_,rank = GetTalentInfo(tree, talent)
			DisplayProfile[tree][talent] = rank
		end
	end
end

local function UpdateViewSync()
	SyncDisplayProfile()
	for tree = 1, 3 do
		UpdateTreeViewSync(tree)
	end
end

local function UpdatePointsSpentTrackersSync()
	local t1 = GetPointsSpentInTreeSync(1)
	local t2 = GetPointsSpentInTreeSync(2)
	local t3 = GetPointsSpentInTreeSync(3)
	TP_Tree1_Description_PointsSpent:SetText("Points spent: "..t1)
	TP_Tree2_Description_PointsSpent:SetText("Points spent: "..t2)
	TP_Tree3_Description_PointsSpent:SetText("Points spent: "..t3)
	TP_Profiles_PointsRemaining_Text:SetText("Points remaining: "..GetUnspentTalentPointsSync())
	TP_Profiles_PointsRemaining_Summary:SetText("("..t1.."/"..t2.."/"..t3..")")
end


----------------------------------------------------------------
--------------------- TALENT FRAME EVENTS ----------------------
----------------------------------------------------------------


local function HasMissingDependecny(tree, talent)
	if (TalentDependencies[PlayerClass][tree][talent] == nil) then
		return false
	end
	local index = TalentDependencies[PlayerClass][tree][talent].index
	local value = TalentDependencies[PlayerClass][tree][talent].value
	if (DisplayProfile[tree][index] < value) then
		DPrint("Missing dependency ("..tree..", "..index..")")
		return true
	end
	return false
end

local function MakesMissingDependecny(tree, talent)
	for dependency in TalentDependencies[PlayerClass][tree] do
		if ((DisplayProfile[tree][dependency] > 0) and
			(TalentDependencies[PlayerClass][tree][dependency].index == talent))
		then
			DPrint("Missing dependency ("..tree..", "..dependency..")")
			return true
		end
	end
	return false
end

local function TalentFrame_OnMouseDown()
	local profile = DisplayProfile
	local tree = self.Tree
	local talent = self.Talent

	if (arg1 == "LeftButton") then
		if (not HasFreePoints(GetPointsSpent(profile))) then return end
		if (profile[tree][talent] >= GetMaxRank(tree, talent)) then return end
		if (not IsControlKeyDown()) then
			if (HasMissingDependecny(tree, talent)) then return end
			if (GetPointsSpentInTree(profile, tree) < (GetTier(tree, talent) - 1) * 5) then return end
		end
		profile[tree][talent] = profile[tree][talent] + 1
		UpdateView(profile)
		UpdatePointsSpentTrackers(profile)
	elseif (arg1 == "RightButton") then
		if (profile[tree][talent] <= 0) then return end
		if (not IsControlKeyDown()) then
			if (MakesMissingDependecny(tree, talent)) then return end
			if (not CanPointBeRemoved(profile, tree, talent)) then return end
		end
		profile[tree][talent] = profile[tree][talent] - 1
		UpdateView(profile)
		UpdatePointsSpentTrackers(profile)
	end
end

local function TalentFrame_OnEnter()
	SetHighlightColor(self, 1, 0, 1, 1)
	local tree = self.Tree
	local talent = self.Talent
	if (TalentDependencies[PlayerClass][tree][talent]) then
		local dTalent = TalentDependencies[PlayerClass][tree][talent].index
		local dFrame = getglobal("TP_Talent_"..tree.."_"..dTalent)
		SetHighlightColor(dFrame, 1, 0, 0, 1)
	end
	GameTooltip_SetDefaultAnchor(GameTooltip, UIParent)
	GameTooltip:SetTalent(tree, talent)
	GameTooltip:Show()
end

local function TalentFrame_OnLeave()
	GameTooltip:Hide()
	local profile = DisplayProfile
	local tree = self.Tree
	local talent = self.Talent
	local pointsTotal = GetPointsSpent(profile)
	local hasFreePoints
	if (TP_MaxLevel) then
		hasFreePoints = TP_MaxTalentPoints - pointsTotal > 10
	else
		hasFreePoints = UnitLevel("player") - pointsTotal > 10
	end
	local pointsInTree = GetPointsSpentInTree(profile, tree)
	if (TalentDependencies[PlayerClass][tree][talent]) then
		local dTalent = TalentDependencies[PlayerClass][tree][talent].index
		local dFrame = getglobal("TP_Talent_"..tree.."_"..dTalent)
		if (pointsInTree >= (GetTier(tree, talent) - 1) * 5) then
			local dRank = DisplayProfile[tree][dTalent]
			if (dRank == GetMaxRank(tree, dTalent)) then
				SetHighlightColor(dFrame, 1, 1, 0, 1)
			elseif (GetUnspentTalentPointsSync() > 0 or dRank > 0) then
				SetHighlightColor(dFrame, 0, 1, 0, 1)
			else
				SetHighlightColor(dFrame, 0, 0, 0, 1)
			end
		else
			SetHighlightColor(dFrame, 0, 0, 0, 1)
		end
	end
	UpdateTalentView(profile, tree, talent, pointsTotal, pointsInTree, hasFreePoints)
end


----------------------------------------------------------------
-------------------- CREATE TALENT FRAMES ----------------------
----------------------------------------------------------------


local function CreateTalentFrames()
	for tree = 1, 3 do
		local points = GetPointsSpentInTreeSync(tree)
		local talent = 1
		while true do
			local talentName, icon, tier, column, rank, maxRank = GetTalentInfo(tree, talent)
			if (talentName == nil) then if (talent == 1) then return false end break end

			DisplayProfile[tree][talent] = rank

			local x = 11 + 40 * (column - 1)
			local y = -34 -11 - 40 * (tier - 1)

			local parent = getglobal("TP_Tree"..tree)

			local button = CreateFrame("BUTTON", "TP_Talent_"..tree.."_"..talent, parent)
			button:SetWidth(32)
			button:SetHeight(32)
			button:SetPoint("TOPLEFT", x, y)
			button:RegisterForClicks("RightButtonDown", "LeftButtonDown")
			button:SetScript("OnMouseDown", TalentFrame_OnMouseDown)
			button:SetScript("OnEnter", TalentFrame_OnEnter)
			button:SetScript("OnLeave", TalentFrame_OnLeave)
			button:SetToplevel(true)
			button:SetFrameStrata("DIALOG")
			button.Tree = tree
			button.Talent = talent
			
			local texture = button:CreateTexture(nil, "BORDER")
			texture:SetTexture(icon)
			texture:SetWidth(32)
			texture:SetHeight(32)
			texture:SetPoint("CENTER", 0, 0)
			texture:SetDesaturated(rank == 0)
			button.Texture = texture
			
			if (points >= (tier - 1) * 5) then
				if (rank == maxRank) then
					CreateBorder(button, 1, 1, 0, 1)
				elseif (GetUnspentTalentPointsSync() > 0 or rank > 0) then
					CreateBorder(button, 0, 1, 0, 1)
				else
					CreateBorder(button, 0, 0, 0, 1)
				end
			else
				CreateBorder(button, 0, 0, 0, 1)
			end
			if (rank == maxRank) then
				CreateCounterFrame(button, rank, 1, 1, 0, 1)
			elseif (rank > 0) then
				CreateCounterFrame(button, rank, 0, 1, 0, 1)
			else
				CreateCounterFrame(button, rank, 1, 1, 1, 1)
			end

			talent = talent + 1
		end
	end
	return true
end


----------------------------------------------------------------
--------------------- PROFILE LIST EVENTS ----------------------
----------------------------------------------------------------


local function ProfileListElement_OnEnter()
	SetHighlightColor(self, 1, 0, 1, 1)
end

local function ProfileListELement_OnLeave()
	if (self == SelectedProfileFrame) then
		SetHighlightColor(self, 1, 1, 0, 1)
	else
		SetHighlightColor(self, 0, 0, 0, 1)
	end
end

local function ProfileListElement_OnClick()
	CopyProfile(TALENT_PROFILES[self.ProfileName], DisplayProfile)
	UpdatePointsSpentTrackers(DisplayProfile)
	UpdateView(DisplayProfile)
	SetHighlightColor(self, 1, 1, 0, 1)
	if (SelectedProfileFrame and SelectedProfileFrame ~= self) then
		SetHighlightColor(SelectedProfileFrame, 0, 0, 0, 1)
	end
	SelectedProfileFrame = self
end

local function ProfileListElement_OnMouseDown()
	if (arg1 == "RightButton") then
		PROFILE_TO_DELETE = self.ProfileName
		PROFILE_TO_DELETE_FRAME = self
		TP_DeleteProfilePopup_Text:SetText("Delete profile \""..self.ProfileName.."\"?")
		TP_DeleteProfilePopup:Show()
	else
		self:SetMovable(true)
	end
end

local function ProfileListElement_OnDragStart()
	TP_DragPoint,_,_,TP_DragX,TP_DragY = self:GetPoint()
	self:StartMoving()
end

local function SwapProfileListElements(button1, button2)
	local dragPoint,_,_,dragX,dragY = button2:GetPoint()
	button2:SetPoint(TP_DragPoint, TP_DragX, TP_DragY)
	button1:SetPoint(dragPoint, dragX, dragY)

	local fontString1 = getglobal(button1:GetName().."_Text")
	local name1 = fontString1:GetText()
	local start1 = tonumber(string.find(name1, ". "))
	local index1 = string.sub(name1, 1, start1 - 1)

	local fontString2 = getglobal(button2:GetName().."_Text")
	local name2 = fontString2:GetText()
	local start2 = tonumber(string.find(name2, ". "))
	local index2 = string.sub(name2, 1, start2 - 1)

	fontString1:SetText(index2..string.sub(name1, start1))
	fontString2:SetText(index1..string.sub(name2, start2))
end
local function ProfileListElement_OnDragStop()
	self:StopMovingOrSizing()
	local success = false
	local index = 1
	for profileName in TALENT_PROFILES do
		if (TALENT_PROFILES[profileName]) then
			local profileID = string.sub(tostring(TALENT_PROFILES[profileName]), 8)
			local target = getglobal(TP_Profiles_List:GetName().."_"..profileID)
			if (target and TALENT_PROFILES[target.ProfileName]) then
				if (self:GetName() ~= target:GetName() and MouseIsOver(target)) then
					SwapProfileListElements(self, target)
					Swap(TALENT_PROFILE_ORDER, self.ProfileName, profileName)
					success = true
					break
				end
			end
			index = index + 1
		end
	end
	if (not success) then self:SetPoint(TP_DragPoint, TP_DragX, TP_DragY) end
end


----------------------------------------------------------------
--------------------- CREATE PROFILE LIST ----------------------
----------------------------------------------------------------


local function CreateProfileListElementView(profileName)
	local parent = TP_Profiles_List

	local profileNumber = nil
	if (not TALENT_PROFILE_ORDER[profileName]) then
		profileNumber = GetNextProfileNumber()
		TALENT_PROFILE_ORDER[profileName] = profileNumber
	else
		profileNumber = TALENT_PROFILE_ORDER[profileName]
	end

	local pointsT1 = GetPointsSpentInTree(TALENT_PROFILES[profileName], 1)
	local pointsT2 = GetPointsSpentInTree(TALENT_PROFILES[profileName], 2)
	local pointsT3 = GetPointsSpentInTree(TALENT_PROFILES[profileName], 3)

	local profileID = string.sub(tostring(TALENT_PROFILES[profileName]), 8)
	local buttonName = parent:GetName().."_"..profileID

	local button = CreateFrame("BUTTON", buttonName, parent)
	button:SetWidth(185)
	button:SetHeight(22)
	button:SetPoint("TOPLEFT", 0.49, -0.6 + (profileNumber - 1) * -22)
	button:SetScript("OnEnter", ProfileListElement_OnEnter)
	button:SetScript("OnLeave", ProfileListELement_OnLeave)
	button:SetScript("OnClick", ProfileListElement_OnClick)
	button:SetScript("OnMouseDown", ProfileListElement_OnMouseDown)
	button:SetScript("OnDragStart", ProfileListElement_OnDragStart)
	button:SetScript("OnDragStop", ProfileListElement_OnDragStop)
	button:RegisterForDrag("LeftButton")
	button.ProfileName = profileName

	local background = button:CreateTexture(nil, "BORDER")
	background:SetWidth(185.5)
	background:SetHeight(22)
	background:SetPoint("CENTER", 0, 0)
	background:SetTexture(0.15, 0.15, 0.15, 1)

	local fontString = button:CreateFontString(buttonName.."_Text", "ARTWORK", "TP_FontSmall")
	fontString:SetWidth(132)
	fontString:SetHeight(21)
	fontString:SetPoint("TOPLEFT", 4, -1)
	fontString:SetText(profileNumber..". "..profileName)
	button.FontString = fontString
	
	local summary = button:CreateFontString(buttonName.."_Summary", "ARTWORK", "TP_FontSmallRight")
	summary:SetWidth(54)
	summary:SetHeight(21)
	summary:SetPoint("TOPRIGHT", -4, -1)
	summary:SetText("("..pointsT1.."/"..pointsT2.."/"..pointsT3..")")

	CreateThinBorder(button, 0, 0, 0, 1)
end

local function CreateProfileListView()
	local index = 1
	for profileName in TALENT_PROFILES do
		if (TALENT_PROFILES[profileName]) then
			CreateProfileListElementView(profileName)
			index = index + 1
		end
	end
	local max = index * 22 - TP_Profiles_ScrollFrame:GetHeight()
	if (max < 0) then max = 0 end
	TP_Slider:SetMinMaxValues(0, max)
end

local function UpdateProfileListView()
	local parent = TP_Profiles_List
	local index = 1
	local missing = nil
	for profileName in TALENT_PROFILE_ORDER do
		if (not TALENT_PROFILES[profileName]) then
			missing = TALENT_PROFILE_ORDER[profileName]
			TALENT_PROFILE_ORDER[profileName] = nil
			break
		end
	end
	for profileName in TALENT_PROFILE_ORDER do
		local profileNumber = TALENT_PROFILE_ORDER[profileName]
		if (missing and profileNumber > missing) then
			local element = getglobal(parent:GetName().."_"..profileName)
			element:SetPoint("TOPLEFT", 0.49, -0.6 + (profileNumber - 2) * -22)
			element.FontString:SetText((profileNumber - 1)..". "..profileName)
			TALENT_PROFILE_ORDER[profileName] = profileNumber - 1
		end
	end
end


----------------------------------------------------------------
-------------------- STANDARD BUTTON EVENTS --------------------
----------------------------------------------------------------


local function StandardButton_OnEnter()
	SetHighlightColor(self, 1, 0, 1, 1)
end

local function StandardButton_OnLeave()
	SetHighlightColor(self, 0, 0, 0, 1)
end


----------------------------------------------------------------
---------------------- CLOSE BUTTON EVENTS ---------------------
----------------------------------------------------------------


local function CloseButton_OnEnter()
	SetHighlightColor(self, 1, 0, 0, 1)
end

local function CloseButton_OnLeave()
	SetHighlightColor(self, 0, 0, 0, 0)
end


----------------------------------------------------------------
----------------------- SYNC BUTTON EVENTS ---------------------
----------------------------------------------------------------


local function SyncButton_OnLeave()
	if (TP_CONFIG.SyncWithCurrentTalents) then
		SetHighlightColor(self, 1, 0, 0, 1)
	else
		SetHighlightColor(self, 0, 0, 0, 1)
	end
end

local function SyncButton_OnClick()
	TP_CONFIG.SyncWithCurrentTalents = not TP_CONFIG.SyncWithCurrentTalents
	if (TP_CONFIG.SyncWithCurrentTalents) then
		Print("Synchronization On")
		SetHighlightColor(self, 1, 0, 0, 1)
		UpdateViewSync()
	else
		Print("Synchronization Off")
		SetHighlightColor(self, 0, 0, 0, 1)
	end
	if (SelectedProfileFrame) then
		SetHighlightColor(SelectedProfileFrame, 0, 0, 0, 1)
		SelectedProfileFrame = nil
	end
end


----------------------------------------------------------------
----------------------- SAVE BUTTON EVENTS ---------------------
----------------------------------------------------------------


local function SaveButton_OnClick()
	TP_SavePopup:Show()
end

local function LoadButton_OnClick()
	if (HasGoodBasis(DisplayProfile)) then
		Print("Loading talents...")
		SimpleLoad()
	else
		Print("self build cannot be applied with currenly picked talents.")
	end
end


----------------------------------------------------------------
--------------------- POPUP - SAVE EVENTS ----------------------
----------------------------------------------------------------


local function PopupSaveOk_OnClick()
	local profileName = TP_SavePopup_EditBox:GetText()
	if (string.find(profileName, "_") or string.len(profileName) < 3) then
		Print("Invalid profile name.")
	else
		SaveProfile(profileName)
		local index = 0
		for p in TALENT_PROFILES do
			if (TALENT_PROFILES[p]) then
				index = index + 1
			end
		end
		CreateProfileListElementView(profileName, index)
		local max = index * 22 - TP_Profiles_ScrollFrame:GetHeight()
		if (max < 0) then max = 0 end
		TP_Slider:SetMinMaxValues(0, max)
	end

	TP_SavePopup:Hide()
	TP_SavePopup_EditBox:SetText("")
end

local function PopupSaveCancel_OnClick()
	TP_SavePopup:Hide()
	TP_SavePopup_EditBox:SetText("")
end


----------------------------------------------------------------
-------------------- POPUP - DELETE EVENTS ---------------------
----------------------------------------------------------------


local function PopupDeleteYes_OnClick()
	local index = 1
	for p in TALENT_PROFILES do
		if (TALENT_PROFILES[p]) then
			index = index + 1
		end
	end
	local max = index * 22 - TP_Profiles_ScrollFrame:GetHeight()
	if (max < 0) then max = 0 end
	TP_Slider:SetMinMaxValues(0, max)

	TALENT_PROFILES[PROFILE_TO_DELETE] = nil
	--TALENT_PROFILE_ORDER[PROFILE_TO_DELETE] = nil
	PROFILE_TO_DELETE_FRAME:Hide()
	self:GetParent():Hide()
	PROFILE_TO_DELETE = nil
	PROFILE_TO_DELETE_FRAME = nil
	UpdateProfileListView()
end

local function PopupDeleteNo_OnClick()
	self:GetParent():Hide()
	PROFILE_TO_DELETE = nil
	PROFILE_TO_DELETE_FRAME = nil
end


----------------------------------------------------------------
--------------------- CONTENT ARROW EVENTS ---------------------
----------------------------------------------------------------


local function ContentArrowButton_OnLoad()
	if (not TP_CONFIG.ContentArrow) then
		TP_ContentArrowButton_Arrow:SetText(">")
		TP_Tree1:Hide()
		TP_Tree2:Hide()
		TP_Tree3:Hide()
		TP_MainFrame:SetWidth(200)
		TP_TopBar:SetWidth(200)
	else
		TP_ContentArrowButton_Arrow:SetText("<")
		TP_Tree1:Show()
		TP_Tree2:Show()
		TP_Tree3:Show()
		TP_MainFrame:SetWidth(722)
		TP_TopBar:SetWidth(722)
	end
end

local function ContentArrowButton_OnClick()
	if (TP_CONFIG.ContentArrow) then
		TP_CONFIG.ContentArrow = false
		TP_ContentArrowButton_Arrow:SetText(">")
		TP_Tree1:Hide()
		TP_Tree2:Hide()
		TP_Tree3:Hide()
		TP_MainFrame:SetWidth(200)
		TP_TopBar:SetWidth(200)
	else
		TP_CONFIG.ContentArrow = true
		TP_ContentArrowButton_Arrow:SetText("<")
		TP_Tree1:Show()
		TP_Tree2:Show()
		TP_Tree3:Show()
		TP_MainFrame:SetWidth(722)
		TP_TopBar:SetWidth(722)
	end
end


----------------------------------------------------------------
------------------- TREE CLEAR BUTTON EVENT --------------------
----------------------------------------------------------------


local function TreeClearButton_OnClick()
	local tree = tonumber(string.sub(self:GetName(), 8, 8))
	for talent in DisplayProfile[tree] do
		DisplayProfile[tree][talent] = 0
	end
	UpdateView(DisplayProfile)
	UpdatePointsSpentTrackers(DisplayProfile)
end


----------------------------------------------------------------
------------------------- XML BUTTONS --------------------------
----------------------------------------------------------------


local function InitButtons()
	ContentArrowButton_OnLoad()
	TP_ContentArrowButton:SetScript("OnClick", ContentArrowButton_OnClick)

	TP_Profiles_Actions_Save:SetScript("OnClick", SaveButton_OnClick)
	TP_Profiles_Actions_Sync:SetScript("OnClick", SyncButton_OnClick)
	TP_Profiles_Actions_Load:SetScript("OnClick", LoadButton_OnClick)
	TP_SavePopup_ButtonSave:SetScript("OnClick", PopupSaveOk_OnClick)
	TP_SavePopup_ButtonCancel:SetScript("OnClick", PopupSaveCancel_OnClick)
	TP_DeleteProfilePopup_ButtonYes:SetScript("OnClick", PopupDeleteYes_OnClick)
	TP_DeleteProfilePopup_ButtonNo:SetScript("OnClick", PopupDeleteNo_OnClick)

	TP_Tree1_ClearButton:SetScript("OnClick", TreeClearButton_OnClick)
	TP_Tree2_ClearButton:SetScript("OnClick", TreeClearButton_OnClick)
	TP_Tree3_ClearButton:SetScript("OnClick", TreeClearButton_OnClick)
end


----------------------------------------------------------------
--------------------- XML / EVENT BORDERS ----------------------
----------------------------------------------------------------


local function CreateBorders()
	CreateBorder(TP_Profiles, 0, 0, 0, 1)
	CreateBorder(TP_Tree1, 0, 0, 0, 1)
	CreateBorder(TP_Tree2, 0, 0, 0, 1)
	CreateBorder(TP_Tree3, 0, 0, 0, 1)

	CreateBorder(TP_Tree1_Description)
	CreateBorder(TP_Tree2_Description)
	CreateBorder(TP_Tree3_Description)

	CreateThinBorder(TP_ContentArrowButton, 0, 0, 0, 1, StandardButton_OnEnter, StandardButton_OnLeave)

	if (TP_CONFIG.SyncWithCurrentTalents) then
		CreateThinBorder(TP_Profiles_Actions_Sync, 1, 0, 0, 1, StandardButton_OnEnter, SyncButton_OnLeave)
	else
		CreateThinBorder(TP_Profiles_Actions_Sync, 0, 0, 0, 1, StandardButton_OnEnter, SyncButton_OnLeave)
	end
	CreateThinBorder(TP_Profiles_Actions_Save, 0, 0, 0, 1, StandardButton_OnEnter, StandardButton_OnLeave)
	CreateThinBorder(TP_Profiles_Actions_Load, 0, 0, 0, 1, StandardButton_OnEnter, StandardButton_OnLeave)

	CreateBorder(TP_SavePopup, 0, 0, 0, 1)
	CreateThinBorder(TP_SavePopup_ButtonSave, 0, 0, 0, 1, StandardButton_OnEnter, StandardButton_OnLeave)
	CreateThinBorder(TP_SavePopup_ButtonCancel, 0, 0, 0, 1, StandardButton_OnEnter, StandardButton_OnLeave)
	CreateThinBorder(TP_DeleteProfilePopup_ButtonYes, 0, 0, 0, 1, StandardButton_OnEnter, StandardButton_OnLeave)
	CreateThinBorder(TP_DeleteProfilePopup_ButtonNo, 0, 0, 0, 1, StandardButton_OnEnter, StandardButton_OnLeave)

	CreateThinBorder(TP_Tree1_ClearButton, 0, 0, 0, 0, CloseButton_OnEnter, CloseButton_OnLeave)
	CreateThinBorder(TP_Tree2_ClearButton, 0, 0, 0, 0, CloseButton_OnEnter, CloseButton_OnLeave)
	CreateThinBorder(TP_Tree3_ClearButton, 0, 0, 0, 0, CloseButton_OnEnter, CloseButton_OnLeave)

	CreateThinBorder(TP_ButtonCloseWidnow, 0, 0, 0, 0, CloseButton_OnEnter, CloseButton_OnLeave)
end


----------------------------------------------------------------
--------------------- CLASS SPECIFIC DATA ----------------------
----------------------------------------------------------------


local function InitClassSpecific()
	TP_Tree1_Description_TreeName:SetText(Specializations[PlayerClass].Spec1)
	TP_Tree2_Description_TreeName:SetText(Specializations[PlayerClass].Spec2)
	TP_Tree3_Description_TreeName:SetText(Specializations[PlayerClass].Spec3)

	TP_Tree1_Description_Icon:SetTexture(Icons[PlayerClass].Spec1)
	TP_Tree2_Description_Icon:SetTexture(Icons[PlayerClass].Spec2)
	TP_Tree3_Description_Icon:SetTexture(Icons[PlayerClass].Spec3)

	TP_Tree1_BackgroundTexture_TopLeft:SetTexture(Backgrounds[PlayerClass].Spec1.."-TopLeft")
	TP_Tree1_BackgroundTexture_TopRight:SetTexture(Backgrounds[PlayerClass].Spec1.."-TopRight")
	TP_Tree1_BackgroundTexture_BottomLeft:SetTexture(Backgrounds[PlayerClass].Spec1.."-BottomLeft")
	TP_Tree1_BackgroundTexture_BottomRight:SetTexture(Backgrounds[PlayerClass].Spec1.."-BottomRight")

	TP_Tree2_BackgroundTexture_TopLeft:SetTexture(Backgrounds[PlayerClass].Spec2.."-TopLeft")
	TP_Tree2_BackgroundTexture_TopRight:SetTexture(Backgrounds[PlayerClass].Spec2.."-TopRight")
	TP_Tree2_BackgroundTexture_BottomLeft:SetTexture(Backgrounds[PlayerClass].Spec2.."-BottomLeft")
	TP_Tree2_BackgroundTexture_BottomRight:SetTexture(Backgrounds[PlayerClass].Spec2.."-BottomRight")

	TP_Tree3_BackgroundTexture_TopLeft:SetTexture(Backgrounds[PlayerClass].Spec3.."-TopLeft")
	TP_Tree3_BackgroundTexture_TopRight:SetTexture(Backgrounds[PlayerClass].Spec3.."-TopRight")
	TP_Tree3_BackgroundTexture_BottomLeft:SetTexture(Backgrounds[PlayerClass].Spec3.."-BottomLeft")
	TP_Tree3_BackgroundTexture_BottomRight:SetTexture(Backgrounds[PlayerClass].Spec3.."-BottomRight")
end


----------------------------------------------------------------
--------------------- ADDON UPDATE HANDLER ---------------------
----------------------------------------------------------------


local function UpdateHandler()
	if (not TalentFramesCreated) then
		TalentFramesCreated = CreateTalentFrames()
		UpdatePointsSpentTrackersSync()
	end
	if (LoadingTalents) then
		PickTalents(CurrentProfile, 1)
		PickTalents(CurrentProfile, 2)
		PickTalents(CurrentProfile, 3)

		UpdateViewSync()

		if ((GetUnspentTalentPointsSync() <= 0) or IsProfileLoaded(CurrentProfile)) then
			LoadingTalents = false
			Print("Talents loaded.")
			if (SelectedProfileFrame) then
				SetHighlightColor(SelectedProfileFrame, 0, 0, 0, 1)
				SelectedProfileFrame = nil
			end
		end
	end
end


----------------------------------------------------------------
---------------------- ADDON EVEN HANDLER ----------------------
----------------------------------------------------------------


local function EventHandler()
	if (event == "VARIABLES_LOADED") then
		PlayerClass = UnitClass("player")
		tinsert(UISpecialFrames, TP_MainFrame:GetName())
		tinsert(UISpecialFrames, TP_DeleteProfilePopup:GetName())
		TalentFramesCreated = CreateTalentFrames()
		
		InitClassSpecific()
		InitButtons()
		CreateBorders()
		CreateProfileListView()

		UpdatePointsSpentTrackersSync()
		
	elseif (event == "CHARACTER_POINTS_CHANGED") then
		if (TP_CONFIG.SyncWithCurrentTalents) then UpdateViewSync() end
	end
end


----------------------------------------------------------------
----------------------- SLASH COMMANDS -------------------------
----------------------------------------------------------------


local function CommandListProfiles(msg)
	if (msg == "list") then
		local talent = 1
		for profile in TALENT_PROFILES do
			if (TALENT_PROFILES[profile]) then
				Print(talent..". "..profile)
				talent = talent + 1
			end
		end
		return true
	end
	return false
end

local function CommandLoad(msg)
	local start, stop = string.find(msg, "load ")
	if (start and stop) then
		local profileName = string.sub(msg, stop + 1)
		if (TALENT_PROFILES[profileName]) then
			LoadingTalents = true
			CurrentProfile = TALENT_PROFILES[profileName]
			Print("Started loading profile: \""..profileName.."\"")
		else
			Print("Profile: \""..profileName.."\" doesn't exist")
		end
		return true
	end
	return false
end

local function CommandSimpleLoad(msg)
	if (msg == "load") then
		SimpleLoad()
		return true
	end
	return false
end

local function CommandSave(msg)
	local start, stop = string.find(msg, "save ")
	if (start and stop) then
		local profileName = string.sub(msg, stop + 1)
		SaveTalents(profileName)
		Print("Profile saved.")
		return true
	end
	return false
end

function TP_ToggleMainFrame()
	if (TP_MainFrame:IsShown()) then
		TP_MainFrame:Hide()
	else
		TP_MainFrame:Show()
	end
end

local function CommandToggle(msg)
	if (msg == "toggle") then
		TP_ToggleMainFrame()
		return true
	end
	return false
end


local function SlashCmdHandler(msg)
	if (CommandListProfiles(msg)) then return end
	if (CommandLoad(msg)) then return end
	if (CommandSimpleLoad(msg)) then return end
	if (CommandSave(msg)) then return end
	if (CommandToggle(msg)) then return end

	TP_MainFrame:Show()
end
SlashCmdList["TALENTPROFILER"] = SlashCmdHandler


----------------------------------------------------------------
------------------------ ADDON ON_LOAD -------------------------
----------------------------------------------------------------







local function TalentProfiler_OnLoad()
	Addon:SetScript("OnEvent", EventHandler)
	Addon:SetScript("OnUpdate", UpdateHandler)

	Addon:RegisterEvent("VARIABLES_LOADED")
	Addon:RegisterEvent("CHARACTER_POINTS_CHANGED")
end
TalentProfiler_OnLoad()
