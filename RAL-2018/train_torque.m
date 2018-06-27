%% This script is to create the Neural Networks for the RAL paper titled: %
%                                                                         %
%      Evaluation of Torque Measurement Surrogates as                     %
%     Applied to Grip Torque and Jaw Angle Estimation                     %
%                of Robotic Surgical Tools                                %
%                                                                         %
%  The script trains the neural networks used for Experiments 1 & 2       %
%                                                                         %
%  Note that this script will take several hours to run                   %
%                                                                         %

%% Set up a key
[ key ] = generateKey();

%% Constants

freqArray=(1:5)-1;
data_folder='../data/';
nn_folder=['Neural_Nets/'];
mkdir(nn_folder);
mkdir('Temp_Mats');
mkdir('Temp_Mats/data');

%% ALL THE TORQUES
folder = [data_folder 'Tool_4_Maryland_L_4'];
clear inputArray;
inputArray{1}=[key.c.p     ,key.r.filt;...       % Try Commanded Current
               key.c.p     ,key.r.difffilt;...
               key.c.cmd1  ,key.r.filt];
inputArray{2}=[key.c.p     ,key.r.filt;...       % Try Measured Current
               key.c.p     ,key.r.difffilt;...
               key.c.c     ,key.r.filt];
inputArray{3}=[key.c.p     ,key.r.filt;...       % Try gearbox differential
               key.c.p     ,key.r.difffilt;...
               key.c.pMaxonDiff,key.r.filt];
inputArray{4}=[key.c.p     ,key.r.filt;...       % Try torque sensor 
               key.c.p     ,key.r.difffilt;...   % (This will be silly for 'staged' NN)
               key.c.T     ,key.r.filt];
inputArray{5}=[key.c.p     ,key.r.filt;...       % Try All of the options
               key.c.p     ,key.r.difffilt;...
               key.c.cmd1  ,key.r.filt;...
               key.c.c     ,key.r.filt;...
               key.c.pMaxonDiff,key.r.filt];
outputArray={'position','torque','backtorque'};
jj = key.M4L4;
for ii=1:length(inputArray)
    for depVar=key.POS:key.BET
        fprintf('array %d of %d, and depVar %d', ii, length(inputArray), depVar);
        [NN{jj,depVar,ii},big_data{jj}] = neuralNetDriver(folder,inputArray{ii},freqArray,10,outputArray{depVar},1,0);
    end
end
%%
save([nn_folder 'Paper2_big_data.mat'],'big_data','key','-v7.3');
SaveNNArray(NN);
