% Fuzzy Systems
% Dimitrios-Marios Exarchou 8805
% Group 3 - Ser08
% Superconductivity Dataset

tic

%% Clear.
clear all;
close all;
clc;


%% Starting.
fprintf('\n Dimitrios-Marios Exarchou 8805 \n\n ######  %s  ######\n\n',mfilename);


%% Reading.
load superconduct.csv


%% TSK with NF = 12,NR = 5 and radii = 0.605
NF = 12;
radii = 0.605;


%% Shuffling Data.
shuffledData = zeros(size(superconduct));
shuffledIndex = randperm(length(superconduct)); % Array of random positions.

for i = 1:length(superconduct)
    shuffledData(i, :) = superconduct(shuffledIndex(i), :);
end


%% Splitting.
N = length(shuffledData);
trainingData = shuffledData(1 : round(N*0.6) , :);
validationData = shuffledData(round(N*0.6) + 1 : round(N*0.8) , :);
checkData = shuffledData(round(N*0.8) + 1 : end , :);


%% Normalizing.
for i = 1 : size(trainingData,2)
    
    data_min = min(trainingData(:,i));
    data_max = max(trainingData(:,i));
    trainingData(:,i) = (trainingData(:,i) - data_min) / (data_max - data_min); % Scaled to [0, 1]
    trainingData(:,i) = trainingData(:,i) * 2 - 1;

    validationData(:,i) = (validationData(:,i) - data_min) / (data_max - data_min); % Scaled to [0, 1]
    validationData(:,i) = validationData(:,i) * 2 - 1;

    checkData(:,i) = (checkData(:,i) - data_min) / (data_max - data_min); % Scaled to [0, 1]
    checkData(:,i) = checkData(:,i) * 2 - 1;
    
end


%% Choosing Features.
load ('idx.mat');

trainingData_x = trainingData(:, idx(1:NF));
trainingData_y = trainingData(:, end);

validationData_x = validationData(:, idx(1:NF));
validationData_y = validationData(:, end);

checkData_x = checkData(:, idx(1:NF));
checkData_y = checkData(:, end);


%% TSK Model with 15 Features and 5 Rules.
% Substractive CLustering. fismat = genfis2(Xin, Xout, radii) 
% Input Data is the most important features from ReliefF
fis = genfis2(trainingData_x, trainingData_y, radii);


%% Plotting initial MFs.
figure (); 
for i = 1:NF
    
    [x, mf] = plotmf(fis, 'input', i);% Returns the values without plotting them.
    plot(x,mf);
    hold on;
    
end
title('MFs before Training');  
saveas(gcf, 'HD_TSK_model/MFs_before_Training.png');

% The four most important inputs.
figure;
[x,mf] = plotmf(fis,'input',1); 
subplot(2,2,1)
plot(x,mf)
xlabel('input 1')

[x,mf] = plotmf(fis,'input',2);
subplot(2,2,2)
plot(x,mf)
xlabel('input 2')

[x,mf] = plotmf(fis,'input',3);
subplot(2,2,3)
plot(x,mf)
xlabel('input 3')

[x,mf] = plotmf(fis,'input',4);
subplot(2,2,4)
plot(x,mf)
xlabel('input 4')

suptitle('Some MFs before Training')
saveas(gcf, 'HD_TSK_model/Some_MFs_before_Training.png')


%% Training.
opt = anfisOptions;
opt.InitialFIS = fis;
opt.EpochNumber = 200;
opt.DisplayANFISInformation = 0;
opt.DisplayErrorValues = 0;
opt.ValidationData = [validationData_x validationData_y] ;
opt.DisplayStepSize = 0;
opt.DisplayFinalResults = 0;

[trnFIS,trainError,stepSize,chkFIS,chkError] = anfis([trainingData_x trainingData_y],opt);
%chkFIS is the trained FIS with minimum validation error.


%% Evaluating.
output = evalfis(checkData_x , chkFIS);


%% Efficiency Indicators.
error = checkData_y - output;
MSE = sum(error.^2)/length(error);
RMSE = sqrt(MSE);

SSres = sum((checkData_y - output).^2);
SStot = sum((checkData_y - mean(checkData_y)).^2);
R2 = 1 - SSres/SStot;

NMSE = 1 - R2;
NDEI = sqrt(NMSE);


%% Plotting final MFs.
figure;
[x,mf] = plotmf(chkFIS,'input',1);
subplot(2,2,1)
plot(x,mf)
xlabel('input 1')

[x,mf] = plotmf(chkFIS,'input',2);
subplot(2,2,2)
plot(x,mf)
xlabel('input 2')

[x,mf] = plotmf(chkFIS,'input',3);
subplot(2,2,3)
plot(x,mf)
xlabel('input 3')

[x,mf] = plotmf(chkFIS,'input',4);
subplot(2,2,4)
plot(x,mf)
xlabel('input 4')

suptitle('Some MFs after Training')
saveas(gcf, 'HD_TSK_model/Some_MFs_after_Training.png')


%% Plotting Learning Curves.
figure;
plot(1:length(trainError),trainError, 1:length(trainError),chkError)
title('Learning Curve')
legend('Traning Data', 'Check Data')
saveas(gcf,'HD_TSK_model/Learning_Curves.png')


%% Plotting Prediction Errors.
figure; 
plot(error)
title('Prediction Errors')
saveas(gcf,'HD_TSK_model/Error.png')  % AUTO ISWS BGEI


figure;
plot(1:length(checkData_x),checkData_y,'.r', 1:length(output),output,'.b')
title('Actual and Predicted Values')
legend('Actual','Predicted')
saveas(gcf,'HD_TSK_model/Actual_Predicted_.png')


%% Matrix of  Efficiency Indicators.
Errors = [ RMSE , NMSE , NDEI , R2]; 
fprintf('RMSE = %f  NMSE = %f  NDEI = %f  R2 = %f\n', RMSE, NMSE, NDEI, R2)

toc

% RMSE = 0.176894  NMSE = 0.229094  NDEI = 0.478638  R2 = 0.770906
% Elapsed time is 149.006165 seconds.