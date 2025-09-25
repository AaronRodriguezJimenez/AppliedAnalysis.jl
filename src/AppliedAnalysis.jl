#=  This is the main module of the package
USAGE Instructions
1.-  Initialize REPL
2.- type ], then dev ., then activate . this will declare that you are developing this MyFirstPackage
3.- then in julia> type using Revise and using MyFirstPackage
This will allow you to have access to whateve you define in the module
don't forget to save all changes. If there are non declaration errors,
restart the REPL and repeat steps 2 and 3.

If nothing works, try to rease data from cache:
In the bash terminal: rm -rf ~/.julia/compiled/v1.11/MyFirstPackage
And restart everything.
=# 

module AppliedAnalysis

include("MathTools.jl") # Include submodules
using .MathTools  # Bring submodules into scope
using Plots

export greet, plot_xy, add_numbers, multiply_arrays
export factorial_iter, approx_derivative, integrate_trapezoid, solve_quadratic


""" Print a greeting message """
greet() = print("Hello guys this is AppliedAnalysis.jl")

""" Plot x vs y """
function plot_xy(x::AbstractVector, y::AbstractVector)
    plot(x, y, label="Test plot")
end

""" Add two numbers """
add_numbers(a::Number, b::Number) = a+b

""" Multiply each element of array A by array B """
function multiply_arrays(A::AbstractVector, B::AbstractVector)
    return A.*B
end


end # module MyFirstPackage
