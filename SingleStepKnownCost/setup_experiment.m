
global par;
global expr;
global util;

util.fn_exp_setup = strcat('Data/', expname, '/exp_setup.mat');
util.fn_gt_envelope = strcat('Data/', expname, '/P_gt');
util.episode_root = strcat('Data/', expname, '/', episode_name);
util.fname_demo = strcat(util.episode_root, '/_demo.mat');
util.fname_irl_result = strcat(util.episode_root, '/_irl_result.mat');

if ~exist(util.episode_root, 'dir')
    mkdir(util.episode_root);
end

if newExp
    
    par.L = 3; par.u_dim = 5; par.x_dim = 10; par.maxstep = 50;
%     par.u_limit = repmat([-5,1], par.u_dim, 1);
    par.u_limit = [-1, 1; ...
                    0, 2; ...
                   -2, -1; ...
                    0, 1; ...
                    -1, 0];
    par.J_upper = 1; par.J_lower = -1;
    
    fig_show_gt = figure('Position', [10 10 900 900]);
    ax_gt = axes('Parent', fig_show_gt);
    expr.fparam.Aw = {}; expr.fparam.Bw = {};
    for j = 1:par.L
        expr.fparam.Aw{end+1} = randn(par.x_dim, par.x_dim);
        expr.fparam.Bw{end+1} = randn(par.x_dim, par.u_dim);
    end

    expr.Cparam.R = eye(par.u_dim);
    M = randn(par.x_dim); expr.Cparam.Q = M*M';

    expr.x_init = mvnrnd(zeros(par.x_dim,1), eye(par.x_dim))';
    expr.x_init = expr.x_init / norm(expr.x_init);

    vv = rand(20,par.L);
    vv(:, 1) = vv(:, 1) / 2 + 0.5;
    vv(:, 2) = vv(:, 2) / 1.2;
    vv(:, 3) = vv(:, 3) / 1.2;
    vv = vv./sum(vv, 2);
    k = convhull(vv(:,1),vv(:,2));
    expr.V_P_gt = vv(k, :);

    expr.P_gt = Polyhedron('V', expr.V_P_gt).minVRep();
    if check_gt_envelope
        visualize(expr.V_P_gt, ax_gt);
        view(ax_gt, [1, 1, 1]); axis(ax_gt, 'equal');
        xlim([0 1]); ylim([0 1]); zlim([0 1]);
%         keyboard;
%         pause;
%         close all;
    end

    if ~exist(strcat('Data/', expname), 'dir')
        mkdir(strcat('Data/', expname));
    end
    save(util.fn_exp_setup, 'expr', 'par');
    fprintf('*** Saved %s\n', util.fn_exp_setup);
else
    load(util.fn_exp_setup);
    fprintf('*** Loaded %s\n', util.fn_exp_setup);
    expr.P_gt = Polyhedron('V', expr.V_P_gt).minVRep();
end