include("JOS.jl")

C1 = make_class(:C1, [], [:a, :b, :c])

C2 = make_class(:C2, [C1],[:d])
c1 = make_instance(C1, :a=>2,:b=>3)
c2 = make_instance(C2,:a=>3,:d=>6)
#dump(c2)
#dump(c2.parametersvalue)
set_slot!(c2,:d,4)
# dump(:(Meta.parse("c2.d")))

#:((f::Class).(x)) = get_slot(:f, :x)
#(f::Expr)(args...) = get_slot(args...)
# (Expr()) = get_slot(:a, :b)

# dump(:(c2.class))

# c2.d
@defclass(C3, [C1,C2], d,e,i)
@defclass(C4, [C1,C3], d,e,i)

#get_slot(c2,:a)
#get_slot(c2,:b)

#println("After get slot\n")
#set_slot!(c1, :f, 2)
#@defgeneric foo(c)=#
#@defmethod foo(c1::R1) = 1

