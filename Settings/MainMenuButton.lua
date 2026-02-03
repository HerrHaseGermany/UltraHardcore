-- Create the button (parented to UIParent so it can sit outside GameMenuFrame across clients)
local button = _G.GameMenuButtonUltraHardcore
if not button then
  button =
    CreateFrame(
      'Button',
      'GameMenuButtonUltraHardcore',
      UIParent,
      'GameMenuButtonTemplate'
    )
end

button:Hide()

-- Make it look less like a default Blizzard button (works in Classic + TBC)
local function SkinUltraButton()
  if button._uhcSkinned then
    return
  end
  button._uhcSkinned = true

  button:SetSize(160, 28)

  -- Hide template text if present; we use our own label for consistent styling
  if button.GetFontString and button:GetFontString() then
    button:GetFontString():Hide()
  end
  if button.Text and button.Text.Hide then
    button.Text:Hide()
  end

  -- Label
  local label = button:CreateFontString(nil, 'OVERLAY', 'GameFontNormal')
  -- Reserve space for icons so the label can be truly centered
  label:SetPoint('LEFT', button, 'LEFT', 34, 0)
  label:SetPoint('RIGHT', button, 'RIGHT', -34, 0)
  label:SetJustifyH('CENTER')
  label:SetText('ULTRA')
  label:SetTextColor(1, 0.82, 0.2)
  button._uhcLabel = label

  -- Hover highlight
  local hover = button:CreateTexture(nil, 'HIGHLIGHT')
  hover:SetAllPoints(button)
  hover:SetColorTexture(1, 1, 1, 0.06)
  button._uhcHover = hover

  button:SetScript('OnEnter', function()
    if button._uhcBorder then
      button._uhcBorder:SetColorTexture(1, 0.8, 0.2, 0.35)
    end
    if button._uhcLeftIcon then
      button._uhcLeftIcon:SetVertexColor(1, 1, 1, 1)
    end
    if button._uhcRightIcon then
      button._uhcRightIcon:SetVertexColor(1, 0.92, 0.35, 1)
    end
    if button._uhcLabel then
      button._uhcLabel:SetTextColor(1, 0.9, 0.35)
    end
  end)

  button:SetScript('OnLeave', function()
    if button._uhcBorder then
      button._uhcBorder:SetColorTexture(1, 0.72, 0.12, 0.22)
    end
    if button._uhcLeftIcon then
      button._uhcLeftIcon:SetVertexColor(1, 1, 1, 0.95)
    end
    if button._uhcRightIcon then
      button._uhcRightIcon:SetVertexColor(1, 1, 1, 0.95)
    end
    if button._uhcLabel then
      button._uhcLabel:SetTextColor(1, 0.82, 0.2)
    end
  end)

  -- Pressed feel
  button:SetScript('OnMouseDown', function()
    if button._uhcBg then
      button._uhcBg:SetColorTexture(0.02, 0.02, 0.025, 0.9)
    end
    if button._uhcLeftIcon then
      button._uhcLeftIcon:ClearAllPoints()
      button._uhcLeftIcon:SetPoint('LEFT', button, 'LEFT', 9, -1)
    end
    if button._uhcRightIcon then
      button._uhcRightIcon:ClearAllPoints()
      button._uhcRightIcon:SetPoint('RIGHT', button, 'RIGHT', -7, -1)
    end
    if button._uhcLabel then
      button._uhcLabel:ClearAllPoints()
      button._uhcLabel:SetPoint('LEFT', button, 'LEFT', 34, -1)
      button._uhcLabel:SetPoint('RIGHT', button, 'RIGHT', -34, -1)
    end
  end)

  button:SetScript('OnMouseUp', function()
    if button._uhcBg then
      button._uhcBg:SetColorTexture(0.03, 0.03, 0.035, 0.82)
    end
    if button._uhcLeftIcon then
      button._uhcLeftIcon:ClearAllPoints()
      button._uhcLeftIcon:SetPoint('LEFT', button, 'LEFT', 8, 0)
    end
    if button._uhcRightIcon then
      button._uhcRightIcon:ClearAllPoints()
      button._uhcRightIcon:SetPoint('RIGHT', button, 'RIGHT', -8, 0)
    end
    if button._uhcLabel then
      button._uhcLabel:ClearAllPoints()
      button._uhcLabel:SetPoint('LEFT', button, 'LEFT', 34, 0)
      button._uhcLabel:SetPoint('RIGHT', button, 'RIGHT', -34, 0)
    end
  end)
