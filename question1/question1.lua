--[[
* TavernLight Games Software Engineer Technical Trial
* Applicant: Tomaz Cuber
* Description: This file contains my proposed solution for Question 1
*              from the Technical Trial for the Software Engineer Position
*              at TavernLight Games.
* Question: Q1 - Fix or improve the implementation of the below methods
*
* local function releaseStorage(player)
*     player:setStorageValue(1000, -1)
* end
*
* function onLogout(player)
*     if player:getStorageValue(1000) == 1 then
*         addEvent(releaseStorage, 1000, player)
*     end
*     return true
* end
*
]]

-- In this question, we are presented with two methods that would be
-- involved in the player logout process, specifically in handling
-- the player's storage state once a logout is started.
--
-- The local releaseStorage(player) method is wrapper function for the
-- player:setStorage method on the given player object, called with the
-- parameters (1000, -1). Based on it's usage, it's  safe to assume that
-- these arguments are a key, value pair where the first argument (1000)
-- is a key to the player's storage and the second (-1) is the desired
-- value for the given storage key. Since the function is described as
-- releasing the player's storage, it's likely that the key 1000 is the
-- storage key that refers to the player's storage ocupation state, and
-- the value -1 is used to indicate that the player's storage is released.
--
-- The global onLogout(player) method is responsible for validating
-- if the player's storage is occupied and, if it is, calls the
-- addEvent(releaseStorage, 1000, player) function. Given it's name
-- this function should be part of an event scheduling mechanism,
-- probablt following the Observer Design Pattern. This means that
-- another object maintains a queue of different events that perform
-- the function given as an argument after a certain delay, while still
-- passing the relevant parameters. In this case, the releaseStorage method
-- is scheduled to be called , probably after a delay of a 1000 milliseconds,
-- with the argument 'player'. The use of this pattern on the logout handling
-- should be useful if realesing the player's storage immediately after the
-- logout process starts could cause unexpected issues.
-- Also, the onLogout method could probably be a callback function, that is
-- used by a scripting interface and registered for different object
-- types as parameters.
--
-- Some issues that could be improved in these methods implementations are:
--  - Rewriting magical numbers for the key, value pairs that are used on the
--    player:getStorageValue and player:setStorageValue methods, and in the
--    event delay in order to give them semantic context.
--  - Performing input validation on the player object passed as parameters to
--    both methods
PLAYER_STORAGE_STATE_KEY = 1000
PLAYER_STORAGE_VALUE_EMPTY = -1
PLAYER_STORAGE_VALUE_FULL = 1

PLAYER_STORAGE_RELEASE_DELAY_MS = 1000

local function releaseStorage(player)
    if not player then
        print("Error: Invalid player object")
        return
    end
    player:setStorageValue(PLAYER_STORAGE_STATE_KEY, PLAYER_STORAGE_VALUE_EMPTY)
end

function onLogout(player)
    if not player then
        print("Error: Invalid player object")
        return false
    end

    if player:getStorageValue(PLAYER_STORAGE_STATE_KEY) == PLAYER_STORAGE_VALUE_FULL then
        addEvent(releaseStorage, PLAYER_STORAGE_RELEASE_DELAY_MS, player)
    end
    return true
end
