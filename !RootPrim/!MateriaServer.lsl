integer LINK_STATUS_AWAY_HUB = 200;
integer LINK_MATERIA_SLOT = 300;
integer LINK_MATERIA_SUPPORT_TOGGLE = 302;
integer LINK_MATERIA_USE = 303;
integer LINK_MATERIA_COOLDOWN = 304;
integer LINK_SCANNER_REQUEST = 400;
integer LINK_TIMER_REQUEST = 500;
integer CHANNEL_MAIN = -9823645;
list Attributes;
string Party = "00000";
key COMMON_KEY = "ffffffff-ffff-ffff-ffff-ffffffffffff";

float Reach = 2.0;

list MateriaListSummon = 
    ["Ifrit"];
list MateriaListCommand = 
    ["Critical", "Potato"];
list MateriaListMagic   = 
    ["Restore"];
list MateriaListSupport = 
    ["Quicken"];
list MateriaListIndependent = 
    ["Strength+"];

integer coolCommand = TRUE;
integer coolMagic   = TRUE;
integer coolSummon  = TRUE;

//Name, Level, IsSupportGroupActive
list Slots = ["Potato", "COMMAND", 1, FALSE, "NULL", 0, FALSE, "NULL", "", 0, FALSE, "NULL", "", 0, FALSE, "NULL", "", 0, FALSE,
              "NULL", "", 0, FALSE, "NULL", "", 0, FALSE, "NULL", "", 0, FALSE, "NULL", "", 0, FALSE, "NULL", "", 0, FALSE];
              
list LinkGroup = [0, 0, 1, 1, 2, 2, 3, 3, 4, 4];

string formatAttack(integer FormatAsCSV, string party, string hpMod, integer hpMin, integer hpRange, string damageType, 
    string mpMod, integer mpChange, integer potency, integer luck, string vfx,
    integer numKeywords, list keywords, integer numEffects, list effects){
    list dump = [party, hpMod, hpMin, hpRange, damageType, mpMod, mpChange, 
                 potency, luck, vfx, numKeywords, llList2CSV(keywords), numEffects, llList2CSV(effects)];
    if(FormatAsCSV)
        return llList2CSV(dump);
    else
        return llDumpList2String(dump, ";");
}
export()
{
    llMessageLinked(LINK_SET, LINK_MATERIA_SLOT, llList2CSV(Slots), NULL_KEY);
}
generateScannerRequest(string ScanType, string TargetType, float ScanRange, 
        integer OutputChannel, string OutputExternal, string OutputInternal){
    llMessageLinked(LINK_SET, LINK_SCANNER_REQUEST, 
        llDumpList2String([ScanType, TargetType, ScanRange, OutputChannel, OutputExternal, OutputInternal], ";"), NULL_KEY);
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

default
{
    state_entry()
    {
        
    }
    link_message(integer linknum, integer num, string str, key id)
    {
        if(num == LINK_STATUS_AWAY_HUB){
            Attributes = llCSV2List(str);
        }
        else if(num == LINK_MATERIA_USE){
            integer slot = (integer)str - 1;
            string name = llList2String(Slots,slot*3);
            string type = llList2String(Slots,slot*3+1);
            integer lv  = llList2Integer(Slots,slot*3+2);
            integer sup = llList2Integer(Slots,slot*3+3);
            
//            llSay(0,"DEBUG: slot="+(string)slot+" type="+);
            if(type == "COMMAND" && coolCommand){
                llSay(0,llKey2Name(llGetOwner())+" unleashes "+name+" Lv"+(string)lv+"!");
                if(name == "Potato"){
                    string output = formatAttack(FALSE, Party, "SUB", 10, 1990, "F", 
                    "SUB", 0, (GetAtt("SPR")+GetAtt("VIT")/2), GetAtt("LUK"), "NULL",
                    2, ["COMMAND", "NEGATIVE"], 1, ["FEAR", 1, 0]);
                    llSay(CHANNEL_MAIN, (string)COMMON_KEY+";"+output);
                    llMessageLinked(LINK_SET, LINK_TIMER_REQUEST, "COMMAND_COOLDOWN, 10", NULL_KEY);
                }
                coolCommand = FALSE;
            }
        }
        else if(num == LINK_MATERIA_COOLDOWN){
            list parse = llParseString2List(str, [";"], []);
            string arg01 = llList2String(parse, 0);
            string arg02 = llList2String(parse, 1);
            if(arg01 == "COMMAND") coolCommand = (integer)arg02;
            if(arg01 == "MAGIC")   coolMagic   = (integer)arg02;
            if(arg01 == "SUMMON")  coolSummon  = (integer)arg02;
        }
        else if(num == LINK_MATERIA_SUPPORT_TOGGLE){
            integer group = (integer)llFloor((float)str / 2.0);
            integer slot = 6 * group;
            integer val = llList2Integer(Slots, slot+2);
        
            if(val == TRUE)
                val = FALSE;
            else
                val = TRUE;
        
            Slots = llListReplaceList(Slots, [val], slot+2, slot+2);
            Slots = llListReplaceList(Slots, [val], slot+5, slot+5);
        
            export();
        }
    }
}
