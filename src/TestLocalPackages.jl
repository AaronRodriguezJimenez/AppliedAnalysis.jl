# based on 1d_n6_bfs.jl
using Pkg
Pkg.activate("/home/aaronrodriguez/VisualStudioProjects/MyFirstPackage.jl")
Pkg.instantiate()
Pkg.develop(path="/home/aaronrodriguez/VisualStudioProjects/PauliOperators.jl")
Pkg.develop(path="/home/aaronrodriguez/VisualStudioProjects/UnitaryPrunning.git")

println("Example usage of a local package:")
using PauliOperators
using UnitaryPrunning
using Distributed
using Statistics
using Printf
using LinearAlgebra
using SharedArrays

# Example usage PauliOperators
Pbasis = PauliBasis("XYZ")
print(Pbasis)
w = PauliOperators.simple_majorana_weight(Pbasis)
println("Simple Majorana weight is: ", w)

w_two = PauliOperators.pauli_to_majorana_occupation(Pbasis)
println("Majorna weight ver 2 is: ", w_two)

function run(; N=6, k=10, thresh=1e-3)
   
    ket = KetBitString(N, 0) 
    o = Pauli(N, Z=[1])

    angles = [] 
    e = [] 
    
    # for i in [(i-1)*2 for i in 1:9]
    for i in 0:16
        α = i * π / 32 
        generators, parameters = UnitaryPruning.get_unitary_sequence_1D(o, α=α, k=k)
        
        ei , nops = UnitaryPruning.bfs_evolution(generators, parameters, PauliSum(o), ket, thresh=thresh)
      
        push!(e, ei)
        push!(angles, α)
        @printf(" α: %6.4f e: %12.8f+%12.8fi nops: %i\n", α, real(ei), imag(ei), maximum(nops))
        
    end
    
    plot(angles, real(e), marker = :circle)
    xlabel!("Angle")
#    ylabel!("expectation value")
#    title!{X_{13,29,31}, Y_{9,30}, Z_{8,12,17,28,32}}
    savefig("plot_1d_n6_bfs.pdf")
    return e
end

@time v,e = run(k=10, N=6, thresh=.5e-4);