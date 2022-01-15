
function resourceStart()
    if not isVoiceEnabled() then
        cancelEvent(true, "[Scyte-Voice] Te rugăm să urmărești tutorial-ul de instalare de pe https://docs.scyte.ro/mta/tutoriale/voice în întregime!")
        outputDebugString("[Scyte-Voice] Te rugăm să urmărești tutorial-ul de instalare de pe https://docs.scyte.ro/mta/tutoriale/voice în întregime!", 3)
    end
end
addEventHandler("onResourceStart", resourceRoot, resourceStart)