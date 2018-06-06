function [fh] = plotOverview(big_data,key,mytitle)

fh=figure;hold on;
% Plot Position
sh(1) = subplot(4,1,1);
hold on;
plot(big_data(:,key.c.p,key.r.raw));
grid on; grid minor;
title('Input Position');
ylabel('rad');

% Velocity    
sh(2) = subplot(4,1,2);
hold on;
plot(big_data(:,key.c.T,key.r.raw));
grid on; grid minor;
title('Input Torque');
ylabel('Nm');

% Input Torque
sh(3) = subplot(4,1,3);
hold on;
plot(big_data(:,key.c.p2,key.r.raw));
grid on;
title('Output Position');
ylabel('rad');

% Output Torque
sh(4) = subplot(4,1,4);
hold on;
plot(big_data(:,key.c.T2,key.r.raw));
grid on;
title('Output Torque');
linkaxes(sh,'x');
ylabel('Nm')

if isOctave == 1
    supTitleOctave(mytitle);
else
    suptitle(mytitle);
end
end

