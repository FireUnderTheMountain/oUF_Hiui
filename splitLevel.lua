local _, Hiui = ...
local default = Hiui.default.splitLevel
--local default = Hiui.custom or Hiui.default

Hiui.splitLevel_DefaultClassPower = function(self, name, point1, point2)
    local magicnumber = 16 -- TODO: fix = MAGIC NUMBER!
    local classPower = {}
    for i = 1, 10 do
        local Bar = CreateFrame("StatusBar", name .. "ClassPowerSegment" .. i, self)

        -- This disables the "default" oUF combo point texture.
        Bar:SetStatusBarTexture([[Interface\PlayerFrame\Priest-ShadowUI]])	--Anything
        Bar:GetStatusBarTexture():SetColorTexture(0, 0, 0, 0)

        Bar:SetSize(magicnumber, magicnumber)

        -- TODO: fix - out of scope reference / magic reference to 'name .. "PowerBar"' and position.
        Bar:SetPoint("BOTTOMRIGHT", name .. "PowerBar", "TOPRIGHT", -(i - 1) * magicnumber, 0)


        -- HealthArt is Artwork 2
        local Icon = Bar:CreateTexture(nil, "ARTWORK", nil, 3)

        Icon:SetTexCoord(0.45703125, 0.60546875, 0.44531250, 0.73437500)
        Icon:SetTexture([[Interface\PlayerFrame\Priest-ShadowUI]])
        Icon:SetDesaturated(true)
        Icon:SetVertexColor(1, .96, .41)
        Icon:SetSize(Bar:GetSize())
        Icon:SetPoint("CENTER", Bar, "CENTER")


        classPower[i] = Bar
    end

    return classPower
end

-- Returns a ClassPower structure, to be used as self.ClassPower
Hiui.splitLevel_HolyPower = function(self, name)
    local classPower = {}
    for i = 1, 5 do
        local bar = CreateFrame("StatusBar", name .. "ClassPowerSegment" .. i, self)

        -- This disables the "default" oUF combo point texture.
        bar:SetStatusBarTexture([[Interface\PlayerFrame\Priest-ShadowUI]])	--Anything
        bar:GetStatusBarTexture():SetColorTexture(0, 0, 0, 0)

        -- HealthArt is Artwork 2
        local Icon = bar:CreateTexture(nil, "ARTWORK", nil, 3)

        bar:SetAllPoints(self.HealthArt) -- TODO: fix - HARDCODED!
        Icon:SetAllPoints(bar)

        Icon:SetTexCoord(377/512, 0, 0, 60/64) -- default, flipped.
        Icon:SetTexture([[Interface\AddOns\oUF_Hiui\textures\splitLevel\power\HolyPower]] .. i)
        --Icon:SetVertexColor(252/255, 233/255, 79/255) -- no work

        classPower[i] = bar
    end

    return classPower
end
