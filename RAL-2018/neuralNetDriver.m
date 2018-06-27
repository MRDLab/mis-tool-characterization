function [NN_Out, big_data] = neuralNetDriver(folderName, inputArray, freqArray, numTorque, trainingMode, USE_LEFT_JAW, load_raw)

% Parameters for the file to run
if nargin < 2 % If freq and torque not given, assume defaults
    freqArray = 0:4;
    numTorque = 4;

    % IMPORTANT: Set these to true or false depending on preferences
    USE_LEFT_JAW = 1;

    % Position or torque
    % trainingMode = 'torque';
    trainingMode = 'position';
end
USE_SEGMENTED_DATA = 1;
hiddenLayerSize = 30;

% Use parallel computing (hopefully)
% pool = parpool;
% pool.NumWorkers

% Get all of the RAW data (not segmented at this point)
[A,B]=strtok(folderName,'/');
fullFileName = ['Temp_Mats/' B '.mat'];
if load_raw || exist(fullFileName, 'file')~=2
    [data,key] = compileData(folderName,freqArray,numTorque,USE_LEFT_JAW);
    save(fullFileName,'data','key');
else
    load(fullFileName);
end


fullFileName = ['Temp_Mats/' B '_Segmented.mat'];
if load_raw || exist(fullFileName, 'file')~=2
    % OPTIONAL: Segment data based on certain criteria (eg-closing portion)
    if (USE_SEGMENTED_DATA)
        velThresh = 0.25; % This is the minimum velocity to segment out closing portions of grasps
        timeThreshStart = 1; % This is the time portion of the grasp you want to eliminate
        timeThreshEnd = 1; % This is the time portion of the grasp you want to eliminate
        [data] = segmentData(data,key,freqArray,numTorque,velThresh,timeThreshStart,timeThreshEnd);
    end

    % concatenate all the grasps into one big 'un
    big_data=[]; % I am well aware that this is inefficient. I care not.
    for ii = 1:length(freqArray)
        for jj = 0:numTorque - 1
            big_data=[big_data; data{numTorque*(ii-1)+jj+1}];
        end
    end
    save(fullFileName,'big_data');
else
    load(fullFileName);
end


% Format the data into the inputs/target for Neural network
[input,target] = formatNeuralNetData(big_data,key,inputArray,trainingMode);

% Plot data on linked axes
% plotLinkedData(input,target,['Output ' trainingMode]);
% estimate = 1;
% true = 1;
% net = 1;
% tr = 1;

% Train the neural net
[net,tr,y,e] = trainNeuralNet(input,target,hiddenLayerSize);
% Validate the neural net
[estimate,true] = validateNetwork(net,tr,input,target);
% 
% % Plot our estimate and our true
% figure;
% plot(estimate,'b');
% hold on;
% plot(true,'r');
% 
% figure;
% plot(abs(estimate-true));
% xlabel('Sample Num');
% ylabel('Torque (N-m)');
% title('Absolute Error');

fprintf('Average Absolute Error = %4.7f\n',mean(abs(estimate-true)));
NN_Out.input=input;
NN_Out.target=target;
NN_Out.estimate=estimate;
NN_Out.true=true;
NN_Out.net=net;
NN_Out.tr=tr;
NN_Out.folderName=folderName;
NN_Out.parameters.numFreq = freqArray;
NN_Out.parameters.inputArray = inputArray;
NN_Out.parameters.numTorque = numTorque;
NN_Out.parameters.hiddenLayerSize = hiddenLayerSize;


end