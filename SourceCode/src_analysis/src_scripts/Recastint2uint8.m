function ImOut = Recastint2uint8(Im, quant)
% casting Im to a new type and rescaling at the same time using quantiles

mini = quantile(Im(:), 1-quant);
maxi = quantile(Im(:), quant);

ImOut = zeros(size(Im));
ImOut = (Im-mini)*255./(maxi-mini);
ImOut = uint8(ImOut);

end

