local DST = CreateFrame("Frame")
DST:RegisterEvent("ADDON_LOADED")
DST:RegisterEvent("ZONE_CHANGED_NEW_AREA")
DST.Version = "0.1"

-- pre-allocate work variables for OnUpdate functions
DST.Work = 	{
	Continent = 1,
	Zone = 1,
	ZoneName = "",
	pxbuff = 0,
	pybuff = 0,
	px = 0,
	py = 0,
	Time = 0,
}

-- local functions
DST.GetPlayerMapPosition = GetPlayerMapPosition
DST.sqrt = sqrt


function DST:OnEvent()
	if event == "ZONE_CHANGED_NEW_AREA" then
		SetMapToCurrentZone()
        DST.Work.Continent = GetCurrentMapContinent()
        DST.Work.Zone = GetCurrentMapZone()
        DST.Work.ZoneName = GetZoneText()
        if ZoneName == "Warsong Gulch" or ZoneName == "Arathi Basin" or ZoneName == "Alterac Valley" then Zone = ZoneName end
		DST.Work.pxbuff, DST.Work.pybuff = DST.GetPlayerMapPosition("player")
		DST.Work.Time = -2
	
	elseif event == "ADDON_LOADED" and arg1 == "Distance" then
		if not DSTVariable then
			DSTVariable = {}
			DSTVariable.Distance = 0 -- saved distance in yrds
			DSTVariable.Interval = 1 -- update interval for yards
		end
		
		SetMapToCurrentZone()
        DST.Work.Continent = GetCurrentMapContinent()
        DST.Work.Zone = GetCurrentMapZone()
        DST.Work.ZoneName = GetZoneText()
        if DST.Work.ZoneName == "Warsong Gulch" or DST.Work.ZoneName == "Arathi Basin" or DST.Work.ZoneName == "Alterac Valley" then DST.Work.Zone = DST.Work.ZoneName end
		DST.Work.pxbuff, DST.Work.pybuff = DST.GetPlayerMapPosition("player")
		DST.Work.Time = 0
		
		DST:SetScript("OnUpdate",DST.OnUpdate)
	end
	
end

function DST:OnUpdate()
	DST.Work.Time = DST.Work.Time + arg1
	if DST.Work.Time >= DSTVariable.Interval then
		DST.Work.px, DST.Work.py = DST.GetPlayerMapPosition("player")
		DSTVariable.Distance = DSTVariable.Distance + (DST.sqrt(((DST.Work.px - DST.Work.pxbuff)/DST.MapScales[DST.Work.Continent][DST.Work.Zone].x)^2 + ((DST.Work.py - DST.Work.pybuff)/DST.MapScales[DST.Work.Continent][DST.Work.Zone].y)^2))/10e9
		DST.Work.Time = 0
		DST.Work.pxbuff = DST.Work.px
		DST.Work.pybuff = DST.Work.py
	end

end

DST:SetScript("OnEvent", DST.OnEvent)

-- prompt
function DistToggle(arg1)
	if string.lower(string.sub(arg1, 1, 5)) == "reset" then
		DSTVariable.Distance = 0
	elseif arg1 == nil or arg1 == "" then
		DEFAULT_CHAT_FRAME:AddMessage(DST.Work.Continent)
		DEFAULT_CHAT_FRAME:AddMessage("Total Distance: ".."|cFFFFFFFF"..DST:round(DSTVariable.Distance*10e9,0).." yrds|r | ".."|cFFFFFFFF"..DST:round(DSTVariable.Distance*10e6/1.0936,2).." km|r | ".."|cFFFFFFFF"..DST:round(DSTVariable.Distance*10e6/1.760,2).." miles|r",1,1,0)
	end
end

SlashCmdList['DISTANCE'] = DistToggle
SLASH_DISTANCE1 = '/distance'
SLASH_DISTANCE2 = '/Distance'

function DST:round(num, idp)
  local mult = 10^(idp or 0)
  return math.floor(num * mult + 0.5) / mult
end

