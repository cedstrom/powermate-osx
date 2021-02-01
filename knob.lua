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

-- ramp the led, flash it slow, flash it quickly, turn it off.
for i=0,1,0.1
do
    hs.distributednotifications.post("kPowermateLEDNotification", "org.hammerspoon", { fn = "kPowermateLEDLevel", level=i})
    hs.timer.usleep(250000);
end

hs.timer.doAfter(1,
    function()
        hs.distributednotifications.post("kPowermateLEDNotification", "org.hammerspoon", { fn = "kPowermateLEDFlash", level=15})
        hs.timer.doAfter(10,
            function()
                hs.distributednotifications.post("kPowermateLEDNotification", "org.hammerspoon", { fn = "kPowermateLEDFlash", level=32})
                hs.timer.doAfter(2,
                    function()
                        hs.distributednotifications.post("kPowermateLEDNotification", "org.hammerspoon", { fn = "kPowermateLEDOff"})
                    end
                )
            end
        )
    end
)

