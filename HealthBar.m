function [healthBar,tf,alive]=HealthBar(x,y,alive)
% Calculates health as function of time

%   Author: John Johnson

%% Toxin Parameters

load('toxdata')
load('raddata')
load('timedata')
load('humanchoice')

%% Calculate Exposure of Toxin

%   dC/dt=1/V(Absorption-Elimination)
%   Absorption=AFDe^(-At)
%   Elimination=EVC

if human
    t=linspace(0,t,t/Z*200); % Creates array of times to make integral possible
    C = A*F*D/V/(E-A)*(exp(-A.*t) - exp(-E.*t));
    tX=trapz(t,C);
else 
    C = A*F*D/V/(E-A)*(exp(-A.*t) - exp(-E.*t));
    tX=zeros(1,length(t));
    tX(1) = 0;
    for i=2:length(t)
        tX(i) = trapz(t(1:i),C(1:i));
    end
end
%% Calculate Exposure of Radiation

if human
    for n=1:Radiation.numRad
        R=(1-m)*R;
        if (x-Radiation.xCenter(n))^2+(y-Radiation.yCenter(n))^2<=Radiation.rInner(n)^2
            R=R+.00005*Z*60; % 8 gy
        elseif (x-Radiation.xCenter(n))^2+(y-Radiation.yCenter(n))^2<=Radiation.rMiddle(n)^2
            R=R+.00014*Z*60; % 14 gy
        elseif (x-Radiation.xCenter(n))^2+(y-Radiation.yCenter(n))^2<=Radiation.rOuter(n)^2
            R=R+.00069*Z*60; % 30 gy
        end
    end
    
    rX=rX+R*Z; % Eqivalent to integral at each time
else
    R=zeros(1,length(t));
    
    for it=2:length(t)
        for n=1:Radiation.numRad
            if (x(it)-Radiation.xCenter(n))^2+(y(it)-Radiation.yCenter(n))^2<=Radiation.rInner(n)^2
                R(it)=R(it-1)+.00005*Z*60;
            elseif (x(it)-Radiation.xCenter(n))^2+(y(it)-Radiation.yCenter(n))^2<=Radiation.rMiddle(n)^2
                R(it)=R(it-1)+.00014*Z*60;
            elseif (x(it)-Radiation.xCenter(n))^2+(y(it)-Radiation.yCenter(n))^2<=Radiation.rOuter(n)^2
                R(it)=R(it-1)+.00069*Z*60;
            end
        end
        R(it)=(1-m)*R(it);
    end
    
    rX=zeros(1,length(t));
    
    
    rX(1)=0;
    for it=2:length(t)
        rX(it)=trapz(t(1:it),R(1:it));
    end
end
save('raddata','Radiation','R','rX','m','show')

%% Calculate % Damage of Each

toxinDamage=tX/lethaltX;

radDamage=rX; % Already converted into percentage


%% Calculate Health

healthBar=(1-toxinDamage-radDamage)*100;
healthBar(healthBar<0)=0;

if ~alive
    healthBar(length(healthBar))=0; % Health goes to zero if dead
end

%% Find Time of Death

if ~human
    for it=1:length(healthBar)
        if healthBar(it)<=0
            tf=it; % tf is index of t, not actual time, when health hits zero or finishes
            alive=0;
            break
        else
            tf=it; % Will become last index in array if health does not reach zero
        end
    end
end