function q = Plot_on_Simplex(vv, ax, color, width, scale)
% Always from simplex center
global par;

n = ones(par.L, 1); n = n./par.L;
n = repmat(n, 1, size(vv, 2));

if ~exist('scale', 'var') % plot refinement direction
    vv = vv.*sqrt(0.1);
    endpoint = n+vv;
    lambda = 0.2 * 4;
    startpoint = (1-lambda)*n + (lambda)*endpoint;
    vv = vv.*sqrt(0.15);
    q = quiver3(ax, startpoint(1,:), startpoint(2,:), startpoint(3,:),...
        vv(1,:), vv(2,:), vv(3,:), ...
        0, ...
        'Color', color,...
        'LineWidth', width, ...
        'LineStyle', '-',...
        'MaxHeadSize', 0.2);
    return;
end
% se = [n; n+v];

vv = vv.*sqrt(0.1);

endpoint = n+vv;
lambda = 0.2 * (scale);
startpoint = (1-lambda)*n + (lambda)*endpoint;

vv = vv.*sqrt(0.02);

q = quiver3(ax, startpoint(1,:), startpoint(2,:), startpoint(3,:),...
            vv(1,:), vv(2,:), vv(3,:), ...
            0, ...
            'Color', color,...
            'LineWidth', width, ...
            'LineStyle', '-',...
            'MaxHeadSize', 0.2);

% dim = [se(:, 2)' 0.3 0.3 0.3];
% str = num2str(alpha);
% annotation(gcf, 'textbox',dim,'String',str,'FitBoxToText','on');

end

