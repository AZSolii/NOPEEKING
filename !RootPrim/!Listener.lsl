integer CHANNEL_INPUT_COMMAND = 135;
integer CHANNEL_INTEROP = -720000;
integer CHANNEL_MATERIA_BASE = -730000;
integer CHANNEL_MAIN = -9823645;

integer LINK_EFFECT = 101;
integer LINK_STATUS_TO_HUB = 201;
integer LINK_EVENT = 600;
integer LINK_COMMAND_INPUT = 601;

default
{
    state_entry()
    {
        llListen(CHANNEL_MAIN, "", NULL_KEY, "");
        llListen(CHANNEL_INTEROP, "", NULL_KEY, "");
        llListen(CHANNEL_MATERIA_BASE, "", NULL_KEY, "");
        llListen(CHANNEL_INPUT_COMMAND, "", NULL_KEY, "");
    }
    listen(integer channel, string name, key id, string message)
    {
        if(channel == CHANNEL_MAIN){
            llMessageLinked(LINK_SET, LINK_EFFECT, message, NULL_KEY);
        }
        if(channel == CHANNEL_INPUT_COMMAND && id == llGetOwner()){
            list parse = llParseString2List(llToUpper(message), [" "], [""]);
            string cmd = llList2String(parse, 0);
            
            if(cmd == "BIND"){
                integer arg1 = llList2Integer(parse, 1);
                string arg2 = llToUpper(llList2String(parse, 2));
                string arg3 = llToUpper(llList2String(parse, 3));
                if(arg2 == "C" || arg2 == "E"){
                    if(arg1 <= 10 && arg1 > 0){
                        if(arg3 == "W" || arg3 == "A" || arg3 == "S" || arg3 == "D"){
                            llMessageLinked(LINK_THIS, LINK_COMMAND_INPUT, cmd+", "+(string)arg1+", "+arg2+arg3, NULL_KEY);
                        }
                        else llOwnerSay("ERROR 013: Invalid command input. Correct syntax is \n/135 bind [slot] [c, e] [w, a, s, d]");
                    }
                    else llOwnerSay("ERROR 013a: Invalid slot ID input. Slot ID must be 1-10. Correct syntax is \n/135 bind [slot] [c, e] [w, a, s, d]");
                }
                else llOwnerSay("ERROR 013: Invalid command input. Correct syntax is \n/135 bind [slot] [c, e] [w, a, s, d]");
            }
            else llOwnerSay("ERROR 012: Invalid command input; Command \""+llToLower(llList2String(parse, 0))+"\" does not exist.");
        }
    }
}
