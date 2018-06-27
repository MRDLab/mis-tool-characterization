function [big_data] = neuralNetData(folderName, yawArray, freqArray, numTorque, USE_LEFT_JAW, load_raw, roll, pitch)


USE_SEGMENTED_DATA = 1;


% Get all of the RAW data (not segmented at this point)
[A,B]=strtok(folderName,'/');
fullFileName = ['Temp_Mats/' B '.mat'];
if load_raw || exist(fullFileName, 'file')~=2
    [data,key] = compileDataRPY(folderName,yawArray,freqArray,numTorque,USE_LEFT_JAW,roll,pitch);
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
    for ii = 1:length(data)
        big_data=[big_data; data{ii}];
    end
    save(fullFileName,'big_data');
else
    load(fullFileName);
end


end

