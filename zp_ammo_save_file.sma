#include <amxmodx>
#include <amxmisc>
#include <zombieplague>

new oldAmmo[33]

new saveBots
new saveType
new saveCust
new saveDest
new saveName

public plugin_init()
{
	register_plugin("[ZP] Save Ammo To File", "1.1", "EfeDursun125")
	saveBots = register_cvar("zp_ammo_save_bots", "1")
	saveType = register_cvar("zp_ammo_save_type", "0")
	saveCust = register_cvar("zp_ammo_save_folder_custom_enable", "0")
	saveDest = register_cvar("zp_ammo_save_folder_custom", "C:\ExampleFolder\cstrike\addons\amxmodx\configs")
	saveName = register_cvar("zp_ammo_save_folder_name", "AmmoSaveFILE")
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
        set_task(2.0, "client_load_ammo", id)
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

    new path[128]

    if (get_pcvar_num(saveCust) != 1)
        get_configsdir(path, charsmax(path))
    else
    {
        new name[96]
        get_pcvar_string(saveDest, name, charsmax(name))
        format(path, charsmax(path), "%s", name)
    }

    new fileName[64]
    get_pcvar_string(saveName, fileName, charsmax(fileName))
    format(path, charsmax(path), "%s/%s/%s.ammo", path, fileName, playerName)

    if (!file_exists(path))
        return

    new line, text[256], txtlen

    while ((line = read_file(path, line, text, charsmax(text), txtlen)) != 0)
    {
        trim(text)
        zp_set_user_ammo_packs(id, str_to_num(text))
    }

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
    if (ammoPacks < 10 && oldAmmo[id] < 10) // for avoid creating many files
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

    new path[128]

    if (get_pcvar_num(saveCust) != 1)
        get_configsdir(path, charsmax(path))
    else
    {
        new name[96]
        get_pcvar_string(saveDest, name, charsmax(name))
        format(path, charsmax(path), "%s", name)
    }

    new fileName[64]
    get_pcvar_string(saveName, fileName, charsmax(fileName))
    format(path, charsmax(path), "%s/%s/%s.ammo", path, fileName, playerName)

    new value[256]
    num_to_str(ammoPacks, value, charsmax(value))

    trim(value)

    write_file(path, value, 0)
}
