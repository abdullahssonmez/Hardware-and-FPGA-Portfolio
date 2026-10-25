function [R, G, B] = hsv2rgb_hdl(H, S, V)
%#codegen
% Bu fonksiyon, histogram equalization uygulanmış V değeriyle birlikte
% H ve S kanallarından RGB dönüşümü gerçekleştirir.
%
% Girişler:
%   H - [270x372] double matris, hue değeri (0 ile 360 derece arası)
%   S - [270x372] double matris, saturation (0 ile 1 arasında)
%   V - [270x372] double matris, histogram equalization uygulanmış value (0 ile 1 arasında)
%
% Çıkışlar:
%   R, G, B - [270x372] uint8 matrisler, 0-255 aralığında RGB değerleri

% Sabit boyutlar
rows = 270;
cols = 372;

% Çıkış dizilerini önceden tanımla.
R = zeros(rows, cols, 'uint8');
G = zeros(rows, cols, 'uint8');
B = zeros(rows, cols, 'uint8');

for i = 1:rows
    for j = 1:cols
        % Her bir piksel için HSV değerlerini oku.
        h = H(i, j);
        s = S(i, j);
        v = V(i, j);
        
        % Güvenlik: Eğer h 360 veya daha büyükse hue 0 kabul edilir.
        if h >= 360
            h = 0;
        end
        
        % Eğer doyma yoksa renk gri tonlardadır.
        if s == 0
            r_val = v;
            g_val = v;
            b_val = v;
        else
            % HSV -> RGB dönüşümü:
            % Hue değeri 60'a bölünerek hangi segmentte olduğumuz bulunur.
            h_sector = h / 60.0;
            i_sector = floor(h_sector);  % Bu değer 0 ile 5 arasında olacaktır.
            f = h_sector - i_sector;
            
            % Ara değerler hesaplanıyor.
            p = v * (1 - s);
            q = v * (1 - s * f);
            t = v * (1 - s * (1 - f));
            
            % i_sector değerine göre RGB hesaplanıyor.
            if i_sector == 0
                r_val = v;
                g_val = t;
                b_val = p;
            elseif i_sector == 1
                r_val = q;
                g_val = v;
                b_val = p;
            elseif i_sector == 2
                r_val = p;
                g_val = v;
                b_val = t;
            elseif i_sector == 3
                r_val = p;
                g_val = q;
                b_val = v;
            elseif i_sector == 4
                r_val = t;
                g_val = p;
                b_val = v;
            elseif i_sector == 5
                r_val = v;
                g_val = p;
                b_val = q;
            else
                % Bu durum normalde gerçekleşmez; güvenlik için.
                r_val = v;
                g_val = v;
                b_val = v;
            end
        end
        
        % 0-1 aralığındaki değerleri 0-255 aralığına ölçeklendirip uint8 çeviriyoruz.
        R(i, j) = uint8(r_val * 255);
        G(i, j) = uint8(g_val * 255);
        B(i, j) = uint8(b_val * 255);
    end
end

end
