hs.loadSpoon("MicMute")

spoon.MicMute:bindHotkeys(
{
    toggle = {
        {"cmd", "shift"}, "M"
    }
},
0.75)

powermate =
    hs.distributednotifications.new(
    function(name, object, userInfo)
        -- print(string.format("name: %s\nobject: %s\nuserInfo: %s\n", name, object, hs.inspect(userInfo)))
        if object == "kPowermateKnobPress" then
            spoon.MicMute.toggleMicMute()
        elseif object == "kPowermateKnobClockwise" then
            device = hs.audiodevice.defaultOutputDevice()
            currentVolume = device:outputVolume() + 1;
            device:setOutputVolume(currentVolume)
        elseif object == "kPowermateKnobCounterClockwise" then
            device = hs.audiodevice.defaultOutputDevice()
            currentVolume = device:outputVolume() - 1;
            device:setOutputVolume(currentVolume)
        end
    end,
    "kPowermateKnobNotification"
)
powermate:start()
