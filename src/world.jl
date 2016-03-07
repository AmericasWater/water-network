using Mimi

# Region Network definitions

using Graphs

typealias RegionNetwork{R, E} IncidenceList{R, E}
typealias OverlaidRegionNetwork RegionNetwork{ExVertex, ExEdge}
typealias MyNumeric Number #Float64

# Region network has OUT nodes to potential IMPORTERS

using DataFrames

empty_extnetwork() = OverlaidRegionNetwork(true, ExVertex[], 0, Vector{Vector{ExEdge}}())

using DataFrames

if isfile("../data/watersources.jld")
    println("Loading from saved water network...")

    waternet = deserialize(open("../data/waternet.jld", "r"))
    regverts = deserialize(open("../data/watervertices.jld", "r"))
    sourceiis = deserialize(open("../data/watersources.jld", "r"))
else
    # Load the network of counties
    waternetdata = read_rda("../data/waternet.RData", convertdataframes=true)

    #netids = UTF8String[]
    waternet = empty_extnetwork()

    for row in 1:nrow(waternetdata["network"])
        thisid = counties[row, :collection] + counties[row, :colid]
        nextpt = counties[row, :nextpt]
        nextid = counties[nextpt, :collection] + counties[nextpt, :colid]

        #if !(thisid in netids)
        #    add_vertex!(waternet, thisid)
        #    push!(netids, thisid)
        #end

        #if !(nextid in netids)
        #    add_vertex!(waternet, nextid)
        #    push!(netids, nextid)
        #end

        add_edge!(waternet, thisid, nextid)
    end

    # Construct the network

    regverts = Dict{UTF8String, ExVertex}()
    names = []
    sourceiis = Dict{Int64, Vector{Int64}}()
    waternet = empty_regnetwork()

    for fips in keys(edges)
        regverts[fips] = ExVertex(length(names)+1, fips)
        push!(names, fips)
        add_vertex!(waternet, regverts[fips])
    end

    for (fips, neighbors) in edges
        for neighbor in neighbors
            if !(neighbor in names)
                # Retroactive add
                regverts[neighbor] = ExVertex(length(names)+1, neighbor)
                push!(names, neighbor)
                add_vertex!(waternet, regverts[neighbor])
            end
            add_edge!(waternet, regverts[fips], regverts[neighbor])
        end
        sourceiis[indexin([fips], names)[1]] = indexin(neighbors, names)
    end

    serialize(open("../data/waternet.jld", "w"), waternet)
    serialize(open("../data/watervertices.jld", "w"), regverts)
    serialize(open("../data/watersources.jld", "w"), sourceiis)
end

# Prepare the model

numcounties = 3155
numedges = num_edges(waternet)
numsteps = 1 #86

function newmodel(ns)
    global numsteps = ns

    m = Model(MyNumeric)

    setindex(m, :time, collect(2015:2015+numsteps-1))
    setindex(m, :regions, names)
    setindex(m, :edges, collect(1:numedges))

    return m
end
