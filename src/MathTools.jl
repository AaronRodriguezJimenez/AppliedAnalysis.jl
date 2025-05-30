#= This submodule handles more complex maths
   MAY 2025:
   - Factorial (recursive or iterative)
   - Numerical Integration
   - Basic derivative approximation
   - Quadratic equation solver
=#

module MathTools

export factorial_iter
export approx_derivative
export integrate_trapezoid
export solve_quadratic

""" Iterative Factorial """
function factorial_iter(n::Integer)
    n < 0 && throw(ArgumentError("Negative Factorial is not Defined"))
    prod(1:n)
end

""" Approximate derivative using finite differences """
function approx_derivative(f::Function, x::Float64; h=1e-6)
    return (f(x + h) - f(x-h)) / (2h)
end

""" Numerical integration using the integrate_trapezoid rule """
function integrate_trapezoid(f::Function, a::Float64, b::Float64, n::Int=100)
    h = (b - a)/n
    s = 0.5 * (f(a) + f(b))
    for i in 1:n-1
        s += f(a + i * h)
    end
    return h * s
end

""" Solve quadratic equation ax^2 +bx +c = 0 """
function solve_quadratic(a::Float64, b::Float64, c::Float64)
    D = b^2 -4a*c
    if D < 0
        return Complex{Float64}[(-b + sqrt(Complex(D)))/(2a), (-b - sqrt(Complex(D)))/(2a)]
    else
        return [(-b + sqrt(Complex(D)))/(2a), (-b - sqrt(Complex(D)))/(2a)]
    end
end

end #module