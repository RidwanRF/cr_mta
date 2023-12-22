local rpTest = {}

function startRPTest()
    if maxQuestions > #questions then
        maxQuestions = #questions
        neededToComplete = math.floor(#questions * multipler)
    end
    alpha = 0
    multipler = 1
    
    stopLoginPanel()
    --requestTextBars
    hasQuestions = {}
    page = "RPTest"
    selected = 5
    questionsQuested = 0
    successQuestions = 0
    nextQuestion()
    addEventHandler("onClientRender", root, drawnRPTest, true, "low-5")
    --createLogoAnimation(1, {sx/2, sy/2 - 225})
    exports['cr_infobox']:addBox("info", "Az interakcióhoz használd az 'Enter' billentyűt!")
    exports["cr_infobox"]:addBox("info", "Ahhoz, hogy regisztrálhass szükséges, hogy kitölts egy RP tesztet!")
    exports["cr_infobox"]:addBox("warning", "Minimum "..100*rtMultipler.."%-t kell elérj!")
    bindKey("enter", "down", interactToEnter)
end

function stopRPTest()
    hasQuestions = {}
    page = "RPTest"
    selected = 5
    questionsQuested = 0
    successQuestions = 0
    removeEventHandler("onClientRender", root, drawnRPTest, true, "low-5")
    unbindKey("enter", "down", interactToEnter)
    --stopLogoAnimation()
end

function interactToEnter()
    if selected == 5 then
        exports["cr_infobox"]:addBox("error", "Válasz ki egy választ!")
        return
    end
    local correctAnswer = questions[nowQuestion][6]
    if correctAnswer == selected then
        successQuestions = successQuestions + 1
    end
    
    if questionsQuested + 1 > maxQuestions then
        finishRPTest()
        return
    else
        nextQuestion()
        return
    end
end

function finishRPTest()
    if successQuestions >= neededToComplete then
        local theMultipler = math.floor((successQuestions/maxQuestions) * 100)
        if theMultipler == inf or tostring(theMultipler) == "inf" then
            theMultipler = 0
        end
        exports["cr_infobox"]:addBox("success", "Sikeresen teljesítetted a tesztet! Most már regisztrálhatsz (".. theMultipler .."%-t értél el)")
        stopRPTest()
        startRegisterPanel()
        
        saveJSON["haveRPTest"] = true
        --GoToReg
    else
        local theMultipler = math.floor((successQuestions/maxQuestions) * 100)
        if theMultipler == inf or tostring(theMultipler) == "inf" then
            theMultipler = 0
        end
        --outputChatBox(neededToComplete/successQuestions)
        exports["cr_infobox"]:addBox("error", "Mivel nem érted el a "..100*rtMultipler.."%-t (".. theMultipler .."%-t értél el) ezért újra kell kezd a tesztet")
        restartRPTest()
    end
end

function restartRPTest()
    exports["cr_infobox"]:addBox("warning", "Minimum "..100*rtMultipler.."%-t kell elérj!")
    hasQuestions = {}
    page = "RPTest"
    selected = 5
    questionsQuested = 0
    successQuestions = 0
    nextQuestion()
end

function nextQuestion()
    local newQuestionID = math.random(1, #questions)
    if hasQuestions[newQuestionID] then
        nextQuestion()
        return
    end
    
    nowQuestion = newQuestionID
    hasQuestions[nowQuestion] = true
    questionsQuested = questionsQuested + 1
    selected = 5
end

function drawnRPTest()
    if alpha + multipler <= 255 then
        alpha = alpha + multipler
    elseif alpha >= 255 then
        alpha = 255
    end
    dxDrawImage(sx/2 - size["login-bg-X"]/2, sy/2 - size["login-bg-Y"]/2, size["login-bg-X"], size["login-bg-Y"], f .. "rptest-bg.png", 0,0,0, tocolor(255,255,255,alpha))
    
    local questionAnswerOne = questions[nowQuestion][2]
    if selected == 1 then
        dxDrawImage(sx/2 - size["login-bg-X"]/2, sy/2 - size["login-bg-Y"]/2, size["login-bg-X"], size["login-bg-Y"], f .. "rptest-bg-box-1-selected.png", 0,0,0, tocolor(255,255,255,alpha))
        dxDrawText(questionAnswerOne, sx/2 - 480/2, sy/2 - 80, sx/2 - 480/2 + 478, sy/2 - 80 + 46, tocolor(0,0,0,alpha), 1, fonts["default-regular"], "center", "center")
    elseif isInSlot(sx/2 - 480/2, sy/2 - 76, 478, 42) then
        dxDrawImage(sx/2 - size["login-bg-X"]/2, sy/2 - size["login-bg-Y"]/2, size["login-bg-X"], size["login-bg-Y"], f .. "rptest-bg-box-1-active.png", 0,0,0, tocolor(255,255,255,alpha))
        dxDrawText(questionAnswerOne, sx/2 - 480/2, sy/2 - 80, sx/2 - 480/2 + 478, sy/2 - 80 + 46, tocolor(255,255,255,alpha), 1, fonts["default-regular"], "center", "center")
    else
        dxDrawImage(sx/2 - size["login-bg-X"]/2, sy/2 - size["login-bg-Y"]/2, size["login-bg-X"], size["login-bg-Y"], f .. "rptest-bg-box-1-deactive.png", 0,0,0, tocolor(255,255,255,alpha))
        dxDrawText(questionAnswerOne, sx/2 - 480/2, sy/2 - 80, sx/2 - 480/2 + 478, sy/2 - 80 + 46, tocolor(255,255,255,alpha), 1, fonts["default-regular"], "center", "center")
    end
    
    local questionAnswerTwo = questions[nowQuestion][3]
    if selected == 2 then
        dxDrawImage(sx/2 - size["login-bg-X"]/2, sy/2 - size["login-bg-Y"]/2, size["login-bg-X"], size["login-bg-Y"], f .. "rptest-bg-box-2-selected.png", 0,0,0, tocolor(255,255,255,alpha))
        dxDrawText(questionAnswerTwo, sx/2 - 480/2, sy/2 - 29, sx/2 - 480/2 + 478, sy/2 - 29 + 46, tocolor(0,0,0,255), 1, fonts["default-regular"], "center", "center")
    elseif isInSlot(sx/2 - 480/2, sy/2 - 29, 478, 46) then
        dxDrawImage(sx/2 - size["login-bg-X"]/2, sy/2 - size["login-bg-Y"]/2, size["login-bg-X"], size["login-bg-Y"], f .. "rptest-bg-box-2-active.png", 0,0,0, tocolor(255,255,255,alpha))
        dxDrawText(questionAnswerTwo, sx/2 - 480/2, sy/2 - 29, sx/2 - 480/2 + 478, sy/2 - 29 + 46, tocolor(255,255,255,alpha), 1, fonts["default-regular"], "center", "center")
    else
        dxDrawImage(sx/2 - size["login-bg-X"]/2, sy/2 - size["login-bg-Y"]/2, size["login-bg-X"], size["login-bg-Y"], f .. "rptest-bg-box-2-deactive.png", 0,0,0, tocolor(255,255,255,alpha))
        dxDrawText(questionAnswerTwo, sx/2 - 480/2, sy/2 - 29, sx/2 - 480/2 + 478, sy/2 - 29 + 46, tocolor(255,255,255,alpha), 1, fonts["default-regular"], "center", "center")
    end
    
    local questionAnswerThree = questions[nowQuestion][4]
    if selected == 3 then
        dxDrawImage(sx/2 - size["login-bg-X"]/2, sy/2 - size["login-bg-Y"]/2, size["login-bg-X"], size["login-bg-Y"], f .. "rptest-bg-box-3-selected.png", 0,0,0, tocolor(255,255,255,alpha))
        dxDrawText(questionAnswerThree, sx/2 - 480/2, sy/2 + 21, sx/2 - 480/2 + 478, sy/2 + 21 + 46, tocolor(0,0,0,alpha), 1, fonts["default-regular"], "center", "center")
    elseif isInSlot(sx/2 - 480/2, sy/2 + 21, 478, 46) then
        dxDrawImage(sx/2 - size["login-bg-X"]/2, sy/2 - size["login-bg-Y"]/2, size["login-bg-X"], size["login-bg-Y"], f .. "rptest-bg-box-3-active.png", 0,0,0, tocolor(255,255,255,alpha))
        dxDrawText(questionAnswerThree, sx/2 - 480/2, sy/2 + 21, sx/2 - 480/2 + 478, sy/2 + 21 + 46, tocolor(255,255,255,alpha), 1, fonts["default-regular"], "center", "center")
    else    
        dxDrawImage(sx/2 - size["login-bg-X"]/2, sy/2 - size["login-bg-Y"]/2, size["login-bg-X"], size["login-bg-Y"], f .. "rptest-bg-box-3-deactive.png", 0,0,0, tocolor(255,255,255,alpha))
        dxDrawText(questionAnswerThree, sx/2 - 480/2, sy/2 + 21, sx/2 - 480/2 + 478, sy/2 + 21 + 46, tocolor(255,255,255,alpha), 1, fonts["default-regular"], "center", "center")
    end
    
    local questionAnswerFour = questions[nowQuestion][5]
    if selected == 4 then
        dxDrawImage(sx/2 - size["login-bg-X"]/2, sy/2 - size["login-bg-Y"]/2, size["login-bg-X"], size["login-bg-Y"], f .. "rptest-bg-box-4-selected.png", 0,0,0, tocolor(255,255,255,alpha))
        dxDrawText(questionAnswerFour, sx/2 - 480/2, sy/2 + 71, sx/2 - 480/2 + 478, sy/2 + 71 + 46, tocolor(0,0,0,alpha), 1, fonts["default-regular"], "center", "center")
    elseif isInSlot(sx/2 - 480/2, sy/2 + 71, 478, 46) then
        dxDrawImage(sx/2 - size["login-bg-X"]/2, sy/2 - size["login-bg-Y"]/2, size["login-bg-X"], size["login-bg-Y"], f .. "rptest-bg-box-4-active.png", 0,0,0, tocolor(255,255,255,alpha))
        dxDrawText(questionAnswerFour, sx/2 - 480/2, sy/2 + 71, sx/2 - 480/2 + 478, sy/2 + 71 + 46, tocolor(255,255,255,alpha), 1, fonts["default-regular"], "center", "center")
    else
        dxDrawImage(sx/2 - size["login-bg-X"]/2, sy/2 - size["login-bg-Y"]/2, size["login-bg-X"], size["login-bg-Y"], f .. "rptest-bg-box-4-deactive.png", 0,0,0, tocolor(255,255,255,alpha))
        dxDrawText(questionAnswerFour, sx/2 - 480/2, sy/2 + 71, sx/2 - 480/2 + 478, sy/2 + 71 + 46, tocolor(255,255,255,alpha), 1, fonts["default-regular"], "center", "center")
    end
    
    local question = questions[nowQuestion][1]
    dxDrawText(question, sx/2 - 488/2, sy/2 - 152, sx/2 - 488/2 + 487, sy/2 - 152 + 70, tocolor(255,255,255,alpha), 1, fonts["default-bold"], "center", "center")
end

function rpTest.onClick(b, s)
--    outputChatBox(page)
    if page == "RPTest" then
        if b == "left" and s == "down" then
            if isInSlot(sx/2 - 480/2, sy/2 - 76, 478, 42) then
                if lastClickTick + 500 > getTickCount() then
                    return
                end
                
                if selected ~= 1 then
                    selected = 1
                elseif selected == 1 then
                    selected = 5
                end
                lastClickTick = getTickCount()
            elseif isInSlot(sx/2 - 480/2, sy/2 - 29, 478, 46) then
                if lastClickTick + 500 > getTickCount() then
                    return
                end
                
                if selected ~= 2 then
                    selected = 2
                elseif selected == 2 then
                    selected = 5
                end
                lastClickTick = getTickCount()
            elseif isInSlot(sx/2 - 480/2, sy/2 + 21, 478, 46) then
                if lastClickTick + 500 > getTickCount() then
                    return
                end
                
                if selected ~= 3 then
                    selected = 3
                elseif selected == 3 then
                    selected = 5
                end
                lastClickTick = getTickCount()
            elseif isInSlot(sx/2 - 480/2, sy/2 + 71, 478, 46) then
                if lastClickTick + 500 > getTickCount() then
                    return
                end
                
                if selected ~= 4 then
                    selected = 4
                elseif selected == 4 then
                    selected = 5
                end
                lastClickTick = getTickCount()
            end
        end
    end
end
addEventHandler("onClientClick", root, rpTest.onClick)