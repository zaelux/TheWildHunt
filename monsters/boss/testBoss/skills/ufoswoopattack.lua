ufoSwoopAttack = {}

function ufoSwoopAttack.enter()
  if not hasTarget() then return nil end
  if self.targetPosition == nil then return nil end

  return {
    timer = 0.0,
    swoopTime = entity.configParameter("ufoSwoopAttack.swoopTime"),
    tookDamage = false
  }
end

function ufoSwoopAttack.enteringState(stateData)
  entity.setActiveSkillName("ufoSwoopAttack")
end

function ufoSwoopAttack.update(dt, stateData)
  if not hasTarget() then return true end

  local position = mcontroller.position()
  if stateData.basePosition == nil then
    stateData.basePosition = { self.targetPosition[1], position[2] }
    stateData.toTarget = world.distance(vec2.add(self.targetPosition, {0, 4.0}), position)

    entity.setDamageOnTouch(true)
  end

  stateData.timer = stateData.timer + dt

  local timerRatio = stateData.timer / stateData.swoopTime
  local angle = timerRatio * math.pi
  local targetPosition = {
    stateData.basePosition[1] - math.cos(angle) * stateData.toTarget[1],
    stateData.basePosition[2] + math.sin(angle) * stateData.toTarget[2]
  }
  local toTarget = world.distance(targetPosition, mcontroller.position())
  mcontroller.setVelocity(vec2.mul(toTarget, 1 / dt))

  if stateData.timer > stateData.swoopTime or checkWalls(util.toDirection(toTarget[1])) then
    return true
  else
    return false
  end
end


function ufoSwoopAttack.leavingState(stateData)
  entity.setDamageOnTouch(false)
end