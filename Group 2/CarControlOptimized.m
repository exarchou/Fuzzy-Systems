% Fuzzy Systems 2019 - Group 2 
% Dimitrios-Marios Exarcou 8805
% Car Control Ser08 Optimized


%% Clear.
clear all;
close all;
clc;


%% Starting.
fprintf('\n Dimitrios-Marios Exarchou 8805 \n %s \n', mfilename);


%% Initialize.
x_init = 9;
y_init = -4.4;
u = 0.05;
thetas = [0 45 90];
x_desired = 15;
y_desired = -7.2;
threshold = 0.15;


%% Read fis.
carFIS = readfis('car_controller_optimized');


%% Plot membership functions.
figure;
subplot(2,2,1)
plotmf(carFIS, 'input', 1);
title('MF of dv');

subplot(2,2,2)
plotmf(carFIS, 'input', 2);
title('MF of dh');

subplot(2,2,3)
plotmf(carFIS, 'input', 3);
title('MF of theta');

subplot(2,2,4)
plotmf(carFIS, 'output', 1);
title('MF of delta_theta');


%% Route Simulation.
for i = 1 : 1 : length(thetas)
    
    x = x_init;
    y = y_init;
    theta = thetas(i);
	x_moves = []; 
    y_moves = [];
    
    flag = 1; % Variable to check if the car crossed the limits of the map.
    isClose = 0;
   
    while (flag == 1 && isClose == 0)
       
        % Calculating Distances.
        [dv, dh] =  distance_sensor(x, y);
        % Estimating Ouput.
        delta_theta = evalfis([dv dh theta], carFIS);
        theta = theta + delta_theta;
        % Movement.
        x = x + u * cosd(theta);
        y = y + u * sind(theta);
        % Check if car is inside the map.
        if (x < 0) || (x > 15) || (y > 0) || (y < -8)
            flag = 0;
        end
        % Update the position
        x_moves = [x_moves; x];
        y_moves = [y_moves; y];
        
        if (sqrt((abs(x-x_desired))^2 + (abs(y-y_desired))^2) < threshold)
            isClose = 1;
            fprintf("Vehicle just arrived in desired position\n");
        end
        
    end
    
    %% Creating Map.
    obstacle_x = [10; 10; 11; 11; 12; 12; 15];
    obstacle_y = [0; -5; -5; -6; -6; -7; -7];
    
    figure;
    line(x_moves, y_moves, 'Color', 'blue');
    line(obstacle_x, obstacle_y, 'Color', 'black');
    % Starting Position.
    hold on;
    plot(x_init, y_init, 'O');
    % Desired Position.
    hold on;
    plot(x_desired, y_desired, 'X');
    
    error_x = x_desired - x;
    error_y = y_desired - y;
    title(['Deegres: ', num2str(thetas(i))]);
    
end