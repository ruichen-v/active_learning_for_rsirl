clear all; close all;

global par;
global util;
global config; config.epsilon_greedy = false;
global expr;

%% Do not change
newExp = false;

%% Comparison
exp_id = 2;
std_id = 7;
active_id = 7;
result_folder = sprintf('Demo/exp_%d_std_%d_active_%d', exp_id, std_id, active_id);
if ~exist(result_folder, 'dir')
    mkdir(result_folder);
end

%% Read data
expname = sprintf('exp_%d', exp_id);

% Standard
episode_name = sprintf('std_%d', std_id);
setup_experiment;
std_demo = load(util.fname_demo);
std_irl = load(util.fname_irl_result);
fname_mse_error = strcat('Data/', expname, '/', episode_name,...
                              '/_mse_error.mat');
std_err = load(fname_mse_error);
std_err = std_err.mse_error;
                          
% Active
episode_name = sprintf('softmax_%d', active_id);
setup_experiment;
active_demo = load(util.fname_demo);
active_irl = load(util.fname_irl_result);
fname_mse_error = strcat('Data/', expname, '/', episode_name,...
                              '/_mse_error.mat');
active_err = load(fname_mse_error);
active_err = active_err.mse_error;

%% Plot

fig = figure('Position', [10 10 1300 1000]);
ax_std = subplot(4,4,[1,2,5,6]); set(gca,'Fontsize',25);
ax_active = subplot(4,4,[3,4,7,8]); set(gca,'Fontsize',25);
ax_mse = subplot(4,4, 13:16); set(gca,'Fontsize',25); hold on;
title(strcat('MSE $\frac{1}{m}||u''_k-u^*_k||^2$'), ...
                'FontSize', 30, 'Interpreter', 'latex');
xlabel('Number of Demonstrations', 'FontSize', 30, 'Interpreter', 'latex');
ylabel('MSE Error', 'FontSize', 30, 'Interpreter', 'latex');
xlim([0 50]); ylim([0, 4e-3]);

std_color = [0.8500, 0.3250, 0.0980];
active_color = [0.4660, 0.6740, 0.1880];

for t = 1:par.maxstep/2

h_lgd_pair = {};
    
% standard
std_g_star = cost(std_demo.xstar_list(:, t), ...
                  std_demo.ustar_list(:, t), ...
                  expr.fparam, expr.Cparam, par.L);
refined = ~isempty(find(std_irl.refine_steps==t, 1));
visualize(std_irl.V_list{t}, ax_std, t, std_g_star, std_irl.tau_prime_list(t), refined);
title(sprintf('Original RS-IRL Step %d', t), 'Interpreter', 'latex');

% active
x = active_demo.xstar_list(:, t); u = active_demo.ustar_list(:, t);
active_g_star = cost(x, u, expr.fparam, expr.Cparam, par.L);
refined = ~isempty(find(active_irl.refine_steps==t, 1));
visualize(active_irl.V_list{t}, ax_active, t, active_g_star, active_irl.tau_prime_list(t), refined);
title(sprintf('Active RS-IRL Step %d', t), 'Interpreter', 'latex');

refine_steps = active_irl.refine_steps(1:min(t, length(active_irl.refine_steps)));
active_sample_dist(x, u, ...
                    active_demo.xstar_list, ...
                    active_demo.ustar_list, ...
                    active_demo.vstar_list, ...
                    refine_steps, ...
                    active_irl.V_list{t}, ax_active);

lgd = legend('Prob. simplex $\Delta^L$',...
    'Approx. envelope $\mathcal{P}_d$',...
    'True envelope $\mathcal{P}$', ...
    'Half-space $\mathcal{H}_d$',...
    'Pruned portion of $\Delta^L$',...
    'Refined direction $\{\bar{\varphi}^*_k\}_{k\in\mathcal{K}}$', ...
    'Predicted $\bar{\varphi}''_{d+1} \vert_{w_d=w^{[1]}}$', ...
    'Predicted $\bar{\varphi}''_{d+1} \vert_{w_d=w^{[2]}}$', ...
    'Predicted $\bar{\varphi}''_{d+1} \vert_{w_d=w^{[3]}}$', ...
    'Interpreter','latex',...
    'Position', [0.46 0.36 0.1 0.1]);
lgd.NumColumns = 3;
                
% test result
cla(ax_mse);
h = plot(ax_mse, 1:t, std_err(1:t), ...
        'Color', std_color, 'Marker', 'x', 'MarkerSize', 4,...
        'LineStyle', '-');
h_lgd_pair{end+1} = {h, 'Standard RS-IRL'};
    
h = plot(ax_mse, 1:t, active_err(1:t), ...
        'Color', active_color, 'Marker', 'o', 'MarkerSize', 4,...
        'LineStyle', '-');
h_lgd_pair{end+1} = {h, 'Active RS-IRL'};

gen_legend(h_lgd_pair, 20);

saveas(fig, strcat(result_folder, '/', num2str(t,'%.3d'), '.png'));

end


function gen_legend(h_lgd_pair, fontsize)
axx = []; lgdd = {};
for i = 1:size(h_lgd_pair, 2)
    axx = [axx, h_lgd_pair{i}{1}];
    lgdd{end+1} = h_lgd_pair{i}{2};
end
    legend(axx, lgdd, 'Fontsize', fontsize, 'Interpreter', 'latex');
end