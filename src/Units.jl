module Units
export units
# This package contains some units for convenient global conversion
# Length
m       = 1.
km      = 1e3

# Time
s       = 1.
min     = 60.
hr      = 360.
day     = 86400.
year    = 365.25*day

# Mass
kg      = 1.
g       = 1e-3
lbm     = 0.4535924
slug    = 32.17405*lbm

# Collecting and exporting data
unitnames = (
    :m, :km,
    :s, :min, :hr, :day, :year,
    :kg, :g, :lbm, :slug
)
units = NamedTuple{unitnames}(eval.(unitnames))
end