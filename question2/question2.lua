--[[
* TavernLight Games Software Engineer Technical Trial
* Applicant: Tomaz Cuber
* Description: This file contains my proposed solution for Question 2
*              from the Technical Trial for the Software Engineer Position
*              at TavernLight Games.
* Question: Q2 - Fix or improve the implementation of the below method
*
* function printSmallGuildNames(memberCount)
*     -- this method is supposed to print names of all guilds that have less than memberCount max members
*     local selectGuildQuery = "SELECT name FROM guilds WHERE max_members < %d;"
*     local resultId = db.storeQuery(string.format(selectGuildQuery, memberCount))
*     local guildName = result.getString("name")
*     print(guildName)
* end
*
]]

-- First, given the function's description, I believe that the it isn´t correctly named.
-- The adjective ´small´ does not describe precisely what guild names will be printed. The
-- result is that in order to understand the expected functionality, a developer will need to
-- open the function implementation and read it.
-- I belive that a better name for the function would be: 'printGuildNamesWithLessMembersThen(memberCount)'
--
-- Additionally, the implementation itself is not correct. If there are more than one guild that fits the
-- criteria, it would only print the name of the first guild returned by the query result. In order to print
-- all the guilds with less than 'memberCount' members, we need to iterate over the rows from the query's result.
-- Assume that both 'db' and 'result' are global variables declared somewhere else in the code, and that 'result'
-- is populated by the query's resulting rows. In that case, is likely that result is a database cursor used to
-- traverse these rows. Since we don't know the implementation of the database interface, we'll use the
-- result.fetchNext() method as a substitute for the real method. The result.fetchNext() method will update the cursor
-- to the following row, returning the next row's resultId or nil if it reaches the end of the resulting rows.
--
-- Moreover, in order to make the function more resilient, we should add validation on the SQL query´s result.
--
-- Finally, one of the most proeminent problems in this implementation is the use of lua's string formatting to
-- assemble the SQL Query. This practice could lead to our program being vulnerable to SQL Injection attacks. If
-- this method is somehow exposed to end users, a malicious attacker could pass SQL statements to the parameter that,
-- in this implementation would be run as is. The most common way of mitigating SQL Injection's is to sanitize and validate
-- the function's input. Most database interfaces offer prepared statements, a mechanism that pre-compiles SQL code and
-- separates the data from the SQL query, so that the data is always interpred as data, and not SQL queries. A possible
-- implementation for a prepared statement in this case would be:
--
--      local selectGuildQuery = db.prepare("SELECT name FROM guilds WHERE max_members < ?")
--      local resultId = db.storeQuery(selectGuildQuery.bindArguments(memberCount))
--
-- However, since 'memberCount' should only be a positive integer value and not a more complex data type, SQL Injections
-- could be prevented if we only allow positive integers in our input. Since this validation is not in the original
-- function's scope, we should separate it in another function, such as:
function validatePositiveInteger(input)
    local num = tonumber(input)
    if num == nil or num < 1 or num % 1 ~= 0 then
        print("Error: invalid input: " .. input)
    else
        return num
    end
end

-- The following is an implementation of the question's method that takes all the previous points in consideration:
function printGuildNamesWithLessMembersThen(memberCount)
    local sanitizedMemberCount = validatePositiveInteger(memberCount)
    if not sanitizedMemberCount then
        return
    end

    local selectGuildQuery = "SELECT name FROM guilds WHERE max_members <" .. sanitizedMemberCount .. ";"
    local resultId = db.storeQuery(selectGuildQuery)

    if not resultId then
        print("Error: invalid database query")
        return
    end

    while resultId do
        local guildName = result.getString("name")
        print(guildName)
        resultId = result.next()
    end
end
