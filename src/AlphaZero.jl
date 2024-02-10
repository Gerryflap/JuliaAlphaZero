module AlphaZero
export run

include("Environments/Environments.jl")
include("Agents/Agents.jl")

using .Environments
import .Environments.TicTacToe
import .Environments.Connect4
import .Environments.Connect3
import .Environments.TestEnv
using .Agents
import .Agents.RandomAgent
import .Agents.PerfectAgent
import .Agents.AlphaBetaPerfectAgent
import .Agents.SimpleMctsAgent
import .Agents.HumanAgent
import .Agents.OpeningBookPerfectAgent


function run()
    # state = initial_state(TicTacToe.TttState)
    # state = initial_state(Connect3.C3State)
    state = initial_state(Connect4.C4State)


    book = get_opening_book(state)

    # agents = [AlphaBetaPerfectAgent.AbpAgentState(), PerfectAgent.PerfectAgentState()]
    agents = [OpeningBookPerfectAgent.ObPerfectAgentState(book), SimpleMctsAgent.MctsAgentState(5000)]
    # agents = [OpeningBookPerfectAgent.ObPerfectAgentState(book), PerfectAgent.PerfectAgentState()]
    render(state)
    while !is_final_state(state)
        current_agent = agents[get_current_player(state)]
        a :: Action = choose_action(current_agent, state)
        state = make_step(state, a)
        render(state)
    end

    println("Game end, rewards = $(get_final_state_rewards(state))")
    
end

function get_opening_book(state::State) :: OpeningBookPerfectAgent.OpeningBook
    book_path = "./opening_book_" * replace(string(typeof(state).name.wrapper), "." => "_")
    println("Trying to load " * book_path)
    book = OpeningBookPerfectAgent.load_opening_book(book_path)
    if isnothing(book)
        println("Loading failed, computing opening book for perfect AI")
        book = OpeningBookPerfectAgent.compute_opening_book(state, 15)
        println("Done computing, saving..")
        OpeningBookPerfectAgent.save_opening_book(book, book_path)
    end
    println("Done...")
    println("Book size: ", length(book.book))
    return book
end

end # module AlphaZero

