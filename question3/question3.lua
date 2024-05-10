--[[
* TavernLight Games Software Engineer Technical Trial
* Applicant: Tomaz Cuber
* Description: This file contains my proposed solution for Question 3
*              from the Technical Trial for the Software Engineer Position
*              at TavernLight Games.
* Question: Q3 - Fix or improve the name and the implementation of the below method
*
* function do_sth_with_PlayerParty(playerId, membername)
*     player = Player(playerId)
*     local party = player:getParty()
*
*     for k,v in pairs(party:getMembers()) do
*         if v == Player(membername) then
*             party:removeMember(Player(membername))
*         end
*     end
* end
*
]]

--  The given do_sth_with_PlayerParty(playerId, membername) function is no correctly named,
--  as its name does not provide any explanation of what the function's purpose is, except
--  that it deals with the party in which the player with the provided playerId is in.
--  Also, the function's name does not follow a consistent naming convention, as the
--  "do_sth_with_" section is formatted in snake_case and "PlayerParty" is in PascalCase.
--  Let's review the function line-by-line in order to discover it's intended functionality.
--
function do_sth_with_PlayerParty(playerId, membername) -- The function receives 2 arguments: a playerId and membername
    player = Player(playerId)                          -- First, creates a global player value, attributing to it a new Player object with the given playerId.
    local party = player:getParty()                    -- Next, it populates a local 'party' variable with the value returned from the player::getParty method.

    for k, v in pairs(party:getMembers()) do           -- Here the function iterates through the party::getMembers table, this table should contain all members of the player's party.
        -- If the current player object from the party members table is the same as a Player object constructed with the given membername
        -- calls the party::removeMember method passing the Player(membername) object. This function, as it's name indicates, removes the
        -- player from the party.
        if v == Player(membername) then
            party:removeMember(Player(membername))
        end
    end
end

-- We can conclude that the function's goal is: given a player's playerId and the name
-- of a player that is a member of the player's party, remove the player with the same
-- name as 'membername' from the player's party.
-- Therefore a better name for this function would be:
-- function removeMemberFromPlayerParty(playerId, memberNameToRemove)

-- Now let's raise some points in which the function's implementation could be improved:
--  1.  We should validate if the given arguments are valid, i.e. check if Player(playerId),
--      player::getParty() and Player(membername) are not nil. This means that the function
--      should return if the player with playerId is not found or if the player is not in a
--      party or if the player with membername is not found.
--  2.  We should not declare a global variable inside the function's scope, opting to declare
--      variables with the 'local' keyword.
--  3.  We should also check if the player is not the same as the player with membername, as it is not the
--      functions intended use. A better practice is to implement a playerLeaveCurrentPaty(playerId) function
--      for dealing with this feature.
--  4.  We can improve the naming of the key and value variables for the party::getMembers iteration:
--      since the key value is not relevant to the iteration we can rename 'k' to '-'. Also, the v variable
--      should be named more semantically: we can simply call it 'member'.
--  5.  As it is, the function is iterating through all the members in the party, regardless if the desired
--      member has already been removed. This could result in performance issues if the party::getMembers
--      is large. To fix it, we should add a return statement after removing the player from the party.
-- Given this considerations, my implementation of the function is:
function removeMemberFromPlayerParty(playerId, memberNameToRemove)
    local player = Player(playerId)
    if not player then
        print("Error: player with id: " .. playerId .. " was not found")
        return
    end

    local party = player:getParty()
    if not party then
        print("Error: player is not in a party")
        return
    end

    local memberToRemove = Player(memberNameToRemove)
    if not memberToRemove then
        print("Error: player " .. memberNameToRemove .. " was not found")
        return
    end

    if player == memberToRemove then
        print("Error: player cannot remove itself from the party")
        return
    end

    for _, member in pairs(party:getMembers()) do
        if member == memberToRemove then
            party:removeMember(memberToRemove)
            return
        end
    end

    print("Error: player " .. memberNameToRemove .. " was not found in the party")
end
