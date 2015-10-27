function Radiation=radiationGen(ymax,stepLength,width)
% function Radiation=radiationGen(ymax,stepLength,width)
%   Creates radiation circles to be used by main functions.

%% Create Centers

Radiation.numRad=5;

for n=1:Radiation.numRad
    Radiation.yCenter(n)=ymax/(Radiation.numRad+1)*n-stepLength+2*stepLength*rand;
    Radiation.xCenter(n)=width*rand;
end
    
%% Create Circles

for n=1:Radiation.numRad
    Radiation.rOuter(n)=4*stepLength-stepLength/2+stepLength*rand; % 8 gy
    Radiation.rMiddle(n)=2/3*Radiation.rOuter(n); % 14 gy
    Radiation.rInner(n)=1/4*Radiation.rOuter(n); % 30 gy
end