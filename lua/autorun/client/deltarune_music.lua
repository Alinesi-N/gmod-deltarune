if SERVER then return end
CreateClientConVar("deltarune_music_volume", "100", true, true,"",0,100)
local AudioSource = nil
local DELTARUNEBGMSafety = false
local cool = false
DELTARUNEBGMPlaying = false
DELTARUNEToEnd = nil

function DELTARUNE_MUSIC_STOP(en)
    if DELTARUNEBGMSafety then return end
    if AudioSource != nil then
        AudioSource:Stop()
    end
    AudioSource = nil
    DELTARUNEBGMIntro = false
    DELTARUNEBGMPlaying = false
    DELTARUNEBGMSafety = false
    if (en==nil or en=="" or en==" " or en == "empty") and DELTARUNEToEnd != nil then
        en = DELTARUNEToEnd
    end
    DELTARUNEToEnd = nil
    if en!=nil then
        sound.PlayFile("sound/"..en,"",function(source, err, errname)
            if IsValid(source) then
                source:Play()
                source:SetVolume( LocalPlayer():GetInfo("deltarune_music_volume")/100 )
            end
        end)
    end
end
function DELTARUNE_MUSIC_START(loop,intro,en)
    if !isstring(loop) or DELTARUNEBGMPlaying then return end
    local delay = 0
    DELTARUNEBGMSafety = true
        if en != nil and en != "" and en != " " and en != "empty" then
            DELTARUNEToEnd = en
        end
        if intro != nil and intro != "" and intro != " " and intro != "empty" then
            delay = SoundDuration(intro)
            DELTARUNEToLoop = loop
            sound.PlayFile("sound/"..intro,"",function(source, err, errname)
                if IsValid(source) then
                    AudioSource = source
                    source:Play()
                    source:SetVolume( LocalPlayer():GetInfo("deltarune_music_volume")/100 )
                    DELTARUNEBGMIntro = true
                end
            end)
        else
            if cool then return end
            cool = true
            sound.PlayFile("sound/"..loop,"noblock",function(source, err, errname)
                if IsValid(source) then
                    AudioSource = source
                    source:EnableLooping(true)
                    source:Play()
                    source:SetVolume( LocalPlayer():GetInfo("deltarune_music_volume")/100 )
                    DELTARUNEBGMSafety = false
                    DELTARUNEBGMPlaying = true
                    DELTARUNEBGMIntro = false
                    cool = false
                end
            end)
        end
end
hook.Add("Think","PVZMUSICEnd",function()
    if AudioSource != nil and AudioSource:GetState() == 0 then
        if DELTARUNEBGMIntro and DELTARUNEToLoop != nil then
            DELTARUNE_MUSIC_START(DELTARUNEToLoop)
        else
            DELTARUNE_MUSIC_STOP(DELTARUNEToEnd)
        end
    end
end)