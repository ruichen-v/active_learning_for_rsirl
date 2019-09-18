function P = constructP(V)
global par;
    P_simp = Polyhedron('V', eye(par.L));
    if ~isempty(V)
        P_tmp = Polyhedron('V', V);
        P = P_simp & Polyhedron('A', P_tmp.A, 'b', P_tmp.b);
    else
        P = P_simp;
    end
end

