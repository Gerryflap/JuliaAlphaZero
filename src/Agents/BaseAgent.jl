using ..Environments

abstract type AgentState end

"""
    choose_action(agentState::AgentState, s::State) :: Action

Lets the agent choose an action using the agent state and the game state, resulting in an action and possibly an update of the agent state
"""
function choose_action(agentState::AgentState, s::State) :: Action end
