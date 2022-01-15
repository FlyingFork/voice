local versionFile = fileExists("version.cfg") and fileOpen("version.cfg") or fileCreate("version.cfg")
local version = tonumber(fileRead(versionFile, fileGetSize(versionFile))) or 0
fileClose(versionFile)

local branch = "main"
local resourceName = ""
local repo = "FlyingFork/voice"

local _fetchRemote = fetchRemote
function fetchRemote(...)
	if not hasObjectPermissionTo(getThisResource(),"function.fetchRemote",true) then
		outputDebugString("[Scyte-Voice] Te rugăm să execuți comanda 'aclrequest allow " .. resourceName .. " all' în consolă", 2)
		return false
	end
	return _fetchRemote(...)
end

local remoteVersion = 0
function checkUpdate(res)
    if res then
        resourceName = getResourceName(res)
    end

    fetchRemote("https://raw.githubusercontent.com/" .. repo .. "/" .. branch .. "/version.cfg", function(data, err)
        if err == 0 then
            remoteVersion = tonumber(data)
            if remoteVersion > version then
                outputDebugString("[Scyte-Voice] Resursa se updatează!")
                startUpdate()
            end
        else
            outputDebugString("[Scyte-Voice] Nu se poate verifica dacă ultima versiune a resursei este instalată!")
        end
    end)

    setTimer(checkUpdate, (59 - getRealTime().minute) * 60000, 1)
end
addEventHandler("onResourceStart", resourceRoot, checkUpdate, false)

function startUpdate()
    setTimer(function()
        fetchRemote("https://raw.githubusercontent.com/" .. repo .. "/" .. branch .. "/meta.xml", function(data, err)
            if err == 0 then
                if fileExists("updater/meta.xml") then
                    fileDelete("updater/meta.xml")
                end

                local meta = fileCreate("updater/meta.xml")
                fileWrite(meta, data)
                fileClose(meta)

                getFolder()
            else
                outputDebugString("[Scyte-Voice] Nu se poate face update la resursă!")
            end
        end)
    end, 50, 1)
end

local count = 0
local files = {}
local folders = {}
local toUpdate = {}
function getFolder(path, nextPath)
    nextPath = nextPath or ""
    fetchRemote(path or "https://api.github.com/repos/" .. repo .. "/git/trees/" .. branch, function(data, err)
        if err == 0 then
            local jsonData = fromJSON(data)
            folders[jsonData.sha] = nil
            for i, entry in pairs(jsonData.tree) do
                if entry.path ~= "meta.xml" then
                    local path = nextPath .. entry.path
                    if entry.mode == "040000" then
                        folders[entry.sha] = true
                        getFolder(entry.url, path .. "/")
                    else
                        files[path] = entry.sha
                    end
                end
            end
            if not next(folders) then
                checkFiles()
            end
        else
            outputDebugString("[Scyte-Voice] Nu se poate face update la resursă!")
        end
    end)
end

function checkFiles()
    local xml = xmlLoadFile("updater/meta.xml")
    for i, entry in pairs(xmlNodeGetChildren(xml)) do
        if xmlNodeGetName(entry) == "script" or xmlNodeGetName(entry) == "file" then
            local path = xmlNodeGetAttribute(entry, "src")
            if path ~= "meta.xml" then
                local sha = ""
                if fileExists(path) then
                    local file = fileOpen(path)
                    local size = fileGetSize(file)
                    local text = fileRead(file, size)
                    fileClose(file)
                    
                    sha = hash("sha1", "blob " .. size .. "\0" ..text)
                end

                if sha ~= files[path] then
                    table.insert(toUpdate, path)
                end
            end
        end
    end

    downloadUpdate()
end

function downloadUpdate()
    count = count + 1
    if not toUpdate[count] then
        return downloadFinish()
    end

    fetchRemote("https://raw.githubusercontent.com/" .. repo .. "/" .. branch .. "/" .. toUpdate[count], function(data, err, path)
        if err == 0 then
            if fileExists(path) then
                fileDelete(path)
            end

            local file = fileCreate(path)
            fileWrite(file, data)
            fileClose(file)
        else
            outputDebugString("[Scyte-Voice] Nu se poate face update la resursă!")
        end

        if toUpdate[count + 1] then
            downloadUpdate()
        else
            downloadFinish()
        end
    end, "", false, toUpdate[count])
end

function downloadFinish()
    if fileExists("version.cfg") then
        fileDelete("version.cfg")
    end

    local file = fileCreate("version.cfg")
    fileWrite(file, tostring(remoteVersion))
    fileClose(file)

    if fileExists("meta.xml") then
        fileDelete("meta.xml")
    end

    local meta = fileOpen("updater/meta.xml")
    local data = fileRead(meta, fileGetSize(meta))
    fileClose(meta)

    local newMeta = fileCreate("meta.xml")
    fileWrite(newMeta, data)
    fileClose(newMeta)

    fileDelete("updater/meta.xml")

    toUpdate = {}
    count = 0

    outputDebugString("[Scyte-Voice] Ultima versiune a resursei a fost instalată!")
    restartResource(getThisResource(), false, true, true, true, true, true, true, true)
end