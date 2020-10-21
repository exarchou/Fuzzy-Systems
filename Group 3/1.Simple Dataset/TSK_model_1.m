% Fuzzy Systems
% Dimitrios-Marios Exarchou 8805
% Group 3 - Ser08
% Combined Cycle Power Plant Dataset

tic

%% Clear.
clear all;
close all;
clc;


%% Starting.
fprintf('\n Dimitrios-Marios Exarchou 8805 \n %s \n',mfilename);


%% Reading.
load CCPP.dat
data = CCPP;


%% Normalizing.
for i = 1 : 5
    
    data_min = min(data(:,i));
    data_max = max(data(:,i));
    data(:,i) = (data(:,i) - data_min) / (data_max - data_min); % Scaled to [0, 1]
    data(:,i) = data(:,i) * 2 - 1;

end


%% Splitting.
N = length(data);
trainingData = data(1 : round(N*0.6) , :);
validationData = data(round(N*0.6) + 1 : round(N*0.8) , :);
checkData = data(round(N*0.8) + 1 : end , :);


%% Generating FIS with 2 MFs and Singleton Output.
opt = genfisOptions('GridPartition');
opt.NumMembershipFunctions = [2 2 2 2];
opt.InputMembershipFunctionType = ["gbellmf" "gbellmf" "gbellmf" "gbellmf"];
opt.OutputMembershipFunctionType = 'constant';

fis = genfis(trainingData(:,1:4), trainingData(:,5), opt);


%% Plotting initial MFs.
figure;

[x,mf] = plotmf(fis,'input',1); % Returns the values without plotting them.
subplot(2,2,1)
plot(x,mf)
xlabel('input 1: Temperature (T)')

[x,mf] = plotmf(fis,'input',2);
subplot(2,2,2)
plot(x,mf)
xlabel('input 2: Ambient Pressure (AP)')

[x,mf] = plotmf(fis,'input',3);
subplot(2,2,3)
plot(x,mf)
xlabel('input 3: Relative Humidity (RH)')

[x,mf] = plotmf(fis,'input',4);
subplot(2,2,4)
plot(x,mf)
xlabel('input 4: Exhaust Vacuum (V)')

suptitle('TSK model 1: MFs before Training')
saveas(gcf, 'TSK_model_1/MFs_before_Training.png')


%% Training.
opt = anfisOptions;
opt.InitialFIS = fis;
opt.EpochNumber = 200;
opt.DisplayANFISInformation = 0;
opt.DisplayErrorValues = 0;
opt.ValidationData = validationData;
opt.DisplayStepSize = 0;
opt.DisplayFinalResults = 0;

[trnFIS,trainError,stepSize,chkFIS,chkError] = anfis(trainingData,opt);
%chkFIS is the trained FIS with minimum validation error.


%% Evaluating.
output = evalfis(checkData(:,1:4) , chkFIS);


%% Efficiency Indicators.
error = checkData(:,5) - output;
MSE = sum(error.^2)/length(error);
RMSE = sqrt(MSE);

SSres = sum((checkData(:,5) - output).^2);
SStot = sum((checkData(:,5) - mean(checkData(:,5))).^2);
R2 = 1 - SSres/SStot;

NMSE = 1 - R2;
NDEI = sqrt(NMSE);


%% Plotting final MFs.
figure;

[x,mf] = plotmf(chkFIS,'input',1);
subplot(2,2,1)
plot(x,mf)
xlabel('input 1: Temperature (T)')

[x,mf] = plotmf(chkFIS,'input',2);
subplot(2,2,2)
plot(x,mf)
xlabel('input 2: Ambient Pressure (AP)')

[x,mf] = plotmf(chkFIS,'input',3);
subplot(2,2,3)
plot(x,mf)
xlabel('input 3: Relative Humidity (RH)')

[x,mf] = plotmf(chkFIS,'input',4);
subplot(2,2,4)
plot(x,mf)
xlabel('input 4: Exhaust Vacuum (V)')

suptitle('TSK model 1: MFs after Training')
saveas(gcf, 'TSK_model_1/MFs_after_Training.png')


%% Plotting Learning Curves.
figure;

plot(1:length(trainError),trainError, 1:length(trainError),chkError)
title('TSK model 1: Learning Curve')
legend('Traning Data', 'Check Data')
saveas(gcf,'TSK_model_1/Learning_Curves.png')


%% Plotting Prediction Errors.
figure; 

plot(error)
title('TSK model 1: Prediction Errors')
saveas(gcf,'TSK_model_1/Error.png')

figure;

plot(1:length(checkData),checkData(:,5),'.r', 1:length(output),output,'.b')
title('TSK model 1: Actual and Predicted Values')
legend('Actual','Predicted')
saveas(gcf,'TSK_model_1/Actual_Predicted_.png')


%% Matrix of  Efficiency Indicators.
Errors = [ RMSE , NMSE , NDEI , R2]; 
fprintf('RMSE = %f  NMSE = %f  NDEI = %f  R2 = %f\n', RMSE, NMSE, NDEI, R2)

toc

% RMSE = 0.114006  NMSE = 0.064144  NDEI = 0.253267  R2 = 0.935856
% Elapsed time is 13.337330 seconds.