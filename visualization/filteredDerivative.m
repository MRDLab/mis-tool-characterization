%% filteredDerivative( data, T)  calculates the numerical derivative from 
% the column 'data' sampled with period 'T'
%  filteredDerivative( data, T, method, filterOpt) -- adds optional
%  arguments to select 'method' of filtering 
%
% Input:  data (mxn) where m = number of samples, n = dimension [use 1]
%         T      = sampling period of data (1/freq)
%         method =  'diff' (1st order difference) [bad idea]
%                   '5 point' (5 point stencil)
%                   'differentiator' designed with filterbuilder
%                   'holobrodko' a noise robust alternative  -- DEFAULT
% see: http://www.holoborodko.com/pavel/numerical-methods/numerical-derivative/smooth-low-noise-differentiators/#noiserobust_2        
%
% By Tim Kowalewski 2011
function [ derivative ] = filteredDerivative( data, T, method, filterOpt)


% parse the input
if nargin == 2
    method = 'holoborodko';
elseif (nargin < 2) || (nargin > 3)
    error('Wrong number of inputs.')
end

% convert textual method inputs to numerical
switch lower(method)
    case 'diff'
        % disp('diff input')
        method = 1;    
    case '5 point'
        % disp('other input')
        method =  2;
    case 'differentiator'
        method = 3;
    case 'holoborodko' 
        method = 4;
    case 'holobrodko' 
        method = 4;        
    otherwise
        method  = 1;
        disp('Unrecognised input.  Defaulting to Diff mode.');
        beep
end

% % data is assumed to be of the form: single column of position data
% if size(data,2) ~= 1 
%     error('Please input a column vector of width 1');
% end


% process data according to the selected method
switch method
    case 1  % diff method
        vel_data = diff(data);
        
        % pad with constant acceleration around time step 1
        derivative = [ 2 * vel_data(1,:) - vel_data(2,:) ; vel_data]/T;
        
    case 2  % 5 point method
        disp ('5 Point Method');        
        h = T;     % sampling period?        
        derivative = zeros(size(data));
        
        for i = 3:(size(data,1)-3)
            %  5 point stencil - works on body of data, not where i<3
            derivative(i,:) = (-data(i+2,:) + 8*data(i+1,:) - ...
                8*data(i-1,:) + data(i-2,:)) / (12*h); % / (12 * h); % ?
        end
        
     
          
        
    case 3
        disp ('differentiator')
        
        % alpha \in [0,1]; 0: inverse trapezoidal
        %                  1: inverse Simpson
        %                  0.8529 (0.8496) Tick
        alpha = .8529;
        [b, a]=lpiirdd(alpha, T);
        derivative =filter(b,a,data)./T;
        derivative(1:5,:) = 0;
        

    case 4
        disp ('Holoborodko Smooth noise-robust differentiator')
        % cf.
        % http://www.holoborodko.com/pavel/numerical-methods/numerical-derivative/smooth-low-noise-differentiators/#noiserobust_2        
        h = T;     % sampling period?      
        
        
        % pad with s extra samples on each side and pre-allocate vel
        s=5; % extra samples, depends on method order   
        [m n] = size(data);
        
        % use zeros of extra samples (bad)
        % f=[ zeros(s, n); ...
        %     data ;
        %     zeros(s, n) ];
        
        % use last sample for extras (ok)
        % f=[ repmat(2*data(1,:)-data(2,:),s, n); ...
        %     data ;
        %     repmat(2*data(end-1,:)-data(end,:),s, n) ];

        % copy and mirror first/last s samples at ends (best)
        pad1 = 2*repmat(data(1  ,:),s,1)-data((s+1):-1:2,:);
        pad2 = 2*repmat(data(end,:),s,1)-data(end-[2:(s+1)],:);
        f = [   pad1;...
                data;...
                pad2];
            
        derivative = zeros(m, n);
        
                
        % 11th order, exact up to x^4
        for i = s+[1:size(data,1)]
            %disp(i);
            derivative(i-s,:) = (322*(f(i+1,:)-f(i-1,:)) + ...
                256*(f(i+2,:)-f(i-2,:)) +39*(f(i+3,:)-f(i-3,:))-...
                32*(f(i+4,:)-f(i-4,:))  -11*(f(i+5,:)-f(i-5,:)))/(1536*h);
            %disp((322*(f(i+1,:)-f(i-1,:))...
            %    +256*(f(i+2,:)-f(i-2,:)) +39*(f(i+3,:)-f(i-3,:)) -32*(f(i+4,:)-f(i-4,:))...
            %    -11*(f(i+5,:)-f(i-5,:)))/(1536))            
        end

        % size(data)
        % size(derivative)

        
        
        % % 7th rder, exact up to x^4
        % for i = 4:(size(data,1)-4)
        %     derivative(i,:) = [39*(f(i+1,:)-f(i-1,:))+12*(f(i+2,:)-f(i-2,:))-5*(f(i+3,:)-f(i-3,:))]/(96*T);
        % end

    otherwise
        Error('Internal error on switch statement');
