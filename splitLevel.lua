local _, Hiui = ...
local default = Hiui.default.splitLevel
--local default = Hiui.custom or Hiui.default

Hiui.splitLevel_DefaultClassPower = function(parent, name, point1, point2)
    local magicnumber = 16 -- TODO: fix = MAGIC NUMBER!
    local classPower = {}
    for i = 1, 10 do
        local bar = CreateFrame("StatusBar", name .. "ClassPowerSegment" .. i, parent)

        -- This disables the "default" oUF combo point texture.
        bar:SetStatusBarTexture([[Interface\PlayerFrame\Priest-ShadowUI]])	--Anything
        bar:GetStatusBarTexture():SetColorTexture(0, 0, 0, 0)

        bar:SetSize(magicnumber, magicnumber)

        -- TODO: fix - out of scope reference / magic reference to 'name .. "PowerBar"' and position.
        bar:SetPoint("BOTTOMRIGHT", parent.Power, "TOPRIGHT", -(i - 1) * magicnumber, 0)


        -- HealthArt is Artwork 2
        bar.icon = bar:CreateTexture(nil, "ARTWORK", nil, 3)

        bar.icon:SetTexCoord(0.45703125, 0.60546875, 0.44531250, 0.73437500)
        bar.icon:SetTexture([[Interface\PlayerFrame\Priest-ShadowUI]])
        bar.icon:SetDesaturated(true)
        bar.icon:SetVertexColor(1, .96, .41)
        bar.icon:SetSize(bar:GetSize())
        bar.icon:SetPoint("CENTER", bar, "CENTER")

        classPower[i] = bar
    end

    return classPower
end

-- Returns a ClassPower structure, to be used as self.ClassPower
Hiui.splitLevel_HolyPower = function(parent, name)
    local classPower = {}
    for i = 1, 5 do
        local bar = CreateFrame("StatusBar", name .. "ClassPowerSegment" .. i, parent)

        -- This disables the "default" oUF combo point texture.
        bar:SetStatusBarTexture([[Interface\PlayerFrame\Priest-ShadowUI]])	--Anything
        bar:GetStatusBarTexture():SetColorTexture(0, 0, 0, 0)

        -- HealthArt is Artwork 2
        bar.icon = bar:CreateTexture(nil, "ARTWORK", nil, 3)

        bar:SetAllPoints(parent.HealthArt) -- TODO: fix - HARDCODED!
        bar.icon:SetAllPoints(bar)

        bar.icon:SetTexCoord(377/512, 0, 0, 60/64) -- default, flipped.
        bar.icon:SetTexture([[Interface\AddOns\oUF_Hiui\textures\splitLevel\power\HolyPower]] .. i)
        --Icon:SetVertexColor(252/255, 233/255, 79/255) -- no work

        classPower[i] = bar
    end

    return classPower
end

