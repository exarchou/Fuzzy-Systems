% Fuzzy Systems
% ® Dimitrios-Marios Exarchou 8805
% Group 4 - Ser04
% Isolet Dataset

tic

%% Clear.
clear all;
close all;
clc;


%% Starting.
fprintf('\n® Dimitrios - Marios Exarchou 8805 \n\n ##### %s #####\n',mfilename);


%% Reading.
load isolet.dat
data = isolet;
%Isolet Dataset has 26 different Classes.
classes = 26;


%% Preproccessing
% Skipping same rows.
temp_data = unique(data,'rows');
data = temp_data;



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
    validationData = vertcat(validationData, class{i}(round(0.6*size(class{i},1))+1:round(0.8*size(class{i},1)), :));
    checkData = vertcat(checkData, class{i}(round(0.8*size(class{i},1))+1:end, :));
    
end


%% Choosing Features.
X = data(:, 1:end-1); %Columns have not been shuffled.
y = data(:, end);
k = 200; % Nearest Neighbors
[idx, weights] = relieff(X, y, k);
save('idx','idx');



%% Initializing.
NF = [3 8 13 18]; 
NR = [6 8 10 13 15]; % Changed.
          
radii = [0.550, 0.430, 0.320, 0.246, 0.220;
         0.850, 0.560, 0.475, 0.280, 0.262;
         0.680, 0.550, 0.480, 0.380, 0.330;
         0.920, 0.680, 0.520, 0.415, 0.350;
         ];
     

Rules = zeros(length(NF), length(NR));
Accuracy = zeros(length(NF), length(NR));
Error = zeros(length(NF), length(NR));
      
 

%% Grid Search.
for f = 1:length(NF)
    
    for r = 1:length(NR)
               
        fprintf('\n *** Number of Features: %d ***', NF(f));
        fprintf('\n *** Number of Rules: %d ***\n', NR(r));
        
        
        %% Find Minimum-Maximum for each column.
        xBounds = zeros(2, NF(f)+1);
        
        for i = 1:NF(f)
            
            trainingData_min = min(trainingData(:,idx(i)));
            trainingData_max = max(trainingData(:,idx(i)));
    
            xBounds(1,i) = trainingData_min;
            xBounds(2,i) = trainingData_max;
            
        end
        xBounds(1,NF(f)+1) = min(trainingData(:,end));
        xBounds(2,NF(f)+1) = max(trainingData(:,end));
        

        %% Generating FIS.
        opt = [0.75 0.70 0.125 0];
        fis = genfis2(trainingData(:,idx(1:NF(f))), trainingData(:,end), radii(f,r), xBounds, opt);
        
        Rules(f, r) = length(fis.rule);
        % Rules
               
        %% Changing Output to constant.
        for i = 1:length(fis.output.mf)
            
            fis.output.mf(i).type = 'constant';
            fis.output.mf(i).params = rand(); 
            
        end
               
        
        %% 5-Fold Cross Validation.
        c = cvpartition(trainingData(:,end), 'KFold', 5);
        
        for i = 1:c.NumTestSets
            
            fprintf('\n *** Fold #%d ***\n', i);
            trnID = c.training(i);
            tstID = c.test(i);
            
            trainingData_x = trainingData(trnID, idx(1:NF(f)));
            trainingData_y = trainingData(trnID, end);
        
            validationData_x = trainingData(tstID, idx(1:NF(f)));
            validationData_y = trainingData(tstID, end);
            
            
            %% Training with anfis.
            opt = anfisOptions;
            opt.InitialFIS = fis;
            opt.EpochNumber = 50;
            opt.DisplayANFISInformation = 0;
            opt.DisplayErrorValues = 0;
            opt.DisplayStepSize = 0;
            opt.DisplayFinalResults = 0;
            opt.ValidationData = [validationData_x validationData_y] ;

            [trnFIS,trainError,stepSize,chkFIS,chkError] = anfis([trainingData_x trainingData_y], opt);
            
            
            %% Evaluate with evalfis.
            output = round(evalfis(validationData(:,idx(1:NF(f))), chkFIS)); 
            
            % Boundary Conditions.
            if (output < 1)
                
                output = 1;
                
            elseif (output > classes)
                
                output = classes;
                
            end  
            
            
            %% Accuracy.
            ConfusionMatrix = confusionmat(validationData(:,end), output);
            N = length(validationData(:,end));
            
            for j = 1:classes
                
                Accuracy(f,r) = Accuracy(f,r) + ConfusionMatrix(j,j);
                
            end
            
            Accuracy(f,r) = Accuracy(f,r)/N;
            Error(f,r) = Error(f,r)+ (1 - Accuracy(f,r));
            
        end
        
        Error(f,r) = Error(f,r)/(c.NumTestSets);
        
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

fprintf('\n===================================================');
Error
fprintf('===================================================\n\nOptimal feature number %d and rule number %d, with %d error.\n',NF(f),NR(r), E_min)


%% Plotting Error with NF and NR
figure(1)
subplot(2,2,1);
plot(NR, Error(1,:))
title('NF = 3')
subplot(2,2,2);
plot(NR, Error(2,:))
title('NF = 8')
subplot(2,2,3);
plot(NR, Error(3,:))
title('NF = 13')
subplot(2,2,4);
plot(NR, Error(4,:))
title('NF = 18')
suptitle('Error - NR relation');
saveas(gcf, 'ErrorNR.png');

figure(2)
subplot(2,3,1);
plot(NF, Error(:, 1))
title('NR = 6')
subplot(2,3,2);
plot(NF, Error(:, 2))
title('NR = 8')
subplot(2,3,3);
plot(NF, Error(:, 3))
title('NR = 10')
subplot(2,3,4);
plot(NF, Error(:, 4))
title('NR = 13')
subplot(2,3,5);
plot(NF, Error(:, 5))
title('NR = 15')
suptitle('Error - NF relation');
saveas(gcf, 'ErrorNF.png');

toc

% ===================================================
% Error =
% 
%     0.9603    0.9602    0.9573    0.9657    0.9639
%     0.9588    0.9434    0.9535    0.9419    0.9555
%     0.9403    0.9223    0.9243    0.9334    0.9399
%     0.9390    0.9370    0.9125    0.9032    0.9618
% 
% ===================================================
% 
% Optimal feature number 18 and rule number 13, with 9.032196e-01 error.
% Radii = 0.415
% Elapsed time is 1252.800718 seconds.
