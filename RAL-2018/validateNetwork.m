function [estimate,true] = validateNetwork(net,tr,input,target)

% Test the Network
if exist('trainNetwork')>0
    % We have the neural net toolbox, so we can use it
    estimate=net(input(:,tr.testInd));
else
    estimate=sim_net_manual_array(net,input(:,tr.testInd));
end

true = target(tr.testInd);

end