function out = sim_net_manual(net,x)
% This function is designed to run a NN without the toolbox
% This version runs on a single input without matrix multiplication, which 
% is significantly slower for MATLAB. Use sim_net_manual_array() for any
% matlab implementation. This function is only helpful for understanding
% how the c++ implementation is generated in generate_nn_cpp().
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

xrange=net.inputs{1}.range;
yrange=net.outputs{end,end}.range;

%%# manually simulate network
%# map input to [-1,1] range
P=(xrange(:,2)-xrange(:,1));
Q=(xrange(:,2)+xrange(:,1));
R=(yrange(:,2)-yrange(:,1));
S=(yrange(:,2)+yrange(:,1));

in=[];
for ii=1:size(IW,2)
    in(ii) = (x(ii) * 2.0 - Q(ii) )./ P(ii);
end

%# propagate values to get output (scaled to [-1,1])
hid=[];%zeros(length(x),size(IW,1));
%whos IW b1 in LW b2 hid
for jj=1:size(IW,1)
    hid(jj)=b1(jj);
    for ii=1:size(IW,2)
        hid(jj)=hid(jj)+IW(jj,ii) .* in(ii);
    end
    if(strcmp(net.layers{1}.transferFcn,'tansig'))
        hid(jj) = (2 ./ (1 + exp(-2*hid(jj))) - 1);  %# hidden layer;
    elseif(strcmp(net.layers{1}.transferFcn,'logsig'))
        %logsig(n) = 1 / (1 + exp(-n))
        hid(jj) = (1 ./ (1 + exp(-hid(jj))));  %# hidden layer;
        
    end
end

out=[];
if(net.numLayers>2)
    %# propagate values to get output (scaled to [-1,1])
    hid2=[];%zeros(length(x),size(IW,1));
    %whos IW b1 in LW b2 hid
    for jj=1:size(LW,1)
        hid2(jj)=b2(jj);
        for ii=1:size(LW,2)
            hid2(jj)=hid2(jj)+LW(jj,ii) .* hid(ii);
        end
        if(strcmp(net.layers{2}.transferFcn,'tansig'))
            hid2(jj) = (2 ./ (1 + exp(-2*hid2(jj))) - 1);  %# hidden layer;
        elseif(strcmp(net.layers{2}.transferFcn,'logsig'))
            %logsig(n) = 1 / (1 + exp(-n))
            hid2(jj) = (1 ./ (1 + exp(-hid2(jj))));  %# hidden layer;

        end
    end
    for ii=1:size(LW2,1)
        out(ii,1)=b3(ii);
        for jj=1:size(LW2,2)
            out(ii,1) = out(ii,1) + LW2(ii,jj).*hid2(jj);
        end
    end
else
    for ii=1:size(LW,1)
        out(ii,1)=b2(ii);
        for jj=1:size(LW,2)
            out(ii,1) = out(ii,1) + LW(ii,jj).*hid(jj);
        end
    end
end

%# output layer

for ii=1:size(out,1)
    %# reverse mapping from [-1,1] to original data scale
    if(strcmp(net.layers{end}.transferFcn,'tansig'))
        out(ii,1) = (2 ./ (1 + exp(-2*(out(ii,1)))) - 1);  %# hidden layer;
    elseif(strcmp(net.layers{end}.transferFcn,'logsig'))
        %logsig(n) = 1 / (1 + exp(-n))
        out(ii,1) = (1 ./ (1 + exp(-out(ii,1))));  %# hidden layer;
    end
    out(ii,1) = (out(ii,1)) .* R(ii) / 2.0 + S(ii) /2.0;
end


%whos x Q in hid X outLayerOut R S out