Hiui.splitLevel_CastBar = function(parent, name)
    local t = parent.template
    local u = parent.unit
    --local stdLine = parent.Health:GetHeight()/4
    local stdLine = 6/60 * parent:GetHeight()
    local dblLine = stdLine * 2
    local iconHeight = 26/60 * parent:GetHeight()

    local castbar = CreateFrame("StatusBar", name .. "CastBar", parent)
    castbar:SetFrameLevel(parent.Health:GetFrameLevel() + 1)

    castbar:SetStatusBarTexture([[Interface/AddOns/oUF_Hiui/textures/splitLevel/castbar]])
    local statusbar = castbar:GetStatusBarTexture()

    if parent.screenSide == "right" then
        statusbar:SetTexCoord(1, 0, 1, 0)
    end

    --castbar:SetWidth(parent.HealthBg)
    -- MAGIC NUMBERS
    castbar:SetPoint("BOTTOMLEFT", parent.Health, "TOPLEFT")
    castbar:SetPoint("BOTTOMRIGHT", parent.Health, "TOPRIGHT")
    castbar:SetHeight(stdLine)
    --castbar:SetHeight(20) -- testing

    local bg = castbar:CreateTexture(nil, "OVERLAY")
    bg:SetAllPoints(castbar)
    bg:SetTexture(0, 0, 0, 0)
    --bg:SetTexture(1, 1, 1, 1) -- rgba

    -- test values for this section from oUF/elements/castbar.lua
    local spark = castbar:CreateTexture(nil, "OVERLAY")
    spark:SetSize(dblLine, dblLine)
    spark:SetBlendMode("ADD")
    spark:SetPoint("CENTER", statusbar, "RIGHT")

    local timer = castbar:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    if parent.screenSide == "left" then
        timer:SetPoint("BOTTOMLEFT", parent.Health, "CENTER", 0, 1)
    else
        timer:SetPoint("BOTTOMRIGHT", parent.Health, "CENTER", 0, 1)
    end

    local spellName = castbar:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    if parent.screenSide == "left" then
        spellName:SetPoint("TOPLEFT", parent.Health, "CENTER", 0, -1)
    else
        spellName:SetPoint("TOPRIGHT", parent.Health, "CENTER", 0, -1)
    end

    local shield = castbar:CreateTexture(nil, "OVERLAY")
    shield:SetTexture([[Interface/AddOns/oUF_Hiui/textures/shieldsmall]]) -- TODO: broke AF
    --shield:SetSize(dblLine, dblLine)
    shield:SetSize(iconHeight * 1.5, iconHeight * 3) -- magic number
    shield:SetPoint("LEFT", castbar, "BOTTOM")

    local icon = castbar:CreateTexture(nil, "OVERLAY", nil, select(2, shield:GetDrawLayer()) + 1)
    icon:SetSize(iconHeight, iconHeight)
    icon:SetPoint("CENTER", shield)
    -- if parent.screenSide == "Left" then
    --     icon:SetPoint("LEFT", parent.Health, "BOTTOMRIGHT")
    -- else
    --     icon:SetPoint("RIGHT", parent.Health, "BOTTOMLEFT")
    -- end

    -- SafeZone - latency


    local function InterruptCheck(self, unit)
        if UnitCanAttack("player", unit) then -- hostile colors
            if self.notInterruptible then
                --print("Enemy cast " .. self.spellID .. " - Not interruptable.") -- neutral colors
                statusbar:SetVertexColor(69/255, 63/255, 63/255) -- hot gray, non-interruptable enemy

                spellName:SetFontObject("GameFontNormal")   -- smaller since you
                timer:SetFontObject("GameFontNormal")       -- won't care as much.
            else
                --print("Enemy cast " .. self.spellID .. " - Interruptable.")
                statusbar:SetVertexColor(231/255, 46/255, 35/255) -- interruptable enemy

                spellName:SetFontObject("GameFontNormalLarge")
                timer:SetFontObject("GameFontNormalLarge")
            end
        elseif UnitCanAssist("player", unit) then -- friendly colors
            --print("Friendly cast - " .. self.spellID)
            local t = RAID_CLASS_COLORS[select(2, UnitClass(unit))]
            statusbar:SetVertexColor(t.r, t.g, t.b)
            -- statusbar:SetVertexColor(220/255, 220/255, 220/255) -- friendly

            spellName:SetFontObject("GameFontNormal")   -- smaller since you
            timer:SetFontObject("GameFontNormal")       -- won't care as much.
        else
            print("NPC(?) cast - " .. self.spellID)
            statusbar:SetVertexColor(220/255, 220/255, 220/255) -- friendly

            spellName:SetFontObject("GameFontNormal")   -- smaller since you
            timer:SetFontObject("GameFontNormal")       -- won't care as much.
        end
    end

    castbar.PostCastInterruptible = InterruptCheck

    castbar.PostCastStart  = function(self, unit)
        InterruptCheck(self, unit)
    end
    castbar.PostCastUpdate = InterruptCheck

    castbar.PostCastFail = function(self, unit, spellID)
        --print("Post cast fail.")
        statusbar:SetVertexColor(231/255, 46/255, 35/255) -- comfort red
    end

    castbar.PostCastStop = function(self, unit, spellID)
        --print("Post cast stop.")
        statusbar:SetVertexColor(69/255, 63/255, 63/255) -- hot gray
    end


    castbar.timeToHold = 1.5


    castbar.bg = bg
    castbar.Spark = spark
    castbar.Time = timer
    castbar.Text = spellName
    castbar.Icon = icon
    castbar.Shield = shield

    return castbar
end
