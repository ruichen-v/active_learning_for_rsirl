function ret = dcost_du(u, x, fparam, Cparam, L)
% Gradient of g
u_dim = length(u);
ret = zeros(L, u_dim);

for j = 1:u_dim
    for l = 1:L
        A = fparam.Aw{l};
        B = fparam.Bw{l};
        x_next = A*x + B*u;

        R = Cparam.R; Q = Cparam.Q;
        ret(l, j) = u'*(R(:, j) + R(j, :)') + x_next'*(Q + Q')*B(:, j);
    end
end

