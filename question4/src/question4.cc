/**
* TavernLight Games Software Engineer Technical Trial
* Applicant: Tomaz Cuber
* Description: This file contains my proposed solution for Question 4 
*              from the Technical Trial for the Software Engineer Position
*              at TavernLight Games.
* Question: Q4 - Assume all method calls work fine. Fix the memory leak issue in below method
* 
* void Game::addItemToPlayer(const std::string& recipient, uint16_t itemId)
* {
*     Player* player = g_game.getPlayerByName(recipient);
*     if (!player) {
*         player = new Player(nullptr);
*         if (!IOLoginData::loadPlayerByName(player, recipient)) {
*             return;
*         }
*     }
*         
*     Item* item = Item::CreateItem(itemId);
*     if (!item) {
*         return;
*     }
* 
*     g_game.internalAddItem(player->getInbox(), item, INDEX_WHEREEVER, FLAG_NOLIMIT);
* 
*     if (player->isOffline()) {
*         IOLoginData::savePlayer(player);
*     }
* }
*/

void Game::addItemToPlayer(const std::string& recipient, uint16_t itemId)
{
    // First we have declared a player pointer that receives the return value of
    // the g_game.getPlayerByName(recipient) call.
    Player* player = g_game.getPlayerByName(recipient);
    // This if statement indicates that the getPlayerByName method will return a nullptr
    // if a player with the provided name hasn't been found. Given the code that follows,
    // it is safe to assume that g_game object manages the lifetime of the player pointer,
    // as long as it exists, meaning that the class is responsible for allocatind and deleting
    // the player object the pointer references from the heap.
    if (!player) {
        // In this case, we attribute the player pointer to a newly allocated Player 
        // object, using the new operator and receiving a nullptr as a constructor parameter. 
        // This is the opportunity for a memory leak. When the Game::addItemToPlayer 
        // method returns, if this Player object was not deleted previously, the memory
        // will be leaked, because the player pointer will leave the stack, but the created Player 
        // object's memory won't be freed from the heap. Therefore, it can't be deleted from anywhere else
        // on the code.
        player = new Player(nullptr);
        if (!IOLoginData::loadPlayerByName(player, recipient)) {
            // Here we are performing an early return if the IOLoginData::loadPlayerByName method call
            // returns a false value. Assuming the IOLoginData::loadPlayerByName method does not take
            // ownership of the Player pointer (i.e. assumes the responsibility of deleting it when it
            // is no longer necessary), it results on a memory leak on the player data. This assumption is
            // probable, because the IOLoginData::loadPlayerByName is static, and therefore, does not manage
            // the IOLoginData class's state.
            return;
        }
    }
    
    // Once again, in this section we are creating a pointer to an object inside the method's scope.
    // This time, instead, since there was no use of the 'new' operator, the heap allocation for the
    // Item object was not handled by this method. Therefore, as a best pratice, we should not worry
    // about deleting the item object in this scope, because it could lead to deleting a resource neede
    // elsewhere or a double deletion, which is undefined behavior.
    Item* item = Item::CreateItem(itemId);
    if (!item) {
        // In this return statement,if the program executed the previous if statement block, 
        // here the player memory would be leaked,in the same manner as the early return from the previous if statement.
        return;
    }
    
    g_game.internalAddItem(player->getInbox(), item, INDEX_WHEREEVER, FLAG_NOLIMIT);

    if (player->isOffline()) {
        IOLoginData::savePlayer(player);
    }

    // At the end of the Game::addItemToPlayer method's scope, if the player was created via dynamic allocation using
    // the 'new' operator inside the if(!player) block, then the player memory will be leaked.
}

// What follows is a solution propposal for fixing the described memory leaks.
// It assumes that IOLoginData::loadPlayerByName does not take ownership of the player pointer.
// The reasoning behind this solution is to avoid dynamic allocation of the Player object with the
// 'new' operator. Instead, we create a temporary Player object inside the method's scope and attribute
// it's address to the player pointer. That way, once the method leaves the stack, since the temporary
// object was not allocated in the heap, it will be destroyed. This solves the memory leak problem, but
// introduces an issue with data persistence for the Player. Therefore, we have no choice but duplicate
// the g_game.internalAddItem call, passing the temporary player object's inbox instead of the original 
// player pointer in order to persist the altered player data with an IOLoginData::savePlayer call on
// the altered temporary player object.
void Game::addItemToPlayerWithoutMemoryLeak(const std::string& recipient, std::uint16_t itemId)
{
    Player* player = g_game.getPlayerByName(recipient);
    
    // As said in the previous method, since Item heap allocation was performed elsewhere, we should
    // not worry about deleting the item pointer.
    Item* item = Item::CreateItem(itemId);
    if (!item) {
       return;
    }
    
    if (!player) {
        // Creating a temporary player object. This object's lifetime is bound to the method's scope,
        // meaning that it's memory cannot be leaked once the program reaches the end of the method's
        // execution.
        Player newTmpPlayer(nullptr);
        if (!IOLoginData::loadPlayerByName(&newTmpPlayer, recipient)) {
            return;
        }
        
        // I dislike the code duplication, but this solution guarantees that the Players altered state
        // is kept in a persistent manner. 
        g_game.internalAddItem(newTmpPlayer.getInbox(), item, INDEX_WHEREEVER, FLAG_NOLIMIT);
        IOLoginData::savePlayer(&newTmpPlayer);
        return;
        // newTmpPlayer is destroyed as the method reaches it's end
    }

    // Performs the item addition and conditional storing of the player's state in the same way 
    // as the previous implementation.
    g_game.internalAddItem(player->getInbox(), item, INDEX_WHEREEVER, FLAG_NOLIMIT);

    if (player->isOffline()) {
        IOLoginData::savePlayer(player);
    }
}
