--------------------------------------------------------------------------------
ufoMoveFireAttack = {}

function ufoMoveFireAttack.enter()
  if not hasTarget() then return nil end

  rangedAttack.setConfig(entity.configParameter("ufoMoveFireAttack.projectile.type"), entity.configParameter("ufoMoveFireAttack.projectile.config"), entity.configParameter("ufoMoveFireAttack.fireInterval"))

  return {
    timer = 0,
    bobTime = entity.configParameter("ufoMoveFireAttack.bobTime"),
    bobHeight = entity.configParameter("ufoMoveFireAttack.bobHeight"),
    skillTime = entity.configParameter("ufoMoveFireAttack.skillTime"),
    direction = util.randomDirection(),
    basePosition = self.spawnPosition,
    cruiseDistance = entity.configParameter("cruiseDistance")
  }
end

function ufoMoveFireAttack.enteringState(stateData)
  entity.setActiveSkillName(nil)
end

function ufoMoveFireAttack.update(dt, stateData)
  if not hasTarget() then return true end

  local projectileOffset = entity.configParameter("ufoMoveFireAttack.projectileOffset")

  local toTarget = vec2.norm(world.distance(self.targetPosition, entity.toAbsolutePosition(projectileOffset)))
  rangedAttack.aim(projectileOffset, toTarget)
  rangedAttack.fireContinuous()

  local position = mcontroller.position()

  local toTarget = world.distance(self.targetPosition, position)
  if toTarget[1] < -stateData.cruiseDistance or checkWalls(1) then
    stateData.direction = -1
  elseif toTarget[1] > stateData.cruiseDistance or checkWalls(-1) then
    stateData.direction = 1
  end

  stateData.timer = stateData.timer + dt
  local angle = 2.0 * math.pi * stateData.timer / stateData.bobTime
  local targetPosition = {
    position[1] + stateData.direction * 5,
    stateData.basePosition[2] + stateData.bobHeight * math.cos(angle)
  }
  flyTo(targetPosition)

  if stateData.timer > stateData.skillTime then
    return true
  else
    return false
  end
end

function ufoMoveFireAttack.leavingState(stateData)
end