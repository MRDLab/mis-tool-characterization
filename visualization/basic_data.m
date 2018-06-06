%% Set up some intial values
USE_LEFT_JAW = 1;
data_folder='../data/';

%% Go through the fixed roll/pitch/yaw data
freqArray=(1:5)-1;
numTorque=10;
folderName = [data_folder 'Tool_4_Maryland_L_4'];

[data,key] = compileData(folderName,freqArray,numTorque,USE_LEFT_JAW);

% concatenate all the grasps into one big matrix
big_data=[];
for ii = 1:length(freqArray)
    for jj = 0:numTorque - 1
        big_data=[big_data; data{numTorque*(ii-1)+jj+1}];
    end
end

%% Go through all the Roll data
folders={'Tool_4_Maryland_L_Roll_1',...
         'Tool_4_Maryland_L_Roll_2',...
         'Tool_4_Maryland_L_Roll_3',...
         'Tool_4_Maryland_L_Roll_4',...
         'Tool_4_Maryland_L_Roll_5'};
rollArray=[-90 -45 0 45 90]*pi/180;
pitchArray=[0 0 0 0 0]*pi/180;
freqArray=0;
yawArray=(1:5)-1;
numTorque=4;
for jj = 1:length(folders)
    folder = [data_folder folders{jj}];
    fprintf('folder %d of %d\n', jj, length(folders));
    [roll_data{jj},~] = compileDataRPY(folder,yawArray,freqArray,numTorque,USE_LEFT_JAW,rollArray(jj),pitchArray(jj));
end

% Now compile all the roll data into one big matrix
data=[];
for kk = 1:length(folders);
    for ii = 1:length(freqArray)
        for jj = 0:numTorque - 1
            data=[data; roll_data{kk}{numTorque*(ii-1)+jj+1}];
        end
    end
end
big_data_roll=data;
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
for jj = 1:length(folders)
    folder = [data_folder folders{jj}];
    fprintf('folder %d of %d\n', jj, length(folders));
    [pitch_data{jj},~] = compileDataRPY(folder,yawArray,freqArray,numTorque,USE_LEFT_JAW,rollArray(jj),pitchArray(jj));
end

% Now compile all the pitch data into one big matrix
data=[];
for kk = 1:length(folders)
    for ii = 1:length(freqArray)
        for jj = 0:numTorque - 1
            data=[data; pitch_data{kk}{numTorque*(ii-1)+jj+1}];
        end
    end
end
big_data_pitch=data;

%% Plot time series of each
plotOverview(big_data,key,'Fixed Roll, Pitch, Yaw');
plotOverview(big_data_roll,key,'Varied Roll & Yaw');
plotOverview(big_data_pitch,key,'Varied Pitch & Yaw');
