#include maps\mp\_utility;
#include common_scripts\utility;
#include maps\mp\gametypes\_hud_util;

init()
{
    level thread onplayerconnect();
	level waittill("prematch_over");
	level.callbackPlayerDamage = ::Callback_PlayerDamage;
}

// functions

takeAmmo(slot)
{
	if (slot == "primary")
	{
		self setWeaponAmmoClip(self.primaryWeapon, 0);
		self setWeaponAmmoStock(self.primaryWeapon, 0);
	}
	else if (slot == "secondary")
	{
		if (isSubstr(self.secondaryWeapon, "akimbo"))
		{
			self setWeaponAmmoClip(self.secondaryWeapon, 0, "left");
			self setWeaponAmmoClip(self.secondaryWeapon, 0, "right");
		} else {
			self setWeaponAmmoClip(self.secondaryWeapon, 0);
		}

		self setWeaponAmmoStock(self.secondaryWeapon, 0);
	}

}

// loops

onplayerconnect()
{
    for(;;)
    {
        level waittill("connected", player);
		player thread onplayerspawned();
    }
}

onplayerspawned()
{
    self endon("disconnect");
    for(;;)
    {
        self waittill("spawned_player");
		
		self takeAmmo("secondary");

		self thread antihardscope();
		self thread keys();
	}
}

antihardscope()
{
    self endon( "disconnect" );
    self endon( "death" );

	time = 8;
    adsTime = 0;

    while (true)
    {
        if (self playerAds() == 1) {
            adsTime ++;
        } else {
            adsTime = 0;
		}

        if (adsTime >= time) {
            adsTime = 0;
			
            self allowAds(false);

            while(self playerAds() > 0)
			{
				wait(0.05);
			}
			
            self allowAds(true);
        }
        wait( 0.05 );
	}
}

keys()
{
	self endon("disconnect");
	self endon( "death" );
	
	self notifyonplayercommand("intervention", "+actionslot 4");
	
	while (true) {
		cmd = self waittill_any_return("intervention");
		if (cmd == "intervention") {
			self takeallweapons();
			self giveweapon("iw5_cheytac_mp_cheytacscope_xmags");
			self giveweapon("iw5_usp45_mp");
			self takeAmmo("secondary");
			//self giveweapon("throwingknife_mp"); // giving tk results in it being spammable
			wait 0.05;
			self switchtoweapon("iw5_cheytac_mp_cheytacscope_xmags");
		}
	}
}

// callbacks

Callback_PlayerDamage( eInflictor, attacker, iDamage, iDFlags, sMeansOfDeath, sWeapon, vPoint, vDir, sHitLoc, psOffsetTime )
{
	if (isSubStr(sWeapon, "cheytac") || isSubStr(sWeapon, "msr") || isSubStr(sWeapon, "l96a1") || isSubStr(sWeapon, "throwingknife_mp")) {
        iDamage = 9999;
	} else {
		iDamage = 0;
	}

	if (sMeansOfDeath == "MOD_MELEE" || sMeansOfDeath == "MOD_EXPLOSIVE") {
		iDamage = 0;
	}

	self maps\mp\gametypes\_damage::Callback_PlayerDamage(eInflictor, attacker, iDamage, iDFlags, sMeansOfDeath, sWeapon, vPoint, vDir, sHitLoc, psOffsetTime );
}
