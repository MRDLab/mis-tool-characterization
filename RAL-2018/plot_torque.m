%% This script is to create the plots for the RAL paper titled:           %
%                                                                         %
%      Evaluation of Torque Measurement Surrogates as                     %
%     Applied to Grip Torque and Jaw Angle Estimation                     %
%                of Robotic Surgical Tools                                %
%                                                                         %
%  The script creates the plots, as well as the tables, used in the paper %
%  and should provide additional insight into the data anaylsis shown in  %
%  the paper.                                                             %
%                                                                         %
%  The results are dependant on the Neural Network objects which          %
%  are expected to be in the Neural_Nets folder, and were generated with  %
%  train_roll.m or train_torque.m                                         %
%                                                                         %
%  Note that due to changes made late in the editing process, the tables  %
%  generated are not formatted the same as those shown in the paper, and  %
%  experiment numbers are wildly inconsistent.                            %
%                                                                         %
%% Set up a key
[ key, conf ] = generateKey();
% conf.save_figs=false; % Save figs defaults to true
datasetIndex=key.M4L4; % This is the dataset we are using
dims=[1:3,5,4];

%% Load up both the raw datas and the neural nets
load('Neural_Nets/Paper2_big_data.mat');
NN=LoadNNArray(datasetIndex,key.POS:key.BET,1:5);
% Also load up the roll/pitch/yaw nets
NN_RPY=LoadNNArray(4:5,key.POS:key.TRQ,1:5);
mkdir('Figures');
mkdir('Tables');

%% Compare the different torque estimation methods
Table=cell(1,1);
for depVar=key.POS:key.BET;
    
    % Initialize variables that grow in loop
    mean_errors=[];
    boxplotMat=[];
    groupingMat=[];
    
    % Decide how many methods to plot
    num_dims=length(dims);
    if depVar==key.BET
        num_dims=4;
    end
    
    
    % Preallocate names
    names    =cell(num_dims,1);
    boxlabels=cell(num_dims,1);
    
    kk=1;
    % Loop through each torque estimation method
    for jj=dims(1:num_dims)
        out_estimate = conf.unitFactor(depVar)*NN{datasetIndex,depVar,jj}.estimate;
        out_test = conf.unitFactor(depVar)*NN{datasetIndex,depVar,jj}.true;
        absolute_err = out_estimate - out_test;
        
        % Format data for boxplotting
        boxplotMat = [boxplotMat, absolute_err]; 
        groupingMat = [groupingMat, (jj)*ones(size(absolute_err))];
        boxlabels{kk}=conf.briefNames{jj};
        
        % Get a mean for bargraphing
        mean_errors(kk)=(mean(abs(absolute_err)));
        names{kk}=conf.names{jj};
        
        % Store metrics
        rownum=kk;
        BoxPlotN = (numel(groupingMat))/5;
        Table = compileMetrics(Table, absolute_err, out_test, conf.percentile, rownum, depVar, BoxPlotN, NaN, NaN);
        kk=kk+1;
    end
    
    
    % Make a box plot of the errors.
    % Warning: I'm setting the y lims so that we have consistant axes for 
    % the paper, but this could mean we aren't showing all outliers.
    fh=figure(10+depVar);clf;
    
    % Hacky way to get color quickly
    if(depVar < 3)
        boxPlotCol = conf.expColors{4};
    else
        boxPlotCol = conf.expColors{2};
    end
    
    boxplot(boxplotMat,groupingMat,'Labels',boxlabels,'color',boxPlotCol);
    ylabel(conf.ylabs{depVar});
    ylim(conf.axislims{depVar});

    
     
    % Change those ugly outliers
    hOutliers = findobj(fh,'tag','Outliers');
    for oo = 1:length(hOutliers)
        hOutliers(oo).Marker = '.';
        hOutliers(oo).MarkerEdgeColor = boxPlotCol;
    end
    
    if conf.save_figs
        saveFigLaTeX(['Figures/Boxplot_' num2str(depVar)],fh,conf.figSize(1),conf.figSize(2));
    end

    
end

%% Tables for Experiments 3 & 1

