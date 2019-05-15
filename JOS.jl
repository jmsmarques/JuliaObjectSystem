#structs definition
struct Metaclass
    name::Symbol
    superclass::Vector{Metaclass}
    parameters::Vector
end

mutable struct Class
    class::Metaclass
    parametersvalue::Vector
end

struct SpecializedMethod
    name::Symbol
    args::Vector{Symbol}
    body::Expr
    nativefunction
end


struct GenericFunction
    name::Symbol
    args::Vector{Symbol}
    type::Type
    methods::Vector{SpecializedMethod}
end
#example form class
struct IntrospectableFunction
    name
    args
    body
    nativefunction
end
square = IntrospectableFunction(:square,:(x,), :(x*x), x->x*x)

(f::IntrospectableFunction)(args...) = f.nativefunction(args...)
#end of examples from class

#array with all generic functions
gen_functions = GenericFunction[]

#array with all  Specialized Method
specialized_methods= SpecializedMethod[]

#end of structs definition

#functions
function make_class(name::Symbol, superclass::Vector, slots::Vector{Symbol})
    object = Metaclass(name, superclass, slots)
    return object
end

function make_class(name::Symbol, superclass::Vector, slots::Tuple{Symbol})
    params::Vector{Symbol} = []

    for i in slots
        push!(params, i)
    end

    object = Metaclass(name, superclass, params)
    return object
end

function get_super_classe(class)
    super_params = Symbol[]
    for param in class.parameters
        push!(super_params,param)
    end
    for super in class.superclass
        for para in super.parameters
            push!(super_params,para)
        end
    end
    return super_params
end

function check_param_super(param,super)
    println("Checking $(param) with $(super)")
    for i in super
        if param == i 
            return true
        end
    end
    return false
end


function verifypairs(class,pairs)
    super = get_super_classe(class)
    println("dump(super): ")
    dump(super)
    param = Pair[]
    println("Pairs")
    dump(pairs)
    for i in pairs
        if (isa(i,Pair))
            println("IS PAIR")
            if (check_param_super(i.first,super))
                push!(param,i)
                println("Added $(i)")
            end
             
        end
    end
    return param
end

function make_instance(name::Metaclass, x...)
    param = verifypairs(name,x)
    object = Class(name,param,)
    return object
end

function get_slot(name::Class, slot::Symbol)
    found = false 
    is_null = true
    println("INSIDE GET SLOT")
    dump(name.parametersvalue)
    for i in name.parametersvalue
        if (i.first == slot)
            println(i.second)
            println("Type: ",typeof(i.second))
            println("indside")
            found = true
            break
        end
    end
    if !found
        println("ERROR: Slot $(slot) is missing\n...")
    end
end

function set_slot!(name::Class, slot::Symbol, value)
    n = 1
    for i in name.parametersvalue
        if i[1] == slot
            println("Contem")
            #dump(name.parametersvalue)
            deleteat!(name.parametersvalue, n)
            push!(name.parametersvalue, slot=>value)            
            return
        end
        n += 1
    end
    println("ERROR: Slot ", slot, " is missing")
    #error("Slot ", slot, " is missing")
end

function make_generic(name::Symbol,params)
    args = Symbol[]
    spe_methods = SpecializedMethod[]
    for i in x.args
        if i != 1 
            push!(args,i)
        end 
    end
    object = GenericFunction(name,args,spe_methods)
    push!(gen_functions,object)
end

#end of functions

#macros
macro defclass(name, superclass, slotnames...)

    show(name);println()
    show(superclass);println()
    show(slotnames);println()

    return :( $(esc(name)) = make_class(($(esc(QuoteNode(name)))), $superclass, $slotnames))
end

#create generic method
macro defgeneric(x)
    name = x.args[1]
    make_generic(name,x.args)
    return
end

macro defmethod(x)
    methodname = x.args[1].args[1] 
    dump(x)
    for gen in gen_functions
        if gen.name == methodName
            println("Mehtod name ",methodName)
            # object = SpecializedMethod()
        end
    end
end
#end of macros
