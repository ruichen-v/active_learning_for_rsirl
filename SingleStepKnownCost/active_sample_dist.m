function [sample_prob, ret_j] = active_sample_dist(x_t, u_t, x_list, u_list, v_list,...
                                    refine_steps, P_V, ax)
% Select disturbance j such that the projection of surface normal of new
% hyperplane on probability simplex is new

% x, u: previous state-action

global par;
global expr;
global config;

% assert(size(x_list, 2) == refine_steps);
% assert(size(u_list, 2) == refine_steps);

predict_c1 = [1,1,1]; predict_c2 = [0, 0.4470, 0.7410];

ca = [1 1 1]; cb = [1 1 0]; delta_color = cb-ca;
clib = {};
for j = 1:par.L
    lambda = 0.1+0.3*j;
    clib{end+1} = (1-lambda)*predict_c1 + lambda*predict_c2;
end

%% Current envelope
g_star_list = []; phi_star_list = [];
for k = 1:length(refine_steps)
    key_step = refine_steps(k);
    g_key = cost(x_list(:, key_step), u_list(:, key_step), expr.fparam, expr.Cparam, par.L);
    % proj on simplex
    [phi, phi_norm, alpha] = proj_on_simplex(g_key, par.L);
    phi_star_list = [phi_star_list, phi_norm];
    % original direction vector
    g_star_list = [g_star_list, g_key./norm(g_key)];
end
if ~isempty(refine_steps)
    if length(ax) == 1
        Plot_on_Simplex(phi_star_list, ax, 'c', 2);
%         Plot_with_Simplex(g_star_list, ax, 'c', 2, 0.4);
    else
        for axi = 1:length(ax)
            Plot_on_Simplex(phi_star_list, ax{axi}, 'c', 2);
    %         Plot_with_Simplex(gstar_norm_list, ax{axi}, 'c', 2, 0.5, v_list(:, refine_steps));
%             Plot_with_Simplex(g_star_list, ax{axi}, 'c', 2, 0.4);
        end
    end
end

%% Predictive disturbance sampling
sample_size = 1000;
g_forward_allL = zeros(par.L, sample_size, par.L);
phi_forward_allL = zeros(par.L, sample_size, par.L);

assert(length(refine_steps) == size(phi_star_list,2));

if ~isempty(refine_steps)
    cossim_allL = zeros(length(refine_steps), sample_size, par.L);
    for j = 1:par.L
        % Iterate through all possible next states
        x_next = env(x_t, u_t, false, j);
        % var to pass to parfor
        u_limit_ = par.u_limit; L_ = par.L; fparam_ = expr.fparam; Cparam_ = expr.Cparam;
        parfor s = 1:sample_size
            u_next = rand_u(u_limit_);
            g_next = cost(x_next, u_next, fparam_, Cparam_, L_);
            [phi, phi_norm, alpha] = proj_on_simplex(g_next, L_);
            phi_forward_allL(:, s, j) = phi_norm;
            g_forward_allL(:, s, j) = g_next./norm(g_next);
            cossim_allL(:, s, j) = phi_star_list'*phi_norm;
        end
        phi_forward_list = phi_forward_allL(:, :, j);
        if length(ax) == 1
            Plot_on_Simplex(phi_forward_list, ax, clib{j}, 2, j);
%             Plot_with_Simplex(g_forward_allL(:, :, j), ax, clib{j}, 0.01, 0.3);
        else
            for axi = 1:length(ax)
                Plot_on_Simplex(phi_forward_list, ax{axi}, clib{j}, 2, j);
%                 Plot_with_Simplex(g_forward_allL(:, :, j), ax{axi}, clib{j}, 0.01, 0.3);
            end
        end
    end
else
    cossim_allL = zeros(1, sample_size, par.L);
end

% Simplex Normal
% if length(ax) == 1
%     Plot_with_Simplex([1;1;1], ax, 'b', 4, 0.4);
% else
%     for axi = 1:length(ax)
%         Plot_with_Simplex([1;1;1], ax{axi}, 'b', 4, 0.4);
%     end
% end

%% cosine similarity as cost
cossim_allL = reshape(sum(mean(cossim_allL, 2), 1), [], 1);
sample_prob = exp(-cossim_allL);
sample_prob = sample_prob./sum(sample_prob, 1);

if config.epsilon_greedy
    disp('Sample greedy dist.');
    % return max prob disturbance
    ret_j = find(sample_prob == max(sample_prob), 1);
else
    disp('Sample softmax dist.');
    % sample disturbance exponentially
    ret_j = randsample(par.L, 1, true, sample_prob);
end

return;

end