depVarName={'Position','Torque','Backend'};
tableLabels={'Experiment3PosResults','Experiment3TrqResults','Experiment1Results'};
tableCaptions={'Experiment 3: ','Experiment 3: ','Experiment 1: '};
for depVar=key.POS:key.BET;
    

    num_dims=length(dims);
    if depVar==key.BET
        num_dims=4;
    end
    
    % Preallocate names
    names    =cell(num_dims,1);
    
    % Loop through each torque estimation method
    kk=1;
    for jj=dims(1:num_dims)
        names{kk}=conf.names{jj};
        kk=kk+1;
    end
    
    
    Absolute_Error=Table{depVar}.AbsoluteError';
    Std_Deviation=Table{depVar}.stdAbsError';
    Err_95th_Pctl=Table{depVar}.PctAbsError';
    Root_Mean_Squared_Error=Table{depVar}.RMSError';
    Data_Range=Table{depVar}.Range';
    Data_Mean=Table{depVar}.Average';
    T = table(Absolute_Error,Err_95th_Pctl,Root_Mean_Squared_Error,'RowNames',names);
    T.Properties.VariableDescriptions = {'Mean Abs Err' '$95^{th}$ Pctl' 'RMSE'};
    disp(conf.ylabs{depVar});
    disp(T);

    % Now use this table as input in our input struct:
    input.data = T;

    input.tableLabel = tableLabels{depVar};
    input.tableCaption =  [tableCaptions{depVar} conf.ylabstime{depVar}];
    input.tablePlacement = 'b!';
    
    % Set the row format of the data values (in this example we want to use
    % integers only):
    input.dataFormat = {'%0.2f',3};

    % Column alignment ('l'=left-justified, 'c'=centered,'r'=right-justified):
    input.tableColumnAlignment = 'c';

    % Switch table borders on/off:
    %input.tableBorders = 1;
    
    % Switch table booktabs on/off:
    input.booktabs = 1;

    % Now call the function to generate LaTex code:
    latex = latexTable(input);
    
    
    % save LaTex code as file
    fid=fopen(['Tables/table_' num2str(depVar) '.tex'],'w');
    [nrows,ncols] = size(latex);
    for row = 1:nrows
        fprintf(fid,'%s\n',latex{row,:});
    end
    fclose(fid);
    
    
end

%% Try plugging in the torque estimates for 1,2,4 into to model for 3
% This is called "staged" in the RAL paper
Table2=cell(1,1);
torque_model=4;
torque_dep=key.BET;
for depVar=key.POS:key.TRQ
    
    % Initialize variables that grow in loop
    mean_errors=[];
    boxplotMat=[];
    groupingMat=[];
    expB_mean_errors=[];
    
    num_dims=4;
    kk=1;
    for jj=dims(1:num_dims)
        X=NN{datasetIndex,torque_dep,jj}.input;
        torque_estimate = NN{datasetIndex,torque_dep,jj}.net(X);
        input_data = NN{datasetIndex,depVar,torque_model}.input;
        input_data(3,:)=torque_estimate;
        [out_estimate,out_test] = validateNetwork(NN{datasetIndex,depVar,torque_model}.net,NN{datasetIndex,depVar,torque_model}.tr,input_data,NN{datasetIndex,depVar,torque_model}.target);
        
        out_estimate = conf.unitFactor(depVar)*out_estimate;
        out_test = conf.unitFactor(depVar)*out_test;
        absolute_err = out_estimate - out_test;
        
        % Format data for boxplotting
        boxplotMat = [boxplotMat, absolute_err]; % err is in Newtons and for plotting we want mNm!
        groupingMat = [groupingMat, (jj)*ones(size(absolute_err))];
        boxlabels{kk}=conf.briefNames{jj};
        
        % Get a mean for bargraphing
        expB_mean_errors(kk)=(mean(abs(absolute_err)));
        names{kk}=conf.names{jj};
        
        % Store metrics
        rownum=kk;
        BoxPlotN = (numel(groupingMat))/5;
        Table2 = compileMetrics(Table2, absolute_err, out_test, conf.percentile, rownum, depVar, BoxPlotN, NaN, NaN);
        kk=kk+1;
    end
    
    % Make a box plot of the errors.
    fh=figure(25+depVar);clf;
    hB = boxplot(boxplotMat,groupingMat,'Labels',boxlabels,'color',conf.expColors{3});
    ylabel(conf.ylabs{depVar});
    ylim(conf.axislims{depVar});

    
    % Change those ugly outliers
    hOutliers = findobj(fh,'tag','Outliers');
    for oo = 1:length(hOutliers)
        hOutliers(oo).Marker = '.';
        hOutliers(oo).MarkerEdgeColor = conf.expColors{3};
    end
    if conf.save_figs
        saveFigLaTeX(['Figures/ExpB_Boxplot_' num2str(depVar)],fh,conf.figSize(1),conf.figSize(2));
    end
