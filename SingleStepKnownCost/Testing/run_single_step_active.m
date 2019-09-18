close all; clear all; clc;
global config;
run_i = [4, 5];

for expi = 1:6
%     if expi ~= 4
%         continue;
%     end
    config.epsilon_greedy = false;
    for i = 1:30
%         if expi == 2 && i <= 28
%             continue;
%         end
    %     if ~isempty(find(run_i == i,1))
            benchmark = true;
            expname = strcat('exp_', num2str(expi));
            episode_name = strcat('softmax_', num2str(i));
            single_step_active;
    %     end
    end
end

% config.epsilon_greedy = true;
% % run_i = [7, 14];
% for i = 1:10
% %     if ~isempty(find(run_i == i,1))
%         benchmark = true;
%         expname = 'exp_1';
%         episode_name = strcat('epsilon_', num2str(i));
%         single_step_active;
% %     end
% end