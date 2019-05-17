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
    parameters::Array
end

struct SpecializedMethod
    name::Symbol
    args::Vector
    nativefunction
end

struct GenericFunction
    name::Symbol
    args::Vector{Symbol}
    methods::Vector{SpecializedMethod}
end
#example form class

(f::GenericFunction)(args...) = run_generic_function(f, args...)

#end of examples from class

#array with all generic functions
gen_functions = GenericFunction[]

function Base.getproperty(obj::Class,sym::Symbol)
    result = get_slot(obj,sym)
    # println(result)
    if !isnothing(result)
        getfield(obj,:parametersvalue)[sym]
    else
        return result
    end
end

function Base.setproperty!(obj::Class,sym::Symbol,val::Any)
    set_slot!(obj,sym,val)
end

#functions
function make_class(name::Symbol, superclass::Vector, slots::Vector{Symbol})
    object = Metaclass(name, superclass, slots)
    return object
end

function make_class(name::Symbol, superclass::Vector, slots::Tuple)
    params::Vector{Symbol} = []

    for i in slots
        push!(params, i)
    end

    object = Metaclass(name, superclass, params)
    return object
end

function get_super_classe(class,super_params)
    # super_params = Symbol[]
    #dump(class)
    for superclass in class
        for param in superclass.parameters
            push!(super_params,param)
        end
        for superparam in superclass.superclass
            for metaparam in superparam.parameters
                push!(super_params,metaparam)
            end
        end
    end
    # return super_params
end


function get_parameters(class,params)
    for param in class
        push!(params,param)
    end
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

function verifypairs(class,pairs,paramnames)
    super_params = Symbol[]
    get_super_classe(class.superclass,super_params)
    get_parameters(class.parameters,super_params)
    #println("Super: ",super_params)
    paramnames = copy(super_params)
    #println("Param: ",paramnames)
    param = Dict() 
    for i in pairs
        if (isa(i,Pair))
            if (check_param_super(i.first,super_params))
                param[i.first] = i.second
            end
             
        end
    end
    return param,paramnames
end

function make_instance(name::Metaclass, x...)
    paramnames = Symbol[]
    paramvalue,paramnames = verifypairs(name,x,paramnames)
    #println(paramnames)
    object = Class(name,paramvalue,paramnames)
    return object
end

function get_slot(name::Class, slot::Symbol)
    found = false 
    unbound = false
    result = nothing
    for (k,v) in getfield(name,:parametersvalue) 
        if k == slot
            result = getfield(name,:parametersvalue)[slot] 
            if isnothing(result) == false
                return result
            else
                error("ERROR: Slot $(slot) is unbound\n...")
            end
        end
    end
    if isnothing(result)  
        error("ERROR: Slot $(slot) is missing\n...")
    end
end

function set_slot!(name::Class, slot::Symbol, value)
    for k in getfield(name,:parameters)
        if (k == slot)
            getfield(name,:parametersvalue)[slot] = value 
        end
    end
end
#end of functions

#macros functions
function make_generic(name::Symbol,params)
    spe_methods = SpecializedMethod[]
    
    # println("make_generic function")

    object = GenericFunction(name,params,spe_methods)
    push!(gen_functions,object)
    return object
end

function make_method(name::Symbol, args::Vector, functionality)
    #get an array with just the types
    argstype::Vector = []
    for i in args
        push!(argstype, i)
    end

    #look for the generic function
    for i in gen_functions
        if i.name == name
            if length(args) == length(i.args)
                push!(i.methods, SpecializedMethod(name, argstype, functionality)) 
                return 
            else
                error("Different number of arguments from generic function") 
            end
        end
    end
    error("Generic function not defined")
end

function run_generic_function(f::GenericFunction, args...)
    for i in f.methods
        if check_args(i, args...)
            println(i.nativefunction(args...))
        end
    end
end

function check_args(f::SpecializedMethod, fargs...)
    for i = 1:length(f.args)
        if Symbol(typeof(fargs[i])) == f.args[i]
            continue
        end
        return false
    end
    return true
end
#end of macro functions

#macros
macro defclass(name, superclass, slotnames...)
    return :( $(esc(name)) = make_class(($(esc(QuoteNode(name)))), $superclass, $slotnames))
end

#create generic method
macro defgeneric(x)
    # dump(x)
    name = x.args[1]
    # dump(name)

    args = []
    
    for i = 2:length(x.args)
        push!(args, x.args[i])
    end

    # dump(args)

    return :($(esc(name)) = make_generic($(QuoteNode(name)), $args))
end

macro defmethod(x)
    name = x.args[1].args[1]

    args = []
    args_aux = []

    for i = 2:length(x.args[1].args)
        push!(args, x.args[1].args[i].args[2])
        push!(args_aux, x.args[1].args[i].args[1])
    end

    #body = Expr(:quote, x.args[2].args[2])
    body = x.args[2].args[2]

    return :(make_method($(QuoteNode(name)), $args, ($(args_aux...),) -> $body))
end
#end of macros
