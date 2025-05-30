#=
 USAGE: 
 julia> ]
(MyFirstPackage) pkg> test

=#
using Test
using MyFirstPackage

@test greet() == nothing # greet() imprime pero no retorna nada