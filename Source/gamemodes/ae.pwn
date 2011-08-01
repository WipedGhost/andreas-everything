/*------------------------------------------------------------------------------
	Andreas Everything
	coded by:
	Steven82, Dowster
	
	Thanks to Incognito - Streamer
	Thanks to Y_Less - sscanf
	Thanks to Splice - BUD(Blazing User Database)
	Thanks to Incognito - Streamer Plugin
------------------------------------------------------------------------------*/
#include <a_samp>
#define BUD_MAX_COLUMNS 50
#define BUD_USE_WHIRLPOOL false
#include <bud>
#include <zcmd>
#include <sscanf2>
#include <arrays>
#include <streamer>
#include <objects>
// Server/Script Defines
#define SCRIPT_MODE "AE v1.0"
#define SCRIPT_WEB "forum.sa-mp.com"
//Virtual World Defines
#define LOBBY_VW 0
#define DEATHMATCH_VW 5
#define FREEROAM_VW 10
#define CNR_VW 15
// Color Defines
#define COLOR_GRAD1 0xB4B5B7FF
#define COLOR_GRAD2 0xBFC0C2FF
#define COLOR_GRAD3 0xCBCCCEFF
#define COLOR_GRAD4 0xD8D8D8FF
#define COLOR_GRAD5 0xE3E3E3FF
#define COLOR_GRAD6 0xF0F0F0FF
#define COLOR_GREY 0xAFAFAFAA
#define COLOR_GREEN 0x33AA33AA
#define COLOR_RED 0xAA3333AA
#define COLOR_LIGHTRED 0xFF6347AA
#define COLOR_LIGHTBLUE 0x33CCFFAA
#define COLOR_LIGHTGREEN 0x9ACD32AA
#define COLOR_YELLOW 0xFFFF00AA
#define COLOR_YELLOW2 0xF5DEB3AA
#define COLOR_WHITE 0xFFFFFFAA
#define COLOR_MAGENTA 0xFF00FFFF
#define COLOR_FADE1 0xE6E6E6E6
#define COLOR_FADE2 0xC8C8C8C8
#define COLOR_FADE3 0xAAAAAAAA
#define COLOR_FADE4 0x8C8C8C8C
#define COLOR_FADE5 0x6E6E6E6E
#define COLOR_PURPLE 0xC2A2DAAA
#define COLOR_DBLUE 0x2641FEAA
#define COLOR_ALLDEPT 0xFF8282AA
// Dialog Defines
#define DIALOG_BLANK 100
#define DIALOG_REGISTER 101
#define DIALOG_LOGIN 102
#define DIALOG_HELP 103
#define DIALOG_MODE_SELECT 104
//Mode Defines
#define MAX_MODES 4
#define MODE_DEATHMATCH 0
#define MODE_FREE_ROAM 1
#define MODE_CNR 2
#define MODE_LOBBY 3
// Variables
new
	LoggedIn[MAX_PLAYERS];
// Enums
enum pData
{
	Adminlevel,
	Muted,
 	Money,
 	Score,
 	Float:Health,
 	Float:Armour,
	MODE
}
//Arrays
new 
	PlayerData[MAX_PLAYERS][pData],
	IPADDRESSES[MAX_PLAYERS][18];
new MODES[MAX_MODES][2][17] = 
{
	{"Deathmatch", 0},
	{"Free Roam", 0},
	{"Cops n' Robbers", 0},
	{"Lobby", 1}
};
//============================================================================//
main()
{
	print("\n----------------------------------");
	print(" Andreas Everything ");
	print(" Script Lines: 431 ");
	print(" Coded by: SA-MP Community ");
	print("----------------------------------\n");
}

public OnGameModeInit()
{
	SetGameModeText(SCRIPT_MODE);
	SendRconCommand(SCRIPT_WEB);
	DisableInteriorEnterExits();
	// SQLite
	BUD::Setting(opt.Database, "AE.db");
	BUD::Setting(opt.KeepAliveTime, 3000);
	BUD::Setting(opt.CheckForUpdates, true);
	BUD::Initialize();
	BUD::VerifyColumn("adminlevel", BUD::TYPE_NUMBER);
	BUD::VerifyColumn("muted", BUD::TYPE_NUMBER);
	BUD::VerifyColumn("money", BUD::TYPE_NUMBER);
	BUD::VerifyColumn("score", BUD::TYPE_NUMBER);
	BUD::VerifyColumn("interior", BUD::TYPE_NUMBER);
	BUD::VerifyColumn("virtualwolrd", BUD::TYPE_NUMBER);
	BUD::VerifyColumn("health", BUD::TYPE_FLOAT);
	BUD::VerifyColumn("armour", BUD::TYPE_FLOAT);
	LobbyObjects();
	return 1;
}

