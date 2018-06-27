%% This script is to create the Neural Networks for the RAL paper titled: %
%                                                                         %
%      Evaluation of Torque Measurement Surrogates as                     %
%     Applied to Grip Torque and Jaw Angle Estimation                     %
%                of Robotic Surgical Tools                                %
%                                                                         %
%  The script trains the neural networks used for Experiment 3: Varied    %
%  Roll Pitch and Yaw.                                                    %
%                                                                         %
%  Note that this script will take several hours to run                   %
%                                                                         %

%% Set up a key
[ key ] = generateKey(true);

%% Constants

freqArray=0;
yawArray=(1:5)-1;
numTorque=4;
data_folder='../data/';
nn_folder=['Neural_Nets/'];
mkdir(nn_folder);
mkdir('Temp_Mats');
mkdir('Temp_Mats/data');

%% Set up input and output states
clear inputArray;
inputArray{1}=[key.c.p     ,key.r.filt;...
               key.c.p     ,key.r.difffilt;...
               key.c.cmd1  ,key.r.filt;...
               key.c.roll  ,key.r.raw;...
               key.c.pitch ,key.r.raw];
inputArray{2}=[key.c.p     ,key.r.filt;...
               key.c.p     ,key.r.difffilt;...
               key.c.c     ,key.r.filt;...
               key.c.roll  ,key.r.raw;...
               key.c.pitch ,key.r.raw];
inputArray{3}=[key.c.p     ,key.r.filt;...
               key.c.p     ,key.r.difffilt;...
               key.c.pMaxonDiff,key.r.filt;...
               key.c.roll  ,key.r.raw;...
               key.c.pitch ,key.r.raw];
inputArray{4}=[key.c.p     ,key.r.filt;...
               key.c.p     ,key.r.difffilt;...
               key.c.T     ,key.r.filt;...
               key.c.roll  ,key.r.raw;...
               key.c.pitch ,key.r.raw];
inputArray{5}=[key.c.p     ,key.r.filt;...       % Try All of the options
               key.c.p     ,key.r.difffilt;...
               key.c.cmd1  ,key.r.filt;...
               key.c.c     ,key.r.filt;...
               key.c.pMaxonDiff,key.r.filt;...
               key.c.roll  ,key.r.raw;...
               key.c.pitch ,key.r.raw];
outputArray={'position','torque'};

%% Go through all the Roll data
folders={'Tool_4_Maryland_L_Roll_1',...
         'Tool_4_Maryland_L_Roll_2',...
         'Tool_4_Maryland_L_Roll_3',...
         'Tool_4_Maryland_L_Roll_4',...
         'Tool_4_Maryland_L_Roll_5'};
rollArray=[-90 -45 0 45 90]*pi/180;
pitchArray=[0 0 0 0 0]*pi/180;
permutationArray=[1];
data=[];
for jj = 1:length(folders);
    folder = [data_folder folders{jj}];
    fprintf('folder %d of %d\n', jj, length(folders));
    [temp_data] = neuralNetData(folder,yawArray,freqArray,numTorque,1,0,rollArray(jj),pitchArray(jj));
    data=[data; temp_data];
    roll_data{jj}=temp_data;
end
big_data_sep{1}=data;

%% Now do the same for Pitch
folders={'Tool_4_Maryland_L_Pitch_1',...
         'Tool_4_Maryland_L_Pitch_2',...
         'Tool_4_Maryland_L_Pitch_3',...
         'Tool_4_Maryland_L_Pitch_4',...
         'Tool_4_Maryland_L_Pitch_5'};
rollArray=[0 0 0 0 0]*pi/180;
pitchArray=[60 30 0 -30 -60]*pi/180;
freqArray=0;%(1:2)-1;
yawArray=(1:2)-1;
numTorque=4;
data=[];
for jj = 1:length(folders)
    folder = [data_folder folders{jj}];
    fprintf('folder %d of %d\n', jj, length(folders));
    [temp_data] = neuralNetData(folder,yawArray,freqArray,numTorque,1,0,rollArray(jj),pitchArray(jj));
    data=[data; temp_data];
    pitch_data{jj}=temp_data;
end
big_data_sep{2}=data;
%% Put everything into a data variable for use later
big_data_rpy.full=[big_data_sep{1};big_data_sep{2}];
big_data_rpy.roll.full=big_data_sep{1};
big_data_rpy.pitch.full=big_data_sep{2};
big_data_rpy.control.full=[pitch_data{3}; roll_data{3}];
%big_data.roll.randomized=big_data.roll.full(randperm(length(big_data.roll.full)));

%% Now train them all together whynot

for ii=1:5
    for depVar=key.POS:key.TRQ
        %[NN{3,depVar,ii}, ~] = neuralNetDriverRPY(folder,inputArray{ii},freqArray,numTorque,outputArray{depVar}, key, big_data_rpy.control.full);
        [NN{4,depVar,ii}, ~] = neuralNetDriverRPY(folder,inputArray{ii},freqArray,numTorque,outputArray{depVar}, key, big_data_rpy.roll.full);
        [NN{5,depVar,ii}, ~] = neuralNetDriverRPY(folder,inputArray{ii},freqArray,numTorque,outputArray{depVar}, key, big_data_rpy.pitch.full);
    end
end

%%
%save([nn_folder 'Paper3_big_data.mat'],'big_data_rpy','key','-v7.3');
SaveNNArray(NN);
