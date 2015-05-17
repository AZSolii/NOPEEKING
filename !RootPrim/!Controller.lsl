integer LINK_STATUS_AWAY_HUB = 200;
integer LINK_STATUS_TO_HUB = 201;
integer LINK_SCANNER_REQUEST = 400;
integer LINK_SCANNER_INTERNAL_FEEDBACK = 401;
integer LINK_COMMAND_INPUT = 601;

list hotkeys = ["CW", -1, "CA", -1, "CS", -1, "CD", -1,
                "EW", -1, "EA", -1, "ES", -1, "ED", -1];

default
{
    state_entry(){
        llRequestPermissions(llGetOwner(), PERMISSION_TAKE_CONTROLS);
    }
    on_rez(integer param){
        llRequestPermissions(llGetOwner(), PERMISSION_TAKE_CONTROLS);
    }
    run_time_permissions(integer perm){
        if(PERMISSION_TAKE_CONTROLS & perm){
            integer controls = 
                CONTROL_FWD | CONTROL_BACK | CONTROL_LEFT | CONTROL_RIGHT | 
                CONTROL_UP | CONTROL_DOWN | CONTROL_LBUTTON | CONTROL_ML_LBUTTON;

            llTakeControls(controls, TRUE, TRUE);
        }
    }
    control(key id, integer level, integer edge){
        integer start = level & edge;
        integer end = ~level & edge;
        integer held = level & ~edge;
        
        if((held & CONTROL_DOWN && start & CONTROL_FWD) || (start & CONTROL_DOWN && held & CONTROL_FWD))
            llSay(0, "DEBUG: CW event, triggering slot "+llList2String(hotkeys, 1));
        if((held & CONTROL_DOWN && start & CONTROL_LEFT) || (start & CONTROL_DOWN && held & CONTROL_LEFT))
            llSay(0, "DEBUG: CA event, triggering slot "+llList2String(hotkeys, 3));
        if((held & CONTROL_DOWN && start & CONTROL_BACK) || (start & CONTROL_DOWN && held & CONTROL_BACK))
            llSay(0, "DEBUG: CS event, triggering slot "+llList2String(hotkeys, 5));
        if((held & CONTROL_DOWN && start & CONTROL_RIGHT) || (start & CONTROL_DOWN && held & CONTROL_RIGHT))
            llSay(0, "DEBUG: CD event, triggering slot "+llList2String(hotkeys, 7));
        if((held & CONTROL_UP && start & CONTROL_FWD) || (start & CONTROL_UP && held & CONTROL_FWD))
            llSay(0, "DEBUG: EW event, triggering slot "+llList2String(hotkeys, 9));
        if((held & CONTROL_UP && start & CONTROL_LEFT) || (start & CONTROL_UP && held & CONTROL_LEFT))
            llSay(0, "DEBUG: EA event, triggering slot "+llList2String(hotkeys, 11));
        if((held & CONTROL_UP && start & CONTROL_BACK) || (start & CONTROL_UP && held & CONTROL_BACK))
            llSay(0, "DEBUG: ES event, triggering slot "+llList2String(hotkeys, 13));
        if((held & CONTROL_UP && start & CONTROL_RIGHT) || (start & CONTROL_UP && held & CONTROL_RIGHT))
            llSay(0, "DEBUG: ED event, triggering slot "+llList2String(hotkeys, 15));
    }
    link_message(integer origin, integer linknum, string str, key id){
        if(linknum == LINK_COMMAND_INPUT){
            list parse = llCSV2List(str);
            if(llList2String(parse,0) == "BIND"){
                integer arg1 = llList2Integer(parse, 1);
                string arg2 = llList2String(parse, 2);
                
                integer index = llListFindList(hotkeys, [arg2]);
                hotkeys = llListReplaceList(hotkeys, [arg1], index+1, index+1);
            }
        }
    }
}