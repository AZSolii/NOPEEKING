list output = ["00000",    //Party ID
               "SUB",      //HP Mod Form
               124,        //HP Modulation Minimum
			   306,        //HP Modulation Range
               "X",        //Damage Types
               "N/A",      //MP Mod Form
               "N/A",      //MP Mod Amount
               128,        //Potency
               64,         //Luck
               "NULL",     //VFX
               2,          //Number of keywords
               "NORMAL",   //NORMAL, COMMAND, MAGIC, ITEM, SUMMON, LIMIT
			   "NEUTRAL",  //POSITIVE, NEUTRAL, NEGATIVE
               1,          //Number of status effects
               "PROTECT",    //Status ID
               1,          //Number of alt values
               0           //Alt value
               ];
string outputFormatted;

default
{
    state_entry(){
        integer i;
        outputFormatted = llList2String(output, 0);
        for(i=1; i<llGetListLength(output); i++){
            outputFormatted += ";"+llList2String(output, i);            
        }
    }
    touch_start(integer total){
        llSay(-9823645, (string)llDetectedKey(0)+";"+outputFormatted);
        llOwnerSay((string)llDetectedKey(0)+";"+outputFormatted);
    }
}
