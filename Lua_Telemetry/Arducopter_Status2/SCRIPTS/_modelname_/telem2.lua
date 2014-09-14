local messages = {}
local last_message = nil
global_new_messages = false

local function init()
end

-- Format a number to a string with 2 digits. 
local function asTimeNumber(number)
	if number < 10
	then
		return "0"..number
	end
	return number
end

-- Takes a time (10 msec resolution) and formats as min:sec
local function formatTimestamp(timestamp)
  local iDiff, fDiff = math.modf((getTime() - timestamp)/100)
  local sec = iDiff%60
  local min = (iDiff-sec)/60
  local ret = asTimeNumber(min)..":"..asTimeNumber(sec)
  return ret
end

-- Looks for new messages and builds a list of messages
local function handleMessage()
  -- Fetch message
  local message = getApmActiveStatus()
  if message ~= nil and (last_message == nil or message.timestamp ~= last_message.timestamp)
  then 
    global_new_messages = true
    last_message = message
	local i = 1
    while messages[i] ~= nil 
	do
      i = i + 1
    end
	for i=i, 2, -1
	do
	  messages[i] = messages[i-1]
	end
	messages[1] = {text = message.message, timestamp = message.timestamp }
  end
end

-- Scan for messages when not visible
local function background()
  handleMessage()
end


local function run(event)
  -- Scan for new messages
  handleMessage()

  -- Reset global flag since we now have shown any new messages
  global_new_messages = false
  
  -- Loop through messages
  local i = 1
  local warnings_received = false
  for i=1, 10, 1
  do
	if messages[i] ~= nil
	then
		lcd.drawText(1, 1 + 8* (i-1) , formatTimestamp(messages[i].timestamp).."  "..messages[i].text, 0)
		warnings_received = true
	end
  end
  -- No messages received - show text
  if warnings_received == false
  then
	lcd.drawFilledRectangle(10, 10, 190, 45, GREY_DEFAULT)
	lcd.drawText(40, 30, "No warnings received", 0)
  end
  
end

return { init=init, run=run, background=background}