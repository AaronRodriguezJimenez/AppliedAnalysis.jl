using Plots
using IterTools

# Define a basic PauliTerm type to mimic OpenFermion's QubitOperator
struct PauliString
    ops::Dict{Int, Char} #Map from qubit index to Pauli QubitOperator
    coeff::Float64
end

"""
 Generates all possible Pauli strings for a given lenght N
"""
function generate_all_pauli_strings(N::Int)
    paulis = ['I', 'X', 'Y', 'Z']
    all_strings = PauliString[]  # Initialize properly typed array
    count = 0
    for term in product(fill(paulis, N)...)
        ops = Dict{Int, Char}()
        for (idx, p) in enumerate(term)
            if p != 'I'
                ops[idx - 1] = p  # Match OpenFermion’s 0-based indexing
            end
        end
        push!(all_strings, PauliString(ops, 1.0))
        count += 1
    end

    return all_strings, count
end

# Custom pretty print
function Base.show(io::IO, ps::PauliString)
    if isempty(ps.ops)
        print(io, "$(ps.coeff)*I")
    else
        sorted_ops = sort(collect(ps.ops))
        ops_str = join(["$op$idx" for (idx, op) in sorted_ops], " ")
        print(io, "$(ps.coeff)*$ops_str")
    end
end

# Compute Pauli weight
function get_pauli_weight(pauli_str::AbstractString)
    count(c -> c in ['X','Y','Z'], pauli_str)
end

#                                                         #
# Functions to create Majorana strings from Pauli strings  #
#
function get_majorana_vector_for_Z_padded_XY(pauli_str::AbstractString)
    N = length(pauli_str)
    vec_len = 2 * N
    vec = zeros(Int, vec_len)

    for i in 1:N
        if pauli_str[i] in ['X', 'Y']
            num_Z = i - 1  # Julia is 1-based, but logic is 0-based
            if pauli_str[i] == 'X'
                vec[2 * num_Z + 1] = 1  # Julia index: m_{2k+1}
            elseif pauli_str[i] == 'Y'
                vec[2 * num_Z + 2] = 1  # Julia index: m_{2k+2}
            end
            break
        end
    end

    return vec
end

function get_majorana_vector_for_Z_only(pauli_str::AbstractString)
    N = length(pauli_str)
    vec_len = 2 * N
    vec = zeros(Int, vec_len)
    z_idx = 0

    for i in 1:N
        p = pauli_str[i]
        if p == 'Z'
            vec[2 * z_idx + 1] = 1  # Julia index correction
            vec[2 * z_idx + 2] = 1
            z_idx += 1
        elseif p == 'I'
            z_idx += 1
        else
            error("Non-Z/I found in Z-only string at position $i: '$p'")
        end
    end

    return vec
end

"""
 Decompose full Pauli string into Majorana occupation vectors.

    For each X/Y, extract its Z-padded form AND the trailing Z-only shield.
    Also extract any standalone Z/I substrings.

    Returns:
        A list of occupation vectors to be XOR'ed into the full Majorana form.
"""
function decompose_to_direct_terms(pauli_str::AbstractString)
    N = length(pauli_str)
    vectors = Vector{Vector{Int}}()  # list of occupation vectors
    used_mask = falses(N)            # tracks used Zs

    # Step 1: global Z-only term (excluding shielded Zs)
    zi_str = join([pauli_str[j] == 'Z' && !used_mask[j] ? 'Z' : 'I' for j in 1:N])
    if occursin('Z', zi_str)
        push!(vectors, get_majorana_vector_for_Z_only(zi_str))
    end

    # Step 2 & 3: Handle X/Y terms
    for i in 1:N
        p = pauli_str[i]
        if p in ['X', 'Y']
            # ZX-like pattern
            pad = ['Z' for _ in 1:(i-1)]
            push!(pad, p)
            append!(pad, ['I' for _ in (i+1):N])
            zxi_str = join(pad)
            vec1 = get_majorana_vector_for_Z_padded_XY(zxi_str)
            push!(vectors, vec1)

            # trailing Z shield
            z_shield = [j != i && zxi_str[j] == 'Z' ? 'Z' : 'I' for j in 1:N]
            if 'Z' in z_shield
                for j in (i+1):N
                    if pauli_str[j] == 'Z'
                        used_mask[j] = true
                    end
                end
                z_only_str = join(z_shield)
                vec2 = get_majorana_vector_for_Z_only(z_only_str)
                push!(vectors, vec2)
            end
        end
    end

    return vectors
