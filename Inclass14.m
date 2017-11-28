%Inclass 14
%GB comments
100 Could run a loop on the threshold parameters and define the “best” mask
2a 100 
2b 100

%Work with the image stemcells_dapi.tif in this folder
filename = 'stemcells_dapi.tif';
img = imread(filename);
imshow(imadjust(img))
% (1) Make a binary mask by thresholding as best you can

mask = img > 310;
imshow(mask_improved);

% (2) Try to separate touching objects using watershed. Use two different
% ways to define the basins. 
%(A) With erosion of the mask 

improved_mask1 = imerode(imclose(imopen(mask, strel('disk', 2)), strel('disk', 2)),strel('disk', 2));
improved_mask2 = imdilate(imclose(imopen(mask, strel('disk', 2)), strel('disk', 2)),strel('disk', 4));
den_erode = -improved_mask1+1;
map_erode = imimposemin(den_erode,improved_mask2);
map = watershed(den_erode);
imshow(map); colormap('jet'); caxis([0 1024]);

%(B) with a distance transform. Which works better in this case?


CC = bwconncomp(mask);
stats = regionprops(CC,'Area');
area = [stats.Area];
fusedCandidates = area > mean(area) + std(area);
Sublist = CC.PixelIdxList(fusedCandidates);
Sublist = cat(1,Sublist{:});
mask_fused = false(size(img));
mask_fused(Sublist) = true;
imshow(mask_fused,'InitialMagnification','fit')
poshrink = round(1.2*sqrt(mean(area))/pi);
nucmin = imerode(mask_fused,strel('disk',poshrink));
imshow(nucmin,'InitialMagnification','fit');
outside = ~imdilate(mask_fused,strel('disk',1));
basin = imcomplement(bwdist(outside));
basin = imimposemin(basin,nucmin|outside);
map = watershed(basin);
imshow(map); colormap('jet'); caxis([0 1024]);
