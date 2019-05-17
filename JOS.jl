import Base
#structs definition
struct Metaclass
    name::Symbol
    superclass::Vector{Metaclass}
    parameters::Vector
end

struct Class
    class::Metaclass
    parametersvalue::Dict{Any,Any}
end

struct SpecializedMethod
    name::Symbol
    args::Vector{Type}
    nativefunction
end

struct GenericFunction
    name::Symbol
    args::Vector{Symbol}
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
(f::SpecializedMethod)(args...) = f.nativefunction(args...)
#end of examples from class

#array with all generic functions
gen_functions = GenericFunction[]

#array with all  Specialized Method
specialized_methods= SpecializedMethod[]

function Base.getproperty(obj::Class,sym::Symbol)
    result = get_slot(obj,sym)
    if isa(result,Number)
        getfield(obj,:parametersvalue)[sym]
    else
        return result
    end
end

function Base.setproperty!(obj::Class,sym::Symbol,val::Any)
    set_slot!(obj,sym,val)
end

# function Base.setproperty!(obj::Class,sym::Symbol,)
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
#check if param exist on super
function check_param_super(param,super)
    for i in super
        if param == i 
            return true
        end
    end
    return false
end

function verifypairs(class,pairs)
    super = get_super_classe(class)
    param = Dict()
    for i in pairs
        if (isa(i,Pair))
            if (check_param_super(i.first,super))
                param[i.first] = i.second
            end
             
        end
    end
    return param
end

function make_instance(name::Metaclass, x...)
    param = verifypairs(name,x)
    object = Class(name,param)
    return object
end

function get_slot(name::Class, slot::Symbol)
    found = false 
    unbound = false
    result = nothing
    for par in getfield(getfield(name,:class),:parameters)
        for (k,v) in getfield(name,:parametersvalue) 
            if k == par && k == slot
                result = getfield(name,:parametersvalue)[slot] 
            elseif k != par && par == slot
                unbound = true
            end
        end
    end
    if isnothing(result) && !unbound 
        error("ERROR: Slot $(slot) is missing\n...")
    else
        if isa(result,Number)
            found = true
            return result
        else
            found = true
            unbound= true 
            error("ERROR: Slot $(slot) is unbound\n...")
        end
    end
end

function set_slot!(name::Class, slot::Symbol, value)
    for (k,v) in getfield(name,:parametersvalue)
        if (k == slot)
            getfield(name,:parametersvalue)[slot] = value 
        end
    end
    #=n = 1=#
    # for i in name.parametersvalue
        # if i[1] == slot
            # println("Contem")
            # #dump(name.parametersvalue)
            # deleteat!(name.parametersvalue, n)
            # push!(name.parametersvalue, slot=>value)            
            # return
        # end
        # n += 1
    #=end=#
    #error("Slot ", slot, " is missing")
end
#end of functions

#macros functions
function make_generic(name::Symbol,params)
    spe_methods = SpecializedMethod[]
    
    println("make_generic function")

    object = GenericFunction(name,params,spe_methods)
    push!(gen_functions,object)
end

function make_method(name::Symbol, args::Vector, functionality)
    #get an array with just the types
    argstype::Vector{Type} = []
    for i in args
        println(i)
        push!(argstype, typeof(i))
    end

    #look for the generic function
    for i in gen_functions
        if i.name == name
            if length(args) == length(i.args)
                func = SpecializedMethod(name, argstype, functionality)
                push!(specialized_methods, func) 
                return func
            else
                error("Different number of arguments from generic function") 
            end
        end
    end
    error("Generic function not defined")
end
#end of macro functions

#macros
macro defclass(name, superclass, slotnames...)
    return :( $(esc(name)) = make_class(($(esc(QuoteNode(name)))), $superclass, $slotnames))
end

#create generic method
macro defgeneric(x)
    dump(x)
    name = x.args[1]
    dump(name)

    args = []
    
    for i = 2:length(x.args)
        push!(args, x.args[i])
    end

    dump(args)

    return :( make_generic($(QuoteNode(name)), $args))
end

macro defmethod(x)
    println("begin macro")
    dump(x)
    
    name = x.args[1].args[1]

    args = []
    args_aux = []

    for i = 2:length(x.args[1].args)
        push!(args, x.args[1].args[i].args[2])
        push!(args_aux, x.args[1].args[i].args[1])
    end
    
    #body = Expr(:quote, x.args[2].args[2])
    body = x.args[2].args[2]

    println("Body:")
    @show body
    
    #println(Meta.parse(body))
    #println("eval: ", eval(body))
    #functionality = x.args[2].args[2]

    b = args -> body

    tuple = (args_aux...,)

    dump(tuple)

    return :($(esc(name)) = make_method($(QuoteNode(name)), $args, ($(args_aux...),) -> $body))
end
#end of macros
@macroexpand @defmethod foo(c1::C1) = 2 * 2