end

local function PositionUltraButton()
  SkinUltraButton()
  -- Parent to GameMenuFrame to avoid scale mismatches between UIParent and the menu frame (TBC issue).
  button:SetParent(GameMenuFrame)
  button:ClearAllPoints()
  -- Insert between the last default button and "Return to Game" for consistent layout.
  local anchorAbove =
    _G.GameMenuButtonQuit or _G.GameMenuButtonExitGame or _G.GameMenuButtonLogout
      or _G.GameMenuButtonMacros or _G.GameMenuButtonContinue
  if anchorAbove then
    button:SetPoint('TOP', anchorAbove, 'BOTTOM', 0, -6)
  else
    button:SetPoint('BOTTOM', GameMenuFrame, 'BOTTOM', 0, 16)
  end
  -- Make sure we're above normal UI so it doesn't tuck behind panels
  button:SetFrameStrata(GameMenuFrame:GetFrameStrata() or 'DIALOG')
  if _G.GameMenuButtonContinue then
    button:SetFrameLevel(GameMenuButtonContinue:GetFrameLevel())
  else
    button:SetFrameLevel((GameMenuFrame:GetFrameLevel() or 0) + 1)
  end

  -- Extend the GameMenuFrame so the button fits inside the box.
  local extraHeight = button:GetHeight() + 8
  local currentHeight = GameMenuFrame:GetHeight()
  if not GameMenuFrame._uhcBaseHeight then
    GameMenuFrame._uhcBaseHeight = currentHeight
  end
  -- If Blizzard reset the height after we adjusted, refresh the base height.
  if
    not GameMenuFrame._uhcHeightAdjusted
    and math.abs(currentHeight - (GameMenuFrame._uhcBaseHeight + extraHeight)) > 1
  then
    GameMenuFrame._uhcBaseHeight = currentHeight
  end
  GameMenuFrame._uhcHeightAdjusted = true
  GameMenuFrame:SetHeight(GameMenuFrame._uhcBaseHeight + extraHeight)

  -- Re-anchor "Return to Game" below our button so it doesn't overlap.
  if _G.GameMenuButtonContinue then
    GameMenuButtonContinue:ClearAllPoints()
    GameMenuButtonContinue:SetPoint('TOP', button, 'BOTTOM', 0, -6)
  end
end

local function ScheduleReposition()
  -- TBC can reshuffle buttons over the next few frames after opening.
  if C_Timer and C_Timer.NewTicker then
    if GameMenuFrame._uhcRepositionTicker then
      GameMenuFrame._uhcRepositionTicker:Cancel()
    end
    local ticks = 0
    GameMenuFrame._uhcRepositionTicker = C_Timer.NewTicker(0, function()
      if not GameMenuFrame:IsShown() then
        return
      end
      PositionUltraButton()
      button:Show()
      ticks = ticks + 1
      if ticks >= 5 and GameMenuFrame._uhcRepositionTicker then
        GameMenuFrame._uhcRepositionTicker:Cancel()
        GameMenuFrame._uhcRepositionTicker = nil
      end
    end)
  elseif C_Timer and C_Timer.After then
    C_Timer.After(0, function()
      if GameMenuFrame:IsShown() then
        PositionUltraButton()
        button:Show()
      end
    end)
  else
    PositionUltraButton()
    button:Show()
  end
end

-- Set the click handler
button:SetScript('OnClick', function()
  -- Hide the game menu
  HideUIPanel(GameMenuFrame)
  -- Toggle settings using the existing function
  ToggleSettings()
end)

-- Show/hide alongside the GameMenuFrame without modifying Blizzard's internal layout
GameMenuFrame:HookScript('OnShow', function()
  -- Delay and retry to allow Blizzard's layout to finish in TBC, then reposition.
  ScheduleReposition()
end)

GameMenuFrame:HookScript('OnHide', function()
  button:Hide()
  GameMenuFrame._uhcHeightAdjusted = false
end)

-- Re-apply after Blizzard updates button layout (TBC reorders on update).
if hooksecurefunc and _G.GameMenuFrame_UpdateVisibleButtons then
  hooksecurefunc('GameMenuFrame_UpdateVisibleButtons', function()
    if GameMenuFrame:IsShown() then
      ScheduleReposition()
    end
  end)
end