DST.MapScales = {
	[0] = {[0] = {x=0.0000000001,y=0.0000000001}}, -- overworld dummy
	
	[-1] = { -- Battlegrounds
		[0] = {x=0.0000000001,y=0.0000000001}, -- dummy
		["Alterac Valley"] = {x=0.00025277584791183,y=0.0003791834626879}, -- alterac
		["Arathi Basin"] = {x=0.00060996413230886,y=0.00091460134301867}, -- arathi
		["Warsong Gulch"] = {x=0.000934666820934484,y=0.0013986080884933}, -- warsong
	},
	
	[1] = { -- Kalimdor
		[0] = {x=0.0000000001,y=0.0000000001}, -- dummy
		[1] = {x=0.00018538534641226,y=0.00027837923594884}, -- Ashenvale
		[2] = {x=0.0002110515322004,y=0.00031666883400508}, -- Aszhara
		[3] = {x=0.00016346999577114,y=0.0002448782324791}, -- Darkshore
		[4] = {x=0.001011919762407,y=0.0015176417572158}, -- Darnassus
		[5] = {x=0.000238049243117769,y=0.00035701000264713}, -- Desolace
		[6] = {x=0.000202241752828887,y=0.00030311250260898},  -- Durotar
		[7] = {x=0.00020404585770198,y=0.00030594425542014}, -- Dustwallow
		[8] = {x=0.00018605589866638,y=0.00027919347797121}, -- Felwood
		[9] = {x=0.00015413335391453,y=0.00023112978254046}, -- Feralas
		[10] = {x=0.00046338992459433,y=0.00069469745670046}, -- Moonglade
		[11] = {x=0.00020824585642133,y=0.00031234536852155}, -- Mulgor
		[12] = {x=0.00076302673135485,y=0.0011450946331024}, -- Orgrimmar
		[13] = {x=0.00030702139650072,y=0.00046115900788988}, -- Silithus
		[14] = {x=0.0002192035317421,y=0.00032897400004523}, -- Stonetalon
		[15] = {x=0.00015519559383392,y=0.00023255497217178}, -- Tanaris
		[16] = {x=0.00021010743720191,y=0.00031522342136928}, -- Teldrassil
		[17] = {x=0.0001055257661002,y=0.00015825512153762}, -- Barrens
		[18] = {x=0.00024301665169852,y=0.00036516572747912}, -- Needles
		[19] = {x=0.00102553303755263,y=0.0015390366315842}, -- Thunderbluff
		[20] = {x=0.00028926772730691,y=0.0004336131470544}, -- Ungoro
		[21] = {x=0.0001503484589713,y=0.0002260080405644}, -- Winterspring
	},
	
	[2] = { -- Eastern Kingdoms
		[0] = {x=0.0000000001,y=0.0000000001}, -- dummy
		[1] = {x=0.00038236060312816,y=0.00057270910058703}, -- Alterac mountains
		[2] = {x=0.00029711957488741,y=0.00044587893145425}, -- arathi
		[3] = {x=0.00043004538331713,y=0.00064518196242196}, -- Badlands
		[4] = {x=0.00031955327306475,y=0.00047930649348668}, -- blasted lands
		[5] = {x=0.00036544565643583,y=0.00054845426763807}, -- Burning steppes
		[6] = {x=0.00042719074657985,y=0.00064268921102796}, -- deadwind pass
		[7] = {x=0.00021748670509883,y=0.00032613213573183}, -- Dun Morogh
		[8] = {x=0.00039665134889739,y=0.000594192317755393},-- duskwood
		[9] = {x=0.00027669753347124,y=0.00041501436914716}, -- EPL
		[10] = {x=0.00030816452843802,y=0.00046261719294957}, -- Elwynn Forest
		[11] = {x=0.00033472904137203,y=0.00050214784485953}, -- hillsbrad
		[12] = {x=0.0013541845338685,y=0.0020301469734737}, -- Ironforge
		[13] = {x=0.00038827742849077,y=0.000582420040021079}, -- loch modan
		[14] = {x=0.00049317521708352,y=0.0007399320602417}, -- redridge mountains
		[15] = {x=0.00047916280371802,y=0.00071918751512255}, -- Searing G.
		[16] = {x=0.00025506743362975,y=0.00038200191089085}, -- silverpine
		[17] = {x=0.00079576990434102,y=0.0011931381055287}, -- Stormwind
		[18] = {x=0.00016783603600093,y=0.00025128040994917}, -- stranglethorn
		[19] = {x=0.00046689595494952,y=0.00070027368409293}, -- swamp of sorrows
		[20] = {x=0.0002777065549578,y=0.00041729531117848}, -- Hinterlands
		[21] = {x=0.00023638989244189,y=0.0003550010068076}, -- Tirisfal 
		[22] = {x=0.0011167100497655,y=0.0016737942184721}, -- Undercity
		[23] = {x=0.00024908781051636,y=0.00037342309951782}, -- WPL
		[24] = {x=0.00030591232436044,y=0.00045816733368805},-- westfall
		[25] = {x=0.00025879591703415,y=0.00038863212934562}, -- wetlands
	}
}