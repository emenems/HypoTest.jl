"""
	prepdata(x[, y])
Remove NaNs. Will return reduced vector if any NaN in input data
"""
function prepdata(x::Vector{Float64})::Vector{Float64}
	return any(isnan.(x)) ? filter(!isnan,x) : copy(x)
end

function prepdata(x::Vector{Float64},y::Vector{Float64})
	m = isnan.(x.+y);
	if any(m)
		return x[.!m],y[.!m]
	else
		return copy(x),copy(y)
	end
end

"""
	histfit(x,d;bins_method="sqrt",pdf_points,new_fig)
Plot (normed) histogram superimposed by fitted distribution

**Input**
* `x`: input samples
* `d`: distribution (e.g. Distributions.Normal())
* `bins_method`: method for number of bins (see `?histbins`)
* `pdf_points`: number of points used to plot PDF
* `new_fig`: plot to new figure

**Example**
```
d = Distributions.Normal(1,3);
histfit(Distributions.rand(d,1000),d)
```
"""
function histfit(x::Vector{Float64},d;bins_method="Rice",pdf_points::Int=100,new_fig=true)
	nb = histbins(x,method=bins_method);
	new_fig ? PyPlot.figure() : nothing
	PyPlot.plt[:hist](x,nb,density=true);
	PyPlot.plot(range(nb[1],stop=nb[end],length=pdf_points),
		Distributions.pdf.(d,range(nb[1],stop=nb[end],length=pdf_points)),"r-",
		linewidth=2);
end

"""
	histbins(x;method)
Compute number of bins and create bin vector using various methods
See https://en.wikipedia.org/wiki/Histogram#Number_of_bins_and_width

**Input**
* datain: input vector
* method = "Scott" | "Rice" | "sqrt" otherwise (range/n) | set to integer with required nr.of bins

**Output**
* vector for bin intervals (start/stop) => length(output)-1 = number of bins

**Example**
```
b = histbins(rand(100),"Scott");
```
"""
function histbins(datain;method="Rice")::Vector{Float64}
	xi = prepdata(datain);
	data_range = extrema(xi);
	n = length(xi);
	if method=="Scott"
		nb = 3.5*Distributions.std(xi)/(n^(1/3));
	elseif method == "Rice"
		nb = 2.0*n^(1/3);
	elseif method == "sqrt"
		nb = sqrt(n);
	elseif eltype(method) == Int
		nb = method;
	else # default
		nb = (data_range[2]-data_range[1])*0.5;
	end
	return collect(range(data_range[1],stop=data_range[2],length=trunc(Int,round(nb))+1));
end

"""
	theobins(d,b)
Count theoretical number of occurances in given bins (`b`) for given
distribution(`d`) using input data (`x`).

**Output**
* bc: expected number of occurences in each bin. Float to avoid summing issues (`sum(bc)==n`)

**Example**
d = Distributions.Normal()
b = collect(-3.:1:3);
n = 100;
bc = HypoTest.theobins(d,b,n);
"""
function theobins(d,b::Vector{Float64},n::Int)::Vector{Float64}
	bc = zeros(Float64,length(b)-1);
	for i in 1:length(bc)
		bc[i] = n*(Distributions.cdf(d,b[i+1])-Distributions.cdf(d,b[i]));
	end
	return bc
end

"""
Count number of occurrences within given bins/intervals (`b`) using input
vector (`x`)

**Output**
* bc: bin counts

**Example**
x = collect(1.:1.:10);
bc = HypoTest.countbins(x,[0.,1.,9.,10.]);
# same as PyPlot.plt[:hist](x,[0.,1.,9.,10.])
"""
function countbins(x::Vector{Float64},b::Vector{Float64})::Vector{Int}
	bc = zeros(Int,length(b)-1);
	for i = 1:length(bc)
		bc[i] = i<length(bc) ? length(findall(y-> y .>= b[i] && y .< b[i+1],x)) :
						   length(findall(y-> y .>= b[i] && y .<= b[i+1],x));
	end
	return bc
end
