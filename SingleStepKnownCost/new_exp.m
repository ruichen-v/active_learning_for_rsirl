% Copyright (c) 2019 Rui Chen
%
% This work is licensed under the terms of the MIT license.
% For a copy, see <https://opensource.org/licenses/MIT>.

close all;
expname = 'exp_4';
episode_name = 'testing';

global par;
global util;
% global config;
%% Setup dynamics and cost

newExp = true; check_gt_envelope = true;

V = [];
setup_experiment;
par.maxstep = 10;

disp('Experiment set up.');

%% Generate expert demonstration
xstar_list = [];
ustar_list = [];
taustar_list = [];
vstar_list = [];
w_list = [];
for restart = 1:20
    x_init = mvnrnd(zeros(par.x_dim,1), eye(par.x_dim))';
    x_init = x_init / norm(x_init);
    fprintf('Generating testset, x_init is:\n');
    [xstar_list_, ustar_list_, taustar_list_, vstar_list_, w_list_] = gen_episode(x_init, par.maxstep);
    xstar_list = [xstar_list, xstar_list_];
    ustar_list = [ustar_list, ustar_list_];
    taustar_list = [taustar_list, taustar_list_];
    vstar_list = [vstar_list, vstar_list_];
    w_list = [w_list, w_list_];
end

save(util.fname_demo, ...
        'xstar_list', 'ustar_list', 'taustar_list', 'vstar_list', 'w_list');
fprintf('*** Saved %s\n', util.fname_demo);