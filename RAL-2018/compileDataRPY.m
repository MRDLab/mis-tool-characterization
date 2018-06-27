function [data, key] = compileDataRPY(folderName,yawArray,freqArray,numTorque,USE_LEFT_JAW,roll,pitch)
% File to compile the data
[ key ] = generateKey(true);

% Parameters to run the file
count=0;
for hh = 1:length(yawArray)
    for ii = 1:length(freqArray)
        for jj = 0:numTorque - 1
            % Make the filename
            filename = sprintf('%s/%d%d%d.TXT',folderName,yawArray(hh),freqArray(ii),jj);
            % Print out the filename
            fprintf('Loading %s\n',filename);
            unitdata=[];

            CountToNm = 0.000039811;
            CountToRadCUI = 0.00076699;
            CountToRadMaxon = 0.09*pi/180;
            CUIToMaxon = -4096/8192*35;% Maxon encoder 1024 ppi, CUI encoder 2048 ppi, 35:1 gearbox

            rawdata = load(filename);
            %rawdata = dlmread(filename,',',12,0); % Read starting from 3rd row and 0th column (0 indexed, obviously)!
            % Separate out the following variables

            if USE_LEFT_JAW
                unitdata(:,key.c.t,key.r.raw)  = rawdata(:,1);                  % Driver Time
                unitdata(:,key.c.p,key.r.raw)  = rawdata(:,2)*CountToRadCUI;    % Driver Position
                unitdata(:,key.c.T,key.r.raw)  = rawdata(:,3)*CountToNm;        % Driver Torque
                unitdata(:,key.c.c,key.r.raw)  = rawdata(:,4);                  % Driver Measured Curren
                unitdata(:,key.c.p2,key.r.raw) = rawdata(:,5)*CountToRadMaxon; % End Effector Position
                unitdata(:,key.c.T2,key.r.raw) = (rawdata(:,6))*CountToNm;       % End Effector Torque

                unitdata(:,key.c.cmd1,key.r.raw) = rawdata(:,8); % Back-end Command [-1:1]
                unitdata(:,key.c.cmd2,key.r.raw) = rawdata(:,7); % Front-end Command [amps?]
                unitdata(:,key.c.pMaxon,key.r.raw) = rawdata(:,9);
                unitdata(:,key.c.traj,key.r.raw) = rawdata(:,10);
                unitdata(:,key.c.pMaxonEst,key.r.raw) = rawdata(:,2)*CUIToMaxon;
                unitdata(:,key.c.pMaxonDiff,key.r.raw) = rawdata(:,9) - rawdata(:,2)*CUIToMaxon;
                unitdata(:,key.c.roll,key.r.raw) = roll;
                unitdata(:,key.c.pitch,key.r.raw) = pitch;

            else
                % Flip pretty much everything, since we are doing right jaw,
                % not left
                unitdata(:,key.c.t,key.r.raw)  = rawdata(:,1);                  % Driver Time
                unitdata(:,key.c.p,key.r.raw)  = -rawdata(:,2)*CountToRadCUI+(2.172+0.4131); % Don't worry about it...;    % Driver Position
                unitdata(:,key.c.T,key.r.raw)  = -rawdata(:,3)*CountToNm;        % Driver Torque
                unitdata(:,key.c.c,key.r.raw)  = -rawdata(:,4);                  % Driver Measured Curren
                unitdata(:,key.c.p2,key.r.raw) = -rawdata(:,5)*CountToRadMaxon; % End Effector Position
                unitdata(:,key.c.T2,key.r.raw) = -(rawdata(:,6))*CountToNm;       % End Effector Torque

                unitdata(:,key.c.cmd1,key.r.raw) = -rawdata(:,8); % Back-end Command [-1:1]
                unitdata(:,key.c.cmd2,key.r.raw) = -rawdata(:,7); % Front-end Command [amps?]
                unitdata(:,key.c.pMaxon,key.r.raw) = -rawdata(:,9);
                unitdata(:,key.c.traj,key.r.raw) = -rawdata(:,10);
                unitdata(:,key.c.pMaxonEst,key.r.raw) = -(rawdata(:,2)*CUIToMaxon);
                unitdata(:,key.c.pMaxonDiff,key.r.raw) = -(rawdata(:,9) - rawdata(:,2)*CUIToMaxon);
                unitdata(:,key.c.roll,key.r.raw) = roll;
                unitdata(:,key.c.pitch,key.r.raw) = pitch;
            end

            % Set up filter parameters
            %From Mark Brown
            N    = 3;     % Order     N = 4;
            Fs   = 1000;  % Sampling Frequency
            F3dB = 50;    % 1.778
            h = fdesign.lowpass('n,f3db', N, F3dB, Fs);

            filt_IIR = design(h, 'butter', 'SystemObject', true);
            SOS = filt_IIR.SOSMatrix;
            G = filt_IIR.ScaleValues;

            for kk=1:key.c.NumCols
                % Filtered values
                unitdata(:,kk,key.r.filt) = filtfilt(SOS,G,unitdata(:,kk,key.r.raw));
                % Simple Derivative (i.e. - velocity)
                unitdata(:,kk,key.r.diff) = gradient(unitdata(:,kk,key.r.raw))*1e3;          % Convert rad/ms to rad/s
                % Filtered Derivative (i.e. - velocity)
                unitdata(:,kk,key.r.difffilt) = filteredDerivative(unitdata(:,kk,key.r.filt),0.001,'holoborodko'); 
            end

            % Store it
            %data{numTorque*length(freqArray)*(hh-1)+numTorque*(ii-1)+jj+1} = unitdata;
            count = count + 1;
            data{count} = unitdata;
        end
    end
end