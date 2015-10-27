function SetParameters(handles)
% function SetParameters(handles)
%   Sets most game parameters, uses 'save' and 'load' MATLAB functions

%% General Parameters
Z=.28; % Used to scale time and distance (1 step takes 1*Z hr)
stepLength=6.71*Z; % Miles
width=20*stepLength; % Width of screen
x(1)=width/2;
y(1)=0;
ymax=stepLength*75;
wallHeight=stepLength/7.5;
if handles.DifficultyPopUp.Value==1 % Easy
    minSpace=stepLength*1.9;
else
    minSpace=stepLength*1.3;
end
save('positiondata','x','y')
save('parameters','stepLength','width','ymax','wallHeight')

stop=0;
save('stopdata','stop')

graphics=handles.GraphicCheck.Value;
save('graphics','graphics')

%% Items
items.Geiger=handles.GeigerButton.Value;
items.Febreeze=handles.FebButton.Value;
items.Running=handles.ShoesButton.Value;
items.Medicine=handles.MedButton.Value;
save('itemdata','items')

%% Toxin
V = 5; % Volume of blood in L
A = .1; % Absorption constant in per hr
F = 1; % Bioavailability
D = 13; % Total Dose in mg
if items.Medicine
    E = .7; % Elimination constant in per hr
else
    E = .6;
end
lethaltX=5; % Lethal exposure (mg*hr/L)

save('toxdata','V','A','F','D','E','lethaltX')

%% Radiation
Radiation=radiationGen(ymax,stepLength,width);
R=0; % Initializes Percent Exposure
rX=0;
if items.Medicine
    m=.04;
else
    m=0;
end
if items.Geiger
    show=1;
else
    show=0;
end
save('raddata','Radiation','R','rX','m','show')

%% Time
t=0;
if items.Running
    s=1.33;
else
    s=1;
end
Z=Z/s;
save('timedata','t','Z')

%% Walls
[LeftWall,RightWall,CenterWall,numWall]=wallGen(stepLength,width,ymax,wallHeight,minSpace);
nw=2;
save('walldata','LeftWall','RightWall','CenterWall','numWall','nw')

%% Direction
direction='none';
player = imread('playerF.jpg');
save('directiondata','direction','player')

%% Alive
alive=1;
save('alivedata','alive')

%% Zombies
zombie=-16*stepLength;
if items.Febreeze
    zombieStep=stepLength/(s-.1)*.3;
else
    zombieStep=stepLength/(s-.1)*.6;
end
save('zomdata','zombie','zombieStep')
