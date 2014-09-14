local soundfile_base = "/SOUNDS/en/fm_"

local apm_status_message = {severity = 0, textnr = 0, timestamp=0}
local pilote_coord = {lat = 0, long = 0, yaw = 0, lock = 0}

local outputs = {"armd"}

local function init()
	-- Prepare a2 for hdop
	local a1t = model.getTelemetryChannel(1)
	if a1t.unit ~= 3 or a1t.range ~=1024 or a1t.offset ~=0 
	then
		a1t.unit = 3
		a1t.range = 1024
		a1t.offset = 0
		model.setTelemetryChannel(1, a1t)
	end
end

local function decodeApmWarning(severity)
	-- +10 is added to mavlink-value so 0 represents no warning
	if     severity == 0 then return ""
	elseif severity == 1 then return "Emergency"
	elseif severity == 2 then return "Alert"
	elseif severity == 3 then return "Critical"
	elseif severity == 4 then return "Error"
	elseif severity == 5 then return "Warning"
	elseif severity == 6 then return "Notice"
	elseif severity == 7 then return "Info"
	elseif severity == 8 then return "Debug"
	end
	return "Unknown"
end

local function decodeApmStatusText(textnr)
  if     textnr == 0  then 
        if getApmGpsLock() < 3 then return "PreArm: Bad GPS position"
        else return ""
        end
	elseif textnr == 1  then return "PreArm: RC not calibrated"
	elseif textnr == 2  then return "PreArm: RC not calibrated"
	elseif textnr == 3  then return "PreArm: Baro not healthy"
	elseif textnr == 4  then return "PreArm: Alt disparity"
	elseif textnr == 5  then return "PreArm: Compass not healthy"
	elseif textnr == 6  then return "PreArm: Compass not calibrated"
	elseif textnr == 7  then return "PreArm: Compass offsets too high"
	elseif textnr == 8  then return "PreArm: Check mag field"
	elseif textnr == 9  then return "PreArm: INS not calibrated"
	elseif textnr == 10 then return "PreArm: INS not healthy"
	elseif textnr == 11 then return "PreArm: Check Board Voltage"
	elseif textnr == 12 then return "PreArm: Ch7&8 Opt cannot be same"
	elseif textnr == 13 then return "PreArm: Check FS_THR_VALUE"
	elseif textnr == 14 then return "PreArm: Check ANGLE_MAX"
	elseif textnr == 15 then return "PreArm: ACRO_BAL_ROLL/PITCH"
	elseif textnr == 16 then return "PreArm: GPS Glitch"
	elseif textnr == 17 then return "PreArm: Need 3D Fix"
	elseif textnr == 18 then return "PreArm: Bad Velocity"
	elseif textnr == 19 then return "PreArm: High GPS HDOP"
	
	elseif textnr == 20 then return "Arm: Alt disparity"
	elseif textnr == 21 then return "Arm: Thr below FS"
	elseif textnr == 22 then return "Arm: Leaning"
	elseif textnr == 23 then return "Arm: Safety Switch"
	
	elseif textnr == 24 then return "AutoTune: Started"
	elseif textnr == 25 then return "AutoTune: Stopped"
	elseif textnr == 26 then return "AutoTune: Success"
	elseif textnr == 27 then return "AutoTune: Failed"

	elseif textnr == 28 then return "Crash: Disarming"
	elseif textnr == 29 then return "Parachute: Released!"
	elseif textnr == 30 then return "Parachute: Too Low"
	elseif textnr == 31 then return "EKF variance"
	elseif textnr == 32 then return "Low Battery!"
	elseif textnr == 33 then return "Lost GPS!"
	elseif textnr == 34 then return "Trim saved"
	end
	return ""
end

function getApmActiveStatus()
	if apm_status_message.timestamp == 0
	then 
		return nil
	end
	return {timestamp = apm_status_message.timestamp, message = getApmActiveWarnings(true)}
end

function getApmActiveStatusSeverity()
	if isApmActiveStatus() == false
	then 
		return ""
	end
	return decodeApmWarning(apm_status_message.severity)
end

function getApmActiveStatusText()
	if isApmActiveStatus() == false
	then 
		return ""
	end
	return decodeApmStatusText(apm_status_message.textnr)
end

function getApmActiveWarnings(includeUnknown)
	local severity = getApmActiveStatusSeverity()
	local text = getApmActiveStatusText()
	
	if includeUnknown == false or text ~= "" 
	then 
		return text
	end
	
	if severity == "" 
	then 
		return ""
	end
	
	return severity..apm_status_message.textnr;
end

function isApmActiveStatus()
	if apm_status_message.timestamp > 0
	then
		return true
	end
	return false
end

function getApmFlightmodeNumber()
	return getValue(208) -- Fuel
end

