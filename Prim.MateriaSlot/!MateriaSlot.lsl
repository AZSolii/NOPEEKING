integer LINK_MATERIA_SLOT = 300;
integer LINK_MATERIA_BIND_REQUEST = 301;
integer LINK_MATERIA_SUPPORT_TOGGLE = 302;

list MateriaTypes = ["NONE", "SUMMON", "COMMAND", "MAGIC", "SUPPORT", "INDEPENDENT"];

integer slot = 0;
string  MateriaName   = "NULL"
integer MateriaLevel  = 0
string  MateriaType   = "NONE"
string  MateriaSupp   = "NULL"
integer SupportActive = FALSE;
integer MPCost        = 0;
integer Delay         = 0;

ProcessMateriaData(string csv){
    list temp = llCSV2List();
    MateriaName =   llList2String(temp, 0);
    MateriaLevel =  llList2Integer(temp, 1);
    MateriaType =   llList2String(temp, 1);
    MateriaSupp =   llList2String(temp, 2);
    SupportActive = llList2Integer(temp, 3);
}
default
{
    link_message(integer linknum, integer num, string str, key id)
    {
        if(num == LINK_MATERIA_SLOT){
            ProcessMateriaData(str);
            if(llListFindList(MateriaTypes, [MateriaType]) != -1){
				     if(MateriaType == "SUMMON") state materia_state_red;
				else if(MateriaType == "COMMAND") state materia_state_yellow;
				else if(MateriaType == "MAGIC") state materia_state_green;
				else if(MateriaType == "SUPPORT") state materia_state_blue;
				else if(MateriaType == "INDEPENDENT") state materia_state_purple;
			}
			else state default;
        }
    }
}
materia_state_red
{
	state_entry
	{
		llOwnerSay("DEBUG: I'm a Summon materia!");
		llSetColor(ALL_SIDES, <1,0,0>);
	}
    link_message(integer linknum, integer num, string str, key id)
    {
        if(num == LINK_MATERIA_SLOT){
			string currentMateria = MateriaName;
            ProcessMateriaData(str);
			if(llListFindList(MateriaTypes, [MateriaType]) != -1 && currentMateria != MateriaName){
				     if(MateriaType == "SUMMON") state materia_state_red;
				else if(MateriaType == "COMMAND") state materia_state_yellow;
				else if(MateriaType == "MAGIC") state materia_state_green;
				else if(MateriaType == "SUPPORT") state materia_state_blue;
				else if(MateriaType == "INDEPENDENT") state materia_state_purple;
			}
        }
    }
}
materia_state_yellow
{
	state_entry
	{
		llOwnerSay("DEBUG: I'm a Command materia!");
		llSetColor(ALL_SIDES, <1,1,0>);
	}
    link_message(integer linknum, integer num, string str, key id)
    {
        if(num == LINK_MATERIA_SLOT){
			string currentMateria = MateriaName;
            ProcessMateriaData(str);
			if(llListFindList(MateriaTypes, [MateriaType]) != -1 && currentMateria != MateriaName){
				     if(MateriaType == "SUMMON") state materia_state_red;
				else if(MateriaType == "COMMAND") state materia_state_yellow;
				else if(MateriaType == "MAGIC") state materia_state_green;
				else if(MateriaType == "SUPPORT") state materia_state_blue;
				else if(MateriaType == "INDEPENDENT") state materia_state_purple;
			}
        }
    }
	touch_start(integer total){
		llMessageLinked(LINK_SET, LINK_MATERIA_USE, MateriaType+"/"+MateriaName+"/"+(string)slot, NULL_KEY);
	}
}
materia_state_green
{
	state_entry
	{
		llOwnerSay("DEBUG: I'm a Magic materia!");
		llSetColor(ALL_SIDES, <0,1,0>);
	}
    link_message(integer linknum, integer num, string str, key id)
    {
        if(num == LINK_MATERIA_SLOT){
			string currentMateria = MateriaName;
            ProcessMateriaData(str);
			if(llListFindList(MateriaTypes, [MateriaType]) != -1 && currentMateria != MateriaName){
				     if(MateriaType == "SUMMON") state materia_state_red;
				else if(MateriaType == "COMMAND") state materia_state_yellow;
				else if(MateriaType == "MAGIC") state materia_state_green;
				else if(MateriaType == "SUPPORT") state materia_state_blue;
				else if(MateriaType == "INDEPENDENT") state materia_state_purple;
			}
        }
    }
}
materia_state_blue
{
	state_entry
	{
		llOwnerSay("DEBUG: I'm a Support materia!");
		llSetColor(ALL_SIDES, <0,0.5,1>);
	}
    link_message(integer linknum, integer num, string str, key id)
    {
        if(num == LINK_MATERIA_SLOT){
			string currentMateria = MateriaName;
            ProcessMateriaData(str);
			if(llListFindList(MateriaTypes, [MateriaType]) != -1 && currentMateria != MateriaName){
				     if(MateriaType == "SUMMON") state materia_state_red;
				else if(MateriaType == "COMMAND") state materia_state_yellow;
				else if(MateriaType == "MAGIC") state materia_state_green;
				else if(MateriaType == "SUPPORT") state materia_state_blue;
				else if(MateriaType == "INDEPENDENT") state materia_state_purple;
			}
        }
    }
	touch_start(integer total){
		llMessageLinked(LINK_SET, LINK_MATERIA_SUPPORT_TOGGLE, (string)slot, NULL_KEY);
		
	}
}
materia_state_purple
{
	state_entry
	{
		llOwnerSay("DEBUG: I'm a Independent materia!");
		llSetColor(ALL_SIDES, <0.5,0,1>);
	}
    link_message(integer linknum, integer num, string str, key id)
    {
        if(num == LINK_MATERIA_SLOT){
            ProcessMateriaData(str);
            if(llListFindList(MateriaTypes, [MateriaType]) != -1){
				     if(MateriaType == "SUMMON") state materia_state_red;
				else if(MateriaType == "COMMAND") state materia_state_yellow;
				else if(MateriaType == "MAGIC") state materia_state_green;
				else if(MateriaType == "SUPPORT") state materia_state_blue;
				else if(MateriaType == "INDEPENDENT") state materia_state_purple;
			}
        }
    }
}