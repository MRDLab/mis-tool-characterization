function [NN_Out, big_data] = neuralNetDriverRPY(folderName, inputArray, freqArray, numTorque, trainingMode, key, big_data)

hiddenLayerSize = 30;

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