function [ ] = saveFigLaTeX( filename, fig, w, h, vector )
%saveFigLaTeX Saves figure to LaTeX
%   Give it the figure handle.

if nargin < 3
  w = 3.00000000;
  h = 2.25000000;
  vector = true;
elseif nargin < 5
  vector = true;
end

%Save to a 'figures' folder
filepath=[pwd,'/', filename];

FIG_W = w;     % Width of actual figure  
FIG_H = h;     % Height of actual figure
FIG_UNITS = 'inches'; % units for W&H
FIG_RES = 600; % figure resolution in dpi

set(findall(fig,'-property','FontSize'),'FontSize',9);
set(findall(fig,'-property','FontSize'),'FontName','Times');
% set it's W and H w/o messing up the position on the screen
set(fig,'PaperPositionMode','auto', 'PaperUnits', FIG_UNITS)
FIG_SZ = get(fig, 'position');
FIG_SZ(3:end) = [FIG_W FIG_H];
set(fig, 'position', FIG_SZ);
set(fig, 'PaperPosition', [0 0 FIG_W FIG_H]); %Position plot at left hand corner with width 5 and height 5.
set(fig, 'PaperSize',         [FIG_W FIG_H]); %Set the paper to have width 
if vector
    set(fig, 'Renderer', 'Painters');
else
    set(fig, 'Renderer', 'OpenGL');
end

% Save the figure to file
%print(fig, filepath, '-dpng', ['-r' num2str(FIG_RES)]) % Raster
print(fig, filepath, '-dpdf', ['-r' num2str(FIG_RES)]) % Vector

end

