% Fuzzy Systems
% Dimitrios-Marios Exarchou 8805
% Group 4 - Ser04
% Avila Dataset

tic

%% Clearing.
clear all;
close all;
clc;


%% Starting.
fprintf('\n Dimitrios-Marios Exarchou 8805 \n #####  %s  #####\n', mfilename);


%% Reading.
% Avila Dataset has 12 different classes.
load avila.txt
data = avila;
classes = 12;


%% Preproccessing.
% Skipping same rows.
temp_data = unique(data, 'rows');
data = temp_data;


%% Shuffling Data.
rng (0);
shuffledData = zeros(size(data));
shuffledIndex = randperm(length(data)); % Array of random positions.

for r = 1:length(data)
    
    shuffledData(r, :) = data(shuffledIndex(r), :);
    
end

data = shuffledData;


%% Normalizing.
for i = 1 : size(data,2) - 1
    
    data_min = min(data(:,i));
    data_max = max(data(:,i));
    
    data(:,i) = (data(:,i) - data_min) / (data_max - data_min);
    data(:,i) = data(:,i)*2 - 1;
    
end


%% Splitting.
class = cell(1, classes);

for i = 1:classes  
    
    class{i} = data(data(:,end) == i, :);
    
end

trainingData = [];
validationData = [];
checkData = [];

for i = 1:classes
    
    trainingData =  vertcat(trainingData, class{i}(1:round(0.6*size(class{i},1)) , :));
    validationData = vertcat(validationData, class{i}(round(0.6*size(class{i},1))+1:round(0.8*size(class{i},1)),:));
    checkData = vertcat(checkData, class{i}(round(0.8*size(class{i},1))+1:end,:));
    
end




%% Find Minimum-Maximum for each column.
xBounds = zeros(2, size(data,2));

for i = 1 : size(data,2)
    
    trainingData_min = min(trainingData(:,i));
    trainingData_max = max(trainingData(:,i));
    
    xBounds(1,i) = trainingData_min;
    xBounds(2,i) = trainingData_max;
    
end


%% Initializations.
NR = [4 8 12 16 19];
radii = [0.90 0.41 0.31 0.26 0.22];
Rules = zeros(1, length(NR));

ErrorMatrix = cell(1, length(NR)); % Contains 5 12x12 arrays
OA = zeros(1, length(NR));
PA = cell(1, length(NR)); % Contains 5 12x12 arrays
UA = cell(1, length(NR));
k = zeros(1, length(NR));
AvPA = zeros(1, length(NR));
AvUA = zeros(1, length(NR));


