clc;
clear;
close all;

% 桌面尺寸和目标点设置
workspace = [0, 100; 0, 100];
table = [10, 10, 80, 80];
start_point = [20, 20];
players = [20, 10; 50, 10; 80, 10; 20, 90; 50, 90; 80, 90];
target_player = 5;
goal_point = players(target_player, :);

% 定义障碍物
obstacles = [
    30, 40, 10, 20;
    60, 30, 15, 10;
    50, 70, 20, 10
];

% 参数设置
max_iter = 500;
step_size = 5;

% 初始化两棵树
T_start = start_point;
T_goal = goal_point;
parent_start = 0;  % T_start 的父节点索引
parent_goal = 0;   % T_goal 的父节点索引
path_found = false;

% 绘制桌面
figure;
hold on;
axis([workspace(1, 1), workspace(1, 2), workspace(2, 1), workspace(2, 2)]);
rectangle('Position', table, 'EdgeColor', 'k', 'LineWidth', 2, 'FaceColor', [0.9, 0.9, 0.9]);
rectangle('Position', [start_point - [2, 2], 4, 4], 'FaceColor', 'g', 'EdgeColor', 'k');
rectangle('Position', [goal_point - [2, 2], 4, 4], 'FaceColor', 'r', 'EdgeColor', 'k');
for i = 1:size(players, 1)
    plot(players(i, 1), players(i, 2), 'o', 'MarkerSize', 8, 'MarkerFaceColor', 'b', 'MarkerEdgeColor', 'k');
end
for i = 1:size(obstacles, 1)
    rectangle('Position', obstacles(i, :), 'FaceColor', [0.5, 0.5, 0.5], 'EdgeColor', 'k');
end
title('RRT-Connect with B-Spline Smoothing');
xlabel('X (cm)');
ylabel('Y (cm)');

% 主循环
for iter = 1:max_iter
    % 随机采样点
    random_point = [rand * 100, rand * 100];
    
    % 从 T_start 扩展
    [q_near_idx, q_near] = nearestNode(T_start, random_point);
    q_new = steer(q_near, random_point, step_size);
    if isCollision(q_new, obstacles) || ~inWorkspace(q_new, table)
        continue;
    end
    T_start = [T_start; q_new];
    parent_start = [parent_start; q_near_idx];
    line([q_near(1), q_new(1)], [q_near(2), q_new(2)], 'Color', 'b');
    drawnow;
    
    % 尝试连接到 T_goal
    [q_near_goal_idx, q_near_goal] = nearestNode(T_goal, q_new);
    q_connect = steer(q_near_goal, q_new, step_size);
    if ~isCollision(q_connect, obstacles) && norm(q_connect - q_new) < step_size
        T_goal = [T_goal; q_connect];
        parent_goal = [parent_goal; q_near_goal_idx];
        path_found = true;
        break;
    end
    
    % 交换树
    [T_start, T_goal] = deal(T_goal, T_start);
    [parent_start, parent_goal] = deal(parent_goal, parent_start);
end

% 绘制路径
if path_found
    disp('Path found using RRT-Connect!');
    path = plotPath(T_start, T_goal, parent_start, parent_goal);
    
    % B样条平滑路径
    smoothPath = bsplineSmooth(path);
    plot(smoothPath(:, 1), smoothPath(:, 2), 'r', 'LineWidth', 2);
else
    disp('Failed to find a path.');
end

% ---- Helper Functions ----
function [idx, q_near] = nearestNode(tree, point)
    distances = sqrt(sum((tree - point).^2, 2));
    [~, idx] = min(distances);
    q_near = tree(idx, :);
end

function q_new = steer(q_near, q_rand, step)
    direction = (q_rand - q_near) / norm(q_rand - q_near);
    q_new = q_near + step * direction;
end

function in = inWorkspace(point, table)
    in = point(1) >= table(1) && point(1) <= table(1) + table(3) && ...
         point(2) >= table(2) && point(2) <= table(2) + table(4);
end

function path = plotPath(T_start, T_goal, parent_start, parent_goal)
    path = [];
    current_idx = size(T_start, 1);
    while current_idx > 0
        path = [T_start(current_idx, :); path];
        current_idx = parent_start(current_idx);
    end
    current_idx = size(T_goal, 1);
    while current_idx > 0
        path = [path; T_goal(current_idx, :)];
        current_idx = parent_goal(current_idx);
    end
    plot(path(:, 1), path(:, 2), 'g', 'LineWidth', 2);
end

function collision = isCollision(point, obstacles)
    collision = false;
    for i = 1:size(obstacles, 1)
        obs = obstacles(i, :);
        if point(1) > obs(1) && point(1) < obs(1) + obs(3) && ...
           point(2) > obs(2) && point(2) < obs(2) + obs(4)
            collision = true;
            break;
        end
    end
end

function smoothPath = bsplineSmooth(path)
    t = 1:size(path, 1);
    t_interp = linspace(1, size(path, 1), 100); % 增加采样点
    x_smooth = spline(t, path(:, 1), t_interp);
    y_smooth = spline(t, path(:, 2), t_interp);
    smoothPath = [x_smooth', y_smooth'];
end
