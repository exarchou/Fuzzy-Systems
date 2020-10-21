% Fuzzy Systems
% Dimitrios-Marios Exarchou 8805
% Group 3 - Ser08
% Superconductivity Dataset

tic

%% Clear.
%clear all;
close all;
clc;


%% Starting.
fprintf('\n Dimitrios-Marios Exarchou 8805 \n\n ######  %s  ###### \n\n', mfilename);


%% Reading.
load superconduct.csv
data = superconduct;


%% Normalizing.
for i = 1 : size(data,2) - 1
    
    data_min = min(data(:,i));
    data_max = max(data(:,i));
    
    data(:,i) = (data(:,i) - data_min) / (data_max - data_min);
    data(:,i) = data(:,i)*2 - 1;
    
end


%% Splitting.
N = length(data);
trainingData = data(1 : round(N*0.6) , :);
validationData = data(round(N*0.6) + 1 : round(N*0.8) , :);
checkData = data(round(N*0.8) + 1 : end , :);


%% Initializing.
NF = [3 6 9 12]; % Changed.
NR = [5 8 11 14 17]; % Changed.

radii = [0.505, 0.295, 0.265, 0.190, 0.141; % NF = 3
         0.480, 0.340, 0.230, 0.190, 0.120; % NF = 6
         0.522, 0.395, 0.233, 0.193, 0.157; % NF = 9
         0.605, 0.390, 0.315, 0.198, 0.185; % NF = 12
         ];

Error = zeros(length(NF), length(NR));
Rules = zeros(length(NF), length(NR));


%% Choosing Features.
X = data(:, 1:end-1); %Columns have not been shuffled.
y = data(:, end);
k = 10; % Nearest Neighbors
[idx, weights] = relieff(X, y, k);
save('idx.mat','idx.mat');


%% Grid Search.
for f = 1:length(NF)
    
    for r = 1:length(NR)
        
        fprintf('\nNumber of Features: %d', NF(f));
        fprintf('\nNumber of Rules: %d\n', NR(r));
          
        % Substractive CLustering fis = genfis2(Xin, Xout, radii) 
        % Input Data is the most important features from ReliefF
        fis = genfis2(trainingData(:,idx(1:NF(f))), trainingData(:,end), radii(f,r));
        Rules(f, r) = length(fis.rule);
        % Rules       
        
        %% 5-Fold Cross Validation.
        c = cvpartition(trainingData(:,end), 'KFold', 5);
        
        for i = 1:c.NumTestSets
            
            fprintf('\nFold #%d\n', i);
            trnID = c.training(i);
            tstID = c.test(i);
            
            trainingData_x = trainingData(trnID, idx(1:NF(f)));
            trainingData_y = trainingData(trnID, end);

            validationData_x = trainingData(tstID, idx(1:NF(f)));
            validationData_y = trainingData(tstID, end);
            
            
            %% Training with anfis.
            opt = anfisOptions;
            opt.InitialFIS = fis;
            opt.EpochNumber = 40;
            opt.DisplayANFISInformation = 0;
            opt.DisplayErrorValues = 0;
            opt.DisplayStepSize = 0;
            opt.DisplayFinalResults = 0;
            opt.ValidationData = [validationData_x validationData_y] ;

            [trnFIS,trainError,stepSize,chkFIS,chkError] = anfis([trainingData_x trainingData_y], opt);
            
            
            %% Evaluate with evalfis.
            output = evalfis(validationData(:,idx(1:NF(f))), chkFIS); 
            Error(f,r) = Error(f,r) + sum((output - validationData(:,end)).^ 2);
            
        end
        
        Error(f,r) = Error(f,r) / (c.NumTestSets * length(output));
        
    end
    
end

%% Calculate minimum Error.
f = NF(1);
r = NR(1);
E_min = Error(1,1);

for i= 1:length(NF)
    
    for j = 1:length(NR)
        
        if Error(i,j) < E_min
            
            f = i;
            r = j;
            E_min = Error(i,j);
            
        end
        
    end
    
end

Error
%r and f have the optimized values
fprintf('\n\n===================================\n\nOptimal feature number %d and rule number %d, with %d error.\n',NF(f),NR(r), E_min)


%% Plotting Error with NF and NR
figure(1)
subplot(2,2,1);
plot(NR, Error(1,:))
title('NF = 3')
subplot(2,2,2);
plot(NR, Error(2,:))
title('NF = 6')
subplot(2,2,3);
plot(NR, Error(3,:))
title('NF = 9')
subplot(2,2,4);
plot(NR, Error(4,:))
title('NF = 12')
suptitle('Error - NR relation');
saveas(gcf, 'ErrorNR.png');

figure(2)
subplot(2,3,1);
plot(NF, Error(:, 1))
title('NR = 5')
subplot(2,3,2);
plot(NF, Error(:, 2))
title('NR = 8')
subplot(2,3,3);
plot(NF, Error(:, 3))
title('NR = 11')
subplot(2,3,4);
plot(NF, Error(:, 4))
title('NR = 14')
subplot(2,3,5);
plot(NF, Error(:, 5))
title('NR = 17')
suptitle('Error - NF relation');
saveas(gcf, 'ErrorNF.png');

toc

save('Rules', 'Rules');

% Error =
% 
%     0.2925    0.2412    0.2301    0.2642    0.2891
%     0.1007    0.1034    0.1217    0.1330    0.1116
%     0.1151    0.1308    1.7088    1.7489    1.0597
%     0.0958    0.1630    0.1257    1.4249    1.1966

% Optimal feature number 12 and rule number 5, with 9.584394e+01 error.
% Elapsed time is 4264.860895 seconds.
            