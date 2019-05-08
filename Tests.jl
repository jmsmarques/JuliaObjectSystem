include("JOS.jl")

C1 = make_class(:C1, [], [:a, :b, :c])

c1 = make_instance(C1)

set_slot!(c1, :f, 2)