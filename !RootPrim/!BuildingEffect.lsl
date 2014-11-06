integer LINK_MATERIA_BUILDING_EFFECT_DEPOSIT = 304;
integer LINK_MATERIA_BUILDING_EFFECT_WITHDRAW = 305;

list validMateria = ["Death","Ultima"];

default
{
	link_message(integer linknum, integer num, string str, key id)
	{
		if(num == LINK_MATERIA_BUILDING_EFFECT_DEPOSIT) {
		
		}
	}
}