end



return % derivative

% 
% 
% figure('windowstyle','docked','numbertitle','off','name','diff vs. 5 point stencil')
% %subplot(2,1,1)
% plot(derivative); hold on;
% title('diff vs 5 point stencil based velocity')
% 
% %subplot(2,1,2)
% plot(d_data,'r')
% %         title('5 point stencil')
% legend('diff','5 point stencil')
% 
% 
% 
% 
% % characterize frequency content of EDGE Signal
% 
% % FFT
% 
% data = data;                % position data
% data = derivative;              % derivative data
% Fs = 30.3030;                    % Sampling frequency
% T = 1/Fs;                     % Sample time
% L = length(data);                     % Length of signal
% 
% time = (1:L)*T;                 % time stamps
% 
% t = (0:L-1)*T;                % Time vector
% % Sum of a 50 Hz sinusoid and a 120 Hz sinusoid
% % x = 0.7*sin(2*pi*50*t) + sin(2*pi*120*t); 
% % y = x + 2*randn(size(t));     % Sinusoids plus noise
% plot(time,data)
% title('Original Signal with noise')
% xlabel('time (milliseconds)')
% 
% NFFT = 2^nextpow2(L); % Next power of 2 from length of y
% Y = fft(data,NFFT)/L;
% f = Fs/2*linspace(0,1,NFFT/2+1);
% 
% % Plot single-sided amplitude spectrum.
% plot(f,2*abs(Y(1:NFFT/2+1))) 
% title('Single-Sided Amplitude Spectrum of y(t)')
% xlabel('Frequency (Hz)')
% ylabel('|Y(f)|')
% 
% 
% 
% 
% 
% 
% 
% % filtering
% 
% if filter
%     warning('Sample frequency assumed to be 30.3030 HZ (EDGE)')
%     f = 30.3030;
%     fNorm = 200 / (f/2);    % must be between 0 and 1, can't filter above the sample frequency
%     
%     [b,a] = butter(10, fNorm, 'low');
%     
%     derivative_filtered = filtfilt(b, a, derivative);
%     
%     
%     
%     % The frequency response for this filter:
%     freqz(b,a,128,f); % characterize the filter frequency responce.
% 
% 
%     h=fdesign.lowpass('Fp,Fst,Ap,Ast',0.15,0.2,1,60);
%     d=design(h,'equiripple'); %Lowpass FIR filter
%     y=filtfilt(d.Numerator,1,x); %zero-phase filtering
% 
%     %derivative_filtered = filtfilt(
% 
%     
%     % a Butterworth second-order section filter
%     h=fdesign.lowpass('N,F3dB',12,0.15);
%     d1 = design(h,'butter');
%     y = filtfilt(d1.sosMatrix,d1.ScaleValues,x);
%     
% end
% 
% % function end
% end
% 
