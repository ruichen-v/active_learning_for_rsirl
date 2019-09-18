function q = Plot_with_Simplex(vv, ax, color, width, scale, start_pt)
% from start_pt. Default is simplex center
global par;
if ~exist('start_pt', 'var')
    n = ones(par.L, 1); n = n./par.L;
    start_pt = repmat(n, 1, size(vv, 2));
end

assert(size(start_pt, 2) == size(vv, 2));

q = quiver3(ax, start_pt(1,:), start_pt(2,:), start_pt(3,:),...
            vv(1,:), vv(2,:), vv(3,:), ...
            scale, ...
            'Color', color,...
            'LineWidth', width, ...
            'MaxHeadSize', 0.1);

end

