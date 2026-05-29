% 初始化图形窗口
figure;
axis equal;
hold on;
axis([-4, 4, -4, 6]); % 设置显示范围
axis off;

% 定义绘制机器人和卡片的函数
function draw_robot_with_stack(card_positions, current_card_x, roller_angle)
    cla; % 清除当前图形

    % 绘制机器人身体和出卡口
    rectangle('Position', [-2, -2, 4, 4], 'Curvature', [1, 1], 'FaceColor', [0.8, 0.8, 0.8]); % 身体
    rectangle('Position', [-1.2, 2.2, 2.4, 2.4], 'Curvature', [1, 1], 'FaceColor', [0.8, 0.8, 0.8]); % 头部
    rectangle('Position', [-0.5, -1.8, 1, 0.2], 'FaceColor', [0.3, 0.3, 0.3]); % 出卡口

    % 绘制脸部屏幕
    rectangle('Position', [-0.8, 3.6, 1.6, 0.6], 'FaceColor', [0, 0, 0]); % 屏幕
    rectangle('Position', [-0.5, 3.8, 0.3, 0.3], 'Curvature', [1, 1], 'FaceColor', [1, 1, 1]); % 左眼
    rectangle('Position', [0.2, 3.8, 0.3, 0.3], 'Curvature', [1, 1], 'FaceColor', [1, 1, 1]); % 右眼
    line([-0.4, 0.4], [3.5, 3.5], 'Color', [1, 1, 1], 'LineWidth', 2); % 嘴巴

    % 绘制滚轮（左）
    rectangle('Position', [-1.0, -1.9, 0.3, 0.3], 'Curvature', [1, 1], ...
              'FaceColor', [0.5, 0.5, 0.5], 'EdgeColor', 'none');
    line([-0.85, -0.85 + 0.2*cosd(roller_angle)], ...
         [-1.75, -1.75 + 0.2*sind(roller_angle)], 'Color', 'k', 'LineWidth', 2); % 滚轮旋转效果

    % 绘制滚轮（右）
    rectangle('Position', [0.7, -1.9, 0.3, 0.3], 'Curvature', [1, 1], ...
              'FaceColor', [0.5, 0.5, 0.5], 'EdgeColor', 'none');
    line([0.85, 0.85 + 0.2*cosd(roller_angle)], ...
         [-1.75, -1.75 + 0.2*sind(roller_angle)], 'Color', 'k', 'LineWidth', 2); % 滚轮旋转效果

    % 绘制剩余卡片堆叠在滚轮上
    for i = 1:length(card_positions)
        rectangle('Position', [-0.8, -1.8 + 0.15 * (i - 1), 1.6, 0.1], ...
                  'FaceColor', [0, 0.4, 0.8], 'EdgeColor', 'none'); % 卡片
    end

    % 绘制正在推出的卡片
    rectangle('Position', [current_card_x, -1.7, 1, 0.2], ...
              'FaceColor', [0, 0.4, 0.8], 'EdgeColor', 'none'); % 推出的卡片
end

% 初始化卡片存储
num_cards = 20;           % 卡片数量
card_positions = 1:num_cards; % 卡片编号
initial_x = -0.5;         % 出口初始x位置
final_x = -3.5;            % 卡片最终推出位置
num_steps = 50;           % 每张卡片推出的动画帧数
roller_angles = linspace(0, 360, num_steps); % 滚轮旋转角度

% 模拟20张卡片依次推出
for card_idx = 1:num_cards
    % 动态模拟当前卡片的推出
    x_positions = linspace(initial_x, final_x, num_steps); % 卡片的运动轨迹
    for i = 1:num_steps
        draw_robot_with_stack(card_positions, x_positions(i), roller_angles(i)); % 绘制每一帧
        pause(0.03); % 动画帧间隔
    end

    % 移除已推出的卡片
    card_positions(1) = []; % 删除最顶部的卡片
end

% 最终画面
draw_robot_with_stack(card_positions, final_x, roller_angles(end));
