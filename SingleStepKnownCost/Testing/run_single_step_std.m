close all; clear all; clc;
run_i = [3, 6];

for expi = 1:6
%     if expi ~= 4
%         continue;
%     end
    for i = 1:30
    %     if ~isempty(find(run_i == i,1))
            benchmark = true;
            expname = strcat('exp_', num2str(expi));
            episode_name = strcat('std_', num2str(i));
            single_step_standard;
    %     end
    end
end