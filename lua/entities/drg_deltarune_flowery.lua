if not DrGBase then return end -- return if DrGBase isn't installed
ENT.Base = "drgbase_nextbot" -- DO NOT TOUCH (obviously)

-- Misc --
ENT.PrintName = "Flowery"
ENT.Category = "DELTARUNE"
ENT.Models = {"models/nextbot/deltarune_lp/flowery_lp.mdl"}
ENT.SpawnHealth = 999

-- AI --
ENT.BehaviourType = AI_BEHAV_BASE
ENT.RangeAttackRange = 0
ENT.MeleeAttackRange = 1135
ENT.ReachEnemyRange = 0
ENT.AvoidEnemyRange = 0
ENT.Acceleration = 10000
ENT.Decceleration = 10000
ENT.MaxYawRate = 10000

-- Relationships --
ENT.DefaultRelationship = D_HT
ENT.Factions = {"FACTION_HL2_REBELS"}

-- Animations --
ENT.SpawnAnimations = {}
ENT.WalkAnimation = "walk"
ENT.RunAnimation = "run"
ENT.IdleAnimation = "idle"
ENT.DeathAnimations = {}
ENT.JumpAnimation = "jump"

-- Sounds --
ENT.AmbientSounds = {}
ENT.DeathSounds = {}

-- Movements --
ENT.UseWalkframes = false
ENT.WalkSpeed = 60
ENT.RunSpeed = 600

-- Climbing --
ENT.ClimbLedges = true
ENT.ClimbProps = true
ENT.ClimbLedgesMaxHeight = 300
ENT.ClimbLadders = true
ENT.ClimbSpeed = 60
ENT.ClimbUpAnimation = ACT_ZOMBIE_CLIMB_UP
ENT.ClimbOffset = Vector(-14, 0, 0)

-- Detection --
ENT.EyeBone = "ValveBiped.Bip01_Head1"
ENT.EyeOffset = Vector(5, 0, 2.5)

-- Possession --
ENT.PossessionEnabled = true
ENT.PossessionMovement = POSSESSION_MOVE_CUSTOM
ENT.PossessionViews = {
  {
    offset = Vector(0, 0, 45),
    distance = 150
  }
}
ENT.PossessionBinds = {
	[IN_ATTACK] = {{coroutine = true,onkeydown = function(self)
		if not self.Combat then return end
		self:JaronaAttack()
	end}},
	[IN_ATTACK2] = {{coroutine = true,onkeydown = function(self)
		if not self.Combat then return end
		self:BarrageAttack()
	end}},
	[IN_RELOAD] = {{coroutine = true,onkeydown = function(self)
		if not self.Combat then
			self:Quote()
		end
		if not self.Combat then return end
		self:PrismBlow()
	end}},
	[IN_DUCK] = {{coroutine = true,onkeydown = function(self)
		self:Taunt()
	end}},
	[IN_JUMP] = {{coroutine = true,onkeydown = function(self)
		if not self.Combat then return end
		self:SpiralDance()
	end}},
}

function ENT:PossessorView()
	if not self:IsPossessed() then return end
	local current, view = self:CurrentViewPreset()

	local origin
	local distance
	if current == -1 or view.auto then
		origin = self:WorldSpaceCenter() +
			Vector(0, 0, self:Height() / 3)
		distance = self:Length() * 3
	else
		local offset = view.offset or Vector(0, 0, 0)
		if view.eyepos then
			origin = self:EyePos()
		elseif isstring(view.bone) then
			local boneid = self:LookupBone(view.bone)
			if boneid ~= nil then
				origin = self:GetBonePosition(boneid)
			end
		elseif IsValid(self:GetNW2Entity("Barraged")) then
			 origin = self:GetNW2Entity("Barraged"):WorldSpaceCenter()
		else origin = self:WorldSpaceCenter() end

		local tr = self:TraceLine(
			self:PossessorForward() * offset.x * self:GetModelScale() +
			self:PossessorRight() * offset.y * self:GetModelScale() +
			self:PossessorUp() * offset.z * self:GetModelScale(), {
			start = origin,
			mask = COLLISION_GROUP_DEBRIS,
			filter = {self,self:GetNW2Entity("Barraged")},
		})

		origin = tr.HitPos
		distance = view.distance or 0
	end

	local tr = self:TraceLine(-self:PossessorNormal() * distance * self:GetModelScale(), {start = origin,filter={self,self:GetNW2Entity("Barraged")},mask = COLLISION_GROUP_DEBRIS})
	return tr.HitPos, self:GetPossessor():EyeAngles()
end
if SERVER then
function ENT:PossessionControls(f,b,r,l)
	if self.AnimState then return end
	local direction = self:GetPos()
		if f then direction = direction + self:PossessorForward()
		elseif b then direction = direction - self:PossessorForward() end
		if r then direction = direction + self:PossessorRight()
		elseif l then direction = direction - self:PossessorRight() end
		if direction ~= self:GetPos() then self:MoveTowards(direction) end