end
%% Outputing tables for the distal position and torque by first estimating proximal torque
% This is called "staged" in the RAL paper

depVarName={'Position','Torque'};
tableLabels={'Experiment2PosResults','Experiment2TrqResults'};
for depVar=key.POS:key.TRQ
    
    num_dims=4;
    
    % Preallocate names
    names    =cell(num_dims,1);
    
    % Loop through each torque estimation method
    kk=1;
    for jj=dims(1:num_dims)
        names{kk}=conf.names{jj};
        kk=kk+1;
    end
    
    
    Absolute_Error=Table2{depVar}.AbsoluteError';
    Std_Deviation=Table2{depVar}.stdAbsError';
    Err_95th_Pctl=Table2{depVar}.PctAbsError';
    Root_Mean_Squared_Error=Table2{depVar}.RMSError';
    Data_Range=Table2{depVar}.Range';
    Data_Mean=Table2{depVar}.Average';
    T = table(Absolute_Error,Err_95th_Pctl,Root_Mean_Squared_Error,'RowNames',names);
    T.Properties.VariableDescriptions = {'Mean Abs Err' '$95^{th}$ Pctl' 'RMSE'};
    disp(depVarName{depVar});
    disp(T);

    % Now use this table as input in our input struct:
    input.data = T;

    input.tableLabel = tableLabels{depVar};
    input.tableCaption =  ['Experiment 2: ' depVarName{depVar} ' (' conf.units{depVar} ')'];
    input.tablePlacement = 'b!';
    
    % Set the row format of the data values (in this example we want to use
    % integers only):
    input.dataFormat = {'%0.2f',3};

    % Column alignment ('l'=left-justified, 'c'=centered,'r'=right-justified):
    input.tableColumnAlignment = 'c';

    % Switch table borders on/off:
    %input.tableBorders = 1;
    
    % Switch table booktabs on/off:
    input.booktabs = 1;

    % Now call the function to generate LaTex code:
    latex = latexTable(input);
    
    
    % save LaTex code as file
    fid=fopen(['Tables/table_' num2str(depVar+5) '.tex'],'w');
    [nrows,ncols] = size(latex);
    for row = 1:nrows
        fprintf(fid,'%s\n',latex{row,:});
    end
    fclose(fid);
    
    
end

%% Experiment 1: Do we even need a model? Maybe linear is good enough

% Try a linear fit for each of our torque analogues
TableC = cell(1,1);
TableC = plot_linear_fit(key,conf,big_data{datasetIndex},key.c.T,key.c.cmd1,key.BET,1,TableC);
TableC = plot_linear_fit(key,conf,big_data{datasetIndex},key.c.T,key.c.c,key.BET,2,TableC);
TableC = plot_linear_fit(key,conf,big_data{datasetIndex},key.c.T,key.c.pMaxonDiff,key.BET,3,TableC);
TableC = plot_linear_fit(key,conf,big_data{datasetIndex},key.c.T,key.c.pMaxon,key.BET,4,TableC);


%% Experiment 1 Linear Results Table
depVar=key.BET;
num_dims=4;
    
% Preallocate names
names    =cell(num_dims,1);

% Loop through each torque estimation method
kk=1;
for jj=dims(1:num_dims)
    names{kk}=conf.names{jj};
    kk=kk+1;
end


