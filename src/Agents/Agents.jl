module Agents
    export RandomAgent, PerfectAgent
    include("RandomAgent.jl")
    include("PerfectAgent.jl")

    import .RandomAgent
    import .PerfectAgent
end