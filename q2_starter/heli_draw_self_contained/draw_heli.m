%woody hoburg
%whoburg@berkeley.edu
%nov 6, 2009
%updated sep 30, 2012 to include tick marks and allow custom axis limits

%total mess as far as code style goes, but it's a black box and it works.

function draw_heli(t,x,axislim)

if nargin < 3
    axislim = 1.2*[-1 1 -1 1 -.1 2];
end

%expand x or y axis limits as necessary so that two views are to scale
xyrange = max(diff(axislim(1:2)), diff(axislim(3:4)));
xyrange = xyrange/2*[-1 1];
axislim(1:2) = mean(axislim(1:2))+xyrange;
axislim(3:4) = mean(axislim(3:4))+xyrange;
axislim

%define heli pieces
persistent hFig points inds colors;
if (isempty(points))
    hFig = figure(25);
    set(hFig,'DoubleBuffer', 'on');
    i = 0; inds = []; colors = ''; points = [];

    %canopy points
    cp = [[4.45; -3.18; 3.81] ...
        [9.53; -3.18; 3.81] ...
        [17.78;    0; 5.08] ...
        [7.62; -3.18; 12.0] ...
        [0;    -3.18; 12.7]]/100;
    canopy_right = [cp(:,1) cp(:,2) cp(:,4) cp(:,5)];
    points = [points canopy_right];
    inds = [inds; i+1 i+4]; i=i+4;
    colors(end+1) = 'r';
    canopy_bot1 = [cp(:,1) cp(:,2) cp(:,2) cp(:,1)];
    canopy_bot1(2,3:4) = -canopy_bot1(2,3:4);
    points = [points canopy_bot1];
    inds = [inds; i+1 i+4]; i=i+4;
    colors(end+1) = 'r';
    canopy_bot2 = [cp(:,2), cp(:,3), cp(:, 2)];
    canopy_bot2(2,3) = -canopy_bot2(2,3);
    points = [points canopy_bot2];
    inds = [inds; i+1 i+3]; i = i+3;
    colors(end+1) = 'r';
    canopy_left = canopy_right;
    canopy_left(2,:) = -canopy_left(2,:);
    points = [points canopy_left];
    inds = [inds; i+1 i+4]; i=i+4;
    colors(end+1) = 'r';
    canopy_rtfront = [cp(:,2) cp(:,3) cp(:,4)];
    points = [points canopy_rtfront];
    inds = [inds; i+1 i+3]; i = i+3;
    colors(end+1) = 'r';
    canopy_ltfront = canopy_rtfront;
    canopy_ltfront(2,:) = -canopy_ltfront(2,:);
    points = [points canopy_ltfront];
    inds = [inds; i+1 i+3]; i = i+3;
    colors(end+1) = 'r';
    canopy_front = [cp(:,4), cp(:,3), cp(:,4)];
    canopy_front(2,3) = -canopy_front(2,3);
    points = [points canopy_front];
    inds = [inds; i+1 i+3]; i = i+3;
    colors(end+1) = 'r';
    canopy_top = [cp(:,5), cp(:,4), cp(:,4), cp(:,5)];
    canopy_top(2,3:4) = -canopy_top(2,3:4);
    points = [points canopy_top];
    inds = [inds; i+1 i+4]; i=i+4;
    colors(end+1) = 'r';
    
    %tailboom
    points = [points [0; 0; .1016] [-.3318; 0; .1016]];
    inds = [inds; i+1 i+2]; i = i+2;
    colors(end+1) = 'k';
    
    %tail rotor
    th = 0:.3:2*pi;
    points = [points [-.3318+.063*cos(th); -.01*ones(size(th)); .1016+.063*sin(th)]];
    inds = [inds; i+1 i+length(th)]; i=i+length(th);
    colors(end+1) = 'b';
    
    %main shaft
    points = [points [0; 0; .0762] [0; 0; .2032]];
    inds = [inds; i+1 i+2]; i = i+2;
    colors(end+1) = 'k';
    
    %main rotor
    points = [points [.28*cos(th); .28*sin(th); .1937*ones(size(th))]];
    inds = [inds; i+1 i+length(th)]; i=i+length(th);
    colors(end+1) = 'g';

    points = [points [.0635; 0; .04] [-.0445; 0; .04]];
    inds = [inds; i+1 i+2]; i = i+2;
    colors(end+1) = 'k';
    
    %skids
    points = [points [-.0571; -.0476; 0] [.0825; -.0476; 0]];
    inds = [inds; i+1 i+2]; i = i+2;
    colors(end+1) = 'k';
    points = [points [-.0571; .0476; 0] [.0825; .0476; 0]];
    inds = [inds; i+1 i+2]; i = i+2;
    colors(end+1) = 'k';
    points = [points [.0825; -.0476; 0] [.1025; -.0476; .015]];
    inds = [inds; i+1 i+2]; i = i+2;
    colors(end+1) = 'k';
    points = [points [.0825; .0476; 0] [.1025; .0476; .015]];
    inds = [inds; i+1 i+2]; i = i+2;
    colors(end+1) = 'k';
    
    points = [points [-.0445; 0; .04] [-.04; -.0476; 0]];
    inds = [inds; i+1 i+2]; i = i+2;
    colors(end+1) = 'k';
    points = [points [-.0445; 0; .04] [-.04; .0476; 0]];
    inds = [inds; i+1 i+2]; i = i+2;
    colors(end+1) = 'k';
    points = [points [.0476; 0; .04] [.05; -.0476; 0]];
    inds = [inds; i+1 i+2]; i = i+2;
    colors(end+1) = 'k';
    points = [points [.0476; 0; .04] [.05; .0476; 0]];
    inds = [inds; i+1 i+2]; i = i+2;
    colors(end+1) = 'k';

    %move cg to [0 0 0] for rotation
    cg = repmat([0; 0; .127], 1, size(points, 2));
    points = points - cg;
end

%add heli pos to points
dp = quat2rmat(x(7:10))*points;
dp = dp + repmat(x(1:3),1,size(points,2));  %drawpoints

figure(hFig); hold on; 
subplot(1,2,1); view(0,0); cla;
do_draw;
subplot(1,2,2); view(90,0); cla;
do_draw;


    function do_draw
        for i = 1:size(inds,1)
            i1 = inds(i,1); i2 = inds(i,2);
            if(i2-i1 == 1)
                line(dp(1,i1:i2), dp(2,i1:i2), dp(3,i1:i2), 'color',colors(i), 'linewidth', 2);
            else
                patch(dp(1,i1:i2), dp(2,i1:i2), dp(3,i1:i2), colors(i));
            end
        end
        title(['t = ', num2str(t,'%.2f') ' sec']);
        %set(gca,'XTick',[],'YTick',[])
        
        patch(10*[-1,1,1,-1]', 10*[1,1,-1,-1]', [0,0,0,0]');
        axis equal; axis(axislim);
        
        drawnow;
    end

%status = 0;
end