Absolute_Error=TableC{depVar}.AbsoluteError';
Std_Deviation=TableC{depVar}.stdAbsError';
Err_95th_Pctl=TableC{depVar}.PctAbsError';
Root_Mean_Squared_Error=TableC{depVar}.RMSError';
Spearman_RHO=TableC{depVar}.Spearman_RHO';
Pearson_R=TableC{depVar}.Pearson_R';
T = table(Absolute_Error,Err_95th_Pctl,Root_Mean_Squared_Error,Pearson_R,Spearman_RHO,'RowNames',names);
T.Properties.VariableDescriptions = {'MAE' '$95^{th}$ Pctl' 'RMSE', 'R', '$\rho$'};
disp(conf.ylabs{depVar});
disp(T);

% Now use this table as input in our input struct:
input.data = T;

input.tableLabel = 'Experiment0Results';
input.tableCaption =  ['Experiment 0: ' conf.ylabs{depVar}];
input.tablePlacement = 'b!';

% Set the row format of the data values (in this example we want to use
% integers only):
input.dataFormat = {'%0.2f' 5};

% Column alignment ('l'=left-justified, 'c'=centered,'r'=right-justified):
input.tableColumnAlignment = 'c';

% Switch table borders on/off:
%input.tableBorders = 1;

% Switch table booktabs on/off:
input.booktabs = 1;

% Now call the function to generate LaTex code:
latex = latexTable(input);


% save LaTex code as file
fid=fopen(['Tables/table_0.tex'],'w');
[nrows,ncols] = size(latex);
for row = 1:nrows
    fprintf(fid,'%s\n',latex{row,:});
end
fclose(fid);

%% Combined Horizontal Bar Plot for Experiment 1

num_dims=4;
    
% Preallocate names
names    =cell(num_dims,1);

% Loop through each torque estimation method
kk=1;
for jj=dims(1:num_dims)
    names{kk}=conf.names{jj};
    kk=kk+1;
end

for depVar = key.BET
    exp_0_1_data=[];
    exp_0_1_data(:,1)=TableC{depVar}.RMSError(1:num_dims)';
    exp_0_1_data(:,2)=Table{depVar}.RMSError(1:num_dims)';
    % We concatenate a zero for Exp 2, since this is estimating torque as
    % an intermediary, and so torque estimating torque is silly. We could
    % also just repeat exp3: Table{depVar}.AbsoluteError(1,4)
    exp_0_1_data(4,1)=0;

    fh = figure(30+depVar);clf;
    h = barh(exp_0_1_data);
    set(gca,'yticklabel',names);
    xlabel(conf.ylabsrmse{depVar});
    %xlim([0,conf.axislims{depVar}(2)]);
    labels={'Linear Fit','Neural Net'};
    fliplegend(labels);
    
    % Make the graph pretty and presentable
    h(1).FaceColor = conf.expColors{1};
    h(2).FaceColor = conf.expColors{2};
    
    if conf.save_figs
        saveFigLaTeX(['Figures/Comparison_' num2str(depVar)],fh,conf.figSize(1),conf.figSize(2));
    end
    

    
end


%% Combined Horizontal Bar Plots for Experiment 2

num_dims=5;
    
% Preallocate names
names    =cell(num_dims,1);

% Loop through each torque estimation method
kk=1;
for jj=dims(1:num_dims)
    names{kk}=conf.names{jj};
    kk=kk+1;
end

