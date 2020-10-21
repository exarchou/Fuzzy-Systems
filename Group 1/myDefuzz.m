function defuzzfun = COS_defuzzifier(xmf, ymf)

    [pks, locs] = findpeaks(ymf, xmf);
    weightedAreaSum = 0;
    areaSum = 0;
 
    for i = 1:length(pks)

        startIndex = find(xmf == locs(i)); 
        endIndex = startIndex + length(ymf(ymf == ymf(startIndex))) - 1; % calculate the number of the times that ymf(1) appears in the array
        upper = abs(xmf(endIndex) - xmf(startIndex)); % calculate the length of the small base of the trapezoid
        area = (0.5 + upper) * pks(i) / 2; % trapezoidal surface
        center = (xmf(endIndex) + xmf(startIndex) ) / 2;
        areaSum = areaSum + area;
        weightedAreaSum = weightedAreaSum + area * center;
        
    end

    
    % Check the NV and PV as findpeaks cannot locate them
    if (ymf(1) ~= 0) 
        
        startIndex = 1;
        endIndex = startIndex + length(ymf(ymf == ymf(startIndex))) - 1; % calculate the number of the times that ymf(1) appears in the array
        upper = abs(xmf(endIndex) - xmf(startIndex)); % upper base of the trapezoid
        area = (0.25 + upper) * ymf(1) / 2; % trapezoidal surface
        function1 = @(w) (ymf(1) * w); % constant function
        function2 = @(w) ((ymf(1) / (xmf(endIndex) + 0.5)) .* (w + 0.5) .* w); % y = ax + b, with values for a and b

        q = integral(function1, - 1, xmf(endIndex)) + integral(function2, xmf(endIndex), - 0.5);

        center =  q / area;
        areaSum = areaSum + area;
        weightedAreaSum = weightedAreaSum + center * area;
        
    end

    if (ymf(end) ~= 0) 
        
        startIndex = 101;
        endIndex = startIndex - length(ymf(ymf == ymf(startIndex))) - 1; % same as before
        upper = abs(- xmf(endIndex) + xmf(startIndex));
        area = (0.25 + upper) * ymf(end) / 2;
        function1 = @(w) ((ymf(end) / (xmf(endIndex) - 0.50)) .* (w - 0.50) .* w);
        function2 = @(w) (ymf(end) * w);

        q = integral(function1, 0.50, xmf(endIndex)) + integral(function2, xmf(endIndex), 1);

        center = q / area;
        areaSum = areaSum + area;
        weightedAreaSum = weightedAreaSum + center * area;
        
    end

    defuzzfun = weightedAreaSum / areaSum;

end