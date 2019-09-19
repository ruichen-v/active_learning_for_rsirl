% Copyright (c) 2019 Rui Chen
%
% This work is licensed under the terms of the MIT license.
% For a copy, see <https://opensource.org/licenses/MIT>.

if ~exist('benchmark', 'var') || ~benchmark
    close all;
    expname = 'exp_2';
    episode_name = 'std_28';
end

global par;
global util;
global config;
config.img_name = 'mse_std';
%% Setup dynamics and cost

newExp = false; check_gt_envelope = true; replay = true; saveall = false;
newDemo = true;

setup_experiment; 

disp('Experiment set up.');

%% Generate expert demonstration
if newDemo
    if exist(util.fname_demo, 'file')
        fprintf('load %s.\n', util.fname_demo);
        load(util.fname_demo);
        x_init = env(xstar_list(:, end), ustar_list(:, end), false, w_list(end));
        maxsteps = par.maxstep - size(xstar_list, 2);
    else
        xstar_list = [];
        ustar_list = [];
        taustar_list = [];
        vstar_list = [];
        w_list = [];
        x_init = expr.x_init;
        maxsteps = par.maxstep;
    end
    [xstar_list_, ustar_list_, taustar_list_, vstar_list_, w_list_] = gen_episode(x_init, maxsteps);
    xstar_list = [xstar_list, xstar_list_];
    ustar_list = [ustar_list, ustar_list_];
    taustar_list = [taustar_list, taustar_list_];
    vstar_list = [vstar_list, vstar_list_];
    w_list = [w_list, w_list_];
    if maxsteps > 0
        replay = false;
        save(util.fname_demo, ...
                'xstar_list', 'ustar_list', 'taustar_list', 'vstar_list', 'w_list');
        fprintf('*** Saved %s\n', util.fname_demo);
    else
        fprintf('*** Demo unchanged at %s.\n', util.fname_demo);
    end
else
    load(util.fname_demo);
    fprintf('*** Loaded %s\n', util.fname_demo);
end

% assert(length(xstar_list) == par.maxstep);
% assert(length(ustar_list) == par.maxstep);

%% Recursively refine envelope
V_list = {}; tau_prime_list = []; refine_steps = []; V = [];
if exist(util.fname_irl_result, 'file')
    if ~replay
        fprintf('load %s.\n', util.fname_irl_result);
        load(util.fname_irl_result);
        V = V_list{end};
    else
        fprintf('Replay. IRL result not loaded.\n');
    end
end
fig_3dview = figure('Position', [10 10 1800 600]);
ax = axes('Parent', fig_3dview);
for t = (size(V_list, 2)+1):par.maxstep
    x_exp = xstar_list(:, t);
    u_exp = ustar_list(:, t);
    [V, V_list, tau_prime_list, refined, msg] = refine_envelope(...
                            x_exp, u_exp, V, ...
                            V_list, tau_prime_list, t, ...
                            vstar_list, taustar_list, ax);

    if refined
        refine_steps = [refine_steps, t];
    end
    
    % save img
    lgd = legend('Prob. simplex $\Delta^L$',...
        'Approx. envelope $\mathcal{P}_d$',...
        'True envelope $\mathcal{P}$', ...
        'Half-space $\mathcal{H}_d$',...
        'Pruned portion of $\Delta^L$',...
        'Interpreter','latex');
%     'Normalized cost vector $\{\bar{g}^*_k\}_{k\in\mathcal{K}}$', ...
    lgd.FontSize = 30; lgd.NumColumns = 1;
    if saveall
        savename = strcat(util.episode_root, '/', num2str(t,'%.3d'), '.png');
        saveas(fig_3dview, savename);
        savename = strcat(util.episode_root, '/', num2str(t,'%.3d'));
        savefig(fig_3dview, savename);
    end
    fprintf('\n'); disp(msg);
end

if ~replay
    fprintf('Finished. Total length %d.\n', size(V_list,2));
    save(util.fname_irl_result, 'V_list', 'tau_prime_list', 'refine_steps', 'config');
    fprintf('*** Saved %s\n', util.fname_irl_result);
else
    fprintf('Replay, result unchanged.\n');
end

% keyboard
close all;
