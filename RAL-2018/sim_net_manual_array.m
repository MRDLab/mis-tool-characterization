function out = sim_net_manual_array(net,x)
% This function is designed to run a NN without the toolbox
% This version runs on a whole array using matrix multiplication, which is
% significantly faster for MATLAB
% 
% Warning: This function is only programmed to work with a narrow subset 
% of NN objects.

IW=net.IW{1};
LW=net.LW{2};
b1=net.b{1};
b2=net.b{2};
if(net.numLayers>2)
    LW2=net.LW{3,2};
    b3=net.b{3};
end

%%# manually simulate network
%# map input to [-1,1] range
xrange=net.inputs{1}.range;
yrange=net.outputs{end,end}.range;

%%# manually simulate network
%# map input to [-1,1] range
P=(xrange(:,2)-xrange(:,1));
Q=(xrange(:,2)+xrange(:,1));

in = (x * 2.0 - Q )./ P;

%# propagate values to get output (scaled to [-1,1])
hid = IW * in + b1;
if(strcmp(net.layers{1}.transferFcn,'tansig'))
    hid = (2 ./ (1 + exp(-2*hid)) - 1);  %# hidden layer;
elseif(strcmp(net.layers{1}.transferFcn,'logsig'))
    %logsig(n) = 1 / (1 + exp(-n))
    hid = (1 ./ (1 + exp(-hid)));  %# hidden layer;

end

if(net.numLayers>2)
    hid2 = LW*hid + b2;     %# output layer
    if(strcmp(net.layers{2}.transferFcn,'tansig'))
        hid2 = (2 ./ (1 + exp(-2*hid2)) - 1);  %# hidden layer;
    elseif(strcmp(net.layers{2}.transferFcn,'logsig'))
        %logsig(n) = 1 / (1 + exp(-n))
        hid2 = (1 ./ (1 + exp(-hid2)));  %# hidden layer;
        
    end
    outLayerOut = LW2*hid2 + b3;     %# output layer
else
    outLayerOut = LW*hid + b2;     %# output layer
end

if strcmp(net.layers{end}.transferFcn,'tansig')
    outLayerOut = (2 ./ (1 + exp(-2*(outLayerOut))) - 1);  %# hidden layer;
elseif(strcmp(net.layers{end}.transferFcn,'logsig'))
    %logsig(n) = 1 / (1 + exp(-n))
    outLayerOut = (1 ./ (1 + exp(-outLayerOut)));  %# hidden layer;

end


%# reverse mapping from [-1,1] to original data scale
R=(yrange(:,2)-yrange(:,1));
S=(yrange(:,2)+yrange(:,1));

out = (outLayerOut) .* R / 2.0 + S /2.0;
