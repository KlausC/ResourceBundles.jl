
const LC_CTYPE_MASK             = Int(1) << 0
const LC_NUMERIC_MASK           = Int(1) << 1
const LC_TIME_MASK              = Int(1) << 2
const LC_COLLATE_MASK           = Int(1) << 3
const LC_MONETARY_MASK          = Int(1) << 4
const LC_MESSAGES_MASK          = Int(1) << 5
const LC_ALL_MASK               = Int(1) << 6
const LC_PAPER_MASK             = Int(1) << 7
const LC_NAME_MASK              = Int(1) << 8
const LC_ADDRESS_MASK           = Int(1) << 9
const LC_TELEPHONE_MASK         = Int(1) << 10
const LC_MEASUREMENT_MASK       = Int(1) << 11
const LC_IDENTIFICATION_MASK    = Int(1) << 12

const LC_MASK = (Int(1) << 13) - 1

const LC_MASKS = Dict(
                      :CTYPE => LC_CTYPE_MASK,
                      :NUMERIC => LC_NUMERIC_MASK,
                      :TIME => LC_TIME_MASK,
                      :COLLATE => LC_COLLATE_MASK,
                      :MONETARY => LC_MONETARY_MASK,
                      :MESSAGES => LC_MESSAGES_MASK,
                      :ALL => LC_ALL_MASK,
                      :PAPER => LC_PAPER_MASK,
                      :NAME => LC_NAME_MASK,
                      :ADDRESS => LC_ADDRESS_MASK,
                      :TELEPHONE => LC_TELEPHONE_MASK,
                      :MEASUREMENT => LC_MEASUREMENT_MASK,
                      :IDENTIFICATION => LC_IDENTIFICATION_MASK,
                     )

function newlocale(mask::Int, loc::Locale, base = Ptr{Void}(0))
    cmask = Cint(mask)
    clocale = Clocale(loc)
    ccall(:newlocale, Ptr{Void}, (Cint, Cstring, Ptr{Void}), cmask, clocale, base)
end

function Clocale(loc::Locale)
    string(loc.language, '_', loc.region, ".utf8")
end

function freelocale(ptr::Ptr{Void})
    ccall(:freelocale, Void, (Ptr{Void},), ptr)
end

function strcoll(s1::AbstractString, s2::AbstractString, loc::Locale)
    ploc = newlocale(LC_COLLATE_MASK, loc)
    if ploc != Ptr{Void}(0)
        res = ccall(:strcoll_l, Cint, (Cstring, Cstring, Ptr{Void}), s1, s2, ploc)
        freelocale(ploc)
    end
    Int(res)
end
