function bar_gra_avg_Callback(~, ~, ~)
% hObject    handle to bar_gra_avg (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

%% 1. Initial setting

% 1.1. Find mask files and the folder

    fclose all; %close all open files.
    [datafile,datapath]=uigetfile('Mask-*.txt','Choose a 2D Mask file'); % returns the file name and path to the file when the user clicks Open.
                                                                         % datafile显示mask名字,datapath显示mask路径
    if datafile==0, return; end
    cd(datapath); %displays the current folder.
    
% 1.2. Initail variables

    fileinfo = dir('Mask-*.txt'); % lists files and folders in the current folder.
    nfiles = numel(fileinfo); % returns the number of elements, n, in array A, 
    % mkdir('image average');
    % cd(datapath);    
    circlesize = 70;
    halfrange = round(circlesize/2);
    masksize = halfrange*2+1;
    temp_bar_count = zeros(10, 1); % no. of bars for each geometry diameter
    
% 1.3. Define main data structure
    
    barImage = repmat(struct('diameter',[], 'TXR', [], 'GFP', []), 10, 1); % B = repmat(A,n): returns an array containing n copies of A in the row and column dimensions. 
    
    % set space for 100 individual nanobar images
    nSingleBar = 100;
    
    for i = 1:10
        
        barImage(i).diameter = 100*i;
        
        barImage(i).TXR = repmat(struct('position',[], 'rawImage',[], 'imagebkgd', [], 'subimage',[]),nSingleBar,1);
        barImage(i).GFP = repmat(struct('position',[], 'rawImage',[], 'imagebkgd', [], 'subimage',[]),nSingleBar,1);
        
        
    end    



 % 1.4. Set up blank total average image for all 10 diameters
        bar_bucket_total = zeros(10, 1);
        bar_avg_TXR_total = zeros(masksize, masksize, 10);
        bar_avg_GFP_total = zeros(masksize, masksize, 10);
        
        
 % 1.5. Creat image average folder for total average image
       mkdir Total_average_image
       
       
%% 2. Image Processing

%   2.1 Loop all Mask file in the same folder one by one
    for i=1:nfiles
        
        maskname = fileinfo(i).name;
        
        % create _image average folder for each image
        foldername=strrep(strrep(maskname,'Mask-',''),'.txt','_image average');
        mkdir(foldername); %creates the folder folderName.
        
        % rename all the images
        %BFname = strrep(strrep(maskname,'Mask-',''),'.txt','_w1BF.TIF') ;
        TXRname = strrep(strrep(maskname,'Mask-',''),'.txt','_w2TXR.TIF') ;
        GFPname = strrep(strrep(maskname,'Mask-',''),'.txt','_w3GFP.TIF') ;
        
        % Setup blank average images for all 10 diameters
       bar_bucket = zeros(10, 1);
       %bar_avg_BF = zeros(masksize, masksize, 10);   %建10个51*51的array,会显示成(:,:,1-10)
       bar_avg_TXR = zeros(masksize, masksize, 10);
       bar_avg_GFP = zeros(masksize, masksize, 10);
        
        % read-in one mask file
        fileID = fopen(maskname,'r');% File identifier of an open text file, specified as an integer. 
                                     % Before reading a file with fscanf, you must use fopen to open the file and obtain the fileID.
        MaskPoints = fscanf(fileID,'%d %d %d', [3 inf]); % Read data from text file
        fclose(fileID);
        NumPoints = numel(MaskPoints(1,:)); % bar number 
        
        % read-in images that has mask drawn already
        if NumPoints > 0        
            %BFimage = imread(BFname);
            TXRimage = imread(TXRname);
            GFPimage = imread(GFPname);

    %   2.2 substract bleedthrough value at 647 channel (w3_GFP) in 1 image
%             Bleedthrough=TXRimage*0.016;
%             GFPimage_subBT=GFPimage-Bleedthrough;

    %   2.3 Loop through each mask /bar postion
               
            sz = size(TXRimage);
            ysize = sz(1);
            xsize = sz(2);  
            
            for p = 1:NumPoints
                
                xpos = MaskPoints(2,p);
                ypos = MaskPoints(1,p);
                barcode = MaskPoints(3,p); % rounds each element of X to the nearest integer greater than or equal to that element.
                temp_bar_count(barcode, 1) = temp_bar_count(barcode, 1) + 1;
                bar = temp_bar_count(barcode, 1);

                if xpos>=halfrange+1 && xpos<=ysize-halfrange && ypos>=halfrange+1 && ypos<=xsize-halfrange  %???

                   %take out masked area for local bkgd sub

                   txrArea=TXRimage(xpos-halfrange:xpos+halfrange,ypos-halfrange:ypos+halfrange);
                   gfpArea=GFPimage(xpos-halfrange:xpos+halfrange,ypos-halfrange:ypos+halfrange);

                   barImage(barcode).TXR(bar).rawImage = txrArea;
                   barImage(barcode).TXR(bar).position = [xpos ypos];
                   barImage(barcode).GFP(bar).rawImage = gfpArea;
                   barImage(barcode).GFP(bar).position = [xpos ypos];    

                   %caculate 3 corner bkgd, 5x5 area
                   txrbkg_start=mean(mean(txrArea(1:5,1:5)));
                   txrbkd_middle=mean(mean(txrArea(1:5,masksize-4:masksize)));
                   txrbkg_finish=mean(mean(txrArea(masksize-4:masksize,1:5)));

                   gfpbkg_start=mean(mean(gfpArea(1:5,1:5)));
                   gfpbkd_middle=mean(mean(gfpArea(1:5,masksize-4:masksize)));
                   gfpbkg_finish=mean(mean(gfpArea(masksize-4:masksize,1:5)));

                   %create blank bkgd image
                   txr_bkg_im=zeros(masksize);
                   gfp_bkg_im=zeros(masksize);

                   %% mashgrid,  have to check the orientation

                   % calculate step size
                   txr_step_y=(txrbkd_middle-txrbkg_start)/(masksize-1);
                   txr_step_x=(txrbkg_finish-txrbkg_start)/(masksize-1);
                   
                   gfp_step_y=(gfpbkd_middle-gfpbkg_start)/(masksize-1);
                   gfp_step_x=(gfpbkg_finish-gfpbkg_start)/(masksize-1);
                   
                   % generate mashgrid
                   y_temp_txr=txrbkg_start:txr_step_y:txrbkd_middle;
                   
                   if isempty(y_temp_txr) % txr_step_y==0
                       y_temp_txr=ones(1,masksize)*gfpbkg_start;
                   end
                   
                   x_temp_txr=0:txr_step_x:txrbkg_finish-txrbkg_start;

                   if isempty(x_temp_txr)  % txr_step_x==0 %
                       x_temp_txr=zeros(1,masksize);
                   end 
                   
                   [X_TEMP_txr, Y_TEMP_txr]=meshgrid(x_temp_txr,y_temp_txr);
                   txr_bkg_im=X_TEMP_txr+Y_TEMP_txr;
                   txr_bkg_im=txr_bkg_im'; % adjust orientation
                   
                   

                   y_temp_gfp=gfpbkg_start:gfp_step_y:gfpbkd_middle;

                   if isempty(y_temp_gfp) % gfp_step_y==0
                       y_temp_gfp=ones(1,masksize)*gfpbkg_start;
                   end
                   
                   x_temp_gfp=0:gfp_step_x:gfpbkg_finish-gfpbkg_start;

                   if isempty(x_temp_gfp) % gfp_step_x==0
                       x_temp_gfp=zeros(1,masksize);
                   end 
                   
                   [X_TEMP_gfp, Y_TEMP_gfp]=meshgrid(x_temp_gfp,y_temp_gfp);
                   gfp_bkg_im=X_TEMP_gfp+Y_TEMP_gfp;
                   gfp_bkg_im=gfp_bkg_im'; % adjust orientation
                 
                   
                   %% 3 point function
                   
%                    % set 3 points for plane generation
%                    txr_start = [1  1 txrbkg_start];
%                    txr_middle = [1  masksize  txrbkd_middle];
%                    txr_finish = [masksize  1  txrbkg_finish];
% 
%                    gfp_start = [1  1 gfpbkg_start];
%                    gfp_middle = [1  masksize  gfpbkd_middle];
%                    gfp_finish = [masksize  1  gfpbkg_finish];
%
%                    % calculate the normal index
%                    txr_normal = cross(txr_start-txr_middle, txr_start-txr_finish);
%                    gfp_normal = cross(gfp_start-gfp_middle, gfp_start-gfp_finish);
% 
%                    % generate the plane, TXR
%                    syms txr_x txr_y txr_z
%                    txr_bkg_point = [txr_x txr_y txr_z];
%                    txr_planefunction = dot(txr_normal, txr_bkg_point - txr_start);
%                    txr_bkg_int = solve(txr_planefunction,txr_z);
% 
%                    % write the background image, TXR
%                    for a=1:masksize
%                        for b=1:masksize
%                        txr_x=a;txr_y=b;
%                        txr_bkg_im(a,b)=eval(char(txr_bkg_int));
%                        end
%                    end
%                    
%                    % generate the plane, GFP
%                    syms gfp_x gfp_y gfp_z
%                    gfp_bkg_point = [gfp_x gfp_y gfp_z];
%                    gfp_planefunction = dot(gfp_normal, gfp_bkg_point - gfp_start);
%                    gfp_bkg_int = solve(gfp_planefunction,gfp_z);
% 
%                     % write the background image, GFP
%                     for a=1:masksize
%                        for b=1:masksize
%                        gfp_x=a;gfp_y=b;
%                        gfp_bkg_im(a,b)=eval(char(gfp_bkg_int));
%                        end
%                     end

                
                   %% subtract the background
                   
                   % remove negative numbers
                   txrArea_sub=max(double(txrArea)-txr_bkg_im,0);
        
                   gfpArea_sub=max(double(gfpArea)-gfp_bkg_im,0);

                   % save the images
                   barImage(barcode).TXR(bar).imagebkgd = txr_bkg_im;
                   barImage(barcode).GFP(bar).imagebkgd = gfp_bkg_im;

                   barImage(barcode).TXR(bar).subimage = txrArea_sub;
                   barImage(barcode).GFP(bar).subimage = gfpArea_sub;

                   % sum the indivudial bars for averaging later
                   bar_avg_TXR(:, :, barcode) = bar_avg_TXR(:, :, barcode) + double(txrArea_sub);
                   bar_avg_GFP(:, :, barcode) = bar_avg_GFP(:, :, barcode) + double(gfpArea_sub);
                   bar_bucket(barcode, 1) = bar_bucket(barcode, 1) + 1;
                   bar_bucket_total(barcode, 1) = bar_bucket_total(barcode, 1) + 1;
                   bar_avg_TXR_total(:, :, barcode) = bar_avg_TXR_total(:, :, barcode) + double(txrArea_sub);
                   bar_avg_GFP_total(:, :, barcode) = bar_avg_GFP_total(:, :, barcode) + double(gfpArea_sub);



                end
            end
        end
        save tempdata.mat;
        % image averaging of all diameters in the folder of one image
        cd(foldername);
        for j = 1:10
             if j < 10
                 MaskAvg_TXR = uint16(bar_avg_TXR(:, :, j)/bar_bucket(j,1));
                 MaskAvg_GFP = uint16(bar_avg_GFP(:, :, j)/bar_bucket(j,1));
                 imwrite(MaskAvg_TXR,['MaskAvg-' sprintf('bar-0%d_%d_', j, bar_bucket(j,1)) 'w2TXR.tif'],'Compression','none');
                 imwrite(MaskAvg_GFP,['MaskAvg-' sprintf('bar-0%d_%d_', j, bar_bucket(j,1)) 'w3GFP.tif'],'Compression','none'); 
             else
                 MaskAvg_TXR = uint16(bar_avg_TXR(:, :, j)/bar_bucket(j,1));
                 MaskAvg_GFP = uint16(bar_avg_GFP(:, :, j)/bar_bucket(j,1));
                 imwrite(MaskAvg_TXR,['MaskAvg-' sprintf('bar-%d_%d_', j, bar_bucket(j,1)) 'w2TXR.tif'],'Compression','none');
                 imwrite(MaskAvg_GFP,['MaskAvg-' sprintf('bar-%d_%d_', j, bar_bucket(j,1)) 'w3GFP.tif'],'Compression','none'); 
            end
        end

        fileID = fopen('bar_count.txt','w');
        fprintf(fileID,'%d %d %d %d %d %d %d %d %d %d\n',bar_bucket(:,1));% write data to text file
        fclose(fileID);
        save('barImage', 'barImage');
        save tempdata.mat;
        cd(datapath);
        
    end 
    
    cd Total_average_image
        for k = 1:10
                 if bar_bucket_total(k,1) > 0
                     MaskAvg_TXR_total = uint16(bar_avg_TXR_total(:, :, k)/bar_bucket_total(k,1));
                     MaskAvg_GFP_total = uint16(bar_avg_GFP_total(:, :, k)/bar_bucket_total(k,1));
                     imwrite(MaskAvg_TXR_total,['MaskAvg-' sprintf('bar-%d_%d_', k, bar_bucket_total(k,1)) 'w2TXR.tif'],'Compression','none');
                     imwrite(MaskAvg_GFP_total,['MaskAvg-' sprintf('bar-%d_%d_', k, bar_bucket_total(k,1)) 'w3GFP.tif'],'Compression','none'); 
                    
                end
            end
    
    save tempdata2.mat;
    cd(datapath);
   
%     for i = 1:10
%         if bar_bucket(i,1) > 0
%             
%             MaskAvg_TXR = uint16(bar_avg_TXR(:, :, i)/bar_bucket(i,1));
%             MaskAvg_GFP = uint16(bar_avg_GFP(:, :, i)/bar_bucket(i,1));
%            
%             imwrite(MaskAvg_TXR,['MaskAvg-' sprintf('bar-%d_%d_', i+1, bar_bucket(i,1)) 'w2TXR.tif'],'Compression','none');
%             imwrite(MaskAvg_GFP,['MaskAvg-' sprintf('bar-%d_%d_', i+1, bar_bucket(i,1)) 'w3GFP.tif'],'Compression','none'); 
%         end
%     end 
    
    
%     cd(datapath);
%     fileID = fopen('bar_count.txt','w');
%     fprintf(fileID,'%d %d %d %d %d %d %d %d %d %d\n',bar_bucket(:,1));
%     fclose(fileID);
%     save('barImage', 'barImage');
    clc;clear;
