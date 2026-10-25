
% Görüntüyü okuma
img = imread('chaledresult.jpg');

% Görüntüyü gri tonlamaya çevirme (zaten gri değilse)
gray_img = rgb2gray(img);

% Histogram verilerini hesaplama
[counts, gray_levels] = imhist(gray_img);
counts(1) = counts(1) * 0.1;
% Histogramı çizme
figure;
bar(gray_levels, counts, 'k'); % siyah çubuklar
xlabel('Gray level');
ylabel('Frequency count');
title('Histogram of Grayscale Image');
xlim([0 255]);
ylim([0 10000]);