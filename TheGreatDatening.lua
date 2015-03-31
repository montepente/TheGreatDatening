TheGreatDatening = {};
TheGreatDatening.fields = {};


local EventFrame = CreateFrame("Frame")
EventFrame:RegisterEvent("ADDON_LOADED")
EventFrame:RegisterEvent("CHAT_MSG_SYSTEM")
--To test, comment the line over this one and uncomment the line below and write in "say" chat something like : NameOfSomeoneInGuildRoster has joined the guild.
--Don't forget to change the event in the script below too.
--EventFrame:RegisterEvent("CHAT_MSG_SAY")
EventFrame:SetScript("OnEvent", function(self,event,msg) 

	if (event == "ADDON_LOADED" and msg == "TheGreatDatening") then
		if TGDOptions == nil then
			TGDOptions = {};
			TGDOptions.dateFormat = "%B %d, %Y";
			TGDOptions.textBefore = "";
			TGDOptions.textAfter = "";
		end

		-- Interface menu
		TheGreatDatening.panel = CreateFrame( "Frame", "TheGreatDateningPanel", InterfaceOptionsFramePanelContainer);
		TheGreatDatening.panel.name = "The Great Datening";
		TheGreatDatening.panel.okay = function (self)
			TheGreatDatening_close(self)
		end
		
		

		local title = TheGreatDatening.panel:CreateFontString("TGDTitle", "ARTWORK", "GameFontNormalLarge")
		title:SetPoint("TOPLEFT", 16, -16)
		title:SetText("The Great Datening")

		local titleDateFormat = TheGreatDatening.panel:CreateFontString("TGDDateFormatLabel", "ARTWORK", "GameFontNormalSmall")
		titleDateFormat:SetPoint("TOPLEFT", 20, -66)
		titleDateFormat:SetText("Date Format")
		
		-- Dropdown => Date Format
		local info = {}
		TheGreatDatening.dateFormat = CreateFrame("Frame", "TGDDateFormat", TheGreatDatening.panel, "UIDropDownMenuTemplate")
		TheGreatDatening.dateFormat:SetPoint("TOPLEFT", 0, -78)
		TheGreatDatening.dateFormat.initialize = function()
			wipe(info)
			local formats = {"%B %d, %Y", "%m-%d-%Y", "%d-%m-%Y", "%Y-%m-%d", "%m/%d/%Y", "%d/%m/%Y", "%Y/%m/%d"}
			local names = {"December 31, 2015", "12-31-2015", "31-12-2015", "2015-12-31", "12/31/2015", "31/12/2015", "2015/12/31"}
			for i, singleFormat in next, formats do
				info.text = names[i]
				info.value = singleFormat
				info.func = function(self)
					currentFormat = self.value
					TGDDateFormatText:SetText(self:GetText())
					TGDOptions.dateFormat = self.value
				end
				if (currentFormat == nil) then
					info.checked = singleFormat == TGDOptions.dateFormat
				else
					info.checked = singleFormat == currentFormat
				end
				
				UIDropDownMenu_AddButton(info)
			end
		end
		TGDDateFormatText:SetText("Date Format")

		local titleTextBefore = TheGreatDatening.panel:CreateFontString("TGDTextBeforeLabel", "ARTWORK", "GameFontNormalSmall")
		titleTextBefore:SetPoint("TOPLEFT", 20, -119)
		titleTextBefore:SetText("Text Before")
		
		-- Text Before
		TheGreatDatening.textBefore = CreateFrame("EditBox", "TGDTextBefore", TheGreatDatening.panel, "InputBoxTemplate")
		TheGreatDatening.textBefore:SetPoint("TOPLEFT", 24, -117)
		TheGreatDatening.textBefore:SetWidth(100)
		TheGreatDatening.textBefore:SetHeight(50)
		TheGreatDatening.textBefore:SetAutoFocus(false)
		if (TGDOptions.textBefore) then
			TheGreatDatening.textBefore:SetText(TGDOptions.textBefore)
			TheGreatDatening.textBefore:SetCursorPosition(0)
		end

		local titleTextAfter = TheGreatDatening.panel:CreateFontString("TGDTextAfterLabel", "ARTWORK", "GameFontNormalSmall")
		titleTextAfter:SetPoint("TOPLEFT", 20, -167)
		titleTextAfter:SetText("Text After")

		-- Text After
		TheGreatDatening.textAfter = CreateFrame("EditBox", "TGDTextAfter", TheGreatDatening.panel, "InputBoxTemplate")
		TheGreatDatening.textAfter:SetPoint("TOPLEFT", 24, -165)
		TheGreatDatening.textAfter:SetWidth(100)
		TheGreatDatening.textAfter:SetHeight(50)
		TheGreatDatening.textAfter:SetAutoFocus(false)
		if (TGDOptions.textAfter) then
			TheGreatDatening.textAfter:SetText(TGDOptions.textAfter)
			TheGreatDatening.textAfter:SetCursorPosition(0)
		end

		InterfaceOptions_AddCategory(TheGreatDatening.panel);
		
	elseif (event == "CHAT_MSG_SYSTEM") then
		playerName = "";
		splitText = msg:splitMsg(" ");
		
		if splitText[3] == "joined" then
			playerName = splitText[1];
		end
		
		if playerName ~= "" and playerName ~= nil then 
			if CanEditOfficerNote() then
				TheGreatDatening_wait(3,TheGreatDatening_AddDate,playerName);
			end
		end
	end
end)

