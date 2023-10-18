module Units
export init_units, get_units
# This package contains some units for convenient global conversion
# Initializing dictionary containing single-dimension units
const un = Dict{Symbol, Dict{Symbol, Float64}}()

# Length
un[:length] = Dict{Symbol, Float64}()
un[:length][:m]     = 1.
un[:length][:km]    = 1e3
un[:length][:cm]    = 1e-2
un[:length][:mm]    = 1e-3
un[:length][:in]    = 2.54*un[:length][:cm]
un[:length][:ft]    = 12.0*un[:length][:in]
un[:length][:yd]    = 3.0*un[:length][:ft]
un[:length][:mi]    = 5280.0*un[:length][:ft]
un[:length][:nmi]   = 1852.0

# Time
un[:time] = Dict{Symbol, Float64}()
un[:time][:s]       = 1.
un[:time][:min]     = 60.
un[:time][:hr]      = 3600.
un[:time][:day]     = 86400.
un[:time][:year]    = 365.25*un[:time][:day]

# Mass
un[:mass] = Dict{Symbol, Float64}()
un[:mass][:kg]      = 1.
un[:mass][:g]       = 1e-3
un[:mass][:lbm]     = 0.4535924
un[:mass][:slug]    = 32.17405*un[:mass][:lbm]

# Force
force = Dict{Symbol, Float64}()
force[:N]           = 1.
force[:kN]          = 1e3
force[:lbf]         = un[:mass][:slug] * un[:length][:ft]

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
    # Convert force units to be compatible with base units
    base_force = un[:mass][Symbol(mass)] * un[:length][Symbol(length)] / un[:time][Symbol(time)]^2
    for key ∈ eachindex(force)
        append!(units, [key=>force[key] / base_force])
    end

    NamedTuple(units)
end

# Loads units from Main if available. Otherwise, loads the base version of init_units
function get_units()
    if isdefined(Main, :un)
        return Main.un
    else
        return init_units()
    end
end

end