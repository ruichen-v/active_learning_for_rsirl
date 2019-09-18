function [xstar_list, ustar_list, taustar_list, vstar_list, w_list] = gen_episode(x_init, steps)
% Generate expert demonstration

% global par;
% global expr;

if steps > 0
    fprintf('Generating demonstration...\n');
else
    fprintf('Skip demo generating...\n');
end

% if gen_testing
%     x = mvnrnd(zeros(par.x_dim,1), eye(par.x_dim))';
%     x = x / norm(x);
%     fprintf('Generating testset, x_init is:\n');
%     disp(x);
% else
%     fprintf('Training, using expr.x_init:\n');
%     x = expr.x_init;
% end

x = x_init;

xstar_list = [x];
ustar_list = [];
taustar_list = [];
vstar_list = [];
w_list = [];


for t = 1:steps
    [ustar, tau_star, v_star] = expert(x);
    
    % step forward with stationarily sampled disturbance
    [x, w_t] = env(x, ustar);
    
    % Collect x, u, tau*, v*
    xstar_list = [xstar_list, x];
    ustar_list = [ustar_list, ustar];
    taustar_list = [taustar_list, tau_star];
    vstar_list = [vstar_list, v_star];
    w_list = [w_list, w_t];
end

xstar_list = xstar_list(:, 1:end-1);

assert(length(xstar_list) == length(ustar_list));

if steps > 0
    disp('Done.');
end
end

