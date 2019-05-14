include("JOS.jl")

C1 = make_class(:C1, [], [:a, :b, :c])

C2 = make_class(:C2, [C1],[:d])
c1 = make_instance(C1, :a=>2,:b=>3)
c2 = make_instance(C2,:a=>3,:d=>6)
#dump(c2)
dump(c2.parametersvalue)
set_slot!(c2,:d,4)
dump(c2.parametersvalue)

"""
get_slot(c2,:a)
#set_slot!(c1, :f, 2)
@defgeneric foo(c)
@defmethod foo(c1::R1) = 1
"""