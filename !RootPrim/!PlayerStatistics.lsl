integer LINK_STATISTICS = 100;
integer LINK_EFFECT = 101;
integer LINK_PARTY = 102;
integer LINK_STATUS_AWAY_HUB = 200;
integer LINK_STATUS_TO_HUB = 201;
integer LINK_EVENT = 600;
integer DEBUG_TEXT_ON = TRUE;
key COMMON_KEY = "ffffffff-ffff-ffff-ffff-ffffffffffff";

list RatingModifier   = ["F", "E", "D-","D", "D+","C-","C", "C+","B-","B", "B+","A-","A", "A+","S"];
list RatingAdjust     = [14,  26,  36,  46,  55,  63,  71,  78,  85,  91,  97,  103, 109, 115, 120];

//In order:
//Class, Background, Trait1, Trait2, Trait3, *EquipOff, *EquipDef, *EquipAcc, *Job
//Starred items are adjustments to a letter grade. Unstarred change the base score.

list Attributes = ["STR", 0, "DEX", 0, "VIT", 0, "MAG", 0, "SPR", 0, "LUK", 0,
                   "MHP", 0, "MMP", 0, "CHP", 0, "CMP", 0];

list AttributeSubStorage = ["STR", 0, 0, 0, 0, 0, 0, 0, 0, 0,
                            "DEX", 0, 0, 0, 0, 0, 0, 0, 0, 0,
                            "VIT", 0, 0, 0, 0, 0, 0, 0, 0, 0,
                            "MAG", 0, 0, 0, 0, 0, 0, 0, 0, 0,
                            "SPR", 0, 0, 0, 0, 0, 0, 0, 0, 0,
                            "LUK", 0, 0, 0, 0, 0, 0, 0, 0, 0,
                            "MHP", 0, 0, 0, 0, 0, 0, 0, 0, 0,
                            "MMP", 0, 0, 0, 0, 0, 0, 0, 0, 0];
                            
list StatusTracker = ["NULL", 0, "NULL", 0, "NULL", 0, "NULL", 0,
                      "NULL", 0, "NULL", 0, "NULL", 0, "NULL", 0,
                      "NULL", 0, "NULL", 0];
                      
integer CHP;
integer CMP;
integer PartyChecksum = 0;
list HP_Status_Events = [];

//The big list of link message channels!

