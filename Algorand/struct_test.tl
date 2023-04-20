#pragma version 8

struct StructA:
 fieldname: int
 q: int
end

struct StructB:
 r: int
 ffieldname: int
end

block main:
    StructA p = ""
    int x = p.fieldname
end

