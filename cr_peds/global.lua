cache = {
    --{"Name", Nokill (true = igen, false = nem), type (server, client), nametagType pld:Hambrugeres, {skin, x,y,z,rx,ry,rz,dim,int}},
    {"Jesse M Black", true, "client", "Eladó (Hamburger)", {107, 1945.390625, -1796.1711425781, 13.546875, 0,0,5, 0,0}, {"fam3", ":cr_texture/files/fam3-2.png"}},
    {"George Davies", true, "client", "Eladó (Hot-Dog)", {107, 1942.5330810547, -1796.2965087891, 13.546875, 0,0,7, 0,0}, {"fam3", ":cr_texture/files/fam3-1.png"}},
}

pedCache = {}

function getPed(id)
    return pedCache[id]
end