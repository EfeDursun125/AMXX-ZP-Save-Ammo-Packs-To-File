#include <amxmodx>
#include <amxmisc>
#include <zombieplague>

new oldAmmo[33]

new saveBots
new saveType
new saveCust
new saveDest
new saveName
new saveMins

public plugin_init()
{
	register_plugin("[ZP] Save Ammo To File", "1.2", "EfeDursun125")
	saveBots = register_cvar("zp_ammo_save_bots", "1")
	saveType = register_cvar("zp_ammo_save_type", "0")
	saveCust = register_cvar("zp_ammo_save_folder_custom_enable", "0")
	saveDest = register_cvar("zp_ammo_save_folder_custom", "C:\ExampleFolder\cstrike\addons\amxmodx\configs")
	saveName = register_cvar("zp_ammo_save_folder_name", "AmmoSaveFILE")
	saveMins = register_cvar("zp_ammo_save_minimum", "20")
}

new const unsupportedTags[][] =
{
	"|",
	"<",
	">",
	"!",
	"?",
	"#", // not gives error but saving as ¼
	"¼",
	"*",
	".",
	",",
	";",
	":",
	"ä",
	"ü",
	"ç",
	"ö",
	"ş",
	"İ",
	"ğ",
	"'",
	"&",
	"%"
}

public client_putinserver(id)
{
	if (get_pcvar_num(saveBots) == 1 || !is_user_bot(id))
		set_task(2.22, "client_load_ammo", id)
}

public client_load_ammo(id)
{
	new playerName[MAX_NAME_LENGTH]

	if (get_pcvar_num(saveType) == 1)
		get_user_authid(id, playerName, charsmax(playerName))
	else if (get_pcvar_num(saveType) == 2)
		get_user_ip(id, playerName, charsmax(playerName))
	else
		get_user_name(id, playerName, charsmax(playerName))

	if (strlen(playerName) < 3)
		return

	trim(playerName)

	oldAmmo[id] = zp_get_user_ammo_packs(id)

	// some tags can cause errors...
	for (new i = 0; i < sizeof(unsupportedTags); i++)
		replace_all(playerName, charsmax(playerName), unsupportedTags[i], "")

	trim(playerName)

	new path[255]

	if (get_pcvar_num(saveCust) != 1)
		get_configsdir(path, charsmax(path))
	else
	{
		new name[96]
		get_pcvar_string(saveDest, name, charsmax(name))
		format(path, charsmax(path), "%s", name)
	}

	new folderName[64]
	get_pcvar_string(saveName, folderName, charsmax(folderName))
	format(path, charsmax(path), "%s/%s", path, folderName)

	if (!dir_exists(path))
		mkdir(path)
	
	format(path, charsmax(path), "%s/%s.ammo", path, playerName)

	new file = fopen(path, "rt+")
	if (file)
	{
		new text[255]
		fgets(file, text, charsmax(text))
		trim(text)
		zp_set_user_ammo_packs(id, str_to_num(text))
		fclose(file)
	}
	else
		return

	// again
	oldAmmo[id] = zp_get_user_ammo_packs(id)
}

#if AMXX_VERSION_NUM <= 182
public client_disconnect(id)
{
	client_save_ammo(id)
}
#else
public client_disconnected(id)
{
	client_save_ammo(id)
}
#endif

public client_save_ammo(id)
{
	if (get_pcvar_num(saveBots) != 1 && is_user_bot(id))
		return
	
	new ammoPacks = zp_get_user_ammo_packs(id)
	new minLimit = get_pcvar_num(saveMins)
	if (ammoPacks < minLimit && oldAmmo[id] < minLimit) // avoid create too many files
		return
	
	new playerName[MAX_NAME_LENGTH]

	if (get_pcvar_num(saveType) == 1)
		get_user_authid(id, playerName, charsmax(playerName))
	else if (get_pcvar_num(saveType) == 2)
		get_user_ip(id, playerName, charsmax(playerName))
	else
		get_user_name(id, playerName, charsmax(playerName))

	if (strlen(playerName) < 3)
		return

	trim(playerName)

	// some tags can cause errors...
	for (new i = 0; i < sizeof(unsupportedTags); i++)
		replace_all(playerName, charsmax(playerName), unsupportedTags[i], "")

	trim(playerName)

	new path[255]

	if (get_pcvar_num(saveCust) != 1)
		get_configsdir(path, charsmax(path))
	else
	{
		new name[96]
		get_pcvar_string(saveDest, name, charsmax(name))
		format(path, charsmax(path), "%s", name)
	}

	new folderName[64]
	get_pcvar_string(saveName, folderName, charsmax(folderName))
	format(path, charsmax(path), "%s/%s", path, folderName)

	if (!dir_exists(path))
		mkdir(path)
	
	format(path, charsmax(path), "%s/%s.ammo", path, playerName)

	new value[256]
	num_to_str(ammoPacks, value, charsmax(value))

	trim(value)

	new file = fopen(path, "wt+")
	
	if (file)
	{
		fprintf(file, value)
		fclose(file)
	}
}