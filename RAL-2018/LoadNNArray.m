function [ NN ] = LoadNNArray( tools, depVars, perms )
% Load a series of Neural Net objects from saved .mat files

nn_folder=['Neural_Nets/'];
for ii=tools
    for depVar=depVars
        for jj=perms
            load([nn_folder 'Paper2_NN_' num2str(ii) '_' num2str(depVar) '_' num2str(jj) '.mat']);
            NN{ii,depVar,jj}=NN_Out;
        end
    end
end


end

