-- Set by user
local capacity_max = 5000
local toogle_sec = 0
local speed_max = 0
local vspeed_max = 1

local function init()
  
end

local function background()
  
  if getTime()%50 == 0 then
    if toogle_sec == 0 then toogle_sec = 1
    else toogle_sec = 0
    end
  end
  
end


local function run(event)
  
  background()
  
---------------------------------------------------------------------------
-- Header (line 1)
---------------------------------------------------------------------------
  
-- Model name && status
  lcd.drawText(1, 1, model.getInfo().name, INVERS + SMLSIZE)
  lcd.drawFilledRectangle(lcd.getLastPos(), 0, 10, 9, 0)
  
-- Flight mode
  lcd.drawText(lcd.getLastPos() + 10, 1, getApmFlightmodeText(), INVERS)
  
  
---------------------------------------------------------------------------
-- Left column (column 1)
---------------------------------------------------------------------------
  
-- Cell vertical gauge
  -- Valid for LiPo cell (max=4.2V, min=3.2V)
  local cell_percent = (100 * getValue("cell-min") - 320) / 100
  if     cell_percent > 1 then cell_percent = 1
  elseif cell_percent < 0 then cell_percent = 0
  end
  -- There is no vertical gauge at this time so use filled rectangle
  lcd.drawRectangle(1, 10, 8, 44, 0)
  lcd.drawFilledRectangle(2, 11+43*(1-cell_percent), 6, 43*cell_percent, 0)
  
  
---------------------------------------------------------------------------
-- Line 2
---------------------------------------------------------------------------
  
-- Arm status
  if getApmArmed()
  then
    lcd.drawText(12, 10, "ARMED", MIDSIZE)
  else
    lcd.drawText(12, 10, "SAFE", MIDSIZE)
  end
-- Lock for sticky throttle
  if getValue("ls20") >= 1020 then
    lcd.drawPixmap(lcd.getLastPos(), 10, "/SCRIPTS/BMP/padlock.bmp")
  end
  
-- RSSI level
  local rssi = getValue("rssi")
  lcd.drawPixmap(70,
                 13,
                 "/SCRIPTS/BMP/rssi"..math.floor(3*rssi/50)..".bmp")
  lcd.drawText(90, 14, rssi.."%", 0)
  
-- Status msg notification
  if global_new_messages ~= nil and global_new_messages == true then
    -- no BLINK attribute for bitmap at this moment,
    -- so use sys time to blink
    if toogle_sec == 1 then
      lcd.drawPixmap(lcd.getLastPos() + 10, 15, "/SCRIPTS/BMP/letter.bmp")
    end
  end
  
  
---------------------------------------------------------------------------
-- Left column (column 2)
---------------------------------------------------------------------------
  
-- Line 3
-- Battery voltage
  lcd.drawText(12,                   25, getValue("vfas").."V", 0)
  lcd.drawText(lcd.getLastPos(),     26, " ["..getValue("vfas-min").."V]", SMLSIZE)
  
-- Line 4
-- Cell voltage
  lcd.drawText(12, 35, getValue("cell-min").."V", 0)
  lcd.drawText(lcd.getLastPos(),     36, " ["..getValue("cell-min-min").."V]", SMLSIZE)
  lcd.drawText(lcd.getLastPos(),     35, " ", 0)
  
-- Line 5
-- Consumption
  lcd.drawText(12, 45, getValue("current").."A", 0)
  lcd.drawText(lcd.getLastPos(),     46, " ["..getValue("current-max").."A]", SMLSIZE)
  lcd.drawText(lcd.getLastPos() + 4, 45, getValue("power").."W", 0)
  
-- Magnetic heading
  local tmp_heading = getValue("heading")
  lcd.drawText(75, 35, tmp_heading.."@"..getCardinalDir(tmp_heading), 0)
  lcd.drawPixmap((lcd.getLastPos()+75)/2-5, 23, "/SCRIPTS/BMP/craft.bmp")
  
