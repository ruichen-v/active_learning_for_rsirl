% Copyright (c) 2019 Rui Chen
%
% This work is licensed under the terms of the MIT license.
% For a copy, see <https://opensource.org/licenses/MIT>.

global config;
global par;
global util;

if ~exist('benchmark', 'var') || ~benchmark
    close all;
    expname = 'exp_2';
    episode_name = 'softmax_7';
    config.epsilon_greedy = false;
end

config.epsilon = 0.1;
    
%% Setup dynamics and cost

newExp = false; check_gt_envelope = true; replay = true; saveall = false;
% newDemo = true;

fprintf('\n\nStarting %s - %s ....\n', expname, episode_name);
setup_experiment;
disp('Experiment set up.');

%% Generate expert demonstration with active disturbance sampling
xstar_list = [];
ustar_list = [];
taustar_list = [];
vstar_list = [];
w_list = [];
x_init = expr.x_init;
% Demo log
if exist(util.fname_demo, 'file')
    if replay
        load(util.fname_demo, 'w_list');
        fprintf('load %s w_list.\n', util.fname_demo);
    else
        load(util.fname_demo);
        fprintf('load %s all.\n', util.fname_demo);
        x_init = env(xstar_list(:, end), ustar_list(:, end), false, w_list(end));
    end
end

x_t = x_init;

V_list = {}; tau_prime_list = []; refine_steps = []; sample_probs = [];
V = []; 
% IRL log
if exist(util.fname_irl_result, 'file')
    if ~replay
        load(util.fname_irl_result);
        fprintf('load %s.\n', util.fname_irl_result);
        V = V_list{end};
    else
        fprintf('Replay. IRL result not loaded.\n');
    end
end

% fig_3dview = figure('Position', [10, 10, 2000, 800]);
% % set(gcf,'Visible', 'off');
% ax1 = subplot(1, 3, 1);
% ax2 = subplot(1, 3, 2);
% ax3 = subplot(1, 3, 3);
% ax = {ax1, ax2, ax3};

fig_3dview = figure('Position', [10 10 2000 600]);
ax = axes('Parent', fig_3dview);

refine_ts = [];
active_ts = [];

for t = (size(V_list, 2)+1):par.maxstep
    
    xstar_list = [xstar_list, x_t];
    [u_t_star, tau_t_star, v_t_star] = expert(x_t);
    ustar_list = [ustar_list, u_t_star];
    taustar_list = [taustar_list, tau_t_star];
    vstar_list = [vstar_list, v_t_star];
    
    tic;
    [V, V_list, tau_prime_list, refined, msg] = refine_envelope(...
                                x_t, u_t_star, V, ...
                                V_list, tau_prime_list, t, ...
                                vstar_list, taustar_list, ax);
    t_refine = toc;
    
    if refined
        refine_steps = [refine_steps, t];
    end
                            
    % active disturbance sampling
    % xstar, ustar -> x_t, u_t
    tic;
    [sample_prob, active_dist] = active_sample_dist(x_t, u_t_star, ...
                                xstar_list, ustar_list, vstar_list, refine_steps,...
                                V, ax);
    t_active = toc;
    
    fprintf('Sample probability:\n w1 %.4f\n w2 %.4f\n w3 %.4f\n', sample_prob(1), sample_prob(2), sample_prob(3));
    sample_probs = [sample_probs, sample_prob];
%     adjust3dview;

    %Save img
    lgd = legend('Prob. simplex $\Delta^L$',...
        'Approx. envelope $\mathcal{P}_d$',...
        'True envelope $\mathcal{P}$', ...
        'Half-space $\mathcal{H}_d$',...
        'Pruned portion of $\Delta^L$',...
        'Refinement direction $\{\bar{\varphi}^*_k\}_{k\in\mathcal{K}}$', ...
        'Predicted $\bar{\varphi}''_{d+1}$ with $w_d=w^{[1]}$', ...
        'Predicted $\bar{\varphi}''_{d+1}$ with $w_d=w^{[2]}$', ...
        'Predicted $\bar{\varphi}''_{d+1}$ with $w_d=w^{[3]}$', ...
        'Interpreter','latex');
%     'Normalized cost vector $\{\bar{g}^*_k\}_{k\in\mathcal{K}}$', ...
    lgd.FontSize = 30; lgd.NumColumns = 2;
    if saveall
        savename = strcat(util.episode_root, '/', num2str(t,'%.3d'), '.png');
        saveas(fig_3dview, savename);
        savename = strcat(util.episode_root, '/', num2str(t,'%.3d'));
        savefig(fig_3dview, savename);
    end
    
    % step forward with actively sampled disturbance
    % x_t+1
    roll = rand();
    if config.epsilon_greedy
        if roll <= config.epsilon
            disp('Epsilon greedy, random dist.');
            [x_t_1, w_t] = env(x_t, u_t_star, true);
        else
            disp('Epsilon greedy, greedy.');
            [x_t_1, w_t] = env(x_t, u_t_star, true, active_dist);
        end
    else
        disp('Softmax.');
        if replay
            disp('Replay.');
            active_dist = w_list(t);
        end
        [x_t_1, w_t] = env(x_t, u_t_star, true, active_dist);
    end
    
    if ~replay
        w_list = [w_list, w_t];
    end
    
%     if t < par.maxstep
%         xstar_list = [xstar_list, x_t_1];
%     end
    
    x_t = x_t_1;
    
    fprintf('Refine time: %.3f\nActive time: %.3f\n', t_refine, t_active);
    fprintf('\n'); disp(msg);
    refine_ts = [refine_ts, t_refine];
    active_ts = [active_ts, t_active];
end

assert(length(xstar_list) == length(ustar_list));

fprintf('Finished. Total length %d.\n', length(xstar_list));
disp('Average refinement time:');
mean(refine_ts)
disp('Average sampling time:');
mean(active_ts)

if ~replay
    save(util.fname_demo, ...
        'xstar_list', 'ustar_list', 'taustar_list', 'vstar_list', 'w_list');
    fprintf('*** Saved %s\n', util.fname_demo);

    save(util.fname_irl_result, ...
        'V_list', 'tau_prime_list', 'refine_steps', 'sample_probs', 'config');
    fprintf('*** Saved %s\n', util.fname_irl_result);
else
    fprintf('Replay, result unchanged.\n');
end

% keyboard
close all;
clear benchmark;
