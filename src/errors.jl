
abstract XMLError <: Exception

immutable XMLParseError{T<:AbstractString} <: XMLError
    msg::T
end

immutable XMLNoRootError <: XMLError
end

immutable XMLAttributeNotFound <: XMLError
end

immutable XMLWriteError{T<:AbstractString} <: XMLError
    msg::T
end

immutable XMLTreeError{T<:AbstractString} <: XMLError
    msg::T
end
