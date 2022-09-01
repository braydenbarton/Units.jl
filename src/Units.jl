module Units
export init_units
# This package contains some units for convenient global conversion
# Initializing dictionary containing units
const un = Dict{Symbol, Dict{Symbol, Float64}}()

# Length
un[:length] = Dict{Symbol, Float64}()
un[:length][:m]     = 1.
un[:length][:km]    = 1e3

# Time
un[:time] = Dict{Symbol, Float64}()
un[:time][:s]       = 1.
un[:time][:min]     = 60.
un[:time][:hr]      = 360.
un[:time][:day]     = 86400.
un[:time][:year]    = 365.25*un[:time][:day]

# Mass
un[:mass] = Dict{Symbol, Float64}()
un[:mass][:kg]      = 1.
un[:mass][:g]       = 1e-3
un[:mass][:lbm]     = 0.4535924
un[:mass][:slug]    = 32.17405*un[:mass][:lbm]

# Converts all units to a given set of base units and returns them to the user
function init_units(; length::Union{String, Symbol}=:m, time::Union{String, Symbol}=:s, mass::Union{String, Symbol}=:kg)
    units = Pair{Symbol, Float64}[]
    baseunits = Dict([
        :length=>Symbol(length), 
        :time=>Symbol(time), 
        :mass=>Symbol(mass)
        ])
    for unittype ∈ eachindex(un)
        for key ∈ eachindex(un[unittype])
            append!(units, [key=>un[unittype][key]/un[unittype][baseunits[unittype]]])
        end
    end
    NamedTuple(units)
end

end