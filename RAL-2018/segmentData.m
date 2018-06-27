function [data] = segmentData(data,key,freqArray,numTorque,closingGraspThresh,startTimeThresh,endTimeThresh)

% File to segment the data

% Set the velocity threshold to negative if using left jaw
closingGraspThresh = -abs(closingGraspThresh);

% If closingGraspThresh = inf then DO NOT segment into closing grasps!
if(closingGraspThresh == inf)
    segmentClosingGrasp = false;
else
    segmentClosingGrasp = true;
end

for ii = 1:length(data)
    % Grab a temp variable, for sanity
    tempdata = data{ii};

    % Segment the data based on start time
    tempdata = tempdata(tempdata(:,key.c.t,key.r.raw) >= startTimeThresh,:,:);

    % Segment the data based on end time
    endTime = tempdata(end,key.c.t,key.r.raw) - endTimeThresh;
    tempdata = tempdata(tempdata(:,key.c.t,key.r.raw) <= endTime,:,:);

    % Truncate so only have the closing portion of grasp
    if(segmentClosingGrasp)
        tempdata = tempdata(tempdata(:,key.c.p,key.r.difffilt) <= closingGraspThresh,:,:);
    end

    data{ii} = tempdata;
end

end



