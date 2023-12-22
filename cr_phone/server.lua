local phoneDatas = {};

phoneDatas["111-111-111"] = {};
phoneDatas["111-111-111"]["Host"] = 1;
phoneDatas["111-111-111"]["Balance"] = 1000;
phoneDatas["111-111-111"]["contacts"] = {};
phoneDatas["111-111-111"]["contacts"][1] = {1, "Béla", "111-111-112"};
phoneDatas["111-111-111"]["contacts"][2] = {2, "Béla", "111-111-113"};
phoneDatas["111-111-111"]["contacts"][3] = {3, "Béla", "111-111-114"};
phoneDatas["111-111-111"]["contacts"][4] = {4, "Béla", "111-111-115"};
phoneDatas["111-111-111"]["sms"] = {};
phoneDatas["111-111-111"]["sms"][1] = {1, "1 sms", "111-111-112"};
phoneDatas["111-111-111"]["sms"][2] = {2, "2 sms", "111-111-113"};
phoneDatas["111-111-111"]["sms"][3] = {3, "3 sms", "111-111-114"};
phoneDatas["111-111-111"]["sms"][4] = {4, "4 sms", "111-111-115"};
phoneDatas["111-111-111"]["sms"][5] = {5, "5 sms", "111-111-116"};
phoneDatas["111-111-111"]["calls"] = {};

addEvent("server -> requestPhoneDatas", true);
addEventHandler("server -> requestPhoneDatas", getRootElement(), function(number)
    if client then
        triggerClientEvent(client, "client -> requestPhoneDatas", client, phoneDatas[number] or {});    
    end
end);