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
    local stdLine = parent.Health:GetHeight()/2

    local castbar = CreateFrame("StatusBar", name .. "CastBar", parent)

    --castbar:SetWidth(parent.HealthBg)
    -- MAGIC NUMBERS
    castbar:SetPoint("TOPLEFT", parent.Health, "TOPLEFT")
    castbar:SetPoint("TOPRIGHT", parent.Health, "TOPRIGHT")
    --castbar:SetHeight(parent.Health:GetHeight()/2)
    castbar:SetHeight(20) -- testing

    local bg = castbar:CreateTexture(nil, "OVERLAY")
    bg:SetAllPoints(castbar)
    bg:SetTexture(0, 0, 0, 0)
    --bg:SetTexture(1, 1, 1, 1) -- rgba

    -- test values for this section from oUF/elements/castbar.lua
    local spark = castbar:CreateTexture(nil, "OVERLAY")
    spark:SetSize(20,20)
    spark:SetBlendMode("ADD")
    spark:SetPoint("CENTER", castbar:GetStatusBarTexture(), "RIGHT")

    local timer = castbar:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    if parent.screenSide == "left" then
        timer:SetPoint("TOPLEFT", castbar, "TOP", 0, -2)
    else
        timer:SetPoint("TOPRIGHT", castbar, "TOP", 0, -2)
    end

    local spellName = castbar:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    if parent.screenSide == "left" then
        spellName:SetPoint("BOTTOMLEFT", parent.Health, "BOTTOM", 0, 2)
    else
        spellName:SetPoint("BOTTOMRIGHT", parent.Health, "BOTTOM", 0, 2)
    end

    local icon = castbar:CreateTexture(nil, "OVERLAY")
    icon:SetSize(parent.Health:GetHeight()/2, parent.Health:GetHeight()/2)

    local shield = castbar:CreateTexture(nil, "OVERLAY") -- not needed.
    shield:SetSize(stdLine, stdLine) -- testing
    shield:SetPoint("RIGHT", castbar)
    -- SafeZone - latency

    castbar.bg = bg
    castbar.Spark = spark
    castbar.Time = timer
    castbar.Text = spellName
    castbar.Icon = icon
    castbar.Shield = shield

    return castbar
end
