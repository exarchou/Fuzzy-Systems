function [dv, dh] = distance_sensor(x, y)
% diastance_sensor is a function that returns the vertical and horizontal
% distance from obstacles by separating the map in 4 areas, depending on x.

if (x <= 10)
    
    dv = -y; % y is negative.
    
    if (y >= -5)
        
        dh = 10 - x;
        
    elseif (y >= -6)
        
        dh = 11 - x;
        
    elseif (y >= -7)
        
        dh = 12 - x;
        
    else
        
        dh = 16 - x; % horizontal deviation is not such a problem. Emphasis on y.
        
    end
    
elseif (x <= 11)
    
    dv = 5 - y;
    
    if (y >= -6)
        
        dh  = 11 - x;
        
    elseif (y >= -7)
        
        dh = 12 - x;
        
    else
        
        dh = 16 - x;
        
    end
    
elseif (x <= 12)
    
    dv = 6 - y;
    
    if (y >= -7)
        
        dh = 12 - x;
        
    else
        
        dh = 16 - x;
        
    end
    
elseif (x <= 15)
    
    dv = 7 - y;
    dh = 16 - x;
    
end

% dv and dh cannot be grater than 1.
if (dv > 1)
    
    dv = 1;
    
end

if (dh > 1)
    
    dh = 1;
    
end

end