public OnGameModeExit()
{
    BUD::Exit();
	return 1;
}

public OnPlayerRequestClass(playerid, classid)
{
	return 1;
}

public OnPlayerConnect(playerid)
{
	// User Account System
	if(BUD::IsNameRegistered(GetPlayerNameEx(playerid)))
        ShowPlayerDialog(playerid, DIALOG_LOGIN, DIALOG_STYLE_INPUT, "Welcome back to Andreas Everything!",
		"Please enter your desired password below, and click 'Login'.\nIf you wish to leave, click 'Leave'.", "Login", "Leave");
    else
        ShowPlayerDialog(playerid, DIALOG_REGISTER, DIALOG_STYLE_INPUT, "Welcome to Andreas Everything!",
		"Please enter your password below, and click 'Register'.\nIf you wish to leave, click 'Leave'.", "Register", "Leave");
	// Misc
	TogglePlayerClock(playerid, 0);
	SetPlayerScore(playerid, 0);
	GetPlayerIp(playerid, IPADDRESSES[playerid], 18);
	return 1;
}

public OnPlayerDisconnect(playerid, reason)
{
	// User Account System
	SaveAccount(playerid);
	//Disconnect Log
	new hour, minute, second, month, year, day, name[MAX_PLAYER_NAME], string[128];
	GetPlayerName(playerid, name, MAX_PLAYER_NAME);
	gettime(hour, minute, second);
	getdate(year, month, day);
	if(minute < 10 && second < 10) format(string, sizeof(string), "[%s %i, %i] - [%i:0%i:0%i] User: %s disconnected from %s\r\n", Months[month], day, year, hour, minute, second, name, IPADDRESSES[playerid]);
	if(minute < 10 && second >= 10) format(string, sizeof(string), "[%s %i, %i] - [%i:0%i:%i] User: %s disconnected from %s\r\n", Months[month], day, year, hour, minute, second, name, IPADDRESSES[playerid]);
	if(minute >= 10 && second < 10) format(string, sizeof(string), "[%s %i, %i] - [%i:%i:0%i] User: %s disconnected from %s\r\n", Months[month], day, year, hour, minute, second, name, IPADDRESSES[playerid]);
	new File:disconnectlog = fopen( "Logs/Disconnects.txt", io_append);
	fwrite( disconnectlog, string);
	fclose(disconnectlog);
	return 1;
}

public OnPlayerSpawn(playerid)
{
	// User Account System
	if(LoggedIn[playerid] == 1)
	{

	}
	else
	{
	    if(BUD::IsNameRegistered(GetPlayerNameEx(playerid)))
    	{
        	ShowPlayerDialog(playerid, DIALOG_LOGIN, DIALOG_STYLE_INPUT, "Welcome back to Andreas Everything!",
			"Please enter your desired password below, and click 'Login'.\nIf you wish to leave, click 'Leave'.", "Login", "Leave");
    	}
    	else
    	{
        	ShowPlayerDialog(playerid, DIALOG_REGISTER, DIALOG_STYLE_INPUT, "Welcome to Andreas Everything!",
			"Please enter your password below, and click 'Register'.\nIf you wish to leave, click 'Leave'.", "Register", "Leave");
		}
	}
	// Misc
	return 1;
}

