string materia = "NAME";
integer level = 1;
string matType = "Q";

list choices;

integer remove;

setColor(){
	if(matType == "COM") llSetColor(<0.74902,0.74902,0.00000>,ALL_SIDES);
    else if(matType == "MAG") llSetColor(<0.00000,0.72549,0.36471>,ALL_SIDES);
    else if(matType == "SUP") llSetColor(<0.00000,0.73333,0.73333>,ALL_SIDES);
    else if(matType == "IND") llSetColor(<0.61961,0.00392,0.69020>,ALL_SIDES);
    else llSetColor(<0.35000,0.35000,0.35000>,ALL_SIDES);
}
default
{
	state_entry()
	{
		setColor();
		integer i;
		for(i=1;i<=10;i++)
		{
			choices += ("Slot "+(string)i+", "+materia);
		}
		llSetObjectName("FP7QFCBS v.1 "+materia+" Materia Lv"+(string)level);
	}
	
	touch_start(integer total) 
	{
		if(llDetectedKey(0) == llGetOwner()) 
		{
			remove = llListen(-730001,"",llGetOwner(),"");
			llDialog(llgetOwner(),"Where would you like to slot me?",choices,-730001);
		}
		else
		{
			string myName = llGetObjectName();
			llSetObjectName("");
			llInstantMessage(llDetectedKey(0),"/me You do not own this materia.");
			llSetObjectName(myName);
		}
	}
	listen(integer channel, string name, key id, string message) 
	{
		if(id == llGetOwner()) 
		{
			if(llGetSubString(message,(-1*llStringLength(materia)),-1) == materia) 
			{
				string slot = llGetSubString(message,5,5);
				string theReturn = materia+" "+(string)level+" "+slot;
				llSay(-730000,(string)llGetOwner()+llStringToBase64(theReturn));
			}
		}
	}
	on_rez(integer q)
	{
		llResetScript();
	}
}
			