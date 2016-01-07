ufoTeleportAttack = {}

function ufoTeleportAttack.enter()
  if self.targetPosition == nil then return nil end

  ufoTeleportAttack.reappeared = false
  entity.burstParticleEmitter("teleport")
  return { 
    timer = entity.configParameter("ufoTeleportAttack.skillTime")
  }
end

function ufoTeleportAttack.enteringState(stateData)
  entity.setActiveSkillName("ufoTeleportAttack")
end

function ufoTeleportAttack.update(dt, stateData)
  if stateData.timer > entity.configParameter("ufoTeleportAttack.skillTime") - 0.55 then
    mcontroller.controlFly({ 0, 0 })
  elseif stateData.timer > 0 then
    if entity.animationState("movement") ~= "invisible" then
      entity.setAnimationState("movement", "invisible")
    end

    if self.targetPosition ~= nil then
      flyTo({
        self.targetPosition[1],
        self.spawnPosition[2]
      })
    else
      mcontroller.controlFly({ 0, 1 })
    end

    if stateData.timer < 0.3 and not ufoTeleportAttack.reappeared then
      ufoTeleportAttack.reappeared = true
      entity.burstParticleEmitter("teleport")
    end
  else
    return true
  end

  stateData.timer = stateData.timer - dt
  return false
end

function ufoTeleportAttack.leavingState(stateData)
  mcontroller.setVelocity({ 0, 0 })
  mcontroller.controlFly({ 0, 0 })
  entity.setAnimationState("movement", "phase"..currentPhase())
end
