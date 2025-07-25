# Math excercises from: https://pythonjulia.blogspot.com/2022/03/100-julia-exercises-with-solutions.html

#- Import under a name
import LinearAlgebra as la
import LinearAlgebra
const la = LinearAlgebra

#Arrays in Julia are the most common method of representing a list of itmes
# They are ordered, mutable and can store items of the same type.

#- Create a zero vector of size 10 and type Int64
a =  zeros(Int64, 10)

#- How to find memory size of an array in bytes
sizeof(a)
println("Memory of array a in bytes:", length(a)*sizeof(eltype(a)))

#- Create a Int vector of size 10 but the fifth value which is 1 
a = zeros(Int, 10)
a[5] = 1
println("Create a Int vector of size 10")
println(a)

#- Create a vector with values ranging from 10 to 49
a = [10:49;]
println("Create a vector with values from 10 to 49")
println(a)
#a = collect(10:49)
#println(a)

#- Return the reverse of a vector (first element becomes last)
a[end:-1:1] #Faster
reverse(a)
#reverse!(a) #inplace
println("Reverse the vector")
println(a)

#- Create a 3x3 matrix with values ranging from 0 to 8
a = reshape(0:8,3,3)
println("Create a 3x3 matrix with values ranging from 0 to 8")
println(a)

#- Find indices of non-zero elements from [1,2,0,0,4,0]
findall(!isequal(0),a)
findall(!iszero, a)
findall(!=(0),a)
println("Find indices of non-zero elements from [1,2,0,0,4,0]")
println(!iszero, a)

#- Create a 3x3 identity matrix
a = la.I(3)
#a = Matrix(1.0I,3,3)
println("Create a 3x3 identity matrix")
println(a)

#- Example array of string
arr_str = ["one", "two", "three"] 

#- 2D Array
arr_2D = [1 2 3; 5 6 7; 8 9 10; 11 12 13]
arr_2D[2,3] # accessing to an element of the array

# Tupples: These are collections of items that cannot be modified. 
# unlike arrays, once a tuple is created, its size and contents 
# cannot be changed. Tuples are used when you want to operate on
# a fixed size collection, for example:
t = (1,2,3,"M",5,6) #tuple of integers
t[4] #Accessing to the element of the tuple

# Julia does not have a built-in linked list type