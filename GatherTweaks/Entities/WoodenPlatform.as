#include "Hitters.as"

#include "FireCommon.as"

Random random;

void onInit(CBlob@ this)
{
	this.SetFacingLeft(XORRandom(128) > 64);

	this.getShape().getConsts().waterPasses = true;

	CShape@ shape = this.getShape();
	shape.AddPlatformDirection(Vec2f(0, -1), 89, false);
	shape.SetRotationsAllowed(false);

	this.server_setTeamNum(-1); //allow anyone to break them
	this.set_TileType("background tile", CMap::tile_wood_back);
	this.set_s16(burn_duration , 300);
	//transfer fire to underlying tiles
	this.Tag(spread_fire_tag);

	if (this.getName() == "wooden_platform")
	{

		if (getNet().isServer())
		{
			dictionary harvest;
			harvest.set('mat_wood', 4);
			this.set('harvest', harvest);
		}
	}

	MakeDamageFrame(this);
}

void onHealthChange(CBlob@ this, f32 oldHealth)
{
	f32 hp = this.getHealth();
	bool repaired = (hp > oldHealth);
	MakeDamageFrame(this, repaired);
}

void MakeDamageFrame(CBlob@ this, bool repaired = false)
{
	f32 hp = this.getHealth();
	f32 full_hp = this.getInitialHealth();
	int frame_count = this.getSprite().animation.getFramesCount();
	int frame = frame_count - frame_count * (hp / full_hp);
	this.getSprite().animation.frame = frame;

	if (repaired)
	{
		this.getSprite().PlaySound("/build_wood.ogg");
	}
}

void onSetStatic(CBlob@ this, const bool isStatic)
{
	if (!isStatic) return;

	this.getSprite().PlaySound("/build_wood.ogg");
}

bool canBePickedUp(CBlob@ this, CBlob@ byBlob)
{
	return false;
}

void onTick(CBlob@ this)
{
	//do some extra buring just for platforms
	s16 burn_time = this.get_s16(burn_timer);
	if (burn_time > 0 && (burn_time % 3) == 0 && this.hasTag(spread_fire_tag))
	{
		Vec2f p = this.getPosition() + Vec2f((random.NextFloat() - 0.5f) * 16.0f, (random.NextFloat() - 0.5f) * 16.0f);
		getMap().server_setFireWorldspace(p, true);
	}
}