local waitTable = {};
local waitFrame = nil;

function TheGreatDatening_wait(delay, func, ...)
  if(type(delay)~="number" or type(func)~="function") then
    return false;
  end
  if(waitFrame == nil) then
    waitFrame = CreateFrame("Frame","WaitFrame", UIParent);
    waitFrame:SetScript("onUpdate",function (self,elapse)
      local count = #waitTable;
      local i = 1;
      while(i<=count) do
        local waitRecord = tremove(waitTable,i);
        local d = tremove(waitRecord,1);
        local f = tremove(waitRecord,1);
        local p = tremove(waitRecord,1);
        if(d>elapse) then
          tinsert(waitTable,i,{d-elapse,f,p});
          i = i + 1;
        else
          count = count - 1;
          f(unpack(p));
        end
      end
    end);
  end
  tinsert(waitTable,{delay,func,{...}});
  return true;
end

function TheGreatDatening_AddDate(datePlayerName)
	ctrRoster = 1;
	endingLoop = 0;
	maxMembers = GetNumGuildMembers();
	
	while endingLoop == 0 do
		fullName, rank, rankIndex, level, class, zone, note, officernote, online, status, classFileName, achievementPoints, achievementRank, isMobile, canSoR, reputation = GetGuildRosterInfo(ctrRoster);
		
		if datePlayerName == fullName then
			GuildRosterSetOfficerNote(ctrRoster, TGDOptions.textBefore .. date(TGDOptions.dateFormat) .. TGDOptions.textAfter);
			
			endingLoop = 1;
		end
		
		if ctrRoster >= maxMembers then
			endingLoop = 1;
		end
		
		ctrRoster = ctrRoster + 1;
	end
end

function TheGreatDatening_close(panel)
	TGDOptions.textBefore = TheGreatDatening.textBefore:GetText()
	TGDOptions.textAfter = TheGreatDatening.textAfter:GetText()
end

function string:splitMsg(inSplitPattern, outResults )

   if not outResults then
      outResults = { }
   end
   local theStart = 1
   local theSplitStart, theSplitEnd = string.find( self, inSplitPattern, theStart )
   while theSplitStart do
      table.insert( outResults, string.sub( self, theStart, theSplitStart-1 ) )
      theStart = theSplitEnd + 1
      theSplitStart, theSplitEnd = string.find( self, inSplitPattern, theStart )
   end
   table.insert( outResults, string.sub( self, theStart ) )
   return outResults
end