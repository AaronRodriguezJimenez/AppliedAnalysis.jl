#=  USAGE Instructions
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

module MyFirstPackage

using Plots
export greet
export plot_xy

""" GREETINGS """
greet() = print("Hello From Revise!")

function plot_xy(x::AbstractVector, y::AbstractVector)
    
    plot(x,y, label="Test plot")
end 

end # module MyFirstPackage
