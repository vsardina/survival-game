function HumanPlayF(hObject,eventdata,handles)
% function HumanPlayF(hObject,eventdata, handles)
%   Main function controlling human play.

%% Set Parameters

load('parameters')
load('walldata')
load('raddata')
load('positiondata')
load('directiondata')
load('zomdata')
load('alivedata')
load('itemdata')
load('timedata')
load('graphics')

hax=handles.PlotAxes;
har=handles.HBar;
pax=handles.ProgressAxes;
handles.hideBox.Visible='off';

%% Calculate Next Step
switch direction
    case 'right'
        if ~(x>= width)   % if it hits right edge of the axes it stops
            x=x+stepLength;
            x(x>width)=width;
        end
    case 'left'
        if ~(x<= 0)   %if it hits left edge of the axes it stops
            x=x-stepLength;
            x(x<0)=0;
        end
    case 'up'
        if   LeftWall.y(nw)-y>stepLength+.01 ||...
                (x>LeftWall.right(nw) && x<RightWall.left(nw) &&...
                (x<CenterWall.left(nw) || x>CenterWall.right(nw)))
            y=y+stepLength;
            if y>=ymax
                stop=1;
                save('stopdata','stop')
            end
        end
    case 'down'
        if nw>=2 && y-stepLength-.01>LeftWall.y(nw-1) ||...
                (x>LeftWall.right(nw-1) && x<RightWall.left(nw-1) &&...
                (x<CenterWall.left(nw-1) || x>CenterWall.right(nw-1)))
            y=y-stepLength;
            y(y<0)=0;
        end
    case 'none'
        x=x;
        y=y;
end

save('positiondata','x','y')

%% Plot Next Step
handles.HText.Visible='on';
handles.HBar.Visible='on';
handles.TimeText.Visible='on';

% Determines axes
if y<10*stepLength
    axmin=0;
    axmax=20*stepLength;
elseif ymax-y<10*stepLength
    axmin=ymax-20*stepLength;
    axmax=ymax;
else
    axmin=y-10*stepLength;
    axmax=y+10*stepLength;
    
end

cla


if graphics
    %adding background
    background = imread('dirt.jpg');
    backImage = image('CData', background);
    
    %adding player image
    playerImage = image('CData', player);
    
    %coordinates of lower left and upper right corners of background image
    backImage.XData = [0,width];
    backImage.YData = [axmin, axmax];
    hold on;                                        %keeps background image
    
    %player marker coordinates
    playerImage.XData = [x-.4,x+.4];
    playerImage.YData = [y+1.6,y];
else
    plot(x,y,'bo')
end
axis(hax,[0,width,axmin,axmax])
hax.XTick=[];
hax.YTick=[];
hold on

for nWall=2:numWall-1
    if LeftWall.y(nWall)>axmin && LeftWall.y(nWall)<axmax
        LeftWall.width(nWall)=LeftWall.right(nWall)-LeftWall.left(nWall);
        rectangle('position',[LeftWall.left(nWall),LeftWall.y(nWall),...
            LeftWall.width(nWall),wallHeight],'Parent',hax);
        rectangle('position',[RightWall.left(nWall),RightWall.y(nWall),...
            RightWall.width(nWall),wallHeight],'Parent',hax);
        rectangle('position',[CenterWall.left(nWall),CenterWall.y(nWall),...
            CenterWall.width(nWall),wallHeight],'Parent',hax);
    end
end

% Plot radiation

if show
    theta=linspace(0,2*pi);
    
    for n=1:Radiation.numRad
        if Radiation.yCenter(n)>axmin && Radiation.yCenter(n)<axmax
            plot(hax,Radiation.rInner(n)*cos(theta)+Radiation.xCenter(n),...
                Radiation.rInner(n)*sin(theta)+Radiation.yCenter(n),'g')
            plot(hax,Radiation.rMiddle(n)*cos(theta)+Radiation.xCenter(n),...
                Radiation.rMiddle(n)*sin(theta)+Radiation.yCenter(n),'g')
            plot(hax,Radiation.rOuter(n)*cos(theta)+Radiation.xCenter(n),...
                Radiation.rOuter(n)*sin(theta)+Radiation.yCenter(n),'g')
        end
    end
end


hold on

% Plot Zombies

zombie=zombie+zombieStep;
if zombie>=y;
    zombie=y;
    alive=0;
else
    alive=1;
end
save('alivedata','alive')

if (zombie-1)>=axmin
    if graphics
        zom = imread('ZombieLine.jpg');
        zomImage = image('CData', zom, 'XData', [0, width],...
            'YData', [zombie+.7, zombie-.7]);
    else
        line([0,width],[zombie,zombie],'Color','r')
    end
end

if y>=LeftWall.y(nw) && nw<numWall-1
    nw=nw+1;
elseif nw>2 && nw<numWall && y<=LeftWall.y(nw-1)
    nw=nw-1;
end
hold on

% Plot Health
handles.hideBar.Visible='off';
healthBar=HealthBar(x,y,alive);
if healthBar<=0
    alive=0;
end
save('alivedata','alive')

bar(healthBar,'r','Parent',har)
axis(har,[.75,1,0,100])
har.XTick=[];
har.YTick=[];
hold off
drawnow

% Plot Progress
cla(pax)
axis(pax,[0,1,0,1])
axis(pax,'on')
pax.XTick=[];
pax.YTick=[];

if graphics
    progBack = image('CData',background,'Parent',pax);
    progBack.XData = [0,1];
    progBack.YData = [1,0];
    hold on;
    
    singleZ = imread('ZombieFig.jpg');
    zProgress = image('CData', singleZ,'Parent',pax);
    zProgress.XData = [zombie/ymax-.05,zombie/ymax];
    zProgress.YData = [1,0];
    hold on
    
    playerR = imread('playerR.jpg');
    pProgress = image('CData',playerR,'Parent',pax);
    pProgress.XData = [y/ymax-.05,y/ymax];
    pProgress.YData = [1,0];
    hold on
    
    checker = imread('Checkerboard.jpg');
    finishLine = image('CData',checker,'Parent',pax);
    finishLine.XData = [.95,1];
    finishLine.YData = [1,0];
    hold on
else
    line([y/ymax,y/ymax],[0,1],'Color','b','Parent',pax)
    line([zombie/ymax,zombie/ymax],[0,1],'Color','r','Parent',pax)
    line([1,1],[.05,.95],'Color','k','LineWidth',5,'Parent',pax)
end

drawnow
hold(pax,'off')

handles.HText.String=[num2str(round(healthBar)),'%'];

save('zomdata','zombie','zombieStep')
save('directiondata','direction','player')
save('walldata','LeftWall','RightWall','CenterWall','numWall','nw')
