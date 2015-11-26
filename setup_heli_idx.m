function idx = setup_heli_idx

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% set up idx, model params, model features  %%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
k=1;
idx.ned_dot = k:k+2; k=k+3;
idx.ned = k:k+2; k=k+3; %North, East, Down
idx.pqr = k:k+2; k=k+3; % angular rate around x, y, z of helicopter
idx.axis_angle = k:k+2; k=k+3;
