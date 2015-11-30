function [ clamped_control ] = clamp_control( control, u_min, u_max )
%CLAMP_CONTROL clamp control between the min and max

    clamped_control = max(min(control, u_max), u_min);


end

