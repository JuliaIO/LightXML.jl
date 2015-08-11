
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

const dom_exception_causes = [
    "Index size error",        #  1
    "DOM string size error",   #  2
    "Hierarchy request error", #  3
    "Wrong document",          #  4
    "Invalid character",       #  5
    "No data allowed",         #  6
    "No modification allowed", #  7
    "Not found",               #  8
    "Not supported",           #  9
    "Inused attribute"         # 10
]


immutable DOMException{T<:AbstractString} <: XMLError
    code::Int
    cause::T

    DOMException(code::Int) = new(code, dom_exception_causes[code])
end
