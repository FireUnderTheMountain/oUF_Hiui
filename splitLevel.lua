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
        --bar:SetPoint("BOTTOMRIGHT", name .. "PowerBar", "TOPRIGHT", -(i - 1) * magicnumber, 0)
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
