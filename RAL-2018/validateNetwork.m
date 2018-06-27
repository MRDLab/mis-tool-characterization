function [estimate,true] = validateNetwork(net,tr,input,target)

% Test the Network
estimate = net(input(:,tr.testInd));

true = target(tr.testInd);

end