calculateStat(string id)
{
    if(llListFindList(["STR","DEX","VIT","MAG","SPR","LUK","MHP","MMP"],[id]) == -1)
        llOwnerSay("ERROR 001: Invalid stat ID!");
        
    integer OldHP = llList2Integer(Attributes, 13);
    integer OldMP = llList2Integer(Attributes, 15);
    
    //ALWAYS use caps on the ID!
    integer index = llListFindList(AttributeSubStorage, [id]);
    integer total = 0;
    
    total += llList2Integer(AttributeSubStorage, index+1);
    total += llList2Integer(AttributeSubStorage, index+2);
    total += llList2Integer(AttributeSubStorage, index+3);
    total += llList2Integer(AttributeSubStorage, index+4);
    total += llList2Integer(AttributeSubStorage, index+5);
    
    integer grade = 1;
    grade += llList2Integer(AttributeSubStorage, index+6);
    grade += llList2Integer(AttributeSubStorage, index+7);
    grade += llList2Integer(AttributeSubStorage, index+8);
    grade += llList2Integer(AttributeSubStorage, index+9);
    
    if(grade < 0) grade = 0;
    if(grade > 14) grade = 14;
    
    total += llList2Integer(RatingAdjust, grade);
    
    if(id == "MHP") total = 4999 + (integer)llRound(5000 * ((float)total / (float)255));
    if(id == "MMP") total = 199 + (integer)llRound(800 * ((float)total / (float)255));;
    
    index = llListFindList(Attributes, [id]);
    
    Attributes = llListReplaceList(Attributes, [total], index+1, index+1);
    
    if(id == "MHP")
        CHP += llList2Integer(Attributes, 13) - OldHP;
    if(id == "MMP")
        CMP += llList2Integer(Attributes, 15) - OldMP;
}
calculateAllStats()
{
    calculateStat("STR");
    calculateStat("DEX");
    calculateStat("VIT");
    calculateStat("MAG");
    calculateStat("SPR");
    calculateStat("LUK");
    calculateStat("MHP");
    calculateStat("MMP");
}
export()
{
    llMessageLinked(LINK_SET, LINK_STATISTICS, llList2CSV(Attributes), NULL_KEY);
}
debugText()
{
    if(DEBUG_TEXT_ON){
        string output;
        integer i;
        for(i=0; i<8; i++){
            output += llList2String(Attributes,i*2)+": "+llList2String(Attributes,i*2+1);
            
            integer grade = 1;
            integer index = llListFindList(AttributeSubStorage, [llList2String(Attributes,i*2)]);
            
            grade += llList2Integer(AttributeSubStorage, index+6);
            grade += llList2Integer(AttributeSubStorage, index+7);
            grade += llList2Integer(AttributeSubStorage, index+8);
            grade += llList2Integer(AttributeSubStorage, index+9);
            output += " ("+llList2String(RatingModifier, grade)+")\n";
        }
        
        output += "HP:"+(string)CHP+"/"+llList2String(Attributes, 13)+"   ";
        output += "MP:"+(string)CMP+"/"+llList2String(Attributes, 15)+"\n";
        output += "S:";
        
        for(i=0;i<llGetListLength(StatusTracker);i+=2){
            if(llList2String(StatusTracker,i) != "NULL"){
                output += "<"+llList2String(StatusTracker,i) + " ×"+llList2String(StatusTracker,i+1)+">";
            }
        }
        llSetText(output,<1,1,1>,1);
    }
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
AddStatusEvent(string eventType){
    if(llListFindList(HP_Status_Events, [eventType]) == -1)
        HP_Status_Events += [eventType];
}

default
{
    state_entry()
    {
        calculateAllStats();
        debugText();
    }
    on_rez(integer param)
    {
        CHP = GetAtt("MHP");
        CMP = GetAtt("MMP");
        export();
    }
    link_message(integer sender, integer linknum, string str, key id)
    {
        if(linknum == LINK_STATUS_AWAY_HUB){
            StatusTracker = llCSV2List(str);
        }
        if(linknum == LINK_PARTY){
            PartyChecksum = (integer)str;
        }
        if(linknum == LINK_EFFECT)
        {
            list parse = llParseString2List(str, [";"], []);
            key filter = llList2Key(parse, 0);
            if(filter == llGetOwner() || filter == COMMON_KEY)
            {
                integer index = 1;
                integer PartyID;
                string HPModForm;
                string MPModForm;
                integer HPModMin = 0;
                integer HPModRange = 0;
                integer MPModMin = 0;
                integer MPModRange = 0;
                string DamageTypes;
                integer Potency = 0;
                integer Luck = 0;
                string VFX;
                integer NumKeywords;
                list Keywords;
                integer NumEffects;
                list StatusEffects;
                
                PartyID = llList2Integer(parse, index);
                index++;
                HPModForm = llList2String(parse, index);
                index++;
                if(HPModForm != "NULL"){
                    HPModMin = llList2Integer(parse, index);
                    index++;
                    HPModRange = llList2Integer(parse, index);
                    index++;
                    DamageTypes = llList2String(parse, index);
                    index++;
                }
                MPModForm = llList2String(parse, index);
                if(MPModForm != "NULL"){
                    MPModMin = llList2Integer(parse, index);
                    index++;
                    MPModRange = llList2Integer(parse, index);
                    index++;
                }
                Potency = llList2Integer(parse, index);
                index++;
                Luck = llList2Integer(parse, index);
                index++;
                VFX = llList2String(parse, index);
                index++;
                NumKeywords = llList2Integer(parse, index);
                index++;
                integer i;
                for(i=0; i<NumKeywords; i++){
                    Keywords += [llList2String(parse, index)];
                    index++;
                }
                i=0;
                NumEffects = llList2Integer(parse, index);
                index++;
                for(i=0; i<NumEffects; i++){
                    StatusEffects += [llList2String(parse, index)]; //ID
                    index++;
                    StatusEffects += [llList2String(parse, index)]; //Stacks/duration
                    index++;
                    integer NumAltValues = llList2Integer(parse, index);
                    index++;
                    integer j;
                    for(j=0; j<NumAltValues; j++){
                        StatusEffects += [llList2String(parse, index)];
                        index++;
                    }
                }
                
                integer doContinue = FALSE;
                //Party Check
                if(PartyID == 0 || PartyChecksum == 0 || llListFindList(Keywords, ["NEUTRAL"]) != -1) //Always hits everyone
                    doContinue = TRUE;
                else if(PartyID == PartyChecksum && llListFindList(Keywords, ["POSITIVE"]) != -1) //If is positive effect & my party, continue
                    doContinue = TRUE;
                else if(PartyID != PartyChecksum && llListFindList(Keywords, ["NEGATIVE"]) != -1) //If is negative effect & not my party, continue
                    doContinue = TRUE;
                    
                integer hasRadius = llListFindList(Keywords, ["RADIUS"]);
                float dist;
                if(hasRadius > -1){
                    vector tPos = (vector)llList2String(Keywords, hasRadius+2);
                    vector mPos = llGetPos();
                    dist = llVecDist(mPos, tPos);
                }
                if(dist > llList2Float(Keywords, hasRadius+1)) {doContinue = FALSE; llOwnerSay("DEBUG: Skipped due to distance check");}
                
                if(doContinue){
                    //Status Export
                    if(NumEffects > 0)
                        llMessageLinked(LINK_SET, LINK_STATUS_TO_HUB, llList2CSV(StatusEffects), NULL_KEY);
                    
                    //Event Export
                    llMessageLinked(LINK_SET, LINK_EVENT, "EFFECT_TYPE_"+llList2String(Keywords,0), llList2Key(Keywords,1));
                    
                    //HP Modulation
                    list vsVit = ["0", "G", "P", "Z", "S"];
                    list vsVitNames = ["Physical", "Gravity", "Poison", "Disease", "Sonic"];
                    
                    list vsSpr = ["F", "I", "T", "L", "E", "W", "L", "D", "M"];
                    list vsSprNames = ["Fire", "Ice", "Thunder", "Air", "Earth", "Water", "Light", "Dark", "Magic"];
                    
                    list vsLuk = ["X"];
                    list vsLukNames = ["Explosive", "NULL_DMG_TYPE"];
                    
                    HP_Status_Events = [llList2CSV(Keywords)];
                    
                    if(HPModForm != "NULL"){
                        integer HPFragMin = (integer)llCeil((float)HPModMin / (float)llStringLength(DamageTypes));
                        integer HPFragRng = (integer)llCeil((float)HPModRange / (float)llStringLength(DamageTypes));
                        
                        integer CritChance = 5 + llRound((float)(Luck - GetAtt("LUK")) / 255.0) * 28;
                        integer IsCrit = (llFrand(100) < CritChance);
                        
                        if(IsCrit) llOwnerSay("You suffered a critical hit!");
                        integer i;
                        for(i=0; i<llStringLength(DamageTypes); i++){
                            integer isPhysical = llListFindList(vsVit, [llGetSubString(DamageTypes,i,i)]);
                            integer isMagical  = llListFindList(vsSpr, [llGetSubString(DamageTypes,i,i)]);
                            integer isLucky    = llListFindList(vsLuk, [llGetSubString(DamageTypes,i,i)]);
                            integer adjust;
                            
                            if(isPhysical > -1){
                                integer pow = Potency;
                                if(IsCrit) pow -= GetAtt("VIT") / 2;
                                else pow -= GetAtt("VIT");
                                if(pow < 0) pow = 0;
                                if(pow > 255) pow = 255;
                                
                                adjust = llRound(HPFragRng * (float)pow / 255.0);
                                adjust += HPFragMin;
                                
                                //Check Blink, Protect/Deprotect
                                if(llList2String(StatusTracker,8) == "BLINK"){
                                    adjust *= 0;
                                    AddStatusEvent("EvasionEvent");
                                }
                                else if(llList2String(StatusTracker,0) == "PROTECT"){
                                    adjust /= 2;
                                    AddStatusEvent("PhysDefEvent");
                                }
                                else if(llList2String(StatusTracker,0) == "DEPROTECT"){
                                    adjust = llRound((float)adjust * 1.3333);
                                    AddStatusEvent("PhysDefEvent");
                                }
                            }
                            else if(isMagical > -1){
                                integer pow = Potency;
                                if(IsCrit) pow -= GetAtt("SPR") / 2;
                                else pow -= GetAtt("SPR");
                                if(pow < 0) pow = 0;
                                if(pow > 255) pow = 255;
                                
                                adjust = llRound(HPFragRng * (float)pow / 255.0);
                                adjust += HPFragMin;
                                
                                //Check Phase, Shell/Deshell
                                if(llList2String(StatusTracker,8) == "PHASE"){
                                    adjust *= 0;
                                    AddStatusEvent("EvasionEvent");
                                }
                                else if(llList2String(StatusTracker,2) == "SHELL"){
                                    adjust /= 2;
                                    AddStatusEvent("MagDefEvent");
                                }
                                else if(llList2String(StatusTracker,2) == "DESHELL"){
                                    adjust = llRound((float)adjust * 1.3333);
                                    AddStatusEvent("MagDefEvent");
                                }
                            }
                            else if(isLucky > -1){
                                integer pow = Potency;
                                if(IsCrit) pow -= GetAtt("LUK") / 2;
                                else pow -= GetAtt("LUK");
                                if(pow < 0) pow = 0;
                                if(pow > 255) pow = 255;
                                
                                adjust = llRound(HPFragRng * (float)pow / 255.0);
                                adjust += HPFragMin;
                            }
                            else llOwnerSay("ERROR 011");
                            
                                 if(HPModForm == "SUB") CHP -= adjust;
                            else if(HPModForm == "ADD") CHP += HPFragRng;
                            else if(HPModForm == "CUR%SUB") CHP -= (integer)llRound(CHP * (float)adjust/100.0);
                            else if(HPModForm == "CUR%ADD") CHP += (integer)llRound(CHP * (float)HPFragRng/100.0);
                            else if(HPModForm == "CUR%ABS"){
                                integer returnVal = (integer)llRound(CHP * (float)adjust/100.0);
                                CHP -= returnVal;
                                //TODO: Return adjustment value as ADD function to originator
                            }
                            else if(HPModForm == "MAX%SUB") CHP -= (integer)llRound(GetAtt("MHP") * (float)adjust/100.0);
                            else if(HPModForm == "MAX%ADD") CHP += (integer)llRound(GetAtt("MHP") * (float)HPFragRng/100.0);
                            else if(HPModForm == "ABS%ADD"){
                                CHP += (integer)llRound(GetAtt("MHP") * (float)HPFragRng/100.0);
                                //TODO: Return adjustment value as ADD function to originator
                            }
                            else if(HPModForm == "SET") CHP = adjust;
                            else llOwnerSay("ERROR 002: Invalid HP Modulation ID!");
                            
                            if(HPModForm == "SUB" || HPModForm == "CUR%SUB" || HPModForm == "MAX%SUB")
                                llOwnerSay("Took "+(string)adjust+" "+llList2String(vsVitNames+vsSprNames+vsLukNames, llListFindList(vsVit+vsSpr+vsLuk, [llGetSubString(DamageTypes,i,i)]))+" damage.");
                            else if(HPModForm == "ADD" || HPModForm == "CUR%ADD" || HPModForm == "MAX%ADD")
                                llOwnerSay("Recovered "+(string)HPFragRng+" HP.");
                            else if(HPModForm == "ADD" || HPModForm == "CUR%ADD" || HPModForm == "MAX%ADD")
                                llOwnerSay(llList2String(vsVitNames+vsSprNames, llListFindList(vsVit+vsSpr, [llGetSubString(DamageTypes,i,i)]))+" reduced your HP to "+(string)HPFragRng+"!");
                        }

                        //MP Modulation
                        if(MPModForm != "NULL"){
                        integer MPFragMin = (integer)llCeil((float)MPModMin / (float)llStringLength(DamageTypes));
                        integer MPFragRng = (integer)llCeil((float)MPModRange / (float)llStringLength(DamageTypes));
                        
                        integer i;
                        for(i=0; i<llStringLength(DamageTypes); i++){
                            integer isPhysical = llListFindList(vsVit, [llGetSubString(DamageTypes,i,i)]);
                            integer isMagical  = llListFindList(vsSpr, [llGetSubString(DamageTypes,i,i)]);
                            integer adjust;
                            
                            if(isPhysical){
                                integer pow = Potency;
                                if(IsCrit) pow -= GetAtt("VIT") / 2;
                                else pow -= GetAtt("VIT");
                                if(pow < 0) pow = 0;
                                if(pow > 255) pow = 255;
                                adjust = llRound(MPFragRng * (float)pow / 255.0);
                            }
                            else if(isMagical){
                                integer pow = Potency;
                                if(IsCrit) pow -= GetAtt("SPR") / 2;
                                else pow -= GetAtt("SPR");
                                if(pow < 0) pow = 0;
                                if(pow > 255) pow = 255;
                                
                                adjust = llRound(MPFragRng * (float)pow / 255.0);
                            }
                            
                            adjust += MPFragMin;
                            
                                 if(MPModForm == "SUB") CMP -= adjust;
                            else if(MPModForm == "ADD") CMP += MPFragRng;
                            else if(MPModForm == "CUR%SUB") CMP -= (integer)llRound(CMP * (float)adjust/100.0);
                            else if(MPModForm == "CUR%ADD") CMP -= (integer)llRound(CMP * (float)MPFragRng/100.0);
                            else if(MPModForm == "MAX%SUB") CMP -= (integer)llRound(GetAtt("MMP") * (float)adjust/100.0);
                            else if(MPModForm == "MAX%ADD") CMP -= (integer)llRound(GetAtt("MMP") * (float)MPFragRng/100.0);
                            else if(MPModForm == "SET") CMP = adjust;
                            else llOwnerSay("ERROR 003: Invalid MP Modulation ID!");
                            }
                        }
                    }
                }
            }
        }
        debugText();
    }
}