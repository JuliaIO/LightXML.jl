abstract type XMLError <: Exception end

struct XMLNoRootError <: XMLError ; end

struct XMLAttributeNotFound <: XMLError ; end

struct XMLParseError{T<:AbstractString} <: XMLError
    msg::T
end

struct XMLWriteError{T<:AbstractString} <: XMLError
    msg::T
end

struct XMLTreeError{T<:AbstractString} <: XMLError
    msg::T
end

struct XMLValidationError{T<:AbstractString} <: XMLError
    msg::T
end
