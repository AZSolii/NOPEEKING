integer CHANNEL_INTEROP = -720000;
integer CHANNEL_MATERIA_BASE = -730000;
integer CHANNEL_MAIN = -9823645;

integer LINK_EFFECT = 101;

default
{
    state_entry()
    {
        llListen(CHANNEL_MAIN, "", NULL_KEY, "");
        llListen(CHANNEL_INTEROP, "", NULL_KEY, "");
        llListen(CHANNEL_MATERIA_BASE, "", NULL_KEY, "");
    }
    listen(integer channel, string name, key id, string message)
    {
        if(channel == CHANNEL_MAIN){
            llMessageLinked(LINK_SET, LINK_EFFECT, message, NULL_KEY);
        }
    }
}
