function visualize(V, ax, t, g_star, tau_prime, refined)
    if ~exist('g_star', 'var') || ~exist('tau_prime', 'var') || ~exist('refined', 'var')
        visualize_gt(V, ax);
        return;
    end
    if ~exist('t', 'var')
        t = 0;
    end
    if length(ax) == 1
        visualize_single_ax(V, ax, t, g_star, tau_prime, refined);
    else
        for axi = 1:length(ax)
            visualize_single_ax(V, ax{axi}, t, g_star, tau_prime, refined);
        end
    end
end

function visualize_single_ax(V, ax, step, g_star, tau_prime, refined)
global par;
global expr;

% figure();
cla(ax); axes(ax);

P_simp = Polyhedron('V', eye(par.L));
P_simp.plot('color','b', 'alpha', 0, 'LineWidth', 2); hold on;

P = constructP(V);
P.plot('color','r','alpha', 1.0, 'LineStyle', 'none');

% expr.P_gt.plot('color', [0.4660 0.6740 0.1880], 'alpha', 1, 'LineStyle', 'none');
P_gt_4plot = Polyhedron('V', expr.P_gt.V+[1e-7 1e-7 1e-7]);
P_gt_4plot.plot('color', [0.4660 0.6740 0.1880], 'alpha', 1, 'LineStyle', 'none');
centroid = mean(expr.P_gt.V, 1);
% text(ax, centroid(1)+0.04, centroid(2), centroid(3)+0.04, 'P', 'FontSize', 30);


P_pos = Polyhedron('A', [-1 0 0;0 -1 0; 0 0 -1],'b',[0;0;0]);
P_new = P_pos & Polyhedron('A', g_star', 'b', tau_prime);
if ~refined
    P_new = Polyhedron('V', -eye(par.L));
end
P_new.plot('color','y', 'alpha', 0.1, 'LineStyle', '--', 'LineWidth', 1);

try
    P_prune = P_simp & Polyhedron('A', -g_star', 'b', -tau_prime);
    if ~refined
        P_prune = Polyhedron('V', -eye(par.L));
    end
    P_prune.plot('color', [0.8500, 0.3250, 0.0980], 'alpha', 0.5, 'LineStyle', '--');
catch
    disp('Empty pruned area.');
end

xlabel('p(1)', 'Interpreter', 'latex');
ylabel('p(2)', 'Interpreter', 'latex');
zlabel('p(3)', 'Interpreter', 'latex');
set(ax, 'FontSize', 25); axis(ax, 'equal');
view(ax, [1, 1, 1]);
% grid off;
xlim([0 1]); ylim([0 1]); zlim([0 1]);

if exist('step', 'var')
    title(sprintf('Step %d', step), 'Interpreter', 'latex');
end

end

function visualize_gt(V, ax)
global par;
global expr;

% figure();
cla(ax); axes(ax);

P_simp = Polyhedron('V', eye(par.L));
P_simp.plot('color','b', 'alpha', 0, 'LineWidth', 2); hold on;

P = constructP(V);
P.plot('color','r','alpha', 1.0, 'LineStyle', 'none');

expr.P_gt.plot('color', [0.4660 0.6740 0.1880], 'alpha', 1, 'LineStyle', 'none');

title('Ground truth envelope P');
xlabel('p(1)', 'Interpreter', 'latex');
ylabel('p(2)', 'Interpreter', 'latex');
zlabel('p(3)', 'Interpreter', 'latex');
set(ax, 'FontSize', 25); axis(ax, 'equal');
% grid off;
view(ax, [1, 1, 1]);

end