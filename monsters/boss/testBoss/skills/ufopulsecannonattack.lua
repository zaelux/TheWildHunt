--------------------------------------------------------------------------------
ufoPulseCannonAttack = {}

function ufoPulseCannonAttack.enter()
  if not hasTarget() then return nil end

  rangedAttack.setConfig(entity.configParameter("ufoPulseCannonAttack.projectile.type"), entity.configParameter("ufoPulseCannonAttack.projectile.config"), 0.2)

  local toTarget = world.distance(self.targetPosition, mcontroller.position())
  return {
    basePosition = self.spawnPosition,
    direction = util.randomDirection(),
    cruiseDistance = entity.configParameter("cruiseDistance"),
    firing = false
  }
end

function ufoPulseCannonAttack.enteringState(stateData)
  entity.setActiveSkillName("ufoPulseCannonAttack")
end

function ufoPulseCannonAttack.update(dt, stateData)
  if not hasTarget() then return true end
  local position = mcontroller.position()

  if not stateData.firing then
    local targetPosition = {
      self.targetPosition[1] + stateData.direction * stateData.cruiseDistance,
      stateData.basePosition[2]
    }
    flyTo(targetPosition)

    local targetDistance = world.magnitude(targetPosition, mcontroller.position())
    if targetDistance < 2 or checkWalls(stateData.direction) then
      stateData.firing = true
    end
  else
    rangedAttack.fireContinuous(true)
    local targetPosition = {
      self.targetPosition[1] - stateData.direction * stateData.cruiseDistance,
      stateData.basePosition[2]
    }
    flyTo(targetPosition)

    local targetDistance = world.magnitude(targetPosition, mcontroller.position())
    if targetDistance < 2 or checkWalls(-stateData.direction) then
      return true
    end
  end

  return false
end

function ufoPulseCannonAttack.leavingState(stateData)
  rangedAttack.stopFiring()
end