function getApmFlightmodeText()
  local mode = getApmFlightmodeNumber()
  if     mode == 0  then return "Stabilize"
  elseif mode == 1  then return "Acro"
  elseif mode == 2  then return "Alt Hold"
  elseif mode == 3  then return "Auto"
  elseif mode == 4  then return "Guided"
  elseif mode == 5  then return "Loiter"
  elseif mode == 6  then return "RTL"
  elseif mode == 7  then return "Circle"
  elseif mode == 9  then return "Land"
  elseif mode == 10 then return "Optical Loiter"
  elseif mode == 11 then return "Drift"
  elseif mode == 13 then return "Sport"
  elseif mode == 15 then return "Auto-tune"
  elseif mode == 16 then return "Pos Hold"
  end
  return "Unknown flightmode"
end

function getApmGpsHdop()
  return getValue(203)/10 -- A2
end 

function getApmGpsSats()
  local telem_t1 = getValue(209) -- Temp1
  return (telem_t1 - (telem_t1%10))/10
end

function getApmGpsLock()
  local telem_t1 = getValue(209) -- Temp1
  return  telem_t1%10
end

function getApmArmed()
	return getValue(210)%2 > 0 -- Temp2
end

function getApmHeading()
  return getValue("heading") - pilote_coord.yaw
end

function getApmLock()
  return pilote_coord.lock
end
function getApmLat()
  return pilote_coord.lat
end
function getApmLong()
  return pilote_coord.long
end
-- The heading to pilot home position - relative to apm position
function getApmHeadingHome()
  local pilotlat = pilote_coord.lat --getValue("pilot-latitude")
  local pilotlon = pilote_coord.long --getValue("pilot-longitude")
  local curlat = getValue("latitude")
  local curlon = getValue("longitude")

  if pilotlat~=0 and curlat~=0 and pilotlon~=0 and curlon~=0 
  then 
    local z1 = math.sin(math.rad(curlon) - math.rad(pilotlon)) * math.cos(math.rad(curlat))
    local z2 = math.cos(math.rad(pilotlat)) * math.sin(math.rad(curlat)) - math.sin(math.rad(pilotlat)) * math.cos(math.rad(curlat)) * math.cos(math.rad(curlon) - math.rad(pilotlon))

    local head_from = (math.deg(math.atan2(z1, z2)) + 360) % 360
    local head_to = head_from --(head_from + 180) % 360
    return head_to
  end
  return 0
end

-- The heading to pilot home position relative to the current heading.
function getApmHeadingHomeRelative()
  local tmp = getApmHeadingHome() - getValue("heading") -- Heading
  return (tmp + 360) % 360
end

function getApmDrawCompass(origin, point, long, angle)
  if     point == 0 then return origin + math.floor(long/2*math.sin(math.rad(angle)))
  elseif point == 1 then return origin + math.floor(long/2*math.cos(math.rad(angle)))
  elseif point == 2 then return origin - math.floor(long/2*math.sin(math.rad(angle)))
  elseif point == 3 then return origin - math.floor(long/2*math.cos(math.rad(angle)))
  end
  return 0
end

function getApmDrawHeading(origin, point)
  local angle = getApmHeadingHomeRelative()
  return getApmDrawCompass(origin, point, 20, angle)
end

function getCardinalDir(angle)
  if     angle >= 330 or  angle < 30  then return "N"
  elseif angle >= 30  and angle < 60  then return "NE"
  elseif angle >= 60  and angle < 120 then return "E"
  elseif angle >= 120 and angle < 150 then return "SE"
  elseif angle >= 150 and angle < 210 then return "S"
  elseif angle >= 210 and angle < 240 then return "SW"
  elseif angle >= 240 and angle < 300 then return "W"
  elseif angle >= 300 and angle < 330 then return "NW"
  end
  return ""
end

local function getWarningTimeout()
  -- 2 second timeout
  return getTime() + 100*2
end

local function run_func()
  -- Handle warning messages from mavlink
  local t2 = getValue(210) -- Temp2
  local armed = t2%0x02;
  t2 = (t2-armed)/0x02;
  local status_severity = t2%0x10;
  t2 = (t2-status_severity)/0x10;
  local status_textnr = t2%0x400;
  if(status_severity > 0)
  then
    if status_severity ~= apm_status_message.severity or status_textnr ~= apm_status_message.textnr
    then
      apm_status_message.severity = status_severity
      apm_status_message.textnr = status_textnr
      apm_status_message.timestamp = getTime()
    end
  end
  if apm_status_message.timestamp > 0 and (apm_status_message.timestamp + 2*100) < getTime()
  then
    apm_status_message.severity = 0
    apm_status_message.textnr = 0
    apm_status_message.timestamp = 0
  end

  -- Calculate return value (armed)
  local armd = 0
  if(getApmArmed() == true)
  then
    armd = 1024
    if(pilote_coord.lock == 0) then
      pilote_coord.lock = 1
      pilote_coord.lat = getValue("latitude")
      pilote_coord.long = getValue("longitude")
      pilote_coord.yaw = getValue("heading")
    end
  else
    armd = 0
    pilote_coord.lock = 0
  end
  return armd
end  

return {init=init, run=run_func, output=outputs}