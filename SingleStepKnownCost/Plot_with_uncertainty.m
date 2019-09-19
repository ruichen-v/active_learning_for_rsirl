% Copyright (c) 2019 Rui Chen
%
% This work is licensed under the terms of the MIT license.
% For a copy, see <https://opensource.org/licenses/MIT>.

function ax = Plot_with_uncertainty(x, y, dy, color)
    x = reshape(x, [], 1);
    y = reshape(y, [], 1);
    dy = reshape(dy, [], 1);
    
    vy = [y-dy;flipud(y+dy)]; vy(vy<0) = 0;
    
    v = [[x;flipud(x)], vy];
    f = 1:size(v, 1);
    patch('Faces', f,'Vertices', v, 'FaceColor', color, 'FaceAlpha', 0.2, ...
          'EdgeColor', color, 'LineStyle', ':', 'LineWidth', 1);
    ax = line(x, y, 'Color', color, 'LineWidth', 2);
end

