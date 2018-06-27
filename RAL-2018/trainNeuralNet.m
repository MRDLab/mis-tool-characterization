function [net,tr,y,e] = trainNeuralNet(input,target,hiddenLayerSize)

% Solve an Input-Output Fitting problem with a Neural Network
% Used to estimate grip force and jaw angle on da vinci tool data
%

% Create a Fitting Network
net = fitnet(hiddenLayerSize);

use_gpu=false;

if use_gpu

    % Scaled Conjugate Gradient
    net.trainFcn = 'trainscg';

    net.trainParam.epochs = 10000;

    net.trainParam.min_grad = 1e-8;

    % Set up Division of Data for Training, Validation, Testing
    net.divideFcn = 'dividerand';
    net.divideParam.trainRatio = 70/100;
    net.divideParam.valRatio = 15/100;
    net.divideParam.testRatio = 15/100;

    net.inputs{1}.processFcns = {'removeconstantrows','mapminmax'};
    net.outputs{2}.processFcns = {'removeconstantrows','mapminmax'};

    % Set the activation functions
    net.layers{1}.transferFcn = 'logsig';
    net.layers{2}.transferFcn = 'purelin';

    % Set this to a positive number to exit training possibly sooner (prior to
    % optimal solution)
    net.trainParam.max_fail = 100;

    % net.performFcn = 'msereg';
    % net.performParam.regularization = 0.25;

    % Train the Network
    [net,tr,y,e] = train(net,input,target,'showResources','yes','useGPU','yes');
else

    % Baysian Regularization
    net.trainFcn = 'trainbr';

    net.trainParam.epochs = 3000;
    net.trainParam.show = 10;

    % net.trainParam.min_grad = 1e-6;
    
    % Set up Division of Data for Training, Validation, Testing
    net.divideFcn = 'dividerand';
    net.divideParam.trainRatio = 70/100;
    net.divideParam.valRatio = 15/100;
    net.divideParam.testRatio = 15/100;

    net.inputs{1}.processFcns = {'removeconstantrows','mapminmax'};
    net.outputs{2}.processFcns = {'removeconstantrows','mapminmax'};

    % Set the activation functions
    net.layers{1}.transferFcn = 'logsig';
    net.layers{2}.transferFcn = 'purelin';

    % Set this to a positive number to exit training possibly sooner (prior to
    % optimal solution)
    % net.trainParam.max_fail = 6;

    % net.performFcn = 'msereg';
    % net.performParam.regularization = 0.25;

    % Train the Network
    % [net,tr,y,e] = train(net,input,target,'showResources','yes','useGPU','yes');
    [net,tr,y,e] = train(net,input,target,'useParallel','yes');
end
 