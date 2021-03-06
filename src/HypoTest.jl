module HypoTest

import Distributions
import PyPlot
import Statistics

include("histdata.jl")
include("momentestim.jl")
include("disttest.jl")
include("othertest.jl")

struct TestResult
	H0::String
	H1::String
	estim::Float64
	critical::Float64
	alpha::Float64
end

export meanconfid, stdconfid
export histfit
export testhist
export corrp


end #module
