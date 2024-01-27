module TestEnv
export TestEnvState, TestEnvAction, initial_state, make_step, is_final_state, get_final_state_rewards, action_space, is_valid_action, render, get_current_player

using Match
import ..Environments

left_states = [2,4,5]
right_states = [3,5,6]

struct TestEnvAction <: Environments.Action
    left :: Bool
    player :: Int
end

struct TestEnvState <: Environments.State
    state :: Int
    player :: Int
end

function Environments.initial_state(::Type{TestEnvState}) :: TestEnvState
    return TestEnvState(1, 1)
end

function Environments.make_step(s::TestEnvState, a::TestEnvAction) :: TestEnvState
    if (!Environments.is_valid_action(s, a))
        throw(Environments.InvalidActionException())
    end
    
    new_state = s.state
    if a.left
        new_state = left_states[s.state]
    else
        new_state = right_states[s.state]
    end

    player = (a.player) % 2 + 1
    return Environments.TestEnvState(new_state, player)
end

function Environments.is_final_state(s::TestEnvState) :: Bool
    return s.state > 3
end

function Environments.get_final_state_rewards(s::TestEnvState) :: Array{Float64}
    return @match s.state begin
        5 => [ 0.0  0.0]    # Draw
        6 => [ 1.0 -1.0]    # P1 win
        4 => [-1.0  1.0]    # P2 win
    end
end

function Environments.get_current_player(s::TestEnvState) :: Int
    return s.player
end


function Environments.action_space(s::TestEnvState) :: Array{TestEnvAction}
    actions = [TestEnvAction(true, s.player), TestEnvAction(false, s.player)]
    return actions
end

function Environments.is_valid_action(s::TestEnvState, a::TestEnvAction) :: Bool
    return !Environments.is_final_state(s) && a.player == s.player
end

function Environments.render(s::TestEnvState)
    println(s)
end

function Environments.max_reward(s::TestEnvState) :: Float64
    return 1.0
end

function Environments.state_hash(s::TestEnvState)::Array{Int64}
    return [s.state]
end

end