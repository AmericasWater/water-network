# The Water Network component
#
# Determines how flows added and removed from the network propogate through.

using Mimi

@defcomp WaterNetwork begin
    gauges = Index()

    # External
    added = Parameter(index=[gauges, time]) # Water added at node
    removed = Parameter(index=[gauges, time]) # Water removed from node

    inflows = Variable(index=[gauges, time]) # Sum of upstream outflows
    outflows = Variable(index=[gauges, time]) # inflow + added - removed
end

"""
Compute the inflows and outflows at each node
"""
function timestep(c::WaterNetwork, tt::Int)
    v = c.Variables
    p = c.Parameters
    d = c.Dimensions

    for rr in d.gauges
        gauge = m.indices_values[rr]
        allflow = 0.
        for upstream in out_edges(wateridverts[gauge], waternet)
            allflow += v.outflows[vertex_index(upstream), tt]
        end
        v.inflows[rr, tt] = allflow

        v.outflows[rr, tt] = allflow + added[rr, tt] - removed[rr, tt]
    end
end
