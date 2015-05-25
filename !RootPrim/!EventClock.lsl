integer LINK_STATISTICS = 100;
integer LINK_EFFECT = 101;
integer LINK_MATERIA_COOLDOWN = 304;
integer LINK_TIMER_REQUEST = 500;
integer LINK_TIMER_PULSE = 501;
integer LINK_TIMER_KILL = 502;

integer SystemTick = 3;

list Events = ["REGEN", 0, 0,  //Stacks, SPR
               "POISN", 0, 0,  //Stacks, MAG
               "BLEED", 0,     //Stacks
               "DEGEN", 0, "0",//Stacks, DamageType
               "BRELE", 0, "0",//Ticks, Element DamageType Code
               "ENELE", 0, "0",//Ticks, Element DamageType Code
               "FLELE", 0, "0",//Ticks, Element DamageType Code
               "FLRRY", 0,     //Ticks
               "BIND",  0,     //Ticks
               "CONFU", 0,     //Ticks
               "PARAL", 0,     //Ticks
               "SILEN", 0,     //Ticks
               "SLEEP", 0,     //Ticks
               "STOP",  0,     //Ticks
               "INFHP", 0,     //Ticks
               "INFMP", 0      //Ticks
                    ];
list MiscEvents = [];

list Attributes = ["STR", 0, "DEX", 0, "VIT", 0, "MAG", 0, "SPR", 0, "LUK", 0,
                   "MHP", 0, "MMP", 0];
integer comCooldown = 0;
integer magCooldown = 0;
integer sumCooldown = 0;

CheckEvents(){
    integer noEvent = TRUE;
    
    integer stacks = 0;
    stacks += llList2Integer(Events, 1);
    stacks += llList2Integer(Events, 4);
    stacks += llList2Integer(Events, 7);
    stacks += llList2Integer(Events, 9);
    
    if(stacks > 0) noEvent = FALSE;
    else if(comCooldown + magCooldown + sumCooldown > 0) noEvent = FALSE;
    
    if(!noEvent) llSetTimerEvent(SystemTick);
    else llSetTimerEvent(0);
}
DecrementStack(integer slot){
    if(llList2Integer(Events,slot) > 0)
        llListReplaceList(Events,[llList2Integer(Events,slot)-1],slot,slot);
}
default
{
    state_entry(){
        
    }
    link_message(integer linknum, integer num, string str, key id){
        if(num == LINK_TIMER_REQUEST){
            list parse = llCSV2List(str);
            string arg01 = llList2String(parse,0);
            string arg02 = llList2String(parse,1);
            string arg03 = llList2String(parse,2);
            if(arg01 == "COMMAND_COOLDOWN")     comCooldown = (integer)arg02;
            else if(arg01 == "MAGIC_COOLDOWN")  magCooldown = (integer)arg02;
            else if(arg01 == "SUMMON_COOLDOWN") sumCooldown = (integer)arg02;
            
            else if(arg01 == "REGEN") llListReplaceList(Events,[arg02,arg03],1,2);
            else if(arg01 == "POISN") llListReplaceList(Events,[arg02,arg03],4,5);
            else if(arg01 == "BLEED") llListReplaceList(Events,[arg02],7,7);
            else if(arg01 == "DEGEN") llListReplaceList(Events,[arg02,arg03],9,10);
            
            else if(arg01 == "BRELE") llListReplaceList(Events,[arg02,arg03],12,13);
            else if(arg01 == "ENELE") llListReplaceList(Events,[arg02,arg03],15,16);
            else if(arg01 == "FLELE") llListReplaceList(Events,[arg02,arg03],18,19);
            else if(arg01 == "FLRRY") llListReplaceList(Events,[arg02],21,21);
            else if(arg01 == "BIND")  llListReplaceList(Events,[arg02],23,23);
            else if(arg01 == "CONFU") llListReplaceList(Events,[arg02],25,25);
            else if(arg01 == "PARAL") llListReplaceList(Events,[arg02],27,27);
            else if(arg01 == "SILEN") llListReplaceList(Events,[arg02],29,29);
            else if(arg01 == "SLEEP") llListReplaceList(Events,[arg02],31,31);
            else if(arg01 == "STOP")  llListReplaceList(Events,[arg02],33,33);
            else if(arg01 == "INFHP") llListReplaceList(Events,[arg02],35,35);
            else if(arg01 == "INFMP") llListReplaceList(Events,[arg02],37,37);
            
            CheckEvents();
        }
        if(num == LINK_STATISTICS){
            Attributes = llCSV2List(str);
        }
    }
    timer(){
        //Regen
        DecrementStack(1);
        //Poison
        DecrementStack(4);
        //Bleed
        DecrementStack(7);
        //Degeneration
        //llMessageLinked();
        DecrementStack(10);
        //Barelement
        DecrementStack(12);
        DecrementStack(15);
        DecrementStack(18);
        DecrementStack(21);
        DecrementStack(23);
        DecrementStack(25);
        DecrementStack(27);
        DecrementStack(29);
        DecrementStack(31);
        DecrementStack(33);
        DecrementStack(35);
        DecrementStack(37);
        
        if(comCooldown <= SystemTick && comCooldown != 0){
            llMessageLinked(LINK_SET, LINK_MATERIA_COOLDOWN, "COMMAND;1", NULL_KEY);
            comCooldown = 0;
            llOwnerSay("Your Command Materia have refreshed.");
        }
        else comCooldown -= SystemTick;
        
        CheckEvents();
    }
}