public OnPlayerDeath(playerid, killerid, reason)
{
	new string[96], deadplayer[MAX_PLAYER_NAME], killer[MAX_PLAYER_NAME], hour, minute, second, year, month, day;
	gettime( hour, minute, second);
	getdate( year, month, day);
	GetPlayerName( playerid, deadplayer, sizeof(deadplayer));
	if (IsPlayerConnected(killerid))
	{
		GetPlayerName( killerid, killer, sizeof(killer));
		format(string, sizeof(string), "[%s %i, %i] - [%i:%i:%i] - %s killed %s, with a %s\r\n", Months[month], day, year, hour, minute, second, killer, deadplayer, DeathReason[reason]);
	}
	else
	{
		format(string, sizeof(string), "[%s %i, %i] - [%i:%i:%i] - %s has died from %s\r\n", Months[month], day, year, hour, minute, second, deadplayer, DeathReason[reason]);
	}
	new File:deathlog = fopen("Logs/Death Log.txt", io_append);
	fwrite(deathlog, string);
	fclose(deathlog);
	return 1;
}

public OnVehicleSpawn(vehicleid)
{
	return 1;
}

public OnVehicleDeath(vehicleid, killerid)
{
	return 1;
}

public OnPlayerText(playerid, text[])
{
	return 1;
}

//============================================================================//
// ZCMD Commands
CMD:help(playerid, params[])
{
	ShowPlayerDialog(playerid, DIALOG_HELP, DIALOG_STYLE_LIST, "Andreas Everything - Help List",
	"Rules\nCommands\nServer Info", "Ok", "Close");
	return 1;
}
// Admin Commands
CMD:kick(playerid, params[])
{
 	new targetid, reason[128], string[128];
    if(PlayerData[playerid][Adminlevel] <= 1) return SendClientMessage( playerid, COLOR_RED, "This is an admin only command!");
	else
    {
		if(sscanf(params, "us", targetid, reason)) return SendClientMessage(playerid, COLOR_GRAD1, "SYNTAX: /kick [playerid] [reason]");
		else
		{
			format(string, sizeof(string), "Adm: You have kicked %s(%d) from the server.", GetPlayerNameEx(targetid), targetid);
			SendClientMessage(playerid, COLOR_YELLOW, string);
			format(string, sizeof(string), "Reason: %s", reason);
			SendClientMessage(playerid, COLOR_YELLOW, string);
			format(string, sizeof(string), "Adm: You have been kicked from the server by %s(%d)", GetPlayerNameEx(playerid), playerid);
			SendClientMessage(targetid, COLOR_YELLOW, string);
            format(string, sizeof(string), "Reason: %s", reason);
			SendClientMessage(playerid, COLOR_YELLOW, string);
			Kick(targetid);
		}
	}
	return 1;
}

CMD:ban(playerid, params[])
{
    new targetid, reason[128], string[128];
    if(PlayerData[playerid][Adminlevel] <= 1) return SendClientMessage( playerid, COLOR_RED, "This is an admin only command!");
	else
    {
		if(sscanf(params, "us", targetid, reason)) return SendClientMessage(playerid, COLOR_GRAD1, "SYNTAX: /ban [playerid] [reason]");
		else
		{
			format(string, sizeof(string), "Adm: You have ban %s(%d) from the server.", GetPlayerNameEx(targetid), targetid);
			SendClientMessage(playerid, COLOR_YELLOW, string);
			format(string, sizeof(string), "Reason: %s", reason);
			SendClientMessage(targetid, COLOR_YELLOW, string);
			format(string, sizeof(string), "Adm: You have been ban from the server by %s(%d)", GetPlayerNameEx(playerid), playerid);
			SendClientMessage(targetid, COLOR_YELLOW, string);
			format(string, sizeof(string), "Reason: %s", reason);
			SendClientMessage(targetid, COLOR_YELLOW, string);
			Ban(targetid);
		}
	}
	return 1;
}
//============================================================================//
public OnPlayerEnterVehicle(playerid, vehicleid, ispassenger)
{
	return 1;
}

public OnPlayerExitVehicle(playerid, vehicleid)
{
	return 1;
}

public OnPlayerStateChange(playerid, newstate, oldstate)
{
	return 1;
}

public OnPlayerEnterCheckpoint(playerid)
{
	return 1;
}

public OnPlayerLeaveCheckpoint(playerid)
{
	return 1;
}

public OnPlayerEnterRaceCheckpoint(playerid)
{
	return 1;
}

public OnPlayerLeaveRaceCheckpoint(playerid)
{
	return 1;
}

public OnRconCommand(cmd[])
{
	return 1;
}

public OnPlayerRequestSpawn(playerid)
{
	return 1;
}

public OnObjectMoved(objectid)
{
	return 1;
}