-- Vertical speed
  local tmp_vspeed = getValue("vertical-speed")
  local vspeed_coord = {x1=115, y1=25, x2=115, y2=50}
  lcd.drawLine(vspeed_coord.x1,
               vspeed_coord.y1,
               vspeed_coord.x2,
               vspeed_coord.y2-1,
               SOLID, 0)
  -- max vspeed line
  lcd.drawLine(vspeed_coord.x1 - 3,
               vspeed_coord.y1,
               vspeed_coord.x2 + 2,
               vspeed_coord.y1,
               SOLID, 0)
  -- null vspeed line
  lcd.drawLine(vspeed_coord.x1 + 3,
               (vspeed_coord.y1 + vspeed_coord.y2) / 2,
               vspeed_coord.x2 + 1,
               (vspeed_coord.y1 + vspeed_coord.y2) / 2,
               SOLID, 0)
  -- min vspeed line
  lcd.drawLine(vspeed_coord.x1 - 3,
               vspeed_coord.y2,
               vspeed_coord.x2 + 2,
               vspeed_coord.y2,
               SOLID, 0)
  -- redefine max if vspeed higher than current max
  if math.abs(tmp_vspeed) > vspeed_max then
    vspeed_max = math.ceil(math.abs(tmp_vspeed / 10)) * 10
  end
  -- current vspeed
  lcd.drawPixmap(vspeed_coord.x1-4,
                 ((vspeed_coord.y1+vspeed_coord.y2)/2) - (tmp_vspeed*vspeed_coord.y1)/(2*vspeed_max) - 3,
                 "/SCRIPTS/BMP/arrow.bmp")
  lcd.drawText(vspeed_coord.x1 + 6,
               (vspeed_coord.y1 + vspeed_coord.y2) / 2 - 3,
               math.abs(tmp_vspeed),
               tmp_vspeed,
               SMLSIZE)
  
---------------------------------------------------------------------------
-- Right column (column 3)
---------------------------------------------------------------------------
  
-- Timer 0
  local timer = model.getTimer(0)
  lcd.drawTimer(142, 0, timer.value, MIDSIZE)  
  
-- Altitude
  lcd.drawText(142, 16, math.floor(getValue("altitude")), MIDSIZE)
  local tmp_pos = lcd.getLastPos()
  lcd.drawText(tmp_pos, 16-1, math.floor(getValue("altitude-max")), SMLSIZE)
  lcd.drawText(tmp_pos, 16+5, "m", SMLSIZE)
  
-- Speed
  --local tmp_speed = getValue("gps-speed")
  --if tmp_speed > speed_max then speed_max = tmp_speed
  --end
  lcd.drawText(142, 33, getValue("gps-speed"), MIDSIZE)
  tmp_pos = lcd.getLastPos()
  lcd.drawText(tmp_pos, 33-1, getValue("gps-speed-max"), SMLSIZE)
  lcd.drawText(tmp_pos, 33+5, "km.h", SMLSIZE)
  --lcd.drawText(tmp_pos, 33+5, getValue("gps-speed-max"), SMLSIZE)
  
-- Distance to home
  lcd.drawPixmap(142, 50, "/SCRIPTS/BMP/home.bmp")
  lcd.drawText(156-1, 50-2, getValue("distance-max"), SMLSIZE)
  lcd.drawText(156, 50+6, getValue("distance").."m", SMLSIZE)
  
-- GPS status
  if getApmGpsLock() >= 3.0 then
    lcd.drawPixmap(190, 1, "/SCRIPTS/BMP/gps3d.bmp")
  else
    lcd.drawPixmap(190, 1, "/SCRIPTS/BMP/gpsno.bmp")
  end
-- GPS HDOP
  local gpsHdop = getApmGpsHdop()
  if gpsHdop ==  0.0 then
    lcd.drawText(190, 30, "---", BLINK)
  elseif gpsHdop == 10.24 then
    lcd.drawText(190, 30, "HIGH", BLINK)
  elseif gpsHdop <= 2.0 then
    lcd.drawText(190, 30, gpsHdop, 0)
  else
    lcd.drawText(190, 30, gpsHdop, BLINK)
  end
  
-- Relative home position
  local relativeHeadingHome = getApmHeadingHomeRelative()
  local integHead, fracHead = math.modf(relativeHeadingHome / 22.5 + 0.5)
  lcd.drawPixmap(190, 42, "/SCRIPTS/BMP/arrow"..(integHead % 16)..".bmp")
  
  
---------------------------------------------------------------------------
-- Footer (line 6)
---------------------------------------------------------------------------
  
-- Battery gauge or APM status
  -- Fetch current status
  local status = getApmActiveStatus()
  if status ~= nil then
    -- Status msg
    lcd.drawText(1, 55, status.message, 0)
  else
    -- Battery gauge
    local telem_mah = getValue("consumption")
    lcd.drawGauge(1, 55, 90, 8, capacity_max - telem_mah, capacity_max)
    lcd.drawText(90 + 4, 55, telem_mah.."mAh", 0)
  end
  
  
end


return { init=init, run=run, background=background}