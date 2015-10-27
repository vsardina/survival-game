function [x,y,zombie,alive,player]=CalculateWalk(hwb,nSim,iSim)
% function [x,y,zombie,alive,player]=CalculateWalk(hwb,nSim,iSim)
%   Calculates the walk of each simulation. Inputs are used for waitbar.

%% Initialize Vectors

% Length is estimate, preallocated for speed. Made correct length later.
x=zeros(1,350);
y=zeros(1,350);
zombie=zeros(1,350);
player=cell(1,350);
player(:)={0};
direction=cell(1,350);
direction(:)={0};

%% Set Parameters
load('positiondata')
load('itemdata')
load('raddata')
load('walldata')
load('parameters')
load('zomdata')
load('timedata')
load('alivedata')
player{1}=imread('playerF.jpg');
istep=1;
nw=2; % Wall counter
nr=1; % Radiation counter

while y(istep)<=ymax
    load('stopdata')
    if stop
        break
    end
    % Breaks if at end or if caught by zombies
    if y(istep)==ymax
        alive=1;
        break
    elseif zombie(istep)>=y(istep)
        zombie(istep)=y(istep);
        alive=0;
        break
    end
     
    %% Determine Direction of Next Step
    if items.Geiger && nr<=Radiation.numRad
        % Radiation is on current level
        if Radiation.yCenter(nr)-Radiation.rOuter(nr)<LeftWall.y(nw) ||...
                (Radiation.yCenter(nr)+Radiation.rOuter(nr)>LeftWall.y(nw-1) &&...
                y(istep)>Radiation.yCenter(nr))
            % Find all spaces in walls
            if CenterWall.left(nw)>0 && CenterWall.right(nw)<width
                spaces.num=2;
                spaces.one.left=LeftWall.right(nw);
                spaces.one.right=CenterWall.left(nw);
                spaces.two.left=CenterWall.right(nw);
                spaces.two.right=RightWall.left(nw);
            else
                spaces.num=1;
                if CenterWall.left<=0
                    spaces.one.left=LeftWall.right(nw);
                    if CenterWall.right(nw)==LeftWall.right(nw)
                        spaces.one.right=RightWall.left(nw);
                    else
                        spaces.one.right=CenterWall.left(nw);
                    end
                else
                    spaces.one.left=min(CenterWall.right(nw),LeftWall.right(nw));
                    if CenterWall.right(nw)==LeftWall.right(nw)
                        spaces.one.right=RightWall.left(nw);
                    else
                        spaces.one.right=CenterWall.left(nw);
                    end
                end
            end
            % One space, already below it, need to go up
            if spaces.num==1 && x(istep)>spaces.one.left && x(istep)<spaces.one.right
                direction{istep}='up';
            % One space, need to get to it, on right
            elseif spaces.num==1 && x(istep)<spaces.one.left
                % Still in radiation, get out
                if x(istep)<Radiation.xCenter(nr)-Radiation.rOuter(nr) ||...
                        x(istep)>Radiation.xCenter(nr)+Radiation.rOuter(nr)
                    direction{istep}='right';
                % Room to go underneath radiation, do not go up
                elseif Radiation.yCenter(nr)-Radiation.rOuter>LeftWall.y(nw)
                    direction{istep}='right';
                % Room to go above radiation, go up first
                elseif Radiation.yCenter(nr)+Radiation.rOuter(nr)<LeftWall.y(nw) &&...
                        y(istep)+stepLength+.01<LeftWall.y(nw)
                    direction{istep}='up';
                % No room up or down, go furthest from center, unless
                % radiation is covering space
                elseif Radiation.yCenter(nr)<(LeftWall.y(nw)+LeftWall.y(nw-1))/2 &&...
                        (Radiation.xCenter(nr)+Radiation.rInner(nr)>spaces.one.right ||...
                        Radiation.xCenter(nr)-Radiation.rInner(nr)<spaces.one.left) &&...
                        (Radiation.xCenter(nr)>spaces.one.right ||...
                        Radiation.xCenter(nr)<spaces.one.left) &&...
                        Radiation.rInner(nr)+stepLength+.1<LeftWall.y(nw) && y(istep)+stepLength+.01<LeftWall.y(nw)
                    direction{istep}='up';
                elseif x(istep)+stepLength>Radiation.xCenter(nr)+Radiation.rOuter(nr) &&...
                        y(istep)+stepLength+.1<LeftWall.y(nw) && y(istep)<Radiation.yCenter(nr)
                    direction{istep}='up';                    
                else
                    direction{istep}='right';
                end
                
            % Same thing with space on left
            elseif spaces.num==1 && x(istep)>spaces.one.right
                % Still in radiation, get out
                if x(istep)<Radiation.xCenter(nr)-Radiation.rOuter(nr) ||...
                        x(istep)>Radiation.xCenter(nr)+Radiation.rOuter(nr)
                    direction{istep}='left';                
                % Room to go underneath radiation, do not go up
                elseif Radiation.yCenter(nr)-Radiation.rOuter>LeftWall.y(nw)
                    direction{istep}='left';
                    % Room to go above radiation, go up first
                elseif Radiation.yCenter(nr)+Radiation.rOuter(nr)<LeftWall.y(nw) &&...
                        y(istep)+stepLength+.01<LeftWall.y(nw) && y(istep)<Radiation.yCenter(nr)
                    direction{istep}='up';
                    % No room up or down, go furthest from center, unless
                    % radiation is covering space
                elseif Radiation.yCenter(nr)<(LeftWall.y(nw)+LeftWall.y(nw-1))/2 &&...
                        (Radiation.xCenter(nr)+Radiation.rInner(nr)>spaces.one.right ||...
                        Radiation.xCenter(nr)-Radiation.rInner(nr)<spaces.one.left) &&...
                        Radiation.rInner(nr)+stepLength+.1<LeftWall.y(nw) && y(istep)+stepLength+.01<LeftWall.y(nw)
                    direction{istep}='up';
                elseif x(istep)+stepLength>Radiation.xCenter(nr)+Radiation.rOuter(nr) &&...
                        y(istep)+stepLength+.1<LeftWall.y(nw)
                    direction{istep}='up';
                else
                    direction{istep}='left';
                end
            % Two spaces, in radiation or below
            elseif spaces.num==2 && x(istep)<Radiation.xCenter(nr)+Radiation.rOuter(nr) &&...
                    x(istep)>Radiation.xCenter(nr)-Radiation.rOuter(nr)
                % In left space, go to right one if shorter
                if (x(istep)>spaces.one.left && x(istep)<spaces.one.right)
                    if x(istep)>Radiation.xCenter(nr)
                        direction{istep}='right';
                    else
                        direction{istep}='up';
                    end
                % In right space, go to left one if shorter
                elseif (x(istep)>spaces.two.left && x(istep)<spaces.two.right)
                    if x(istep)<Radiation.xCenter(nr)
                        direction{istep}='left';
                    else
                        direction{istep}='up';
                    end
                % One space on each side and in line with radiation
                elseif spaces.one.right<x(istep) && spaces.two.left>x(istep)
                    % If in radiation, go to closer one
                    if (x(istep)-Radiation.xCenter(nr))^2+(y(istep)-Radiation.yCenter(nr))^2<Radiation.rOuter(nr)^2
                        % Closer one is on right
                        if x(istep)>Radiation.xCenter(nr)
                            direction{istep}='right';
                        else
                            direction{istep}='left';
                        end
                    % If right space is blocked    
                    elseif spaces.two.right<Radiation.xCenter(nr)+Radiation.rOuter(nr)
                        direction{istep}='left';
                    % Same for left space    
                    elseif spaces.one.left>Radiation.xCenter(nr)-Radiation.rOuter(nr)
                        direction{istep}='right';
                    % If both blocked, go to shortest one    
                    else
                        if x(istep)-spaces.one.right>spaces.two.left-x(istep)
                            direction{istep}='right';
                        else
                            direction{istep}='left';
                        end
                    end
                % Both spaces on right
                elseif spaces.one.left>=x(istep)
                    if y(istep)+stepLength>Radiation.yCenter(nr) &&...
                            y(istep)+stepLength+.1<LeftWall.y(nw)
                        direction{istep}='up';
                    else
                        direction{istep}='right';
                    end
                % Same for left
                elseif spaces.two.right<=x(istep)
                    if y(istep)+stepLength>Radiation.yCenter(nr) &&...
                            y(istep)+stepLength+.1<LeftWall.y(nw)
                        direction{istep}='up';
                    else
                        direction{istep}='left';
                    end
                end
            % Go up if in open space    
            elseif (x(istep)>spaces.one.left && x(istep)<spaces.one.right) ||...
                    (x(istep)>spaces.two.left && x(istep)<spaces.two.right)
                direction{istep}='up';
            % Two spaces, not in radiation
            elseif spaces.num==2 && (x(istep)<Radiation.xCenter(nr)-Radiation.rOuter(nr) ||...
                    x(istep)>Radiation.xCenter(nr)+Radiation.rOuter(nr))
                % Space on both sides, only go if space is not blocked
                if spaces.one.right<x(istep) && spaces.two.left>x(istep)
                    % Right Space is blocked
                    if Radiation.xCenter(nr)+Radiation.rOuter(nr)>spaces.two.left &&...
                          Radiation.xCenter(nr)-Radiation.rOuter(nr)<spaces.two.right 
                        direction{istep}='left';
                        % Same for if left is blocked
                    elseif Radiation.xCenter(nr)+Radiation.rOuter(nr)>spaces.one.left &&...
                          Radiation.xCenter(nr)-Radiation.rOuter(nr)<spaces.one.right 
                        direction{istep}='right';
                        % Go to closest
                    else
                        % Space on right is closer
                        if x(istep)-spaces.one.right>=spaces.two.left-x(istep)
                            direction{istep}='right';
                        else
                            direction{istep}='left';
                        end
                    end
                % Both spaces on right
                elseif spaces.one.left>=x(istep)
                    % First space is not blocked
                    if spaces.one.left<Radiation.xCenter(nr)-Radiation.rOuter(nr)
                        direction{istep}='right';
                        % First space is blocked
                    else
                        % Same as one space on right
                        % Room to go underneath radiation, do not go up
                        if Radiation.yCenter(nr)-Radiation.rOuter>LeftWall.y(nw)
                            direction{istep}='right';
                            % Room to go above radiation, go up first
                        elseif Radiation.yCenter(nr)+Radiation.rOuter(nr)<LeftWall.y(nw) &&...
                                y(istep)+stepLength+.01<LeftWall.y(nw)
                            direction{istep}='up';
                            % No room up or down, go furthest from center, unless
                            % radiation is covering space
                        elseif Radiation.yCenter(nr)<(LeftWall.y(nw)+LeftWall.y(nw-1))/2 &&...
                                (Radiation.xCenter(nr)+Radiation.rInner(nr)>spaces.one.right ||...
                                Radiation.xCenter(nr)-Radiation.rInner(nr)<spaces.one.left) &&...
                                (Radiation.xCenter(nr)>spaces.one.right ||...
                                Radiation.xCenter(nr)<spaces.one.left) &&...
                                Radiation.rInner(nr)+stepLength+.1<LeftWall.y(nw) && y(istep)+stepLength+.01<LeftWall.y(nw)
                            direction{istep}='up';
                        elseif x(istep)+stepLength>Radiation.xCenter(nr)+Radiation.rOuter(nr) &&...
                                y(istep)+stepLength+.1<LeftWall.y(nw) && y(istep)<Radiation.yCenter(nr)
                            direction{istep}='up';
                        else
                            direction{istep}='right';
                        end
                    end
                    % Same with both spaces on left
                elseif spaces.two.right<=x(istep)
                    % Not blocked
                    if spaces.two.right>Radiation.xCenter(nr)+Radiation.rOuter(nr)
                        direction{istep}='left';
                    else
                        % Room to go underneath radiation, do not go up
                        if Radiation.yCenter(nr)-Radiation.rOuter>LeftWall.y(nw)
                            direction{istep}='left';
                            % Room to go above radiation, go up first
                        elseif Radiation.yCenter(nr)+Radiation.rOuter(nr)<LeftWall.y(nw) &&...
                                y(istep)+stepLength+.01<LeftWall.y(nw)
                            direction{istep}='up';
                            % No room up or down, go furthest from center, unless
                            % radiation is covering space
                        elseif Radiation.yCenter(nr)<(LeftWall.y(nw)+LeftWall.y(nw-1))/2 &&...
                                (Radiation.xCenter(nr)+Radiation.rInner(nr)>spaces.one.right ||...
                                Radiation.xCenter(nr)-Radiation.rInner(nr)<spaces.one.left) &&...
                                Radiation.rInner(nr)+stepLength+.1<LeftWall.y(nw) && y(istep)+stepLength+.01<LeftWall.y(nw)
                            direction{istep}='up';
                        elseif x(istep)+stepLength>Radiation.xCenter(nr)+Radiation.rOuter(nr) &&...
                                y(istep)+stepLength+.1<LeftWall.y(nw) && y(istep)<Radiation.yCenter(nr)
                            direction{istep}='up';
                        else
                            direction{istep}='left';
                        end
                    end
                end
                
            else
                % Moves as if there is no radiation
                if   LeftWall.y(nw)-y(istep)>stepLength+.01 ||...
                        (x(istep)>LeftWall.right(nw) && x(istep)<RightWall.left(nw) &&...
                        (x(istep)<CenterWall.left(nw) || x(istep)>CenterWall.right(nw)))
                    % Move up
                    direction{istep}='up';
                else
                    if x(istep)<=LeftWall.right(nw)
                        wallHit='left';
                    elseif x(istep)>=RightWall.left(nw)
                        wallHit='right';
                    else
                        wallHit='center';
                    end
                    switch wallHit
                        case 'right'
                            % Move left
                            direction{istep}='left';
                        case 'left'
                            % Move right
                            direction{istep}='right';
                        case 'center'
                            if (x(istep)-CenterWall.left(nw))<(CenterWall.right(nw)-x(istep)) ||...
                                    CenterWall.right(nw)>=width
                                % Move left
                                direction{istep}='left';
                            else
                                % Move right
                                direction{istep}='right';
                            end
                    end
                end
            end
        else % Radiation is not on current level
            % Moves as if there is no radiation
            if   LeftWall.y(nw)-y(istep)>stepLength+.01 ||...
                    (x(istep)>LeftWall.right(nw) && x(istep)<RightWall.left(nw) &&...
                    (x(istep)<CenterWall.left(nw) || x(istep)>CenterWall.right(nw)))
                % Move up
                direction{istep}='up';
            else
                if x(istep)<=LeftWall.right(nw)
                    wallHit='left';
                elseif x(istep)>=RightWall.left(nw)
                    wallHit='right';
                else
                    wallHit='center';
                end
                switch wallHit
                    case 'right'
                        % Move left
                        direction{istep}='left';
                    case 'left'
                        % Move right
                        direction{istep}='right';
                    case 'center'
                        if (x(istep)-CenterWall.left(nw))<(CenterWall.right(nw)-x(istep)) ||...
                                CenterWall.right(nw)>=width
                            % Move left
                            direction{istep}='left';
                        else
                            % Move right
                            direction{istep}='right';
                        end
                end
            end
        end
    else % No geiger counter
        % Moves as if there is no radiation
        if   LeftWall.y(nw)-y(istep)>stepLength+.01 ||...
                (x(istep)>LeftWall.right(nw) && x(istep)<RightWall.left(nw) &&...
                (x(istep)<CenterWall.left(nw) || x(istep)>CenterWall.right(nw)))
            % Move up
            direction{istep}='up';
        else
            if x(istep)<=LeftWall.right(nw)
                wallHit='left';
            elseif x(istep)>=RightWall.left(nw)
                wallHit='right';
            else
                wallHit='center';
            end
            switch wallHit
                case 'right'
                    % Move left
                    direction{istep}='left';
                case 'left'
                    % Move right
                    direction{istep}='right';
                case 'center'
                    if (x(istep)-CenterWall.left(nw))<(CenterWall.right(nw)-x(istep)) ||...
                            CenterWall.right(nw)>=width
                        % Move left
                        direction{istep}='left';
                    else
                        % Move right
                        direction{istep}='right';
                    end
            end
        end
    end
    
    %% Calculates next step
    switch direction{istep}
        case 'up'
            y(istep+1)=y(istep)+stepLength;
            x(istep+1)=x(istep);
            player{istep+1}=imread('playerF.jpg');
        case 'right'
            x(istep+1)=x(istep)+stepLength;
            y(istep+1)=y(istep);
            x(x>width)=width;
            player{istep+1}=imread('playerR.jpg');
        case 'left'
            x(istep+1)=x(istep)-stepLength;
            y(istep+1)=y(istep);
            x(x<0)=0;
            player{istep+1}=imread('playerL.jpg');
        case 'down'
            y(istep+1)=y(istep)-stepLength;
            x(istep+1)=x(istep);
            player{istep+1}=imread('playerD.jpg');
    end
    
    % Move on to next radiation
    if y(istep+1)>Radiation.yCenter(nr)+Radiation.rOuter(nr)
        nr=nr+1;
        nr(nr>Radiation.numRad)=Radiation.numRad;
    end
    
    % Moves on to next wall
    if y(istep)>=LeftWall.y(nw) && nw<numWall-1
        nw=nw+1;
    end
    
    zombie(istep+1)=zombie(istep)+zombieStep;
    
    % Prevents from going past end
    if y(istep+1)>=ymax
        y(istep+1)=ymax;
    end
    istep=istep+1;
    
    % Waitbar takes into account multiple simulations
    waitbar(y(istep)/(ymax*nSim)+(iSim-1)/nSim,hwb)
end

%% Set Length of Vectors
x=x(1:istep);
y=y(1:istep);
zombie=zombie(1:istep);
player=player(1:istep);
end