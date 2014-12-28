//Index is the name of the status.
//Set is for status effects to make sure you can only have one active of each group. Set 0 is no set.
//Priority is for CC/Disables, since you can only have one of each.
integer LINK_STATUS_AWAY_HUB = 200;
integer LINK_STATUS_TO_HUB = 201;
integer LINK_EVENT = 600;
list IndexStatus     = ["Addle", "Berserk", "Blind", "Blink", "Bravery",
                        "Deprotect", "Deshell", "Faith", "Fear", "Flurry",
                        "Fog", "Haste", "Phase", "Protect", "Shell", 
                        "Slow", "Zombie", "Barspell", "Enspell", "Felspell"];
//NOTE: Treat Bar/En/Fel as a single status effect. Note element with an alt value, saves us a lot of headache.
//Status groups. Status effects with the same ID cannot coexist; 0 is free
list SetStatus       = [0, 0, 0, 3, 1,
                        3, 4, 2, 1, 0, 
                        2, 5, 4, 3, 4,
                        5, 0, 6, 6, 6];
list IndexControl    = ["Bind", "Confuse", "Paralyze", "Silence", "Sleep", "Stop"];
list PriorityControl = [1, 2, 3, 3, 4, 5];

//ORDER:
//                      PHYSDEF, MAGDEF , PHYSPOW, MAGPOW ,
//                      EVASION, ACCURAC, TIMFACT, CUREMOD,
//                      CRITICA, HPOTIME
list StatusTrackerS  = ["NULL", 0, "NULL", 0, "NULL", 0, "NULL", 0,
                        "NULL", 0, "NULL", 0, "NULL", 0, "NULL", 0,
                        "NULL", 0, "NULL", 0];
list StatusTrackerD  = [];

export(){
    llMessageLinked(LINK_SET, LINK_STATUS_AWAY_HUB, llList2CSV(StatusTrackerS+StatusTrackerD), NULL_KEY);
}
setStackStatus(string statusID, integer statusNum){
    
    integer target;
    if(statusID == "Protect") target = 0;
    else if(statusID == "Deprotect") target = 0;
    else if(statusID == "Shell") target = 2;
    else if(statusID == "Deshell") target = 2;
    else if(statusID == "Bravery") target = 4;
    else if(statusID == "Fear") target = 4;
    else if(statusID == "Faith") target = 6;
    else if(statusID == "Fog") target = 6;
    else if(statusID == "Blink") target = 8;
    else if(statusID == "Phase") target = 8;
    else if(statusID == "Blind") target = 10;
    else if(statusID == "Addle") target = 10;
    else if(statusID == "Haste") target = 12;
    else if(statusID == "Slow") target = 12;
    else if(statusID == "Zombie") target = 14;
    else if(statusID == "Berserk") target = 16;
    else if(statusID == "Regen") target = 18;
    else if(statusID == "Poison") target = 18;
    else if(statusID == "Degen") target = 18;
    
    if(statusNum != 0)
        StatusTrackerS = llListReplaceList(StatusTrackerS, [statusID, statusNum], target, target+1);
    else
        StatusTrackerS = llListReplaceList(StatusTrackerS, ["NULL", 0], target, target+1);
    
    llOwnerSay(llList2CSV(StatusTrackerS));
}
debugText(){
    llOwnerSay("debugText go");
    string s = "";
    integer i;
    for(i=0;i<llGetListLength(StatusTrackerS);i+=2){
        string entry = llList2String(StatusTrackerS,i);
        if(entry != "NULL"){
            s+=entry+" ×"+llList2String(StatusTrackerS, i+1)+"\n";
        }
    }
    //do duration'd ones
    llSetText("===Status Effects===\n"+s, <1,0.5,1>, 1);
}
//i:ID slot for the status name
//s:Only decrement if it's this status, leave null otherwise.
decrementStack(integer i, string filter){
    string status = llList2String(StatusTrackerS, i);
    integer stacks = llList2Integer(StatusTrackerS, i+1);
    
    if(status == filter || filter == ""){    
        if(stacks<0) stacks++;
        else if(stacks>0) stacks--;
        
        if(stacks == 0) status = "NULL";
        
        llListReplaceList(StatusTrackerS, [status, stacks], i, i+1);
    }
}
default
{
    state_entry()
    {
        llOwnerSay("====BEGIN====");
        llSetText("",<0,0,0>,0);
        setStackStatus("Bravery",4);
        setStackStatus("Protect",3);
        setStackStatus("Fog",6);
        setStackStatus("Blink",9);
        debugText();
    }
    //Status;stacksorduration;
    link_message(integer linknum, integer num, string str, key id){
        if(num == LINK_STATUS_TO_HUB){
            
        }
        if(num == LINK_EVENT){
//          00PHYSDEF, 02MAGDEF , 04PHYSPOW, 06MAGPOW ,
//          08EVASION, 10ACCURAC, 12TIMFACT, 14CUREMOD,
//          16CRITICA, 18HPOTIME
            if(str == "ATTACK_USED"){
                if(llFrand(100) < 40)
                    decrementStack(4, "");
                decrementStack(12, "");
            }
            if(str == "COMMAND_USED"){
                decrementStack(4, "");
                decrementStack(10, "Blind");
                decrementStack(12, "");
            }
            if(str == "MAGIC_USED"){
                decrementStack(6, "");
                decrementStack(10, "Addle");
                decrementStack(12, "");
            }
            if(str == "DAMAGE_TAKEN_PHYSICAL"){
                if(llFrand(100) < 40)
                    decrementStack(0, "");
            }
            if(str == "DAMAGE_TAKEN_MAGICAL"){
                if(llFrand(100) < 40)
                    decrementStack(2, "");
            }
            if(str == "DAMAGE_TAKEN_MATERIA_PHYSICAL"){
                decrementStack(0, "");
                decrementStack(8, "Blink");
            }
            if(str == "DAMAGE_TAKEN_MATERIA_MAGICAL"){
                decrementStack(2, "");
                decrementStack(8, "Phase");
            }
        }
    }
}
