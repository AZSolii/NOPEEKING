integer LINK_STATISTICS = 100;
integer LINK_EFFECT = 101;
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
			   "INFMP", 0,     //Ticks
					];

list Attributes = ["STR", 0, "DEX", 0, "VIT", 0, "MAG", 0, "SPR", 0, "LUK", 0,
                   "MHP", 0, "MMP", 0];
					
CheckEvents(){
	integer noEvent = TRUE;
	
	integer stacks = 0;
	stacks += llList2Integer(Events, 1);
	stacks += llList2Integer(Events, 4);
	stacks += llList2Integer(Events, 7);
	stacks += llList2Integer(Events, 9);
	
	if(stacks > 0) llSetTimerEvent(SystemTick);
	else llSetTimerEvent(0);
}
DecrementStack(integer slot){
	if(llList2Integer(EventDoT,slot) > 0)
		llListReplaceList(EventDoT,[llList2Integer(EventDoT,slot)-1],slot);
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
			if(arg01 == "REGEN") llListReplaceList(EventDoT,[arg02,arg03],1,2);
			else if(arg01 == "POISN") llListReplaceList(EventDoT,[arg02,arg03],4,5);
			else if(arg01 == "BLEED") llListReplaceList(EventDoT,[arg02],7);
			else if(arg01 == "DEGEN") llListReplaceList(EventDoT,[arg02,arg03],9,10);
			
			else if(arg01 == "BRELE") llListReplaceList(EventStatus,[arg02,arg03],12,13);
			else if(arg01 == "ENELE") llListReplaceList(EventStatus,[arg02,arg03],15,16);
			else if(arg01 == "FLELE") llListReplaceList(EventStatus,[arg02,arg03],18,19);
			else if(arg01 == "FLRRY") llListReplaceList(EventStatus,[arg02],21);
			else if(arg01 == "BIND")  llListReplaceList(EventStatus,[arg02],23);
			else if(arg01 == "CONFU") llListReplaceList(EventStatus,[arg02],25);
			else if(arg01 == "PARAL") llListReplaceList(EventStatus,[arg02],27);
			else if(arg01 == "SILEN") llListReplaceList(EventStatus,[arg02],29);
			else if(arg01 == "SLEEP") llListReplaceList(EventStatus,[arg02],31);
			else if(arg01 == "STOP")  llListReplaceList(EventStatus,[arg02],33);
			else if(arg01 == "INFHP") llListReplaceList(EventStatus,[arg02],35);
			else if(arg01 == "INFMP") llListReplaceList(EventStatus,[arg02],37);
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
		llMessageLinked();
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
		
		CheckEvents();
	}
}