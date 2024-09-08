game.clock = {}
game.clock.milliseconds = 0
game.clock.seconds = 0
game.clock.minutes = 0
game.clock.hours = 0
game.clock.days = 1
game.clock.weeks = 0
game.clock.months = 1
game.clock.years = 0

-- Constants for time conversion
local MILLISECONDS_IN_SECOND = 1000
local SECONDS_IN_MINUTE = 60
local MINUTES_IN_HOUR = 60
local HOURS_IN_DAY = 24
local DAYS_IN_WEEK = 7

-- Month lengths in days (non-leap year)
local monthLengths = {
    31, -- January
    28, -- February (29 in leap years)
    31, -- March
    30, -- April
    31, -- May
    30, -- June
    31, -- July
    31, -- August
    30, -- September
    31, -- October
    30, -- November
    31, -- December
}

-- Function to determine if a year is a leap year
local function isLeapYear(year)
    if year % 4 == 0 then
        if year % 100 == 0 then
            return year % 400 == 0
        else
            return true
        end
    else
        return false
    end
end

-- Function to get the number of days in the current month
local function getCurrentMonthLength()
    local month = game.clock.months
    if month == 2 and isLeapYear(game.clock.years) then
        return 29 -- February in a leap year
    else
        return monthLengths[(month - 1) % 12 + 1] -- Make sure month is always valid
    end
end

local function normalizeClock()
    -- Normalize milliseconds to seconds
    if game.clock.milliseconds >= MILLISECONDS_IN_SECOND then
        game.clock.seconds = game.clock.seconds + math.floor(game.clock.milliseconds / MILLISECONDS_IN_SECOND)
        game.clock.milliseconds = game.clock.milliseconds % MILLISECONDS_IN_SECOND
    elseif game.clock.milliseconds < 0 then
        game.clock.seconds = game.clock.seconds + math.floor(game.clock.milliseconds / MILLISECONDS_IN_SECOND)
        game.clock.milliseconds = (game.clock.milliseconds % MILLISECONDS_IN_SECOND + MILLISECONDS_IN_SECOND) % MILLISECONDS_IN_SECOND
    end
    
    -- Normalize seconds to minutes
    if game.clock.seconds >= SECONDS_IN_MINUTE then
        game.clock.minutes = game.clock.minutes + math.floor(game.clock.seconds / SECONDS_IN_MINUTE)
        game.clock.seconds = game.clock.seconds % SECONDS_IN_MINUTE
    elseif game.clock.seconds < 0 then
        game.clock.minutes = game.clock.minutes + math.floor(game.clock.seconds / SECONDS_IN_MINUTE)
        game.clock.seconds = (game.clock.seconds % SECONDS_IN_MINUTE + SECONDS_IN_MINUTE) % SECONDS_IN_MINUTE
    end
    
    -- Normalize minutes to hours
    if game.clock.minutes >= MINUTES_IN_HOUR then
        game.clock.hours = game.clock.hours + math.floor(game.clock.minutes / MINUTES_IN_HOUR)
        game.clock.minutes = game.clock.minutes % MINUTES_IN_HOUR
    elseif game.clock.minutes < 0 then
        game.clock.hours = game.clock.hours + math.floor(game.clock.minutes / MINUTES_IN_HOUR)
        game.clock.minutes = (game.clock.minutes % MINUTES_IN_HOUR + MINUTES_IN_HOUR) % MINUTES_IN_HOUR
    end
    
    -- Normalize hours to days
    if game.clock.hours >= HOURS_IN_DAY then
        game.clock.days = game.clock.days + math.floor(game.clock.hours / HOURS_IN_DAY)
        game.clock.hours = game.clock.hours % HOURS_IN_DAY
    elseif game.clock.hours < 0 then
        game.clock.days = game.clock.days + math.floor(game.clock.hours / HOURS_IN_DAY)
        game.clock.hours = (game.clock.hours % HOURS_IN_DAY + HOURS_IN_DAY) % HOURS_IN_DAY
    end
    
    -- Normalize days to months based on current month's length
    local currentMonthLength = getCurrentMonthLength()
    while game.clock.days > currentMonthLength do
        game.clock.months = game.clock.months + 1
        game.clock.days = game.clock.days - currentMonthLength
        currentMonthLength = getCurrentMonthLength() -- Update for next month if overflow
    end
    
    while game.clock.days <= 0 do
        game.clock.months = game.clock.months - 1
        currentMonthLength = getCurrentMonthLength()
        game.clock.days = game.clock.days + currentMonthLength
    end
    
    -- Normalize months to years
    if game.clock.months > 12 then
        game.clock.years = game.clock.years + math.floor((game.clock.months - 1) / 12)
        game.clock.months = (game.clock.months - 1) % 12 + 1
    elseif game.clock.months <= 0 then
        game.clock.years = game.clock.years + math.floor((game.clock.months - 1) / 12)
        game.clock.months = (game.clock.months - 1) % 12 + 12
    end
end

local function updateClock(deltaTime)
    -- Convert deltaTime from seconds to milliseconds
    game.clock.milliseconds = game.clock.milliseconds + deltaTime * MILLISECONDS_IN_SECOND
    
    -- Normalize the clock values after adding deltaTime
    normalizeClock()
end

-- Add time to the clock
function game.clock.addTime(milliseconds, seconds, minutes, hours, days, months, years)
    game.clock.milliseconds = game.clock.milliseconds + (milliseconds or 0)
    game.clock.seconds = game.clock.seconds + (seconds or 0)
    game.clock.minutes = game.clock.minutes + (minutes or 0)
    game.clock.hours = game.clock.hours + (hours or 0)
    game.clock.days = game.clock.days + (days or 0)
    game.clock.months = game.clock.months + (months or 0)
    game.clock.years = game.clock.years + (years or 0)
    
    -- Normalize after adding time
    normalizeClock()
end

-- Remove time from the clock
function game.clock.removeTime(milliseconds, seconds, minutes, hours, days, months, years)
    game.clock.milliseconds = game.clock.milliseconds - (milliseconds or 0)
    game.clock.seconds = game.clock.seconds - (seconds or 0)
    game.clock.minutes = game.clock.minutes - (minutes or 0)
    game.clock.hours = game.clock.hours - (hours or 0)
    game.clock.days = game.clock.days - (days or 0)
    game.clock.months = game.clock.months - (months or 0)
    game.clock.years = game.clock.years - (years or 0)
    
    -- Normalize after removing time
    normalizeClock()
end

hooks.Add("OnGameUpdate", function(deltaTime)
    updateClock(deltaTime)

    if love.keyboard.isDown("e") then
        game.clock.addTime(0,0,0,1)
    end

    if love.keyboard.isDown("r") then
        game.clock.addTime(12,12,12,12,12,12)
    end    
end)

hooks.Add("OnGameDraw", function()
    -- Display the clock (example formatting)
    love.graphics.print(string.format("Years: %d, Months: %d, Days: %d, Hours: %d, Minutes: %d, Seconds: %d\nLeap Year?: %s\nMonth length: %s", 
        game.clock.years, game.clock.months, game.clock.days, game.clock.hours, game.clock.minutes, game.clock.seconds, isLeapYear(game.clock.years) == true and "True" or "False", getCurrentMonthLength()), ScreenX()/2, ScreenY()/2)
end)
