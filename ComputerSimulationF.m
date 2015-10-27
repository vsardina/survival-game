function ComputerSimulationF(handles)
% function ComputerSimulationF(handles)
%   Runs computer simulations of game
%   If one simulation, displays gameplay. If more than one keeps and
%   displays statistics

%% Initialize Vectors

nSim=str2double(handles.SimText.String);
handles.hideBox.Visible='on';
win=zeros(1,nSim);
health=zeros(1,nSim);
completion=zeros(1,nSim);
caught=zeros(1,nSim);
hwb=waitbar(0,'Simulating...','Name',['Computer Simulations(0 of ',num2str(nSim),')']);

for iSim=1:nSim
    hwb.Name=['Computer Simulations(',num2str(iSim),' of ',num2str(nSim),')'];
    %% Set Parameters
    load('stopdata')
    if stop
        handles.hideBox.Visible='off';
        cla(handles.HBar);
        cla(handles.ProgressAxes);
        cla(handles.PlotAxes);
        handles.statPanel.Visible='off';
        handles.HBar.Visible='off';
        handles.TimeText.Visible='off';
        handles.HText.Visible='off';
        handles.ProgressAxes.Visible='off';
        axis(handles.PlotAxes,[0,10,0,10])
        opening = imread('Opener.jpg');
        openerImage = image('CData', opening);
        openerImage.XData = [0,10];
        openerImage.YData = [10,0];
        break
    end
    SetParameters(handles)
    load('parameters')
    load('walldata')
    load('raddata')
    load('positiondata')
    load('directiondata')
    load('zomdata')
    load('alivedata')
    load('itemdata')
    load('timedata')
    
    %% Calculate Walk
    [x,y,zombie,alive,player]=CalculateWalk(hwb,nSim,iSim);
    
    %% Calculates Health Bar
    
    t=linspace(0,Z*length(x),length(x)); % Delta t is 15 min
    save('timedata','t','Z')
    
    [healthBar,tf,alive]=HealthBar(x,y,alive); % tf is index of t, not actual time
    
    if nSim>1
        health(iSim)=healthBar(tf);
        completion(iSim)=y(tf)/ymax;
        if alive
            win(iSim)=1;
            caught(iSim)=0;
        else
            win(iSim)=0;
            if zombie(tf)==y(tf)
                caught(iSim)=1;
            else
                caught(iSim)=0;
            end
        end
        
    end
    waitbar(iSim/nSim,hwb);
end
close(hwb)

%% Calculate Stats
if nSim>1 && ~stop
    
    wPercent=sum(win)/nSim*100; % Win percentage
    cPercent=sum(completion)/nSim*100; % Average completion percentage
    if sum(win)==0;
        hPercent=0; % Avoids dividing by 0
    else
        hPercent=sum(health)/sum(win); % Average health remaining (wins only)
    end
    zPercent=sum(caught)/(nSim-sum(win))*100; % Percentage of deaths caused by zombies
end

%% Plot
handles.hideBox.Visible='off';

