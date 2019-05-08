#structs definition
struct Metalass
    name::Symbol
    superclass::Vector{Symbol}
    parameters::Vector
end

struct Class
    class::Metaclass
    parametersvalue::Vector
end

struct IntrospectableFunction
    name
    args
    body
    nativefunction
end
#end of structs definition

#examples from class
square = IntrospectableFunction(:square,:(x,), :(x*x), x->x*x)

(f::IntrospectableFunction)(args...) = f.nativefunction(args...)
#end of examples from class

#functions
function make_class(name::Symbol, superclass::Vector, slots::Vector{Symbol})
   
    return
end

function make_instance(name::String, x...)

end

function get_slot(name::String, slot::Symbol)

end

function set_slot!(name::String, slot::Symbol, value)

end
#end of functions

#macros
macro defclass(name, superclass, slotnames)
    
end

macro defgeneric(name::String)

end

macro defmethod(name)

end
#end of macros