#include <amxmodx>
#include <amxmisc>
#include <zombieplague>

public plugin_init()
{
	register_plugin("[ZP] Save Ammo To File", "1.0", "EfeDursun125")
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
    ":"
}

public client_putinserver(id)
{
    set_task(2.0, "client_load_ammo", id)
}

public client_load_ammo(id)
{
    new playerName[MAX_NAME_LENGTH]
    get_user_name(id, playerName, charsmax(playerName))

    if (strlen(playerName) < 3)
        return

    trim(playerName)

    // some tags can cause errors...
    for (new i = 0; i < sizeof(unsupportedTags); i++)
    {
        replace_all(playerName, charsmax(playerName), unsupportedTags[i], "")
    }

    trim(playerName)

    new path[64]
    get_configsdir(path, charsmax(path))

    format(path, charsmax(path), "%s/AmmoSaveFILE/%s.ammo", path, playerName)

    if (!file_exists(path))
        return

    new line, text[256], txtlen

    while ((line = read_file(path, line, text, charsmax(text), txtlen)) != 0)
    {
        trim(text)
        zp_set_user_ammo_packs(id, str_to_num(text))
    }
}

public client_remove(id)
{
    new ammoPacks = zp_get_user_ammo_packs(id)
    if (ammoPacks < 10) // for avoid creating many files
        return
    
    new playerName[MAX_NAME_LENGTH]
    get_user_name(id, playerName, charsmax(playerName))

    if (strlen(playerName) < 3)
        return

    trim(playerName)

    // some tags can cause errors...
    for (new i = 0; i < sizeof(unsupportedTags); i++)
    {
        replace_all(playerName, charsmax(playerName), unsupportedTags[i], "")
    }

    trim(playerName)

    new path[64]
    get_configsdir(path, charsmax(path))

    format(path, charsmax(path), "%s/AmmoSaveFILE/%s.ammo", path, playerName)
    new value[256]
    num_to_str(ammoPacks, value, charsmax(value))
    trim(value)

    write_file(path, value, 0)
}
