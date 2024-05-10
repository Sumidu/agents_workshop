using Pkg
Pkg.activate(".")
using CairoMakie
#using GLMakie
using Agents

# This is a model of agents that simulate a SIRS model

@agent struct Person(GridAgent{2})
    state::Int  # 0 = S, 1 = I, 2 = R
    next_state::Int
end

function sir_step!(agent, model)
    if agent.state == 1
        # infect neighbors
        neighbors = nearby_agents(agent, model, 1)
        for neighbor in neighbors
            neighbor.next_state = 1
        end
        # recover
    end


end

function sir_update!(model)
    for agent in allagents(model)
        agent.state = agent.next_state
    end
end


function initialize_model(agent_count = 1, infection_probability = 0.1, recovery_probability = 0.1)

    # generate a space
    space = GridSpaceSingle((10, 10), periodic=true)
    
    properties = Dict(
        :infection_probability => infection_probability,
        :recovery_probability => recovery_probability
    )

    # generate a model
    model = ABM(Person, space, properties=properties, agent_step! = sir_step!, model_step! = sir_update!)

    # add agents that are healthy
    for i in 1:agent_count
        agent = Person(i, (0,0), 0, 0)
        add_agent_single!(agent, model)
    end

    case_zero = random_agent(model)
    case_zero.state = 1
    case_zero.next_state = 1
    return model
end




model = initialize_model(120, 0.4)

model

step!(model)


for i in 1:100
    println(model[i])
end


acolor(agent) = agent.state 

scene = abmplot(model; agent_color = acolor)
fig = scene[1]
fig

fig, _, _ = abmplot(model; agent_color = acolor)
fig