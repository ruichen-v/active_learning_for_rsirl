function ret_V = suppressV(V)
processed = {};
for i = 1:size(V, 1)
    v = V(i, :);
    j = 1;
    while j <= size(processed, 2) && norm(v - processed{j}(1,:)) > 1e-3
        j = j+1;
    end
    if j > size(processed, 2)
        processed{end+1} = v;
    else
        processed{j} = [processed{j}; v];
    end
end
ret_V = [];
for i = 1:size(processed, 2)
    ret_V = [ret_V; mean(processed{i},1)];
end
end

