function [LeftWall,RightWall,CenterWall,numWall]=wallRec2(stepLength,width,ymax,wallHeight,minSpace)
% function [LeftWall,RightWall,CenterWall,numWall]=wallRec2(stepLength,width,ymax,wallHeight,minSpace)
%   Generates walls on left, center, and right of map. Used by main game
%   functions.

%% Set initial parameters

% stepLength=3; % Length of each step
% width=20; % Width of screen
% x(1)=width/2;
% y(1)=0;
% ymax=50;
% wallHeight=.2;
% minSpace=3;

a=3;
numWall=(round(ymax/a/stepLength,0));
wallSpacing=a*stepLength;
%% Create Left Walls

for nWall=2:numWall-1
    LeftWall.left(nWall)=-.1-minSpace;
    if rand<.8
        LeftWall.right(nWall)=width*rand-minSpace;
    else
        LeftWall.right(nWall)=0;
    end
    LeftWall.y(nWall)=nWall*wallSpacing-wallSpacing/2; % Evenly spaces
    LeftWall.width(nWall)=abs(LeftWall.right(nWall)-LeftWall.left(nWall));
    rectangle('position',[LeftWall.left(nWall),LeftWall.y(nWall),...
        LeftWall.width(nWall),wallHeight]);
    axis([0,width,0,ymax])
end


%% Create Center Walls

for nWall=2:numWall-1
    if rand<.95
        CenterWall.left(nWall)=LeftWall.right(nWall)+minSpace+rand*minSpace;
        CenterWall.right(nWall)=CenterWall.left(nWall)+rand*(width-CenterWall.left(nWall))+minSpace;
        if CenterWall.right(nWall)>width-minSpace/4
            CenterWall.right(nWall)=width;
        end
    else
        CenterWall.left(nWall)=LeftWall.left(nWall);
        CenterWall.right(nWall)=LeftWall.right(nWall);
    end
    CenterWall.y(nWall)=nWall*wallSpacing-wallSpacing/2; % Evenly spaces
    CenterWall.width(nWall)=abs(CenterWall.right(nWall)-CenterWall.left(nWall));
    rectangle('position',[CenterWall.left(nWall),CenterWall.y(nWall),...
        CenterWall.width(nWall),wallHeight]);
    axis([0,width,0,ymax])
end


%% Create Right Walls

for nWall=2:numWall-1
    if rand<.8
        RightWall.left(nWall)=CenterWall.right(nWall)+minSpace+rand*minSpace;
        RightWall.right(nWall)=width;
    else
        RightWall.left(nWall)=width+.1;
        RightWall.right(nWall)=width+.1+minSpace;
    end
    RightWall.y(nWall)=nWall*wallSpacing-wallSpacing/2; % Evenly spaces
    RightWall.width(nWall)=abs(RightWall.right(nWall)-RightWall.left(nWall));
    rectangle('position',[RightWall.left(nWall),RightWall.y(nWall),...
        RightWall.width(nWall),wallHeight]);
    axis([0,width,0,ymax])
end

