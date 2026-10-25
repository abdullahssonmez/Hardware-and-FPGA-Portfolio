video = VideoReader('output.avi');
frameIdx = 1;

while hasFrame(video)
    frame = readFrame(video);
    
    if frameIdx == 10
        grayFrame = rgb2gray(frame);

        % Histogram verisini hesapla
        [counts, binEdges] = histcounts(grayFrame, 0:256);
        binCenters = binEdges(1:end-1) + 0.5;

        % Histogram çizimi (siyah çizgilerle)
        figure;
        bar(binCenters, counts, 'k');
        xlim([0 255]);
        title(['Histogram of Frame ', num2str(frameIdx)]);
        xlabel('Gray level');
        ylabel('Frequency count');
        grid on;
        
        break;
    end
    
    frameIdx = frameIdx + 1;
end