public OnPlayerObjectMoved(playerid, objectid)
{
	return 1;
}

public OnPlayerPickUpPickup(playerid, pickupid)
{
	return 1;
}

public OnVehicleMod(playerid, vehicleid, componentid)
{
	return 1;
}

public OnVehiclePaintjob(playerid, vehicleid, paintjobid)
{
	return 1;
}

public OnVehicleRespray(playerid, vehicleid, color1, color2)
{
	return 1;
}

public OnPlayerSelectedMenuRow(playerid, row)
{
	return 1;
}

public OnPlayerExitedMenu(playerid)
{
	return 1;
}

public OnPlayerInteriorChange(playerid, newinteriorid, oldinteriorid)
{
	return 1;
}

public OnPlayerKeyStateChange(playerid, newkeys, oldkeys)
{
	return 1;
}

public OnRconLoginAttempt(ip[], password[], success)
{
	return 1;
}

public OnPlayerUpdate(playerid)
{
	return 1;
}

public OnPlayerStreamIn(playerid, forplayerid)
{
	return 1;
}

public OnPlayerStreamOut(playerid, forplayerid)
{
	return 1;
}

public OnVehicleStreamIn(vehicleid, forplayerid)
{
	return 1;
}

public OnVehicleStreamOut(vehicleid, forplayerid)
{
	return 1;
}

public OnDialogResponse(playerid, dialogid, response, listitem, inputtext[])
{
	// User Account System
	if(dialogid == DIALOG_REGISTER)
	{
	    if(!response)
	        return SendClientMessage(playerid, COLOR_LIGHTRED, "Info: You have decided to leave the server, goodbye."), Kick(playerid);
		//
		BUD::RegisterName(GetPlayerNameEx(playerid), inputtext);
        new
			userid = BUD::GetNameUID(GetPlayerNameEx(playerid));
        BUD::MultiSet(userid, "iiiiff",
        "adminlevel", 0,
        "muted", 0,
        "money", 0,
        "score", 0,
        "health", 100.0,
        "armour", 0.0
    	);
    	ShowPlayerDialog(playerid, DIALOG_LOGIN, DIALOG_STYLE_INPUT, "Welcome back to Andreas Everything!",
		"Please enter your desired password below, and click 'Login'.\nIf you wish to leave, click 'Leave'.", "Login", "Leave");

	}
	if(dialogid == DIALOG_LOGIN)
	{
	    new
			userid = BUD::GetNameUID(GetPlayerNameEx(playerid));
	    if(!response)
	        return SendClientMessage(playerid, COLOR_LIGHTRED, "Info: You have decided to leave the server, goodbye."), Kick(playerid);
		//
		if(BUD::CheckAuth(GetPlayerNameEx(playerid), inputtext))
		{
			PlayerData[playerid][Adminlevel] = BUD::GetIntEntry(userid, "adminlevel");
			PlayerData[playerid][Muted] = BUD::GetIntEntry(userid, "muted");
			PlayerData[playerid][Money] = BUD::GetIntEntry(userid, "money");
			PlayerData[playerid][Score] = BUD::GetIntEntry(userid, "score");
			PlayerData[playerid][Health] = BUD::GetFloatEntry(userid, "health");
			PlayerData[playerid][Armour] = BUD::GetFloatEntry(userid, "armour");
			LoggedIn[playerid] = 1;
			SetSpawnInfo(playerid, 0, 0, 1958.3783, 1343.1572, 15.3746, 269.1425, 0, 0, 0, 0, 0, 0);
			SpawnPlayer(playerid);
			new 
				string[512];
			for(new i = 0; i < MAX_MODES; i++)
			{
				if(MODES[i][1][0] == 0) format(string, sizeof(string), "%s %s: {FF0000} Inactive\r\n", string, MODES[i][0]);
				else
				{
					new players;
					for(new p = 0; p < MAX_PLAYERS; p++)
					{
						if(PlayerData[playerid][MODE] == i) players++;
						else continue;
					}
					format(string, sizeof(string), "%s %s: {00FF00} Active {FFFFFF} Players: %i\r\n", string, MODES[i][0], players);
				}
			}
			ShowPlayerDialog(playerid, DIALOG_MODE_SELECT, DIALOG_STYLE_LIST, "Please select a mode to play", string, "Enter", "Quit");
		}
		else
		    ShowPlayerDialog(playerid, DIALOG_LOGIN, DIALOG_STYLE_INPUT, "Welcome back to Andreas Everything!",
			"Please enter your desired password below, and click 'Login'.\nIf you wish to leave, click 'Leave'.", "Login", "Leave");
  	}
  	// Help Dialog
  	if(dialogid == DIALOG_HELP)
  	{
  	    if(response)
  	    {
			switch(listitem)
			{
		    	case 0: // Rules
		    	{
		            ShowPlayerDialog(playerid, DIALOG_BLANK, DIALOG_STYLE_MSGBOX, "Andreas Everything - Rules",
		            "Andreas Everything rules comming soon.", "Ok", "");
		    	}
		    	case 1: // Commands
		    	{
		    	    ShowPlayerDialog(playerid, DIALOG_BLANK, DIALOG_STYLE_MSGBOX, "Andreas Everything - Commands",
		            "Andreas Everything rules comming soon.", "Ok", "");
		    	}
				case 2: // Server Info
				{
				    ShowPlayerDialog(playerid, DIALOG_BLANK, DIALOG_STYLE_MSGBOX, "Andreas Everything - Server Info",
		            "Andreas Everything rules comming soon.", "Ok", "");
				}
			}
		}
	}
	//Mode Selection Dialog
	if(dialogid == DIALOG_MODE_SELECT)
	{
		if(!response)
		{
			new 
				string[512];
			for(new i = 0; i < MAX_MODES; i++)
			{
				if(MODES[i][1][0] == 0) format(string, sizeof(string), "%s %s: {FF0000} Inactive\r\n", string, MODES[i][0]);
				else format(string, sizeof(string), "%s %s: {00FF00} Active\r\n", string, MODES[i][0]);
			}
			ShowPlayerDialog(playerid, DIALOG_MODE_SELECT, DIALOG_STYLE_LIST, "{FF0000}You must select a mode!", string, "Enter", "Quit");
		}
		else
		{
			switch(listitem)
			{
				case MODE_DEATHMATCH: //Deathmatch
				{
					DeathMatch(playerid);
				}
				case MODE_FREE_ROAM: //Free Roam
				{
					FreeRoam(playerid);
				}
				case MODE_CNR: //CNR
				{
					CNR(playerid);
				}
				case MODE_LOBBY:
				{
					Lobby(playerid);
				}
			}
		}
	}
	return 1;
}