%% Create 5 TSK Models with different number of Rules.
for r = 1:length(NR)
    
    fprintf('\n ### TSK Model with %d rules. ###\n' ,NR(r));
    
    %% Generating FIS.
    
    %     opt = genfisOptions('SubtractiveClustering');
    %     opt.ClusterInfluenceRange = radii(r);
    %     opt.DataScale = xBounds;
    %     opt.SquashFactor = 0.4;
    %     opt.AcceptRatio = 0.61;
    %     opt.RejectRatio = 0.055;
    %     opt.Verbose = false;
    %     fis = genfis(trainingData(:,1:end-1), trainingData(:,end), opt);
    
    opt = [0.5 0.61 0.055 0];
    fis = genfis2(trainingData(:,1:end-1), trainingData(:,end), radii(r), xBounds, opt);
    Rules(r) = length(fis.rule);
    % Rules
    
    
    %% Changing Output to constant.
    for i = 1:length(fis.output.mf)
        
        fis.output.mf(i).type = 'constant';
        fis.output.mf(i).params = rand(); 
        
    end
      
    
    %% Plotting MFs before Training.
    figure ();
    for i = 1:size(data,2)-1
        
        [x, mf] = plotmf(fis, 'input', i);
        plot(x,mf);
        hold on;
        
    end
    
    xlabel('x');
    ylabel('Degree of MF');
    title(['TSK model ', num2str(r),': MFs before Training'])
    fileName = sprintf('TSK_model_%d/MFs_before_Training.png' ,r);
    saveas(gcf, fileName);

       
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
    output = round(evalfis(checkData(:,1:end-1) , chkFIS)); % Output has to be rounded to the nearest integer.
    % Boundary Conditions.
    if (output < 1)
        
        output = 1;
        
    elseif (output > 12)
        
        output = 12;
        
    end
    
    %% Efficiency Indicators.
    %Confusion Matrix.
    ErrorMatrix{r} = confusionmat(checkData(:,end), output);
    ConfusionMatrix = ErrorMatrix{r};
    N = length(checkData);
    
    % Overall Accuracy.
    for i = 1:classes
        
        OA(r) = OA(r) + ConfusionMatrix(i,i);
        
    end
    OA(r) = OA(r)/N;
    
    %Producer's and User's Accuracy.
    PAtemp = zeros(1, classes);
    UAtemp = zeros(1, classes);
    
    for i = 1:length(NR)
        % Probavility of correctly classification in a known Class.
        PAtemp(i) = ConfusionMatrix(i,i)/sum(ConfusionMatrix(:,i));
        % Probavility of correctly classification of a predicted Class.
        UAtemp(i) = ConfusionMatrix(i,i)/sum(ConfusionMatrix(i,:));
        
    end
    
    PA{r} = PAtemp;
    UA{r} = UAtemp;   
    %k Indicator.
    colSums = sum(ConfusionMatrix, 1);
    rowSums = sum(ConfusionMatrix, 2);
    crossSum = 0;
    
    for i = 1:classes
        
        crossSum = rowSums(i)*colSums(i);
        
    end
    
    k(r) = (OA(r)-crossSum/N^2) / (1-crossSum/N^2);
    
        
    %% Plotting MFs after Training.
    figure ();
    for i = 1:size(data,2)-1
        
        [x, mf] = plotmf(chkFIS, 'input', i);
        subplot(2,5,i);
        plot(x,mf);
        str = sprintf('Input %d',i);
        xlabel(str);
        
    end
    str = sprintf('TSK model %d: MFs after Training', r);
    suptitle(str);
    fileName = sprintf('TSK_model_%d/MFs_after_Training.png', r);
    saveas(gcf, fileName);

    
    
    %% Plotting Learning Curves.
    figure ();
    plot(1:length(trainError),trainError, 1:length(trainError),chkError)
    title(['TSK model ', num2str(r),': Learning Curve'])
    xlabel('Iterations');
    ylabel('Error');
    legend('Traning Data', 'Check Data')
    fileName = sprintf('TSK_model_%d/Learning_Curves.png' ,r);
    saveas(gcf, fileName);

end


%% Plotting Error Metrics.
figure;
bar(NR(1:length(NR)), OA*100)
xlabel('Number of rules');
ylabel('Accuracy %');
title('Overall Accuracy depending on Number of Rules');
saveas(gcf, 'Accuracy ~ Rules.png');

figure;
bar(NR(1:length(NR)), k*100)
xlabel('Number of rules');
ylabel('k %');
title('k depending on Number of Rules');
saveas(gcf, 'k ~ Rules.png');

% Finding average PA and UA
for i = 1:5
    
    ProdAcc = PA{i};
    UsAcc = UA{i};
    
    ProdAcc(isnan(ProdAcc)) = 0;
    UsAcc(isnan(UsAcc)) = 0;

    AvPA(i) = mean(ProdAcc);
    AvUA(i) = mean(UsAcc);
    
end

figure;
bar(NR(1:length(NR)), AvPA*100)
xlabel('Number of rules');
ylabel('Average Producers Accuracy %');
title('PA depending on Number of Rules');
saveas(gcf, 'PA ~ Rules.png');

figure;
bar(NR(1:length(NR)), AvUA*100)
xlabel('Number of rules');
ylabel('Average Users Accuracy %');
title('UA depending on Number of Rules');
saveas(gcf, 'UA ~ Rules.png');

% OA*100
% AvPA*100
% AvUA*100
% k*100

toc

% OA =      7.0419    8.7425    8.6707   11.6407   13.1737
% AvPA =    5.5164    6.3887    7.5126    7.5292    7.7108  
% AvUA =    0.2285    1.0318    0.5786    0.5008    1.0483
% k =       6.9142    8.7300    8.5539   11.3426   13.1647
% Elapsed time is 629.269114 seconds.