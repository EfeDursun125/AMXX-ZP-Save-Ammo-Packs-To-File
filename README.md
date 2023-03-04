# ZP Save Ammo Packs To File
This plugin saves ammopacks to file, use this if other banks not saving or banks has problems on your server
.ammo files can be read as text with notepad and can be changed

# IMPORTANT
1. Name/SteamID/IP based save system (Default is name)
2. IP values can be changed and they are not static, so i don't recommend to use it
3. Names can be changed to but you can use any register system to protect names
4. Cracked client's SteamID may be changed, so i recommend name based save system with register system

# CVars
zp_ammo_save_bots "1" // should we save bot's ammo ? (name only)
zp_ammo_save_type "0" // 0 = name | 1 = steamid | 2 = ip
zp_ammo_save_folder_custom_enable "0" // to save custom dir, multi server support (2 servers 1 save file, players will be happy)
zp_ammo_save_folder_custom "C:\ExampleFolder\cstrike\addons\amxmodx\configs" // path for custom dir, multiple servers can acces this path
zp_ammo_save_folder_name "AmmoSaveFILE" // custom folder name
zp_ammo_save_minimum "20" // minimum ammo packs to save, avoid spamming / too many file creation
