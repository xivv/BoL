
--[[

    ____              __     ____                  __  __       
   / __ \____  ____  / /_   / __ )________  ____ _/ /_/ /_  ___ 
  / / / / __ \/ __ \/ __/  / __  / ___/ _ \/ __ `/ __/ __ \/ _ \
 / /_/ / /_/ / / / / /_   / /_/ / /  /  __/ /_/ / /_/ / / /  __/
/_____/\____/_/ /_/\__/  /_____/_/   \___/\__,_/\__/_/ /_/\___/ 
                                                                


]]

if myHero.charName ~= "Fizz" then return end

require "VPrediction"

local ts
local jumpOne = false
local killstealing

function OnLoad()

	PrintChat("<font color=\"#61EE2E\" >Fizz, Stop Breathing</font>")
	ts = TargetSelector(TARGET_LESS_CAST,2050)
	VP = VPrediction()
	Menu()
end

function OnTick()

	ts:update()
	
	KillSteal()
	LastBreath()
	
	if ts.target ~= nil then
		
		KeyListener(ts.target)
	end
end

function KeyListener(Target)

	if not Target and not killstealing then return end
	
	if Param.Key.hkey then
	
		Harass(Target)	
	elseif Param.Key.ckey then 	
	
		Combo(Target)
	end
end

function LastBreath()

	if Param.Setup.breathon and myHero.health <= myHero.maxHealth * (Param.Setup.breath / 100) then
	
		for i, enemy in pairs(GetEnemyHeroes()) do
	
			if InRange(enemy,600) then
		
				CastW()
				CastE(enemy)
				CastQ(enemy)							
			end	
		end	
	end
end

function KillSteal()

	for i, enemy in pairs(GetEnemyHeroes()) do
	
		if InRange(enemy,1200) and not enemy.dead then
		
			if InRange(enemy,600) and GetQDamage(enemy) >= enemy.health then
		
				killstealing = true
				CastQ(enemy)
			elseif InRange(enemy,600) and GetEDamage(enemy) >= enemy.health then
				killstealing = true
				CastE(enemy)
			elseif GetRDamage(enemy) >= enemy.health then
				killstealing = true
				CastR(enemy)
			elseif InRange(enemy,600) and GetDamage(enemy) >= enemy.health then
				Combo(enemy)
			else
				killstealing = false
			end
		end
	end
end

function Harass(Target)

	if InRange(Target,1200) then
		
			if not jumpOne and (CanUse(_Q) and myHero.mana >= GetManaCost(_Q) + GetManaCost(_E)) or InRange(Target,600) then
			
				CastE(Target)
			elseif jumpOne and InRange(Target,750) then
			
				CastE(Target)	
			end
			
			CastQ(Target)
			DelayAction(function() if InRange(Target,myHero.range) and TargetDoted(Target) then CastW() end end,2.1)
	end

end

function Combo(Target)

	if InRange(Target,1200) then
		
			if (CanUse(_Q) and myHero.mana >= GetManaCost(_Q) + GetManaCost(_E)) or InRange(Target,600) then
			
				CastR(Target)
				CastE(Target)
				CastQ(Target)
			    DelayAction(function() if InRange(Target,myHero.range) and TargetDoted(Target) or InRange(Target,myHero.range + myHero.boundingRadius + Target.boundingRadius) then CastW() end end,2.1)
				
			end		
	end
end

function TargetDoted(Target)

    -- return TargetHaveBuff("fizzdot", Target)
	
	for i= 20,1,-1 do 
	
	if Target:getBuff(i).name ~= nil and Target:getBuff(i).name:find("dot") then
	
		return true	
	end
	end
end
function GetManaCost(spell)

	if spell == _Q then return 50
	elseif spell == _W then return myHero:GetSpellData(_W).level * 10 + 20
	elseif spell == _E then return myHero:GetSpellData(_E).level * 5 + 85
	elseif spell == _R then return 100
	end

end

function CastR(Target)

	 local CastPosition, HitChance, Position = VP:GetLineCastPosition(ts.target, 0.25, 80, 1200, 1350, myHero, true)
	 
		if CastPosition and HitChance >= 2 and GetDistance(CastPosition) < 1200 then
		
			CastSpell(_R, CastPosition.x, CastPosition.z)
		end
end

function CastE(Target)

	CastSpell(_E,Target)
end

function CastW()

	CastSpell(_W)
end

function CastQ(Target)

	CastSpell(_Q,Target)
end

function Menu()

	Param = scriptConfig("Fizz, Dont Breath", "Config");

	Param:addSubMenu("Keys", "Key");
		Param.Key:addParam("hkey", "Harass", SCRIPT_PARAM_ONKEYDOWN, false,32);
		Param.Key:addParam("ckey", "Combo", SCRIPT_PARAM_ONKEYDOWN, false,17);
	
	Param:addSubMenu("Setup", "Setup");
		Param.Setup:addParam("flashkill", "FlashKillSteal", SCRIPT_PARAM_ONOFF, true);
		Param.Setup:addParam("breathon", "LastBreath", SCRIPT_PARAM_ONOFF, true);
		Param.Setup:addParam("breath", "LastBreathTreshhold %", SCRIPT_PARAM_SLICE,5.0,1.0,100.0,1.0);
		
	Param:addSubMenu("Draws", "Draw");
		Param.Draw:addParam("eDraw", "Enable", SCRIPT_PARAM_ONOFF, true);
		Param.Draw:addParam("target", "Target", SCRIPT_PARAM_ONOFF, true);
        Param.Draw:addParam("Damage", "Damage", SCRIPT_PARAM_ONOFF, true);
        Param.Draw:addParam("Potential", "Kill", SCRIPT_PARAM_ONOFF, true);
		Param.Draw:addParam("Range", "Range", SCRIPT_PARAM_ONOFF, true);

end

function OnDraw()

    if myHero.dead or not Param.Draw.eDraw then return end
		
	if Param.Draw.Range then
		

		if CanUse(_E) or CanUse(_Q) then DrawCircle3D(myHero.x,myHero.y,myHero.z,600,2,ARGB(255,0,0,0)) DrawCircle3D(myHero.x,myHero.y,myHero.z,200,2,ARGB(255,0,0,0)) end
		if CanUse(_R) then DrawCircle3D(myHero.x,myHero.y,myHero.z,1250,2,ARGB(255,0,0,0)) end
	end
		
	if ts.target ~= nil then
		
		if Param.Draw.Damage then
	
			DrawText3D("" .. GetDamage(ts.target),ts.target.x,ts.target.y,ts.target.z,12,ARGB(255,255,100,0))		
		end
		
		if Param.Draw.target and ts.target ~= nil then
	
			DrawCircle3D(ts.target.x,ts.target.y,ts.target.z,50,2,ARGB(255,255,0,0))		
		end
		
		if Param.Draw.Potential then
	
			DrawkillPotential(GetDamage(ts.target))
		end		
	end
end

function DrawkillPotential(damage)

	for i, Target in pairs(GetEnemyHeroes()) do
	
		if Target.dead then else 
			if(damage >= Target.health) then

				DrawCircle3D(Target.x,Target.y,Target.z,75,3,ARGB(255,255,0,0))
			elseif damage * 1.2 >= Target.health then

				DrawCircle3D(Target.x,Target.y,Target.z,75,3,ARGB(255,0,255,0))
			elseif damage * 1.5 >= Target.health then

				DrawCircle3D(Target.x,Target.y,Target.z,75,3,ARGB(255,0,255,255))
			end
	end
end
end

function GetDamage(Target) 

	return math.ceil(GetRDamage(Target) + GetQDamage(Target) + GetWDamage(Target) + GetEDamage(Target))
end

function GetRDamage(Target)

	if CanUse(_R) then

		local dmg 
	
		if GetDistance(Target) > 910 then
			
			dmg = myHero:GetSpellData(_R).level * 100 + 200 + 1.2 * myHero.ap
			
		elseif GetDistance(Target) < 910 and GetDistance(Target) > 455 then
		
			dmg = myHero:GetSpellData(_R).level * 100 + 125 + 0.8 * myHero.ap
			
		elseif GetDistance(Target) < 455 then
			
			dmg = myHero:GetSpellData(_R).level * 100 + 50 + 0.6 * myHero.ap
			
		end

		return myHero:CalcMagicDamage(Target,dmg)
	else
		return 0
	end
end

function GetEDamage(Target)

	if CanUse(_E) then
	
		local dmg = myHero:GetSpellData(_E).level * 50 + 20 + 0.75 * myHero.ap
		return myHero:CalcMagicDamage(Target,dmg)
	else
		return 0
	end
end

function GetWDamage(Target)

	if CanUse(_W) then
	
		local dmg = myHero:GetSpellData(_W).level * 15 + 10
		return myHero:CalcMagicDamage(Target,dmg)
	else
		return 0
	end
end

function GetQDamage(Target)

	if CanUse(_Q) then
	
		local dmg = myHero:GetSpellData(_Q).level * 15 - 5 + 0.35 * myHero.ap
		return	myHero:CalcDamage(Target,myHero.damage) + myHero:CalcMagicDamage(Target,dmg)
	else
		return 0
	end
end


function OnProcessSpell(unit,spell)

	if unit.isMe then
	
		if spell.name == "FizzE" then
		
			jumpOne = true
		end
	end
end

function OnRemoveBuff(unit,buff)

	if unit.isMe then
		
		if buff.name == "fizzeicon" then
		
			jumpOne = false
		end
	end
end


function CanUse(spell)

	return myHero:CanUseSpell(spell) == READY
end

function InRange(Target,range)

	if GetDistanceSqr(Target) < range*range then return true else return false end
end