for depVar = key.POS:key.TRQ
    exp_2_data=[];
    exp_2_data(:,2)=Table{depVar}.RMSError';
    exp_2_data(:,1)=[Table2{depVar}.RMSError'; 0];
    % We concatenate a zero for Exp 2, since this is estimating torque as
    % an intermediary, and so torque estimating torque is silly. We could
    % also just repeat exp3: Table{depVar}.AbsoluteError(1,4)

    fh = figure(30+depVar);clf;
    h = barh(exp_2_data);
    set(gca,'yticklabel',names);
    xlabel(conf.ylabsrmse{depVar});
    %xlim([0,conf.axislims{depVar}(2)]);
    labels={'Staged','End-to-End'};
    fliplegend(labels);

    
    % Make the graph pretty and presentable
    h(1).FaceColor = conf.expColors{3};
    h(2).FaceColor = conf.expColors{4};
    
    if conf.save_figs
        saveFigLaTeX(['Figures/Comparison_' num2str(depVar)],fh,conf.figSize(1),conf.figSize(2));
    end
    
end

%% Generate tables and plots for Roll Pitch Yaw study, Experiment 3
% Note: These bar plots were not used in the RAL paper

Table3=cell(1,1);
RPY_Names={[],[],[],'Roll','Pitch'};
for ii=4:5
    for depVar=key.POS:key.TRQ

        % Initialize variables that grow in loop
        mean_errors=[];
        boxplotMat=[];
        groupingMat=[];

        % Decide how many methods to plot
        num_dims=length(dims);
        if depVar==key.BET
            num_dims=4;
        end


        % Preallocate names
        names    =cell(num_dims,1);
        boxlabels=cell(num_dims,1);

        kk=1;
        % Loop through each torque estimation method
        for jj=dims(1:num_dims)
            out_estimate = conf.unitFactor(depVar)*NN_RPY{ii,depVar,jj}.estimate;
            out_test = conf.unitFactor(depVar)*NN_RPY{ii,depVar,jj}.true;
            absolute_err = out_estimate - out_test;

            % Format data for boxplotting
            boxplotMat = [boxplotMat, absolute_err]; 
            groupingMat = [groupingMat, (jj)*ones(size(absolute_err))];
            boxlabels{kk}=conf.briefNames{jj};

            % Get a mean for bargraphing
            mean_errors(kk)=(mean(abs(absolute_err)));
            names{kk}=conf.names{jj};

            % Store metrics
            rownum=kk;
            BoxPlotN = (numel(groupingMat))/5;
            Table3 = compileMetrics(Table3, absolute_err, out_test, conf.percentile, rownum, depVar, BoxPlotN, NaN, NaN);
            kk=kk+1;
        end

        % First make a plot of just the mean absolute error
    %     fh=figure(5+depVar);clf;
    %     barh(mean_errors);
    %     set(gca,'yticklabel',names);
    %     xlabel(conf.ylabs{depVar});
    %     if conf.save_figs
    %         saveFigLaTeX(['Figures/Average_Error_' num2str(depVar)],fh,conf.figSize(1),conf.figSize(2));
    %     end

        % Make a box plot of the errors.
        % WARNING! THE OUTLIER ARE SO BONKERS I'M SETTING THE Y LIMS SO WE
        % AREN'T SHOWING ALL OUTLIERS!!! YOU HAVE BEEN WARNED.
        fh=figure(10+depVar);clf;

        % Hacky way to get color quickly
        boxPlotCol = conf.expColors{ii+1};
        

        boxplot(boxplotMat,groupingMat,'Labels',boxlabels,'color',boxPlotCol);
        ylabel(conf.ylabs{depVar});
        ylim(conf.axislims{depVar});



        % Change those ugly outliers
        hOutliers = findobj(fh,'tag','Outliers');
        for oo = 1:length(hOutliers)
            hOutliers(oo).Marker = '.';
            hOutliers(oo).MarkerEdgeColor = boxPlotCol;
        end

        if conf.save_figs
            saveFigLaTeX(['Figures/Boxplot_' RPY_Names{ii} '_' num2str(depVar)],fh,conf.figSize(1),conf.figSize(2));
        end


    end
    Tables{ii}.T=Table3;

    depVarName={'Position','Torque'};
    tableLabels={['Experiment3PosResults' RPY_Names{ii}],['Experiment3TrqResults' RPY_Names{ii}]};
    tableCaptions={['Experiment 3 ' RPY_Names{ii} ': '],['Experiment 3 ' RPY_Names{ii} ': ']};
    for depVar=key.POS:key.TRQ;


        num_dims=length(dims);
        if depVar==key.BET
            num_dims=4;
        end

        % Preallocate names
        names    =cell(num_dims,1);

        % Loop through each torque estimation method
        kk=1;
        for jj=dims(1:num_dims)
            names{kk}=conf.names{jj};
            kk=kk+1;
        end


        Absolute_Error=Table3{depVar}.AbsoluteError';
        Std_Deviation=Table3{depVar}.stdAbsError';
        Err_95th_Pctl=Table3{depVar}.PctAbsError';
        Root_Mean_Squared_Error=Table3{depVar}.RMSError';
        Data_Range=Table3{depVar}.Range';
        Data_Mean=Table3{depVar}.Average';
        T = table(Absolute_Error,Err_95th_Pctl,Root_Mean_Squared_Error,'RowNames',names);
        T.Properties.VariableDescriptions = {'Mean Abs Err' '$95^{th}$ Pctl' 'RMSE'};
        disp([RPY_Names{ii} ': ' conf.ylabs{depVar}]);
        disp(T);

        % Now use this table as input in our input struct:
        input.data = T;

        input.tableLabel = tableLabels{depVar};
        input.tableCaption =  [tableCaptions{depVar} conf.ylabstime{depVar}];
        input.tablePlacement = 'b!';

        % Set the row format of the data values (in this example we want to use
        % integers only):
        input.dataFormat = {'%0.2f',3};

        % Column alignment ('l'=left-justified, 'c'=centered,'r'=right-justified):
        input.tableColumnAlignment = 'c';

        % Switch table borders on/off:
        %input.tableBorders = 1;

        % Switch table booktabs on/off:
        input.booktabs = 1;

        % Now call the function to generate LaTex code:
        latex = latexTable(input);


        % save LaTex code as file
        fid=fopen(['Tables/table_' RPY_Names{ii} '_'  num2str(depVar) '.tex'],'w');
        [nrows,ncols] = size(latex);
        for row = 1:nrows
            fprintf(fid,'%s\n',latex{row,:});
        end
        fclose(fid);

    end
end

num_dims=5;

% Preallocate names
names    =cell(num_dims,1);

% Loop through each torque estimation method
kk=1;
for jj=dims(1:num_dims)
    names{kk}=conf.names{jj};
    kk=kk+1;
end
%% Combined Horizontal Bar Plots for Experiment 3
for depVar = key.POS:key.TRQ
    exp_3_data=[];
    exp_3_data(:,1)=Tables{4}.T{depVar}.RMSError';
    exp_3_data(:,2)=Tables{5}.T{depVar}.RMSError';

    fh = figure(35+depVar);clf;
    h = barh(exp_3_data);
    set(gca,'yticklabel',names);
    xlabel(conf.ylabsrmse{depVar});
    %xlim([0,conf.axislims{depVar}(2)]);
    labels={RPY_Names{4},RPY_Names{5}};
    fliplegend(labels);


    % Make the graph pretty and presentable
    h(1).FaceColor = conf.expColors{5};
    h(2).FaceColor = conf.expColors{6};

    if conf.save_figs
        saveFigLaTeX(['Figures/RPY_' num2str(depVar)],fh,conf.figSize(1),conf.figSize(2));
    end

end

%% Combined Figs for Exp 2 & 3 Note: These were not used in the RAL paper

num_dims=4;
    
% Preallocate names
names    =cell(num_dims,1);

% Loop through each torque estimation method
kk=1;
for jj=dims(1:num_dims)
    names{kk}=conf.names{jj};
    kk=kk+1;
end

for depVar = key.POS:key.TRQ
    exp_2_3_data=[];
    exp_2_3_data(:,2)=Table{depVar}.RMSError';
    exp_2_3_data(:,1)=[Table2{depVar}.RMSError'; 0];
    exp_2_3_data(:,3)=Tables{4}.T{depVar}.RMSError';
    exp_2_3_data(:,4)=Tables{5}.T{depVar}.RMSError';
    % We concatenate a zero for Exp 2, since this is estimating torque as
    % an intermediary, and so torque estimating torque is silly. We could
    % also just repeat exp3: Table{depVar}.AbsoluteError(1,4)

    fh = figure(37+depVar);clf;
    h = barh(exp_2_3_data);
    set(gca,'yticklabel',names);
    xlabel(conf.ylabsrmse{depVar});
    %xlim([0,conf.axislims{depVar}(2)]);
    labels={'Staged','End-to-End',RPY_Names{4},RPY_Names{5}};
    fliplegend(labels);

    
    % Make the graph pretty and presentable
    h(1).FaceColor = conf.expColors{3};
    h(2).FaceColor = conf.expColors{4};
    h(1).FaceColor = conf.expColors{5};
    h(2).FaceColor = conf.expColors{6};
    
    if conf.save_figs
        saveFigLaTeX(['Figures/Exp23_Overview_' num2str(depVar)],fh,conf.figSize(1),conf.figSize(2)*1.5);
    end
    
end
