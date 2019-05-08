#structs definition
struct Metaclass
    name::Symbol
    superclass::Vector{Metaclass}
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
    object = Metaclass(name, superclass, slots)
    return object
end

function make_instance(name::Metaclass, x...)
    for i in x
        println(i)
    end
    object = Class(name, [])
    return object
end

function get_slot(name::Class, slot::Symbol)

end

function set_slot!(name::Class, slot::Symbol, value)
    for i in name.class.parameters
        if i == slot
            println("Contem")
            return
        end
    end
    println("ERROR: Slot ", slot, " is missing")
    #error("Slot ", slot, " is missing")
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