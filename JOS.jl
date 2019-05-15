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

struct IntrospectableFunction
    name
    args
    body
    nativefunction
end



#array with all generic functions
gen_functions = GenericFunction[]

#array with all  Specialized Method
specialized_methods= SpecializedMethod[]

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

function make_class(name::Symbol, superclass::Vector, slots::Tuple{Symbol})
    params::Vector{Symbol} = []

    for i in slots
        push!(params, i)
    end

    object = Metaclass(name, superclass, params)
    return object
end

function verifypairs(pairs)
    param = Pair[]
    for i in pairs
        if (isa(i,Pair))
            println("Added $(i)")
            push!(param,i) 
        end
    end
    return param
end

function make_instance(name::Metaclass, x...)
    for i in x
        println(i)
    end
    param = verifypairs(x)
    object = Class(name, param)
    return object
end

function get_slot(name::Class, slot::Symbol)
    found = false 
    for i in name.parametersvalue
        if (i.first == slot)
            println(i.second)
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
#end of functions

#macros functions

#end of macro functions


#macros
macro defclass(name, superclass, slotnames...)
    return :( $(esc(name)) = make_class(($(esc(QuoteNode(name)))), $superclass, $slotnames))
end

#create generic method
macro defgeneric(x)
    dump(x)
    name = x.args[1]
    args = Symbol[]
    spe_methods = SpecializedMethod[]
    aux_var = 1
    for i in x.args
       if aux_var != 1 
           push!(args,i)
       end 
       aux_var = aux_var + 1
   end
   object = GenericFunction(name,args,spe_methods)
   push!(gen_functions,object)
   
   return object
end

macro defmethod(x)
    println("Inside def method macro")
    methodname = x.args[1].args[1] 
    println(methodname)
    
    dump(x)

    object = SpecializedMethod(x.args[1].args[2].args[1], [], :(x.args[2].args[2]), x.args[2].args[2])
    
    dump(object)

    object.nativefunction

    return :(x.args[2].args[2])
    # for gen in gen_functions
    #     if gen.name == methodName
    #         println("Method name ",methodName)

    #         # object = SpecializedMethod()
    #     end
    # end


end
#end of macros
