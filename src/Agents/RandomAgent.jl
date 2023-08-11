module RandomAgent
    export choose_action
    using Random
    using ...Environments
    
    function choose_action(s::State) :: Action
        possible_actions = action_space(s)
        return possible_actions[rand(1:(length(possible_actions)))]
    end
end