public OnPlayerClickPlayer(playerid, clickedplayerid, source)
{
	return 1;
}
//============================================================================//
//forwards
forward SaveAccount(playerid);
public SaveAccount(playerid)
{
    new Float:health, Float:armour, userid;
    GetPlayerHealth(playerid, health);
    GetPlayerArmour(playerid, armour);
    userid = BUD::GetNameUID(GetPlayerNameEx(playerid));
    //
    BUD::SetIntEntry(userid, "adminlevel", PlayerData[playerid][Adminlevel]);
	BUD::SetIntEntry(userid, "muted", PlayerData[playerid][Muted]);
	BUD::SetIntEntry(userid, "money", GetPlayerMoney(playerid));
	BUD::SetIntEntry(userid, "score", GetPlayerScore(playerid));
	BUD::SetFloatEntry(userid, "health", health);
	BUD::SetFloatEntry(userid, "armour", armour);
	return 1;
}
// stocks
stock GetPlayerNameEx(playerid)
{
	new pName[MAX_PLAYER_NAME];
	if(IsPlayerConnected(playerid))
	{
	    GetPlayerName(playerid, pName, sizeof(pName));
	}
	else pName = "Unknow";
	return pName;
}
// Mode Stocks
stock CNR(playerid)
{
	return 1;
}

stock DeathMatch(playerid)
{
	return 1;
}

stock FreeRoam(playerid)
{
	return 1;
}
stock Lobby(playerid)
{
	SetPlayerVirtualWorld( playerid, LOBBY_VW);
	SetPlayerInterior( playerid, 18);
	SetPlayerPos( playerid, 1727.328125, -1639.4775390625, 20.223743438721);
	PlayerData[playerid][MODE] = MODE_LOBBY;
	return 1;
}
