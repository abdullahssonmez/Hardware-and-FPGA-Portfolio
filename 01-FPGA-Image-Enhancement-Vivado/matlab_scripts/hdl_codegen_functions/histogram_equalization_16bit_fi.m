function v_out = histogram_equalization(v_in)
%#codegen

persistent hist cdf

% Çıkış boyutunu ve türünü belirleme
v_out = coder.nullcopy(zeros(size(v_in), 'uint8')); 

if isempty(hist)
    hist = fi(zeros(1,256), 0, 16, 0); % 16-bit sabit nokta histogram
    cdf  = fi(zeros(1,256), 0, 16, 0); % 16-bit sabit nokta CDF
end

% Histogram hesaplama
for i = 1:length(v_in)
    hist(v_in(i) + 1) = hist(v_in(i) + 1) + 1;
end

% Kümülatif dağılım fonksiyonu (CDF) hesaplama
cdf(1) = hist(1);
for j = 2:256
    cdf(j) = cdf(j-1) + hist(j); 
end

% Normalize etme (CDF'nin son elemanına göre normalize et)
max_cdf_value = double(cdf(256)); % veya cdf(end)
% Normalize edilmiş CDF'yi farklı bir değişkende saklayın
cdf_norm = fi(255 * double(cdf) / max_cdf_value, 0, 16, 0); 

% Yeni parlaklık değerlerini eşitleme
for i = 1:length(v_in)
    v_out(i) = uint8(double(cdf_norm(v_in(i) + 1))); 
end

end
