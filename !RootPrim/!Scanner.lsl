integer LINK_SCANNER_REQUEST = 400;
integer LINK_SCANNER_INTERNAL_FEEDBACK = 401;
integer CHANNEL_MAIN;

integer SavedOutputChannel;
string SavedOutputExternal;

integer filter;

default
{
    link_message(integer linknum, integer num, string str, key id)
    {
        if(num == LINK_SCANNER_REQUEST){
            //Parse string into a list. Arguments we need:
            //Whether it's a ray or a sensor
            //Whether we're scanning for objects, agents, or both
            //Range of scan
            //Output string on successful scan
            //Everything else that's flooded back into the system on a successful scan. Paired as Int (channel), String (message)
            list parse = llParseString2List(str, [";"], []);
            
            string RequestType = llList2String(parse, 0);
                //RAY, SENSOR
            string CollisionType = llList2String(parse, 1);
                //AGENT, OBJECT, BOTH
            float Range = llList2Integer(parse, 2);
                //Just a float value, ya'll.
            string OutputExternal = llList2String(parse, 3);
            integer OutputChannel = llList2Integer(parse, 4);
            string OutputInternal = llList2String(parse, 5);
                //Both of these trigger on a successful scan.
            
            if(RequestType == "RAY")
            {
                //TODO: Take collision type into account
                vector start = llGetPos();
                vector aim = llRot2Fwd(llGetRot()) * Range;
                vector end = start + aim;
                
                if ( filter > 8 )
                    filter = 0;
                    
                list results = llCastRay(start, end, [RC_MAX_HITS, 1] );
                
                integer hitNum;
                while (hitNum <= llList2Integer(results, -1))
                {
                    key uuid = llList2Key(results, 2*hitNum);
                    if (uuid != NULL_KEY){
                        if(OutputChannel != 0){
                            if(OutputExternal != ""){
                                //TODO: Adjust OutputExternal to save key information, add party information.
                                llOwnerSay("DEBUG: ["+(string)Range+"m] Detected "+llKey2Name(uuid)+" <<"+(string)uuid+">>");
                                llShout(OutputChannel, OutputExternal);
                                llMessageLinked(LINK_SET, LINK_SCANNER_INTERNAL_FEEDBACK, OutputInternal, uuid);
                            }
                            else llOwnerSay("ERROR 006");
                        }
                        else llOwnerSay("ERROR 005");
                    }
                    //else llOwnerSay("DEBUG: ["+(string)Range+"m] No valid target detected.");
         
                    ++hitNum;
                }
         
                ++filter;
            }
            else if(RequestType == "CONE")
            {
                SavedOutputChannel = OutputChannel;
                SavedOutputExternal = OutputExternal;
                llSensor("", NULL_KEY,AGENT,Range, PI * 0.333);
            }
            else if(RequestType == "RADIAL")
            {
                SavedOutputChannel = OutputChannel;
                SavedOutputExternal = OutputExternal;
                llSensor("", NULL_KEY,AGENT,Range, PI);
            }
        }
    }
    sensor(integer total)
    {
        list victimKeys;
        integer i;
        for(i=0; i<total; i++){
            llShout(SavedOutputChannel, SavedOutputExternal);
            //TODO: Adjust SavedOutputExternal for party, add key to beginning.
        }
        SavedOutputChannel = 0;
        SavedOutputExternal = "";
    }
}