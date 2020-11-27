DelayedQuestText = {}

local FADE_TIME = 1.0
local TEXT_PADDING = 10
local SHOW_DURATION = 16

local frame = CreateFrame("Frame", "DelayedQuestTextFrame", UIParent, "BackdropTemplate")
frame:EnableMouse(true)
frame:SetMovable(true)
frame:SetWidth(280)
frame:SetHeight(TEXT_PADDING * 2)
frame:SetBackdrop({
  bgFile = "Interface/Tooltips/UI-Tooltip-Background", 
  edgeFile = "Interface/Tooltips/UI-Tooltip-Border", 
  tile = true, tileSize = 16, edgeSize = 16, 
  insets = { left = 4, right = 4, top = 4, bottom = 4 }
})
frame:SetBackdropColor(0,0,0,0.5);
frame:SetPoint("TOPRIGHT", ObjectiveTrackerFrame, "TOPLEFT", -40, 0)
frame.text = frame:CreateFontString(nil, "OVERLAY", "GameFontWhite");
frame.text:SetPoint("TOPLEFT");
frame.text:SetJustifyV("TOP");
frame.text:SetJustifyH("LEFT");
frame.text:SetPoint("TOPLEFT",frame,"TOPLEFT", TEXT_PADDING,-TEXT_PADDING)
frame.text:SetWidth(frame:GetRight() - frame:GetLeft() - TEXT_PADDING * 2)
frame:Hide()

frame:SetScript("OnEvent", function(self, event, ...)
  if self[event] then return self[event](self, ...); end
end)
  
local questQueue = {}

frame:RegisterEvent("QUEST_ACCEPTED")
function frame:QUEST_ACCEPTED(questID)
  tinsert(questQueue, questID)
  ShowQuest()
end

function ShowQuest()
  if #questQueue >= 1 and not frame.questID then
    frame.questID = tremove(questQueue, 1)
    C_QuestLog.SetSelectedQuest(frame.questID)
    local questDescription, questObjectives = GetQuestLogQuestText()
    local questTitle = C_QuestLog.GetTitleForQuestID(frame.questID)

    frame.text:SetText("|cffffd100" .. questTitle .. "|r|n|n" .. questDescription .. "|n|n|cffffd100Objective|r|n|n" .. questObjectives)
    frame:SetHeight(frame.text:GetHeight() + TEXT_PADDING * 2)
    
    UIFrameFadeIn(frame, FADE_TIME, 0, 1)

    C_Timer.After(SHOW_DURATION, function()
      frame.questID = nil
      UIFrameFadeOut(frame, FADE_TIME, 1, 0)
      C_Timer.After(FADE_TIME, function()
        if #questQueue >= 1 then
          ShowQuest()
        end
      end)
    end)
  end
end
