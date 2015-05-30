integer LINK_STATISTICS = 100;
integer LINK_PARTY = 102;
integer LINK_STATUS_AWAY_HUB = 200;
integer LINK_SCANNER_REQUEST = 400;
integer LINK_INPUT = 602;
integer attackDelay = FALSE;
integer PartyChecksum = 0;

float distRanged  = 36.0;
float distMelee   = 3.0;
float delayNormal = 1.4;
float delayFlurry = 0.9;
integer dmgMinMelee = 75;
integer dmgMinRanged = 50;
integer dmgSpreadMelee = 225;
integer dmgSpreadRanged = 200;
float dmgMult = 1.0;

list Attributes = ["STR", 0, "DEX", 0, "VIT", 0, "MAG", 0, "SPR", 0, "LUK", 0,
                   "MHP", 0, "MMP", 0, "CHP", 0, "CMP", 0];
list StatusTracker = ["NULL", 0, "NULL", 0, "NULL", 0, "NULL", 0,
                      "NULL", 0, "NULL", 0, "NULL", 0, "NULL", 0,
                      "NULL", 0, "NULL", 0];

string formatAttack(integer party, string hpMod, integer hpMin, integer hpRange, string damageType, 
    string mpMod, integer mpChange, integer potency, integer luck, string vfx,
    integer numKeywords, list keywords, integer numEffects, list effects){
    list dump = [party, hpMod, hpMin, hpRange, damageType, mpMod, mpChange, 
                 potency, luck, vfx, numKeywords, llList2CSV(keywords), numEffects, llList2CSV(effects)];
    return llList2CSV(dump);
}
integer GetAtt(string id){
         if(id == "STR") return llList2Integer(Attributes, 1);
    else if(id == "DEX") return llList2Integer(Attributes, 3);
    else if(id == "VIT") return llList2Integer(Attributes, 5);
    else if(id == "MAG") return llList2Integer(Attributes, 7);
    else if(id == "SPR") return llList2Integer(Attributes, 9);
    else if(id == "LUK") return llList2Integer(Attributes, 11);
    else if(id == "MHP" || id == "HP") return llList2Integer(Attributes, 13);
    else if(id == "MMP" || id == "MP") return llList2Integer(Attributes, 15);
    return -255;
}
integer GetStackStatus(string id){
         if(id == "PHYSDEF") return llList2Integer(StatusTracker, 1);
    else if(id == "MAGDEF")  return llList2Integer(StatusTracker, 3);
    else if(id == "PHYSPOW") return llList2Integer(StatusTracker, 5);
    else if(id == "MAGPOW")  return llList2Integer(StatusTracker, 7);
    else if(id == "EVASION") return llList2Integer(StatusTracker, 9);
    else if(id == "ACCURAC") return llList2Integer(StatusTracker, 11);
    else if(id == "TIMFACT") return llList2Integer(StatusTracker, 13);
    else if(id == "CRITICA") return llList2Integer(StatusTracker, 13);
    else if(id == "CUREMOD") return llList2Integer(StatusTracker, 15);
    else if(id == "HPOTIME") return llList2Integer(StatusTracker, 17);
    else llOwnerSay("ERROR 009");
    return 0;
}
calcDamageValues(){
    string status = llList2String(StatusTracker, 4);
    if(status == "BRAVERY")
        dmgMult = 1.3333;
    if(status == "FEAR")
        dmgMult = 0.6666;
    if(status == "NULL")
        dmgMult = 1.0;
}
default
{
    link_message(integer origin, integer linknum, string str, key id){
        if(linknum == LINK_STATISTICS){
            Attributes = llCSV2List(str);
        }
        if(linknum == LINK_STATUS_AWAY_HUB){
            StatusTracker = llCSV2List(str);
        }
        if(linknum == LINK_PARTY){
            PartyChecksum = (integer)str;
        }
        if(linknum == LINK_INPUT){
            if(str == "EVENT_MELEE" && !attackDelay){
                string output = formatAttack(
                    PartyChecksum,
                    "SUB", llRound(dmgMinMelee * dmgMult), llRound(dmgSpreadMelee * dmgMult), "0", //fix damage type later 
                    "NULL", 0, GetAtt("STR"), GetAtt("LUK"), "NULL", //change if elemental
                    2, ["NORMAL", "NEGATIVE"], 
                    0, []);
                
                llMessageLinked(LINK_THIS, LINK_SCANNER_REQUEST, "CONE;AGENT;"+(string)distMelee+";"+output+";-9823645;NULL", NULL_KEY);
                attackDelay = TRUE;
                if(llList2String(StatusTracker, 12) == "FLURRY")
                    llSetTimerEvent(delayFlurry);
                else
                    llSetTimerEvent(delayNormal);
            }
            if(str == "EVENT_RANGED" && !attackDelay){
                string output = formatAttack(
                    PartyChecksum,
                    "SUB", llRound(dmgMinRanged * dmgMult), llRound(dmgSpreadRanged * dmgMult), "0", //fix damage type later 
                    "NULL", 0, GetAtt("DEX"), GetAtt("LUK"), "NULL", //change if elemental
                    2, ["NORMAL", "NEGATIVE"], 
                    0, []);
                
                llMessageLinked(LINK_THIS, LINK_SCANNER_REQUEST, "RAY;AGENT;"+(string)distRanged+";"+output+";-9823645;NULL", NULL_KEY);
                attackDelay = TRUE;
                if(llList2String(StatusTracker, 12) == "FLURRY")
                    llSetTimerEvent(delayFlurry);
                else
                    llSetTimerEvent(delayNormal);
            }
        }
    }
    timer(){
        attackDelay = FALSE;
        llSetTimerEvent(0);
    }
}
