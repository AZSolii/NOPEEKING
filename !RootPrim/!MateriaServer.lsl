integer LINK_STATUS_AWAY_HUB = 200;
integer LINK_MATERIA_SLOT = 300;
integer LINK_MATERIA_SUPPORT_TOGGLE = 302;
integer LINK_SCANNER_REQUEST = 400;
list Attributes;

float Reach = 2.0;

list MateriaListSummon = 
	["Ifrit"];
list MateriaListCommand = 
	["Critical"];
list MateriaListMagic   = 
	["Restore"];
list MateriaListSupport = 
	["Quicken"];
list MateriaListIndependent = 
	["Strength+"];

//Name, Level, IsSupportGroupActive
list Slots = ["NULL", 0, FALSE, "NULL", 0, FALSE, "NULL", 0, FALSE, "NULL", 0, FALSE, "NULL", 0,
			  "NULL", 0, FALSE, "NULL", 0, FALSE, "NULL", 0, FALSE, "NULL", 0, FALSE, "NULL", 0];
			  
list LinkGroup = [0, 0, 1, 1, 2, 2, 3, 3, 4, 4];

integer mapToHP(float x)
{
	//float value maps directly to percents. EG: 0.0 = 0%, 1.0 = 100%
	float baseline = 5000;
	float overflow = 5000;
	float clamp = 9999;
	
	float num = -1;
	if(x < 0.0){
		llOwnerSay("ERROR 007: Value passed to mapToHP cannot be negative.");
		return -1;
	}
	else if(x <= 1.0) {
		num = baseline * num;
	}
	else {
		num = baseline;
		while(x > 1.0) {
			float y = x % 1.0;
			num += (overflow * y);
			x -= 1.0;
		}
	}
	if(num > clamp) num = clamp;
	return llRound(num);
}
integer mapToMP(float x)
{
	//float value maps directly to percents. EG: 0.0 = 0%, 1.0 = 100%
	float baseline = 100;
	float overflow = 100;
	float clamp = 999;
	
	float num = -1;
	if(x < 0.0){
		llOwnerSay("ERROR 008: Value passed to mapToMP cannot be negative.");
		return -1;
	}
	else if(x <= 1.0) {
		num = baseline * num;
	}
	else {
		num = baseline;
		while(x > 1.0) {
			float y = x % 1.0;
			num += (overflow * y);
			x -= 1.0;
		}
	}
	if(num > clamp) num = clamp;
	return llRound(num);
}
export()
{
    llMessageLinked(LINK_SET, LINK_MATERIA_SLOT, llList2CSV(Slots), NULL_KEY);
}
generateScannerRequest(string ScanType, string TargetType, float ScanRange, 
		integer OutputChannel, string OutputExternal, string OutputInternal){
	llMessageLinked(LINK_SET, LINK_SCANNER_REQUEST, 
		[ScanType, TargetType, ScanRange, OutputChannel, OutputExternal, OutputInternal], NULL_KEY);
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
	if(num == LINK_STATUS AWAY HUB){
	
	Attributes = llCSV2List(str);
	
	}
	else {
		link_message(integer linknum, integer num, string str, key id)
		{
			if(num == LINK_MATERIA_SUPPORT_TOGGLE){
				integer group = (integer)llFloor((float)str / 2.0);
				integer slot = 6 * group;
				integer val = llList2Integer(Slots, slot+2);
			
				if(val == TRUE)
					val = FALSE;
				else
					val = TRUE;
			
				Slots = llListReplaceList(Slots, val, slot+2, slot+2);
				Slots = llListReplaceList(Slots, val, slot+5, slot+5);
			
				export();
			}
			else if(num == LINK_MATERIA_USE){
				list temp = llParseString2List(str, ["/"], []);
				string type = llList2String(temp,0);
				string name = llList2String(temp,1);
				integer lv  = llList2Integer(temp,2);
				if(type == "COMMAND"){
					if(name == "Doublecut"){
						list out = ["SUB", "150", "40", "0" "NULL", (getAtt("STR") + getAtt("DEX") + getAtt("DEX")) / 3 ,getAtt("LUK"), 1, "DoublecutEffect",  0];
						generateScannerRequest("RAY", "AGENT", Reach, -9823645, llDumpList2String(out, ";"),"");
						generateScannerRequest("RAY", "AGENT", Reach, -9823645, llDumpList2String(out, ";"),"");
					}
				}
			}
		}
	}
}
