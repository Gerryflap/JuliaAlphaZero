module RandomAgent
    export choose_action, RandomAgentState
    using Random
    import ..Agents
    using ...Environments

    struct RandomAgentState <: Agents.AgentState end
    
    function Agents.choose_action(agentState::RandomAgentState, s::State) :: Action
        possible_actions = action_space(s)
        return possible_actions[rand(1:(length(possible_actions)))]
    end
end