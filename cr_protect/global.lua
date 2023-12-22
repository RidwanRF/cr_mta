function getTriggerName(res, triggerDefName)
    if res then
        local resName = getResourceName(res)
        if resName then
            --outputDebugString("TriggerName requested by: "..resName)
            local hash1 = hash("sha512", triggerDefName)
            local hash2 = hash("md5", "<StayMTA>-<" .. hash1 .. ">-<MTAStay>")
            return hash2
        end
    end
end