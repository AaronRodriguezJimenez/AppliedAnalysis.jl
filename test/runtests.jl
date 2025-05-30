#=
 USAGE: 
 julia> ]
(MyFirstPackage) pkg> test

=#
using Test
using MyFirstPackage

@test greet() == nothing # greet() imprime pero no retorna nada

@test add_numbers(2, 3) == 5
@test add_numbers(-1,1) == 0

@test multiply_arrays([1,2], [3,4]) == [3,8]

# TESTS FOR MODULE MathTools
@testset "MathTools tests" begin
    using MyFirstPackage.MathTools

    @test factorial_iter(5) == 120
    @test isapprox(approx_derivative(sin, 0.0), cos(0.0); atol=1e-5)
    @test isapprox(integrate_trapezoid(x -> x^2, 0.0, 1.0, 100), 1/3; atol=1e-3)
  #  roots = solve_quadratic(1.0, 2.0, 1.0)
  #  @test sort(roots) ≈ [1.0, -1.0]
end