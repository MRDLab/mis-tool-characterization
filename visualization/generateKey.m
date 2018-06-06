function [ key, conf ] = generateKey( use_rpy )
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here
if nargin < 1
    use_rpy = false;
end

% Separate NN for position and torque
key.POS=1;
key.TRQ=2;
key.BET=3;
key.ROL=4;
key.PCH=5;

% Lots of different runs of Maryland tools
key.M5L2=1;
key.M5L3=2;
key.M4L2=3;
key.M4L1=4;
key.M4R5=5;
key.M4L4=6;

key.c.t=1;
key.c.p=2;
key.c.T=3;
key.c.c=4;
key.c.p2=5;
key.c.T2=6;
key.c.cmd2=7;
key.c.cmd1=8;
key.c.pMaxon=9;
key.c.traj=10;
key.c.pMaxonEst=11;
key.c.pMaxonDiff=12;
if use_rpy
    key.c.roll=13;
    key.c.pitch=14;
    key.c.NumCols=14;
else
    key.c.NumCols=12;
end

key.r.raw=1;
key.r.filt=2;
key.r.diff=3;
key.r.difffilt=4;
key.r.NumRows=4;

conf.figSize=[3.45,2];
conf.unitFactor=[180/pi,1000,1000,180/pi,180/pi];
conf.labs={'0.1','0.2','0.3','0.4','0.5'};
conf.units={'Deg','mNm','mNm','Deg','Deg'};
conf.axislims={[-10,10],[-80,80],[-80,80],[-180,180],[-180,180]};
conf.dimBrief={  'POS','TRQ','BET','ROL','PCH'};
conf.ylabs={    ['Jaw Angle Error [' conf.units{1} ']'],...
                ['Torque Error [' conf.units{2} ']'],...
                ['Backend Torque Error [' conf.units{2} ']'],...
                ['Roll Error [' conf.units{4} ']'],...
                ['Pitch Error [' conf.units{5} ']']};
conf.ylabstime={['Jaw Angle [' conf.units{1} ']'],...
                ['Torque [' conf.units{2} ']'],...
                ['Backend Torque [' conf.units{3} ']'],...
                ['Roll [' conf.units{4} ']'],...
                ['Pitch [' conf.units{5} ']']};
conf.ylabsrmse={['Jaw Angle RMSE [' conf.units{1} ']'],...
                ['Torque RMSE [' conf.units{2} ']'],...
                ['Backend Torque RMSE [' conf.units{2} ']'],...
                ['Roll RMSE [' conf.units{4} ']'],...
                ['Pitch RMSE [' conf.units{5} ']']};
conf.RowNames={ 'Exp 1';'Exp 2 Interp';'Exp 2 Extrap';...
                'Exp 3 Same'  ;'Exp 3 Other' ;...
                'Exp 4 Same'  ;'Exp 4 Other' };
conf.names={    'Motor Command','Motor Current',...
                'Gearbox Strain', 'Torque Sensor',...
                'All 3 Sensors', 'Filtered Maxon, FUTEK',...
                'Unfiltered CUI, Filtered FUTEK','Unfiltered Maxon, Filtered FUTEK',...
                'Unfiltered CUI and FUTEK','Unfiltered Maxon and FUTEK',...
                'Unfiltered CUI and Current','Unfiltered Maxon and Current'};
conf.permunits={' [Unitless]',' [Amperes]',...
                ' [Radians]', ' [Unitless]',...
                ' []', ' []',...
                ' []', ' []',...
                ' []', ' []',...
                ' []', ' []'};
conf.permscale={-1.0',1.0,...
                0.09*pi/180/35,1.0,...
                1.0',1.0,...
                1.0',1.0,...
                1.0',1.0,...
                1.0',1.0};
conf.briefNames={'Command','Current',...
                'Gearbox', 'Torque',...
                'All 3','Maxon',...
                'UF CUI','UF Max',...
                'UF C+F','UF M+F',...
                'UF C+c','UF M+c'};
conf.expColors={[215,25 ,28 ]*(1/255),...
                [253,174,97 ]*(1/255),...
                [171,221,164]*(1/255),...
                [43 ,131,186]*(1/255),...
                [255,250,35]*(1/255),...
                [250,23,131]*(1/255)};
conf.percentile=95;
conf.save_figs=true;

end

