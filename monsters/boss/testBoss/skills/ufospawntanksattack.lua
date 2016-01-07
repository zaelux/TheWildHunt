--------------------------------------------------------------------------------
ufoSpawnTanksAttack = {}

--This is the state that handles phase transitions so it can handle
--phase animation states too
function ufoSpawnTanksAttack.onInit()
  entity.setAnimationState("movement", "phase1")
end

function ufoSpawnTanksAttack.enterWith(args)
  if not args or not args.enteringPhase or not hasTarget() then return nil end

  entity.setAnimationState("movement", "phase"..currentPhase())

  return {
    spawns = 0,
    startDirection = util.randomDirection(),
    spawnDistance = entity.configParameter("ufoSpawnTanksAttack.spawnDistance"),
    basePosition = self.spawnPosition,
  }
end

function ufoSpawnTanksAttack.enteringState(stateData)
  entity.setActiveSkillName("ufoSpawnTanksAttack")
end

function ufoSpawnTanksAttack.update(dt, stateData)
  if not hasTarget() then return true end

  if stateData.spawns > 1 then
    return true
  end

  local targetPosition = {stateData.basePosition[1], stateData.basePosition[2]}
  if stateData.spawns == 0 then
    targetPosition[1] = targetPosition[1] + stateData.spawnDistance * stateData.startDirection
  else
    targetPosition[1] = targetPosition[1] + stateData.spawnDistance * -stateData.startDirection
  end

  local targetDistance = world.magnitude(targetPosition, mcontroller.position())
  if targetDistance < 3 then
    rangedAttack.fireOnce(entity.configParameter("ufoSpawnTanksAttack.projectiles.tankspawn.type"), entity.configParameter("ufoSpawnTanksAttack.projectiles.tankspawn.config"), nil, true)
    stateData.spawns = stateData.spawns + 1
  end

  flyTo(targetPosition)

  return false
end

function ufoSpawnTanksAttack.findReinforcements()
  local selfId = entity.id()
  local position = mcontroller.position()
  local min = { position[1] - 50.0, position[2] - 50.0 }
  local max = { position[1] + 50.0, position[2] + 50.0 }

  return world.entityQuery(min, max, { callScript = "isPenguinReinforcement", includedTypes = {"monster"} })
end