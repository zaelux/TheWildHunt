--------------------------------------------------------------------------------
ufoSlamAttack = {}

function ufoSlamAttack.enter()
  if self.targetPosition == nil then return nil end

  return {
    slamHeight = entity.configParameter("ufoSlamAttack.slamHeight"),
    riseSpeed = entity.configParameter("ufoSlamAttack.riseSpeed"),
    slamSpeed = entity.configParameter("ufoSlamAttack.slamSpeed"),
    timer = entity.configParameter("ufoSlamAttack.skillTime"),
    stunDuration = entity.configParameter("ufoSlamAttack.stunDuration"),
    prepareSlam = false,
    slam = false
  }
end

function ufoSlamAttack.enteringState(stateData)
  entity.setActiveSkillName("ufoSlamAttack")
end

function ufoSlamAttack.update(dt, stateData)
  local position = mcontroller.position()

  stateData.timer = stateData.timer - dt
  if stateData.timer <= 0 then
    return true
  end

  --Move to above target
  if not stateData.prepareSlam then
    local approachPosition = {
      self.targetPosition[1],
      self.spawnPosition[2]
    }
    local toApproach = world.distance(approachPosition, position)

    if math.abs(toApproach[1]) < 3 or checkWalls(util.toDirection(toApproach[1])) then
      stateData.prepareSlam = true
    else
      flyTo(approachPosition)
      return false
    end
  end

  --Move up a bit before slamming
  if stateData.prepareSlam then
    local approachPosition = {
      position[1],
      self.spawnPosition[2] + stateData.slamHeight
    }

    if checkWalls(1) then
      approachPosition[1] = approachPosition[1] - 2
    end
    if checkWalls(-1) then
      approachPosition[1] = approachPosition[1] + 2
    end

    local toApproach = world.distance(approachPosition, position)

    if math.abs(toApproach[2]) < 1 then
      stateData.slam = true
      entity.setParticleEmitterActive("falling", true)
    else
      flyTo(approachPosition, stateData.riseSpeed)
    end
  end

  --Slam and stay on ground for stun duration
  if stateData.slam then
    mcontroller.controlParameters({
      gravityEnabled = true  
    })
    if mcontroller.onGround() then -- and not entity.isFiring() then
      if not stateData.landed then
        entity.playSound("landing")
        entity.burstParticleEmitter("landing")
      end
      stateData.landed = true
      entity.setDamageOnTouch(false)
      entity.setParticleEmitterActive("falling", false)
      entity.setParticleEmitterActive("stunned", true)
      if stateData.timer > stateData.stunDuration then
        stateData.timer = stateData.stunDuration
      end
    else
      if not stateData.landed then
        entity.setDamageOnTouch(true)
      end
      mcontroller.controlApproachYVelocity(-entity.configParameter("ufoSlamAttack.slamSpeed"), 100)
    end
  end

  return false
end

function ufoSlamAttack.leavingState(stateData)
  entity.setDamageOnTouch(false)
  entity.setParticleEmitterActive("stunned", false)
end

function ufoSlamAttack.flyToTargetYOffsetRange(targetPosition)
  local position = mcontroller.position()
  local yOffsetRange = entity.configParameter("targetYOffsetRange")
  local destination = {
    targetPosition[1],
    util.clamp(position[2], targetPosition[2] + yOffsetRange[1], targetPosition[2] + yOffsetRange[2])
  }

  if math.abs(destination[2] - position[2]) < 1.0 then
    return true
  else
    flyTo(destination)
  end

  return false
end
