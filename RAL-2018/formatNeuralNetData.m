function [input,target,big_data] = formatNeuralNetData(big_data,key,inputArray,trainingMode)
% File to format the data into input and target for neural net



% Now grab only the columns that we want
input = []; % I am well aware that this is inefficient. I care not.
for ii=1:size(inputArray,1)
    input = [input, big_data(:,inputArray(ii,1),inputArray(ii,2))];
end

% Now grab the column that corresponds to the output variable. 
% If this variable is in inputArray our job will be very easy...
if(strcmp(trainingMode,'position'))
    target = big_data(:,key.c.p2,key.r.filt);
    disp('Position');
elseif(strcmp(trainingMode,'torque'))
    target = big_data(:,key.c.T2,key.r.filt);
    disp('Torque');
elseif(strcmp(trainingMode,'backtorque'))
    target = big_data(:,key.c.T,key.r.filt);
    disp('Backend Torque');
else
    disp('SOMETHING IS WRONG WITH TRAINING MODE INPUT STRING');
end

% Transpose for the NN
input = input';
target = target';

end



