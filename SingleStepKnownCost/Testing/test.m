close all;

global par;
global util;
global expr;

% expid = 2; % uncomment for testing single experiment
expname = sprintf('exp_%d', expid);

epsilon_epis = 1:30;
epsilon_greedy_episodes = {};

softmax_epis = 1:30;
softmax_episodes = {};

std_epis = 1:30;
std_episodes = {};

plot_per_experiment = true;

for i = 1:length(epsilon_epis)
    epsilon_epi = epsilon_epis(i);
    epsilon_greedy_episodes{end+1} = strcat('epsilon_', num2str(epsilon_epi));
end
for i = 1:length(softmax_epis)
    active_epi = softmax_epis(i);
    softmax_episodes{end+1} = strcat('softmax_', num2str(active_epi));
end
for i = 1:length(std_epis)
    std_epi = std_epis(i);
    std_episodes{end+1} = strcat('std_', num2str(std_epi));
end

%% Setup test case
episode_name = 'testing';
newExp = false; setup_experiment;
fprintf('Experiment set up for %s.\n', episode_name);
load(util.fname_demo, 'xstar_list', 'ustar_list'); % load gt demo
fprintf('Loaded %s\n', util.fname_demo); disp(size(xstar_list));

% show gt
fig_show_gt = figure('Position', [10 10 500 500]);
ax_gt = axes('Parent', fig_show_gt);
visualize(expr.V_P_gt, ax_gt);
title(strcat('Test~', num2str(expid), ' True Envelope $\mathcal{P}$'), ...
    'Interpreter', 'latex');
view(ax_gt, [1, 1, 1]); axis(ax_gt, 'equal');
xlim([0 1]); ylim([0 1]); zlim([0 1]);
savefig(fig_show_gt, util.fn_gt_envelope);
saveas(fig_show_gt, strcat(util.fn_gt_envelope, '.png'));

% for parfor
u_dim_ = par.u_dim; u_limit_ = par.u_limit; L_ = par.L;
fparam_ = expr.fparam; Cparam_ = expr.Cparam;

%% Testing All IRL inference

fig = figure('Position', [10, 10, 900, 600]); hold on;
h_lgd_pair = {};

color_epsilon = [0.3010, 0.7450, 0.9330];
color_softmax = [0.4660, 0.6740, 0.1880];
color_std = [0.8500, 0.3250, 0.0980];

% h_lgd_pair = run_test(expname, epsilon_greedy_episodes, xstar_list, ustar_list, ...
%                                L_, u_limit_, u_dim_, fparam_, Cparam_, ...
%                                h_lgd_pair, plot_per_experiment, ...
%                                 'Epsilon Greedy', color_epsilon);
h_lgd_pair = run_test(expname, std_episodes, xstar_list, ustar_list, ...
                               L_, u_limit_, u_dim_, fparam_, Cparam_, ...
                               h_lgd_pair, plot_per_experiment, ...
                                'Original RS-IRL', color_std);
h_lgd_pair = run_test(expname, softmax_episodes, xstar_list, ustar_list, ...
                               L_, u_limit_, u_dim_, fparam_, Cparam_, ...
                               h_lgd_pair, plot_per_experiment, ...
                                'Active RS-IRL', color_softmax);


%% Plot
axx = []; lgdd = {};
for i = 1:size(h_lgd_pair, 2)
    axx = [axx, h_lgd_pair{i}{1}];
    lgdd{end+1} = h_lgd_pair{i}{2};
end
legend(axx, lgdd, 'Fontsize',25, 'Interpreter', 'latex');
set(gca,'Fontsize',25)
title(strcat('MSE $\frac{1}{m}||u''_k-u^*_k||^2$ for Test~', num2str(expid)), 'FontSize', 30, ...
                'Interpreter', 'latex');
xlabel('Number of Demonstrations', 'FontSize', 30, 'Interpreter', 'latex');
ylabel('MSE Error', 'FontSize', 30, 'Interpreter', 'latex');
saveas(fig, strcat('Data/', expname, '/mse.png'));

%%
function h_lgd_pair = run_test(expname, episodes, xstar_list, ustar_list, ...
                               L_, u_limit_, u_dim_, fparam_, Cparam_, ...
                               h_lgd_pair, plot_per_experiment,...
                               name, color)
    global par;
    
    mse_error_active = [];
    for epi = 1:size(episodes, 2)

        mse_error = test_(expname, episodes{epi}, xstar_list, ustar_list,...
                            L_, u_limit_, u_dim_, fparam_, Cparam_);
        if strcmp(expname, 'exp_3')
            mse_error = mse_error(1:50);
        end
        mse_error_active = [mse_error_active, mse_error];
        if plot_per_experiment
            h = plot(1:size(mse_error, 1), mse_error, ...
                        'Color', color, 'Marker', 'x', 'MarkerSize', 4,...
                        'LineStyle', '--');
        end
        fprintf('***********\nEpisode %s done.\n***********\n\n', episodes{epi});
    end
    if plot_per_experiment
        h_lgd_pair{end+1} = {h, strcat(name, ' - per experiment')};
    end

    mean_error_active = mean(mse_error_active, 2);
    if size(mse_error_active, 2) == 1
        mse_error_active = repmat(mse_error_active, 1, 2);
    end
    std_error_active = std(mse_error_active')';
    h = Plot_with_uncertainty(1:size(mean_error_active, 1), mean_error_active,...
                                std_error_active, color);
    h_lgd_pair{end+1} = {h, name};
end

%%
function mse_error = test_(expname, episode_name, xstar_list, ustar_list, ...
                            L, u_limit, u_dim, fparam, Cparam)
    global config;
    rerun = false;
    fname_mse_error = strcat('Data/', expname, '/', episode_name,...
                              '/_mse_error.mat');
                          
    if ~exist(fname_mse_error, 'file') || rerun
        mse_error = [];
        prev_mse_error = -1;
    else
        load(fname_mse_error, 'mse_error');
        fprintf('load %s.\n', fname_mse_error);
        prev_mse_error = mse_error(end);
    end
    % load pparams
    fname_irl_result = strcat('Data/', expname, '/', episode_name,...
                              '/_irl_result.mat');
    load(fname_irl_result, 'V_list', 'refine_steps', 'config');
    fprintf('load %s.\n', fname_irl_result);
   
    for t = (size(mse_error, 1)+1):size(V_list, 2)
        % Always run eval in first step and refine steps
        if t == 1 || ~isempty(find(refine_steps==t, 1))
            V_t = V_list{t};
            error_all_t = zeros(size(xstar_list, 2), 1);                
            P = constructP(V_t);
            parfor k = 1:size(xstar_list, 2)
%                 parfor k = 1:20
                x = xstar_list(:, k); u_gt = ustar_list(:, k);
                [u_pred, ~, ~] = predict(x, u_dim, u_limit, P, ...
                                                    L, fparam, Cparam);
                error = norm(u_pred - u_gt)^2/u_dim;
                error_all_t(k) = error;
            end
            mse_error_t = mean(error_all_t, 1);
            fprintf('[new] ');
        else
            assert(prev_mse_error ~= -1);
            mse_error_t = prev_mse_error;
            fprintf('[old] ');
        end

        mse_error = [mse_error; mse_error_t];
        fprintf('Episode %s - Step %d - MSE error: %.5f\n', ...
                            episode_name, t, mse_error_t);

        prev_mse_error = mse_error_t;
    end
    save(fname_mse_error, 'mse_error');
    fprintf('save %s.\n', fname_mse_error);
end