end

	-- Init/Think --

	function ENT:OnLandOnGround()
		self.Combo = 0
		self.PrismCombo = false
		if self.DeathFall then
			self.DeathFall = false
			self:EmitSound("deltarune/snd_impact.wav",100)
			self:DeathAnim()
		end
		if self.Jarona then
			self.Jarona = false
			self.JaronaFly = false
			self:SetColor(Color(255,255,255))
			self.AnimState = false
		end
	end
	function ENT:NewModelBBFix(model)
		self:SetModel(model)
		self:SetCollisionBounds(
		  Vector(self.CollisionBounds.x, self.CollisionBounds.y, self.CollisionBounds.z),
		  Vector(-self.CollisionBounds.x, -self.CollisionBounds.y, 0)
		)
	end
	function ENT:Quote()
		if self.AnimState then return end
		self.AnimState = true
		local anims = {"condescend","point_cooler","pose","shrugforward"}
		self.AnimStateAnim = anims[math.random(#anims)]
		local clips = {"snd_flowery_voiceclip_itsmeflowery","snd_flowery_voiceclip_itsme","snd_flowery_voiceclip_heyguys","snd_flowery_voiceclip_heyguysithinkifoundaglue","snd_flowery_voiceclip_heytherelittleguy","snd_flowery_voiceclip_sorrytokeepyouwaiting1","snd_flowery_voiceclip_sorrytokeepyouwaiting2","snd_flowery_voiceclip_sorrytokeepaladyinwaiting","snd_flowery_voiceclip_all_according_to_all_according_to_plant","snd_flowery_voiceclip_flowery","snd_flowery_voiceclip_flowery2","snd_flowery_voiceclip_glue","snd_flowery_voiceclip_great_style","snd_flowery_voiceclip_hey","snd_flowery_voiceclip_imsorryonceagainikeptaladyinwaiting","snd_flowery_voiceclip_its_all_in_a_name","snd_flowery_voiceclip_its_all_yours","snd_flowery_voiceclip_its_so_human","snd_flowery_voiceclip_itsme","snd_flowery_voiceclip_minipeppers","snd_flowery_voiceclip_mostlys","snd_flowery_voiceclip_my_king","snd_flowery_voiceclip_stingus","snd_flowery_voiceclip_thatsgreat","snd_flowery_voiceclip_theyre_eating_my_flesh","snd_flowery_voiceclip_thisguysyourbestfriend","snd_flowery_voiceclip_try_my_flavor","snd_flowery_voiceclip_wow","snd_flowery_voiceclip_yes","snd_flowery_voiceclip_yourdadsmybestfriend"}
		self:EmitVoice("deltarune/flowery/"..clips[math.random(#clips)]..".wav")
		self:Timer(1,function()
			self.AnimState = false
			self:EnableAI()
		end)
	end
	function ENT:Taunt()
		if self.AnimState then return end
		if not self.Combat then
			self.PoweringUp = true
			self.AnimState = true
			self.Combat = true
			self.IFRAME = true
			self.AnimStateAnim = "poweringup"
			self:EmitSound("deltarune/flowery/snd_flowery_power_up.wav",511)
			self:Timer(3,function()
				self:EmitVoice("deltarune/flowery/snd_flowery_voiceclip_lend_me_your_power.wav")
				self.AnimStateAnim = "poweringupfinish"
				self.PoweringUp = false
			end)
			self:Timer(3.7,function()
				self.AnimStateAnim = "powerupintoidletransition"
			end)
			self:Timer(4.7,function()
				self.IFRAME = false
				self.AnimState = false
			end)
		return
		end
		if self.DreamMeter == 100 and not self.Omega then
			self.PoweringUp = true
			self.IFRAME = true
			self.AnimState = true
			self:SetCooldown("OmegaTime",999)
			self.AnimStateAnim = "poweringup"
			self:EmitSound("deltarune/flowery/snd_flowery_power_up.wav",511)
			self:EmitVoice("deltarune/flowery/snd_flowery_voiceclip_with_your_powers_combined.wav")
			self:Timer(4,function()
				for _,ply in pairs(player.GetAll()) do
					ply:ScreenFade( SCREENFADE.OUT, Color( 255, 255, 255, 255 ), 0.7, 0.1 )
				end
				self.AnimStateAnim = "poweringupfinish"
			end)
			self:Timer(4.7,function()
				for _,ply in pairs(player.GetAll()) do
					ply:ScreenFade( SCREENFADE.IN, Color( 255, 255, 255, 255 ), 0.5, 0 )
				end
				self:NewModelBBFix("models/nextbot/deltarune_lp/omega_flowery_lp.mdl")
				self.FreezeFrame = true
				self.PoweringUp = false
				self.AnimStateAnim = "omega_pose"
				self.Omega = true
				self:EmitVoice("deltarune/flowery/snd_flowery_voiceclip_omega_flowery.wav")
			end)
			self:Timer(7.5,function()
				self.AnimStateAnim = "omega_flex"
				self:EmitVoice("deltarune/flowery/snd_flowery_voiceclip_last_jarona.wav")
			end)
			self:Timer(9,function()
				self:SetCooldown("OmegaTime",35)
				self.AnimState = false
				self.FreezeFrame = false
			end)
		else
			self.AnimState = true
			--self:FaceInstant(self:GetPos()+self:GetAimVector()*1000)
			local clips = {"snd_flowery_voiceclip_thatsgreat","snd_flowery_voiceclip_dont_you_like_serving_humans","snd_flowery_voiceclip_flowers_blooms_in_your_heart","snd_flowery_voiceclip_forget_it","snd_flowery_voiceclip_get_a_chance_1","snd_flowery_voiceclip_get_a_chance_2","snd_flowery_voiceclip_go_home","snd_flowery_voiceclip_heh_it_s_my_jarona","snd_flowery_voiceclip_huhillshowyou","snd_flowery_voiceclip_nonono","snd_flowery_voiceclip_sorryaboutthatlittleguy","snd_flowery_voiceclip_suckle_it_up","snd_flowery_voiceclip_what_a_predictable_creature"}
			self.AnimStateAnim = "condescend"
			self:EmitVoice("deltarune/flowery/"..clips[math.random(#clips)]..".wav")
			self.DreamMeter = self.DreamMeter + 5
			if self.DreamMeter >= 100 then
				self.DreamMeter = 100
			end
			self:Timer(1,function()
				self.AnimState = false
			end)
		end
	end
	function ENT:SpiralDance()
		if self.AnimState or self.DreamMeter < 20 then return end
		self.AnimState = true
		self:FaceInstant(self:GetPos()+self:GetAimVector()*1000)
		self.AnimStateAnim = "pirouette"
		self:EmitSound("deltarune/snd_pirouette.wav",100)
		self.DreamMeter = self.DreamMeter - 20
		if self.DreamMeter < 0 then
			self.DreamMeter = 0
		end
		self:EmitVoice("deltarune/flowery/snd_flowery_voiceclip_spiral_dance.wav")
		for k,v in pairs(ents.FindInSphere(self:GetPos(),500)) do
			v:SetGravity(300)
			if v:IsNextBot() then
				v.loco:SetGravity(300)
				v.loco:Jump(10)
			end
			v:SetGroundEntity(NULL)
			v:SetVelocity(v:GetUp()*1000)
		end
		self:Timer(2,function()
			self.AnimState = false
		end)
	end
	function ENT:PrismBlow()
		if self.AnimState or self.DreamMeter < 10 then return end
		self.AnimState = true
		self:FaceInstant(self:GetPos()+self:GetAimVector()*1000)
		local clips = {"snd_flowery_voiceclip_prism_blow","snd_flowery_voiceclip_mysterious_wind"}
		self.AnimStateAnim = "kiss"
		self:EmitSound("deltarune/snd_magicsprinkle.wav",100)
		self.DreamMeter = self.DreamMeter - 10
		if self.DreamMeter < 0 then
			self.DreamMeter = 0
		end
		self:EmitVoice("deltarune/flowery/"..clips[math.random(#clips)]..".wav")
		self:Timer(0.5,function()
			self:EmitSound("deltarune/snd_coaster_kiss.wav",100)
			self:EmitSound("deltarune/snd_spellcast.wav",100)
			self:Attack({
				damage = 0,
				viewpunch = Angle(0, 0, 0),
				type = DMG_CLUB,
				range=600,
				angle=140,
			}, function(self, hit)
				for k,v in pairs(hit) do
					v.PrismBlown = true
					self:KnockBack(v,800,500)
					timer.Simple(2,function()
						if IsValid(v) then
							v.PrismBlown = false
						end
					end)
				end
			end)
		end)
		self:Timer(1,function()
			self.AnimState = false
		end)
	end
	function ENT:BarrageAttack()
		if self.AnimState or self.Barrage or self.FreezeFrame or self.Jarona or self.DreamMeter < 15 then return end
		self.AnimState = true
		self.DreamMeter = self.DreamMeter - 15
		if self.DreamMeter < 0 then
			self.DreamMeter = 0
		end
		self:SetCooldown("BarrageAutoEnd",5)
		self:FaceInstant(self:GetPos()+self:GetAimVector()*1000)
		self.AnimStateAnim = "prepare"
		self:EmitSound("deltarune/snd_grab.wav",100)
		local clips = {"snd_flowery_voiceclip_leaf_it_to_me","snd_flowery_voiceclip_hereicomesanfrandisco_strong","snd_flowery_voiceclip_huhillshowyou"}
		self:EmitVoice("deltarune/flowery/"..clips[math.random(#clips)]..".wav")
		self:Timer(0.5,function()
			self.Barrage = true
			self:EmitSound("deltarune/snd_chargeshot_fire.wav",100)
			self.AnimState = false
		end)
	end
	function ENT:JaronaAttack(ent)
		if self.AnimState or self.Jarona or self.FreezeFrame or self.Barrage then return end
		self.AnimState = true
		self.IFRAME = true
		self.FreezeFrame = true
		if !self.Combo then
			self.Combo = 0
		end
		if IsValid(ent) then
			self:FaceInstant(ent)
		else
			self:FaceInstant(self:GetPos()+self:GetAimVector()*1000)
		end
		local anims = {"crouch","jump","punchwindup"}
		self.AnimStateAnim = anims[math.random(#anims)]
		self:EmitVoice("deltarune/flowery/snd_flowery_voiceclip_jarona"..math.random(4)..".wav")
		self:Timer(0.25,function()
			self.Jarona = true
			self.IFRAME = false
			self.loco:SetGravity(600)
			self.FreezeFrame = false
			if self:IsPossessed() and not self.PrismCombo and self:GetPossessor():KeyDown(IN_RELOAD) then
					self.AnimStateAnim = "shrugforward"
					self:EmitVoice("deltarune/flowery/snd_ja_kidding.wav")
					self.Jarona = false
					self:Timer(0.5,function()
						self.AnimState = false
					end)
			else
				self:SetColor(Color(0,161,255))
				self.JaronaFly = true
				if IsValid(ent) then
					self:FaceInstant(ent)
				else
					self:FaceInstant(self:GetPos()+self:GetAimVector()*1000)
				end
				self:EmitSound("deltarune/snd_glove_launch.wav")
				if self.AnimStateAnim == "crouch" then
					self.AnimStateAnim = "fair"
				elseif self.AnimStateAnim == "jump" then
					self.AnimStateAnim = "shrugforward"
				elseif self.AnimStateAnim == "punchwindup" then
					self.AnimStateAnim = "puunch"
				end
					self:LeaveGround()
					if IsValid(ent) then
						if self:IsOnGround() then
							self:SetVelocity(self:GetUp()*150+self:GetForward()*1500)
						else
							self:SetVelocity(self:GetForward()*1500)
						end
					else
						if self:IsOnGround() then
							self:SetVelocity(self:GetUp()*150+self:GetAimVector()*1500)
						else
							self:SetVelocity(self:GetAimVector()*1500)
						end
					end
			end
		end)
	end
	function ENT:KnockBack(ent, up, back)
		if not IsValid(ent) then return end
		if ent:Health() <= 0 or ent.NoKnockback then return end
		local up = up or 300
		local back = back or 250
		local push = ents.Create("prop_dynamic")
		push:SetModel("models/Gibs/HGIBS.mdl")
		push:Spawn()
		push:SetPos(ent:GetPos())
		local angle = (ent:GetPos() - self:GetPos()):Angle()
		push:SetAngles(Angle(0, angle.y, angle.z))
		push:SetNoDraw(true)
		push:SetNotSolid(true)
		push:SetOwner(self)
		if ent.GWNextBot then
			ent.KnockBacked = true
		end
		if ent.IsDrGNextbot then
		ent:Jump()
		ent:LeaveGround()
		ent:SetVelocity(push:GetUp()*up + push:GetForward()*back)
		elseif ent.Type == "nextbot" then
		local JumpHeight = ent.loco:GetJumpHeight()
		ent.loco:SetJumpHeight(1)
		ent.loco:Jump()
		ent.loco:SetJumpHeight( JumpHeight )
		ent.loco:SetVelocity(push:GetUp()*up + push:GetForward()*back)
		else
		end
		ent:SetGroundEntity(NULL)
		ent:SetVelocity(push:GetUp()*up + push:GetForward()*back)
		SafeRemoveEntity(push)
	end
	function ENT:OnContact(ent)
		if IsValid(ent) and ent == self:GetPossessor() then return end
		if self.Jarona and not ent.PrismBlown then
			self.Jarona = false
			self.JaronaFly = false
			self:SetColor(Color(255,255,255))
			self.Combo = self.Combo + 1
			self:EmitSound("deltarune/snd_heavyswing.wav")
			self:EmitSound("deltarune/snd_punchmed.wav")
			local clips = {"snd_flowery_voiceclip_hah","snd_flowery_voiceclip_hoo","snd_flowery_voiceclip_huh"}
			self:EmitVoice("deltarune/flowery/"..clips[math.random(#clips)]..".wav")
			self:AfterImage(_,true)
				self.loco:SetGravity(0)
				self:SetCollisionGroup(COLLISION_GROUP_IN_VEHICLE)
			local push = ents.Create("prop_dynamic")
			push:SetModel("models/Gibs/HGIBS.mdl")
			push:Spawn()
			push:SetPos(ent:WorldSpaceCenter())
			local angle = (ent:WorldSpaceCenter() - self:WorldSpaceCenter()):Angle()
			push:SetAngles(Angle(0, angle.y, angle.z))
			push:SetNoDraw(true)
			push:SetNotSolid(true)
			push:SetOwner(self)
			if ent == game.GetWorld() then
				self.Combo = 0
				self:EmitSound("deltarune/snd_impact.wav",100)
				self.AnimStateAnim = "deflected"
				if self.Omega then
					self:Timer(0.25,function()
						self.AnimState = false
						self:SetCollisionGroup(COLLISION_GROUP_NONE)
					end)
				else
					self:Timer(1,function()
						self.AnimState = false
						self:SetCollisionGroup(COLLISION_GROUP_NONE)
					end)
				end
				self:Timer(0.1,function()
					self:LeaveGround()
					self:SetVelocity(self:GetUp()*250+self:GetForward()*-500)
					SafeRemoveEntity(push)
					self.loco:SetGravity(600)
				end)
				local dmg = DamageInfo()
				dmg:SetAttacker( self )
				dmg:SetInflictor( self )
				dmg:SetDamage( 80 )
				dmg:SetDamageType( DMG_BLAST )
				dmg:SetDamagePosition( self:GetPos() )
				ent:TakeDamageInfo( dmg )
				self.DreamMeter = self.DreamMeter - 5
				if self.DreamMeter < 0 then
					self.DreamMeter = 0
				end
			elseif self.Combo >= 4 and not self.Omega or self.Combo >=10 and self.Omega or ent:Health()<80 or self.PrismCombo then
				self.Combo = 0
				self.IFRAME = true
				self.PrismCombo = false
				self.FreezeFrame = true
				self.FreezeFramePartner = ent
				local fx = EffectData()
				fx:SetEntity(self)
				fx:SetOrigin(push:GetPos())
				fx:SetStart(push:GetPos())
				fx:SetScale(5)
				fx:SetMagnitude(5)
				util.Effect("MetalSpark",fx)
				if ent.IsDrGNextbot then
					ent:DisableAI()
				end
				self:EmitVoice("deltarune/flowery/snd_forthefans.wav")
				self:Timer(3,function()
					self:SetCollisionGroup(COLLISION_GROUP_NONE)
					self.AnimState = false
				end)
				self:Timer(2,function()
					self.DreamMeter = self.DreamMeter + 15
					if self.DreamMeter > 100 then
						self.DreamMeter = 100
					end
					self.IFRAME = false
					self:AfterImage()
					self:EmitSound("deltarune/snd_ultraswing.wav")
					self:EmitSound("deltarune/snd_punchheavythunder.wav")
					if IsValid(ent) then
						local dmg = DamageInfo()
						dmg:SetAttacker( self )
						dmg:SetInflictor( self )
						dmg:SetDamage( 150 )
						dmg:SetDamageType( DMG_BLAST )
						dmg:SetDamagePosition( self:GetPos() )
						ent:TakeDamageInfo( dmg )
						if ent.IsDrGNextbot then
							ent:EnableAI()
						end
					end
					self.FreezeFramePartner = nil
					self.AnimStateAnim = "shrugspin"
					self.FreezeFrame = false
					self:LeaveGround()
					self:RemoveFlags(FL_NOTARGET)
					self:SetVelocity(self:GetUp()*250+push:GetForward()*-1000)
					ent:SetVelocity(self:GetUp()*250+self:GetForward()*1000)
					SafeRemoveEntity(push)
					self.loco:SetGravity(600)
				end)
			else
				self.DreamMeter = self.DreamMeter + 5
				if self.DreamMeter > 100 then
					self.DreamMeter = 100
				end
				self.AnimStateAnim = "shrugspin"
				if self.Omega then
					self:Timer(0.25,function()
						self.IFRAME = false
						self.AnimState = false
						self:SetCollisionGroup(COLLISION_GROUP_NONE)
					end)
				else
					self:Timer(0.5,function()
						self.IFRAME = false
						self.AnimState = false
						self:SetCollisionGroup(COLLISION_GROUP_NONE)
					end)
				end
				self:Timer(0.1,function()
					self:LeaveGround()
					if self.Omega then
						self:SetVelocity(self:GetUp()*250+push:GetForward()*-1500)
					else
						self:SetVelocity(self:GetUp()*250+push:GetForward()*-500)
					end
					SafeRemoveEntity(push)
					self.loco:SetGravity(600)
				end)
				local dmg = DamageInfo()
				dmg:SetAttacker( self )
				dmg:SetInflictor( self )
				dmg:SetDamage( 80 )
				dmg:SetDamageType( DMG_BLAST )
				dmg:SetDamagePosition( self:GetPos() )
				ent:TakeDamageInfo( dmg )
			end
		elseif self.Barrage or self.Jarona and ent.PrismBlown and self.DreamMeter >= 10 then
			if ent.PrismBlown then
				self.DreamMeter = self.DreamMeter - 10
				if self.DreamMeter < 0 then
					self.DreamMeter = 0
				end
				self.PrismCombo = true
				ent:SetGravity(0)
			end
			if ent:IsNextBot() or ent:IsNPC() or ent:IsPlayer() then
				self:AfterImage(_,true)
				self.BHits = 0
				self.IFRAME = true
				self.Jarona = false
				self.JaronaFly = false
				self:SetColor(Color(255,255,255))
				self.Barrage = false
				self.Barraged = ent
				self:SetNW2Entity("Barraged",ent)
				self:AddFlags(FL_NOTARGET)
				if ent.IsDrGNextbot then
					ent:DisableAI()
				end
				self.Barrging = true
			end
		end
	end
	function ENT:ZombiePreSpawn()
	end
	function ENT:ZombieOnSpawn()
	end
	function ENT:ZombiePostSpawn()
	end
	function ENT:OnSpawn()
		self:DisableAI()
		self.AnimState = true
		--[[self.AnimStateAnim = "poweringup"
		self:EmitSound("deltarune/flowery/snd_flowery_power_up.wav",511)
		self:EmitVoice("deltarune/flowery/snd_flowery_voiceclip_lend_me_your_power.wav")
		self:Timer(3,function()
			self.AnimStateAnim = "poweringupfinish"
		end)
		self:Timer(3.7,function()
			self.AnimState = false
		end)]]
		self.AnimStateAnim = "point_cooler"
		self:EmitSound("deltarune/flowery/snd_flowery_joined.wav",511)
		local clips = {"snd_flowery_voiceclip_itsmeflowery","snd_flowery_voiceclip_itsme","snd_flowery_voiceclip_heyguys","snd_flowery_voiceclip_heyguysithinkifoundaglue","snd_flowery_voiceclip_heytherelittleguy","snd_flowery_voiceclip_sorrytokeepyouwaiting1","snd_flowery_voiceclip_sorrytokeepyouwaiting2","snd_flowery_voiceclip_sorrytokeepaladyinwaiting"}
		self:EmitVoice("deltarune/flowery/"..clips[math.random(#clips)]..".wav")
		self:Timer(2,function()
			self.AnimState = false
			self:EnableAI()
		end)
	end
	function ENT:ZombieInit()
	end
	function ENT:CustomInitialize()
		self.DreamMeter = 0
	end
	function ENT:AttackFunction(dmg,dmgtype,sndhit,sndmiss,rang,bleed,bleedtime,ang,viewp)
		local dmg = dmg or 15
		local dmgtype = dmgtype or DMG_GENERIC
		local sndhit = sndhit or "npc/combine_soldier/vo/_period.wav"
		local sndmiss = sndmiss or "npc/combine_soldier/vo/_period.wav"
		local viewp = viewp or 20
		local rang = rang or 55
		local bleed = bleed or false
		local bleedtime = bleedtime or 4
		local ang = ang or 135
		self:Attack({
			damage = dmg,
			viewpunch = Angle(viewp, 0, 0),
			type = dmgtype,
			range=rang,
			angle=ang,
		}, function(self, hit)
			if #hit == 0 then self:EmitSound(sndmiss)return end 
			self:EmitSound(sndhit)
		end)
	end
	function ENT:StopAttack()
		self.EndAttack = true
		for i=1,1000 do
			timer.Remove("AttackTimer_"..i.."_"..self:EntIndex())
		end
	end
    function ENT:ZombieDealtDamage()
	end
    function ENT:OnDealtDamage(ent, dmg)
		self:ZombieDealtDamage(ent, dmg)
		if self.SelectAttack and self.SelectAttack["DamageFX"] != nil then
			self.SelectAttack["DamageFX"].func(self,1,ent)
		end
    end
	function ENT:DoAttack(id,enemy)
		if not isnumber(id) then return end
		self.SelectAttack = self.Attacks[id]
		if self:GetCooldown(self.SelectAttack["Properties"].CooldownName)>0 or self.SelectAttack["Properties"].BeginRange and not self:IsInRange(enemy,self.SelectAttack["Properties"].BeginRange) then return end
		self:RandomizeAnims()
		self.EndAttack = false
		if self.SelectAttack["Properties"].Event != nil then
			self:SetNW2Float("AttackEvent",self.SelectAttack["Properties"].Event)
		end
		if self.SelectAttack["Properties"].HasTimerEvents then
			for i=1,#self.SelectAttack["Timing"] do
				if isstring(self.SelectAttack["Timing"][i]) then
					self.SelectAttack["SpecialTimers"][self.SelectAttack["Timing"][i]].func(self,i)
					time = self.NewTimer
				else
					time = self.SelectAttack["Timing"][i]
				end
				timer.Create("AttackTimer_"..i.."_"..self:EntIndex(), time, 1, function()
					if not IsValid(self) then return end
					self.SelectAttack["EventFuncs"][self.SelectAttack["Events"][i]].func(self,i)
				end)
			end
		end
		if self.SelectAttack["Properties"].Gesture then
			self:PlaySequenceAndOverrideGesture(self.SelectAttack["Properties"].Animation,{rate = self.SelectAttack["Properties"].AnimRate})
		else
			self:SetVelocity(Vector(0,0,self:GetVelocity().z))
			self:PlaySequenceAndMove(self.SelectAttack["Properties"].Animation,{rate = self.SelectAttack["Properties"].AnimRate},function(self)
				if self.SelectAttack and self.SelectAttack["Properties"].FaceEnemy and self:HasEnemy() then self:FaceEnemy() end
				if self.EndAttack then self.EndAttack = false return true end
			end)
		end
	end
	function ENT:OnMeleeAttack(enemy)
		self:JaronaAttack()
	end
	function ENT:PerZombieEvents(a,b,c,d,e)
	end
	function ENT:HandleAnimEvent(a,b,c,d,e)
		self:PerZombieEvents(a,b,c,d,e)
		print(e)
		if e=="boss_headbang" then
			self:EmitSound("nz_moo/zombies/vox/_engineer/fly/headbang/headbang_0"..math.random(0,5)..".mp3")
		elseif e=="death_ragdoll" then
			self:BecomeRagdollSBXZ()
		end
	end

	function ENT:OnUpdateAnimation()
		if self:IsDead() then return end
		if self.AnimState then return self.AnimStateAnim, 1
		elseif not self:IsOnGround() then return self.JumpAnimation, 1
		elseif self:IsMoving() and self:IsRunning() then return self.RunAnimation, 1
		elseif self:IsMoving() then return self.WalkAnimation, 1
		else return self.IdleAnimation, 1 end
	end
	function ENT:EmitVoice(snd,lvl,pitch)
		pitch = pitch or 100
		level = lvl or 100
		self:SetCooldown("AmbientSound",math.Rand(3,8)+SoundDuration(snd))
		self:EmitSound(snd,level,pitch,1,CHAN_VOICE)
	end
	function ENT:CustomThink()
		if self.Omega then
			self.DreamMeter = 100
		end
		if self.Omega and not self.AnimState and self:GetCooldown("OmegaTime")<=0 then
			self.Omega = false
			if self:IsOnGround() then
				self:DeathAnim()
			else
				self.DeathFall = true
				self.loco:SetGravity(200)
				self:SetVelocity(Vector(0,0,5))
				self:EmitSound("deltarune/snd_fall.wav",100)
				self:EmitVoice("deltarune/flowery/snd_flowery_voiceclip_im_falling.wav")
				self:ResetSequence("hurt")
			end
		end
		self:SetDreamMeter(self.DreamMeter)
		if (self:IsRunning() and not self.Jarona and self:IsOnGround()) or self.Barrage or self.JaronaFly or self.Omega then
			if (self.Barrage or self.JaronaFly) and not self.Omega then
				self:AfterImage(_,true)
			else
				self:AfterImage(true)
			end
		end
		if self.Barrage and self:GetCooldown("BarrageAutoEnd")<=0 then
			self.Barrage = false
			self.AnimState = true
			self.AnimStateAnim = "brave_shocked"
			self:EmitSound("deltarune/snd_smallswing.wav",100)
			self:Timer(0.5,function()
				self.AnimState = false
			end)
		end
		if self.FreezeFrame then
			self.loco:SetGravity(0)
			self:SetVelocity(Vector(0,0,0))
			if IsValid(self.FreezeFramePartner) then
				self.FreezeFramePartner:SetVelocity(Vector(0,0,0))
			end
		elseif self.PoweringUp then
			self.loco:SetGravity(0)
			self:SetVelocity(Vector(0,0,5))
			if self:IsOnGround() then
				self:SetPos(self:GetPos()+Vector(0,0,25))
			end
		end
		if self.Barrging then
			self.loco:SetGravity(0)
			self:SetVelocity(Vector(0,0,0))
			if IsValid(self.Barraged) then
				self.Barraged:SetVelocity(Vector(0,0,0))
			end
			if not IsValid(self.Barraged) then
				self:EmitVoice("deltarune/flowery/snd_flowery_voiceclip_all_according_to_all_according_to_plant.wav")
				self.Barrging = false
				self.AnimState = true
				self.loco:SetGravity(600)
				self:SetVelocity(Vector(0,0,0))
				self.AnimState = false
				self:RemoveFlags(FL_NOTARGET)
			end
		end
		if self.JaronaFly and not self:IsOnGround() and not self.PrismCombo then
			self:SetVelocity(self:GetAimVector()*1500)
			self:FaceInstant(self:GetPos()+self:GetAimVector()*1500)
		end
		if self.Barrging and IsValid(self.Barraged) and self:GetCooldown("NextBHit")<=0 then
			self.BHits = self.BHits + 0.025
			local hits = 0.35-self.BHits
			local tim = hits>=0.05 and hits or 0.05
			self:SetCooldown("NextBHit",tim)
			if self.PrismCombo then
				self:AfterImage(true)
			else
				self:AfterImage(_,true)
			end
			local clips = {"snd_flowery_voiceclip_hah","snd_flowery_voiceclip_hoo","snd_flowery_voiceclip_huh"}
			self:EmitVoice("deltarune/flowery/"..clips[math.random(#clips)]..".wav")
			self:EmitSound("deltarune/snd_heavyswing.wav")
			local p1 = self.Barraged:GetPos()
			local p2 = self.Barraged:OBBMaxs()*2
			self:SetPos(p1+Vector(math.random(-p2.x,p2.x),math.random(-p2.y,p2.y),math.random(-(p2.z/4),p2.z/3)))
			self:FaceInstant(self.Barraged)
			self.AnimState = true
			local anims = {"kick","fair","puunch"}
			self.AnimStateAnim = anims[math.random(#anims)]
			self:EmitSound("deltarune/snd_punchheavythunder.wav")
			if self.Barraged:Health() <= 30 then
				if self.Barraged:Health()>1 then
					self.Barraged:TakeDamage(1,self,self)
				end
			else
				self.Barraged:TakeDamage(30,self,self)
			end
			if self.BHits >= 0.5 then
				self:SetNW2Entity("Barraged",nil)
				self.Barraged:TakeDamage(30,self,self)
				self.Barrging = false
				if self.PrismCombo and self.Barraged:Health()>0 then
					self.AnimState = false
					self:SetPos(self.Barraged:GetPos()+self.Barraged:GetForward()*(100+(self.Barraged:OBBMaxs().x/1.5)))
					self:SetAngles(self.Barraged:GetAngles())
					self:JaronaAttack(self.Barraged)
					self.FreezeFrame = true
					self.FreezeFramePartner = self.Barraged
				return end
				if self.Barraged:Health()<=0 then
					local clips = {"snd_flowery_voiceclip_thatsgreat","snd_flowery_voiceclip_dont_you_like_serving_humans","snd_flowery_voiceclip_flowers_blooms_in_your_heart","snd_flowery_voiceclip_forget_it","snd_flowery_voiceclip_get_a_chance_1","snd_flowery_voiceclip_get_a_chance_2","snd_flowery_voiceclip_go_home","snd_flowery_voiceclip_heh_it_s_my_jarona","snd_flowery_voiceclip_huhillshowyou","snd_flowery_voiceclip_nonono","snd_flowery_voiceclip_sorryaboutthatlittleguy","snd_flowery_voiceclip_suckle_it_up","snd_flowery_voiceclip_what_a_predictable_creature"}
					self:EmitVoice("deltarune/flowery/"..clips[math.random(#clips)]..".wav")
				else
					self:EmitVoice("deltarune/flowery/snd_flowery_voiceclip_heh_it_s_my_jarona.wav")
				end
				self.AnimState = true
				self.AnimStateAnim = "pose"
				self:SetPos(self.Barraged:GetPos()+self.Barraged:GetForward()*(100+(self.Barraged:OBBMaxs().x/1.5)))
				self:SetAngles(self.Barraged:GetAngles())
				self:SetAngles(self:GetAngles()+Angle(0,90,0))
				self:Timer(1,function()
					self.IFRAME = false
					self.loco:SetGravity(600)
					self:SetVelocity(Vector(0,0,0))
					self:SetAngles(self:GetAngles()+Angle(0,-90,0))
					self.AnimState = false
					self:RemoveFlags(FL_NOTARGET)
					self.Barraged:SetGravity(600)
					if self.Barraged.IsDrGNextbot then
						self.Barraged:EnableAI()
					end
				end)
			end
		end
	end
	function ENT:AfterImage(rainbow,blue)
		if self:GetCooldown("Aura")>0 or self:GetSequence()<=0 then return end
		self:SetCooldown("Aura",0.1)
		local aura = ents.Create("base_anim")
		  aura:SetModel(string.Replace(self:GetModel(),".mdl","_image.mdl"))
		  aura:SetPos(self:GetPos())
		  aura:SetAngles(self:GetAngles())
		  aura:SetModelScale(self:GetModelScale())
		  aura:SetSequence(self:GetSequence())
		  aura:SetCycle(self:GetCycle())
		  aura:SetRenderMode(RENDERMODE_TRANSCOLOR)
		  if self:IsRunning() then
			aura:SetPlaybackRate(1)
		  else
		    aura:SetPlaybackRate(0)
		  end
		  if !self.ImageColorLoop then
			self.ImageColorLoop = 0
		  end
		  if rainbow then
			aura:SetMaterial("deltaflowery/white")
			local col = self.ImageColorLoop
			if col==0 then
			  aura:SetColor(Color(255,0,0))
			elseif col==1 then
			  aura:SetColor(Color(255,122,0))
			elseif col==2 then
			  aura:SetColor(Color(255,255,0))
			elseif col==3 then
			  aura:SetColor(Color(122,255,0))
			elseif col==4 then
			  aura:SetColor(Color(0,255,0))
			elseif col==5 then
			  aura:SetColor(Color(0,255,122))
			elseif col==6 then
			  aura:SetColor(Color(0,255,255))
			elseif col==7 then
			  aura:SetColor(Color(0,122,255))
			elseif col==8 then
			  aura:SetColor(Color(0,0,255))
			elseif col==9 then
			  aura:SetColor(Color(122,0,255))
			elseif col==10 then
			  aura:SetColor(Color(255,0,255))
			elseif col>=11 then
			  aura:SetColor(Color(255,0,122))
			  self.ImageColorLoop = -1
			end
			self.ImageColorLoop = self.ImageColorLoop + 1
			elseif blue then
				aura:SetMaterial("deltaflowery/white")
				aura:SetColor(Color(0,100,255))
		  end
		   	for i=1,aura:GetBoneCount() do
				aura:ManipulateBoneScale(i,Vector(0.95,0.95,0.95))
			end
		  	for i =1,60 do
				timer.Simple(0.1*i,function()
					if IsValid(aura) then
						aura:SetColor(Color(aura:GetColor().r,aura:GetColor().g,aura:GetColor().b,aura:GetColor().a-25))
					end
				end)
			end
		  SafeRemoveEntityDelayed(aura,1)
	end

	-- Damage --

	function ENT:BecomeRagdollSBXZ(dmg)
		if IsValid(dmg) then
			local force = dmg:GetDamageForce()
			local position = dmg:GetDamagePosition()
			self:SetNW2Vector("deadforce",force)
			if dmg:IsDamageType(DMG_BUCKSHOT) then
				self:SetNW2Vector("deadforce",force*4)
			elseif dmg:IsDamageType(DMG_BLAST) then
				self:SetNW2Vector("deadforce",force*2)
			end
			self:SetNW2Vector("deadpos",position)
		end
		SafeRemoveEntity(self.FSprite)
		SafeRemoveEntity(self.FProj)
		self:SetVelocity(self:GetVelocity())
		self:Fire("Becomeragdoll")
	end
	function ENT:SBXZ_CreateRagdoll(dmg)
	  if not util.IsValidRagdoll(self:GetModel()) then return NULL end
	  local ragdoll = ents.Create("prop_ragdoll")
	  if IsValid(ragdoll) then
		if not dmg then dmg = DamageInfo() end
		ragdoll:SetPos(self:GetPos())
		ragdoll:SetAngles(self:GetAngles())
		ragdoll:SetModel(self:GetModel())
		ragdoll:SetSkin(self:GetSkin())
		ragdoll:SetColor(self:GetColor())
		ragdoll:SetModelScale(self:GetModelScale())
		ragdoll:SetBloodColor(self:GetBloodColor())
		for i = 1, #self:GetBodyGroups() do
		  ragdoll:SetBodygroup(i-1, self:GetBodygroup(i-1))
		end
		ragdoll:Spawn()
		for i = 0, (ragdoll:GetPhysicsObjectCount()-1) do
		  local bone = ragdoll:GetPhysicsObjectNum(i)
		  if not IsValid(bone) then continue end
		  local pos, angles = self:GetBonePosition(ragdoll:TranslatePhysBoneToBone(i))
		  bone:SetPos(pos)
		  bone:SetAngles(angles)
		end
		local phys = ragdoll:GetPhysicsObject()
		phys:SetVelocity(self:GetVelocity())
		local force = dmg:GetDamageForce()
		local position = dmg:GetDamagePosition()
		if IsValid(phys) and isvector(force) and isvector(position) then
		  phys:ApplyForceOffset(force, position)
		end
		if dmg:IsDamageType(DMG_DISSOLVE) then ragdoll:DrG_Dissolve()
		elseif self:IsOnFire() then ragdoll:Ignite(10) end
		local attacker = dmg:GetAttacker()
		if IsValid(attacker) and attacker.IsDrGNextbot then
		  attacker:SpotEntity(ragdoll)
		end
		ragdoll.EntityClass = self:GetClass()
		return ragdoll
	  else return NULL end
	end
	local function NextbotDeathSBXZ(self, dmg)
	  if not IsValid(self) then return end
	  if self:HasWeapon() and self.DropWeaponOnDeath then
		self:DropWeapon()
	  end
	  if self.RagdollOnDeathSBXZ then
		return self:BecomeRagdollSBXZ(dmg)
	  else self:Remove() end
	end
	function ENT:OnKilled(dmg)
	  if self:IsDead() then return end
	  local hitgroup = self._DrGBaseHitGroupToHandle and self:LastHitGroup() or HITGROUP_GENERIC
	  self._DrGBaseHitGroupToHandle = false
	  self:SetHealth(0)
	  self:SetNW2Bool("DrGBaseDying", true)
	  self:DrG_DeathNotice(dmg:GetAttacker(), dmg:GetInflictor())
	  if #self.OnDeathSounds > 0 then
		self:EmitSound(self.OnDeathSounds[mathn(#self.OnDeathSounds)])
	  end
	  if dmg:IsDamageType(DMG_DISSOLVE) then self:DrG_Dissolve() end
	  if isfunction(self.OnDeath) then
		local data = util.DrG_SaveDmg(dmg)
		self.BehaveThread = coroutine.create(function()
		  self:SetNW2Bool("DrGBaseDying", false)
		  self:SetNW2Bool("DrGBaseDead", true)
		  if GetConVar("drgbase_remove_dead"):GetBool() and GetConVar("drgbase_remove_ragdolls"):GetFloat() >= 0 then
			self:Timer(GetConVar("drgbase_remove_ragdolls"):GetFloat(), self.Remove)
		  end
		  local now = CurTime()
		  dmg = self:OnDeath(util.DrG_LoadDmg(data), hitgroup)
		  if dmg == nil then
			dmg = util.DrG_LoadDmg(data)
			if CurTime() > now then
			  dmg:SetDamageForce(Vector(0, 0, 1))
			end
		  end
		  NextbotDeathSBXZ(self, dmg)
		end)
	  else
		self:SetNW2Bool("DrGBaseDying", false)
		self:SetNW2Bool("DrGBaseDead", true)
		NextbotDeathSBXZ(self, dmg)
	  end
	end
	function ENT:ZombieDamaged(dmg, hitgroup, attacker)
	end
	function ENT:OnTakeDamage(dmg, hitgroup)
		if self.IFRAME then dmg:SetDamage(0) return end
		if self.Jarona then
			dmg:SetDamage(0)
			self.Jarona = false
			self.JaronaFly = false
			self:SetColor(Color(255,255,255))
			self:AfterImage(_,true)
			local ent = dmg:GetDamagePosition()
			self:EmitSound("deltarune/snd_parry_fast_nodelay.wav")
				self.AnimStateAnim = "deflected"
				self:Timer(0.5,function()
					self.AnimState = false
					self:SetCollisionGroup(COLLISION_GROUP_NONE)
				end)
				self.loco:SetGravity(0)
				self:SetCollisionGroup(COLLISION_GROUP_IN_VEHICLE)
			local push = ents.Create("prop_dynamic")
			push:SetModel("models/Gibs/HGIBS.mdl")
			push:Spawn()
			push:SetPos(ent)
			local angle = (ent - self:WorldSpaceCenter()):Angle()
			push:SetAngles(Angle(0, angle.y, angle.z))
			push:SetNoDraw(true)
			push:SetNotSolid(true)
			push:SetOwner(self)
			self:Timer(0.1,function()
				self:LeaveGround()
				self:SetVelocity(self:GetUp()*250+push:GetForward()*-500)
				SafeRemoveEntity(push)
				self.loco:SetGravity(600)
			end)
		else
			if self.DreamMeter > 0 then
				dmg:ScaleDamage(0.25)
				self.DreamMeter = self.DreamMeter - 5
				if self.DreamMeter < 0 then
					self.DreamMeter = 0
				end
			end
			if not self.Omega and not self.AnimState then
				self.AnimState = true
				self:EmitSound("deltarune/snd_damage.wav",511)
				self.AnimStateAnim = "hurt"
				self:Timer(0.5,function()
					self.AnimState = false
				end)
			end
		end
	end
	function ENT:DeathAnim()
		if self:IsDead() then
			self:Timer(0.5,function()
				self:EmitVoice("deltarune/flowery/snd_flowery_voiceclip_goodbye.wav")
			end)
			self:Timer(1.5,function()
				self:EmitSound("deltarune/snd_sparkle_glock.wav",100)
				self:SetNW2Bool("Flower",true)
				self:DrawShadow(false)
				self:SetRenderMode(RENDERMODE_TRANSCOLOR)
				self:SetColor(Color(0,0,0,1))
				self:SetMaterial("Models/effects/vol_light001")
			end)
			self:ResetSequence("kneel")
		else
			self.DreamMeter = 0
			self.AnimState = true
			self.AnimStateAnim = "kneel"
			self:Timer(1,function()
				self.IFRAME = true
				for _,ply in pairs(player.GetAll()) do
					ply:ScreenFade( SCREENFADE.OUT, Color( 255, 255, 255, 255 ), 0.5, 0.1 )
				end
			end)
			self:Timer(1.5,function()
				self:EmitSound("deltarune/snd_sparkle_glock.wav",100)
				self:NewModelBBFix("models/nextbot/deltarune_lp/flowery_lp.mdl")
				self:SetBodygroup(1,0)
				for _,ply in pairs(player.GetAll()) do
					ply:ScreenFade( SCREENFADE.IN, Color( 255, 255, 255, 255 ), 0.5, 0 )
				end
			end)
			self:Timer(2,function()
				self:EmitVoice("deltarune/flowery/snd_flowery_voiceclip_sorryaboutthatguys.wav")
				self.AnimStateAnim = "condescend"
				self.IFRAME = false
			end)
			self:Timer(3,function()
				self.AnimState = false
			end)
		end
	end
	function ENT:OnDeath(dmg, hitgroup)
		self.DreamMeter = 0
		self.Jarona = false
		self.JaronaFly = false
		self.Barrage = false
		self:SetColor(Color(255,255,255))
		self:SetCollisionGroup(COLLISION_GROUP_IN_VEHICLE)
		self:EmitSound("deltarune/snd_damage.wav",511)
		if self:IsOnGround() then
			self:DeathAnim()
		else
			self.DeathFall = true
			self.loco:SetGravity(200)
			self:SetVelocity(Vector(0,0,5))
			self:EmitSound("deltarune/snd_fall.wav",100)
			self:EmitVoice("deltarune/flowery/snd_flowery_voiceclip_im_falling.wav")
			self:ResetSequence("hurt")
		end
		self:PauseCoroutine(true)
	end
elseif CLIENT then
	
function ENT:CustomDraw()
	if self:GetNW2Bool("Flower") then 
		local mat = Material("deltaflowery/flower")
		render.SetMaterial(mat)
		local normal = self:GetPos():DrG_Direction(EyePos())
		normal.z = 0
		render.DrawQuadEasy(self:GetPos()+self:GetUp()*10, normal, 30, 30, Color(255,255,255), 0 + 180)
	else
		self:DrawModel()
	end
end
surface.CreateFont( "BIGSHOT", {
	font = "BIG SHOT",
	extended = false,
	size = 37,
	weight = 1,
	blursize = 0,
	scanlines = 0,
	antialias = false,
	underline = false,
	italic = false,
	strikeout = false,
	symbol = false,
	rotary = false,
	shadow = true,
	additive = false,
	outline = false,
} )
DELTARUNE_Text = "Hey guys, I think\nI sharted."
DELTARUNE_TextBox = true
DELTARUNE_TextBoxFace = "deltaflowery/face1"
DELTARUNE_TextBoxColor = 1
DELTARUNE_TextBoxColorD = 0
DELTARUNE_TextBoxSpeak = 0
DELTARUNE_TextBoxSpeakD = 0
DELTARUNE_TextBoxSpeakVoice = 0
DELTARUNE_TextBoxDialouge = ""
DELTARUNE_TextBoxDialougeVoiceClip = nil -- deltarune/flowery/snd_flowery_voiceclip_no_way_its_your_children_ja.wav
DELTARUNE_TextBoxDissapearD = 0
DELTARUNE_TextBoxDissapear = false
hook.Add("HUDPaint", "DeltaruneText", function()
	if DELTARUNE_TextBox then
		if head == nil then
			local headface = DELTARUNE_TextBoxFace
			head = Material(headface, "smooth unlitgeneric")
		end

		if DELTARUNE_TextBoxColorD <= CurTime() then
			DELTARUNE_TextBoxColorD = CurTime()+1
			DELTARUNE_TextBoxColor = DELTARUNE_TextBoxColor+1
			if DELTARUNE_TextBoxColor>5 then
				DELTARUNE_TextBoxColor = 1
			end
		end

		local box1 = Material("deltaflowery/box"..DELTARUNE_TextBoxColor, "smooth unlitgeneric")
		surface.SetDrawColor(255,255,255,255)
		surface.SetMaterial(box1)
		surface.DrawTexturedRectRotatedPoint(
			ScrW()/2, ScrH()/1.2,
			593*1.5,
			167*1.5,
			0,
			0,
			0
		)
		surface.SetDrawColor(255,255,255,255)
		surface.SetMaterial(head)
		surface.DrawTexturedRectRotatedPoint(
			(ScrW()/2)-330, (ScrH()/1.2)-5,
			head:Width()*3,
			head:Height()*3,
			0,
			0,
			0
		)
		local text = DELTARUNE_Text
		draw.DrawText( "*", "BIGSHOT", (ScrW()/2)-230, (ScrH()/1.32), color_white, TEXT_ALIGN_LEFT )
		if DELTARUNE_TextBoxSpeakD <= CurTime() and DELTARUNE_TextBoxDialouge != text then
			DELTARUNE_TextBoxSpeak = DELTARUNE_TextBoxSpeak+1
			local pause =string.sub( text, DELTARUNE_TextBoxSpeak, DELTARUNE_TextBoxSpeak )
			local breaks = {
				[","] = true,
				["!"] = true,
				["."] = true,
				["?"] = true,
			}
			DELTARUNE_TextBoxSpeakD = CurTime()+0.05
			if breaks[pause]==true then
				DELTARUNE_TextBoxSpeakD = CurTime()+0.5
			end
			DELTARUNE_TextBoxDialouge = string.sub( text, 1, DELTARUNE_TextBoxSpeak )
			if string.len(pause)<25 then
				if pause==" " then
					text = string.Replace(text, DELTARUNE_TextBoxDialouge, DELTARUNE_TextBoxDialouge.."\n")
				end
			end
			if DELTARUNE_TextBoxDialougeVoiceClip and DELTARUNE_TextBoxSpeak==1 then
				sound.PlayFile("sound/"..DELTARUNE_TextBoxDialougeVoiceClip,"",function(source, err, errname)
					if IsValid(source) then
						source:Play()
					end
				end)
			end
			if DELTARUNE_TextBoxSpeakVoice <= CurTime() and not DELTARUNE_TextBoxDialougeVoiceClip then
				DELTARUNE_TextBoxSpeakVoice = CurTime()+0.1
				sound.PlayFile("sound/deltarune/flowery/snd_flowery_voicenoise_"..math.random(3)..".wav","",function(source, err, errname)
					if IsValid(source) then
						source:Play()
					end
				end)
			end
			if DELTARUNE_TextBoxDialouge == text then
				DELTARUNE_TextBoxDissapearD = CurTime()+3
				DELTARUNE_TextBoxDissapear = true
			end
		end
		if DELTARUNE_TextBoxDissapear and DELTARUNE_TextBoxDissapearD <=CurTime() then
			DELTARUNE_TextBoxDissapearD = 0
			DELTARUNE_TextBoxDissapear = false
			DELTARUNE_TextBox = false
			DELTARUNE_TextBoxDialougeVoiceClip = nil
			DELTARUNE_TextBoxDialouge = ""
			DELTARUNE_TextBoxColor = 1
			DELTARUNE_TextBoxColorD = 0
			DELTARUNE_TextBoxSpeak = 0
			DELTARUNE_TextBoxSpeakD = 0
			DELTARUNE_TextBoxSpeakVoice = 0
			head = nil
		end
		draw.DrawText( DELTARUNE_TextBoxDialouge, "BIGSHOT", (ScrW()/2)-186, (ScrH()/1.32), color_white, TEXT_ALIGN_LEFT )
	end
end)
hook.Add( "OnPlayerChat", "flowery", function( ply, text )
	print("foop")
	if string.sub(text,1,9) == "!flowery " then
		DELTARUNE_Text = string.Replace(text,"!flowery ","")
		DELTARUNE_TextBox = true
		return true
	end
end )
CreateConVar("deltarune_flowery_text", "pvzgw2/music/coopgraveyardops/combat_generic_high/combat_generic_high_A/GraveyardOps_Combat_A_High_intro.wav", {FCVAR_USERINFO, FCVAR_ARCHIVE}, "Enable Music")
local function DeltaFloweryMenu()
	local frame = vgui.Create( "DFrame" )
	frame:SetSize( 500, 500 )
	frame:Center()
	frame:MakePopup()
	
	local DScrollPanel = vgui.Create( "DScrollPanel", frame )
	DScrollPanel:Dock( FILL )
	DScrollPanel:SetPaintBackground(true)
	DScrollPanel:SetBackgroundColor(Color(0,0,0,255))
	DScrollPanel.Text = "test"
	for i=1,35 do
		local DButton = DScrollPanel:Add( "DImageButton" )
		local n1 = (-103)
		local n2 = (80)
		DButton:SetPos( n1+n2*i, 50 )	
		if i>30 then
			DButton:SetPos( (n1+n2*(i-30)), 550 )	
		elseif i>24 then
			DButton:SetPos( (n1+n2*(i-24)), 450 )	
		elseif i>18 then
			DButton:SetPos( (n1+n2*(i-18)), 350 )	
		elseif i>12 then
			DButton:SetPos( (n1+n2*(i-12)), 250 )	
		elseif i>6 then
			DButton:SetPos( (n1+n2*(i-6)), 150 )	
		end
		DButton:SetImage( "deltaflowery/face"..i )
		DButton.Icon = "deltaflowery/face"..i
		DButton:Dock( NODOCK )
		DButton:SetKeepAspect(true)
		DButton:SizeToContents()	
		DButton:SetSize(120,120)	
		DButton.DoClick = function()				-- A custom function run when clicked ( note the . instead of : )
			DELTARUNE_TextBoxFace = DButton:GetImage()
		end
	end
	local DTextEntry = DScrollPanel:Add( "DTextEntry" )
	DTextEntry:Dock( TOP )
	DTextEntry:SetUpdateOnType( true )
	function DTextEntry:OnValueChange( value )
		print(value)
		DScrollPanel.Text = value
	end
	
	local DButton = DScrollPanel:Add( "DButton" )
	DButton:SetText( "Send Text" )
	DButton:Dock( TOP )
	DButton:DockMargin( 0, 0, 0, 5 )
	DButton.DoClick = function()				-- A custom function run when clicked ( note the . instead of : )
		print("what")
		DELTARUNE_TextBoxDissapearD = 0
		DELTARUNE_TextBoxDissapear = false
		DELTARUNE_TextBox = false
		DELTARUNE_TextBoxDialougeVoiceClip = nil
		DELTARUNE_TextBoxDialouge = ""
		DELTARUNE_TextBoxColor = 1
		DELTARUNE_TextBoxColorD = 0
		DELTARUNE_TextBoxSpeak = 0
		DELTARUNE_TextBoxSpeakD = 0
		DELTARUNE_TextBoxSpeakVoice = 0
		DELTARUNE_Text = DScrollPanel.Text
		DELTARUNE_TextBox = true
		head = nil
	end
end
concommand.Add( "deltarune_flowery_menu", function( ply, cmd, args )
    DeltaFloweryMenu()
end )
function ENT:PossessionHUD()
	local dream = self:GetDreamMeter()
	surface.SetDrawColor(255,230,25,255)
	surface.DrawRect(ScrW()*0.75-5, ScrH()*0.76-5, ScrW()*0.15+10, ScrH()*0.07+10)
	surface.SetDrawColor(0,0,0,255)
	surface.DrawRect(ScrW()*0.75, ScrH()*0.76, ScrW()*0.15, ScrH()*0.07)
	if dream >= 100 then
		if !self.ImageColorChange then
			self.ImageColorChange = 0
		end
		if self.ImageColorChange<=CurTime() then
			self.ImageColorChange = CurTime()+0.1
			if !self.ImageColorLoop then
				self.ImageColorLoop = 7
				self.LastImageColor = Vector(0,100,255)
			end
			local col = self.ImageColorLoop
			if col==0 then
			  color =Vector(255,0,0)
			elseif col==1 then
			  color =Vector(255,122,0)
			elseif col==2 then
			  color =Vector(255,255,0)
			elseif col==3 then
			  color =Vector(122,255,0)
			elseif col==4 then
			  color =Vector(0,255,0)
			elseif col==5 then
			  color =Vector(0,255,122)
			elseif col==6 then
			  color =Vector(0,255,255)
			elseif col==7 then
			  color =Vector(0,122,255)
			elseif col==8 then
			  color =Vector(0,0,255)
			elseif col==9 then
			  color =Vector(122,0,255)
			elseif col==10 then
			  color =Vector(255,0,255)
			elseif col>=11 then
			  color =Vector(255,0,122)
			  self.ImageColorLoop = -1
			end
			self.ImageColorLoop = self.ImageColorLoop + 1
		end
		local output = LerpVector( 0.5, self.LastImageColor, color )
		self.LastImageColor = color
		surface.SetDrawColor(output.x,output.y,output.z,255)
	else
		self.ImageColorLoop = nil
		surface.SetDrawColor(0,100,255,255)
	end
	surface.DrawRect(ScrW()*0.75, ScrH()*0.76, (ScrW()*0.15)*dream/100, ScrH()*0.07)
	draw.DrawText("Dream", "BIGSHOT", ScrW()*0.825, ScrH()*0.72, Color(255,230,25,255), TEXT_ALIGN_CENTER )
	draw.DrawText(dream.."%", "BIGSHOT", ScrW()*0.825, ScrH()*0.777, Color(255,230,25,255), TEXT_ALIGN_CENTER )
	local hp = self:Health()
	local hpmax = self:GetMaxHealth()
	surface.SetDrawColor(255,255,255,255)
	surface.DrawRect(ScrW()*0.1-5, ScrH()*0.76-5, ScrW()*0.15+10, ScrH()*0.07+10)
	surface.SetDrawColor(122,0,0,255)
	surface.DrawRect(ScrW()*0.1, ScrH()*0.76, ScrW()*0.15, ScrH()*0.07)
	surface.SetDrawColor(255,230,25,255)
	surface.DrawRect(ScrW()*0.1, ScrH()*0.76, (ScrW()*0.15)*hp/hpmax, ScrH()*0.07)
	draw.DrawText("HP", "BIGSHOT", ScrW()*0.175, ScrH()*0.72, Color(255,255,255,255), TEXT_ALIGN_CENTER )
	draw.DrawText(hp, "BIGSHOT", ScrW()*0.175, ScrH()*0.777, Color(255,255,255,255), TEXT_ALIGN_CENTER )
end
end
function ENT:SetupDataTables()
	self:NetworkVar("Float", 1, "DreamMeter")
end

-- DO NOT TOUCH --
AddCSLuaFile()
DrGBase.AddNextbot(ENT)
