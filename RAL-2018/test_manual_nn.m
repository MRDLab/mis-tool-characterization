%% This script is designed to test/validate the different manual NN functions
%
%  This script trains a number of differet NN's with differet sizes and
%  transfer functions and then tests the manual NN functions against them.
%
%  For some reason sometimes the NN generator runs incorrectly, you can see
%  this on the GUI as it will not show the expected layers & outputs. I
%  don't know why this occurs, but it isn't a fault of the manual NN code.

%x = [linspace(-71,71,200)];         %# 1D input
x = [linspace(-71,72,20);linspace(-35,12,20);linspace(-56,23,20)];% 3D input
y_model = x.^2;                      % model
y = y_model + 10*randn(size(x)).*x;  % add some noise
y = y(1:2,:);                        % 3D output
nodes=[30 15];
transfer_functions={ 'tansig','logsig','purelin'};
for layers=1:2
    for tf_type=1:length(transfer_functions)
        clear net tr;
        %%# create ANN, train, simulate
        net = fitnet(nodes(1:layers));
        net.divideFcn = 'dividerand';
        
        net.trainParam.epochs = 50;
        net.layers{1}.transferFcn = transfer_functions{tf_type};
        net.layers{2}.transferFcn = transfer_functions{tf_type};
        if(layers>1)
            net.layers{3}.transferFcn = transfer_functions{tf_type};
        end
        [net,tr,y,e] = train(net,x,y);
        y_hat = net(x);
        % 
        out=[];
        out2=[];
        for ii=1:length(x)
            out2(:,ii)=sim_net_manual_array(net,x(:,ii));
            [out(:,ii)]=sim_net_manual(net,x(:,ii));
        end

        name=strcat('_test_',num2str(layers),'layers_',transfer_functions{tf_type});
        %# compare against MATLAB output
        indiv_err=max(max( abs(out - y_hat) ) );       %# this should be zero (or in the order of `eps`)
        array_err=max(max( abs(out2 - y_hat) ) );       %# this should be zero (or in the order of `eps`)
        if(indiv_err>eps*max(max(abs(y_hat)))*10.0)
            fprintf('individual error of %f for run "%s" seems too large\n',indiv_err,name);
        end
        if(array_err>eps*max(max(abs(y_hat)))*10.0)
            fprintf('array error of %f for run "%s" seems too large\n',array_err,name);
        end
        
        temp.net=net;
        temp.tr=tr;
        results=validateNetwork(temp.net,tr,x,y);
        generate_nn_cpp( net,  name, 'double', x(:,1) );
    end
end