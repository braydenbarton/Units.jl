module Units
export init_units, Unit, UnitNumber
# This package contains some units for convenient global conversion
# Initializing dictionary containing single-dimension units

"""
# Parameters
- `name::Symbol`: The typical representation of the unit, i.e. :km or :in
- `value::Real`: The value of the unit relative to base SI units, i.e. 1 for a meter
- `priority::Int64`: The hierarchy placement of this unit for conversions. When numbers with different units are added,
    the unit with a higher value is used.
- `length::Real`: The length dimension of the unit, i.e. 2 for kg-m^2/s^2
- `mass::Real`: The mass dimension of the unit, i.e. 1 for kg-m^2/s^2
- `time::Real`: The time dimension of the unit, i.e. -2 for kg-m^2/s^2
"""
struct Unit
    name::Symbol
    value::Real
    priority::Int64
    length::Real
    mass::Real
    time::Real
end
# Returns the dimensions of the unit as a vector
function unit_dims(unit::Unit)
    [unit.length, unit.mass, unit.time]
end

# Determines the unit created by multiplying two units together
function Base.:*(unit1::Unit, unit2::Unit)
    return Unit(:none, unit1.value*unit2.value, typemin(Int64), (unit_dims(unit1)+unit_dims(unit2))...)
end

# Determines the unit created by dividing two units
function Base.:/(unit1::Unit, unit2::Unit)
    return Unit(:none, unit1.value/unit2.value, typemin(Int64), (unit_dims(unit1)-unit_dims(unit2))...)
end

# Determines the unit created by exponentiation
function Base.:^(unit::Unit, power::Real)
    return Unit(:none, unit.value^power, typemin(Int64), (unit_dims(unit)*power)...)
end

struct UnitNumber{T} <: T where {T<:Number}
    value::T
    unit::Unit
end

function Base.:+(num1::UnitNumber, num2::UnitNumber)
    if num1.unit == num2.unit
        return UnitNumber(num1.value + num2.value, num1.unit)
    elseif unit_dims(num1.unit) == unit_dims(num2.unit)
        if num1.unit.priority < num2.unit.priority  # Determine which number has a higher unit priority
            num1, num2 = num2, num1
        end
        # Convert second number to units of first number, add, and create new UnitNumber
        return UnitNumber(num1.value + num2.value * num2.unit.value / num1.unit.value, num1.unit)
    else
        throw(ArgumentError("Values have mismatched unit dimensions with $unit_dims(num1.unit) and 
        $unit_dims(num1.unit)"))
    end
end

Base.:-(num1::UnitNumber, num2::UnitNumber) = num1 + UnitNumber(-num2.value, num2.unit)
Base.:-(num::UnitNumber) = UnitNumber(-num.value, num.unit)
Base.:*(num1::UnitNumber, num2::UnitNumber) = UnitNumber(num1.value*num2.value, num1.unit*num2.unit)
Base.:/(num1::UnitNumber, num2::UnitNumber) = UnitNumber(num1.value/num2.value, num1.unit/num2.unit)
Base.:^(num::UnitNumber, power::Real) = UnitNumber(num.value^power, num.unit^power)
Base.:^(num::UnitNumber, power::Integer) = UnitNumber(num.value^power, num.unit^power)
Base.sqrt(num::UnitNumber) = num^(1/2)
Base.cbrt(num::UnitNumber) = num^(1/3)

Base.promote_rule(::Type{UnitNumber{T}}, ::Type{Float64}) where T<:Number = 
(x) -> UnitNumber(x, Unit(:none, 1, typemin(Int64), 0, 0, 0,))

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
un[:time][:hr]      = 360.
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

end