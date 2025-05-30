#=
 USAGE: 
 julia> ]
(MyFirstPackage) pkg> test

=#
using Test
using MyFirstPackage

@test greet() == nothing # greet() imprime pero no retorna nada
@test plot_xy(1:10, rand(10)) == nothing