end

"""
 Bitwise XOR all majorana occupations: Is equivalent to get the vector associated with Majorana
"""
function combine_majorana_vectors(vectors::Vector{Vector{Int64}})
    result = zeros(Int, length(vectors[1]))
    for v in vectors
        result .= xor.(result, v)
    end
    return result
end

""" 
 Given an occupation vector, return the list of Majorana operators
"""
function get_majorana_operators_from_vector(vec::Vector{Int})
    return ["m$(i)" for (i, val) in enumerate(vec) if val == 1]
end


"""
  Main function for Pauli to Majorana conversion
"""
function pauli_to_majorana_occupation(pauli_str::AbstractString)
    if all(c -> c == 'I', pauli_str)
        return 0, String[]
    else
        vectors = decompose_to_direct_terms(pauli_str)
        result_vec = combine_majorana_vectors(vectors)
        #w = count_ones(result_vec)
        w = count(x -> x == 1, result_vec)
        return w, get_majorana_operators_from_vector(result_vec)
    end
end

#####################################################
# # #  Test run # # #
function main()
    # This block runs only when the file is executed directly
    println("Running as a script")

    N = 4
    threshold = 4 # for cases where the comparison needs
    n_lower = 0
    mw_list = Int[]
    pw_list = Int[]
    indx_lst = Int[]


    all_paulis, total_paulis = generate_all_pauli_strings(N)
    for ps in all_paulis
        println(ps)
    end

    println("Test weights")
    println("weight for IXYZ :", get_pauli_weight("IXYZ"))  # Output: 3
    println("weight for IIII", get_pauli_weight("IIII"))  # Output: 0
    
    for (i,op) in enumerate(all_paulis)
        # Extract the Pauli string from our custom example 
        pauli = Vector{Char}(fill('I', N))
        for (idx, p) in op.ops
            pauli[idx + 1] = p
        end
        pauli_str = join(pauli)

        majo_weight, majo_str = pauli_to_majorana_occupation(pauli_str)
        pauli_weight = get_pauli_weight(pauli_str)

        println("$(i): $pauli_str weight $pauli_weight ==> $majo_str with weight $majo_weight")

        if majo_weight < pauli_weight
            push!(mw_list, majo_weight)
            push!(pw_list, pauli_weight)
            push!(indx_lst, i)
            n_lower +=1
        end
    end

    println("Majorana monomials with weight lower than Paulis: $n_lower from $total_paulis total operators")

    # Plot the results
    bar_width = 0.35
    x = collect(1:length(indx_lst))  # ensure x is a Vector{Int}
    println("typeof(x) ",typeof(x))
    println("pw_list = ", pw_list, ", typeof(pw_list) = ", typeof(pw_list))
    println("mw_vals = ", mw_list, ", typeof(mw_list) = ", typeof(mw_list))


    x1 = [i - bar_width / 2 for i in x]
    x2 = [i + bar_width / 2 for i in x]

    bar(
    x1, pw_list,
    bar_width = bar_width,
    label = "Pauli Weight",
    color = :orange,
    xlabel = "Operator Index",
    ylabel = "Weight",
    title = "Comparison of Pauli and Majorana Weights",
    legend = :topright
    )

    bar!(
    x2, mw_list,
    bar_width=bar_width,
    label = "Majorana Weight",
    color = :gray
    )

    display(current())

    # # Show example cases
    println("Example case: YXXZZZ")
    println(pauli_to_majorana_occupation("YXXZZZ"))

    println("Example case: ZZ")
    println(pauli_to_majorana_occupation("ZZ"))

    println("Example case: IXXI")
    println(pauli_to_majorana_occupation("IXXI"))

    println("Example case: YZZY")
    println(pauli_to_majorana_occupation("YZZY"))
end



# Run main if this file is executed directly (scrip mode)
main()