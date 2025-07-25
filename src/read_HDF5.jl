using HDF5

function to_pauli_string(term::String, nqubits::Int)
    result = fill('I', nqubits)

    isempty(strip(term)) && return join(result)

    for m in eachmatch(r"([XYZ])(\d+)", term)
        pauli = m.captures[1][1]  # Get first character as Char
        idx = parse(Int, m.captures[2])
        result[idx + 1] = pauli  # Julia uses 1-based indexing
    end

    return join(result)
end



fid=h5open("FH_D-1.hdf5","r")

dset = fid["/fh-graph-1D-grid-pbc-qubitnodes_Lx-6_U-2_enc-jw"]


println("the dataset: t", typeof(dset))

data=read(dset)
print(dset)
println("data is:")
println(typeof(data))

labels = String[]
coeffs = ComplexF64[]

pattern = r"\(([^)]+)\)\s*\[([^\]]*)\]"
matches = collect(eachmatch(pattern, data))

for m in matches
    coeff_str = m.captures[1]
    term_str = m.captures[2]
    println(m)
    #println(coeff_str, term_str)
    coeff = parse(ComplexF64, strip(coeff_str))
    term = strip(term_str)
    push!(coeffs, coeff)
    push!(labels, term)

end

println(labels)
println(coeffs)

nqubits = 12
formatted = [to_pauli_string(term, nqubits) for term in labels]

println(typeof(formatted))
for pauli in formatted
    println(pauli)
end


close(fid)