if nSim==1 && ~stop
    %% Plot Walk and Healthbar
    handles.HText.Visible='on';
    handles.HBar.Visible='on';
    handles.TimeText.Visible='on';
    handles.statPanel.Visible='off';
    
    hax=handles.PlotAxes;
    har=handles.HBar;
    pax=handles.ProgressAxes;
    
    for i=1:tf
        load('stopdata')
        load('graphics')
        
        % Determines axes
        if y(i)<10*stepLength
            axmin=0;
            axmax=20*stepLength;
        elseif ymax-y(i)<10*stepLength
            axmin=ymax-20*stepLength;
            axmax=ymax;
        else
            axmin=y(i)-10*stepLength;
            axmax=y(i)+10*stepLength;
        end
        hax.XTick=[];
        hax.YTick=[];
        axis(hax,[0,width,axmin,axmax])
        
        if stop
            opening = imread('Opener.jpg');
            openerImage = image('CData', opening);
            openerImage.XData = [0,width];
            openerImage.YData = [axmax,axmin];
            break
        end
        
        % Plot Player
        if graphics
            % Add background
            background = imread('dirt.jpg');
            backImage = image('CData', background,'Parent',hax);
            backImage.XData = [0,width];
            backImage.YData = [axmin, axmax];
            hold(hax,'on');
            
            % Add player
            playerImage = image('CData', player{i},'Parent',hax);
            playerImage.XData = [x(i)-.4,x(i)+.4];
            playerImage.YData = [y(i)+1.6,y(i)];
        else
            plot(hax,x(i),y(i),'bo')
            axis(hax,[0,width,axmin,axmax])
            hax.XTick=[];
            hax.YTick=[];
        end
        
        
        % Plot walls
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
        
        hold(hax,'on')
        
        % Plot radiation
        
        if show
            theta=linspace(0,2*pi);
            
            for n=1:Radiation.numRad
                hold(hax,'on')
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
        
        % Plots Zombies
        
        if (zombie(i)-1)>=axmin
            if graphics
                zom = imread('ZombieLine.jpg');
                zomImage = image('CData', zom,'Parent',hax);
                zomImage.XData = [0, width];
                zomImage.YData = [zombie(i)+.7, zombie(i)-.7];
            else
                line([0,width],[zombie(i),zombie(i)],'Color','r','Parent',hax)
            end
        end
        
        drawnow
        hold(hax,'off')
        
        % Plots Health
        
        handles.hideBar.Visible='off';
        bar(healthBar(i),'r','Parent',har)
        axis(har,[.75,1,0,100])
        har.XTick=[];
        har.YTick=[];
        drawnow
        handles.HText.String=[num2str(round(healthBar(i))),'%'];
        hold(har,'off')
        
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
            zProgress.XData = [zombie(i)/ymax-.05,zombie(i)/ymax];
            zProgress.YData = [1,0];
            hold on
            
            playerR = imread('playerR.jpg');
            pProgress = image('CData',playerR,'Parent',pax);
            pProgress.XData = [y(i)/ymax-.05,y(i)/ymax];
            pProgress.YData = [1,0];
            hold on
            
            checker = imread('Checkerboard.jpg');
            finishLine = image('CData',checker,'Parent',pax);
            finishLine.XData = [.95,1];
            finishLine.YData = [1,0];
            hold on
        else
            line([y(i)/ymax,y(i)/ymax],[0,1],'Color','b','Parent',pax)
            line([zombie(i)/ymax,zombie(i)/ymax],[0,1],'Color','r','Parent',pax)
            line([1,1],[.05,.95],'Color','k','LineWidth',5,'Parent',pax)
        end
        
        drawnow
        hold(pax,'off')
        
        handles.TimeText.String=['Time: ',num2str(round(t(i),2))];
    end
    
    % After Game Ends
    handles.GoButton.Value=0;
    handles.TimeText.Visible='off';
    healthBar=0;
    bar(healthBar,'r','Parent',har)
    cla(har)
    handles.HBar.Visible='off';
    handles.HText.Visible='off';
    cla(pax)
    axis(pax,'off')
    if alive && ~handles.EndButton.Value
        wPercent = imread('WinClose.jpg');
        winImage = image('CData', wPercent,'Parent',hax);
        winImage.XData = [0,width];
        winImage.YData = [axmax,axmin];
    elseif ~handles.EndButton.Value
        lose = imread('LoseClose.jpg');
        loseImage = image('CData', lose,'Parent',hax);
        loseImage.XData = [0,width];
        loseImage.YData = [axmax,axmin];
    else
        opening = imread('Opener.jpg');
        openerImage = image('CData', opening,'Parent',hax);
        openerImage.XData = [0,-width];
        openerImage.YData = [-axmax,-axmin];
    end
    
elseif ~stop
    %% Plot Stats
    handles.hideBox.Visible='off';
    handles.statPanel.Visible='on';
    axis(handles.PlotAxes,'off')
    
    pa1=handles.pa1;
    pa2=handles.pa2;
    pa3=handles.pa3;
    pa4=handles.pa4;
    
    bar(wPercent,'b','Parent',pa1)
    pa1.XTick=[];
    title(pa1,'Win Percentage')
    ylabel(pa1,'%')
    axis(pa1,[.6,.61,0,100])
    hold on
    
    bar(cPercent,'b','Parent',pa2)
    pa2.XTick=[];
    title(pa2,'Average Completion Percentage')
    ylabel(pa2,'%')
    axis(pa2,[.6,.61,0,100])
    hold on
    
    
    bar(hPercent,'b','Parent',pa3)
    pa3.XTick=[];
    title(pa3,'Average Health Remaining (Wins Ony)')
    ylabel(pa3,'%')
    axis(pa3,[.6,.61,0,100])
    hold on
    
    bar(zPercent,'b','Parent',pa4)
    pa1.XTick=[];
    title(pa4,'Percentage of Zombie Deaths')
    ylabel(pa4,'%')
    axis(pa4,[.6,.61,0,100])
    
    handles.WinText.String=['Wins: ',num2str(sum(win)),];
    handles.LossText.String=['Losses: ',num2str(nSim-sum(win))];
    handles.CPText.String=['Avg. Completion Percentage: ',num2str(round(cPercent,3,'significant')),'%'];
    handles.HRText.String=['Avg. Health Remaining: ',num2str(round(hPercent,3,'significant')),'%'];
    handles.ZomText.String=['Zombie Deaths: ',num2str(sum(caught))];
    
    iText.item=[items.Geiger,items.Medicine,items.Febreeze,items.Running];
    iText.Strings={'Geiger Counter','Medicine','Febreeze','Running Shoes'};
    
    item1='None';
    item2='';
    if handles.DifficultyPopUp.Value==1
        mode='Easy';
        next=0;
        for j=1:4
            if iText.item(j)
                if next
                    item2=[', ',iText.Strings{j}];
                    break
                end
                item1=iText.Strings{j};
                next=1;
            end
        end
                
    else
        mode='Hard';
        for j=1:4
            if iText.item(j)
                item1=iText.Strings{j};
                break
            end
        end
    end
    
    
    handles.ModeText.String=['Mode: ',mode];
    if strcmp(mode,'Easy')
        handles.ItemText.String=['Items: ',item1,item2];
    else
        handles.ItemText.String=['Items: ',item1];
    end
    
    hold off
    
    handles.GoButton.Value=0;
end