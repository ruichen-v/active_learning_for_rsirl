function u = rand_u(u_limit)
% global par;
    u_dim = size(u_limit, 1);
    u = u_limit(:, 1) + ...
        rand(u_dim, 1) .* (u_limit(:, 2)-u_limit(:, 1));
end

