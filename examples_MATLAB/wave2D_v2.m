% Solves 2D Wave Eqn. with MDM and position Verlet algorithm

clc
close all

addpath('../mole_MATLAB')

% Spatial discretization
k = 4;    % Order of accuracy
m = 101;  % Spatial resolution
n = m;    % Spatial resolution
a = -5;   % West
b = 10;   % East
c = -5;   % South
d = 10;   % North
dx = (b-a)/m;
dy = (d-c)/n;

% 2D Staggered grid
xgrid = [a a+dx/2 : dx : b-dx/2 b];
ygrid = [c c+dy/2 : dy : d-dy/2 d];

[X, Y] = meshgrid(xgrid, ygrid);

% Mimetic Operator (Laplacian)
L = lap2D(k, m, dx, n, dy);
L = L + robinBC2D(k, m, dx, n, dy, 0, 0);
I = interpol2D(m, n, 0.5, 0.5);
I2 = interpolD2D(m, n, 0.5, 0.5);

% Wave propagation speed
cc = 100;  % Depends on the problem

% "Force" function
F = @(x, cc) (cc^2)*L*x;

% Simulation time
TIME = 0.3;

% Temporal discretization based on CFL condition
dt = dx/(2*cc); % dt = h on Young's paper

% Initial condition
ICU = @(x, y) sin(pi*x).*sin(pi*y).*(x>2).*(x<3).*(y>2).*(y<3);
uold = ICU(X, Y);
ICV = @(x, y) zeros(2*m*n+m+n, 1);
vold = ICV(X, Y);

uold = reshape(uold, (m+2)*(n+2), 1);

theta = 1/(2-2^(1/3)); % From Peter Young's paper

% Premultiply out of the time loop (since it doesn't change)
I = dt*I;
I2 = 0.5*dt*I2;

%v = VideoWriter('2DWave_Corbino.avi', 'Uncompressed AVI');
%v.FrameRate = 10;
%open(v);

% Time integration loop
for t = 0 : TIME/dt
    % Apply "position Verlet" algorithm -----------------------------------
    uold = uold + I2*vold;
    vnew = vold + I*F(uold, cc);
    unew = uold + I2*vnew;
    
    % Update
    uold = unew;
    vold = vnew;
    
    % Plot results
    surf(X, Y, reshape(unew, m+2, n+2), 'EdgeColor', 'none')
    title(['2D Wave equation solved with MOLE' '\newlineTime = ' num2str(dt*t)])
    
    colormap winter
    colorbar

    axis([a b c d -1 1])
    set(gcf, 'color', 'w')
    xlabel('x')
    ylabel('y')
    shading interp
    drawnow
    
    %M(t+1) = getframe(gcf);
end

%writeVideo(v, M)
%close(v)
