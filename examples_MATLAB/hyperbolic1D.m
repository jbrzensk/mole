% Solves the 1D Advection equation with periodic boundary conditions

clc
close all

addpath('../mole_MATLAB')

a = 1; % Velocity
west = 0; % Domain's limits
east = 1;

k = 2; % Operator's order of accuracy
m = 50; % Number of cells
dx = (east-west)/m;

t = 1; % Simulation time
dt = dx/abs((k/2)*a); % CFL condition for explicit schemes

D = div(k, m, dx); % 1D Mimetic divergence operator
I = interpol(m, 0.5); % 1D 2nd order interpolator

% 1D Staggered grid
grid = [west west+dx/2: dx :east-dx/2 east];

% IC
U = sin(2*pi*grid)';

% Periodic BC imposed on the divergence operator
D(1,2) = 1/(2*dx);
D(1,end-1) = -1/(2*dx);
D(end,2) = 1/(2*dx);
D(end,end-1) = -1/(2*dx);

% Premultiply out of the time loop (since it doesn't change)
D = -a*dt*2*D*I;

U2 = U + D/2*U; % Compute one step using Euler's method

% Time integration loop
for i = 1 : t/dt
    
    plot(grid, U2, 'o-')
    hold on
    plot(grid, sin(2*pi*(grid - a*i*dt))) % Plot exact solution
    hold off
    axis([0 1 -1.5 1.5])
    str = sprintf('t = %.2f', i*dt);
    title(str)
    xlabel('x')
    ylabel('u(x)')
    pause(0.04)
    U3 = U + D*U2; % Compute next step using Leapfrog scheme
    U = U2;
    U2 = U3;
end
