using StatProfilerHTML
using TypedPolynomials
@polyvar x y z
@profilehtml (x + y + z)^120;